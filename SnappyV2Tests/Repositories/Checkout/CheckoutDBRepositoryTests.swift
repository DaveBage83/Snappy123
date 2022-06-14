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
    func test_clearBasket() async {
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
        
        do {
            try await self.mockedStore.preloadData { context in
                basket.store(in: context)
            }
            try await sut.clearBasket()
        } catch {
            XCTFail("Unexpected error: \(error)", file: #file, line: #line)
        }
        mockedStore.verify()
    }
    
    // MARK: - clearLastDeliveryOrderOnDevice()
    func test_clearLastDeliveryOrderOnDevice() async {
        let lastDeliveryOrder = LastDeliveryOrderOnDevice.mockedData
        
        mockedStore.actions = .init(expected: [
            .update(
                .init(
                    inserted: 0,
                    updated: 0,
                    deleted: 1
                )
            )
        ])
        
        do {
            try await self.mockedStore.preloadData { context in
                lastDeliveryOrder.store(in: context)
            }
            try await sut.clearLastDeliveryOrderOnDevice()
        } catch {
            XCTFail("Unexpected error: \(error)", file: #file, line: #line)
        }
        mockedStore.verify()
    }
    
    // MARK: - store(lastDeliveryOrderOnDevice:)
    func test_storeLastDeliveryOrderOnDevice() async {
        let lastDeliveryOrder = LastDeliveryOrderOnDevice.mockedData
        
        mockedStore.actions = .init(expected: [
            .update(
                .init(
                    inserted: 1,
                    updated: 0,
                    deleted: 0
                )
            )
        ])
        
        do {
            try await sut.store(lastDeliveryOrderOnDevice: lastDeliveryOrder)
        } catch {
            XCTFail("Unexpected error: \(error)", file: #file, line: #line)
        }
        mockedStore.verify()
    }
    
    // MARK: - lastDeliveryOrderOnDevice()
    func test_lastDeliveryOrderOnDevice_whenNotSaved() async {
        
        mockedStore.actions = .init(expected: [
            .fetch(String(describing: LastDeliveryOrderOnDeviceMO.self), .init(
                    inserted: 0,
                    updated: 0,
                    deleted: 0
                )
            )
        ])
        
        do {
            let result = try await sut.lastDeliveryOrderOnDevice()
            XCTAssertNil(result, file: #file, line: #line)
        } catch {
            XCTFail("Unexpected error: \(error)", file: #file, line: #line)
        }
        mockedStore.verify()
    }
    
    // MARK: - lastDeliveryOrderOnDevice()
    func test_lastDeliveryOrderOnDevice_whenSaved() async {
        let lastDeliveryOrder = LastDeliveryOrderOnDevice.mockedData
        
        mockedStore.actions = .init(expected: [
            .fetch(String(describing: LastDeliveryOrderOnDeviceMO.self), .init(
                    inserted: 0,
                    updated: 0,
                    deleted: 0
                )
            )
        ])
        
        do {
            try await self.mockedStore.preloadData { context in
                lastDeliveryOrder.store(in: context)
            }
            let result = try await sut.lastDeliveryOrderOnDevice()
            XCTAssertEqual(result, lastDeliveryOrder, file: #file, line: #line)
        } catch {
            XCTFail("Unexpected error: \(error)", file: #file, line: #line)
        }
        mockedStore.verify()
    }
    
}
