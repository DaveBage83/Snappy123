//
//  ProductCardViewModelTests.swift
//  SnappyV2Tests
//
//  Created by Henrik Gustavii on 11/11/2021.
//

import XCTest
import Combine

// 3rd party
import Firebase

@testable import SnappyV2

@MainActor
class ProductCardViewModelTests: XCTestCase {
    
    func test_init() {
        let price = RetailStoreMenuItemPrice(price: 10, fromPrice: 0, unitMetric: "", unitsInPack: 0, unitVolume: 0, wasPrice: nil)
        let menuItem = RetailStoreMenuItem(id: 123, name: "", eposCode: nil, outOfStock: false, ageRestriction: 0, description: "", quickAdd: true, acceptCustomerInstructions: false, basketQuantityLimit: 500, price: price, images: nil, menuItemSizes: nil, menuItemOptions: nil, availableDeals: nil, itemCaptions: nil, mainCategory: MenuItemCategory(id: 345, name: ""), itemDetails: nil, deal: nil)
        let selectedStore = RetailStoreDetails.mockedData
        let appState = AppState(userData: AppState.UserData(selectedStore: .loaded(selectedStore), selectedFulfilmentMethod: .delivery, searchResult: .notRequested, basket: nil, currentFulfilmentLocation: nil, tempTodayTimeSlot: nil, basketDeliveryAddress: nil, memberProfile: nil))
        let sut = makeSUT(container: DIContainer(appState: appState, eventLogger: MockedEventLogger(), services: .mocked()), menuItem: menuItem)
        
        XCTAssertEqual(sut.itemDetail, menuItem)
        XCTAssertFalse(sut.showSearchProductCard)
        XCTAssertFalse(sut.isReduced)
        XCTAssertNil(sut.calorieInfo)
        XCTAssertNil(sut.fromPriceString)
        XCTAssertFalse(sut.isOffer)
    }
    
    func test_whenWasPricePresent_thenIsReducedIsTrueAndWasPriceStringIsPopulated() {
        let price = RetailStoreMenuItemPrice(price: 10, fromPrice: 0, unitMetric: "", unitsInPack: 0, unitVolume: 0, wasPrice: 22)
        let menuItem = RetailStoreMenuItem(id: 123, name: "", eposCode: nil, outOfStock: false, ageRestriction: 0, description: "", quickAdd: true, acceptCustomerInstructions: false, basketQuantityLimit: 500, price: price, images: nil, menuItemSizes: nil, menuItemOptions: nil, availableDeals: nil, itemCaptions: nil, mainCategory: MenuItemCategory(id: 345, name: ""), itemDetails: nil, deal: nil)
        let selectedStore = RetailStoreDetails.mockedData
        let appState = AppState(userData: AppState.UserData(selectedStore: .loaded(selectedStore), selectedFulfilmentMethod: .delivery, searchResult: .notRequested, basket: nil, currentFulfilmentLocation: nil, tempTodayTimeSlot: nil, basketDeliveryAddress: nil, memberProfile: nil))
        let sut = makeSUT(container: DIContainer(appState: appState, eventLogger: MockedEventLogger(), services: .mocked()), menuItem: menuItem)
        
        XCTAssertTrue(sut.isReduced)
        XCTAssertEqual(sut.wasPriceString, "£22.00")
    }
    
    func test_whenCalorieInfoPresent_thenCalorieStringPopulated() {
        let price = RetailStoreMenuItemPrice(price: 10, fromPrice: 0, unitMetric: "", unitsInPack: 0, unitVolume: 0, wasPrice: 22)
        let menuItem = RetailStoreMenuItem(id: 123, name: "", eposCode: nil, outOfStock: false, ageRestriction: 0, description: "", quickAdd: true, acceptCustomerInstructions: false, basketQuantityLimit: 500, price: price, images: nil, menuItemSizes: nil, menuItemOptions: nil, availableDeals: nil, itemCaptions: ItemCaptions(portionSize: "450 kcal per 100g"), mainCategory: MenuItemCategory(id: 345, name: ""), itemDetails: nil, deal: nil)
        let sut = makeSUT(menuItem: menuItem)
        
        XCTAssertEqual(sut.calorieInfo, "450 kcal per 100g")
    }
    
    func test_whenFromPriceIs0_thenHasNoFromPrice() {
        let price = RetailStoreMenuItemPrice(price: 10, fromPrice: 0, unitMetric: "", unitsInPack: 0, unitVolume: 0, wasPrice: 22)
        let menuItem = RetailStoreMenuItem(id: 123, name: "", eposCode: nil, outOfStock: false, ageRestriction: 0, description: "", quickAdd: true, acceptCustomerInstructions: false, basketQuantityLimit: 500, price: price, images: nil, menuItemSizes: nil, menuItemOptions: nil, availableDeals: nil, itemCaptions: ItemCaptions(portionSize: "450 kcal per 100g"), mainCategory: MenuItemCategory(id: 345, name: ""), itemDetails: nil, deal: nil)
        let selectedStore = RetailStoreDetails.mockedData
        let appState = AppState(userData: AppState.UserData(selectedStore: .loaded(selectedStore), selectedFulfilmentMethod: .delivery, searchResult: .notRequested, basket: nil, currentFulfilmentLocation: nil, tempTodayTimeSlot: nil, basketDeliveryAddress: nil, memberProfile: nil))
        let sut = makeSUT(container: DIContainer(appState: appState, eventLogger: MockedEventLogger(), services: .mocked()), menuItem: menuItem)
        
        XCTAssertNil(sut.fromPriceString)
    }
    
    func test_whenFromPriceIsGreaterThan0_thenHasFromPrice() {
        let price = RetailStoreMenuItemPrice(price: 10, fromPrice: 22, unitMetric: "", unitsInPack: 0, unitVolume: 0, wasPrice: 22)
        let menuItem = RetailStoreMenuItem(id: 123, name: "", eposCode: nil, outOfStock: false, ageRestriction: 0, description: "", quickAdd: true, acceptCustomerInstructions: false, basketQuantityLimit: 500, price: price, images: nil, menuItemSizes: [RetailStoreMenuItemSize(id: 444, name: "", price: MenuItemSizePrice(price: 10))], menuItemOptions: nil, availableDeals: nil, itemCaptions: ItemCaptions(portionSize: "450 kcal per 100g"), mainCategory: MenuItemCategory(id: 345, name: ""), itemDetails: nil, deal: nil)
        let selectedStore = RetailStoreDetails.mockedData
        let appState = AppState(userData: AppState.UserData(selectedStore: .loaded(selectedStore), selectedFulfilmentMethod: .delivery, searchResult: .notRequested, basket: nil, currentFulfilmentLocation: nil, tempTodayTimeSlot: nil, basketDeliveryAddress: nil, memberProfile: nil))
        let sut = makeSUT(container: DIContainer(appState: appState, eventLogger: MockedEventLogger(), services: .mocked()), menuItem: menuItem)
        
        XCTAssertEqual(sut.fromPriceString, "£22.00")
    }
    
    func test_latestOffer() {
        let deals = [RetailStoreMenuItemAvailableDeal(id: 888, name: "Test deal", type: "Test type"),
                     RetailStoreMenuItemAvailableDeal(id: 999, name: "Test deal", type: "Test type")]
        let price = RetailStoreMenuItemPrice(price: 10, fromPrice: 0, unitMetric: "", unitsInPack: 0, unitVolume: 0, wasPrice: nil)
        let menuItem = RetailStoreMenuItem(id: 123, name: "", eposCode: nil, outOfStock: false, ageRestriction: 0, description: "", quickAdd: true, acceptCustomerInstructions: false, basketQuantityLimit: 500, price: price, images: nil, menuItemSizes: nil, menuItemOptions: nil, availableDeals: deals, itemCaptions: nil, mainCategory: MenuItemCategory(id: 345, name: ""), itemDetails: nil, deal: nil)
        let sut = makeSUT(menuItem: menuItem)
        
        XCTAssertEqual(sut.latestOffer?.id, 999)
    }
    
    func test_whenProductCardTapped_givenNoSelectedStore_thenIsGettingProductDetailsRemainsFalse() async {
        let sut = makeSUT(menuItem: RetailStoreMenuItem.mockedData)
        
        do {
            try await sut.productCardTapped()
            XCTAssertFalse(sut.isGettingProductDetails)
        } catch {
            XCTFail("Unexpected error trying to get product details")
        }
    }
    
    func test_whenProductCardTapped_givenStoreSelected_thenProductDetailsRequested() async {
        let item = RetailStoreMenuItem.mockedData
        let store = RetailStoreDetails.mockedData
        
        let request = RetailStoreMenuItemRequest(itemId: item.id, storeId: store.id, categoryId: nil, fulfilmentMethod: .delivery, fulfilmentDate: "")
        let eventLogger = MockedEventLogger()
        let container = DIContainer(appState: AppState(), eventLogger: eventLogger, services: .mocked(retailStoreMenuService: [.getItem(request: request)]))
        container.appState.value.userData.selectedStore = .loaded(RetailStoreDetails.mockedData)
        
        let sut = makeSUT(container: container, menuItem: RetailStoreMenuItem.mockedData)
        
        do {
            try await sut.productCardTapped()
            container.services.verify(as: .retailStoreMenu)
            // No events should be logged without an associated search term
            eventLogger.verify()
        } catch {
            XCTFail("Unexpected error trying to get product details")
        }
    }
    
    func test_whenProductCardTapped_givenStoreSelectedAndAssociatedTerm_thenProductDetailsRequestedAndEventSent() async {
        let searchTerm = "Test"
        let item = RetailStoreMenuItem.mockedData
        let store = RetailStoreDetails.mockedData
        
        let request = RetailStoreMenuItemRequest(itemId: item.id, storeId: store.id, categoryId: nil, fulfilmentMethod: .delivery, fulfilmentDate: "")
        let eventLogger = MockedEventLogger(expected: [
            .sendEvent(
                for: SnappyV2.AppEvent.searchResultSelection,
                with: SnappyV2.EventLoggerType.firebaseAnalytics,
                params: [
                    AnalyticsParameterSearchTerm: searchTerm,
                    "name": item.name,
                    "item_id": item.id,
                    "category_id": item.mainCategory.id
                ]
            )
        ])
        let container = DIContainer(appState: AppState(), eventLogger: eventLogger, services: .mocked(retailStoreMenuService: [.getItem(request: request)]))
        container.appState.value.userData.selectedStore = .loaded(RetailStoreDetails.mockedData)
        
        let sut = makeSUT(container: container, menuItem: RetailStoreMenuItem.mockedData, associatedSearchTerm: searchTerm)
        
        do {
            try await sut.productCardTapped()
            container.services.verify(as: .retailStoreMenu)
            eventLogger.verify()
        } catch {
            XCTFail("Unexpected error trying to get product details")
        }
    }
    
    func test_whenIsInBasketIsTrue_thenShowSpecialOfferPillAsButtonIsFalse() {
        let sut = makeSUT(menuItem: RetailStoreMenuItem.mockedData, isInBasket: true)
        XCTAssertFalse(sut.showSpecialOfferPillAsButton)
    }
    
    func test_whenIsInBasketIsFalse_thenShowSpecialOfferPillAsButtonIsTrue() {
        let sut = makeSUT(menuItem: RetailStoreMenuItem.mockedData)
        XCTAssertTrue(sut.showSpecialOfferPillAsButton)
    }
    
    func makeSUT(container: DIContainer = DIContainer(appState: AppState(), eventLogger: MockedEventLogger(), services: .mocked()), menuItem: RetailStoreMenuItem, isInBasket: Bool = false, associatedSearchTerm: String? = nil) -> ProductCardViewModel {
        let sut = ProductCardViewModel(container: container, menuItem: menuItem, isInBasket: isInBasket, associatedSearchTerm: associatedSearchTerm, productSelected: {
        _ in})
        
        trackForMemoryLeaks(sut)
        
        return sut
    }
}
    
