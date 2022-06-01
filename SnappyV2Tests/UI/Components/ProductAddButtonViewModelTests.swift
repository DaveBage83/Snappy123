//
//  ProductAddButtonViewModelTests.swift
//  SnappyV2Tests
//
//  Created by Henrik Gustavii on 18/01/2022.
//

import XCTest
import Combine
import AppsFlyerLib
@testable import SnappyV2

@MainActor
class ProductAddButtonViewModelTests: XCTestCase {
    
    func test_init() {
        let price = RetailStoreMenuItemPrice(price: 10, fromPrice: 0, unitMetric: "", unitsInPack: 0, unitVolume: 0, wasPrice: nil)
        let menuItem = RetailStoreMenuItem(id: 123, name: "", eposCode: nil, outOfStock: false, ageRestriction: 0, description: "", quickAdd: true, acceptCustomerInstructions: false, basketQuantityLimit: 0, price: price, images: nil, menuItemSizes: nil, menuItemOptions: nil, availableDeals: nil, itemCaptions: nil, mainCategory: MenuItemCategory.mockedData)
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
        XCTAssertFalse(sut.quantityLimitReached)
    }
    
    func test_whenMenuSizesIsNotNil_thenItemHasOptionOrSizesIsTrue() {
        let price = RetailStoreMenuItemPrice(price: 10, fromPrice: 0, unitMetric: "", unitsInPack: 0, unitVolume: 0, wasPrice: nil)
        let menuItem = RetailStoreMenuItem(id: 123, name: "", eposCode: nil, outOfStock: false, ageRestriction: 0, description: "", quickAdd: true, acceptCustomerInstructions: false, basketQuantityLimit: 500, price: price, images: nil, menuItemSizes: [], menuItemOptions: nil, availableDeals: nil, itemCaptions: nil, mainCategory: MenuItemCategory.mockedData)
        let sut = makeSUT(menuItem: menuItem)
        
        XCTAssertTrue(sut.itemHasOptionsOrSizes)
    }
    
    func test_whenBasketQuantityIs1_thenShowDeleteButtonIsTrue() {
        let sut = makeSUT(menuItem: RetailStoreMenuItem.mockedData)
        sut.basketQuantity = 1
        
        XCTAssertTrue(sut.showDeleteButton)
    }
    
    func test_whenMenuItemOptionsIsNotNil_thenItemHasOptionOrSizesIsTrue() {
        let price = RetailStoreMenuItemPrice(price: 10, fromPrice: 0, unitMetric: "", unitsInPack: 0, unitVolume: 0, wasPrice: nil)
        let menuItem = RetailStoreMenuItem(id: 123, name: "", eposCode: nil, outOfStock: false, ageRestriction: 0, description: "", quickAdd: true, acceptCustomerInstructions: false, basketQuantityLimit: 500, price: price, images: nil, menuItemSizes: nil, menuItemOptions: [], availableDeals: nil, itemCaptions: nil, mainCategory: MenuItemCategory.mockedData)
        let sut = makeSUT(menuItem: menuItem)
        
        XCTAssertTrue(sut.itemHasOptionsOrSizes)
    }
    
    func test_whenAgeIsMoreThanZero_thenHasAgeRestrictionIsTrue() {
        let price = RetailStoreMenuItemPrice(price: 10, fromPrice: 0, unitMetric: "", unitsInPack: 0, unitVolume: 0, wasPrice: nil)
        let menuItem = RetailStoreMenuItem(id: 123, name: "", eposCode: nil, outOfStock: false, ageRestriction: 18, description: "", quickAdd: true, acceptCustomerInstructions: false, basketQuantityLimit: 500, price: price, images: nil, menuItemSizes: nil, menuItemOptions: nil, availableDeals: nil, itemCaptions: nil, mainCategory: MenuItemCategory.mockedData)
        let sut = makeSUT(menuItem: menuItem)
        
        XCTAssertTrue(sut.hasAgeRestriction)
    }
    
    func test_whenAddItemCalled_thenQuantityIncreases() {
        let price = RetailStoreMenuItemPrice(price: 10, fromPrice: 0, unitMetric: "", unitsInPack: 0, unitVolume: 0, wasPrice: nil)
        let menuItem = RetailStoreMenuItem(id: 123, name: "", eposCode: nil, outOfStock: false, ageRestriction: 0, description: "", quickAdd: true, acceptCustomerInstructions: false, basketQuantityLimit: 500, price: price, images: nil, menuItemSizes: nil, menuItemOptions: nil, availableDeals: nil, itemCaptions: nil, mainCategory: MenuItemCategory.mockedData)
        let sut = makeSUT(menuItem: menuItem)
        
        sut.addItem()
        
        XCTAssertEqual(sut.changeQuantity, 1)
    }
    
    func test_whenRemoveItemCalled_thenQuantityDecreases() {
        let price = RetailStoreMenuItemPrice(price: 10, fromPrice: 0, unitMetric: "", unitsInPack: 0, unitVolume: 0, wasPrice: nil)
        let menuItem = RetailStoreMenuItem(id: 123, name: "", eposCode: nil, outOfStock: false, ageRestriction: 0, description: "", quickAdd: true, acceptCustomerInstructions: false, basketQuantityLimit: 500, price: price, images: nil, menuItemSizes: nil, menuItemOptions: nil, availableDeals: nil, itemCaptions: nil, mainCategory: MenuItemCategory.mockedData)
        let sut = makeSUT(menuItem: menuItem)
        
        sut.removeItem()
        
        XCTAssertEqual(sut.changeQuantity, -1)
    }
    
    func test_givenZeroBasketQuantity_whenAddItemTapped_thenAddItemServiceIsTriggeredAndIsCorrect() {
        let price = RetailStoreMenuItemPrice(price: 10, fromPrice: 0, unitMetric: "", unitsInPack: 0, unitVolume: 0, wasPrice: nil)
        let menuItem = RetailStoreMenuItem(id: 123, name: "", eposCode: "23423", outOfStock: false, ageRestriction: 0, description: "", quickAdd: true, acceptCustomerInstructions: false, basketQuantityLimit: 500, price: price, images: nil, menuItemSizes: nil, menuItemOptions: nil, availableDeals: nil, itemCaptions: nil, mainCategory: MenuItemCategory.mockedData)
        let container = DIContainer(appState: AppState(), eventLogger: MockedEventLogger(), services: .mocked(basketService: [.addItem(basketItemRequest: BasketItemRequest(menuItemId: menuItem.id, quantity: 1, sizeId: 0, bannerAdvertId: 0, options: [], instructions: nil), item: menuItem)]))
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
        
        container.services.verify(as: .basket)
        eventLogger.verify()
    }
    
    func test_givenBasketQuantity1_whenAddItemTapped_thenUpdateItemServiceIsTriggeredAndIsCorrect() {
        let basketItem = BasketItem.mockedData
        let container = DIContainer(appState: AppState(), eventLogger: MockedEventLogger(), services: .mocked(basketService: [.updateItem(basketItemRequest: BasketItemRequest(menuItemId: basketItem.menuItem.id, quantity: 2, sizeId: 0, bannerAdvertId: 0, options: [], instructions: nil), basketItem: basketItem)]))
        
        let menuItem = basketItem.menuItem
        let sut = makeSUT(container: container, menuItem: menuItem)
        sut.basketQuantity = 1
        sut.basketItem = basketItem
        
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
        
        container.services.verify(as: .basket)
    }
    
    func test_givenBasketQuantity1_whenRemoveItemTapped_thenUpdateItemServiceIsTriggeredAndIsCorrect() {
        let basketItem = BasketItem.mockedData
        let menuItem = basketItem.menuItem
        let container = DIContainer(appState: AppState(), eventLogger: MockedEventLogger(), services: .mocked(basketService: [.removeItem(basketLineId: basketItem.basketLineId, item: menuItem)]))
        let sut = makeSUT(container: container, menuItem: menuItem)
        sut.basketQuantity = 1
        sut.basketItem = basketItem
        
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
        
        container.services.verify(as: .basket)
    }
    
    func test_givenBasketWithItem_whenBasketUpdatedToEmptyBasketItems_thenBasketQuantityAndBasketLineIdIsCleared() {
        let price = RetailStoreMenuItemPrice(price: 10, fromPrice: 0, unitMetric: "", unitsInPack: 0, unitVolume: 0, wasPrice: nil)
        let menuItem = RetailStoreMenuItem(id: 123, name: "", eposCode: nil, outOfStock: false, ageRestriction: 0, description: "", quickAdd: true, acceptCustomerInstructions: false, basketQuantityLimit: 500, price: price, images: nil, menuItemSizes: nil, menuItemOptions: nil, availableDeals: nil, itemCaptions: nil, mainCategory: MenuItemCategory.mockedData)
        let basketItem = BasketItem(basketLineId: 321, menuItem: menuItem, totalPrice: 10, totalPriceBeforeDiscounts: 10, price: 10, pricePaid: 10, quantity: 1, instructions: nil, size: nil, selectedOptions: nil, missedPromotions: nil)
        let basketWithItem = Basket(basketToken: "213ouihwefo", isNewBasket: false, items: [basketItem], fulfilmentMethod: BasketFulfilmentMethod(type: .delivery, cost: 2.5, minSpend: 10), selectedSlot: nil, savings: nil, coupon: nil, fees: nil, tips: nil, addresses: nil, orderSubtotal: 0, orderTotal: 0, storeId: nil, basketItemRemoved: nil)
        let appState = AppState(system: AppState.System(), routing: AppState.ViewRouting(), userData: .init(selectedStore: .notRequested, selectedFulfilmentMethod: .delivery, searchResult: .notRequested, basket: basketWithItem, memberProfile: nil))
        let sut = makeSUT(container: DIContainer(appState: appState, eventLogger: MockedEventLogger(), services: .mocked()), menuItem: menuItem)
        
        let expectation1 = expectation(description: "basketQuantity")
        let expectation2 = expectation(description: "basketQuantity")
        var cancellables = Set<AnyCancellable>()
        
        sut.$basketQuantity
            .first()
            .receive(on: RunLoop.main)
            .sink { _ in
                expectation1.fulfill()
            }
            .store(in: &cancellables)
        
        wait(for: [expectation1], timeout: 2)
        
        XCTAssertEqual(sut.basketQuantity, 1)
        XCTAssertEqual(sut.basketItem, basketItem)
        
        let basketEmpty = Basket(basketToken: "213ouihwefo", isNewBasket: false, items: [], fulfilmentMethod: BasketFulfilmentMethod(type: .delivery, cost: 2.5, minSpend: 10), selectedSlot: nil, savings: nil, coupon: nil, fees: nil, tips: nil, addresses: nil, orderSubtotal: 0, orderTotal: 0, storeId: nil, basketItemRemoved: nil)
        
        sut.container.appState.value.userData.basket = basketEmpty
        
        sut.$basketQuantity
            .first()
            .receive(on: RunLoop.main)
            .sink { _ in
                expectation2.fulfill()
            }
            .store(in: &cancellables)
        
        wait(for: [expectation2], timeout: 2)
        
        XCTAssertEqual(sut.basketQuantity, 0)
        XCTAssertNil(sut.basketItem)
    }
    
    func test_givenBasketWithTwo_whenBasketUpdatedWithOnlyOneOtherItem_thenBasketQuantityAndBasketLineIdIsCleared() {
        let price = RetailStoreMenuItemPrice(price: 10, fromPrice: 0, unitMetric: "", unitsInPack: 0, unitVolume: 0, wasPrice: nil)
        let menuItem1 = RetailStoreMenuItem(id: 123, name: "", eposCode: nil, outOfStock: false, ageRestriction: 0, description: "", quickAdd: true, acceptCustomerInstructions: false, basketQuantityLimit: 500, price: price, images: nil, menuItemSizes: nil, menuItemOptions: nil, availableDeals: nil, itemCaptions: nil, mainCategory: MenuItemCategory.mockedData)
        let menuItem2 = RetailStoreMenuItem(id: 234, name: "", eposCode: nil, outOfStock: false, ageRestriction: 0, description: "", quickAdd: true, acceptCustomerInstructions: false, basketQuantityLimit: 500, price: price, images: nil, menuItemSizes: nil, menuItemOptions: nil, availableDeals: nil, itemCaptions: nil, mainCategory: MenuItemCategory.mockedData)
        let basketItem1 = BasketItem(basketLineId: 321, menuItem: menuItem1, totalPrice: 10, totalPriceBeforeDiscounts: 10, price: 10, pricePaid: 10, quantity: 1, instructions: nil, size: nil, selectedOptions: nil, missedPromotions: nil)
        let basketItem2 = BasketItem(basketLineId: 432, menuItem: menuItem2, totalPrice: 10, totalPriceBeforeDiscounts: 10, price: 10, pricePaid: 10, quantity: 1, instructions: nil, size: nil, selectedOptions: nil, missedPromotions: nil)
        let basketWithTwoItems = Basket(basketToken: "213ouihwefo", isNewBasket: false, items: [basketItem1, basketItem2], fulfilmentMethod: BasketFulfilmentMethod(type: .delivery, cost: 2.5, minSpend: 10), selectedSlot: nil, savings: nil, coupon: nil, fees: nil, tips: nil, addresses: nil, orderSubtotal: 0, orderTotal: 0, storeId: nil, basketItemRemoved: nil)
        let appState = AppState(system: AppState.System(), routing: AppState.ViewRouting(), userData: .init(selectedStore: .notRequested, selectedFulfilmentMethod: .delivery, searchResult: .notRequested, basket: basketWithTwoItems, memberProfile: nil))
        let sut = makeSUT(container: DIContainer(appState: appState, eventLogger: MockedEventLogger(), services: .mocked()), menuItem: menuItem1)
        
        let expectation1 = expectation(description: "basketQuantity")
        let expectation2 = expectation(description: "basketQuantity")
        var cancellables = Set<AnyCancellable>()
        
        sut.$basketQuantity
            .first()
            .receive(on: RunLoop.main)
            .sink { _ in
                expectation1.fulfill()
            }
            .store(in: &cancellables)
        
        wait(for: [expectation1], timeout: 2)
        
        XCTAssertEqual(sut.basketQuantity, 1)
        XCTAssertEqual(sut.basketItem, basketItem1)
        XCTAssertEqual(sut.container.appState.value.userData.basket?.items.count, 2)
        
        let basketWithOneItem = Basket(basketToken: "213ouihwefo", isNewBasket: false, items: [basketItem2], fulfilmentMethod: BasketFulfilmentMethod(type: .delivery, cost: 2.5, minSpend: 10), selectedSlot: nil, savings: nil, coupon: nil, fees: nil, tips: nil, addresses: nil, orderSubtotal: 0, orderTotal: 0, storeId: nil, basketItemRemoved: nil)
        
        sut.container.appState.value.userData.basket = basketWithOneItem
        
        sut.$basketQuantity
            .first()
            .receive(on: RunLoop.main)
            .sink { _ in
                expectation2.fulfill()
            }
            .store(in: &cancellables)
        
        wait(for: [expectation2], timeout: 2)
        
        XCTAssertEqual(sut.basketQuantity, 0)
        XCTAssertNil(sut.basketItem)
        XCTAssertEqual(sut.container.appState.value.userData.basket?.items.count, 1)
    }
    
    func test_givenBasketWithItemOf2Quantity_thenQuantityShows2() {
        let price = RetailStoreMenuItemPrice(price: 10, fromPrice: 0, unitMetric: "", unitsInPack: 0, unitVolume: 0, wasPrice: nil)
        let menuItem = RetailStoreMenuItem(id: 123, name: "", eposCode: nil, outOfStock: false, ageRestriction: 0, description: "", quickAdd: true, acceptCustomerInstructions: false, basketQuantityLimit: 500, price: price, images: nil, menuItemSizes: nil, menuItemOptions: nil, availableDeals: nil, itemCaptions: nil, mainCategory: MenuItemCategory.mockedData)
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
        
        let basketItem = BasketItem(basketLineId: 45, menuItem: menuItem, totalPrice: 10, totalPriceBeforeDiscounts: 10, price: 5, pricePaid: 10, quantity: 2, instructions: nil, size: nil, selectedOptions: nil, missedPromotions: nil)
        sut.container.appState.value.userData.basket = Basket(basketToken: "", isNewBasket: false, items: [basketItem], fulfilmentMethod: BasketFulfilmentMethod(type: .delivery, cost: 2.5, minSpend: 10), selectedSlot: nil, savings: nil, coupon: nil, fees: nil, tips: nil, addresses: nil, orderSubtotal: 0, orderTotal: 0, storeId: nil, basketItemRemoved: nil)
        
        wait(for: [expectation], timeout: 5)
        
        XCTAssertEqual(sut.basketQuantity, 2)
    }
    
    func test_whenAddItemsWithOptionsTapped_thenShowOptionsIsTrue() {
        let price = RetailStoreMenuItemPrice(price: 10, fromPrice: 0, unitMetric: "", unitsInPack: 0, unitVolume: 0, wasPrice: nil)
        let menuItem = RetailStoreMenuItem(id: 123, name: "", eposCode: nil, outOfStock: false, ageRestriction: 0, description: "", quickAdd: true, acceptCustomerInstructions: false, basketQuantityLimit: 500, price: price, images: nil, menuItemSizes: nil, menuItemOptions: nil, availableDeals: nil, itemCaptions: nil, mainCategory: MenuItemCategory.mockedData)
        let sut = makeSUT(menuItem: menuItem)
        
        sut.addItemWithOptionsTapped()
        
        XCTAssertTrue(sut.showOptions)
    }
    
    func test_givenItemWithLimitAndQuantityAtLimit_thenQuantityLimitReachedIsTrue() {
        let item = RetailStoreMenuItem(id: 123, name: "", eposCode: nil, outOfStock: false, ageRestriction: 0, description: nil, quickAdd: true, acceptCustomerInstructions: true, basketQuantityLimit: 3, price: RetailStoreMenuItemPrice(price: 10, fromPrice: 10, unitMetric: "", unitsInPack: 0, unitVolume: 1, wasPrice: nil), images: nil, menuItemSizes: nil, menuItemOptions: nil, availableDeals: nil, itemCaptions: nil, mainCategory: MenuItemCategory.mockedData)
        let basketItem = BasketItem(basketLineId: 32, menuItem: item, totalPrice: 10, totalPriceBeforeDiscounts: 10, price: 10, pricePaid: 10, quantity: 3, instructions: nil, size: nil, selectedOptions: nil, missedPromotions: nil)
        let basket = Basket(basketToken: "", isNewBasket: true, items: [basketItem], fulfilmentMethod: BasketFulfilmentMethod(type: .delivery, cost: 2, minSpend: 10), selectedSlot: nil, savings: nil, coupon: nil, fees: nil, tips: nil, addresses: nil, orderSubtotal: 10, orderTotal: 10, storeId: nil, basketItemRemoved: nil)
        let userData = AppState.UserData(selectedStore: .notRequested, selectedFulfilmentMethod: .delivery, searchResult: .notRequested, basket: basket, currentFulfilmentLocation: nil, tempTodayTimeSlot: nil, basketDeliveryAddress: nil, memberProfile: nil)
        let appState = AppState(system: AppState.System(), routing: AppState.ViewRouting(), businessData: AppState.BusinessData(), userData: userData)
        let container = DIContainer(appState: appState, eventLogger: MockedEventLogger(), services: .mocked())
        let sut = makeSUT(container: container, menuItem: item)
        
        let exp = expectation(description: "basketQuantity")
        var cancellables = Set<AnyCancellable>()
        
        sut.$basketQuantity
            .first()
            .receive(on: RunLoop.main)
            .sink { _ in
                exp.fulfill()
            }
            .store(in: &cancellables)
        
        wait(for: [exp], timeout: 2)
        
        XCTAssertTrue(sut.quantityLimitReached)
    }
    
    func test_givenItemWithLimitAndQuantityIsBelowLimit_thenQuantityLimitReachedIsFalse() {
        let item = RetailStoreMenuItem(id: 123, name: "", eposCode: nil, outOfStock: false, ageRestriction: 0, description: nil, quickAdd: true, acceptCustomerInstructions: true, basketQuantityLimit: 3, price: RetailStoreMenuItemPrice(price: 10, fromPrice: 10, unitMetric: "", unitsInPack: 0, unitVolume: 1, wasPrice: nil), images: nil, menuItemSizes: nil, menuItemOptions: nil, availableDeals: nil, itemCaptions: nil, mainCategory: MenuItemCategory.mockedData)
        let basketItem = BasketItem(basketLineId: 32, menuItem: item, totalPrice: 10, totalPriceBeforeDiscounts: 10, price: 10, pricePaid: 10, quantity: 2, instructions: nil, size: nil, selectedOptions: nil, missedPromotions: nil)
        let basket = Basket(basketToken: "", isNewBasket: true, items: [basketItem], fulfilmentMethod: BasketFulfilmentMethod(type: .delivery, cost: 2, minSpend: 10), selectedSlot: nil, savings: nil, coupon: nil, fees: nil, tips: nil, addresses: nil, orderSubtotal: 10, orderTotal: 10, storeId: nil, basketItemRemoved: nil)
        let userData = AppState.UserData(selectedStore: .notRequested, selectedFulfilmentMethod: .delivery, searchResult: .notRequested, basket: basket, currentFulfilmentLocation: nil, tempTodayTimeSlot: nil, basketDeliveryAddress: nil, memberProfile: nil)
        let appState = AppState(system: AppState.System(), routing: AppState.ViewRouting(), businessData: AppState.BusinessData(), userData: userData)
        let container = DIContainer(appState: appState, eventLogger: MockedEventLogger(), services: .mocked())
        let sut = makeSUT(container: container, menuItem: item)
        
        let exp = expectation(description: "basketQuantity")
        var cancellables = Set<AnyCancellable>()
        
        sut.$basketQuantity
            .first()
            .receive(on: RunLoop.main)
            .sink { _ in
                exp.fulfill()
            }
            .store(in: &cancellables)
        
        wait(for: [exp], timeout: 2)
        
        XCTAssertFalse(sut.quantityLimitReached)
    }
    
    func test_givenItemWithLimitZeroAndQuantityIsZero_thenQuantityLimitReachedIsFalse() {
        let item = RetailStoreMenuItem(id: 123, name: "", eposCode: nil, outOfStock: false, ageRestriction: 0, description: nil, quickAdd: true, acceptCustomerInstructions: true, basketQuantityLimit: 0, price: RetailStoreMenuItemPrice(price: 10, fromPrice: 10, unitMetric: "", unitsInPack: 0, unitVolume: 1, wasPrice: nil), images: nil, menuItemSizes: nil, menuItemOptions: nil, availableDeals: nil, itemCaptions: nil, mainCategory: MenuItemCategory.mockedData)
        let basketItem = BasketItem(basketLineId: 32, menuItem: item, totalPrice: 10, totalPriceBeforeDiscounts: 10, price: 10, pricePaid: 10, quantity: 2, instructions: nil, size: nil, selectedOptions: nil, missedPromotions: nil)
        let basket = Basket(basketToken: "", isNewBasket: true, items: [basketItem], fulfilmentMethod: BasketFulfilmentMethod(type: .delivery, cost: 2, minSpend: 10), selectedSlot: nil, savings: nil, coupon: nil, fees: nil, tips: nil, addresses: nil, orderSubtotal: 10, orderTotal: 10, storeId: nil, basketItemRemoved: nil)
        let userData = AppState.UserData(selectedStore: .notRequested, selectedFulfilmentMethod: .delivery, searchResult: .notRequested, basket: basket, currentFulfilmentLocation: nil, tempTodayTimeSlot: nil, basketDeliveryAddress: nil, memberProfile: nil)
        let appState = AppState(system: AppState.System(), routing: AppState.ViewRouting(), businessData: AppState.BusinessData(), userData: userData)
        let container = DIContainer(appState: appState, eventLogger: MockedEventLogger(), services: .mocked())
        let sut = makeSUT(container: container, menuItem: item)
        
        let exp = expectation(description: "basketQuantity")
        var cancellables = Set<AnyCancellable>()
        
        sut.$basketQuantity
            .first()
            .receive(on: RunLoop.main)
            .sink { _ in
                exp.fulfill()
            }
            .store(in: &cancellables)
        
        wait(for: [exp], timeout: 2)
        
        XCTAssertFalse(sut.quantityLimitReached)
    }

    func makeSUT(container: DIContainer = DIContainer(appState: AppState(), eventLogger: MockedEventLogger(), services: .mocked()), menuItem: RetailStoreMenuItem) -> ProductAddButtonViewModel {
        let sut = ProductAddButtonViewModel(container: container, menuItem: menuItem)
        
        trackForMemoryLeaks(sut)
        
        return sut
    }
}
