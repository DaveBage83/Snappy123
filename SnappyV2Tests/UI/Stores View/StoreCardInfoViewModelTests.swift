//
//  StoreCardInfoViewModelTests.swift
//  SnappyV2Tests
//
//  Created by Henrik Gustavii on 03/10/2021.
//

import XCTest
@testable import SnappyV2

class StoreCardInfoViewModelTests: XCTestCase {

    func test_init() {
        let sut = makeSUT(storeDetails: storeInit)
        
        XCTAssertEqual(sut.distance, "0")
        XCTAssertEqual(sut.storeDetails.storeName, "Most Basic Store Ever")
    }
    
    func test_given4DecimalDistance_thenConvertedTo2DecimalString() {
        let storeDetails = RetailStore(id: 1, storeName: "Slightly Better Store", distance: 3.9638, storeLogo: nil, storeProductTypes: nil, orderMethods: nil, ratings: nil, currency: RetailStoreCurrency.mockedGBPData)
        let sut = makeSUT(storeDetails: storeDetails)
        
        XCTAssertEqual(sut.distance, "3.96")
    }
    
    func test_whenStoreHasOrderDeliveryMethod_thenOrderDeliveryMethodPopulated() {
        let store = RetailStore.mockedData.first
        let sut = makeSUT(storeDetails: store!)
        let expectedMethod = RetailStore.mockedData.first?.orderMethods!["delivery"]
        let expectedCurrency = RetailStore.mockedData.first?.currency
        XCTAssertEqual(sut.orderDeliveryMethod, expectedMethod)
        XCTAssertEqual(sut.currency, expectedCurrency)
    }
    
    func test_whenNoCurrencyPassedIn_thenFromDeliveryCostIsNil() {
        let store = RetailStore.mockedData.first
        let expectedMethod = RetailStore.mockedData.first?.orderMethods!["delivery"]
        let fromCost = expectedMethod?.fromDeliveryCost(currency: nil)
        XCTAssertNil(fromCost)
    }
    
    // Following tests are all testing the RetailStore extension which returns the min spend string
    func test_whenLowestDeliveryCostPresentAndCostPresentAndLowestTierDeliveryCostGreaterThanCostAndMindSpendIsNil_givenCurrencyPresent_thenReturnExpectedString() {
        let tiers = [
            DeliveryTier(minBasketSpend: 5, deliveryFee: 5)
        ]
        
        let currency = RetailStoreCurrency(currencyCode: "GBP", symbol: "£", ratio: 1, symbolChar: "£", name: "GBP")
        
        let cost: Double = 3
        
        let orderMethod: RetailStoreOrderMethod = .init(name: .delivery, earliestTime: nil, status: .open, cost: cost, fulfilmentIn: nil, freeFulfilmentMessage: nil, deliveryTiers: tiers, freeFrom: nil, minSpend: nil)
        
        let fromDeliveryCostString = orderMethod.fromDeliveryCost(currency: currency)?.text
        let hasTiers = orderMethod.fromDeliveryCost(currency: currency)?.hasTiers
        
        XCTAssertEqual(fromDeliveryCostString, "£3")
        XCTAssertTrue(hasTiers == true)
    }
    
    func test_whenLowestDeliveryCostPresentAndCostPresentAndLowestTierDeliveryCostGreaterThanCostAndMindSpendIs0_givenCurrencyPresent_thenReturnExpectedString() {
        let tiers = [
            DeliveryTier(minBasketSpend: 5, deliveryFee: 5)
        ]
        
        let currency = RetailStoreCurrency(currencyCode: "GBP", symbol: "£", ratio: 1, symbolChar: "£", name: "GBP")
        
        let cost: Double = 3
        
        let orderMethod: RetailStoreOrderMethod = .init(name: .delivery, earliestTime: nil, status: .open, cost: cost, fulfilmentIn: nil, freeFulfilmentMessage: nil, deliveryTiers: tiers, freeFrom: nil, minSpend: 0)
        
        let fromDeliveryCostString = orderMethod.fromDeliveryCost(currency: currency)?.text
        let hasTiers = orderMethod.fromDeliveryCost(currency: currency)?.hasTiers

        XCTAssertEqual(fromDeliveryCostString, "£3")
        XCTAssertTrue(hasTiers == true)
    }
    
    func test_whenLowestDeliveryCostPresentAndCostIsNilAndLowestTierDeliveryCostGreaterThanCostAndMindSpendIs0_givenCurrencyPresent_thenReturnExpectedString() {
        let tiers = [
            DeliveryTier(minBasketSpend: 5, deliveryFee: 3),
            DeliveryTier(minBasketSpend: 5, deliveryFee: 5)
        ]
        
        let currency = RetailStoreCurrency(currencyCode: "GBP", symbol: "£", ratio: 1, symbolChar: "£", name: "GBP")
                
        let orderMethod: RetailStoreOrderMethod = .init(name: .delivery, earliestTime: nil, status: .open, cost: nil, fulfilmentIn: nil, freeFulfilmentMessage: nil, deliveryTiers: tiers, freeFrom: nil, minSpend: 0)
        
        let lowestCostString = tiers.first?.deliveryFee.toCurrencyString(using: currency, roundWholeNumbers: true)
                
        let fromDeliveryCostString = orderMethod.fromDeliveryCost(currency: currency)?.text
        let hasTiers = orderMethod.fromDeliveryCost(currency: currency)?.hasTiers
        
        XCTAssertEqual(fromDeliveryCostString, "£3")
        XCTAssertTrue(hasTiers == true)
    }
    
    func test_whenLowestDeliveryCostPresentAndCostPresentAndLowestTierDeliveryCostLessThanCostAndMindSpendIs0_givenCurrencyPresent_thenReturnExpectedString() {
        let tiers = [
            DeliveryTier(minBasketSpend: 5, deliveryFee: 3),
            DeliveryTier(minBasketSpend: 5, deliveryFee: 5)
        ]
        
        let currency = RetailStoreCurrency(currencyCode: "GBP", symbol: "£", ratio: 1, symbolChar: "£", name: "GBP")
              
        let cost: Double = 10
        
        let orderMethod: RetailStoreOrderMethod = .init(name: .delivery, earliestTime: nil, status: .open, cost: cost, fulfilmentIn: nil, freeFulfilmentMessage: nil, deliveryTiers: tiers, freeFrom: nil, minSpend: 0)
        
        let lowestCostString = tiers.first?.deliveryFee.toCurrencyString(using: currency, roundWholeNumbers: true)
                
        let fromDeliveryCostString = orderMethod.fromDeliveryCost(currency: currency)?.text
        let hasTiers = orderMethod.fromDeliveryCost(currency: currency)?.hasTiers

        XCTAssertEqual(fromDeliveryCostString, "£3")
        XCTAssertTrue(hasTiers == true)
    }
    
    func test_whenLowestDeliveryCostPresentAndCostPresentAndLowestTierDeliveryCostGreaterThanCostAndMindSpendIsNotNilAndMindSpendIsNotNil_givenCurrencyPresent_thenReturnExpectedString() {
        let tiers = [
            DeliveryTier(minBasketSpend: 5, deliveryFee: 3),
            DeliveryTier(minBasketSpend: 5, deliveryFee: 5)
        ]
        
        let currency = RetailStoreCurrency(currencyCode: "GBP", symbol: "£", ratio: 1, symbolChar: "£", name: "GBP")
              
        let cost: Double = 2
        
        let orderMethod: RetailStoreOrderMethod = .init(name: .delivery, earliestTime: nil, status: .open, cost: cost, fulfilmentIn: nil, freeFulfilmentMessage: nil, deliveryTiers: tiers, freeFrom: nil, minSpend: 2)
        
        let lowestCostString = tiers.first?.deliveryFee.toCurrencyString(using: currency, roundWholeNumbers: true)
                
        let fromDeliveryCostString = orderMethod.fromDeliveryCost(currency: currency)?.text
        let hasTiers = orderMethod.fromDeliveryCost(currency: currency)?.hasTiers

        XCTAssertEqual(fromDeliveryCostString, "£3")
        XCTAssertTrue(hasTiers == true)
    }
    
    func test_whenLowestDeliveryCostNilAndMinSpendPresentAndFreeFromPresentAndFreeFromGreaterThan0AndMinSpendGreaterThanOrEqualToFreeFrom_thenReturnExpectedString() {
  
        let currency = RetailStoreCurrency(currencyCode: "GBP", symbol: "£", ratio: 1, symbolChar: "£", name: "GBP")
              
        let cost: Double = 2
        
        let orderMethod: RetailStoreOrderMethod = .init(name: .delivery, earliestTime: nil, status: .open, cost: cost, fulfilmentIn: nil, freeFulfilmentMessage: nil, deliveryTiers: nil, freeFrom: 10, minSpend: 20)
        
        let fromDeliveryCostString = orderMethod.fromDeliveryCost(currency: currency)?.text
        
        XCTAssertEqual(fromDeliveryCostString, Strings.StoresView.DeliveryTiers.freeDelivery.localized)
    }
    
    func test_whenLowestDeliveryCostNilAndMinSpendNilAndFreeFromPresentAndFreeFromGreaterThan0AndMinSpendGreaterThanOrEqualToFreeFrom_thenReturnExpectedString() {
  
        let currency = RetailStoreCurrency(currencyCode: "GBP", symbol: "£", ratio: 1, symbolChar: "£", name: "GBP")
              
        let cost: Double = 2
        
        let orderMethod: RetailStoreOrderMethod = .init(name: .delivery, earliestTime: nil, status: .open, cost: cost, fulfilmentIn: nil, freeFulfilmentMessage: nil, deliveryTiers: nil, freeFrom: 10, minSpend: nil)
        
        let fromDeliveryCostString = orderMethod.fromDeliveryCost(currency: currency)?.text
        let hasTiers = orderMethod.fromDeliveryCost(currency: currency)?.hasTiers

        XCTAssertEqual(fromDeliveryCostString, cost.toCurrencyString(using: currency, roundWholeNumbers: true))
        XCTAssertTrue(hasTiers == false)
    }
    
    func test_whenLowestDeliveryCostNilAndMinSpendPresentAndFreeFromNilAndFreeFromGreaterThan0AndMinSpendGreaterThanOrEqualToFreeFrom_thenReturnExpectedString() {
  
        let currency = RetailStoreCurrency(currencyCode: "GBP", symbol: "£", ratio: 1, symbolChar: "£", name: "GBP")
              
        let cost: Double = 2
        
        let orderMethod: RetailStoreOrderMethod = .init(name: .delivery, earliestTime: nil, status: .open, cost: cost, fulfilmentIn: nil, freeFulfilmentMessage: nil, deliveryTiers: nil, freeFrom: nil, minSpend: 10)
        
        let fromDeliveryCostString = orderMethod.fromDeliveryCost(currency: currency)?.text
        let hasTiers = orderMethod.fromDeliveryCost(currency: currency)?.hasTiers

        XCTAssertEqual(fromDeliveryCostString, cost.toCurrencyString(using: currency, roundWholeNumbers: true))
        XCTAssertTrue(hasTiers == false)
    }
    
    func test_whenLowestDeliveryCostNilAndMinSpendPresentAndFreeFromPresentAndFreeFromIs0AndMinSpendGreaterThanOrEqualToFreeFrom_thenReturnExpectedString() {
  
        let currency = RetailStoreCurrency(currencyCode: "GBP", symbol: "£", ratio: 1, symbolChar: "£", name: "GBP")
              
        let cost: Double = 2
        
        let orderMethod: RetailStoreOrderMethod = .init(name: .delivery, earliestTime: nil, status: .open, cost: cost, fulfilmentIn: nil, freeFulfilmentMessage: nil, deliveryTiers: nil, freeFrom: 0, minSpend: 10)
        
        let fromDeliveryCostString = orderMethod.fromDeliveryCost(currency: currency)?.text
        let hasTiers = orderMethod.fromDeliveryCost(currency: currency)?.hasTiers

        
        XCTAssertEqual(fromDeliveryCostString, cost.toCurrencyString(using: currency, roundWholeNumbers: true))
        XCTAssertTrue(hasTiers == false)
    }
    
    func test_whenLowestDeliveryCostNilAndMinSpendPresentAndFreeFromPresentAndFreeFromIsGreaterThan0AndMinSpendLessThanFreeFrom_thenReturnExpectedString() {
  
        let currency = RetailStoreCurrency(currencyCode: "GBP", symbol: "£", ratio: 1, symbolChar: "£", name: "GBP")
              
        let cost: Double = 2
        
        let orderMethod: RetailStoreOrderMethod = .init(name: .delivery, earliestTime: nil, status: .open, cost: cost, fulfilmentIn: nil, freeFulfilmentMessage: nil, deliveryTiers: nil, freeFrom: 10, minSpend: 5)
        
        let fromDeliveryCostString = orderMethod.fromDeliveryCost(currency: currency)?.text
        let hasTiers = orderMethod.fromDeliveryCost(currency: currency)?.hasTiers

        XCTAssertEqual(fromDeliveryCostString, cost.toCurrencyString(using: currency, roundWholeNumbers: true))
        XCTAssertTrue(hasTiers == false)
    }
    
    func test_whenNoTiersPresent_thenLowestTierDeliveryCostNil() {
        let cost: Double = 2
        
        let orderMethod: RetailStoreOrderMethod = .init(name: .delivery, earliestTime: nil, status: .open, cost: cost, fulfilmentIn: nil, freeFulfilmentMessage: nil, deliveryTiers: nil, freeFrom: 10, minSpend: 20)
        
        XCTAssertNil(orderMethod.lowestTierDeliveryCost)
    }
    
    func test_whenTiersPresent_thenLowestTierDeliveryCostReturned() {
        let cost: Double = 2
        
        let tiers = [
            DeliveryTier(minBasketSpend: 5, deliveryFee: 3),
            DeliveryTier(minBasketSpend: 5, deliveryFee: 5)
        ]
        
        let orderMethod: RetailStoreOrderMethod = .init(name: .delivery, earliestTime: nil, status: .open, cost: cost, fulfilmentIn: nil, freeFulfilmentMessage: nil, deliveryTiers: tiers, freeFrom: 10, minSpend: 20)
        
        XCTAssertEqual(orderMethod.lowestTierDeliveryCost, 3)
    }
    
    func test_whenFulfilmentTypeSelectedIsDelivery_thenFulfilmentTimeTitleSetCorrectly() {
        let sut = makeSUT(storeDetails: storeInit)
        sut.container.appState.value.userData.selectedFulfilmentMethod = .delivery
        
        XCTAssertEqual(sut.fulfilmentTimeTitle, GeneralStrings.deliveryTime.localized)
    }
    
    func test_whenFulfilmentTypeSelectedIsCollection_thenFulfilmentTimeTitleSetCorrectly() {
        let sut = makeSUT(storeDetails: storeInit)
        sut.container.appState.value.userData.selectedFulfilmentMethod = .collection
        
        XCTAssertEqual(sut.fulfilmentTimeTitle, GeneralStrings.collectionTime.localized)
    }
    
    func test_whenFulfilmentTypeSelectedIsDelivery_thenFulfilmentTimeTitleShortSetCorrectly() {
        let sut = makeSUT(storeDetails: storeInit)
        sut.container.appState.value.userData.selectedFulfilmentMethod = .delivery
        
        XCTAssertEqual(sut.fulfilmentTimeTitleShort, GeneralStrings.deliveryTimeShort.localized)
    }
    
    func test_whenFulfilmentTypeSelectedIsCollection_thenFulfilmentTimeTitleShortSetCorrectly() {
        let sut = makeSUT(storeDetails: storeInit)
        sut.container.appState.value.userData.selectedFulfilmentMethod = .collection
        
        XCTAssertEqual(sut.fulfilmentTimeTitleShort, GeneralStrings.collectionTimeShort.localized)
    }
    
    func test_whenFulfilmentTypeSelectedIsDelivery_thenShowDeliveryOfferIfApplicableTrue() {
        let sut = makeSUT(storeDetails: storeInit)
        sut.container.appState.value.userData.selectedFulfilmentMethod = .delivery
        
        XCTAssertTrue(sut.showDeliveryOfferIfApplicable)
    }
    
    func test_whenFulfilmentTypeSelectedIsCollection_thenShowDeliveryOfferIfApplicableFalse() {
        let sut = makeSUT(storeDetails: storeInit)
        sut.container.appState.value.userData.selectedFulfilmentMethod = .collection
        
        XCTAssertFalse(sut.showDeliveryOfferIfApplicable)
    }
    
    func test_whenFulfilmentTypeSelectedIsDelivery_thenShowDeliveryCostTrue() {
        let sut = makeSUT(storeDetails: storeInit)
        sut.container.appState.value.userData.selectedFulfilmentMethod = .delivery
        
        XCTAssertTrue(sut.showDeliveryCost)
    }
    
    func test_whenFulfilmentTypeSelectedIsCollection_thenShowDeliveryCostFalse() {
        let sut = makeSUT(storeDetails: storeInit)
        sut.container.appState.value.userData.selectedFulfilmentMethod = .collection
        
        XCTAssertFalse(sut.showDeliveryCost)
    }
    
    func test_whenFulfilmentTypeSelectedIsDelivery_thenFulfilmentTimeStringSetCorrectly() {
        let sut = makeSUT(storeDetails: .mockedData.first!)
        sut.container.appState.value.userData.selectedFulfilmentMethod = .delivery
        
        XCTAssertEqual(sut.fulfilmentTime, "6 to 66 mins")
    }
    
    func test_whenFulfilmentTypeSelectedIsCollection_thenFulfilmentTimeStringSetCorrectly() {
            let sut = makeSUT(storeDetails: .mockedData.first!)
        sut.container.appState.value.userData.selectedFulfilmentMethod = .collection
        
        XCTAssertEqual(sut.fulfilmentTime, "1 to 6 mins")
    }
    
    func makeSUT(storeDetails: RetailStore) -> StoreCardInfoViewModel {
        let sut = StoreCardInfoViewModel(container: .preview, storeDetails: storeDetails)
        
        trackForMemoryLeaks(sut)
        
        return sut
    }
    
    let storeInit = RetailStore(id: 1, storeName: "Most Basic Store Ever", distance: 0, storeLogo: nil, storeProductTypes: nil, orderMethods: nil, ratings: nil, currency: RetailStoreCurrency.mockedGBPData)

}
