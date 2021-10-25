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
        
//        let details = Country.Details.test
//        let intermediate = Country.Details.Intermediate(
//            capital: details.capital, currencies: details.currencies,
//            borders: details.neighbors.map { $0.alpha3Code })
//        let parentCountry = Country.testLocalized[2]
//        mockedStore.actions = .init(expected: [
//            .update(.init(inserted: 1 + details.currencies.count, // self + currencies
//                          updated: details.neighbors.count + 1, // neighbors + parent
//                          deleted: 0))
//        ])
//        try mockedStore.preloadData { context in
//            parentCountry.store(in: context)
//            details.neighbors.forEach { $0.store(in: context) }
//        }
//        let exp = XCTestExpectation(description: #function)
//        sut.store(countryDetails: intermediate, for: parentCountry)
//            .sinkToResult { result in
//                result.assertSuccess(value: details)
//                self.mockedStore.verify()
//                exp.fulfill()
//            }
//            .store(in: cancelBag)
//        wait(for: [exp], timeout: 0.5)
    }
    
}
