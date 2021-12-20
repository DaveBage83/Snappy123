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
func searchRetailStores(search: LoadableSubject<RetailStoresSearch>, postcode: String)
func searchRetailStores(search: LoadableSubject<RetailStoresSearch>, location: CLLocationCoordinate2D)
func repeatLastSearch(search: LoadableSubject<RetailStoresSearch>)
func getStoreDetails(details: LoadableSubject<RetailStoreDetails>, storeId: Int, postcode: String)
func getStoreDeliveryTimeSlots(slots: LoadableSubject<RetailStoreTimeSlots>, storeId: Int, startDate: Date, endDate: Date, location: CLLocationCoordinate2D)
func getStoreCollectionTimeSlots(slots: LoadableSubject<RetailStoreTimeSlots>, storeId: Int, startDate: Date, endDate: Date)
*/

// MARK: - func searchRetailStores(search:postcode:)
final class SearchRetailStoresByPostcodeTests: RetailStoresServiceTests {
    
    func test_successfulSearch() {
        
//        let searchResult = RetailStoresSearch.mockedData
//
//        // Configuring expected actions on repositories
//
//        mockedWebRepo.actions = .init(expected: [
//            .loadRetailStores(postcode: searchResult.fulfilmentLocation.postcode)
//        ])
//        mockedDBRepo.actions = .init(expected: [
//            .clearSearches,
//            .store(searchResult: searchResult, forPostode: "DD1 3JA")
//        ])
//
//        // Configuring responses from repositories
//
//        mockedWebRepo.loadRetailStoresByPostcodeResponse = .success(searchResult)
//        mockedDBRepo.clearSearchesResult = .success(true)
//        mockedDBRepo.storeByLocation = .success(searchResult)
//        mockedDBRepo.fetchRetailStoresSearchByPostcodeResult = .success(searchResult)
//
//        let search = BindingWithPublisher(value: Loadable<RetailStoresSearch>.notRequested)
//        sut.searchRetailStores(postcode: searchResult.fulfilmentLocation.postcode)
//        let exp = XCTestExpectation(description: #function)
//        search.updatesRecorder.sink { updates in
//            XCTAssertEqual(updates, [
//                .notRequested,
//                .isLoading(last: nil, cancelBag: CancelBag()),
//                .loaded(searchResult)
//            ], removing: RetailStoresSearch.prefixes)
//            self.mockedWebRepo.verify()
//            self.mockedDBRepo.verify()
//            exp.fulfill()
//        }.store(in: &subscriptions)
//        wait(for: [exp], timeout: 2)
        
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
        mockedDBRepo.storeByLocation = .success(searchResult)
        mockedDBRepo.fetchRetailStoresSearchByPostcodeResult = .success(searchResult)
        
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
    
    
    func test_filledDB_successfulSearch() {
        
    }
    
    func test_filledDB_failedSearch() {
        
    }
    
    func test_emptyDB_failedRequest() {
        
    }
    
    func test_emptyDB_successfulRequest_successfulStoring() {
        
    }
    
    func test_emptyDB_successfulRequest_failedStoring() {
        
    }
    
    //func searchRetailStores(search: LoadableSubject<RetailStoresSearch>, location: CLLocationCoordinate2D)
    
}

// MARK: - func searchRetailStores(search: location:)
final class SearchRetailStoresByLocationTests: RetailStoresServiceTests {
    
    func test_filledDB_successfulSearch() {

    }
    
    func test_filledDB_failedSearch() {
        
    }
    
    func test_emptyDB_failedRequest() {
        
    }
    
    func test_emptyDB_successfulRequest_successfulStoring() {
        
    }
    
    func test_emptyDB_successfulRequest_failedStoring() {
        
    }

}

// MARK: - func clearLastSearch()
final class ClearLastRetailStoresSearchTests: RetailStoresServiceTests {
    
}


extension RetailStoresSearch: PrefixRemovable { }
