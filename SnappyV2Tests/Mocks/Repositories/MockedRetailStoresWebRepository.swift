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
    }
    var actions = MockActions<Action>(expected: [])
    
    var loadRetailStoresByPostcodeResponse: Result<RetailStoresSearch, Error> = .failure(MockError.valueNotSet)
    var loadRetailStoresByLocationResponse: Result<RetailStoresSearch, Error> = .failure(MockError.valueNotSet)
    
    func loadRetailStores(postcode: String) -> AnyPublisher<RetailStoresSearch, Error> {
        register(.loadRetailStores(postcode: postcode))
        return loadRetailStoresByPostcodeResponse.publish()
    }
    
    func loadRetailStores(location: CLLocationCoordinate2D) -> AnyPublisher<RetailStoresSearch, Error> {
        register(.loadRetailStores(location: location))
        return loadRetailStoresByLocationResponse.publish()
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
