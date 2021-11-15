//
//  RetailStoresDBRepositoryTests.swift
//  SnappyV2Tests
//
//  Created by Kevin Palser on 16/10/2021.
//

import XCTest
import Combine
@testable import SnappyV2
import CoreLocation

class RetailStoresDBRepositoryTests: XCTestCase {
    
    var mockedStore: MockedPersistentStore!
    var sut: RetailStoresDBRepository!
    var cancelBag = CancelBag()
    
    override func setUp() {
        mockedStore = MockedPersistentStore()
        sut = RetailStoresDBRepository(persistentStore: mockedStore)
        mockedStore.verify()
    }
    
    override func tearDown() {
        cancelBag = CancelBag()
        sut = nil
        mockedStore = nil
    }
}

// MARK: - Methods in RetailStoresDBRepositoryProtocol

final class RetailStoresDBRepositoryProtocolTests: RetailStoresDBRepositoryTests {
    
    // MARK: - store(searchResult:forPostode:)
    
    func test_storeSearchResult_forPostcode() throws {
        let search = RetailStoresSearch.mockedData
        
        mockedStore.actions = .init(expected: [
            .update(.init(
                inserted: search.recordsCount,
                updated: 0,
                deleted: 0)
            )
        ])
        
        let exp = XCTestExpectation(description: #function)
        sut.store(
            searchResult: search,
            forPostode: search.fulfilmentLocation.postcode
        )
            .sinkToResult { result in
                result.assertSuccess(value: search)
                self.mockedStore.verify()
                exp.fulfill()
            }
            .store(in: cancelBag)
        wait(for: [exp], timeout: 0.5)
        
    }
    
    // MARK: - store(searchResult:location:)
    
    func test_storeSearchResult_forLocation() throws {
        let search = RetailStoresSearch.mockedData
        
        mockedStore.actions = .init(expected: [
            .update(.init(
                inserted: search.recordsCount,
                updated: 0,
                deleted: 0)
            )
        ])
        
        let exp = XCTestExpectation(description: #function)
        sut.store(
            searchResult: search,
            location: search.fulfilmentLocation.location
        )
            .sinkToResult { result in
                result.assertSuccess(value: search)
                self.mockedStore.verify()
                exp.fulfill()
            }
            .store(in: cancelBag)
        wait(for: [exp], timeout: 0.5)
        
    }
    
    // MARK: - store(storeDetails:forPostode:)
    
    func test_storeStoreDetails_forPostode() throws {
        let storeDetails = RetailStoreDetails.mockedData
        
        mockedStore.actions = .init(expected: [
            .update(.init(
                inserted: storeDetails.recordsCount,
                updated: 0,
                deleted: 0)
            )
        ])
        
        let exp = XCTestExpectation(description: #function)
        sut.store(
            storeDetails: storeDetails,
            forPostode: storeDetails.searchPostcode ?? ""
        )
            .sinkToResult { result in
                result.assertSuccess(value: RetailStoreDetails.mockedDataWithStartAndEndDates)
                self.mockedStore.verify()
                exp.fulfill()
            }
            .store(in: cancelBag)
        wait(for: [exp], timeout: 0.5)
        
    }
    
    // MARK: - store(storeTimeSlots:forStoreId:location:)
    
    func test_storeStoreTimeSlots_forStoreId() throws {
        
        let timeSlots = RetailStoreTimeSlots.mockedAPIResponseData
        
        mockedStore.actions = .init(expected: [
            .update(.init(
                inserted: timeSlots.recordsCount,
                updated: 0,
                deleted: 0)
            )
        ])
        
        let mockedPersistedData = RetailStoreTimeSlots.mockedPersistedDataWithoutCoordinates(basedOn: timeSlots)
        
        let exp = XCTestExpectation(description: #function)
        sut.store(
            storeTimeSlots: timeSlots,
            forStoreId: mockedPersistedData.searchStoreId ?? 0,
            location: nil
        )
            .sinkToResult { result in
                result.assertSuccess(value: mockedPersistedData)
                self.mockedStore.verify()
                exp.fulfill()
            }
            .store(in: cancelBag)
        wait(for: [exp], timeout: 0.5)
        
    }
    
    func test_storeStoreTimeSlots_forStoreId_withLocation() throws {
        
        let timeSlots = RetailStoreTimeSlots.mockedAPIResponseData
        
        mockedStore.actions = .init(expected: [
            .update(.init(
                inserted: timeSlots.recordsCount,
                updated: 0,
                deleted: 0)
            )
        ])
        
        let mockedPersistedData = RetailStoreTimeSlots.mockedPersistedDataWithCoordinates(basedOn: timeSlots)
        
        let exp = XCTestExpectation(description: #function)
        sut.store(
            storeTimeSlots: timeSlots,
            forStoreId: 30,
            location: CLLocationCoordinate2D(
                latitude: mockedPersistedData.searchLatitude ?? 0,
                longitude: mockedPersistedData.searchLongitude ?? 0
            )
        )
            .sinkToResult { result in
                result.assertSuccess(value: mockedPersistedData)
                self.mockedStore.verify()
                exp.fulfill()
            }
            .store(in: cancelBag)
        wait(for: [exp], timeout: 0.5)
        
    }
    
    // MARK: - clearSearches()
    
    func test_clearSearches() throws {
        
        let search = RetailStoresSearch.mockedData
        
        mockedStore.actions = .init(expected: [
            .update(
                .init(
                    inserted: 0,
                    updated: 0,
                    // not search.recordsCount because of cascade deletion
                    deleted: 1
                )
            )
        ])
        
        try mockedStore.preloadData { context in
            search.store(in: context)
        }
        
        let exp = XCTestExpectation(description: #function)
        sut.clearSearchesTest()//clearSearches()
            .sinkToResult { result in
                result.assertSuccess(value: true)
                self.mockedStore.verify()
                exp.fulfill()
            }
            .store(in: cancelBag)
        wait(for: [exp], timeout: 0.5)

    }
    
//    // removing all search results
//    func clearSearches() -> AnyPublisher<Bool, Error>
//
//    // removing all detail results
//    func clearRetailStoreDetails() -> AnyPublisher<Bool, Error>
//
//    // removing all time slots results
//    func clearRetailStoreTimeSlots() -> AnyPublisher<Bool, Error>
//
//    // fetching search results
    
    // MARK: - retailStoresSearch(forPostcode:)
    
    func test_retailStoresSearch_forPostcode() throws {
        
        let search = RetailStoresSearch.mockedData
        
        mockedStore.actions = .init(expected: [
            .fetch(String(describing: RetailStoresSearchMO.self), .init(inserted: 0, updated: 0, deleted: 0))
        ])
        
        try mockedStore.preloadData { context in
            search.store(in: context)
        }
        
        let exp = XCTestExpectation(description: #function)
        sut.retailStoresSearch(forPostcode: search.fulfilmentLocation.postcode)
            .sinkToResult { result in
                result.assertSuccess(value: search)
                self.mockedStore.verify()
                exp.fulfill()
            }
            .store(in: cancelBag)
        wait(for: [exp], timeout: 0.5)
        
    }
    
//    func retailStoresSearch(forPostcode: String) -> AnyPublisher<RetailStoresSearch?, Error>
//    func retailStoresSearch(forLocation: CLLocationCoordinate2D) -> AnyPublisher<RetailStoresSearch?, Error>
//    func lastStoresSearch() -> AnyPublisher<RetailStoresSearch?, Error>
//
//    // fetching detail results
//    func retailStoreDetails(forStoreId: Int, postcode: String) -> AnyPublisher<RetailStoreDetails?, Error>
//
//    // fetching time slot results
//    func retailStoreTimeSlots(forStoreId: Int, startDate: Date, endDate: Date, method: RetailStoreOrderMethodType, location: CLLocationCoordinate2D?) -> AnyPublisher<RetailStoreTimeSlots?, Error>
    
}
