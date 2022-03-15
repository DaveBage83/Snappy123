//
//  RetailStoresServiceTests.swift
//  SnappyV2Tests
//
//  Created by Kevin Palser on 26/09/2021.
//

import XCTest
import Combine
@testable import SnappyV2

class RetailStoresServiceTests: XCTestCase {

    let appState = CurrentValueSubject<AppState, Never>(AppState())
    var mockedWebRepo: MockedRetailStoresWebRepository!
    var mockedDBRepo: MockedRetailStoresDBRepository!
    var subscriptions = Set<AnyCancellable>()
    var sut: RetailStoresService!

    override func setUp() {
        mockedWebRepo = MockedRetailStoresWebRepository()
        mockedDBRepo = MockedRetailStoresDBRepository()
        sut = RetailStoresService(
            webRepository: mockedWebRepo,
            dbRepository: mockedDBRepo,
            appState: appState
        )
    }
    
    func delay(_ closure: @escaping () -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: closure)
    }

    override func tearDown() {
        subscriptions = Set<AnyCancellable>()
        mockedWebRepo = nil
        mockedDBRepo = nil
        sut = nil
    }
}

/*
func searchRetailStores(postcode: String)
func searchRetailStores(location: CLLocationCoordinate2D)
func repeatLastSearch()
func getStoreDetails(storeId: Int, postcode: String)
func getStoreDeliveryTimeSlots(slots: LoadableSubject<RetailStoreTimeSlots>, storeId: Int, startDate: Date, endDate: Date, location: CLLocationCoordinate2D)
func getStoreCollectionTimeSlots(slots: LoadableSubject<RetailStoreTimeSlots>, storeId: Int, startDate: Date, endDate: Date)
*/

// MARK: - func searchRetailStores(postcode:)
final class SearchRetailStoresByPostcodeTests: RetailStoresServiceTests {
    
    func test_successfulSearch_setAppSearchResultState() {
        
        let searchResult = RetailStoresSearch.mockedData
        
        // Configuring expected actions on repositories

        mockedWebRepo.actions = .init(expected: [
            .loadRetailStores(postcode: searchResult.fulfilmentLocation.postcode)
        ])
        mockedDBRepo.actions = .init(expected: [
            .clearSearches,
            .store(searchResult: searchResult, forPostode: "DD1 3JA")
        ])

        // Configuring responses from repositories

        mockedWebRepo.loadRetailStoresByPostcodeResponse = .success(searchResult)
        mockedDBRepo.clearSearchesResult = .success(true)
        mockedDBRepo.storeByPostcode = .success(searchResult)
        
        XCTAssertEqual(AppState().userData.searchResult, .notRequested)
        let exp = XCTestExpectation(description: #function)
        sut.searchRetailStores(postcode: searchResult.fulfilmentLocation.postcode)
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
        wait(for: [exp], timeout: 0.5)
    }
    
    
    func test_unsuccessfulSearch_whenNetworkErrorAndNoPreviousResult_nilAppSearchResultState() {
        
        let networkError = NSError(domain: NSURLErrorDomain, code: -1009, userInfo: [:])
        let searchResult = RetailStoresSearch.mockedData
        
        // Configuring expected actions on repositories

        mockedWebRepo.actions = .init(expected: [
            .loadRetailStores(postcode: searchResult.fulfilmentLocation.postcode)
        ])
        mockedDBRepo.actions = .init(expected: [
            .clearSearches
        ])

        // Configuring responses from repositories

        mockedWebRepo.loadRetailStoresByPostcodeResponse = .failure(networkError)
        mockedDBRepo.clearSearchesResult = .success(true)
        
        XCTAssertEqual(AppState().userData.searchResult, .notRequested)
        let exp = XCTestExpectation(description: #function)
        sut.searchRetailStores(postcode: searchResult.fulfilmentLocation.postcode)
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
        wait(for: [exp], timeout: 0.5)
        
    }
    
    func test_unsuccessfulSearch_whenNetworkErrorAndPreviousResult_nilAppSearchResultState() {
        
        let networkError = NSError(domain: NSURLErrorDomain, code: -1009, userInfo: [:])
        let searchResult = RetailStoresSearch.mockedData
        
        // Configuring app prexisting states
        appState.value.userData.searchResult = .loaded(searchResult)
        
        // Configuring expected actions on repositories

        mockedWebRepo.actions = .init(expected: [
            .loadRetailStores(postcode: searchResult.fulfilmentLocation.postcode)
        ])
        mockedDBRepo.actions = .init(expected: [
            .clearSearches
        ])

        // Configuring responses from repositories

        mockedWebRepo.loadRetailStoresByPostcodeResponse = .failure(networkError)
        mockedDBRepo.clearSearchesResult = .success(true)
        
        XCTAssertEqual(AppState().userData.searchResult, .notRequested)
        let exp = XCTestExpectation(description: #function)
        sut.searchRetailStores(postcode: searchResult.fulfilmentLocation.postcode)
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
        wait(for: [exp], timeout: 0.5)
        
    }
    
    func test_unsuccessfulSearch_whenUnableToSaveResult_nilAppSearchResultState() {
        
        let dbError = NSError(domain: "CoreData", code: -1009, userInfo: [:])
        let searchResult = RetailStoresSearch.mockedData
        
        // Configuring expected actions on repositories

        mockedWebRepo.actions = .init(expected: [
            .loadRetailStores(postcode: searchResult.fulfilmentLocation.postcode)
        ])
        mockedDBRepo.actions = .init(expected: [
            .clearSearches,
            .store(searchResult: searchResult, forPostode: "DD1 3JA")
        ])

        // Configuring responses from repositories

        mockedWebRepo.loadRetailStoresByPostcodeResponse = .success(searchResult)
        mockedDBRepo.clearSearchesResult = .success(true)
        mockedDBRepo.storeByPostcode = .failure(dbError)
        
        XCTAssertEqual(AppState().userData.searchResult, .notRequested)
        let exp = XCTestExpectation(description: #function)
        sut.searchRetailStores(postcode: searchResult.fulfilmentLocation.postcode)
        delay {
            if let error = self.sut.appState.value.userData.searchResult.error {
                XCTAssertEqual(error as NSError, dbError, file: #file, line: #line)
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
        wait(for: [exp], timeout: 0.5)
        
    }
    
}

// MARK: - func searchRetailStores(search: location:)
final class SearchRetailStoresByLocationTests: RetailStoresServiceTests {
    
    func test_successfulSearch_setAppSearchResultState() {
        
        let searchResult = RetailStoresSearch.mockedData
        
        // Configuring expected actions on repositories

        mockedWebRepo.actions = .init(expected: [
            .loadRetailStores(location: searchResult.fulfilmentLocation.location)
        ])
        mockedDBRepo.actions = .init(expected: [
            .clearSearches,
            .store(searchResult: searchResult, location: searchResult.fulfilmentLocation.location)
        ])

        // Configuring responses from repositories

        mockedWebRepo.loadRetailStoresByLocationResponse = .success(searchResult)
        mockedDBRepo.clearSearchesResult = .success(true)
        mockedDBRepo.storeByLocation = .success(searchResult)
        
        XCTAssertEqual(AppState().userData.searchResult, .notRequested)
        let exp = XCTestExpectation(description: #function)
        sut.searchRetailStores(location: searchResult.fulfilmentLocation.location)
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
        wait(for: [exp], timeout: 0.5)
    }
    
    
    func test_unsuccessfulSearch_whenNetworkErrorAndNoPreviousResult_nilAppSearchResultState() {
        
        let networkError = NSError(domain: NSURLErrorDomain, code: -1009, userInfo: [:])
        let searchResult = RetailStoresSearch.mockedData
        
        // Configuring expected actions on repositories

        mockedWebRepo.actions = .init(expected: [
            .loadRetailStores(location: searchResult.fulfilmentLocation.location)
        ])
        mockedDBRepo.actions = .init(expected: [
            .clearSearches
        ])

        // Configuring responses from repositories

        mockedWebRepo.loadRetailStoresByLocationResponse = .failure(networkError)
        mockedDBRepo.clearSearchesResult = .success(true)
        
        XCTAssertEqual(AppState().userData.searchResult, .notRequested)
        let exp = XCTestExpectation(description: #function)
        sut.searchRetailStores(location: searchResult.fulfilmentLocation.location)
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
        wait(for: [exp], timeout: 0.5)
        
    }
    
    func test_unsuccessfulSearch_whenNetworkErrorAndPreviousResult_nilAppSearchResultState() {
        
        let networkError = NSError(domain: NSURLErrorDomain, code: -1009, userInfo: [:])
        let searchResult = RetailStoresSearch.mockedData
        
        // Configuring app prexisting states
        appState.value.userData.searchResult = .loaded(searchResult)
        
        // Configuring expected actions on repositories

        mockedWebRepo.actions = .init(expected: [
            .loadRetailStores(location: searchResult.fulfilmentLocation.location)
        ])
        mockedDBRepo.actions = .init(expected: [
            .clearSearches
        ])

        // Configuring responses from repositories

        mockedWebRepo.loadRetailStoresByLocationResponse = .failure(networkError)
        mockedDBRepo.clearSearchesResult = .success(true)
        
        XCTAssertEqual(AppState().userData.searchResult, .notRequested)
        let exp = XCTestExpectation(description: #function)
        sut.searchRetailStores(location: searchResult.fulfilmentLocation.location)
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
        wait(for: [exp], timeout: 0.5)
        
    }
    
    func test_unsuccessfulSearch_whenUnableToSaveResult_nilAppSearchResultState() {
        
        let dbError = NSError(domain: "CoreData", code: -1009, userInfo: [:])
        let searchResult = RetailStoresSearch.mockedData
        
        // Configuring expected actions on repositories

        mockedWebRepo.actions = .init(expected: [
            .loadRetailStores(location: searchResult.fulfilmentLocation.location)
        ])
        mockedDBRepo.actions = .init(expected: [
            .clearSearches,
            .store(searchResult: searchResult, location: searchResult.fulfilmentLocation.location)
        ])

        // Configuring responses from repositories

        mockedWebRepo.loadRetailStoresByLocationResponse = .success(searchResult)
        mockedDBRepo.clearSearchesResult = .success(true)
        mockedDBRepo.storeByPostcode = .failure(dbError)
        
        XCTAssertEqual(AppState().userData.searchResult, .notRequested)
        let exp = XCTestExpectation(description: #function)
        sut.searchRetailStores(location: searchResult.fulfilmentLocation.location)
        delay {
            XCTAssertEqual(
                self.sut.appState.value.userData.searchResult.value,
                nil
            )
            self.mockedWebRepo.verify()
            self.mockedDBRepo.verify()
            exp.fulfill()
        }
        wait(for: [exp], timeout: 0.5)
        
    }

}

// MARK: - func repeatLastSearch()
final class RepeatLastSearchTests: RetailStoresServiceTests {
    
    func test_unsuccessfulSearch_whenNoStoredResult_nilAppSearchResultState() {
        
        // Configuring expected actions on repositories
        
        mockedDBRepo.actions = .init(expected: [
            .lastStoresSearch
        ])
        
        // Configuring responses from repositories

        mockedDBRepo.lastStoresSearchResult = .success(nil)
        
        XCTAssertEqual(AppState().userData.searchResult, .notRequested)
        let exp = XCTestExpectation(description: #function)
        sut
            .repeatLastSearch()
            .sinkToResult { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success:
                    XCTAssertNil(self.sut.appState.value.userData.searchResult.error, "Expected no error: \(String(describing: self.sut.appState.value.userData.searchResult.error))", file: #file, line: #line)
                    XCTAssertEqual(
                        self.sut.appState.value.userData.searchResult.value,
                        nil
                    )
                case let .failure(error):
                    XCTFail("Unexpected error: \(error)", file: #file, line: #line)
                }
                self.mockedWebRepo.verify()
                self.mockedDBRepo.verify()
                exp.fulfill()
            }
            .store(in: &subscriptions)
        wait(for: [exp], timeout: 0.5)
    }
    
    func test_successfulSearch_whenStoredResult_setAppSearchResultState() {
        
        let searchResult = RetailStoresSearch.mockedData
        
        // Configuring expected actions on repositories
        
        mockedWebRepo.actions = .init(expected: [
            .loadRetailStores(location: searchResult.fulfilmentLocation.location) // 2nd
        ])
        mockedDBRepo.actions = .init(expected: [
            .lastStoresSearch, // 1st
            .clearSearches, // 3rd
            .store(searchResult: searchResult, location: searchResult.fulfilmentLocation.location), // 4th
            .currentFulfilmentLocation // 5th
        ])
        
        // Configuring responses from repositories

        mockedDBRepo.lastStoresSearchResult = .success(searchResult)
        mockedWebRepo.loadRetailStoresByLocationResponse = .success(searchResult)
        mockedDBRepo.clearSearchesResult = .success(true)
        mockedDBRepo.storeByLocation = .success(searchResult)
        mockedDBRepo.currentFulfilmentLocationResult = .success(searchResult.fulfilmentLocation)
        
        XCTAssertEqual(AppState().userData.searchResult, .notRequested)
        let exp = XCTestExpectation(description: #function)
        sut
            .repeatLastSearch()
            .sinkToResult { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success:
                    XCTAssertNil(self.sut.appState.value.userData.searchResult.error, "Expected no error: \(String(describing: self.sut.appState.value.userData.searchResult.error))", file: #file, line: #line)
                    XCTAssertEqual(
                        self.sut.appState.value.userData.searchResult.value,
                        searchResult
                    )
                    XCTAssertEqual(
                        self.appState.value.userData.currentFulfilmentLocation,
                        searchResult.fulfilmentLocation
                    )
                case let .failure(error):
                    XCTFail("Unexpected error: \(error)", file: #file, line: #line)
                }
                self.mockedWebRepo.verify()
                self.mockedDBRepo.verify()
                exp.fulfill()
            }
            .store(in: &subscriptions)
        wait(for: [exp], timeout: 0.5)
    }
    
    func test_successfulSearch_whenStoredResultAndNetworkError_nilAppSearchResultState() {
        
        let networkError = NSError(domain: NSURLErrorDomain, code: -1009, userInfo: [:])
        let searchResult = RetailStoresSearch.mockedData
        
        // Configuring expected actions on repositories
        
        mockedWebRepo.actions = .init(expected: [
            .loadRetailStores(location: searchResult.fulfilmentLocation.location) // 2nd
        ])
        mockedDBRepo.actions = .init(expected: [
            .lastStoresSearch, // 1st
        ])
        
        // Configuring responses from repositories

        mockedDBRepo.lastStoresSearchResult = .success(searchResult)
        mockedWebRepo.loadRetailStoresByLocationResponse = .failure(networkError)
        
        XCTAssertEqual(AppState().userData.searchResult, .notRequested)
        let exp = XCTestExpectation(description: #function)
        sut
            .repeatLastSearch()
            .sinkToResult { [weak self] result in
                guard let self = self else { return }
                XCTAssertEqual(result.isSuccess, false, file: #file, line: #line)
                switch result {
                case .success:
                    break
                case let .failure(error):
                    XCTAssertEqual(error as NSError, networkError, file: #file, line: #line)
                }
                self.mockedWebRepo.verify()
                self.mockedDBRepo.verify()
                exp.fulfill()
            }
            .store(in: &subscriptions)
        wait(for: [exp], timeout: 0.5)
        
    }
}

// MARK: - func getStoreDetails(storeId:postcode:)
final class GetStoreDetailsTests: RetailStoresServiceTests {
    
    func test_successfulGetStoreDetails() {
        
        let storeDetails = RetailStoreDetails.mockedData
        
        // Configuring expected actions on repositories
        
        mockedWebRepo.actions = .init(expected: [
            .loadRetailStoreDetails(storeId: storeDetails.id, postcode: "DD1 3JA") // 2nd
        ])
        mockedDBRepo.actions = .init(expected: [
            .clearRetailStoreDetails, // 1st
            .store(storeDetails: storeDetails, forPostode: "DD1 3JA") // 3rd
        ])
        
        // Configuring responses from repositories

        mockedDBRepo.clearRetailStoreDetailsResult = .success(true)
        mockedDBRepo.storeDetailsByPostcode = .success(storeDetails)
        mockedWebRepo.loadRetailStoreDetailsResponse = .success(storeDetails)
        
        XCTAssertEqual(AppState().userData.selectedStore, .notRequested)
        let exp = XCTestExpectation(description: #function)
        sut.getStoreDetails(storeId: storeDetails.id, postcode: "DD1 3JA")
        delay {
            XCTAssertEqual(
                self.sut.appState.value.userData.selectedStore.value,
                storeDetails
            )
            self.mockedWebRepo.verify()
            self.mockedDBRepo.verify()
            exp.fulfill()
        }
        wait(for: [exp], timeout: 0.5)
    }
    
    func test_unsuccessfulGetStoreDetails_whenNetworkError() {
        
        let networkError = NSError(domain: NSURLErrorDomain, code: -1009, userInfo: [:])
        let storeDetails = RetailStoreDetails.mockedData
        
        // Configuring expected actions on repositories
        
        mockedWebRepo.actions = .init(expected: [
            .loadRetailStoreDetails(storeId: storeDetails.id, postcode: "DD1 3JA") // 2nd
        ])
        mockedDBRepo.actions = .init(expected: [
            .clearRetailStoreDetails, // 1st
        ])
        
        // Configuring responses from repositories

        mockedDBRepo.clearRetailStoreDetailsResult = .success(true)
        mockedWebRepo.loadRetailStoreDetailsResponse = .failure(networkError)
        
        XCTAssertEqual(AppState().userData.selectedStore, .notRequested)
        let exp = XCTestExpectation(description: #function)
        sut.getStoreDetails(storeId: storeDetails.id, postcode: "DD1 3JA")
        delay {
            if let error = self.sut.appState.value.userData.selectedStore.error {
                XCTAssertEqual(
                    error as NSError,
                    networkError
                )
            } else {
                XCTFail("Unexpected error: \(String(describing: self.sut.appState.value.userData.selectedStore.error))", file: #file, line: #line)
            }
            XCTAssertEqual(
                self.sut.appState.value.userData.selectedStore.value,
                nil
            )
            self.mockedWebRepo.verify()
            self.mockedDBRepo.verify()
            exp.fulfill()
        }
        wait(for: [exp], timeout: 0.5)
    }
}

// MARK: - func getStoreDeliveryTimeSlots(slots:storeId:startDate:endDate:location:)
final class GetStoreDeliveryTimeSlotsTests: RetailStoresServiceTests {
    
}

// MARK: - func getStoreCollectionTimeSlots(slots:storeId:startDate:endDate:)
final class GetStoreCollectionTimeSlotsTests: RetailStoresServiceTests {
    
}

extension RetailStoresSearch: PrefixRemovable { }
