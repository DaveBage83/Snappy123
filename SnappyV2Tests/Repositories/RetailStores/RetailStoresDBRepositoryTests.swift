//
//  RetailStoresDBRepositoryTests.swift
//  SnappyV2Tests
//
//  Created by Kevin Palser on 16/10/2021.
//

import XCTest
import Combine
import CoreLocation
@testable import SnappyV2

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
        wait(for: [exp], timeout: 2)
        
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
    
    // MARK: - store(storeDetails:forPostcode:)
    
    func test_storeStoreDetails_forPostcode() throws {
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
        wait(for: [exp], timeout: 2)
        
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
    
    func test_storeFulfilmentLocation() throws {
        
        let location = FulfilmentLocation.mockedData
        
        mockedStore.actions = .init(expected: [
            .update(.init(
                inserted: 1,
                updated: 0,
                deleted: 0)
            )
        ])
        
        let exp = XCTestExpectation(description: #function)
        sut.store(fulfilmentLocation: location)
            .sinkToResult { result in
                result.assertSuccess(value: location)
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
        sut.clearSearches()
            .sinkToResult { result in
                result.assertSuccess(value: true)
                self.mockedStore.verify()
                exp.fulfill()
            }
            .store(in: cancelBag)
        wait(for: [exp], timeout: 0.5)

    }
    
    // MARK: - clearRetailStoreDetails()

    func test_clearRetailStoreDetails() throws {
        
        let details = RetailStoreDetails.mockedData
        
        mockedStore.actions = .init(expected: [
            .update(
                .init(
                    inserted: 0,
                    updated: 0,
                    // not details.recordsCount because of cascade deletion
                    deleted: 1
                )
            )
        ])
        
        try mockedStore.preloadData { context in
            details.store(in: context)
        }
        
        let exp = XCTestExpectation(description: #function)
        sut.clearRetailStoreDetails()
            .sinkToResult { result in
                result.assertSuccess(value: true)
                self.mockedStore.verify()
                exp.fulfill()
            }
            .store(in: cancelBag)
        wait(for: [exp], timeout: 0.5)

    }
    
    // MARK: - clearRetailStoreTimeSlots()
    
    func test_clearRetailStoreTimeSlots() throws {
        
        let timeSlotsFromAPI = RetailStoreTimeSlots.mockedAPIResponseData
        let timeSlots = RetailStoreTimeSlots.mockedPersistedDataWithCoordinates(basedOn: timeSlotsFromAPI)
        
        mockedStore.actions = .init(expected: [
            .update(
                .init(
                    inserted: 0,
                    updated: 0,
                    // not details.recordsCount because of cascade deletion
                    deleted: 1
                )
            )
        ])
        
        try mockedStore.preloadData { context in
            timeSlots.store(in: context)
        }
        
        let exp = XCTestExpectation(description: #function)
        sut.clearRetailStoreTimeSlots()
            .sinkToResult { result in
                result.assertSuccess(value: true)
                self.mockedStore.verify()
                exp.fulfill()
            }
            .store(in: cancelBag)
        wait(for: [exp], timeout: 0.5)

    }
    
    // MARK: - clearFulfilmentLocation()
    
    func test_clearFulfilmentLocation() throws {
        
        let location = FulfilmentLocation.mockedData
        
        mockedStore.actions = .init(expected: [
            .update(
                .init(
                    inserted: 0,
                    updated: 0,
                    // not details.recordsCount because of cascade deletion
                    deleted: 1
                )
            )
        ])
        
        try mockedStore.preloadData { context in
            location.store(in: context)
        }
        
        let exp = XCTestExpectation(description: #function)
        sut.clearFulfilmentLocation()
            .sinkToResult { result in
                result.assertSuccess(value: true)
                self.mockedStore.verify()
                exp.fulfill()
            }
            .store(in: cancelBag)
        wait(for: [exp], timeout: 0.5)

    }
    
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
    
    func test_retailStoresSearch_forPostcode_no_match() throws {
        
        let search = RetailStoresSearch.mockedData
        
        mockedStore.actions = .init(expected: [
            .fetch(String(describing: RetailStoresSearchMO.self), .init(inserted: 0, updated: 0, deleted: 0))
        ])
        
        try mockedStore.preloadData { context in
            search.store(in: context)
        }
        
        let exp = XCTestExpectation(description: #function)
        sut.retailStoresSearch(forPostcode: "X99 9XX")
            .sinkToResult { result in
                result.assertSuccess(value: nil)
                self.mockedStore.verify()
                exp.fulfill()
            }
            .store(in: cancelBag)
        wait(for: [exp], timeout: 0.5)
        
    }
    
    // MARK: - retailStoresSearch(forLocation:)
    
    func test_retailStoresSearch_forLocation() throws {
        
        let search = RetailStoresSearch.mockedData
        
        mockedStore.actions = .init(expected: [
            .fetch(String(describing: RetailStoresSearchMO.self), .init(inserted: 0, updated: 0, deleted: 0))
        ])
        
        try mockedStore.preloadData { context in
            search.store(in: context)
        }
        
        let exp = XCTestExpectation(description: #function)
        sut.retailStoresSearch(forLocation: search.fulfilmentLocation.location)
            .sinkToResult { result in
                result.assertSuccess(value: search)
                self.mockedStore.verify()
                exp.fulfill()
            }
            .store(in: cancelBag)
        wait(for: [exp], timeout: 0.5)
        
    }
    
    func test_retailStoresSearch_forLocation_no_match() throws {
        
        let search = RetailStoresSearch.mockedData
        
        mockedStore.actions = .init(expected: [
            .fetch(String(describing: RetailStoresSearchMO.self), .init(inserted: 0, updated: 0, deleted: 0))
        ])
        
        try mockedStore.preloadData { context in
            search.store(in: context)
        }
        
        let exp = XCTestExpectation(description: #function)
        sut.retailStoresSearch(forLocation: CLLocationCoordinate2D(latitude: 99, longitude: 99))
            .sinkToResult { result in
                result.assertSuccess(value: nil)
                self.mockedStore.verify()
                exp.fulfill()
            }
            .store(in: cancelBag)
        wait(for: [exp], timeout: 0.5)
        
    }
    
    // MARK: - lastStoresSearch()
    
    func test_lastStoresSearch() throws {
        
        let search = RetailStoresSearch.mockedData
        
        mockedStore.actions = .init(expected: [
            .fetch(String(describing: RetailStoresSearchMO.self), .init(inserted: 0, updated: 0, deleted: 0))
        ])
        
        try mockedStore.preloadData { context in
            search.store(in: context)
        }
        
        let exp = XCTestExpectation(description: #function)
        sut.lastStoresSearch()
            .sinkToResult { result in
                result.assertSuccess(value: search)
                self.mockedStore.verify()
                exp.fulfill()
            }
            .store(in: cancelBag)
        wait(for: [exp], timeout: 0.5)
        
    }
    
    func test_lastStoresSearch_no_stored_search() throws {
        
        mockedStore.actions = .init(expected: [
            .fetch(String(describing: RetailStoresSearchMO.self), .init(inserted: 0, updated: 0, deleted: 0))
        ])

        let exp = XCTestExpectation(description: #function)
        sut.lastStoresSearch()
            .sinkToResult { result in
                result.assertSuccess(value: nil)
                self.mockedStore.verify()
                exp.fulfill()
            }
            .store(in: cancelBag)
        wait(for: [exp], timeout: 0.5)
        
    }
    
    // MARK: - currentFulfilmentLocation()
    
    func test_currentFulfilmentLocation() throws {
        
        let location = FulfilmentLocation.mockedData
        
        mockedStore.actions = .init(expected: [
            .fetch(String(describing: CurrentFulfilmentLocationMO.self), .init(inserted: 0, updated: 0, deleted: 0))
        ])
        
        try mockedStore.preloadData { context in
            location.store(in: context)
        }
        
        let exp = XCTestExpectation(description: #function)
        sut.currentFulfilmentLocation()
            .sinkToResult { result in
                result.assertSuccess(value: location)
                self.mockedStore.verify()
                exp.fulfill()
            }
            .store(in: cancelBag)
        wait(for: [exp], timeout: 0.5)
        
    }
    
    func test_currentFulfilmentLocation_whenNoStoredLocation() throws {
        
        mockedStore.actions = .init(expected: [
            .fetch(String(describing: CurrentFulfilmentLocationMO.self), .init(inserted: 0, updated: 0, deleted: 0))
        ])
        
        let exp = XCTestExpectation(description: #function)
        sut.currentFulfilmentLocation()
            .sinkToResult { result in
                result.assertSuccess(value: nil)
                self.mockedStore.verify()
                exp.fulfill()
            }
            .store(in: cancelBag)
        wait(for: [exp], timeout: 0.5)
        
    }
    
    // MARK: - retailStoreDetails(forStoreId:postcode:)

    func test_retailStoreDetails() throws {
        
        let details = RetailStoreDetails.mockedData
        
        mockedStore.actions = .init(expected: [
            .fetch(String(describing: RetailStoreDetailsMO.self), .init(inserted: 0, updated: 0, deleted: 0))
        ])
        
        try mockedStore.preloadData { context in
            let detailsMO = details.store(in: context)
            detailsMO?.searchPostcode = details.searchPostcode
        }
        
        let exp = XCTestExpectation(description: #function)
        sut.retailStoreDetails(forStoreId: details.id, postcode: details.searchPostcode ?? "")
            .sinkToResult { result in
                result.assertSuccess(value: RetailStoreDetails.mockedDataWithStartAndEndDates)
                self.mockedStore.verify()
                exp.fulfill()
            }
            .store(in: cancelBag)
        wait(for: [exp], timeout: 0.5)
        
    }
    
    func test_retailStoreDetails_no_match() throws {
        
        let details = RetailStoreDetails.mockedData
        
        mockedStore.actions = .init(expected: [
            .fetch(String(describing: RetailStoreDetailsMO.self), .init(inserted: 0, updated: 0, deleted: 0))
        ])
        
        try mockedStore.preloadData { context in
            let detailsMO = details.store(in: context)
            detailsMO?.searchPostcode = details.searchPostcode
        }
        
        let exp = XCTestExpectation(description: #function)
        sut.retailStoreDetails(forStoreId: details.id + 1, postcode: details.searchPostcode ?? "")
            .sinkToResult { result in
                result.assertSuccess(value: nil)
                self.mockedStore.verify()
                exp.fulfill()
            }
            .store(in: cancelBag)
        wait(for: [exp], timeout: 0.5)
        
    }
    
    // MARK: - retailStoreTimeSlots(forStoreId:startDate:endDate:method:location)
    
    func test_retailStoreTimeSlots() throws {
        
        let timeSlots = RetailStoreTimeSlots.mockedAPIResponseData
        let mockedPersistedData = RetailStoreTimeSlots.mockedPersistedDataWithoutCoordinates(basedOn: timeSlots)
        
        mockedStore.actions = .init(expected: [
            .fetch(String(describing: RetailStoreTimeSlotsMO.self), .init(inserted: 0, updated: 0, deleted: 0))
        ])
        
        try mockedStore.preloadData { context in
            let timeSlotsMO = timeSlots.store(in: context)
            timeSlotsMO?.storeId = Int64(mockedPersistedData.searchStoreId ?? 0)
        }
        
        let exp = XCTestExpectation(description: #function)
        sut.retailStoreTimeSlots(
            forStoreId: mockedPersistedData.searchStoreId ?? 0,
            startDate: mockedPersistedData.startDate,
            endDate: mockedPersistedData.endDate,
            method: RetailStoreOrderMethodType(rawValue: mockedPersistedData.fulfilmentMethod) ?? .delivery,
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
    
    func test_retailStoreTimeSlots_no_match() throws {
        
        let timeSlots = RetailStoreTimeSlots.mockedAPIResponseData
        let mockedPersistedData = RetailStoreTimeSlots.mockedPersistedDataWithoutCoordinates(basedOn: timeSlots)
        
        mockedStore.actions = .init(expected: [
            .fetch(String(describing: RetailStoreTimeSlotsMO.self), .init(inserted: 0, updated: 0, deleted: 0))
        ])
        
        try mockedStore.preloadData { context in
            let timeSlotsMO = timeSlots.store(in: context)
            // Increment the storeId to fource no result
            timeSlotsMO?.storeId = Int64(mockedPersistedData.searchStoreId ?? 0) + 1
        }
        
        let exp = XCTestExpectation(description: #function)
        sut.retailStoreTimeSlots(
            forStoreId: mockedPersistedData.searchStoreId ?? 0,
            startDate: mockedPersistedData.startDate,
            endDate: mockedPersistedData.endDate,
            method: RetailStoreOrderMethodType(rawValue: mockedPersistedData.fulfilmentMethod) ?? .delivery,
            location: nil
        )
            .sinkToResult { result in
                result.assertSuccess(value: nil)
                self.mockedStore.verify()
                exp.fulfill()
            }
            .store(in: cancelBag)
        wait(for: [exp], timeout: 0.5)
        
    }
    
    func test_retailStoreTimeSlots_forLocation() throws {
        
        let timeSlots = RetailStoreTimeSlots.mockedAPIResponseData
        let mockedPersistedData = RetailStoreTimeSlots.mockedPersistedDataWithoutCoordinates(basedOn: timeSlots)
        
        mockedStore.actions = .init(expected: [
            .fetch(String(describing: RetailStoreTimeSlotsMO.self), .init(inserted: 0, updated: 0, deleted: 0))
        ])
        
        var location: CLLocationCoordinate2D?
        if
            let latitude = mockedPersistedData.searchLatitude,
            let longitude = mockedPersistedData.searchLongitude
        {
            location = CLLocationCoordinate2D(
                latitude: latitude,
                longitude: longitude
            )
        }
        
        try mockedStore.preloadData { context in
            let timeSlotsMO = timeSlots.store(in: context)
            timeSlotsMO?.storeId = Int64(mockedPersistedData.searchStoreId ?? 0)
            if let location = location {
                timeSlotsMO?.latitude = NSNumber(value: location.latitude)
                timeSlotsMO?.longitude = NSNumber(value: location.longitude)
            }
        }
        
        let exp = XCTestExpectation(description: #function)
        sut.retailStoreTimeSlots(
            forStoreId: mockedPersistedData.searchStoreId ?? 0,
            startDate: mockedPersistedData.startDate,
            endDate: mockedPersistedData.endDate,
            method: RetailStoreOrderMethodType(rawValue: mockedPersistedData.fulfilmentMethod) ?? .delivery,
            location: location
        )
            .sinkToResult { result in
                result.assertSuccess(value: mockedPersistedData)
                self.mockedStore.verify()
                exp.fulfill()
            }
            .store(in: cancelBag)
        wait(for: [exp], timeout: 0.5)
        
    }
    
    func test_retailStoreTimeSlots_forLocation_no_match() throws {
        
        let timeSlots = RetailStoreTimeSlots.mockedAPIResponseData
        let mockedPersistedData = RetailStoreTimeSlots.mockedPersistedDataWithoutCoordinates(basedOn: timeSlots)
        
        mockedStore.actions = .init(expected: [
            .fetch(String(describing: RetailStoreTimeSlotsMO.self), .init(inserted: 0, updated: 0, deleted: 0))
        ])
        
        var location: CLLocationCoordinate2D?
        if
            let latitude = mockedPersistedData.searchLatitude,
            let longitude = mockedPersistedData.searchLongitude
        {
            location = CLLocationCoordinate2D(
                latitude: latitude,
                longitude: longitude
            )
        }
        
        try mockedStore.preloadData { context in
            let timeSlotsMO = timeSlots.store(in: context)
            // Increment the storeId to fource no result
            timeSlotsMO?.storeId = Int64(mockedPersistedData.searchStoreId ?? 0) + 1
            if let location = location {
                timeSlotsMO?.latitude = NSNumber(value: location.latitude)
                timeSlotsMO?.longitude = NSNumber(value: location.longitude)
            }
        }
        
        let exp = XCTestExpectation(description: #function)
        sut.retailStoreTimeSlots(
            forStoreId: mockedPersistedData.searchStoreId ?? 0,
            startDate: mockedPersistedData.startDate,
            endDate: mockedPersistedData.endDate,
            method: RetailStoreOrderMethodType(rawValue: mockedPersistedData.fulfilmentMethod) ?? .delivery,
            location: location
        )
            .sinkToResult { result in
                result.assertSuccess(value: nil)
                self.mockedStore.verify()
                exp.fulfill()
            }
            .store(in: cancelBag)
        wait(for: [exp], timeout: 0.5)
        
    }
    
}
