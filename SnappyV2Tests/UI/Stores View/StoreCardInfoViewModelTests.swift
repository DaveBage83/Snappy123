//
//  StoreCardInfoViewModelTests.swift
//  SnappyV2Tests
//
//  Created by Henrik Gustavii on 03/10/2021.
//

import XCTest
@testable import SnappyV2
import Combine

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
        
        let orderMethod: RetailStoreOrderMethod = .init(name: .delivery, earliestTime: nil, status: .open, cost: cost, fulfilmentIn: nil, freeFulfilmentMessage: nil, deliveryTiers: tiers, freeFrom: nil, minSpend: nil, earliestOpeningDate: nil)
        
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
        
        let orderMethod: RetailStoreOrderMethod = .init(name: .delivery, earliestTime: nil, status: .open, cost: cost, fulfilmentIn: nil, freeFulfilmentMessage: nil, deliveryTiers: tiers, freeFrom: nil, minSpend: 0, earliestOpeningDate: nil)
        
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
                
        let orderMethod: RetailStoreOrderMethod = .init(name: .delivery, earliestTime: nil, status: .open, cost: nil, fulfilmentIn: nil, freeFulfilmentMessage: nil, deliveryTiers: tiers, freeFrom: nil, minSpend: 0, earliestOpeningDate: nil)
        
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
        
        let orderMethod: RetailStoreOrderMethod = .init(name: .delivery, earliestTime: nil, status: .open, cost: cost, fulfilmentIn: nil, freeFulfilmentMessage: nil, deliveryTiers: tiers, freeFrom: nil, minSpend: 0, earliestOpeningDate: nil)
        
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
        
        let orderMethod: RetailStoreOrderMethod = .init(name: .delivery, earliestTime: nil, status: .open, cost: cost, fulfilmentIn: nil, freeFulfilmentMessage: nil, deliveryTiers: tiers, freeFrom: nil, minSpend: 2, earliestOpeningDate: nil)
        
        let lowestCostString = tiers.first?.deliveryFee.toCurrencyString(using: currency, roundWholeNumbers: true)
                
        let fromDeliveryCostString = orderMethod.fromDeliveryCost(currency: currency)?.text
        let hasTiers = orderMethod.fromDeliveryCost(currency: currency)?.hasTiers

        XCTAssertEqual(fromDeliveryCostString, "£3")
        XCTAssertTrue(hasTiers == true)
    }
    
    func test_whenLowestDeliveryCostNilAndMinSpendPresentAndFreeFromPresentAndFreeFromGreaterThan0AndMinSpendGreaterThanOrEqualToFreeFrom_thenReturnExpectedString() {
  
        let currency = RetailStoreCurrency(currencyCode: "GBP", symbol: "£", ratio: 1, symbolChar: "£", name: "GBP")
              
        let cost: Double = 2
        
        let orderMethod: RetailStoreOrderMethod = .init(name: .delivery, earliestTime: nil, status: .open, cost: cost, fulfilmentIn: nil, freeFulfilmentMessage: nil, deliveryTiers: nil, freeFrom: 10, minSpend: 20, earliestOpeningDate: nil)
        
        let fromDeliveryCostString = orderMethod.fromDeliveryCost(currency: currency)?.text
        
        XCTAssertEqual(fromDeliveryCostString, Strings.StoresView.DeliveryTiers.freeDelivery.localized)
    }
    
    func test_whenLowestDeliveryCostNilAndMinSpendNilAndFreeFromPresentAndFreeFromGreaterThan0AndMinSpendGreaterThanOrEqualToFreeFrom_thenReturnExpectedString() {
  
        let currency = RetailStoreCurrency(currencyCode: "GBP", symbol: "£", ratio: 1, symbolChar: "£", name: "GBP")
              
        let cost: Double = 2
        
        let orderMethod: RetailStoreOrderMethod = .init(name: .delivery, earliestTime: nil, status: .open, cost: cost, fulfilmentIn: nil, freeFulfilmentMessage: nil, deliveryTiers: nil, freeFrom: 10, minSpend: nil, earliestOpeningDate: nil)
        
        let fromDeliveryCostString = orderMethod.fromDeliveryCost(currency: currency)?.text
        let hasTiers = orderMethod.fromDeliveryCost(currency: currency)?.hasTiers

        XCTAssertEqual(fromDeliveryCostString, cost.toCurrencyString(using: currency, roundWholeNumbers: true))
        XCTAssertTrue(hasTiers == false)
    }
    
    func test_whenLowestDeliveryCostNilAndMinSpendPresentAndFreeFromNilAndFreeFromGreaterThan0AndMinSpendGreaterThanOrEqualToFreeFrom_thenReturnExpectedString() {
  
        let currency = RetailStoreCurrency(currencyCode: "GBP", symbol: "£", ratio: 1, symbolChar: "£", name: "GBP")
              
        let cost: Double = 2
        
        let orderMethod: RetailStoreOrderMethod = .init(name: .delivery, earliestTime: nil, status: .open, cost: cost, fulfilmentIn: nil, freeFulfilmentMessage: nil, deliveryTiers: nil, freeFrom: nil, minSpend: 10, earliestOpeningDate: nil)
        
        let fromDeliveryCostString = orderMethod.fromDeliveryCost(currency: currency)?.text
        let hasTiers = orderMethod.fromDeliveryCost(currency: currency)?.hasTiers

        XCTAssertEqual(fromDeliveryCostString, cost.toCurrencyString(using: currency, roundWholeNumbers: true))
        XCTAssertTrue(hasTiers == false)
    }
    
    func test_whenLowestDeliveryCostNilAndMinSpendPresentAndFreeFromPresentAndFreeFromIs0AndMinSpendGreaterThanOrEqualToFreeFrom_thenReturnExpectedString() {
  
        let currency = RetailStoreCurrency(currencyCode: "GBP", symbol: "£", ratio: 1, symbolChar: "£", name: "GBP")
              
        let cost: Double = 2
        
        let orderMethod: RetailStoreOrderMethod = .init(name: .delivery, earliestTime: nil, status: .open, cost: cost, fulfilmentIn: nil, freeFulfilmentMessage: nil, deliveryTiers: nil, freeFrom: 0, minSpend: 10, earliestOpeningDate: nil)
        
        let fromDeliveryCostString = orderMethod.fromDeliveryCost(currency: currency)?.text
        let hasTiers = orderMethod.fromDeliveryCost(currency: currency)?.hasTiers

        
        XCTAssertEqual(fromDeliveryCostString, cost.toCurrencyString(using: currency, roundWholeNumbers: true))
        XCTAssertTrue(hasTiers == false)
    }
    
    func test_whenLowestDeliveryCostNilAndMinSpendPresentAndFreeFromPresentAndFreeFromIsGreaterThan0AndMinSpendLessThanFreeFrom_thenReturnExpectedString() {
  
        let currency = RetailStoreCurrency(currencyCode: "GBP", symbol: "£", ratio: 1, symbolChar: "£", name: "GBP")
              
        let cost: Double = 2
        
        let orderMethod: RetailStoreOrderMethod = .init(name: .delivery, earliestTime: nil, status: .open, cost: cost, fulfilmentIn: nil, freeFulfilmentMessage: nil, deliveryTiers: nil, freeFrom: 10, minSpend: 5, earliestOpeningDate: nil)
        
        let fromDeliveryCostString = orderMethod.fromDeliveryCost(currency: currency)?.text
        let hasTiers = orderMethod.fromDeliveryCost(currency: currency)?.hasTiers

        XCTAssertEqual(fromDeliveryCostString, cost.toCurrencyString(using: currency, roundWholeNumbers: true))
        XCTAssertTrue(hasTiers == false)
    }
    
    func test_whenNoTiersPresent_thenLowestTierDeliveryCostNil() {
        let cost: Double = 2
        
        let orderMethod: RetailStoreOrderMethod = .init(name: .delivery, earliestTime: nil, status: .open, cost: cost, fulfilmentIn: nil, freeFulfilmentMessage: nil, deliveryTiers: nil, freeFrom: 10, minSpend: 20, earliestOpeningDate: nil)
        
        XCTAssertNil(orderMethod.lowestTierDeliveryCost)
    }
    
    func test_whenTiersPresent_thenLowestTierDeliveryCostReturned() {
        let cost: Double = 2
        
        let tiers = [
            DeliveryTier(minBasketSpend: 5, deliveryFee: 3),
            DeliveryTier(minBasketSpend: 5, deliveryFee: 5)
        ]
        
        let orderMethod: RetailStoreOrderMethod = .init(name: .delivery, earliestTime: nil, status: .open, cost: cost, fulfilmentIn: nil, freeFulfilmentMessage: nil, deliveryTiers: tiers, freeFrom: 10, minSpend: 20, earliestOpeningDate: nil)
        
        XCTAssertEqual(orderMethod.lowestTierDeliveryCost, 3)
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
    
    func test_whenDeliveryOrderMethodIsNil_thenFreeDeliveryTextIsNil() {
        let sut = makeSUT(storeDetails: RetailStore.mockedDataIndividualStoreNoDelivery)
        XCTAssertNil(sut.freeDeliveryText)
    }
    
    func test_whenDeliveryOrderMethodIsNotNil_givenFreeDeliveryTextPreset_thenFreeDeliveryTextIsPopulated() {
        let sut = makeSUT(storeDetails: RetailStore.mockedDataIndividualStoreWithDeliveryOffer)
        XCTAssertEqual(sut.freeDeliveryText, "Test")
    }
    
    func test_whenDeliveryOrderMethodIsNotNil_givenFreeDeliveryTextNotPreset_thenFreeDeliveryTextIsPopulated() {
        let sut = makeSUT(storeDetails: RetailStore.mockedDataIndividualStoreWithNoDeliveryOffer)
        XCTAssertNil(sut.freeDeliveryText)
    }
    
    func test_whenNoDeliveryMethod_thenNoMinOrder() {
        let sut = makeSUT(storeDetails: .mockedDataIndividualStoreNoDelivery)
        XCTAssertEqual(sut.minOrder, Strings.StoresView.DeliveryTiers.noMinOrder.localized)
    }
    
    func test_whenDeliveryMethodPresent_givenShowDeliveryCostIsFalse_thenNoMinOrder() {
        let sut = makeSUT(storeDetails: .mockedDataIndividualStoreWithDeliveryOffer)
        sut.container.appState.value.userData.selectedFulfilmentMethod = .collection
        XCTAssertEqual(sut.minOrder, Strings.StoresView.DeliveryTiers.noMinOrder.localized)    }
    
    func test_whenDeliveryMethodPresent_givenShowDeliveryCostIsTrueAndMinSpendPresentInAPI_thenMinOrderPopulated() {
        let sut = makeSUT(storeDetails: .mockedDataIndividualStoreWithMinSpend)
        sut.container.appState.value.userData.selectedFulfilmentMethod = .delivery
        XCTAssertEqual(sut.minOrder, "Min £10")
    }
    
    func test_whenDeliveryMethodPresent_givenShowDeliveryCostIsTrueAndMinSpendPresentInAPIButIs0_thenMinOrderNil() {
        let sut = makeSUT(storeDetails: .mockedDataIndividualStoreWithZeroSpend)
        sut.container.appState.value.userData.selectedFulfilmentMethod = .delivery
        XCTAssertEqual(sut.minOrder, Strings.StoresView.DeliveryTiers.noMinOrder.localized)
    }
    
    func test_whenDeliveryMethodPresent_givenShowDeliveryCostIsTrueAndNoMinSpendInAPI_thenMinOrderNil() {
        let sut = makeSUT(storeDetails: .mockedDataIndividualStoreWithNilSpend)
        sut.container.appState.value.userData.selectedFulfilmentMethod = .delivery
        XCTAssertEqual(sut.minOrder, Strings.StoresView.DeliveryTiers.noMinOrder.localized)
    }
    
    func test_whenAppStateSelectedStoreIDIsSameAsStoreDetailsID_thenIsSelectedStoreIsTrue() {
        let container = DIContainer(appState: AppState(), eventLogger: MockedEventLogger(), services: .mocked())
        container.appState.value.userData.selectedStore = .loaded(.mockedDataID1234)
        let store = RetailStore(id: 1234, storeName: "", distance: 1, storeLogo: nil, storeProductTypes: nil, orderMethods: nil, ratings: nil, currency: .mockedGBPData)
        let sut = makeSUT(container: container, storeDetails: store)
        let expectation = expectation(description: "storeSelected == true")
        var cancellables = Set<AnyCancellable>()
        
        container.appState
            .map(\.userData.selectedStore)
            .first()
            .receive(on: RunLoop.main)
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        wait(for: [expectation], timeout: 2)
        
        XCTAssertTrue(sut.isSelectedStore)
    }
    
    func test_whenAppStateSelectedStoreIDIsNOTSameAsStoreDetailsID_thenIsSelectedStoreIsFalse() {
        let container = DIContainer(appState: AppState(), eventLogger: MockedEventLogger(), services: .mocked())
        container.appState.value.userData.selectedStore = .loaded(.mockedDataID1234)
        let store = RetailStore(id: 5678, storeName: "", distance: 1, storeLogo: nil, storeProductTypes: nil, orderMethods: nil, ratings: nil, currency: .mockedGBPData)
        let sut = makeSUT(container: container, storeDetails: store)
        let expectation = expectation(description: "storeSelected == true")
        var cancellables = Set<AnyCancellable>()
        
        container.appState
            .map(\.userData.selectedStore)
            .first()
            .receive(on: RunLoop.main)
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        wait(for: [expectation], timeout: 2)
        
        XCTAssertFalse(sut.isSelectedStore)
    }
    
    func test_whenOrderMethodIsDelivery_givenStoreHasDeliveryAndStatusOpen_thenReturnCorrectStoreStatus() {
        let sut = makeSUT(storeDetails: .mockedDataIndividualStoreDeliveryOpen)
        sut.container.appState.value.userData.selectedFulfilmentMethod = .delivery
        XCTAssertEqual(sut.storeStatus, .open)
    }
    
    
    func test_whenOrderMethodIsDelivery_givenStoreHasDeliveryAndStatusCloded_thenReturnCorrectStoreStatus() {
        let sut = makeSUT(storeDetails: .mockedDataIndividualStoreDeliveryClosed)
        sut.container.appState.value.userData.selectedFulfilmentMethod = .delivery
        XCTAssertEqual(sut.storeStatus, .closed)
    }
    
    func test_whenOrderMethodIsDelivery_givenStoreHasNoDelivery_thenReturnCorrectStoreStatusNil() {
        let sut = makeSUT(storeDetails: .mockedDataIndividualStoreCollectionOpen)
        sut.container.appState.value.userData.selectedFulfilmentMethod = .delivery
        XCTAssertNil(sut.storeStatus)
    }
    
    func test_whenOrderMethodIsCollection_givenStoreHasCollectionAndStatusOpen_thenReturnCorrectStoreStatus() {
        let sut = makeSUT(storeDetails: .mockedDataIndividualStoreCollectionOpen)
        sut.container.appState.value.userData.selectedFulfilmentMethod = .collection
        XCTAssertEqual(sut.storeStatus, .open)
    }
    
    func test_whenOrderMethodIsCollection_givenStoreHasCollectionAndStatusCloded_thenReturnCorrectStoreStatus() {
        let sut = makeSUT(storeDetails: .mockedDataIndividualStoreCollectionClosed)
        sut.container.appState.value.userData.selectedFulfilmentMethod = .collection
        XCTAssertEqual(sut.storeStatus, .closed)
    }
    
    func test_whenOrderMethodIsCollection_givenStoreHasNoCollection_thenReturnCorrectStoreStatusNil() {
        let sut = makeSUT(storeDetails: .mockedDataIndividualStoreDeliveryOpen)
        sut.container.appState.value.userData.selectedFulfilmentMethod = .collection
        XCTAssertNil(sut.storeStatus)
    }
    
    func test_whenSelectedMethodIsDelivery_givenPreorderStatus_thenReturnCorrectFulfilmentTimeString() {
        let sut = makeSUT(storeDetails: .mockedDataIndividualStoreDeliveryPreorder)
        sut.container.appState.value.userData.selectedFulfilmentMethod = .delivery
        
        XCTAssertEqual(sut.fulfilmentTime, "31-Jan")
    }
    
    func test_whenSelectedMethodIsCollection_givenPreorderStatus_thenReturnCorrectFulfilmentTimeString() {
        let sut = makeSUT(storeDetails: .mockedDataIndividualStoreCollectionPreorder)
        sut.container.appState.value.userData.selectedFulfilmentMethod = .collection
        
        XCTAssertEqual(sut.fulfilmentTime, "31-Jan")
    }
    
    
    func test_whenSelectedMethodIsDelivery_givenPreorderStatusAndWrongDateFormat_thenReturnFulfilmentTimeStringAsNil() {
        let sut = makeSUT(storeDetails: .mockedDataIndividualStoreDeliveryPreorderWrongDateFormat)
        sut.container.appState.value.userData.selectedFulfilmentMethod = .delivery
        
        XCTAssertNil(sut.fulfilmentTime)
    }
    
    func makeSUT(container: DIContainer = .preview, storeDetails: RetailStore) -> StoreCardInfoViewModel {
        let sut = StoreCardInfoViewModel(container: container, storeDetails: storeDetails)
        
        trackForMemoryLeaks(sut)
        
        return sut
    }
    
    let storeInit = RetailStore(id: 1, storeName: "Most Basic Store Ever", distance: 0, storeLogo: nil, storeProductTypes: nil, orderMethods: nil, ratings: nil, currency: RetailStoreCurrency.mockedGBPData)

}
