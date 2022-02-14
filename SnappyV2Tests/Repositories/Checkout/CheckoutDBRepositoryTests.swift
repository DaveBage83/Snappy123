//
//  CheckoutDBRepositoryTests.swift
//  SnappyV2Tests
//
//  Created by Kevin Palser on 06/02/2022.
//

import XCTest
import Combine
@testable import SnappyV2

class CheckoutDBRepositoryTests: XCTestCase {
    
    var mockedStore: MockedPersistentStore!
    var sut: CheckoutDBRepository!
    var cancelBag = CancelBag()
    
    override func setUp() {
        mockedStore = MockedPersistentStore()
        sut = CheckoutDBRepository(persistentStore: mockedStore)
        mockedStore.verify()
    }
    
    override func tearDown() {
        cancelBag = CancelBag()
        sut = nil
        mockedStore = nil
    }
    
}

// MARK: - Methods in CheckoutDBRepositoryProtocol

final class CheckoutDBRepositoryProtocolTests: CheckoutDBRepositoryTests {
    
    // MARK: - clearBasket()
    
    func test_clearBasket() throws {
        let basket = Basket.mockedData
        
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
            basket.store(in: context)
        }
        
        let exp = XCTestExpectation(description: #function)
        sut.clearBasket()
            .sinkToResult { result in
                result.assertSuccess(value: true)
                self.mockedStore.verify()
                exp.fulfill()
            }
            .store(in: cancelBag)
        wait(for: [exp], timeout: 0.5)
    }
    
}
