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

public func ==(lhs: RetailStoresSearch, rhs: RetailStoresSearch) -> Bool {
    return lhs.fulfilmentLocation.postcode == rhs.fulfilmentLocation.postcode || lhs.fulfilmentLocation.location == rhs.fulfilmentLocation.location
}

public func ==(lhs: RetailStoreDetails, rhs: RetailStoreDetails) -> Bool {
    if
        let lhsSearchPostcode = lhs.searchPostcode,
        let rhsSearchPostcode = rhs.searchPostcode
    {
        return lhsSearchPostcode == rhsSearchPostcode && lhs.id == rhs.id
    }
    return lhs.id == rhs.id
}

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
        case store(searchResult: RetailStoresSearch, forPostode: String, isFirstOrder: Bool)
        case store(searchResult: RetailStoresSearch, location: CLLocationCoordinate2D, isFirstOrder: Bool)
        case store(storeDetails: RetailStoreDetails, forPostode: String, isFirstOrder: Bool)
        case store(storeTimeSlots: RetailStoreTimeSlots, forStoreId: Int, location: CLLocationCoordinate2D?)
        case store(fulfilmentLocation: FulfilmentLocation)
        case clearSearches
        case clearSearchesTest
        case clearRetailStoreDetails
        case clearRetailStoreTimeSlots
        case clearFulfilmentLocation
        case retailStoresSearch(forPostcode: String, isFirstOrder: Bool)
        case retailStoresSearch(forLocation: CLLocationCoordinate2D, isFirstOrder: Bool)
        case lastStoresSearch
        case lastSelectedStore
        case currentFulfilmentLocation
        case retailStoreDetails(forStoreId: Int, postcode: String, isFirstOrder: Bool)
        case retailStoreTimeSlots(forStoreId: Int, startDate: Date, endDate: Date, method: RetailStoreOrderMethodType, location: CLLocationCoordinate2D?)
    }
    var actions = MockActions<Action>(expected: [])
    
    var storeByPostcode: Result<RetailStoresSearch?, Error> = .failure(MockError.valueNotSet)
    var storeByLocation: Result<RetailStoresSearch?, Error> = .failure(MockError.valueNotSet)
    var storeDetailsByPostcode: Result<RetailStoreDetails?, Error> = .failure(MockError.valueNotSet)
    var storeTimeSlotsBy: Result<RetailStoreTimeSlots?, Error> = .failure(MockError.valueNotSet)
    var storeFulfilmentLocation: Result<FulfilmentLocation?, Error> = .failure(MockError.valueNotSet)
    
    var clearSearchesResult: Result<Bool, Error> = .failure(MockError.valueNotSet)
    var clearRetailStoreDetailsResult: Result<Bool, Error> = .failure(MockError.valueNotSet)
    var clearRetailStoreTimeSlotsResult: Result<Bool, Error> = .failure(MockError.valueNotSet)
    var clearFulfilmentLocationResult: Result<Bool, Error> = .failure(MockError.valueNotSet)
    var fetchRetailStoresSearchByPostcodeResult: Result<RetailStoresSearch?, Error> = .failure(MockError.valueNotSet)
    var fetchRetailStoresSearchByLocationResult: Result<RetailStoresSearch?, Error> = .failure(MockError.valueNotSet)
    var lastStoresSearchResult: Result<RetailStoresSearch?, Error> = .failure(MockError.valueNotSet)
    var lastSelectedStoreResult: Result<RetailStoreDetails?, Error> = .failure(MockError.valueNotSet)
    var currentFulfilmentLocationResult: Result<FulfilmentLocation?, Error> = .failure(MockError.valueNotSet)
    var retailStoreDetailsResult: Result<RetailStoreDetails?, Error> = .failure(MockError.valueNotSet)
    var retailStoreTimeSlotsResult: Result<RetailStoreTimeSlots?, Error> = .failure(MockError.valueNotSet)
    
    func store(searchResult: RetailStoresSearch, forPostode postcode: String, isFirstOrder: Bool) -> AnyPublisher<RetailStoresSearch?, Error> {
        register(.store(searchResult: searchResult, forPostode: postcode, isFirstOrder: isFirstOrder))
        return storeByPostcode.publish()
    }
    
    func store(searchResult: RetailStoresSearch, location: CLLocationCoordinate2D, isFirstOrder: Bool) -> AnyPublisher<RetailStoresSearch?, Error> {
        register(.store(searchResult: searchResult, location: location, isFirstOrder: isFirstOrder))
        return storeByLocation.publish()
    }
    
    func store(storeDetails: RetailStoreDetails, forPostode postcode: String, isFirstOrder: Bool) -> AnyPublisher<RetailStoreDetails?, Error> {
        register(.store(storeDetails: storeDetails, forPostode: postcode, isFirstOrder: isFirstOrder))
        return storeDetailsByPostcode.publish()
    }
    
    func store(storeTimeSlots: RetailStoreTimeSlots, forStoreId storeId: Int, location: CLLocationCoordinate2D?) -> AnyPublisher<RetailStoreTimeSlots?, Error> {
        register(.store(storeTimeSlots: storeTimeSlots, forStoreId: storeId, location: location))
        return storeTimeSlotsBy.publish()
    }
    
    func store(fulfilmentLocation: FulfilmentLocation) -> AnyPublisher<FulfilmentLocation?, Error> {
        register(.store(fulfilmentLocation: fulfilmentLocation))
        return storeFulfilmentLocation.publish()
    }
    
    func clearSearches() -> AnyPublisher<Bool, Error> {
        register(.clearSearches)
        return clearSearchesResult.publish()
    }
    
    func clearSearchesTest() -> AnyPublisher<Bool, Error> {
        register(.clearSearchesTest)
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
    
    func clearFulfilmentLocation() -> AnyPublisher<Bool, Error> {
        register(.clearFulfilmentLocation)
        return clearFulfilmentLocationResult.publish()
    }
    
    func retailStoresSearch(forPostcode postcode: String, isFirstOrder: Bool) -> AnyPublisher<RetailStoresSearch?, Error> {
        register(.retailStoresSearch(forPostcode: postcode, isFirstOrder: isFirstOrder))
        return fetchRetailStoresSearchByPostcodeResult.publish()
    }
    
    func retailStoresSearch(forLocation location: CLLocationCoordinate2D, isFirstOrder: Bool) -> AnyPublisher<RetailStoresSearch?, Error> {
        register(.retailStoresSearch(forLocation: location, isFirstOrder: isFirstOrder))
        return fetchRetailStoresSearchByLocationResult.publish()
    }

    func lastStoresSearch() -> AnyPublisher<RetailStoresSearch?, Error> {
        register(.lastStoresSearch)
        return lastStoresSearchResult.publish()
    }
    
    func lastSelectedStore() async throws -> RetailStoreDetails? {
        register(.lastSelectedStore)
        switch lastSelectedStoreResult {
        case .success(let result):
            return result
        case .failure(let error):
            throw error
        }
    }
    
    func currentFulfilmentLocation() -> AnyPublisher<FulfilmentLocation?, Error> {
        register(.currentFulfilmentLocation)
        return currentFulfilmentLocationResult.publish()
    }
    
    func retailStoreDetails(forStoreId storeId: Int, postcode: String, isFirstOrder: Bool) -> AnyPublisher<RetailStoreDetails?, Error> {
        register(.retailStoreDetails(forStoreId: storeId, postcode: postcode, isFirstOrder: isFirstOrder))
        return retailStoreDetailsResult.publish()
    }

    func retailStoreTimeSlots(forStoreId storeId: Int, startDate: Date, endDate: Date, method: RetailStoreOrderMethodType, location: CLLocationCoordinate2D?) -> AnyPublisher<RetailStoreTimeSlots?, Error> {
        register(.retailStoreTimeSlots(forStoreId: storeId, startDate: startDate, endDate: endDate, method: method, location: location))
        return retailStoreTimeSlotsResult.publish()
    }

}
