//
//  RetailStoresServiceTests.swift
//  SnappyV2Tests
//
//  Created by Kevin Palser on 26/09/2021.
//

import XCTest
import Combine
import AppsFlyerLib
@testable import SnappyV2
import CoreLocation

class RetailStoresServiceTests: XCTestCase {

    var appState = CurrentValueSubject<AppState, Never>(AppState())
    var mockedEventLogger: MockedEventLogger!
    var mockedWebRepo: MockedRetailStoresWebRepository!
    var mockedDBRepo: MockedRetailStoresDBRepository!
    var mockedSearchHistoryDBRepo: MockedSearchHistoryDBRepository!
    var subscriptions = Set<AnyCancellable>()
    var sut: RetailStoresService!

    override func setUp() {
        mockedEventLogger = MockedEventLogger()
        mockedWebRepo = MockedRetailStoresWebRepository()
        mockedDBRepo = MockedRetailStoresDBRepository()
        mockedSearchHistoryDBRepo = MockedSearchHistoryDBRepository()
        sut = RetailStoresService(
            webRepository: mockedWebRepo,
            dbRepository: mockedDBRepo,
            searchHistoryDBRepository: mockedSearchHistoryDBRepo,
            appState: appState,
            eventLogger: mockedEventLogger
        )
    }
    
    func delay(_ closure: @escaping () -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: closure)
    }

    override func tearDown() {
        appState = CurrentValueSubject<AppState, Never>(AppState())
        subscriptions = Set<AnyCancellable>()
        mockedEventLogger = nil
        mockedWebRepo = nil
        mockedDBRepo = nil
        sut = nil
    }
}

// MARK: - func searchRetailStores(postcode:)
final class SearchRetailStoresByPostcodeTests: RetailStoresServiceTests {
    
    func test_successfulSearch_givenOpenStoresAndFirstOrder_setAppSearchResultState() async {
        
        let searchResult = RetailStoresSearch.mockedData
        let isFirstOrder = true
        
        // Configuring app prexisting states
        appState.value.userData.isFirstOrder = isFirstOrder
        
        // Configuring expected actions on repositories

        mockedWebRepo.actions = .init(expected: [
            .loadRetailStores(
                postcode: searchResult.fulfilmentLocation.postcode,
                isFirstOrder: isFirstOrder
            )
        ])
        mockedDBRepo.actions = .init(expected: [
            .clearSearches,
            .store(
                searchResult: searchResult,
                forPostode: "DD1 3JA",
                isFirstOrder: isFirstOrder
            )
        ])
        
        let appsFlyerParams: [String: Any] = [
            AFEventParamSearchString: searchResult.fulfilmentLocation.postcode,
            AFEventParamLat: searchResult.fulfilmentLocation.latitude,
            AFEventParamLong: searchResult.fulfilmentLocation.longitude,
            "delivery_stores": [1944, 1414, 1807, 910],
            "num_delivery_stores": 4,
            "collection_stores": [1944, 1807],
            "num_collection_stores": 2
        ]
        
        let iterableParams: [String: Any] = [
            "postalCode": searchResult.fulfilmentLocation.postcode,
            "lat": searchResult.fulfilmentLocation.latitude,
            "long": searchResult.fulfilmentLocation.longitude,
            "deliveryStoreIdsFound": [1944, 1414, 1807, 910],
            "totalDeliveryStoresFound": 4,
            "collectionStoreIdsFound": [1944, 1807],
            "totalCollectionStoresFound": 2,
        ]
        
        mockedEventLogger.actions = .init(expected: [
            .sendEvent(for: .storeSearch, with: .appsFlyer, params: appsFlyerParams),
            .sendEvent(for: .storeSearch, with: .iterable, params: iterableParams),
            .sendEvent(for: .storeSearch, with: .firebaseAnalytics, params: ["store_search_result": "open"])
        ])

        // Configuring responses from repositories

        mockedWebRepo.loadRetailStoresByPostcodeResponse = .success(searchResult)
        mockedDBRepo.clearSearchesResult = .success(true)
        mockedDBRepo.storeByPostcode = .success(searchResult)
        
        XCTAssertEqual(appState.value.userData.searchResult, .notRequested)
        
        do {
            try await sut.searchRetailStores(postcode: searchResult.fulfilmentLocation.postcode).singleOutput()
            
            XCTAssertEqual(
                self.sut.appState.value.userData.searchResult.value,
                searchResult
            )
        } catch {
            XCTAssertNil(self.sut.appState.value.userData.searchResult.error, "Expected no error: \(String(describing: self.sut.appState.value.userData.searchResult.error))", file: #file, line: #line)
        }
        
        self.mockedWebRepo.verify()
        self.mockedDBRepo.verify()
        self.mockedEventLogger.verify()
    }
    
    func test_successfulSearch_givenOpenStoresAndNotFirstOrder_setAppSearchResultState() async {
        
        let searchResult = RetailStoresSearch.mockedData
        let isFirstOrder = false
        
        // Configuring app prexisting states
        appState.value.userData.isFirstOrder = isFirstOrder
        
        // Configuring expected actions on repositories

        mockedWebRepo.actions = .init(expected: [
            .loadRetailStores(
                postcode: searchResult.fulfilmentLocation.postcode,
                isFirstOrder: isFirstOrder
            )
        ])
        mockedDBRepo.actions = .init(expected: [
            .clearSearches,
            .store(
                searchResult: searchResult,
                forPostode: "DD1 3JA",
                isFirstOrder: isFirstOrder
            )
        ])
        
        let appsFlyerParams: [String: Any] = [
            AFEventParamSearchString: searchResult.fulfilmentLocation.postcode,
            AFEventParamLat: searchResult.fulfilmentLocation.latitude,
            AFEventParamLong: searchResult.fulfilmentLocation.longitude,
            "delivery_stores": [1944, 1414, 1807, 910],
            "num_delivery_stores": 4,
            "collection_stores": [1944, 1807],
            "num_collection_stores": 2
        ]
        
        let iterableParams: [String: Any] = [
            "postalCode": searchResult.fulfilmentLocation.postcode,
            "lat": searchResult.fulfilmentLocation.latitude,
            "long": searchResult.fulfilmentLocation.longitude,
            "deliveryStoreIdsFound": [1944, 1414, 1807, 910],
            "totalDeliveryStoresFound": 4,
            "collectionStoreIdsFound": [1944, 1807],
            "totalCollectionStoresFound": 2,
        ]
        
        mockedEventLogger.actions = .init(expected: [
            .sendEvent(for: .storeSearch, with: .appsFlyer, params: appsFlyerParams),
            .sendEvent(for: .storeSearch, with: .iterable, params: iterableParams),
            .sendEvent(for: .storeSearch, with: .firebaseAnalytics, params: ["store_search_result": "open"])
        ])

        // Configuring responses from repositories

        mockedWebRepo.loadRetailStoresByPostcodeResponse = .success(searchResult)
        mockedDBRepo.clearSearchesResult = .success(true)
        mockedDBRepo.storeByPostcode = .success(searchResult)
        
        XCTAssertEqual(appState.value.userData.searchResult, .notRequested)
        
        do {
            try await sut.searchRetailStores(postcode: searchResult.fulfilmentLocation.postcode).singleOutput()
            
            XCTAssertEqual(
                self.sut.appState.value.userData.searchResult.value,
                searchResult
            )
        } catch {
            XCTAssertNil(self.sut.appState.value.userData.searchResult.error, "Expected no error: \(String(describing: self.sut.appState.value.userData.searchResult.error))", file: #file, line: #line)
        }
        
        self.mockedWebRepo.verify()
        self.mockedDBRepo.verify()
        self.mockedEventLogger.verify()
    }
    
    func test_successfulSearch_givenClosedStores_setAppSearchResultState() async {
        
        let searchResult = RetailStoresSearch.mockedDataOnlyClosedStores
        let isFirstOrder = true
        
        // Configuring app prexisting states
        appState.value.userData.isFirstOrder = isFirstOrder
        
        // Configuring expected actions on repositories

        mockedWebRepo.actions = .init(expected: [
            .loadRetailStores(
                postcode: searchResult.fulfilmentLocation.postcode,
                isFirstOrder: isFirstOrder
            )
        ])
        mockedDBRepo.actions = .init(expected: [
            .clearSearches,
            .store(
                searchResult: searchResult,
                forPostode: "DD1 3JA",
                isFirstOrder: isFirstOrder
            )
        ])
        
        let appsFlyerParams: [String: Any] = [
            AFEventParamSearchString: searchResult.fulfilmentLocation.postcode,
            AFEventParamLat: searchResult.fulfilmentLocation.latitude,
            AFEventParamLong: searchResult.fulfilmentLocation.longitude,
            "delivery_stores": [1944, 910],
            "num_delivery_stores": 2,
            "collection_stores": [1944],
            "num_collection_stores": 1
        ]
        
        let iterableParams: [String: Any] = [
            "postalCode": searchResult.fulfilmentLocation.postcode,
            "lat": searchResult.fulfilmentLocation.latitude,
            "long": searchResult.fulfilmentLocation.longitude,
            "deliveryStoreIdsFound": [1944, 910],
            "totalDeliveryStoresFound": 2,
            "collectionStoreIdsFound": [1944],
            "totalCollectionStoresFound": 1,
        ]
        
        mockedEventLogger.actions = .init(expected: [
            .sendEvent(for: .storeSearch, with: .appsFlyer, params: appsFlyerParams),
            .sendEvent(for: .storeSearch, with: .iterable, params: iterableParams),
            .sendEvent(for: .storeSearch, with: .firebaseAnalytics, params: ["store_search_result": "closed"])
        ])

        // Configuring responses from repositories

        mockedWebRepo.loadRetailStoresByPostcodeResponse = .success(searchResult)
        mockedDBRepo.clearSearchesResult = .success(true)
        mockedDBRepo.storeByPostcode = .success(searchResult)
        
        XCTAssertEqual(appState.value.userData.searchResult, .notRequested)
        
        do {
            try await sut.searchRetailStores(postcode: searchResult.fulfilmentLocation.postcode).singleOutput()
            
            XCTAssertEqual(
                self.sut.appState.value.userData.searchResult.value,
                searchResult
            )
        } catch {
            XCTAssertNil(self.sut.appState.value.userData.searchResult.error, "Expected no error: \(String(describing: self.sut.appState.value.userData.searchResult.error))", file: #file, line: #line)
        }
        
        self.mockedWebRepo.verify()
        self.mockedDBRepo.verify()
        self.mockedEventLogger.verify()
    }
    
    func test_successfulSearch_givenNoMatchingStores_setAppSearchResultState() async {
        
        let searchResult = RetailStoresSearch.mockedDataNoMatchingStores
        let isFirstOrder = true
        
        // Configuring app prexisting states
        appState.value.userData.isFirstOrder = isFirstOrder
        
        // Configuring expected actions on repositories

        mockedWebRepo.actions = .init(expected: [
            .loadRetailStores(
                postcode: searchResult.fulfilmentLocation.postcode,
                isFirstOrder: isFirstOrder
            )
        ])
        mockedDBRepo.actions = .init(expected: [
            .clearSearches,
            .store(
                searchResult: searchResult,
                forPostode: "DD1 3JA",
                isFirstOrder: isFirstOrder
            )
        ])
        
        let appsFlyerParams: [String: Any] = [
            AFEventParamSearchString: searchResult.fulfilmentLocation.postcode,
            AFEventParamLat: searchResult.fulfilmentLocation.latitude,
            AFEventParamLong: searchResult.fulfilmentLocation.longitude
        ]
        
        let iterableParams: [String: Any] = [
            "postalCode": searchResult.fulfilmentLocation.postcode,
            "lat": searchResult.fulfilmentLocation.latitude,
            "long": searchResult.fulfilmentLocation.longitude,
            "deliveryStoreIdsFound": [],
            "totalDeliveryStoresFound": 0,
            "collectionStoreIdsFound": [],
            "totalCollectionStoresFound": 0,
        ]
        
        mockedEventLogger.actions = .init(expected: [
            .sendEvent(for: .storeSearch, with: .appsFlyer, params: appsFlyerParams),
            .sendEvent(for: .storeSearch, with: .iterable, params: iterableParams),
            .sendEvent(for: .storeSearch, with: .firebaseAnalytics, params: ["store_search_result": "no_store"])
        ])

        // Configuring responses from repositories

        mockedWebRepo.loadRetailStoresByPostcodeResponse = .success(searchResult)
        mockedDBRepo.clearSearchesResult = .success(true)
        mockedDBRepo.storeByPostcode = .success(searchResult)
        
        XCTAssertEqual(appState.value.userData.searchResult, .notRequested)
        
        do {
            try await sut.searchRetailStores(postcode: searchResult.fulfilmentLocation.postcode).singleOutput()
            
            XCTAssertEqual(
                self.sut.appState.value.userData.searchResult.value,
                searchResult
            )
        } catch {
            XCTAssertNil(self.sut.appState.value.userData.searchResult.error, "Expected no error: \(String(describing: self.sut.appState.value.userData.searchResult.error))", file: #file, line: #line)
        }
        
        self.mockedWebRepo.verify()
        self.mockedDBRepo.verify()
        self.mockedEventLogger.verify()
    }
    
    func test_unsuccessfulSearch_whenNetworkErrorAndNoPreviousResult_nilAppSearchResultState() async {
        
        let networkError = NSError(domain: NSURLErrorDomain, code: -1009, userInfo: [:])
        let searchResult = RetailStoresSearch.mockedData
        let isFirstOrder = true
        
        // Configuring app prexisting states
        appState.value.userData.isFirstOrder = isFirstOrder
        
        // Configuring expected actions on repositories

        mockedWebRepo.actions = .init(expected: [
            .loadRetailStores(
                postcode: searchResult.fulfilmentLocation.postcode,
                isFirstOrder: isFirstOrder
            )
        ])
        mockedDBRepo.actions = .init(expected: [
            .clearSearches
        ])

        // Configuring responses from repositories

        mockedWebRepo.loadRetailStoresByPostcodeResponse = .failure(networkError)
        mockedDBRepo.clearSearchesResult = .success(true)
        
        XCTAssertEqual(appState.value.userData.searchResult, .notRequested)
        
        do {
            try await sut.searchRetailStores(postcode: searchResult.fulfilmentLocation.postcode).singleOutput()
            XCTFail("Expected error to be thrown")
        } catch {
            XCTAssertEqual(error as NSError, networkError)
            XCTAssertEqual(
                self.sut.appState.value.userData.searchResult.value,
                nil
            )
        }
        
        self.mockedWebRepo.verify()
        self.mockedDBRepo.verify()
    }
    
    func test_unsuccessfulSearch_whenNetworkErrorAndPreviousResult_keepPreviousAppSearchResultState() async {
        
        let networkError = NSError(domain: NSURLErrorDomain, code: -1009, userInfo: [:])
        let searchResult = RetailStoresSearch.mockedData
        let isFirstOrder = true
        
        // Configuring app prexisting states
        appState.value.userData.isFirstOrder = isFirstOrder
        appState.value.userData.searchResult = .loaded(searchResult)
        
        // Configuring expected actions on repositories

        mockedWebRepo.actions = .init(expected: [
            .loadRetailStores(
                postcode: searchResult.fulfilmentLocation.postcode,
                isFirstOrder: isFirstOrder
            )
        ])
        mockedDBRepo.actions = .init(expected: [
            .clearSearches
        ])

        // Configuring responses from repositories

        mockedWebRepo.loadRetailStoresByPostcodeResponse = .failure(networkError)
        mockedDBRepo.clearSearchesResult = .success(true)
        
        do {
            try await sut.searchRetailStores(postcode: searchResult.fulfilmentLocation.postcode).singleOutput()
            XCTFail("Expected error to be thrown")
        } catch {
            XCTAssertEqual(error as NSError, networkError)
            XCTAssertEqual(appState.value.userData.searchResult.value, searchResult)
        }
        
        self.mockedWebRepo.verify()
        self.mockedDBRepo.verify()
    }
    
    func test_unsuccessfulSearch_whenUnableToSaveResult_nilAppSearchResultState() async {
        
        let dbError = NSError(domain: "CoreData", code: -1009, userInfo: [:])
        let searchResult = RetailStoresSearch.mockedData
        let isFirstOrder = true
        
        // Configuring app prexisting states
        appState.value.userData.isFirstOrder = isFirstOrder
        
        // Configuring expected actions on repositories

        mockedWebRepo.actions = .init(expected: [
            .loadRetailStores(
                postcode: searchResult.fulfilmentLocation.postcode,
                isFirstOrder: isFirstOrder
            )
        ])
        mockedDBRepo.actions = .init(expected: [
            .clearSearches,
            .store(
                searchResult: searchResult,
                forPostode: "DD1 3JA",
                isFirstOrder: isFirstOrder
            )
        ])

        // Configuring responses from repositories

        mockedWebRepo.loadRetailStoresByPostcodeResponse = .success(searchResult)
        mockedDBRepo.clearSearchesResult = .success(true)
        mockedDBRepo.storeByPostcode = .failure(dbError)
        
        XCTAssertEqual(appState.value.userData.searchResult, .notRequested)
        
        do {
            try await sut.searchRetailStores(postcode: searchResult.fulfilmentLocation.postcode).singleOutput()
            XCTFail("Expected error to be thrown")
        } catch {
            XCTAssertEqual(error as NSError, dbError)
            XCTAssertEqual(
                self.sut.appState.value.userData.searchResult.value,
                nil
            )
            // Returning cancel by user, which is a temporary hack in the RetailStoresService
            //XCTAssertEqual(appState.value.userData.searchResult, .notRequested)
        }
        
        self.mockedWebRepo.verify()
        self.mockedDBRepo.verify()
    }
    
}

// MARK: - func searchRetailStores(search: location:)
final class SearchRetailStoresByLocationTests: RetailStoresServiceTests {
    
    #warning("Needs fixing - 2-3% failure rate")
    func test_successfulSearch_givenIsFirstOrder_setAppSearchResultState() {
        
        let searchResult = RetailStoresSearch.mockedData
        let isFirstOrder = true
        
        // Configuring app prexisting states
        appState.value.userData.isFirstOrder = isFirstOrder
        
        // Configuring expected actions on repositories

        mockedWebRepo.actions = .init(expected: [
            .loadRetailStores(
                location: searchResult.fulfilmentLocation.location,
                isFirstOrder: isFirstOrder
            )
        ])
        mockedDBRepo.actions = .init(expected: [
            .clearSearches,
            .store(
                searchResult: searchResult,
                location: searchResult.fulfilmentLocation.location,
                isFirstOrder: isFirstOrder
            )
        ])

        // Configuring responses from repositories

        mockedWebRepo.loadRetailStoresByLocationResponse = .success(searchResult)
        mockedDBRepo.clearSearchesResult = .success(true)
        mockedDBRepo.storeByLocation = .success(searchResult)
        
        XCTAssertEqual(appState.value.userData.searchResult, .notRequested)
        let exp = XCTestExpectation(description: #function)
        _ = sut.searchRetailStores(location: searchResult.fulfilmentLocation.location)
        delay {
            XCTAssertNil(self.sut.appState.value.userData.searchResult.error, "Expected no error: \(String(describing: self.sut.appState.value.userData.searchResult.error))", file: #file, line: #line)
            XCTAssertEqual(
                self.sut.appState.value.userData.searchResult.value,
                searchResult
            )
            self.mockedWebRepo.verify()
            self.mockedDBRepo.verify()
            exp.fulfill()
        }
        wait(for: [exp], timeout: 2)
    }
    
    func test_successfulSearch_givenIsNotFirstOrder_setAppSearchResultState() {
        
        let searchResult = RetailStoresSearch.mockedData
        let isFirstOrder = false
        
        // Configuring app prexisting states
        appState.value.userData.isFirstOrder = isFirstOrder
        
        // Configuring expected actions on repositories

        mockedWebRepo.actions = .init(expected: [
            .loadRetailStores(
                location: searchResult.fulfilmentLocation.location,
                isFirstOrder: isFirstOrder
            )
        ])
        mockedDBRepo.actions = .init(expected: [
            .clearSearches,
            .store(
                searchResult: searchResult,
                location: searchResult.fulfilmentLocation.location,
                isFirstOrder: isFirstOrder
            )
        ])

        // Configuring responses from repositories

        mockedWebRepo.loadRetailStoresByLocationResponse = .success(searchResult)
        mockedDBRepo.clearSearchesResult = .success(true)
        mockedDBRepo.storeByLocation = .success(searchResult)
        
        XCTAssertEqual(appState.value.userData.searchResult, .notRequested)
        let exp = XCTestExpectation(description: #function)
        _ = sut.searchRetailStores(location: searchResult.fulfilmentLocation.location)
        delay {
            XCTAssertNil(self.sut.appState.value.userData.searchResult.error, "Expected no error: \(String(describing: self.sut.appState.value.userData.searchResult.error))", file: #file, line: #line)
            XCTAssertEqual(
                self.sut.appState.value.userData.searchResult.value,
                searchResult
            )
            self.mockedWebRepo.verify()
            self.mockedDBRepo.verify()
            exp.fulfill()
        }
        wait(for: [exp], timeout: 2)
    }
    
    func test_unsuccessfulSearch_whenNetworkErrorAndNoPreviousResult_nilAppSearchResultState() {
        
        let networkError = NSError(domain: NSURLErrorDomain, code: -1009, userInfo: [:])
        let searchResult = RetailStoresSearch.mockedData
        let isFirstOrder = true
        
        // Configuring app prexisting states
        appState.value.userData.isFirstOrder = isFirstOrder
        
        // Configuring expected actions on repositories

        mockedWebRepo.actions = .init(expected: [
            .loadRetailStores(
                location: searchResult.fulfilmentLocation.location,
                isFirstOrder: isFirstOrder
            )
        ])
        mockedDBRepo.actions = .init(expected: [
            .clearSearches
        ])

        // Configuring responses from repositories

        mockedWebRepo.loadRetailStoresByLocationResponse = .failure(networkError)
        mockedDBRepo.clearSearchesResult = .success(true)
        
        XCTAssertEqual(appState.value.userData.searchResult, .notRequested)
        let exp = XCTestExpectation(description: #function)
        _ = sut.searchRetailStores(location: searchResult.fulfilmentLocation.location)
        delay {
            if let error = self.sut.appState.value.userData.searchResult.error {
                XCTAssertEqual(error as NSError, networkError, file: #file, line: #line)
            } else {
                XCTAssertNotNil(self.sut.appState.value.userData.searchResult.error, "Expected error", file: #file, line: #line)
            }
            XCTAssertEqual(
                self.sut.appState.value.userData.searchResult.value,
                nil
            )
            self.mockedWebRepo.verify()
            self.mockedDBRepo.verify()
            exp.fulfill()
        }
        wait(for: [exp], timeout: 2)
        
    }
    
    func test_unsuccessfulSearch_whenNetworkErrorAndPreviousResult_nilAppSearchResultState() {
        
        let networkError = NSError(domain: NSURLErrorDomain, code: -1009, userInfo: [:])
        let searchResult = RetailStoresSearch.mockedData
        let isFirstOrder = true
        
        // Configuring app prexisting states
        appState.value.userData.isFirstOrder = isFirstOrder
        appState.value.userData.searchResult = .loaded(searchResult)
        
        // Configuring expected actions on repositories

        mockedWebRepo.actions = .init(expected: [
            .loadRetailStores(
                location: searchResult.fulfilmentLocation.location,
                isFirstOrder: isFirstOrder
            )
        ])
        mockedDBRepo.actions = .init(expected: [
            .clearSearches
        ])

        // Configuring responses from repositories

        mockedWebRepo.loadRetailStoresByLocationResponse = .failure(networkError)
        mockedDBRepo.clearSearchesResult = .success(true)
        
        let exp = XCTestExpectation(description: #function)
        _ = sut.searchRetailStores(location: searchResult.fulfilmentLocation.location)
        delay {
            if let error = self.sut.appState.value.userData.searchResult.error {
                XCTAssertEqual(error as NSError, networkError, file: #file, line: #line)
            } else {
                XCTAssertNotNil(self.sut.appState.value.userData.searchResult.error, "Expected error", file: #file, line: #line)
            }
            XCTAssertEqual(
                self.sut.appState.value.userData.searchResult.value,
                nil
            )
            self.mockedWebRepo.verify()
            self.mockedDBRepo.verify()
            exp.fulfill()
        }
        wait(for: [exp], timeout: 2)
        
    }
    
    func test_unsuccessfulSearch_whenUnableToSaveResult_nilAppSearchResultState() {
        
        let dbError = NSError(domain: "CoreData", code: -1009, userInfo: [:])
        let searchResult = RetailStoresSearch.mockedData
        let isFirstOrder = true
        
        // Configuring app prexisting states
        appState.value.userData.isFirstOrder = isFirstOrder
        
        // Configuring expected actions on repositories

        mockedWebRepo.actions = .init(expected: [
            .loadRetailStores(
                location: searchResult.fulfilmentLocation.location,
                isFirstOrder: isFirstOrder
            )
        ])
        mockedDBRepo.actions = .init(expected: [
            .clearSearches,
            .store(
                searchResult: searchResult,
                location: searchResult.fulfilmentLocation.location,
                isFirstOrder: isFirstOrder
            )
        ])

        // Configuring responses from repositories

        mockedWebRepo.loadRetailStoresByLocationResponse = .success(searchResult)
        mockedDBRepo.clearSearchesResult = .success(true)
        mockedDBRepo.storeByPostcode = .failure(dbError)
        
        XCTAssertEqual(appState.value.userData.searchResult, .notRequested)
        let exp = XCTestExpectation(description: #function)
        _ = sut.searchRetailStores(location: searchResult.fulfilmentLocation.location)
        delay {
            XCTAssertEqual(
                self.sut.appState.value.userData.searchResult.value,
                nil
            )
            self.mockedWebRepo.verify()
            self.mockedDBRepo.verify()
            exp.fulfill()
        }
        wait(for: [exp], timeout: 2)
        
    }

}

// MARK: - func repeatLastSearch()
final class RepeatLastSearchTests: RetailStoresServiceTests {
    
    func test_unsuccessfulSearch_whenNoStoredResult_nilAppSearchResultState() async {
        
        // Configuring expected actions on repositories
        
        mockedDBRepo.actions = .init(expected: [
            .lastStoresSearch
        ])
        
        // Configuring responses from repositories

        mockedDBRepo.lastStoresSearchResult = .success(nil)
        
        XCTAssertEqual(appState.value.userData.searchResult, .notRequested)
        
        do {
            try await sut.repeatLastSearch()
            
            XCTAssertNil(self.sut.appState.value.userData.searchResult.error, "Expected no error: \(String(describing: self.sut.appState.value.userData.searchResult.error))", file: #file, line: #line)
            XCTAssertEqual(
                self.sut.appState.value.userData.searchResult.value,
                nil
            )
        } catch {
            XCTFail("Unexpected error: \(error)", file: #file, line: #line)
        }
        
        self.mockedWebRepo.verify()
        self.mockedDBRepo.verify()
    }
    
    func test_successfulSearch_whenStoredResultAndIsFirstOrder_setAppSearchResultState() async {
        
        let searchResult = RetailStoresSearch.mockedData
        let isFirstOrder = true
        
        // Configuring app prexisting states
        appState.value.userData.isFirstOrder = isFirstOrder
        
        // Configuring expected actions on repositories
        
        mockedWebRepo.actions = .init(expected: [
            .loadRetailStores(
                location: searchResult.fulfilmentLocation.location,
                isFirstOrder: isFirstOrder
            ) // 2nd
        ])
        mockedDBRepo.actions = .init(expected: [
            .lastStoresSearch, // 1st
            .clearSearches, // 3rd
            .store(
                searchResult: searchResult,
                location: searchResult.fulfilmentLocation.location,
                isFirstOrder: isFirstOrder
            ), // 4th
            .currentFulfilmentLocation // 5th
        ])
        
        // Configuring responses from repositories

        mockedDBRepo.lastStoresSearchResult = .success(searchResult)
        mockedWebRepo.loadRetailStoresByLocationResponse = .success(searchResult)
        mockedDBRepo.clearSearchesResult = .success(true)
        mockedDBRepo.storeByLocation = .success(searchResult)
        mockedDBRepo.currentFulfilmentLocationResult = .success(searchResult.fulfilmentLocation)
        
        XCTAssertEqual(appState.value.userData.searchResult, .notRequested)
        
        do {
            try await sut.repeatLastSearch()
            
            XCTAssertNil(self.sut.appState.value.userData.searchResult.error, "Expected no error: \(String(describing: self.sut.appState.value.userData.searchResult.error))", file: #file, line: #line)
            XCTAssertEqual(
                self.sut.appState.value.userData.searchResult.value,
                searchResult
            )
            XCTAssertEqual(
                self.appState.value.userData.currentFulfilmentLocation,
                searchResult.fulfilmentLocation
            )
        } catch {
            XCTFail("Unexpected error: \(error)", file: #file, line: #line)
        }
        
        self.mockedWebRepo.verify()
        self.mockedDBRepo.verify()
    }
    
    func test_successfulSearch_whenStoredResultAndIsNotFirstOrder_setAppSearchResultState() async {
        
        let searchResult = RetailStoresSearch.mockedData
        let isFirstOrder = false
        
        // Configuring app prexisting states
        appState.value.userData.isFirstOrder = isFirstOrder
        
        // Configuring expected actions on repositories
        
        mockedWebRepo.actions = .init(expected: [
            .loadRetailStores(
                location: searchResult.fulfilmentLocation.location,
                isFirstOrder: isFirstOrder
            ) // 2nd
        ])
        mockedDBRepo.actions = .init(expected: [
            .lastStoresSearch, // 1st
            .clearSearches, // 3rd
            .store(
                searchResult: searchResult,
                location: searchResult.fulfilmentLocation.location,
                isFirstOrder: isFirstOrder
            ), // 4th
            .currentFulfilmentLocation // 5th
        ])
        
        // Configuring responses from repositories

        mockedDBRepo.lastStoresSearchResult = .success(searchResult)
        mockedWebRepo.loadRetailStoresByLocationResponse = .success(searchResult)
        mockedDBRepo.clearSearchesResult = .success(true)
        mockedDBRepo.storeByLocation = .success(searchResult)
        mockedDBRepo.currentFulfilmentLocationResult = .success(searchResult.fulfilmentLocation)
        
        XCTAssertEqual(appState.value.userData.searchResult, .notRequested)
        
        do {
            try await sut.repeatLastSearch()
            
            XCTAssertNil(self.sut.appState.value.userData.searchResult.error, "Expected no error: \(String(describing: self.sut.appState.value.userData.searchResult.error))", file: #file, line: #line)
            XCTAssertEqual(
                self.sut.appState.value.userData.searchResult.value,
                searchResult
            )
            XCTAssertEqual(
                self.appState.value.userData.currentFulfilmentLocation,
                searchResult.fulfilmentLocation
            )
        } catch {
            XCTFail("Unexpected error: \(error)", file: #file, line: #line)
        }
        
        self.mockedWebRepo.verify()
        self.mockedDBRepo.verify()
    }
    
    func test_successfulSearch_whenStoredResultAndNetworkError_nilAppSearchResultState() async {
        
        let networkError = NSError(domain: NSURLErrorDomain, code: -1009, userInfo: [:])
        let searchResult = RetailStoresSearch.mockedData
        let isFirstOrder = true
        
        // Configuring app prexisting states
        appState.value.userData.isFirstOrder = isFirstOrder
        
        // Configuring expected actions on repositories
        
        mockedWebRepo.actions = .init(expected: [
            .loadRetailStores(
                location: searchResult.fulfilmentLocation.location,
                isFirstOrder: isFirstOrder
            ) // 2nd
        ])
        mockedDBRepo.actions = .init(expected: [
            .lastStoresSearch, // 1st
        ])
        
        // Configuring responses from repositories

        mockedDBRepo.lastStoresSearchResult = .success(searchResult)
        mockedWebRepo.loadRetailStoresByLocationResponse = .failure(networkError)
        
        XCTAssertEqual(appState.value.userData.searchResult, .notRequested)
        
        do {
            try await sut.repeatLastSearch()
        } catch {
            XCTAssertEqual(error as NSError, networkError, file: #file, line: #line)
        }
        
        self.mockedWebRepo.verify()
        self.mockedDBRepo.verify()
    }
}


// MARK: - func repeatLastSearch()
final class RestoreLastSelectedStoreTests: RetailStoresServiceTests {
    func test_givenNoResult_whenRestoreLastSelectedStoreTriggered_thenSelectedStoreInAppStateIsNotRequested() async {
        
        // Configuring expected actions on repositories
        mockedDBRepo.actions = .init(expected: [.lastSelectedStore])
        mockedDBRepo.lastSelectedStoreResult = .success(nil)
        
        XCTAssertEqual(AppState().userData.selectedStore, .notRequested)
        
        do {
            try await sut.restoreLastSelectedStore(postcode: "")
            
            XCTAssertNil(self.sut.appState.value.userData.selectedStore.error, "Expected no error: \(String(describing: self.sut.appState.value.userData.selectedStore.error))", file: #file, line: #line)
            XCTAssertEqual(
                self.sut.appState.value.userData.selectedStore.value,
                nil
            )
        } catch {
            XCTFail("Unexpected error: \(error)", file: #file, line: #line)
        }
        
        self.mockedWebRepo.verify()
        self.mockedDBRepo.verify()
    }
    
    func test_givenResult_whenRestoreLastSelectedStoreTriggeredAndIsFirstOrder_thenSelectedStoreInAppStateIsLoadedWithResult() async {
        let restoredStoreResult = RetailStoreDetails.mockedData
        let isFirstOrder = true
        
        // Configuring app prexisting states
        appState.value.userData.isFirstOrder = isFirstOrder
        
        // Configuring expected actions on repositories
        mockedWebRepo.actions = .init(expected: [
            .loadRetailStoreDetails(
                storeId: restoredStoreResult.id,
                postcode: restoredStoreResult.postcode,
                isFirstOrder: isFirstOrder
            ) // 2nd
        ])
        mockedDBRepo.actions = .init(expected: [
            .lastSelectedStore, // 1st
            .clearRetailStoreDetails, // 3rd
            .store(
                storeDetails: restoredStoreResult,
                forPostode: restoredStoreResult.postcode,
                isFirstOrder: isFirstOrder
            ) // 4th
        ])
        
        mockedDBRepo.lastSelectedStoreResult = .success(restoredStoreResult)
        mockedWebRepo.loadRetailStoreDetailsResponse = .success(restoredStoreResult)
        mockedDBRepo.clearRetailStoreDetailsResult = .success(true)
        mockedDBRepo.storeDetailsByPostcode = .success(restoredStoreResult)
        
        XCTAssertEqual(AppState().userData.selectedStore, .notRequested)
        
        do {
            try await sut.restoreLastSelectedStore(postcode: restoredStoreResult.postcode)
            
            XCTAssertNil(self.sut.appState.value.userData.selectedStore.error, "Expected no error: \(String(describing: self.sut.appState.value.userData.selectedStore.error))", file: #file, line: #line)
            XCTAssertEqual(
                self.sut.appState.value.userData.selectedStore.value,
                restoredStoreResult
            )
        } catch {
            XCTFail("Unexpected error: \(error)", file: #file, line: #line)
        }
        
        self.mockedWebRepo.verify()
        self.mockedDBRepo.verify()
    }
    
    func test_givenResult_whenRestoreLastSelectedStoreTriggeredAndIsNotFirstOrder_thenSelectedStoreInAppStateIsLoadedWithResult() async {
        let restoredStoreResult = RetailStoreDetails.mockedData
        let isFirstOrder = false
        
        // Configuring app prexisting states
        appState.value.userData.isFirstOrder = isFirstOrder
        
        // Configuring expected actions on repositories
        mockedWebRepo.actions = .init(expected: [
            .loadRetailStoreDetails(
                storeId: restoredStoreResult.id,
                postcode: restoredStoreResult.postcode,
                isFirstOrder: isFirstOrder
            ) // 2nd
        ])
        mockedDBRepo.actions = .init(expected: [
            .lastSelectedStore, // 1st
            .clearRetailStoreDetails, // 3rd
            .store(
                storeDetails: restoredStoreResult,
                forPostode: restoredStoreResult.postcode,
                isFirstOrder: isFirstOrder
            ) // 4th
        ])
        
        mockedDBRepo.lastSelectedStoreResult = .success(restoredStoreResult)
        mockedWebRepo.loadRetailStoreDetailsResponse = .success(restoredStoreResult)
        mockedDBRepo.clearRetailStoreDetailsResult = .success(true)
        mockedDBRepo.storeDetailsByPostcode = .success(restoredStoreResult)
        
        XCTAssertEqual(AppState().userData.selectedStore, .notRequested)
        
        do {
            try await sut.restoreLastSelectedStore(postcode: restoredStoreResult.postcode)
            
            XCTAssertNil(self.sut.appState.value.userData.selectedStore.error, "Expected no error: \(String(describing: self.sut.appState.value.userData.selectedStore.error))", file: #file, line: #line)
            XCTAssertEqual(
                self.sut.appState.value.userData.selectedStore.value,
                restoredStoreResult
            )
        } catch {
            XCTFail("Unexpected error: \(error)", file: #file, line: #line)
        }
        
        self.mockedWebRepo.verify()
        self.mockedDBRepo.verify()
    }
    
    func test_givenNetworkError_whenRestoreLastSelectedStoreTriggered_thenSelectedStoreInAppStateIsNilAndError() async {
        let networkError = NSError(domain: NSURLErrorDomain, code: -1009, userInfo: [:])
        let restoredStoreResult = RetailStoreDetails.mockedData
        let isFirstOrder = true
        
        // Configuring app prexisting states
        appState.value.userData.isFirstOrder = isFirstOrder
        
        // Configuring expected actions on repositories
        mockedWebRepo.actions = .init(expected: [
            .loadRetailStoreDetails(
                storeId: restoredStoreResult.id,
                postcode: restoredStoreResult.postcode,
                isFirstOrder: isFirstOrder
            ) // 2nd
        ])
        mockedDBRepo.actions = .init(expected: [
            .lastSelectedStore
        ])
        
        mockedDBRepo.lastSelectedStoreResult = .success(restoredStoreResult)
        mockedWebRepo.loadRetailStoreDetailsResponse = .failure(networkError)
        
        XCTAssertEqual(AppState().userData.selectedStore, .notRequested)
        
        do {
            try await sut.restoreLastSelectedStore(postcode: restoredStoreResult.postcode)
        } catch {
            XCTAssertEqual(error as NSError, networkError, file: #file, line: #line)
        }
        
        self.mockedWebRepo.verify()
        self.mockedDBRepo.verify()
    }
}

// MARK: - func getStoreDetails(storeId:postcode:)
final class GetStoreDetailsTests: RetailStoresServiceTests {
    
    func test_successfulGetStoreDetails_givenIsFirstOrder() async {
        
        let storeDetails = RetailStoreDetails.mockedData
        let isFirstOrder = true
        
        // Configuring app prexisting states
        appState.value.userData.isFirstOrder = isFirstOrder
        sut.appState.value.storeMenu.rootCategories = [RetailStoreMenuCategory.mockedData]
        sut.appState.value.storeMenu.subCategories = [[RetailStoreMenuCategory.mockedData]]
        sut.appState.value.storeMenu.unsortedItems = [RetailStoreMenuItem.mockedData]
        sut.appState.value.storeMenu.specialOfferItems = [RetailStoreMenuItem.mockedData]
        
        // Configuring expected actions on repositories
        
        mockedWebRepo.actions = .init(expected: [
            .loadRetailStoreDetails(
                storeId: storeDetails.id,
                postcode: "DD1 3JA",
                isFirstOrder: isFirstOrder
            ) // 2nd
        ])
        mockedDBRepo.actions = .init(expected: [
            .clearRetailStoreDetails, // 1st
            .store(
                storeDetails: storeDetails,
                forPostode: "DD1 3JA",
                isFirstOrder: isFirstOrder
            ) // 3rd
        ])
    
        // Configuring expected events
        mockedEventLogger.actions = .init(expected: [
            .sendEvent(
                for: .selectStore,
                with: .appsFlyer,
                params: [
                    "store_id": storeDetails.id,
                    "fulfilment_method" : appState.value.userData.selectedFulfilmentMethod.rawValue]
            )
        ])
        
        // Configuring responses from repositories

        mockedDBRepo.clearRetailStoreDetailsResult = .success(true)
        mockedDBRepo.storeDetailsByPostcode = .success(storeDetails)
        mockedWebRepo.loadRetailStoreDetailsResponse = .success(storeDetails)
        
        XCTAssertEqual(sut.appState.value.userData.selectedStore, .notRequested)
        
        do {
            try await sut.getStoreDetails(storeId: storeDetails.id, postcode: "DD1 3JA").singleOutput()
            
            XCTAssertEqual(
                self.sut.appState.value.userData.selectedStore.value,
                storeDetails
            )
        } catch {
            XCTFail("Unexpected fail - Error: \(error)")
        }
        
        XCTAssertTrue(sut.appState.value.storeMenu.rootCategories.isEmpty)
        XCTAssertTrue(sut.appState.value.storeMenu.subCategories.isEmpty)
        XCTAssertTrue(sut.appState.value.storeMenu.unsortedItems.isEmpty)
        XCTAssertTrue(sut.appState.value.storeMenu.specialOfferItems.isEmpty)
        self.mockedWebRepo.verify()
        self.mockedDBRepo.verify()
        self.mockedEventLogger.verify()
    }
    
    func test_successfulGetStoreDetails_givenIsNotFirstOrder() async {
        
        let storeDetails = RetailStoreDetails.mockedData
        let isFirstOrder = false
        
        // Configuring app prexisting states
        appState.value.userData.isFirstOrder = isFirstOrder
        sut.appState.value.storeMenu.rootCategories = [RetailStoreMenuCategory.mockedData]
        sut.appState.value.storeMenu.subCategories = [[RetailStoreMenuCategory.mockedData]]
        sut.appState.value.storeMenu.unsortedItems = [RetailStoreMenuItem.mockedData]
        sut.appState.value.storeMenu.specialOfferItems = [RetailStoreMenuItem.mockedData]
        
        // Configuring expected actions on repositories
        
        mockedWebRepo.actions = .init(expected: [
            .loadRetailStoreDetails(
                storeId: storeDetails.id,
                postcode: "DD1 3JA",
                isFirstOrder: isFirstOrder
            ) // 2nd
        ])
        mockedDBRepo.actions = .init(expected: [
            .clearRetailStoreDetails, // 1st
            .store(
                storeDetails: storeDetails,
                forPostode: "DD1 3JA",
                isFirstOrder: isFirstOrder
            ) // 3rd
        ])
    
        // Configuring expected events
        mockedEventLogger.actions = .init(expected: [
            .sendEvent(
                for: .selectStore,
                with: .appsFlyer,
                params: [
                    "store_id": storeDetails.id,
                    "fulfilment_method" : appState.value.userData.selectedFulfilmentMethod.rawValue]
            )
        ])
        
        // Configuring responses from repositories

        mockedDBRepo.clearRetailStoreDetailsResult = .success(true)
        mockedDBRepo.storeDetailsByPostcode = .success(storeDetails)
        mockedWebRepo.loadRetailStoreDetailsResponse = .success(storeDetails)
        
        XCTAssertEqual(sut.appState.value.userData.selectedStore, .notRequested)
        
        do {
            try await sut.getStoreDetails(storeId: storeDetails.id, postcode: "DD1 3JA").singleOutput()
            
            XCTAssertEqual(
                self.sut.appState.value.userData.selectedStore.value,
                storeDetails
            )
        } catch {
            XCTFail("Unexpected fail - Error: \(error)")
        }
        
        XCTAssertTrue(sut.appState.value.storeMenu.rootCategories.isEmpty)
        XCTAssertTrue(sut.appState.value.storeMenu.subCategories.isEmpty)
        XCTAssertTrue(sut.appState.value.storeMenu.unsortedItems.isEmpty)
        XCTAssertTrue(sut.appState.value.storeMenu.specialOfferItems.isEmpty)
        self.mockedWebRepo.verify()
        self.mockedDBRepo.verify()
        self.mockedEventLogger.verify()
    }
    
    func test_unsuccessfulGetStoreDetails_whenNetworkError() async {
        
        let networkError = NSError(domain: NSURLErrorDomain, code: -1009, userInfo: [:])
        let storeDetails = RetailStoreDetails.mockedData
        let isFirstOrder = true
        
        // Configuring app prexisting states
        appState.value.userData.isFirstOrder = isFirstOrder
        
        // Configuring expected actions on repositories
        
        mockedWebRepo.actions = .init(expected: [
            .loadRetailStoreDetails(
                storeId: storeDetails.id,
                postcode: "DD1 3JA",
                isFirstOrder: isFirstOrder
            ) // 2nd
        ])
        mockedDBRepo.actions = .init(expected: [
            .clearRetailStoreDetails, // 1st
        ])
        
        // Configuring responses from repositories

        mockedDBRepo.clearRetailStoreDetailsResult = .success(true)
        mockedWebRepo.loadRetailStoreDetailsResponse = .failure(networkError)
        
        XCTAssertEqual(sut.appState.value.userData.selectedStore, .notRequested)
        
        do {
            try await sut.getStoreDetails(storeId: storeDetails.id, postcode: "DD1 3JA").singleOutput()
            
            XCTAssertEqual(
                self.sut.appState.value.userData.selectedStore.value,
                nil
            )
        } catch {
            if let error = self.sut.appState.value.userData.selectedStore.error {
                XCTAssertEqual(
                    error as NSError,
                    networkError
                )
            } else {
                XCTFail("Unexpected error: \(String(describing: self.sut.appState.value.userData.selectedStore.error))", file: #file, line: #line)
            }
        }
        
        self.mockedWebRepo.verify()
        self.mockedDBRepo.verify()
        self.mockedEventLogger.verify()
    }
}

// MARK: - func getStoreDeliveryTimeSlots(slots:storeId:startDate:endDate:location:)
final class GetStoreDeliveryTimeSlotsTests: RetailStoresServiceTests {
    
    func test_succesfulGetStoreDeliveryTimeSlots() {
        
        let slotsAPIResult = RetailStoreTimeSlots.mockedAPIResponseData
        let slots = RetailStoreTimeSlots.mockedPersistedDataWithCoordinates(basedOn: slotsAPIResult)
        let location = CLLocationCoordinate2D(latitude: slots.searchLatitude ?? 0, longitude: slots.searchLongitude ?? 0)
        
        // Configuring expected actions on repositories

        mockedWebRepo.actions = .init(expected: [
            .loadRetailStoreTimeSlots(
                storeId: slots.searchStoreId ?? 0,
                startDate: slots.startDate,
                endDate: slots.endDate,
                method: .delivery,
                location: location
            )
        ])
        mockedDBRepo.actions = .init(expected: [
            .clearRetailStoreTimeSlots,
            .store(
                storeTimeSlots: slotsAPIResult,
                forStoreId: slots.searchStoreId ?? 0,
                location: location
            )
        ])

        // Configuring responses from repositories

        mockedWebRepo.loadRetailStoreTimeSlotsResponse = .success(slotsAPIResult)
        mockedDBRepo.clearRetailStoreTimeSlotsResult = .success(true)
        mockedDBRepo.storeTimeSlotsBy = .success(slots)
        
        let exp = XCTestExpectation(description: #function)
        let timeSlots = BindingWithPublisher(value: Loadable<RetailStoreTimeSlots>.notRequested)
        sut.getStoreDeliveryTimeSlots(
            slots: timeSlots.binding,
            storeId: slots.searchStoreId ?? 0,
            startDate: slots.startDate,
            endDate: slots.endDate,
            location: location
        )
        timeSlots.updatesRecorder.sink { updates in
            XCTAssertEqual(updates, [
                .notRequested,
                .isLoading(last: nil, cancelBag: CancelBag()),
                .loaded(slots)
            ], removing: [])
            self.mockedWebRepo.verify()
            self.mockedDBRepo.verify()
            exp.fulfill()
        }.store(in: &subscriptions)
        wait(for: [exp], timeout: 2)
    }
    
    func test_unsuccesfulGetStoreDeliveryTimeSlots_whenNetworkError_returnError() {
        
        let networkError = NSError(domain: NSURLErrorDomain, code: -1009, userInfo: [:])
        
        // dummy values that do not require realistic values
        let date = Date()
        let location = CLLocationCoordinate2D(latitude: 0, longitude: 0)
        
        // Configuring expected actions on repositories

        mockedWebRepo.actions = .init(expected: [
            .loadRetailStoreTimeSlots(
                storeId: 30,
                startDate: date,
                endDate: date,
                method: .delivery,
                location: CLLocationCoordinate2D(latitude: 0, longitude: 0)
            )
        ])
        mockedDBRepo.actions = .init(expected: [
            .clearRetailStoreTimeSlots
        ])

        // Configuring responses from repositories

        mockedWebRepo.loadRetailStoreTimeSlotsResponse = .failure(networkError)
        mockedDBRepo.clearRetailStoreTimeSlotsResult = .success(true)
        
        let exp = XCTestExpectation(description: #function)
        let timeSlots = BindingWithPublisher(value: Loadable<RetailStoreTimeSlots>.notRequested)
        sut.getStoreDeliveryTimeSlots(
            slots: timeSlots.binding,
            storeId: 30,
            startDate: date,
            endDate: date,
            location: location
        )
        timeSlots.updatesRecorder.sink { updates in
            XCTAssertEqual(updates, [
                .notRequested,
                .isLoading(last: nil, cancelBag: CancelBag()),
                .failed(networkError)
            ], removing: [])
            self.mockedWebRepo.verify()
            self.mockedDBRepo.verify()
            exp.fulfill()
        }.store(in: &subscriptions)
        wait(for: [exp], timeout: 2)
    }
    
}

// MARK: - func getStoreCollectionTimeSlots(slots:storeId:startDate:endDate:)
final class GetStoreCollectionTimeSlotsTests: RetailStoresServiceTests {
    
    func test_succesfulGetStoreCollectionTimeSlots() {
        
        let slotsAPIResult = RetailStoreTimeSlots.mockedAPIResponseData
        let slots = RetailStoreTimeSlots.mockedPersistedDataWithoutCoordinates(basedOn: slotsAPIResult)
        
        // Configuring expected actions on repositories

        mockedWebRepo.actions = .init(expected: [
            .loadRetailStoreTimeSlots(
                storeId: slots.searchStoreId ?? 0,
                startDate: slots.startDate,
                endDate: slots.endDate,
                method: .collection,
                location: nil
            )
        ])
        mockedDBRepo.actions = .init(expected: [
            .clearRetailStoreTimeSlots,
            .store(
                storeTimeSlots: slotsAPIResult,
                forStoreId: slots.searchStoreId ?? 0,
                location: nil
            )
        ])

        // Configuring responses from repositories

        mockedWebRepo.loadRetailStoreTimeSlotsResponse = .success(slotsAPIResult)
        mockedDBRepo.clearRetailStoreTimeSlotsResult = .success(true)
        mockedDBRepo.storeTimeSlotsBy = .success(slots)
        
        let exp = XCTestExpectation(description: #function)
        let timeSlots = BindingWithPublisher(value: Loadable<RetailStoreTimeSlots>.notRequested)
        sut.getStoreCollectionTimeSlots(
            slots: timeSlots.binding,
            storeId: slots.searchStoreId ?? 0,
            startDate: slots.startDate,
            endDate: slots.endDate
        )
        timeSlots.updatesRecorder.sink { updates in
            XCTAssertEqual(updates, [
                .notRequested,
                .isLoading(last: nil, cancelBag: CancelBag()),
                .loaded(slots)
            ], removing: [])
            self.mockedWebRepo.verify()
            self.mockedDBRepo.verify()
            exp.fulfill()
        }.store(in: &subscriptions)
        wait(for: [exp], timeout: 2)
    }
    
    func test_unsuccesfulGetStoreDeliveryTimeSlots_whenNetworkError_returnError() {
        
        let networkError = NSError(domain: NSURLErrorDomain, code: -1009, userInfo: [:])
        
        // dummy value that does not require a realistic value
        let date = Date()
        
        // Configuring expected actions on repositories

        mockedWebRepo.actions = .init(expected: [
            .loadRetailStoreTimeSlots(
                storeId: 30,
                startDate: date,
                endDate: date,
                method: .collection,
                location: nil
            )
        ])
        mockedDBRepo.actions = .init(expected: [
            .clearRetailStoreTimeSlots
        ])

        // Configuring responses from repositories

        mockedWebRepo.loadRetailStoreTimeSlotsResponse = .failure(networkError)
        mockedDBRepo.clearRetailStoreTimeSlotsResult = .success(true)
        
        let exp = XCTestExpectation(description: #function)
        let timeSlots = BindingWithPublisher(value: Loadable<RetailStoreTimeSlots>.notRequested)
        sut.getStoreCollectionTimeSlots(
            slots: timeSlots.binding,
            storeId: 30,
            startDate: date,
            endDate: date
        )
        timeSlots.updatesRecorder.sink { updates in
            XCTAssertEqual(updates, [
                .notRequested,
                .isLoading(last: nil, cancelBag: CancelBag()),
                .failed(networkError)
            ], removing: [])
            self.mockedWebRepo.verify()
            self.mockedDBRepo.verify()
            exp.fulfill()
        }.store(in: &subscriptions)
        wait(for: [exp], timeout: 2)
    }
    
}

// MARK: - func futureContactRequest(email:)
final class FutureContactRequestTests: RetailStoresServiceTests {
    
    func test_successfulFutureContactRequest() async {
        let searchResult = RetailStoresSearch.mockedDataNoMatchingStores
        let email = "someone@me.com"
        appState.value.userData.searchResult = .loaded(searchResult)
        
        // Configuring expected actions on repositories
        mockedWebRepo.actions = .init(expected: [.futureContactRequest(email: email, postcode: searchResult.fulfilmentLocation.postcode)])
        mockedWebRepo.futureContactRequestResponse = .success(FutureContactRequestResponse.mockedData)
        let params: [String: Any] = [
            "contact_postcode": searchResult.fulfilmentLocation.postcode,
            AFEventParamLat: searchResult.fulfilmentLocation.latitude,
            AFEventParamLong: searchResult.fulfilmentLocation.longitude
        ]
        mockedEventLogger.actions = .init(expected: [
            .sendEvent(for: .futureContact, with: .appsFlyer, params: params),
            .sendEvent(for: .futureContact, with: .firebaseAnalytics, params: ["search_text": searchResult.fulfilmentLocation.postcode])
        ])
        
        do {
            let _ = try await sut.futureContactRequest(email: email)
            
            self.mockedWebRepo.verify()
            self.mockedEventLogger.verify()
        } catch {
            XCTFail("Unexpected error - Error: \(error)", file: #file, line: #line)
        }
    }
    
    func test_unsuccessfulFutureContactRequest_whenStoresWereMatched() async {
        let searchResult = RetailStoresSearch.mockedData
        let email = "someone@me.com"
        appState.value.userData.searchResult = .loaded(searchResult)
                
        do {
            let result = try await sut.futureContactRequest(email: email)
            XCTFail("Unexpected result - Result: \(result ?? "")", file: #file, line: #line)
        } catch {
            XCTAssertEqual(error as? RetailStoresServiceError, RetailStoresServiceError.cannotUseWhenFoundStores, file: #file, line: #line)
            self.mockedWebRepo.verify()
            self.mockedEventLogger.verify()
        }
    }
}

// MARK: - sendReview(for review: RetailStoreReview, rating: Int, comments: String?)
final class SendReviewTests: RetailStoresServiceTests {
    func test_successfulSendReview() async {
        let review = RetailStoreReview.mockedData
        let rating = 4
        let comments = "Some comments"
        let data = RetailStoreReviewResponse.mockedDataSucess
        
        // Configuring expected actions on repositories
        mockedWebRepo.actions = .init(expected: [
            .sendRetailStoreCustomerRating(
                orderId: review.orderId,
                hash: review.hash,
                rating: rating,
                comments: comments
            )
        ])
        mockedWebRepo.sendRetailStoreCustomerRatingResponse = .success(data)
        
        do {
            let message = try await sut.sendReview(for: review, rating: rating, comments: comments)
            XCTAssertEqual(message, data.message, file: #file, line: #line)
            mockedWebRepo.verify()
            mockedEventLogger.verify()
        } catch {
            XCTFail("Unexpected error - Error: \(error)", file: #file, line: #line)
        }
    }
    
    func test_unsuccessfulSendReview() async {
        let review = RetailStoreReview.mockedData
        let rating = 4
        let comments = "Some comments"
        let data = RetailStoreReviewResponse.mockedDataFailure
        
        // Configuring expected actions on repositories
        mockedWebRepo.actions = .init(expected: [
            .sendRetailStoreCustomerRating(
                orderId: review.orderId,
                hash: review.hash,
                rating: rating,
                comments: comments
            )
        ])
        mockedWebRepo.sendRetailStoreCustomerRatingResponse = .success(data)
        
        do {
            let message = try await sut.sendReview(for: review, rating: rating, comments: comments)
            XCTFail("Unexpected result - \(message)", file: #file, line: #line)
        } catch {
            if let error = error as? RetailStoresServiceError {
                XCTAssertEqual(error, RetailStoresServiceError.cannotSendStoreReview(data.message), file: #file, line: #line)
            } else {
                XCTFail("Unexpected error type: \(error)", file: #file, line: #line)
            }
            mockedWebRepo.verify()
            mockedEventLogger.verify()
        }
    }
}

extension RetailStoresSearch: PrefixRemovable { }
