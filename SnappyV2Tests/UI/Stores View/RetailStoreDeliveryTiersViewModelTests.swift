//
//  RetailStoreDeliveryTiersViewModelTests.swift
//  SnappyV2Tests
//
//  Created by David Bage on 18/10/2022.
//

import XCTest
@testable import SnappyV2

class RetailStoreDeliveryTiersViewModelTests: XCTestCase {
    typealias CustomTiersString = Strings.StoresView.DeliveryTiersCustom
    
    func test_whenMinSpendIsNotNilAndMinSpendIsGreaterThan0_thenReturnNil() {
        let sut = makeSUT(deliveryOrderMethod: .init(name: .delivery, earliestTime: nil, status: .open, cost: nil, fulfilmentIn: nil, freeFulfilmentMessage: nil, deliveryTiers: [.init(minBasketSpend: 0, deliveryFee: 1)], freeFrom: nil, minSpend: 0, earliestOpeningDate: nil))
        XCTAssertNil(sut.minSpend)
    }
    
    func test_whenMinSpendIsNotNilAndMinSpendIsNotGreaterThan0_givenCurrencyIsNotNil_thenReturnCorrectString() {
        let sut = makeSUT(deliveryOrderMethod: .init(name: .delivery, earliestTime: nil, status: .open, cost: nil, fulfilmentIn: nil, freeFulfilmentMessage: nil, deliveryTiers: [.init(minBasketSpend: 10, deliveryFee: 1)], freeFrom: nil, minSpend: 10, earliestOpeningDate: nil))
        
        guard let currency = sut.currency else {
            XCTFail("Currency should be present")
            return
        }
        
        let expectedSpend = sut.deliveryOrderMethod?.minSpend?.toCurrencyString(using: currency)
        
        XCTAssertEqual(sut.minSpend, CustomTiersString.minSpend.localizedFormat(expectedSpend!))
    }
    
    func test_whenDeliveryTiersOnOrderMethodIsNil_thenDeliveryTiersIsNil() {
        let sut = makeSUT(deliveryOrderMethod: .init(name: .delivery, earliestTime: nil, status: .open, cost: nil, fulfilmentIn: nil, freeFulfilmentMessage: nil, deliveryTiers: nil, freeFrom: nil, minSpend: 10, earliestOpeningDate: nil))
        
        XCTAssertNil(sut.deliveryTiers)
    }
    
    func test_whenDeliveryTiersIsNotNil_givenTiersAreEmpty_thenDeliveryTiersIsNil() {
        let sut = makeSUT(deliveryOrderMethod: .init(name: .delivery, earliestTime: nil, status: .open, cost: nil, fulfilmentIn: nil, freeFulfilmentMessage: nil, deliveryTiers: [], freeFrom: nil, minSpend: 10, earliestOpeningDate: nil))
        
        XCTAssertNil(sut.deliveryTiers)
    }
    
    func test_whenDeliveryTiersvIsNotNil_givenMinSpendPresentAndDefaultDeliveryCostPresentAndLowestThresholdNotEqualToMinSpend_thenInsertNewDeliveryTierFrom0() {
        
        let tiers: [DeliveryTier] = [
            .init(minBasketSpend: 10, deliveryFee: 3),
            .init(minBasketSpend: 20, deliveryFee: 2),
            .init(minBasketSpend: 30, deliveryFee: 1)
        ]
        
        let sut = makeSUT(deliveryOrderMethod: .init(name: .delivery, earliestTime: nil, status: .open, cost: 5, fulfilmentIn: nil, freeFulfilmentMessage: nil, deliveryTiers: tiers, freeFrom: nil, minSpend: 5, earliestOpeningDate: nil))
        
        let expectedAdditionalTier = DeliveryTier(minBasketSpend: 5, deliveryFee:5)
        
        let expectedFinalTiers: DeliveryTiers = .init(minSpend: 5, deliveryTiers: [
            .init(minBasketSpend: 5, deliveryFee: 5),
            .init(minBasketSpend: 10, deliveryFee: 3),
            .init(minBasketSpend: 20, deliveryFee: 2),
            .init(minBasketSpend: 30, deliveryFee: 1)
        ])
        
        XCTAssertEqual(sut.deliveryTiers, expectedFinalTiers)
    }
    
    func test_whenDeliveryTiersvIsNotNil_givenNoMinSpendPresentAndDefaultDeliveryCostPresentAndLowestThresholdGreaterThan0_thenInsertNewDeliveryTierFrom0() {
        
        let tiers: [DeliveryTier] = [
            .init(minBasketSpend: 10, deliveryFee: 3),
            .init(minBasketSpend: 20, deliveryFee: 2),
            .init(minBasketSpend: 30, deliveryFee: 1)
        ]
        
        let sut = makeSUT(deliveryOrderMethod: .init(name: .delivery, earliestTime: nil, status: .open, cost: 5, fulfilmentIn: nil, freeFulfilmentMessage: nil, deliveryTiers: tiers, freeFrom: nil, minSpend: nil, earliestOpeningDate: nil))
        
        let expectedAdditionalTier = DeliveryTier(minBasketSpend: 5, deliveryFee:5)
        
        let expectedFinalTiers: DeliveryTiers = .init(minSpend: nil, deliveryTiers: [
            .init(minBasketSpend: 0, deliveryFee: 5),
            .init(minBasketSpend: 10, deliveryFee: 3),
            .init(minBasketSpend: 20, deliveryFee: 2),
            .init(minBasketSpend: 30, deliveryFee: 1)
        ])
        
        XCTAssertEqual(sut.deliveryTiers, expectedFinalTiers)
    }
    
    func test_whenMinSpendPresent_thenMindSpendPopulated() {
        let sut = makeSUT(deliveryOrderMethod: .init(name: .delivery, earliestTime: nil, status: .open, cost: 5, fulfilmentIn: nil, freeFulfilmentMessage: nil, deliveryTiers: nil, freeFrom: nil, minSpend: 5, earliestOpeningDate: nil))
        XCTAssertEqual(sut.minSpendValue, 5)
    }
    
    func test_whenMinSpendPresent_thenMindSpendNil() {
        let sut = makeSUT(deliveryOrderMethod: .init(name: .delivery, earliestTime: nil, status: .open, cost: 5, fulfilmentIn: nil, freeFulfilmentMessage: nil, deliveryTiers: nil, freeFrom: nil, minSpend: nil, earliestOpeningDate: nil))
        XCTAssertNil(sut.minSpendValue)
    }
    
    func test_whenMinSpendIsNotNilAndMinSpendIsNotGreaterThan0_givenCurrencyIsNil_thenReturnCorrectString() {
        let sut = makeSUT(deliveryOrderMethod: .init(name: .delivery, earliestTime: nil, status: .open, cost: nil, fulfilmentIn: nil, freeFulfilmentMessage: nil, deliveryTiers: [.init(minBasketSpend: 10, deliveryFee: 1)], freeFrom: nil, minSpend: 10, earliestOpeningDate: nil), currency: nil)

        let expectedSpend = sut.deliveryOrderMethod?.minSpend?.toCurrencyString(using: .init(currencyCode: "GBP", symbol: "£", ratio: 1, symbolChar: "£", name: "Great British Pount"))
        
        XCTAssertEqual(sut.minSpend, CustomTiersString.minSpend.localizedFormat(expectedSpend!))
    }
    
    func test_whenCostPresent_thenDefaultDeliveryCostPopulated() {
        let sut = makeSUT(deliveryOrderMethod: .init(name: .delivery, earliestTime: nil, status: .open, cost: 5, fulfilmentIn: nil, freeFulfilmentMessage: nil, deliveryTiers: [.init(minBasketSpend: 10, deliveryFee: 1)], freeFrom: nil, minSpend: 10, earliestOpeningDate: nil), currency: nil)
        XCTAssertEqual(sut.defaultDeliveryCost, 5)
    }
    
    func test_whenCostNil_thenDefaultDeliveryCostNil() {
        let sut = makeSUT(deliveryOrderMethod: .init(name: .delivery, earliestTime: nil, status: .open, cost: nil, fulfilmentIn: nil, freeFulfilmentMessage: nil, deliveryTiers: [.init(minBasketSpend: 10, deliveryFee: 1)], freeFrom: nil, minSpend: 10, earliestOpeningDate: nil), currency: nil)
        XCTAssertNil(sut.defaultDeliveryCost)
    }
    
    func test_whenDeliveryOrderMethodNil_givenDefaultCostIsPresent_thenDefaultDeliveryCostNil() {
        let sut = makeSUT(deliveryOrderMethod: nil, currency: nil)
        XCTAssertNil(sut.defaultDeliveryCost)
    }
    
    func makeSUT(container: DIContainer = DIContainer(appState: AppState(), eventLogger: MockedEventLogger(), services: .mocked()), deliveryOrderMethod: RetailStoreOrderMethod?, currency: RetailStoreCurrency? = .init(currencyCode: "GBP", symbol: "£", ratio: 1, symbolChar: "£", name: "Great British Pount")) -> RetailStoreDeliveryTiersViewModel {
        let sut = RetailStoreDeliveryTiersViewModel(container: container, deliveryOrderMethod: deliveryOrderMethod, currency: currency)
        
        trackForMemoryLeaks(sut)
        
        return sut
    }
}
