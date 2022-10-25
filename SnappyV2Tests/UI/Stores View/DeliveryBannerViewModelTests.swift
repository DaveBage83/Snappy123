//
//  DeliveryBannerViewModelTests.swift
//  SnappyV2Tests
//
//  Created by David Bage on 19/10/2022.
//

import XCTest
@testable import SnappyV2

class DeliveryBannerViewModelTests: XCTestCase {
    func test_whenFromBasket_givenHasTiersTrue_thenBannerTypeIsDeliveryOfferWithTiers() {
        let tiers: [DeliveryTier] = [
            .init(minBasketSpend: 10, deliveryFee: 2),
            .init(minBasketSpend: 20, deliveryFee: 1)
        ]
        
        let orderMethod = RetailStoreOrderMethod(name: .delivery, earliestTime: nil, status: .open, cost: 1, fulfilmentIn: nil, freeFulfilmentMessage: nil, deliveryTiers: tiers, freeFrom: 10, minSpend: 0)
        
        let deliveryTierInfo = DeliveryTierInfo(orderMethod: orderMethod, currency: nil)
        
        let sut = makeSUT(deliveryTierInfo: deliveryTierInfo, fromBasket: true)
        
        XCTAssertEqual(sut.bannerType, .deliveryOfferWithTiers)
    }
    
    func test_whenFromBasket_givenHasTiersFalse_thenBannerTypeIsDeliveryOfferWithTiers() {
        
        let orderMethod = RetailStoreOrderMethod(name: .delivery, earliestTime: nil, status: .open, cost: 1, fulfilmentIn: nil, freeFulfilmentMessage: nil, deliveryTiers: nil, freeFrom: 10, minSpend: 0)
        
        let deliveryTierInfo = DeliveryTierInfo(orderMethod: orderMethod, currency: nil)
        
        let sut = makeSUT(deliveryTierInfo: deliveryTierInfo, fromBasket: true)
        
        XCTAssertEqual(sut.bannerType, .deliveryOffer)
    }
    
    func test_whenFromBasketFalse_givenHasTiersTrue_thenBannerTypeIsDeliveryOfferWithTiers() {
        let tiers: [DeliveryTier] = [
            .init(minBasketSpend: 10, deliveryFee: 2),
            .init(minBasketSpend: 20, deliveryFee: 1)
        ]
        
        let orderMethod = RetailStoreOrderMethod(name: .delivery, earliestTime: nil, status: .open, cost: 1, fulfilmentIn: nil, freeFulfilmentMessage: nil, deliveryTiers: tiers, freeFrom: 10, minSpend: 0)
        
        let deliveryTierInfo = DeliveryTierInfo(orderMethod: orderMethod, currency: nil)
        
        let sut = makeSUT(deliveryTierInfo: deliveryTierInfo, fromBasket: false)
        
        XCTAssertEqual(sut.bannerType, .deliveryOfferWithTiersMain)
    }
    
    func test_whenFromBasketFalse_givenHasTiersFalse_thenBannerTypeIsDeliveryOfferWithTiers() {
        
        let orderMethod = RetailStoreOrderMethod(name: .delivery, earliestTime: nil, status: .open, cost: 1, fulfilmentIn: nil, freeFulfilmentMessage: nil, deliveryTiers: nil, freeFrom: 10, minSpend: 0)
        
        let deliveryTierInfo = DeliveryTierInfo(orderMethod: orderMethod, currency: nil)
        
        let sut = makeSUT(deliveryTierInfo: deliveryTierInfo, fromBasket: false)
        
        XCTAssertEqual(sut.bannerType, .deliveryOfferMain)
    }
    
    func test_whenFreeFulfilmentMessagePresentAndNotEmpty_returnMessage() {
        
        let orderMethod = RetailStoreOrderMethod(name: .delivery, earliestTime: nil, status: .open, cost: 1, fulfilmentIn: nil, freeFulfilmentMessage: "test", deliveryTiers: nil, freeFrom: 10, minSpend: 0)
        
        let deliveryTierInfo = DeliveryTierInfo(orderMethod: orderMethod, currency: nil)
        
        let sut = makeSUT(deliveryTierInfo: deliveryTierInfo, fromBasket: false)
        
        XCTAssertEqual(sut.freeFulfilmentMessage, "test")
    }
    
    func test_whenFreeFulfilmentMessageNil_freeFulfilmentMessageNil() {
        
        let orderMethod = RetailStoreOrderMethod(name: .delivery, earliestTime: nil, status: .open, cost: 1, fulfilmentIn: nil, freeFulfilmentMessage: nil, deliveryTiers: nil, freeFrom: 10, minSpend: 0)
        
        let deliveryTierInfo = DeliveryTierInfo(orderMethod: orderMethod, currency: nil)
        
        let sut = makeSUT(deliveryTierInfo: deliveryTierInfo, fromBasket: false)
        
        XCTAssertNil(sut.freeFulfilmentMessage)
        XCTAssertFalse(sut.showDeliveryBanner)
    }
    
    func test_whenFreeFulfilmentMessageEmpty_freeFulfilmentMessageNil() {
        
        let orderMethod = RetailStoreOrderMethod(name: .delivery, earliestTime: nil, status: .open, cost: 1, fulfilmentIn: nil, freeFulfilmentMessage: "", deliveryTiers: nil, freeFrom: 10, minSpend: 0)
        
        let deliveryTierInfo = DeliveryTierInfo(orderMethod: orderMethod, currency: nil)
        
        let sut = makeSUT(deliveryTierInfo: deliveryTierInfo, fromBasket: false)
        
        XCTAssertNil(sut.freeFulfilmentMessage)
        XCTAssertFalse(sut.showDeliveryBanner)
    }
    
    func test_whenFreeFromNil_thenSetFreeFromToNil() {
        
        let orderMethod = RetailStoreOrderMethod(name: .delivery, earliestTime: nil, status: .open, cost: 1, fulfilmentIn: nil, freeFulfilmentMessage: "", deliveryTiers: nil, freeFrom: nil, minSpend: 0)
        
        let deliveryTierInfo = DeliveryTierInfo(orderMethod: orderMethod, currency: nil)
        
        let sut = makeSUT(deliveryTierInfo: deliveryTierInfo, fromBasket: false)
        
        XCTAssertNil(sut.freeFrom)
    }
    
    func test_whenFreeFrom0_thenSetFreeFromToNil() {
        
        let orderMethod = RetailStoreOrderMethod(name: .delivery, earliestTime: nil, status: .open, cost: 1, fulfilmentIn: nil, freeFulfilmentMessage: "", deliveryTiers: nil, freeFrom: 0, minSpend: 0)
        
        let deliveryTierInfo = DeliveryTierInfo(orderMethod: orderMethod, currency: nil)
        
        let sut = makeSUT(deliveryTierInfo: deliveryTierInfo, fromBasket: false)
        
        XCTAssertNil(sut.freeFrom)
    }
    
    func test_whenFreeFromGreaterThan0_thenSetFreeFrom() {
        
        let orderMethod = RetailStoreOrderMethod(name: .delivery, earliestTime: nil, status: .open, cost: 1, fulfilmentIn: nil, freeFulfilmentMessage: "", deliveryTiers: nil, freeFrom: 10, minSpend: 0)
        
        let deliveryTierInfo = DeliveryTierInfo(orderMethod: orderMethod, currency: nil)
        
        let sut = makeSUT(deliveryTierInfo: deliveryTierInfo, fromBasket: false)
        
        XCTAssertEqual(sut.freeFrom, 10)
    }
    
    func test_whenCurrencyNil_thenDeliveryBannerTextIsNil() {
        
        let orderMethod = RetailStoreOrderMethod(name: .delivery, earliestTime: nil, status: .open, cost: 1, fulfilmentIn: nil, freeFulfilmentMessage: "", deliveryTiers: nil, freeFrom: 10, minSpend: 0)
        
        let deliveryTierInfo = DeliveryTierInfo(orderMethod: orderMethod, currency: nil)
        
        let sut = makeSUT(deliveryTierInfo: deliveryTierInfo, fromBasket: false)
        
        XCTAssertNil(sut.deliveryBannerText)
        XCTAssertFalse(sut.showDeliveryBanner)
    }
    
    func test_whenCurrencyNotNilAndDeliveryBannerTextNotNilAndNotEmpty_thenSetDeliveryBannerText() {
        
        let currency = RetailStoreCurrency(currencyCode: "GBP", symbol: "£", ratio: 1, symbolChar: "£", name: "GBP")
        
        let orderMethod = RetailStoreOrderMethod(name: .delivery, earliestTime: nil, status: .open, cost: 1, fulfilmentIn: nil, freeFulfilmentMessage: "Test Delivery Offer", deliveryTiers: nil, freeFrom: 10, minSpend: 0)
        
        let deliveryTierInfo = DeliveryTierInfo(orderMethod: orderMethod, currency: currency)
        
        let sut = makeSUT(deliveryTierInfo: deliveryTierInfo, fromBasket: false)
        
        XCTAssertEqual(sut.deliveryBannerText, "Test Delivery Offer")
        XCTAssertTrue(sut.showDeliveryBanner)
    }
    
    func test_whenCurrencyNotNilAndDeliveryBannerTextNil_givenFreeFromPresentAndDeliveryTiersNil_thenSetDeliveryBannerText() {
        
        let currency = RetailStoreCurrency(currencyCode: "GBP", symbol: "£", ratio: 1, symbolChar: "£", name: "GBP")
        
        let freeFromCost: Double = 10
        
        let orderMethod = RetailStoreOrderMethod(name: .delivery, earliestTime: nil, status: .open, cost: 1, fulfilmentIn: nil, freeFulfilmentMessage: nil, deliveryTiers: nil, freeFrom: freeFromCost, minSpend: 0)
        
        let freeFromText = Strings.StoresView.DeliveryTiersCustom.freeFrom.localizedFormat(freeFromCost.toCurrencyString(using: currency))
        
        let deliveryTierInfo = DeliveryTierInfo(orderMethod: orderMethod, currency: currency)
        
        let sut = makeSUT(deliveryTierInfo: deliveryTierInfo, fromBasket: false)
        
        XCTAssertEqual(sut.deliveryBannerText, freeFromText)
        XCTAssertTrue(sut.showDeliveryBanner)
    }
    
    func test_whenCurrencyNotNilAndDeliveryBannerTextEmpty_givenFreeFromPresentAndDeliveryTiersNil_thenSetDeliveryBannerText() {
        
        let currency = RetailStoreCurrency(currencyCode: "GBP", symbol: "£", ratio: 1, symbolChar: "£", name: "GBP")
        
        let freeFromCost: Double = 10
        
        let orderMethod = RetailStoreOrderMethod(name: .delivery, earliestTime: nil, status: .open, cost: 1, fulfilmentIn: nil, freeFulfilmentMessage: "", deliveryTiers: nil, freeFrom: freeFromCost, minSpend: 0)
        
        let freeFromText = Strings.StoresView.DeliveryTiersCustom.freeFrom.localizedFormat(freeFromCost.toCurrencyString(using: currency))
        
        let deliveryTierInfo = DeliveryTierInfo(orderMethod: orderMethod, currency: currency)
        
        let sut = makeSUT(deliveryTierInfo: deliveryTierInfo, fromBasket: false)
        
        XCTAssertEqual(sut.deliveryBannerText, freeFromText)
        XCTAssertTrue(sut.showDeliveryBanner)
    }
    
    func test_whenCurrencyNotNilAndDeliveryBannerTextNil_givenFreeFromPresentAndDeliveryTiersEmpty_thenSetDeliveryBannerText() {
        
        let currency = RetailStoreCurrency(currencyCode: "GBP", symbol: "£", ratio: 1, symbolChar: "£", name: "GBP")
        
        let freeFromCost: Double = 10
        
        let orderMethod = RetailStoreOrderMethod(name: .delivery, earliestTime: nil, status: .open, cost: 1, fulfilmentIn: nil, freeFulfilmentMessage: nil, deliveryTiers: [], freeFrom: freeFromCost, minSpend: 0)
        
        let freeFromText = Strings.StoresView.DeliveryTiersCustom.freeFrom.localizedFormat(freeFromCost.toCurrencyString(using: currency))
        
        let deliveryTierInfo = DeliveryTierInfo(orderMethod: orderMethod, currency: currency)
        
        let sut = makeSUT(deliveryTierInfo: deliveryTierInfo, fromBasket: false)
        
        XCTAssertEqual(sut.deliveryBannerText, freeFromText)
        XCTAssertTrue(sut.showDeliveryBanner)
    }
    
    func test_whenCurrencyNotNilAndDeliveryBannerTextEmpty_givenFreeFromPresentAndDeliveryTiersEmpty_thenSetDeliveryBannerText() {
        
        let currency = RetailStoreCurrency(currencyCode: "GBP", symbol: "£", ratio: 1, symbolChar: "£", name: "GBP")
        
        let freeFromCost: Double = 10
        
        let orderMethod = RetailStoreOrderMethod(name: .delivery, earliestTime: nil, status: .open, cost: 1, fulfilmentIn: nil, freeFulfilmentMessage: "", deliveryTiers: [], freeFrom: freeFromCost, minSpend: 0)
        
        let freeFromText = Strings.StoresView.DeliveryTiersCustom.freeFrom.localizedFormat(freeFromCost.toCurrencyString(using: currency))
        
        let deliveryTierInfo = DeliveryTierInfo(orderMethod: orderMethod, currency: currency)
        
        let sut = makeSUT(deliveryTierInfo: deliveryTierInfo, fromBasket: false)
        
        XCTAssertEqual(sut.deliveryBannerText, freeFromText)
        XCTAssertTrue(sut.showDeliveryBanner)
    }
    
    func test_whenCurrencyNotNilAndDeliveryBannerTextNil_givenFreeFromNilAndDeliveryTiersNotEmpty_thenSetDeliveryBannerText() {
        
        let tiers: [DeliveryTier] = [
            .init(minBasketSpend: 10, deliveryFee: 2),
            .init(minBasketSpend: 20, deliveryFee: 1)
        ]
        
        let currency = RetailStoreCurrency(currencyCode: "GBP", symbol: "£", ratio: 1, symbolChar: "£", name: "GBP")
                
        let orderMethod = RetailStoreOrderMethod(name: .delivery, earliestTime: nil, status: .open, cost: 1, fulfilmentIn: nil, freeFulfilmentMessage: nil, deliveryTiers: tiers, freeFrom: nil, minSpend: 0)

        let deliveryTierInfo = DeliveryTierInfo(orderMethod: orderMethod, currency: currency)
        
        let sut = makeSUT(deliveryTierInfo: deliveryTierInfo, fromBasket: false)
        
        let expectedString = deliveryTierInfo.orderMethod?.fromDeliveryCost(currency: currency)
        
        XCTAssertEqual(sut.deliveryBannerText, expectedString)
        XCTAssertTrue(sut.showDeliveryBanner)
    }
    
    func test_whenCurrencyNotNilAndDeliveryBannerTextEmpty_givenFreeFromNilAndDeliveryTiersNotEmpty_thenSetDeliveryBannerText() {
        
        let tiers: [DeliveryTier] = [
            .init(minBasketSpend: 10, deliveryFee: 2),
            .init(minBasketSpend: 20, deliveryFee: 1)
        ]
        
        let currency = RetailStoreCurrency(currencyCode: "GBP", symbol: "£", ratio: 1, symbolChar: "£", name: "GBP")
                
        let orderMethod = RetailStoreOrderMethod(name: .delivery, earliestTime: nil, status: .open, cost: 1, fulfilmentIn: nil, freeFulfilmentMessage: "", deliveryTiers: tiers, freeFrom: nil, minSpend: 0)

        let deliveryTierInfo = DeliveryTierInfo(orderMethod: orderMethod, currency: currency)
        
        let sut = makeSUT(deliveryTierInfo: deliveryTierInfo, fromBasket: false)
        
        let expectedString = deliveryTierInfo.orderMethod?.fromDeliveryCost(currency: currency)
        
        XCTAssertEqual(sut.deliveryBannerText, expectedString)
        XCTAssertTrue(sut.showDeliveryBanner)
    }
    
    func test_whenCurrencyNotNilAndDeliveryBannerTextEmpty_givenFreeFromNilAndDeliveryTiersNil_thenSetDeliveryBannerTextToNil() {
        
        let currency = RetailStoreCurrency(currencyCode: "GBP", symbol: "£", ratio: 1, symbolChar: "£", name: "GBP")
                
        let orderMethod = RetailStoreOrderMethod(name: .delivery, earliestTime: nil, status: .open, cost: 1, fulfilmentIn: nil, freeFulfilmentMessage: "", deliveryTiers: nil, freeFrom: nil, minSpend: 0)

        let deliveryTierInfo = DeliveryTierInfo(orderMethod: orderMethod, currency: currency)
        
        let sut = makeSUT(deliveryTierInfo: deliveryTierInfo, fromBasket: false)

        XCTAssertNil(sut.deliveryBannerText)
        XCTAssertFalse(sut.showDeliveryBanner)
    }
    
    func test_whenCurrencyNotNilAndDeliveryBannerTextEmpty_givenFreeFromNilAndDeliveryTiersEmpty_thenSetDeliveryBannerTextToNil() {
        
        let currency = RetailStoreCurrency(currencyCode: "GBP", symbol: "£", ratio: 1, symbolChar: "£", name: "GBP")
                
        let orderMethod = RetailStoreOrderMethod(name: .delivery, earliestTime: nil, status: .open, cost: 1, fulfilmentIn: nil, freeFulfilmentMessage: "", deliveryTiers: [], freeFrom: nil, minSpend: 0)

        let deliveryTierInfo = DeliveryTierInfo(orderMethod: orderMethod, currency: currency)
        
        let sut = makeSUT(deliveryTierInfo: deliveryTierInfo, fromBasket: false)

        XCTAssertNil(sut.deliveryBannerText)
        XCTAssertFalse(sut.showDeliveryBanner)
    }
    
    func test_whenTiersAreNil_thenHasTiersIsFalse() {
        
        let currency = RetailStoreCurrency(currencyCode: "GBP", symbol: "£", ratio: 1, symbolChar: "£", name: "GBP")
                
        let orderMethod = RetailStoreOrderMethod(name: .delivery, earliestTime: nil, status: .open, cost: 1, fulfilmentIn: nil, freeFulfilmentMessage: "", deliveryTiers: nil, freeFrom: nil, minSpend: 0)

        let deliveryTierInfo = DeliveryTierInfo(orderMethod: orderMethod, currency: currency)
        
        let sut = makeSUT(deliveryTierInfo: deliveryTierInfo, fromBasket: false)
        
        XCTAssertFalse(sut.hasTiers)
        XCTAssertTrue(sut.isDisabled)
    }
    
    func test_whenTiersAreEmpty_thenHasTiersIsFalse() {
        
        let currency = RetailStoreCurrency(currencyCode: "GBP", symbol: "£", ratio: 1, symbolChar: "£", name: "GBP")
                
        let orderMethod = RetailStoreOrderMethod(name: .delivery, earliestTime: nil, status: .open, cost: 1, fulfilmentIn: nil, freeFulfilmentMessage: "", deliveryTiers: [], freeFrom: nil, minSpend: 0)

        let deliveryTierInfo = DeliveryTierInfo(orderMethod: orderMethod, currency: currency)
        
        let sut = makeSUT(deliveryTierInfo: deliveryTierInfo, fromBasket: false)
        
        XCTAssertFalse(sut.hasTiers)
        XCTAssertTrue(sut.isDisabled)
    }
    
    
    func test_whenTiersAreNotEmpty_thenHasTiersIsTrue() {
        let tiers: [DeliveryTier] = [
            .init(minBasketSpend: 10, deliveryFee: 2),
            .init(minBasketSpend: 20, deliveryFee: 1)
        ]
        
        let currency = RetailStoreCurrency(currencyCode: "GBP", symbol: "£", ratio: 1, symbolChar: "£", name: "GBP")
                
        let orderMethod = RetailStoreOrderMethod(name: .delivery, earliestTime: nil, status: .open, cost: 1, fulfilmentIn: nil, freeFulfilmentMessage: "", deliveryTiers: tiers, freeFrom: nil, minSpend: 0)

        let deliveryTierInfo = DeliveryTierInfo(orderMethod: orderMethod, currency: currency)
        
        let sut = makeSUT(deliveryTierInfo: deliveryTierInfo, fromBasket: false)
        
        XCTAssertTrue(sut.hasTiers)
        XCTAssertFalse(sut.isDisabled)
    }
    
    func test_whenSetOrderMethodCalled_thenOrderMethodSet() {
        let tiers: [DeliveryTier] = [
            .init(minBasketSpend: 10, deliveryFee: 2),
            .init(minBasketSpend: 20, deliveryFee: 1)
        ]
        
        let currency = RetailStoreCurrency(currencyCode: "GBP", symbol: "£", ratio: 1, symbolChar: "£", name: "GBP")
                
        let orderMethod = RetailStoreOrderMethod(name: .delivery, earliestTime: nil, status: .open, cost: 1, fulfilmentIn: nil, freeFulfilmentMessage: "", deliveryTiers: tiers, freeFrom: nil, minSpend: 0)

        let deliveryTierInfo = DeliveryTierInfo(orderMethod: orderMethod, currency: currency)
        
        let sut = makeSUT(deliveryTierInfo: deliveryTierInfo, fromBasket: false)
        
        sut.setOrderMethod(orderMethod)
        
        XCTAssertEqual(sut.selectedDeliveryTierInfo?.orderMethod, orderMethod)
    }
    
    func makeSUT(container: DIContainer = DIContainer(appState: AppState(), eventLogger: MockedEventLogger(), services: .mocked()), runMemoryLeakTracking: Bool = true, deliveryTierInfo: DeliveryTierInfo, fromBasket: Bool) -> DeliveryOfferBannerViewModel {
        
        let currency = RetailStoreCurrency(currencyCode: "GBP", symbol: "£", ratio: 1, symbolChar: "£", name: "Great British Pound")

        let sut = DeliveryOfferBannerViewModel(container: container, deliveryTierInfo: deliveryTierInfo, currency: currency, fromBasket: fromBasket)
        
        // Tasks, in Xcode 14, trigger memory leaks, so they are stored and cancelled on deinit
        if runMemoryLeakTracking {
            trackForMemoryLeaks(sut)
        }
        
        return sut
    }
}
