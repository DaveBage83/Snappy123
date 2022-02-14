//
//  ProductAddButtonViewModelTests.swift
//  SnappyV2Tests
//
//  Created by Henrik Gustavii on 18/01/2022.
//

import XCTest
import Combine
@testable import SnappyV2

class ProductAddButtonViewModelTests: XCTestCase {
    
    func test_init() {
        let price = RetailStoreMenuItemPrice(price: 10, fromPrice: 0, unitMetric: "", unitsInPack: 0, unitVolume: 0, wasPrice: nil)
        let menuItem = RetailStoreMenuItem(id: 123, name: "", eposCode: nil, outOfStock: false, ageRestriction: 0, description: "", quickAdd: true, price: price, images: nil, menuItemSizes: nil, menuItemOptions: nil, availableDeals: nil)
        let sut = makeSUT(menuItem: menuItem)
        
        XCTAssertEqual(sut.item, menuItem)
        XCTAssertNil(sut.basket)
        XCTAssertTrue(sut.quickAddIsEnabled)
        XCTAssertFalse(sut.hasAgeRestriction)
        XCTAssertFalse(sut.isUpdatingQuantity)
        XCTAssertEqual(sut.basketQuantity, 0)
        XCTAssertFalse(sut.itemHasOptionsOrSizes)
        XCTAssertTrue(sut.showStandardButton)
        XCTAssertFalse(sut.showOptions)
    }
    
    func test_whenMenuSizesIsNotNil_thenItemHasOptionOrSizesIsTrue() {
        let price = RetailStoreMenuItemPrice(price: 10, fromPrice: 0, unitMetric: "", unitsInPack: 0, unitVolume: 0, wasPrice: nil)
        let menuItem = RetailStoreMenuItem(id: 123, name: "", eposCode: nil, outOfStock: false, ageRestriction: 0, description: "", quickAdd: true, price: price, images: nil, menuItemSizes: [], menuItemOptions: nil, availableDeals: nil)
        let sut = makeSUT(menuItem: menuItem)
        
        XCTAssertTrue(sut.itemHasOptionsOrSizes)
    }
    
    func test_whenMenuItemOptionsIsNotNil_thenItemHasOptionOrSizesIsTrue() {
        let price = RetailStoreMenuItemPrice(price: 10, fromPrice: 0, unitMetric: "", unitsInPack: 0, unitVolume: 0, wasPrice: nil)
        let menuItem = RetailStoreMenuItem(id: 123, name: "", eposCode: nil, outOfStock: false, ageRestriction: 0, description: "", quickAdd: true, price: price, images: nil, menuItemSizes: nil, menuItemOptions: [], availableDeals: nil)
        let sut = makeSUT(menuItem: menuItem)
        
        XCTAssertTrue(sut.itemHasOptionsOrSizes)
    }
    
    func test_whenAgeIsMoreThanZero_thenHasAgeRestrictionIsTrue() {
        let price = RetailStoreMenuItemPrice(price: 10, fromPrice: 0, unitMetric: "", unitsInPack: 0, unitVolume: 0, wasPrice: nil)
        let menuItem = RetailStoreMenuItem(id: 123, name: "", eposCode: nil, outOfStock: false, ageRestriction: 18, description: "", quickAdd: true, price: price, images: nil, menuItemSizes: nil, menuItemOptions: nil, availableDeals: nil)
        let sut = makeSUT(menuItem: menuItem)
        
        XCTAssertTrue(sut.hasAgeRestriction)
    }
    
    func test_whenAddItemCalled_thenQuantityIncreases() {
        let price = RetailStoreMenuItemPrice(price: 10, fromPrice: 0, unitMetric: "", unitsInPack: 0, unitVolume: 0, wasPrice: nil)
        let menuItem = RetailStoreMenuItem(id: 123, name: "", eposCode: nil, outOfStock: false, ageRestriction: 0, description: "", quickAdd: true, price: price, images: nil, menuItemSizes: nil, menuItemOptions: nil, availableDeals: nil)
        let sut = makeSUT(menuItem: menuItem)
        
        sut.addItem()
        
        XCTAssertEqual(sut.changeQuantity, 1)
    }
    
    func test_whenRemoveItemCalled_thenQuantityDecreases() {
        let price = RetailStoreMenuItemPrice(price: 10, fromPrice: 0, unitMetric: "", unitsInPack: 0, unitVolume: 0, wasPrice: nil)
        let menuItem = RetailStoreMenuItem(id: 123, name: "", eposCode: nil, outOfStock: false, ageRestriction: 0, description: "", quickAdd: true, price: price, images: nil, menuItemSizes: nil, menuItemOptions: nil, availableDeals: nil)
        let sut = makeSUT(menuItem: menuItem)
        
        sut.removeItem()
        
        XCTAssertEqual(sut.changeQuantity, -1)
    }
    
    func test_givenZeroBasketQuantity_whenAddItemTapped_thenAddItemServiceIsTriggeredAndIsCorrect() {
        let container = DIContainer(appState: AppState(), services: .mocked(basketService: [.addItem(item: BasketItemRequest(menuItemId: 123, quantity: 1, sizeId: 0, bannerAdvertId: 0, options: []))]))
        
        let price = RetailStoreMenuItemPrice(price: 10, fromPrice: 0, unitMetric: "", unitsInPack: 0, unitVolume: 0, wasPrice: nil)
        let menuItem = RetailStoreMenuItem(id: 123, name: "", eposCode: nil, outOfStock: false, ageRestriction: 0, description: "", quickAdd: true, price: price, images: nil, menuItemSizes: nil, menuItemOptions: nil, availableDeals: nil)
        let sut = makeSUT(container: container, menuItem: menuItem)
        
        let expectation = expectation(description: "setupItemQuantityChange")
        var cancellables = Set<AnyCancellable>()
        
        sut.$isUpdatingQuantity
            .collect(2)
            .receive(on: RunLoop.main)
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        sut.addItem()
        
        wait(for: [expectation], timeout: 5)
        
        XCTAssertFalse(sut.isUpdatingQuantity)
        
        container.services.verify()
    }
    
    func test_givenBasketQuantity1_whenAddItemTapped_thenUpdateItemServiceIsTriggeredAndIsCorrect() {
        let container = DIContainer(appState: AppState(), services: .mocked(basketService: [.updateItem(item: BasketItemRequest(menuItemId: 123, quantity: 2, sizeId: 0, bannerAdvertId: 0, options: []), basketLineId: 234)]))
        
        let price = RetailStoreMenuItemPrice(price: 10, fromPrice: 0, unitMetric: "", unitsInPack: 0, unitVolume: 0, wasPrice: nil)
        let menuItem = RetailStoreMenuItem(id: 123, name: "", eposCode: nil, outOfStock: false, ageRestriction: 0, description: "", quickAdd: true, price: price, images: nil, menuItemSizes: nil, menuItemOptions: nil, availableDeals: nil)
        let sut = makeSUT(container: container, menuItem: menuItem)
        sut.basketQuantity = 1
        sut.basketLineId = 234
        
        let expectation = expectation(description: "setupItemQuantityChange")
        var cancellables = Set<AnyCancellable>()
        
        sut.$isUpdatingQuantity
            .collect(2)
            .receive(on: RunLoop.main)
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        sut.addItem()
        
        wait(for: [expectation], timeout: 5)
        
        XCTAssertFalse(sut.isUpdatingQuantity)
        
        container.services.verify()
    }
    
    func test_givenBasketQuantity1_whenRemoveItemTapped_thenUpdateItemServiceIsTriggeredAndIsCorrect() {
        let container = DIContainer(appState: AppState(), services: .mocked(basketService: [.removeItem(basketLineId: 234)]))
        
        let price = RetailStoreMenuItemPrice(price: 10, fromPrice: 0, unitMetric: "", unitsInPack: 0, unitVolume: 0, wasPrice: nil)
        let menuItem = RetailStoreMenuItem(id: 123, name: "", eposCode: nil, outOfStock: false, ageRestriction: 0, description: "", quickAdd: true, price: price, images: nil, menuItemSizes: nil, menuItemOptions: nil, availableDeals: nil)
        let sut = makeSUT(container: container, menuItem: menuItem)
        sut.basketQuantity = 1
        sut.basketLineId = 234
        
        let expectation = expectation(description: "setupItemQuantityChange")
        var cancellables = Set<AnyCancellable>()
        
        sut.$isUpdatingQuantity
            .collect(2)
            .receive(on: RunLoop.main)
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        sut.removeItem()
        
        wait(for: [expectation], timeout: 5)
        
        XCTAssertFalse(sut.isUpdatingQuantity)
        
        container.services.verify()
    }
    
    func test_givenBasketWithItem_whenBasketUpdatedToEmptyBasketItems_thenBasketQuantityAndBasketLineIdIsCleared() {
        let price = RetailStoreMenuItemPrice(price: 10, fromPrice: 0, unitMetric: "", unitsInPack: 0, unitVolume: 0, wasPrice: nil)
        let menuItem = RetailStoreMenuItem(id: 123, name: "", eposCode: nil, outOfStock: false, ageRestriction: 0, description: "", quickAdd: true, price: price, images: nil, menuItemSizes: nil, menuItemOptions: nil, availableDeals: nil)
        let basketItem = BasketItem(basketLineId: 321, menuItem: menuItem, totalPrice: 10, totalPriceBeforeDiscounts: 10, price: 10, pricePaid: 10, quantity: 1, size: nil, selectedOptions: nil, missedPromotions: nil)
        let basketWithItem = Basket(basketToken: "213ouihwefo", isNewBasket: false, items: [basketItem], fulfilmentMethod: BasketFulfilmentMethod(type: .delivery), selectedSlot: nil, savings: nil, coupon: nil, fees: nil, addresses: nil, orderSubtotal: 0, orderTotal: 0)
        let appState = AppState(system: AppState.System(), routing: AppState.ViewRouting(), userData: .init(selectedStore: .notRequested, selectedFulfilmentMethod: .delivery, searchResult: .notRequested, basket: basketWithItem, memberSignedIn: false))
        let sut = makeSUT(container: DIContainer(appState: appState, services: .mocked()), menuItem: menuItem)
        
        XCTAssertEqual(sut.basketQuantity, 1)
        XCTAssertEqual(sut.basketLineId, 321)
        
        let basketEmpty = Basket(basketToken: "213ouihwefo", isNewBasket: false, items: [], fulfilmentMethod: BasketFulfilmentMethod(type: .delivery), selectedSlot: nil, savings: nil, coupon: nil, fees: nil, addresses: nil, orderSubtotal: 0, orderTotal: 0)
        
        sut.container.appState.value.userData.basket = basketEmpty
        
        XCTAssertEqual(sut.basketQuantity, 0)
        XCTAssertNil(sut.basketLineId)
    }
    
    func test_givenBasketWithTwo_whenBasketUpdatedWithOnlyOneOtherItem_thenBasketQuantityAndBasketLineIdIsCleared() {
        let price = RetailStoreMenuItemPrice(price: 10, fromPrice: 0, unitMetric: "", unitsInPack: 0, unitVolume: 0, wasPrice: nil)
        let menuItem1 = RetailStoreMenuItem(id: 123, name: "", eposCode: nil, outOfStock: false, ageRestriction: 0, description: "", quickAdd: true, price: price, images: nil, menuItemSizes: nil, menuItemOptions: nil, availableDeals: nil)
        let menuItem2 = RetailStoreMenuItem(id: 234, name: "", eposCode: nil, outOfStock: false, ageRestriction: 0, description: "", quickAdd: true, price: price, images: nil, menuItemSizes: nil, menuItemOptions: nil, availableDeals: nil)
        let basketItem1 = BasketItem(basketLineId: 321, menuItem: menuItem1, totalPrice: 10, totalPriceBeforeDiscounts: 10, price: 10, pricePaid: 10, quantity: 1, size: nil, selectedOptions: nil, missedPromotions: nil)
        let basketItem2 = BasketItem(basketLineId: 432, menuItem: menuItem2, totalPrice: 10, totalPriceBeforeDiscounts: 10, price: 10, pricePaid: 10, quantity: 1, size: nil, selectedOptions: nil, missedPromotions: nil)
        let basketWithTwoItems = Basket(basketToken: "213ouihwefo", isNewBasket: false, items: [basketItem1, basketItem2], fulfilmentMethod: BasketFulfilmentMethod(type: .delivery), selectedSlot: nil, savings: nil, coupon: nil, fees: nil, addresses: nil, orderSubtotal: 0, orderTotal: 0)
        let appState = AppState(system: AppState.System(), routing: AppState.ViewRouting(), userData: .init(selectedStore: .notRequested, selectedFulfilmentMethod: .delivery, searchResult: .notRequested, basket: basketWithTwoItems, memberSignedIn: false))
        let sut = makeSUT(container: DIContainer(appState: appState, services: .mocked()), menuItem: menuItem1)
        
        XCTAssertEqual(sut.basketQuantity, 1)
        XCTAssertEqual(sut.basketLineId, 321)
        XCTAssertEqual(sut.container.appState.value.userData.basket?.items.count, 2)
        
        let basketWithOneItem = Basket(basketToken: "213ouihwefo", isNewBasket: false, items: [basketItem2], fulfilmentMethod: BasketFulfilmentMethod(type: .delivery), selectedSlot: nil, savings: nil, coupon: nil, fees: nil, addresses: nil, orderSubtotal: 0, orderTotal: 0)
        
        sut.container.appState.value.userData.basket = basketWithOneItem
        
        XCTAssertEqual(sut.basketQuantity, 0)
        XCTAssertNil(sut.basketLineId)
        XCTAssertEqual(sut.container.appState.value.userData.basket?.items.count, 1)
    }
    
    func test_givenBasketWithItemOf2Quantity_thenQuantityShows2() {
        let price = RetailStoreMenuItemPrice(price: 10, fromPrice: 0, unitMetric: "", unitsInPack: 0, unitVolume: 0, wasPrice: nil)
        let menuItem = RetailStoreMenuItem(id: 123, name: "", eposCode: nil, outOfStock: false, ageRestriction: 0, description: "", quickAdd: true, price: price, images: nil, menuItemSizes: nil, menuItemOptions: nil, availableDeals: nil)
        let sut = makeSUT(menuItem: menuItem)
        
        let expectation = expectation(description: "setupBasketItemCheck")
        var cancellables = Set<AnyCancellable>()
        
        sut.$basketQuantity
            .first()
            .receive(on: RunLoop.main)
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        let basketItem = BasketItem(basketLineId: 45, menuItem: menuItem, totalPrice: 10, totalPriceBeforeDiscounts: 10, price: 5, pricePaid: 10, quantity: 2, size: nil, selectedOptions: nil, missedPromotions: nil)
        sut.container.appState.value.userData.basket = Basket(basketToken: "", isNewBasket: false, items: [basketItem], fulfilmentMethod: BasketFulfilmentMethod(type: .delivery), selectedSlot: nil, savings: nil, coupon: nil, fees: nil, addresses: nil, orderSubtotal: 0, orderTotal: 0)
        
        wait(for: [expectation], timeout: 5)
        
        XCTAssertEqual(sut.basketQuantity, 2)
    }
    
    func test_whenAddItemsWithOptionsTapped_thenShowOptionsIsTrue() {
        let price = RetailStoreMenuItemPrice(price: 10, fromPrice: 0, unitMetric: "", unitsInPack: 0, unitVolume: 0, wasPrice: nil)
        let menuItem = RetailStoreMenuItem(id: 123, name: "", eposCode: nil, outOfStock: false, ageRestriction: 0, description: "", quickAdd: true, price: price, images: nil, menuItemSizes: nil, menuItemOptions: nil, availableDeals: nil)
        let sut = makeSUT(menuItem: menuItem)
        
        sut.addItemWithOptionsTapped()
        
        XCTAssertTrue(sut.showOptions)
    }

    func makeSUT(container: DIContainer = DIContainer(appState: AppState(), services: .mocked()), menuItem: RetailStoreMenuItem) -> ProductAddButtonViewModel {
        let sut = ProductAddButtonViewModel(container: container, menuItem: menuItem)
        
        trackForMemoryLeaks(sut)
        
        return sut
    }
}