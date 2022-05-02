//
//  BasketDBRepositoryTests.swift
//  SnappyV2Tests
//
//  Created by Kevin Palser on 30/01/2022.
//

import XCTest
import Combine
@testable import SnappyV2

class BasketDBRepositoryTests: XCTestCase {
    
    var mockedStore: MockedPersistentStore!
    var sut: BasketDBRepository!
    var cancelBag = CancelBag()
    
    override func setUp() {
        mockedStore = MockedPersistentStore()
        sut = BasketDBRepository(persistentStore: mockedStore)
        mockedStore.verify()
    }
    
    override func tearDown() {
        cancelBag = CancelBag()
        sut = nil
        mockedStore = nil
    }
    
}

// MARK: - Methods in BasketDBRepositoryProtocol

final class BasketDBRepositoryProtocolTests: BasketDBRepositoryTests {
    
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
        wait(for: [exp], timeout: 2)
    }
    
    // MARK: - store(basket:)
    
    func test_store_basketGiven_storeAndReturnWithBasket() throws {
        let basket = Basket.mockedData
        
        mockedStore.actions = .init(expected: [
            .update(.init(
                    inserted: basket.recordsCount,
                    updated: 0,
                    deleted: 0
                )
            )
        ])
        
        let exp = XCTestExpectation(description: #function)
        sut.store(basket: basket)
            .sinkToResult { result in
                result.assertSuccess(value: basket)
                self.mockedStore.verify()
                exp.fulfill()
            }
            .store(in: cancelBag)
        wait(for: [exp], timeout: 2)
    }
    
    // MARK: - fetchBasket()
    
    func test_fetchBasket_basketStored_returnWithBasket() throws {
        let basket = Basket.mockedData
        
        mockedStore.actions = .init(expected: [
            .fetch(String(describing: BasketMO.self), .init(
                    inserted: 0,
                    updated: 0,
                    deleted: 0
                )
            )
        ])
        
        try mockedStore.preloadData { context in
            basket.store(in: context)
        }
        
        let exp = XCTestExpectation(description: #function)
        sut.fetchBasket()
            .sinkToResult { result in
                result.assertSuccess(value: basket)
                self.mockedStore.verify()
                exp.fulfill()
            }
            .store(in: cancelBag)
        wait(for: [exp], timeout: 2)
    }
    
    func test_fetchBasket_nobasketStored_returnWithoutBasket() throws {

        mockedStore.actions = .init(expected: [
            .fetch(String(describing: BasketMO.self), .init(
                    inserted: 0,
                    updated: 0,
                    deleted: 0
                )
            )
        ])
        
        let exp = XCTestExpectation(description: #function)
        sut.fetchBasket()
            .sinkToResult { result in
                result.assertSuccess(value: nil)
                self.mockedStore.verify()
                exp.fulfill()
            }
            .store(in: cancelBag)
        wait(for: [exp], timeout: 2)
    }
    
}
