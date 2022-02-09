//
//  AddressService.swift
//  SnappyV2
//
//  Created by Kevin Palser on 14/01/2022.
//

import Combine
import Foundation

enum AddressServiceError: Swift.Error {
    case unableToPersistResult
    case invalidParameters([String])
}

extension AddressServiceError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .unableToPersistResult:
            return "Unable to persist web fetch result"
        case let .invalidParameters(parameters):
            return "Parameters Error: \(parameters.joined(separator: ", "))"
        }
    }
}

protocol AddressServiceProtocol {
    // Used to fetch address to automatically populate address fields based on a
    // postcode. At the time of writing (14/01/2022) this can only return UK
    // addresses.
    func findAddresses(addresses: LoadableSubject<[FoundAddress]?>, postcode: String, countryCode: String)
    
    // Used to fetch countries that can be shown as options in the customer address
    // forms.
    func getSelectionCountries(countries: LoadableSubject<[AddressSelectionCountry]?>)
}

struct AddressService: AddressServiceProtocol {

    let webRepository: AddressWebRepositoryProtocol
    let dbRepository: AddressDBRepositoryProtocol
    
    private var cancelBag = CancelBag()
    
    init(webRepository: AddressWebRepositoryProtocol, dbRepository: AddressDBRepositoryProtocol) {
        self.webRepository = webRepository
        self.dbRepository = dbRepository
    }
    
    func findAddresses(addresses: LoadableSubject<[FoundAddress]?>, postcode: String, countryCode: String) {
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
    
    private var requestHoldBackTimeInterval: TimeInterval {
        return ProcessInfo.processInfo.isRunningTests ? 0 : 0.5
    }

}

struct StubAddressService: AddressServiceProtocol {
    func findAddresses(addresses: LoadableSubject<[FoundAddress]?>, postcode: String, countryCode: String) { }
    func getSelectionCountries(countries: LoadableSubject<[AddressSelectionCountry]?>) { }
}
