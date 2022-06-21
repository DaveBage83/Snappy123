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
    func test_clearBasket() async throws {
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
        
        try await self.mockedStore.preloadData { context in
            basket.store(in: context)
        }

        do {
            try await sut.clearBasket()
        } catch {
            XCTFail("Unexpected error: \(error)", file: #file, line: #line)
        }
        mockedStore.verify()
    }
    
}
