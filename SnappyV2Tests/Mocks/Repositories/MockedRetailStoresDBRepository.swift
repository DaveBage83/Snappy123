//
//  MockedRetailStoresDBRepository.swift
//  SnappyV2Tests
//
//  Created by Kevin Palser on 26/09/2021.
//

import XCTest
import Combine
import CoreLocation
@testable import SnappyV2

//extension RetailStoresSearch: Equatable {}
public func ==(lhs: RetailStoresSearch, rhs: RetailStoresSearch) -> Bool {
    if
        let lhsLat = lhs.latitude,
        let lhsLng = lhs.longitude,
        let rhsLat = rhs.latitude,
        let rhsLng = rhs.longitude
    {
        return CLLocationCoordinate2D(latitude: lhsLat, longitude: lhsLng) == CLLocationCoordinate2D(latitude: rhsLat, longitude: rhsLng)
    }
    return lhs.postcode == rhs.postcode || lhs.longitude == rhs.longitude
}

extension RetailStoreDetails: Equatable {}
public func ==(lhs: RetailStoreDetails, rhs: RetailStoreDetails) -> Bool {
    if
        let lhsSearchPostcode = lhs.searchPostcode,
        let rhsSearchPostcode = rhs.searchPostcode
    {
        return lhsSearchPostcode == rhsSearchPostcode && lhs.id == rhs.id
    }
    return lhs.id == rhs.id
}

extension RetailStoreTimeSlots: Equatable {}
public func ==(lhs: RetailStoreTimeSlots, rhs: RetailStoreTimeSlots) -> Bool {
    
    if (lhs.searchStoreId != rhs.searchStoreId) || (lhs.fulfilmentMethod != rhs.fulfilmentMethod) {
        return false
    }
    
    if RetailStoreOrderMethodType(rawValue: lhs.fulfilmentMethod) == .delivery {
        
    }
    
    return true
}

final class MockedRetailStoresDBRepository: Mock, RetailStoresDBRepositoryProtocol {

    enum Action: Equatable {
        case store(searchResult: RetailStoresSearch, forPostode: String)
        case store(searchResult: RetailStoresSearch, location: CLLocationCoordinate2D)
        case store(storeDetails: RetailStoreDetails, forPostode: String)
        case store(storeTimeSlots: RetailStoreTimeSlots, forStoreId: Int, location: CLLocationCoordinate2D?)
        case clearSearches
        case clearRetailStoreDetails
        case clearRetailStoreTimeSlots
        case retailStoresSearch(forPostcode: String)
        case retailStoresSearch(forLocation: CLLocationCoordinate2D)
        case lastStoresSearch
        case retailStoreDetails(forStoreId: Int, postcode: String)
        case retailStoreTimeSlots(forStoreId: Int, startDate: Date, endDate: Date, method: RetailStoreOrderMethodType, location: CLLocationCoordinate2D?)
    }
    var actions = MockActions<Action>(expected: [])
    
    var storeByPostcode: Result<RetailStoresSearch?, Error> = .failure(MockError.valueNotSet)
    var storeByLocation: Result<RetailStoresSearch?, Error> = .failure(MockError.valueNotSet)
    var storeDetailsByPostcode: Result<RetailStoreDetails?, Error> = .failure(MockError.valueNotSet)
    var storeTimeSlotsBy: Result<RetailStoreTimeSlots?, Error> = .failure(MockError.valueNotSet)
    
    var clearSearchesResult: Result<Bool, Error> = .failure(MockError.valueNotSet)
    var clearRetailStoreDetailsResult: Result<Bool, Error> = .failure(MockError.valueNotSet)
    var clearRetailStoreTimeSlotsResult: Result<Bool, Error> = .failure(MockError.valueNotSet)
    var fetchRetailStoresSearchByPostcodeResult: Result<RetailStoresSearch?, Error> = .failure(MockError.valueNotSet)
    var fetchRetailStoresSearchByLocationResult: Result<RetailStoresSearch?, Error> = .failure(MockError.valueNotSet)
    var lastStoresSearchResult: Result<RetailStoresSearch?, Error> = .failure(MockError.valueNotSet)
    var retailStoreDetailsResult: Result<RetailStoreDetails?, Error> = .failure(MockError.valueNotSet)
    var retailStoreTimeSlotsResult: Result<RetailStoreTimeSlots?, Error> = .failure(MockError.valueNotSet)
    
    func store(searchResult: RetailStoresSearch, forPostode postcode: String) -> AnyPublisher<RetailStoresSearch?, Error> {
        register(.store(searchResult: searchResult, forPostode: postcode))
        return storeByLocation.publish()
    }
    
    func store(searchResult: RetailStoresSearch, location: CLLocationCoordinate2D) -> AnyPublisher<RetailStoresSearch?, Error> {
        register(.store(searchResult: searchResult, location: location))
        return storeByPostcode.publish()
    }
    
    func store(storeDetails: RetailStoreDetails, forPostode postcode: String) -> AnyPublisher<RetailStoreDetails?, Error> {
        register(.store(storeDetails: storeDetails, forPostode: postcode))
        return storeDetailsByPostcode.publish()
    }
    
    func store(storeTimeSlots: RetailStoreTimeSlots, forStoreId storeId: Int, location: CLLocationCoordinate2D?) -> AnyPublisher<RetailStoreTimeSlots?, Error> {
        register(.store(storeTimeSlots: storeTimeSlots, forStoreId: storeId, location: location))
        return storeTimeSlotsBy.publish()
    }
    
    func clearSearches() -> AnyPublisher<Bool, Error> {
        register(.clearSearches)
        return clearSearchesResult.publish()
    }
    
    func clearRetailStoreDetails() -> AnyPublisher<Bool, Error> {
        register(.clearRetailStoreDetails)
        return clearRetailStoreDetailsResult.publish()
    }
    
    func clearRetailStoreTimeSlots() -> AnyPublisher<Bool, Error> {
        register(.clearRetailStoreTimeSlots)
        return clearRetailStoreTimeSlotsResult.publish()
    }
    
    func retailStoresSearch(forPostcode postcode: String) -> AnyPublisher<RetailStoresSearch?, Error> {
        register(.retailStoresSearch(forPostcode: postcode))
        return fetchRetailStoresSearchByPostcodeResult.publish()
    }
    
    func retailStoresSearch(forLocation location: CLLocationCoordinate2D) -> AnyPublisher<RetailStoresSearch?, Error> {
        register(.retailStoresSearch(forLocation: location))
        return fetchRetailStoresSearchByLocationResult.publish()
    }

    func lastStoresSearch() -> AnyPublisher<RetailStoresSearch?, Error> {
        register(.lastStoresSearch)
        return lastStoresSearchResult.publish()
    }
    
    func retailStoreDetails(forStoreId storeId: Int, postcode: String) -> AnyPublisher<RetailStoreDetails?, Error> {
        register(.retailStoreDetails(forStoreId: storeId, postcode: postcode))
        return retailStoreDetailsResult.publish()
    }

    func retailStoreTimeSlots(forStoreId storeId: Int, startDate: Date, endDate: Date, method: RetailStoreOrderMethodType, location: CLLocationCoordinate2D?) -> AnyPublisher<RetailStoreTimeSlots?, Error> {
        register(.retailStoreTimeSlots(forStoreId: storeId, startDate: startDate, endDate: endDate, method: method, location: location))
        return retailStoreTimeSlotsResult.publish()
    }

//    enum Action: Equatable {
//        case hasLoadedCountries
//        case storeCountries([Country])
//        case fetchCountries(search: String, locale: Locale)
//        case storeCountryDetails(Country.Details.Intermediate)
//        case fetchCountryDetails(Country)
//    }
//    var actions = MockActions<Action>(expected: [])
//
//    var hasLoadedCountriesResult: Result<Bool, Error> = .failure(MockError.valueNotSet)
//    var storeCountriesResult: Result<Void, Error> = .failure(MockError.valueNotSet)
//    var fetchCountriesResult: Result<LazyList<Country>, Error> = .failure(MockError.valueNotSet)
//    var storeCountryDetailsResult: Result<Country.Details?, Error> = .failure(MockError.valueNotSet)
//    var fetchCountryDetailsResult: Result<Country.Details?, Error> = .failure(MockError.valueNotSet)
//
//    // MARK: - API
//
//    func hasLoadedCountries() -> AnyPublisher<Bool, Error> {
//        register(.hasLoadedCountries)
//        return hasLoadedCountriesResult.publish()
//    }
//
//    func store(countries: [Country]) -> AnyPublisher<Void, Error> {
//        register(.storeCountries(countries))
//        return storeCountriesResult.publish()
//    }
//
//    func countries(search: String, locale: Locale) -> AnyPublisher<LazyList<Country>, Error> {
//        register(.fetchCountries(search: search, locale: locale))
//        return fetchCountriesResult.publish()
//    }
//
//    func store(countryDetails: Country.Details.Intermediate,
//               for country: Country) -> AnyPublisher<Country.Details?, Error> {
//        register(.storeCountryDetails(countryDetails))
//        return storeCountryDetailsResult.publish()
//    }
//
//    func countryDetails(country: Country) -> AnyPublisher<Country.Details?, Error> {
//        register(.fetchCountryDetails(country))
//        return fetchCountryDetailsResult.publish()
//    }
}

// MARK: - CountriesWebRepository

//final class MockedCountriesDBRepository: Mock, CountriesDBRepository {
//
//    enum Action: Equatable {
//        case hasLoadedCountries
//        case storeCountries([Country])
//        case fetchCountries(search: String, locale: Locale)
//        case storeCountryDetails(Country.Details.Intermediate)
//        case fetchCountryDetails(Country)
//    }
//    var actions = MockActions<Action>(expected: [])
//
//    var hasLoadedCountriesResult: Result<Bool, Error> = .failure(MockError.valueNotSet)
//    var storeCountriesResult: Result<Void, Error> = .failure(MockError.valueNotSet)
//    var fetchCountriesResult: Result<LazyList<Country>, Error> = .failure(MockError.valueNotSet)
//    var storeCountryDetailsResult: Result<Country.Details?, Error> = .failure(MockError.valueNotSet)
//    var fetchCountryDetailsResult: Result<Country.Details?, Error> = .failure(MockError.valueNotSet)
//
//    // MARK: - API
//
//    func hasLoadedCountries() -> AnyPublisher<Bool, Error> {
//        register(.hasLoadedCountries)
//        return hasLoadedCountriesResult.publish()
//    }
//
//    func store(countries: [Country]) -> AnyPublisher<Void, Error> {
//        register(.storeCountries(countries))
//        return storeCountriesResult.publish()
//    }
//
//    func countries(search: String, locale: Locale) -> AnyPublisher<LazyList<Country>, Error> {
//        register(.fetchCountries(search: search, locale: locale))
//        return fetchCountriesResult.publish()
//    }
//
//    func store(countryDetails: Country.Details.Intermediate,
//               for country: Country) -> AnyPublisher<Country.Details?, Error> {
//        register(.storeCountryDetails(countryDetails))
//        return storeCountryDetailsResult.publish()
//    }
//
//    func countryDetails(country: Country) -> AnyPublisher<Country.Details?, Error> {
//        register(.fetchCountryDetails(country))
//        return fetchCountryDetailsResult.publish()
//    }
//}
