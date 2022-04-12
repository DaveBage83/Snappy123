//
//  MockedRetailStoresWebRepository.swift
//  SnappyV2Tests
//
//  Created by Kevin Palser on 26/09/2021.
//

import XCTest
import Combine
import CoreLocation
@testable import SnappyV2

final class MockedRetailStoresWebRepository: TestWebRepository, Mock, RetailStoresWebRepositoryProtocol {

    enum Action: Equatable {
        case loadRetailStores(postcode: String)
        case loadRetailStores(location: CLLocationCoordinate2D)
        case loadRetailStoreDetails(storeId: Int, postcode: String)
        case loadRetailStoreTimeSlots(storeId: Int, startDate: Date, endDate: Date, method: RetailStoreOrderMethodType, location: CLLocationCoordinate2D?)
        case futureContactRequest(email: String, postcode: String)
    }
    var actions = MockActions<Action>(expected: [])
    
    var loadRetailStoresByPostcodeResponse: Result<RetailStoresSearch, Error> = .failure(MockError.valueNotSet)
    var loadRetailStoresByLocationResponse: Result<RetailStoresSearch, Error> = .failure(MockError.valueNotSet)
    var loadRetailStoreDetailsResponse: Result<RetailStoreDetails, Error> = .failure(MockError.valueNotSet)
    var loadRetailStoreTimeSlotsResponse: Result<RetailStoreTimeSlots, Error> = .failure(MockError.valueNotSet)
    
    func loadRetailStores(postcode: String) -> AnyPublisher<RetailStoresSearch, Error> {
        register(.loadRetailStores(postcode: postcode))
        return loadRetailStoresByPostcodeResponse.publish()
    }
    
    func loadRetailStores(location: CLLocationCoordinate2D) -> AnyPublisher<RetailStoresSearch, Error> {
        register(.loadRetailStores(location: location))
        return loadRetailStoresByLocationResponse.publish()
    }
    
    func loadRetailStoreDetails(storeId: Int, postcode: String) -> AnyPublisher<RetailStoreDetails, Error> {
        register(.loadRetailStoreDetails(storeId: storeId, postcode: postcode))
        return loadRetailStoreDetailsResponse.publish()
    }
    
    func loadRetailStoreTimeSlots(storeId: Int, startDate: Date, endDate: Date, method: RetailStoreOrderMethodType, location: CLLocationCoordinate2D?) -> AnyPublisher<RetailStoreTimeSlots, Error> {
        register(.loadRetailStoreTimeSlots(storeId: storeId, startDate: startDate, endDate: endDate, method: method, location: location))
        return loadRetailStoreTimeSlotsResponse.publish()
    }
    
    func futureContactRequest(email: String, postcode: String) async throws -> FutureContactRequestResponse {
        register(.futureContactRequest(email: email, postcode: postcode))
        return FutureContactRequestResponse.mockedData
    }
    
//    enum Action: Equatable {
//        case loadCountries
//        case loadCountryDetails(Country)
//    }
//    var actions = MockActions<Action>(expected: [])
//    
//    var countriesResponse: Result<[Country], Error> = .failure(MockError.valueNotSet)
//    var detailsResponse: Result<Country.Details.Intermediate, Error> = .failure(MockError.valueNotSet)
//    
//    func loadCountries() -> AnyPublisher<[Country], Error> {
//        register(.loadCountries)
//        return countriesResponse.publish()
//    }
//    
//    func loadCountryDetails(country: Country) -> AnyPublisher<Country.Details.Intermediate, Error> {
//        register(.loadCountryDetails(country))
//        return detailsResponse.publish()
//    }
}

//final class MockedRetailStoresWebRepository: TestWebRepository, Mock, RetailStoresWebRepository {
//    
//    enum Action: Equatable {
//        case loadCountries
//        case loadCountryDetails(Country)
//    }
//    var actions = MockActions<Action>(expected: [])
//    
//    var countriesResponse: Result<[Country], Error> = .failure(MockError.valueNotSet)
//    var detailsResponse: Result<Country.Details.Intermediate, Error> = .failure(MockError.valueNotSet)
//    
//    func loadCountries() -> AnyPublisher<[Country], Error> {
//        register(.loadCountries)
//        return countriesResponse.publish()
//    }
//    
//    func loadCountryDetails(country: Country) -> AnyPublisher<Country.Details.Intermediate, Error> {
//        register(.loadCountryDetails(country))
//        return detailsResponse.publish()
//    }
//}
