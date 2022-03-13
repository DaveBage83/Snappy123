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
    
}

// MARK: - func getStoreDetails(storeId:postcode:)
final class GetStoreDetailsTests: RetailStoresServiceTests {
    
}

// MARK: - func getStoreDeliveryTimeSlots(slots:storeId:startDate:endDate:location:)
final class GetStoreDeliveryTimeSlotsTests: RetailStoresServiceTests {
    
}

// MARK: - func getStoreCollectionTimeSlots(slots:storeId:startDate:endDate:)
final class GetStoreCollectionTimeSlotsTests: RetailStoresServiceTests {
    
}

extension RetailStoresSearch: PrefixRemovable { }
