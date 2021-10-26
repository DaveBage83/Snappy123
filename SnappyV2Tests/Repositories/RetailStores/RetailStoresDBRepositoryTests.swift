//
//  RetailStoresDBRepositoryTests.swift
//  SnappyV2Tests
//
//  Created by Kevin Palser on 16/10/2021.
//

import XCTest
import Combine
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
    
    func test_storeSearchResult_forpostcode() throws {
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
    
}
