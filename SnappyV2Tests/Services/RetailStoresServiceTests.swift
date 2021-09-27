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

    var mockedWebRepo: MockedRetailStoresWebRepository!
    var mockedDBRepo: MockedRetailStoresDBRepository!
    var subscriptions = Set<AnyCancellable>()
    var sut: RetailStoresService!

    override func setUp() {
        mockedWebRepo = MockedRetailStoresWebRepository()
        mockedDBRepo = MockedRetailStoresDBRepository()
        sut = RetailStoresService(
            webRepository: mockedWebRepo,
            dbRepository: mockedDBRepo
        )
    }

    override func tearDown() {
        subscriptions = Set<AnyCancellable>()
    }
}

// MARK: - func searchRetailStores(search: postcode:)
final class SearchRetailStoresByPostcodeTests: RetailStoresServiceTests {
    
    func test_filledDB_successfulSearch() {
        
        let searchResult = RetailStoresSearch.mockedData
        
        // Configuring expected actions on repositories
        
        mockedWebRepo.actions = .init(expected: [
        ])
        mockedDBRepo.actions = .init(expected: [
            .retailStoresSearch(forPostcode: "DD1 3JA"),
            //.store(searchResult: searchResult, forPostode: "DD1 3JA")
        ])
        
        // Configuring responses from repositories
    
        mockedDBRepo.fetchRetailStoresSearchByPostcodeResult = .success(searchResult)
        
        let search = BindingWithPublisher(value: Loadable<RetailStoresSearch>.notRequested)
        sut.searchRetailStores(search: search.binding, postcode: "DD1 3JA")
        let exp = XCTestExpectation(description: #function)
        search.updatesRecorder.sink { updates in
            XCTAssertEqual(updates, [
                .notRequested,
                .isLoading(last: nil, cancelBag: CancelBag()),
                .loaded(searchResult)
            ], removing: RetailStoresSearch.prefixes)
            self.mockedWebRepo.verify()
            self.mockedDBRepo.verify()
            exp.fulfill()
        }.store(in: &subscriptions)
        wait(for: [exp], timeout: 2)
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
