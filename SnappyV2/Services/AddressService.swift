//
//  AddressService.swift
//  SnappyV2
//
//  Created by Kevin Palser on 14/01/2022.
//

import Combine
import Foundation

enum AddressServiceError: Swift.Error, Equatable {
    case unableToPersistResult
    case invalidParameters([String])
    case noAddressesFound
    case postcodeFormatNotRecognised(String)
}

extension AddressServiceError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .unableToPersistResult:
            return "Unable to persist web fetch result"
        case let .invalidParameters(parameters):
            return "Parameters Error: \(parameters.joined(separator: ", "))"
        case .noAddressesFound:
            return Strings.AddressService.noAddressesFound.localized
        case let .postcodeFormatNotRecognised(postcode):
            return Strings.General.Search.Customisable.postcodeFormatError.localizedFormat(postcode)
        }
    }
}

protocol AddressServiceProtocol {
    // Used to fetch address to automatically populate address fields based on a
    // postcode. At the time of writing (14/01/2022) this can only return UK
    // addresses.
    func findAddresses(addresses: LoadableSubject<[FoundAddress]?>, postcode: String, countryCode: String)
    
    func findAddressesAsync(postcode: String, countryCode: String) async throws -> [FoundAddress]?
    
    // Used to fetch countries that can be shown as options in the customer address
    // forms.
    func getSelectionCountries(countries: LoadableSubject<[AddressSelectionCountry]?>)
}

struct AddressService: AddressServiceProtocol {

    let webRepository: AddressWebRepositoryProtocol
    let dbRepository: AddressDBRepositoryProtocol
    // Used purely to harness the PostcodeRules if available in the
    // loaded business profile
    let appState: Store<AppState>
    
    let eventLogger: EventLoggerProtocol
    
    init(webRepository: AddressWebRepositoryProtocol, dbRepository: AddressDBRepositoryProtocol, appState: Store<AppState>, eventLogger: EventLoggerProtocol) {
        self.webRepository = webRepository
        self.dbRepository = dbRepository
        self.appState = appState
        self.eventLogger = eventLogger
    }
    
    func findAddresses(addresses: LoadableSubject<[FoundAddress]?>, postcode: String, countryCode: String) {
        
        guard checkPostcodeFormat(for: postcode, countryCode: countryCode) else {
            addresses.wrappedValue = .failed(AddressServiceError.postcodeFormatNotRecognised(postcode))
            return
        }
        
        let cancelBag = CancelBag()
        addresses.wrappedValue.setIsLoading(cancelBag: cancelBag)
        
        return dbRepository
            .findAddressesFetch(
                postcode: postcode,
                countryCode: countryCode
            )
            .flatMap { searchResult -> AnyPublisher<[FoundAddress]?, Error> in
                if
                    let searchResult = searchResult,
                    // check that the data is not too old
                    let fetchTimestamp = searchResult.fetchTimestamp,
                    fetchTimestamp > AppV2Constants.Business.addressesCachedExpiry
                {
                    // return the cached result
                    return Just<[FoundAddress]?>.withErrorType(searchResult.addresses, Error.self)
                } else {
                    // clear any cached result, fetch from the API, cache and then return
                    return dbRepository
                        .clearAddressesFetch(postcode: postcode, countryCode: countryCode)
                        .flatMap { _ -> AnyPublisher<[FoundAddress]?, Error> in
                            return webRepository
                                .findAddresses(postcode: postcode, countryCode: countryCode)
                                .ensureTimeSpan(requestHoldBackTimeInterval)
                                .flatMap { fetchedAddresses -> AnyPublisher<[FoundAddress]?, Error> in
                                    return dbRepository
                                        .store(
                                            addresses: fetchedAddresses,
                                            postcode: postcode,
                                            countryCode: countryCode
                                        )
                                        // need to map from AddressesSearch?
                                        // to [FoundAddress]?
                                        .flatMap { fetch -> AnyPublisher<[FoundAddress]?, Error> in
                                            if let fetch = fetch {
                                                return Just<[FoundAddress]?>.withErrorType(fetch.addresses, Error.self)
                                            } else {
                                                return Fail<[FoundAddress]?, Error>(error: AddressServiceError.unableToPersistResult)
                                                    .eraseToAnyPublisher()
                                            }
                                        }
                                        .eraseToAnyPublisher()
                                }.eraseToAnyPublisher()
                        }.eraseToAnyPublisher()
                }
            }
            .eraseToAnyPublisher()
            .receive(on: RunLoop.main)
            .sinkToLoadable { addresses.wrappedValue = $0 }
            .store(in: cancelBag)
    }
    
    // A duplicate of the above method but using async. We will phase out the above combined method
    func findAddressesAsync(postcode: String, countryCode: String) async throws -> [FoundAddress]? {
        
        guard checkPostcodeFormat(for: postcode, countryCode: countryCode) else {
            throw AddressServiceError.postcodeFormatNotRecognised(postcode)
        }
        
        do {
            let cachedAddressSearch = try await dbRepository
                .findAddressesFetch(
                    postcode: postcode,
                    countryCode: countryCode).singleOutput()
            
            // Check that the data is not too old
            if let cachedAddressSearch = cachedAddressSearch,
               let fetchTimestamp = cachedAddressSearch.fetchTimestamp,
               fetchTimestamp > AppV2Constants.Business.addressesCachedExpiry {
                return cachedAddressSearch.addresses
            }
            
            // If no cached results OR data too old, clear the cache
            let _ = try await dbRepository.clearAddressesFetch(postcode: postcode, countryCode: countryCode).singleOutput()
            
            // Fetch addresses from API
            let addressesFromWeb = try await webRepository
                .findAddresses(postcode: postcode, countryCode: countryCode).singleOutput()
            
            // Store addresses to db
            let _ = try await dbRepository
                .store(
                    addresses: addressesFromWeb,
                    postcode: postcode,
                    countryCode: countryCode).singleOutput()
            
            return addressesFromWeb
        } catch {
            #warning("There is currentlly an issue whereby the error result is not always returned as an error, but as a dictionary containing the error description. This causes an internal decoding error and also means we cannot consume the error description to show to the user. For now, we are using this generic error for all cases but this needs looking into separately.")
            throw AddressServiceError.noAddressesFound
        }
    }
    
    func getSelectionCountries(countries: LoadableSubject<[AddressSelectionCountry]?>) {
        let cancelBag = CancelBag()
        countries.wrappedValue.setIsLoading(cancelBag: cancelBag)
        
        let languageCode = AppV2Constants.Client.languageCode
        
        return dbRepository
            .findAddressSelectionCountriesFetch(forLocaleCode: languageCode)
            .flatMap { fetchResult -> AnyPublisher<[AddressSelectionCountry]?, Error> in
                if
                    let fetchResult = fetchResult,
                    // check that the data is not too old
                    let fetchTimestamp = fetchResult.fetchTimestamp,
                    fetchTimestamp > AppV2Constants.Business.addressesCachedExpiry
                {
                    // return the cached result
                    return Just<[AddressSelectionCountry]?>.withErrorType(fetchResult.countries, Error.self)
                } else {
                    // clear any cached result, fetch from the API, cache and then return
                    return dbRepository
                        .clearAddressSelectionCountriesFetch(forLocaleCode: languageCode)
                        .flatMap { _ -> AnyPublisher<[AddressSelectionCountry]?, Error> in
                            return webRepository
                                .getCountries()
                                .ensureTimeSpan(requestHoldBackTimeInterval)
                                .flatMap { fetchedCountries -> AnyPublisher<[AddressSelectionCountry]?, Error> in
                                    return dbRepository
                                        .store(countries: fetchedCountries, forLocaleCode: languageCode)
                                        // need to map from AddressSelectionCountriesFetch?
                                        // to [AddressSelectionCountry]?
                                        .flatMap { fetch -> AnyPublisher<[AddressSelectionCountry]?, Error> in
                                            if let fetch = fetch {
                                                return Just<[AddressSelectionCountry]?>.withErrorType(fetch.countries, Error.self)
                                            } else {
                                                return Fail<[AddressSelectionCountry]?, Error>(error: AddressServiceError.unableToPersistResult)
                                                    .eraseToAnyPublisher()
                                            }
                                        }
                                        .eraseToAnyPublisher()
                                }.eraseToAnyPublisher()
                        }.eraseToAnyPublisher()
                }
            }
            .eraseToAnyPublisher()
            .sinkToLoadable { countries.wrappedValue = $0 }
            .store(in: cancelBag)
    }
    
    private func checkPostcodeFormat(for postcode: String, countryCode: String) -> Bool {
        let lowercasedCountryCode = countryCode.lowercased()
        if
            let businessProfile = appState.value.businessData.businessProfile,
            let postcodeRules = businessProfile.postcodeRules
        {
            return postcode.isPostcode(rules: postcodeRules.filter {
                // GB is UK for this comparision
                $0.countryCode.lowercased() == lowercasedCountryCode || (lowercasedCountryCode == "uk" && $0.countryCode.lowercased() == "gb")
            })
        }
        return true
    }
    
    private var requestHoldBackTimeInterval: TimeInterval {
        return ProcessInfo.processInfo.isRunningTests ? 0 : 0.5
    }

}

struct StubAddressService: AddressServiceProtocol {
    func findAddressesAsync(postcode: String, countryCode: String) async throws -> [FoundAddress]? { return nil }

    func findAddresses(addresses: LoadableSubject<[FoundAddress]?>, postcode: String, countryCode: String) { }
    func getSelectionCountries(countries: LoadableSubject<[AddressSelectionCountry]?>) { }
}
