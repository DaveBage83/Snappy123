//
//  ProductIncrementButtonViewModelTests.swift
//  SnappyV2Tests
//
//  Created by Henrik Gustavii on 18/01/2022.
//

import XCTest
import Combine
import AppsFlyerLib
@testable import SnappyV2

@MainActor
class ProductIncrementButtonViewModelTests: XCTestCase {
    
    func test_init() {
        let price = RetailStoreMenuItemPrice(price: 10, fromPrice: 0, unitMetric: "", unitsInPack: 0, unitVolume: 0, wasPrice: nil)
        let menuItem = RetailStoreMenuItem(id: 123, name: "", eposCode: nil, outOfStock: false, ageRestriction: 0, description: "", quickAdd: true, acceptCustomerInstructions: false, basketQuantityLimit: 0, price: price, images: nil, menuItemSizes: nil, menuItemOptions: nil, availableDeals: nil, itemCaptions: nil, mainCategory: MenuItemCategory.mockedData, itemDetails: nil, deal: nil)
        let sut = makeSUT(menuItem: menuItem)
        
        XCTAssertEqual(sut.item, menuItem)
        XCTAssertNil(sut.basket)
        XCTAssertTrue(sut.quickAddIsEnabled)
        XCTAssertFalse(sut.hasAgeRestriction)
        XCTAssertFalse(sut.isUpdatingQuantity)
        XCTAssertEqual(sut.basketQuantity, 0)
        XCTAssertNil(sut.optionsShown)
        XCTAssertFalse(sut.quantityLimitReached)
    }
    
    func test_whenAddOrRemoveTapped_thenInteractionLoggerHandlerCalled() async {
        let price = RetailStoreMenuItemPrice(price: 10, fromPrice: 0, unitMetric: "", unitsInPack: 0, unitVolume: 0, wasPrice: nil)
        let menuItem = RetailStoreMenuItem(id: 123, name: "", eposCode: nil, outOfStock: false, ageRestriction: 0, description: "", quickAdd: true, acceptCustomerInstructions: false, basketQuantityLimit: 0, price: price, images: nil, menuItemSizes: nil, menuItemOptions: nil, availableDeals: nil, itemCaptions: nil, mainCategory: MenuItemCategory.mockedData, itemDetails: nil, deal: nil)
        
        var handlerCallCount = 0
        let sut = makeSUT(menuItem: menuItem) { item in
            XCTAssertEqual(item, menuItem)
            handlerCallCount += 1
        }
        
        await sut.addItem()
        sut.removeItem()
        
        XCTAssertEqual(handlerCallCount, 2)
    }
    
    func test_whenBasketQuantityIs1_thenShowDeleteButtonIsTrue() {
        let sut = makeSUT(menuItem: RetailStoreMenuItem.mockedData)
        sut.basketQuantity = 1
        
        XCTAssertTrue(sut.showDeleteButton)
    }
    
    func test_whenAgeIsMoreThanZero_thenHasAgeRestrictionIsTrue() {
        let price = RetailStoreMenuItemPrice(price: 10, fromPrice: 0, unitMetric: "", unitsInPack: 0, unitVolume: 0, wasPrice: nil)
        let menuItem = RetailStoreMenuItem(id: 123, name: "", eposCode: nil, outOfStock: false, ageRestriction: 18, description: "", quickAdd: true, acceptCustomerInstructions: false, basketQuantityLimit: 500, price: price, images: nil, menuItemSizes: nil, menuItemOptions: nil, availableDeals: nil, itemCaptions: nil, mainCategory: MenuItemCategory.mockedData, itemDetails: nil, deal: nil)
        let sut = makeSUT(menuItem: menuItem)
        
        XCTAssertTrue(sut.hasAgeRestriction)
    }
    
    func test_givenUserHasNotConfirmedAge_whenAgeRestrictedItemIsAdded_thenAgeConfirmationAlertDisplayed() async {
        let price = RetailStoreMenuItemPrice(price: 10, fromPrice: 0, unitMetric: "", unitsInPack: 0, unitVolume: 0, wasPrice: nil)
        let menuItem = RetailStoreMenuItem(id: 123, name: "", eposCode: nil, outOfStock: false, ageRestriction: 18, description: "", quickAdd: true, acceptCustomerInstructions: false, basketQuantityLimit: 500, price: price, images: nil, menuItemSizes: nil, menuItemOptions: nil, availableDeals: nil, itemCaptions: nil, mainCategory: MenuItemCategory.mockedData, itemDetails: nil, deal: nil)
        
        let container = DIContainer(appState: AppState(), eventLogger: MockedEventLogger(), services: .mocked())
        
        let sut = makeSUT(container: container, menuItem: menuItem)
        await sut.addItem()
        
        XCTAssertEqual(sut.isDisplayingAgeAlert, true)
    }
    
    func test_whenUserConfirmedAgeCalled_thenConfirmedAgeIsSet() async {
        let price = RetailStoreMenuItemPrice(price: 10, fromPrice: 0, unitMetric: "", unitsInPack: 0, unitVolume: 0, wasPrice: nil)
        let menuItem = RetailStoreMenuItem(id: 123, name: "", eposCode: nil, outOfStock: false, ageRestriction: 18, description: "", quickAdd: true, acceptCustomerInstructions: false, basketQuantityLimit: 500, price: price, images: nil, menuItemSizes: nil, menuItemOptions: nil, availableDeals: nil, itemCaptions: nil, mainCategory: MenuItemCategory.mockedData, itemDetails: nil, deal: nil)
        let container = DIContainer(appState: AppState(), eventLogger: MockedEventLogger(), services: .mocked())
        
        let sut = makeSUT(container: container, menuItem: menuItem)
        await sut.userConfirmedAge()
        
        let appStateAge = sut.container.appState.value.userData.confirmedAge
        
        XCTAssertEqual(18, appStateAge)
    }
    
    func test_whenAddItemCalled_thenQuantityIncreases() async {
        let price = RetailStoreMenuItemPrice(price: 10, fromPrice: 0, unitMetric: "", unitsInPack: 0, unitVolume: 0, wasPrice: nil)
        let menuItem = RetailStoreMenuItem(id: 123, name: "", eposCode: nil, outOfStock: false, ageRestriction: 0, description: "", quickAdd: true, acceptCustomerInstructions: false, basketQuantityLimit: 500, price: price, images: nil, menuItemSizes: nil, menuItemOptions: nil, availableDeals: nil, itemCaptions: nil, mainCategory: MenuItemCategory.mockedData, itemDetails: nil, deal: nil)
        let sut = makeSUT(menuItem: menuItem)
        
        await sut.addItem()
        
        XCTAssertEqual(sut.changeQuantity, 1)
    }
    
    func test_whenRemoveItemCalled_thenQuantityDecreases() {
        let price = RetailStoreMenuItemPrice(price: 10, fromPrice: 0, unitMetric: "", unitsInPack: 0, unitVolume: 0, wasPrice: nil)
        let menuItem = RetailStoreMenuItem(id: 123, name: "", eposCode: nil, outOfStock: false, ageRestriction: 0, description: "", quickAdd: true, acceptCustomerInstructions: false, basketQuantityLimit: 500, price: price, images: nil, menuItemSizes: nil, menuItemOptions: nil, availableDeals: nil, itemCaptions: nil, mainCategory: MenuItemCategory.mockedData, itemDetails: nil, deal: nil)
        let sut = makeSUT(menuItem: menuItem)
        
        sut.removeItem()
        
        XCTAssertEqual(sut.changeQuantity, -1)
    }
    
    #warning("These tests fail with Xcode 14 when using async Tasks")
//    func test_givenZeroBasketQuantity_whenAddItemTapped_thenAddItemServiceIsTriggeredAndIsCorrect() async {
//        let price = RetailStoreMenuItemPrice(price: 10, fromPrice: 0, unitMetric: "", unitsInPack: 0, unitVolume: 0, wasPrice: nil)
//        let menuItem = RetailStoreMenuItem(id: 123, name: "", eposCode: "23423", outOfStock: false, ageRestriction: 0, description: "", quickAdd: true, acceptCustomerInstructions: false, basketQuantityLimit: 500, price: price, images: nil, menuItemSizes: nil, menuItemOptions: nil, availableDeals: nil, itemCaptions: nil, mainCategory: MenuItemCategory.mockedData, itemDetails: nil, deal: nil)
//        let container = DIContainer(appState: AppState(), eventLogger: MockedEventLogger(), services: .mocked(basketService: [.addItem(basketItemRequest: BasketItemRequest(menuItemId: menuItem.id, quantity: 1, sizeId: 0, bannerAdvertId: 0, options: [], instructions: nil), item: menuItem)]))
//        let sut = makeSUT(container: container, menuItem: menuItem)
//
//        let expectation = expectation(description: #function)
//        var cancellables = Set<AnyCancellable>()
//
//        sut.$isUpdatingQuantity
//            .first()
//            .receive(on: RunLoop.main)
//            .sink { _ in
//                expectation.fulfill()
//            }
//            .store(in: &cancellables)
//
//        await sut.addItem()
//        let _ = await sut.updateBasketTask?.result
//
//        wait(for: [expectation], timeout: 2)
//
//        XCTAssertFalse(sut.isUpdatingQuantity)
//
//        container.services.verify(as: .basket)
//    }
//
//    func test_givenBasketQuantity1_whenAddItemTapped_thenUpdateItemServiceIsTriggeredAndIsCorrect() async {
//        let basketItem = BasketItem.mockedData
//        let container = DIContainer(appState: AppState(), eventLogger: MockedEventLogger(), services: .mocked(basketService: [.updateItem(basketItemRequest: BasketItemRequest(menuItemId: basketItem.menuItem.id, quantity: 2, sizeId: 0, bannerAdvertId: 0, options: [], instructions: nil), basketItem: basketItem)]))
//
//        let menuItem = basketItem.menuItem
//        let sut = makeSUT(container: container, menuItem: menuItem)
//        sut.basketQuantity = 1
//        sut.basketItem = basketItem
//
//        let expectation = expectation(description: "setupItemQuantityChange")
//        var cancellables = Set<AnyCancellable>()
//
//        sut.$isUpdatingQuantity
//            .collect(3)
//            .receive(on: RunLoop.main)
//            .sink { _ in
//                expectation.fulfill()
//            }
//            .store(in: &cancellables)
//
//        await sut.addItem()
//
//        wait(for: [expectation], timeout: 2)
//
//        XCTAssertFalse(sut.isUpdatingQuantity)
//
//        container.services.verify(as: .basket)
//    }
    
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
            .collect(3)
            .receive(on: RunLoop.main)
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        sut.removeItem()
        
        wait(for: [expectation], timeout: 2)
        
        XCTAssertFalse(sut.isUpdatingQuantity)
        
        container.services.verify(as: .basket)
    }
    
    func test_givenBasketQuantity1ComplexItem_whenRemoveItemTapped_thenUpdateItemServiceIsTriggeredAndIsCorrect() {
        let basketItem = BasketItem.mockedDataComplex
        let menuItem = basketItem.menuItem
        let container = DIContainer(appState: AppState(), eventLogger: MockedEventLogger(), services: .mocked(basketService: [.removeItem(basketLineId: basketItem.basketLineId, item: menuItem)]))
        let sut = makeSUT(container: container, menuItem: menuItem)
        sut.basketQuantity = 1
        sut.basketItem = basketItem
        
        let expectation = expectation(description: "setupItemQuantityChange")
        var cancellables = Set<AnyCancellable>()
        
        sut.$isUpdatingQuantity
            .collect(3)
            .receive(on: RunLoop.main)
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        sut.removeItem()
        
        wait(for: [expectation], timeout: 2)
        
        XCTAssertFalse(sut.isUpdatingQuantity)
        
        container.services.verify(as: .basket)
    }
    
    func test_givenBasketQuantity2OfSimilarComplexItem_whenRemoveItemTapped_thenUpdateItemServiceIsNotTriggeredAndShowMultipleComplexItemsAlertIsTrue() {
        let basketItem = BasketItem.mockedDataComplex
        let menuItem = basketItem.menuItem
        let container = DIContainer(appState: AppState(), eventLogger: MockedEventLogger(), services: .mocked())
        let sut = makeSUT(container: container, menuItem: menuItem)
        sut.basketQuantity = 2
        sut.basketItem = basketItem
        
        sut.removeItem()
        
        XCTAssertFalse(sut.isUpdatingQuantity)
        XCTAssertTrue(sut.showMultipleComplexItemsAlert)
        
        container.services.verify(as: .basket)
    }
    
    func test_givenBasketWithItem_whenBasketUpdatedToEmptyBasketItems_thenBasketQuantityAndBasketLineIdIsCleared() {
        let price = RetailStoreMenuItemPrice(price: 10, fromPrice: 0, unitMetric: "", unitsInPack: 0, unitVolume: 0, wasPrice: nil)
        let menuItem = RetailStoreMenuItem(id: 123, name: "", eposCode: nil, outOfStock: false, ageRestriction: 0, description: "", quickAdd: true, acceptCustomerInstructions: false, basketQuantityLimit: 500, price: price, images: nil, menuItemSizes: nil, menuItemOptions: nil, availableDeals: nil, itemCaptions: nil, mainCategory: MenuItemCategory.mockedData, itemDetails: nil, deal: nil)
        let basketItem = BasketItem(basketLineId: 321, menuItem: menuItem, totalPrice: 10, totalPriceBeforeDiscounts: 10, price: 10, pricePaid: 10, quantity: 1, instructions: nil, size: nil, selectedOptions: nil, missedPromotions: nil, isAlcohol: false)

        let basketWithItem = Basket(
            basketToken: "nejnsfkj",
            isNewBasket: false,
            items: [basketItem],
            fulfilmentMethod: .init(
                type: .delivery,
                cost: 2.5,
                minSpend: 10,
                zoneFreeDeliveryMessage: nil,
                minBasketSpendForNextDeliveryTier: nil,
                nextTierSpendIsHigherThanCurrent: false,
                minAdditionalBasketSpendForNextTier: nil,
                nextTierDeliveryCost: nil),
            selectedSlot: nil,
            savings: nil,
            coupon: nil,
            fees: nil,
            tips: nil,
            addresses: nil,
            orderSubtotal: 0,
            orderTotal: 0,
            storeId: nil,
            basketItemRemoved: nil)
        
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

        let basketEmpty = Basket(
            basketToken: "nejnsfkj",
            isNewBasket: false,
            items: [],
            fulfilmentMethod: .init(
                type: .delivery,
                cost: 2.5,
                minSpend: 10,
                zoneFreeDeliveryMessage: nil,
                minBasketSpendForNextDeliveryTier: nil,
                nextTierSpendIsHigherThanCurrent: false,
                minAdditionalBasketSpendForNextTier: nil,
                nextTierDeliveryCost: nil),
            selectedSlot: nil,
            savings: nil,
            coupon: nil,
            fees: nil,
            tips: nil,
            addresses: nil,
            orderSubtotal: 0,
            orderTotal: 0,
            storeId: nil,
            basketItemRemoved: nil)
        
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
        let menuItem1 = RetailStoreMenuItem(id: 123, name: "", eposCode: nil, outOfStock: false, ageRestriction: 0, description: "", quickAdd: true, acceptCustomerInstructions: false, basketQuantityLimit: 500, price: price, images: nil, menuItemSizes: nil, menuItemOptions: nil, availableDeals: nil, itemCaptions: nil, mainCategory: MenuItemCategory.mockedData, itemDetails: nil, deal: nil)
        let menuItem2 = RetailStoreMenuItem(id: 234, name: "", eposCode: nil, outOfStock: false, ageRestriction: 0, description: "", quickAdd: true, acceptCustomerInstructions: false, basketQuantityLimit: 500, price: price, images: nil, menuItemSizes: nil, menuItemOptions: nil, availableDeals: nil, itemCaptions: nil, mainCategory: MenuItemCategory.mockedData, itemDetails: nil, deal: nil)
        let basketItem1 = BasketItem(basketLineId: 321, menuItem: menuItem1, totalPrice: 10, totalPriceBeforeDiscounts: 10, price: 10, pricePaid: 10, quantity: 1, instructions: nil, size: nil, selectedOptions: nil, missedPromotions: nil, isAlcohol: false)
        let basketItem2 = BasketItem(basketLineId: 432, menuItem: menuItem2, totalPrice: 10, totalPriceBeforeDiscounts: 10, price: 10, pricePaid: 10, quantity: 1, instructions: nil, size: nil, selectedOptions: nil, missedPromotions: nil, isAlcohol: false)

        let basketWithTwoItems = Basket(
            basketToken: "nejnsfkj",
            isNewBasket: false,
            items: [basketItem1, basketItem2],
            fulfilmentMethod: .init(
                type: .delivery,
                cost: 2.5,
                minSpend: 10,
                zoneFreeDeliveryMessage: nil,
                minBasketSpendForNextDeliveryTier: nil,
                nextTierSpendIsHigherThanCurrent: false,
                minAdditionalBasketSpendForNextTier: nil,
                nextTierDeliveryCost: nil),
            selectedSlot: nil,
            savings: nil,
            coupon: nil,
            fees: nil,
            tips: nil,
            addresses: nil,
            orderSubtotal: 0,
            orderTotal: 0,
            storeId: nil,
            basketItemRemoved: nil)
        
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

        let basketWithOneItem = Basket(
            basketToken: "nejnsfkj",
            isNewBasket: false,
            items: [basketItem2],
            fulfilmentMethod: .init(
                type: .delivery,
                cost: 2.5,
                minSpend: 10,
                zoneFreeDeliveryMessage: nil,
                minBasketSpendForNextDeliveryTier: nil,
                nextTierSpendIsHigherThanCurrent: false,
                minAdditionalBasketSpendForNextTier: nil,
                nextTierDeliveryCost: nil),
            selectedSlot: nil,
            savings: nil,
            coupon: nil,
            fees: nil,
            tips: nil,
            addresses: nil,
            orderSubtotal: 0,
            orderTotal: 0,
            storeId: nil,
            basketItemRemoved: nil)
        
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
        let menuItem = RetailStoreMenuItem(id: 123, name: "", eposCode: nil, outOfStock: false, ageRestriction: 0, description: "", quickAdd: true, acceptCustomerInstructions: false, basketQuantityLimit: 500, price: price, images: nil, menuItemSizes: nil, menuItemOptions: nil, availableDeals: nil, itemCaptions: nil, mainCategory: MenuItemCategory.mockedData, itemDetails: nil, deal: nil)
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
        
        let basketItem = BasketItem(basketLineId: 45, menuItem: menuItem, totalPrice: 10, totalPriceBeforeDiscounts: 10, price: 5, pricePaid: 10, quantity: 2, instructions: nil, size: nil, selectedOptions: nil, missedPromotions: nil, isAlcohol: false)
        
        let basket = Basket(
            basketToken: "nejnsfkj",
            isNewBasket: false,
            items: [basketItem],
            fulfilmentMethod: .init(
                type: .delivery,
                cost: 2.5,
                minSpend: 10,
                zoneFreeDeliveryMessage: nil,
                minBasketSpendForNextDeliveryTier: nil,
                nextTierSpendIsHigherThanCurrent: false,
                minAdditionalBasketSpendForNextTier: nil,
                nextTierDeliveryCost: nil),
            selectedSlot: nil,
            savings: nil,
            coupon: nil,
            fees: nil,
            tips: nil,
            addresses: nil,
            orderSubtotal: 0,
            orderTotal: 0,
            storeId: nil,
            basketItemRemoved: nil)
        
        sut.container.appState.value.userData.basket = basket
        
        wait(for: [expectation], timeout: 2)
        
        XCTAssertEqual(sut.basketQuantity, 2)
    }
    
    func test_givenBasketWith2OfSameComplexItemWithDifferentComplexities_thenQuantityShows2() {
        let price = RetailStoreMenuItemPrice(price: 10, fromPrice: 0, unitMetric: "", unitsInPack: 0, unitVolume: 0, wasPrice: nil)
        let menuItem = RetailStoreMenuItem(id: 123, name: "", eposCode: nil, outOfStock: false, ageRestriction: 0, description: "", quickAdd: true, acceptCustomerInstructions: false, basketQuantityLimit: 500, price: price, images: nil, menuItemSizes: [RetailStoreMenuItemSize(id: 456, name: "Large", price: MenuItemSizePrice(price: 12)), RetailStoreMenuItemSize(id: 567, name: "Small", price: MenuItemSizePrice(price: 10))], menuItemOptions: nil, availableDeals: nil, itemCaptions: nil, mainCategory: MenuItemCategory.mockedData, itemDetails: nil, deal: nil)
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
        
        let basketItem1 = BasketItem(basketLineId: 45, menuItem: menuItem, totalPrice: 10, totalPriceBeforeDiscounts: 10, price: 5, pricePaid: 10, quantity: 1, instructions: nil, size: BasketItemSelectedSize(id: 567, name: "Small"), selectedOptions: nil, missedPromotions: nil, isAlcohol: false)
        let basketItem2 = BasketItem(basketLineId: 46, menuItem: menuItem, totalPrice: 12, totalPriceBeforeDiscounts: 10, price: 5, pricePaid: 10, quantity: 1, instructions: nil, size: BasketItemSelectedSize(id: 456, name: "Large"), selectedOptions: nil, missedPromotions: nil, isAlcohol: false)
        
        let basket = Basket(
            basketToken: "nejnsfkj",
            isNewBasket: false,
            items: [basketItem1, basketItem2],
            fulfilmentMethod: .init(
                type: .delivery,
                cost: 2.5,
                minSpend: 10,
                zoneFreeDeliveryMessage: nil,
                minBasketSpendForNextDeliveryTier: nil,
                nextTierSpendIsHigherThanCurrent: false,
                minAdditionalBasketSpendForNextTier: nil,
                nextTierDeliveryCost: nil),
            selectedSlot: nil,
            savings: nil,
            coupon: nil,
            fees: nil,
            tips: nil,
            addresses: nil,
            orderSubtotal: 0,
            orderTotal: 0,
            storeId: nil,
            basketItemRemoved: nil)
        
        sut.container.appState.value.userData.basket = basket
        
        wait(for: [expectation], timeout: 2)
        
        XCTAssertEqual(sut.basketQuantity, 2)
    }
    
    func test_givenBasketWith2OfSameComplexItemWithDifferentComplexities_whenInBasket_thenQuantityShows2() async {
        let price = RetailStoreMenuItemPrice(price: 10, fromPrice: 0, unitMetric: "", unitsInPack: 0, unitVolume: 0, wasPrice: nil)
        let menuItem = RetailStoreMenuItem(id: 123, name: "", eposCode: nil, outOfStock: false, ageRestriction: 0, description: "", quickAdd: true, acceptCustomerInstructions: false, basketQuantityLimit: 500, price: price, images: nil, menuItemSizes: [RetailStoreMenuItemSize(id: 456, name: "Large", price: MenuItemSizePrice(price: 12)), RetailStoreMenuItemSize(id: 567, name: "Small", price: MenuItemSizePrice(price: 10))], menuItemOptions: nil, availableDeals: nil, itemCaptions: nil, mainCategory: MenuItemCategory.mockedData, itemDetails: nil, deal: nil)
        let sut = makeSUT(menuItem: menuItem, isInBasket: true)
        
        let expectation = expectation(description: "setupBasketItemCheck")
        var cancellables = Set<AnyCancellable>()
        
        sut.$basketQuantity
            .first()
            .receive(on: RunLoop.main)
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        let basketItem1 = BasketItem(basketLineId: 45, menuItem: menuItem, totalPrice: 10, totalPriceBeforeDiscounts: 10, price: 5, pricePaid: 10, quantity: 1, instructions: nil, size: BasketItemSelectedSize(id: 567, name: "Small"), selectedOptions: nil, missedPromotions: nil, isAlcohol: false)
        let basketItem2 = BasketItem(basketLineId: 46, menuItem: menuItem, totalPrice: 12, totalPriceBeforeDiscounts: 10, price: 5, pricePaid: 10, quantity: 1, instructions: nil, size: BasketItemSelectedSize(id: 456, name: "Large"), selectedOptions: nil, missedPromotions: nil, isAlcohol: false)
        
        let basket = Basket(
            basketToken: "nejnsfkj",
            isNewBasket: false,
            items: [basketItem1, basketItem2],
            fulfilmentMethod: .init(
                type: .delivery,
                cost: 2.5,
                minSpend: 10,
                zoneFreeDeliveryMessage: nil,
                minBasketSpendForNextDeliveryTier: nil,
                nextTierSpendIsHigherThanCurrent: false,
                minAdditionalBasketSpendForNextTier: nil,
                nextTierDeliveryCost: nil),
            selectedSlot: nil,
            savings: nil,
            coupon: nil,
            fees: nil,
            tips: nil,
            addresses: nil,
            orderSubtotal: 0,
            orderTotal: 0,
            storeId: nil,
            basketItemRemoved: nil)
        
        sut.container.appState.value.userData.basket = basket
        
        wait(for: [expectation], timeout: 2)
        
        XCTAssertEqual(sut.basketQuantity, 1)
    }
    
    #warning("These tests fail with Xcode 14 when using async Tasks")
//    func test_givenAnItemWithOptions_whenAddItemsTriggered_thenShowOptionsIsTrue() async {
//        let price = RetailStoreMenuItemPrice(price: 10, fromPrice: 0, unitMetric: "", unitsInPack: 0, unitVolume: 0, wasPrice: nil)
//        let menuItem = RetailStoreMenuItem(id: 123, name: "", eposCode: nil, outOfStock: false, ageRestriction: 0, description: "", quickAdd: false, acceptCustomerInstructions: false, basketQuantityLimit: 500, price: price, images: nil, menuItemSizes: nil, menuItemOptions: nil, availableDeals: nil, itemCaptions: nil, mainCategory: MenuItemCategory.mockedData, itemDetails: nil)
//        let sut = makeSUT(menuItem: menuItem)
//
//        await sut.addItem()
//
//        XCTAssertEqual(sut.optionsShown, menuItem)
//    }
    
    func test_whenGoToBasketViewTriggered_thenAppStateSelectedTabIsCorrect() {
        let menuItem = RetailStoreMenuItem.mockedData
        let sut = makeSUT(menuItem: menuItem)
        
        sut.goToBasketView()
        
        XCTAssertEqual(sut.container.appState.value.routing.selectedTab, .basket)
    }
    
    func test_givenItemWithLimitAndQuantityAtLimit_thenQuantityLimitReachedIsTrue() {
        let item = RetailStoreMenuItem(id: 123, name: "", eposCode: nil, outOfStock: false, ageRestriction: 0, description: nil, quickAdd: true, acceptCustomerInstructions: true, basketQuantityLimit: 3, price: RetailStoreMenuItemPrice(price: 10, fromPrice: 10, unitMetric: "", unitsInPack: 0, unitVolume: 1, wasPrice: nil), images: nil, menuItemSizes: nil, menuItemOptions: nil, availableDeals: nil, itemCaptions: nil, mainCategory: MenuItemCategory.mockedData, itemDetails: nil, deal: nil)
        let basketItem = BasketItem(basketLineId: 32, menuItem: item, totalPrice: 10, totalPriceBeforeDiscounts: 10, price: 10, pricePaid: 10, quantity: 3, instructions: nil, size: nil, selectedOptions: nil, missedPromotions: nil, isAlcohol: false)
        
        let basket = Basket(
            basketToken: "nejnsfkj",
            isNewBasket: false,
            items: [basketItem],
            fulfilmentMethod: .init(
                type: .delivery,
                cost: 2,
                minSpend: 10,
                zoneFreeDeliveryMessage: nil,
                minBasketSpendForNextDeliveryTier: nil,
                nextTierSpendIsHigherThanCurrent: false,
                minAdditionalBasketSpendForNextTier: nil,
                nextTierDeliveryCost: nil),
            selectedSlot: nil,
            savings: nil,
            coupon: nil,
            fees: nil,
            tips: nil,
            addresses: nil,
            orderSubtotal: 10,
            orderTotal: 10,
            storeId: nil,
            basketItemRemoved: nil)

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
        let item = RetailStoreMenuItem(id: 123, name: "", eposCode: nil, outOfStock: false, ageRestriction: 0, description: nil, quickAdd: true, acceptCustomerInstructions: true, basketQuantityLimit: 3, price: RetailStoreMenuItemPrice(price: 10, fromPrice: 10, unitMetric: "", unitsInPack: 0, unitVolume: 1, wasPrice: nil), images: nil, menuItemSizes: nil, menuItemOptions: nil, availableDeals: nil, itemCaptions: nil, mainCategory: MenuItemCategory.mockedData, itemDetails: nil, deal: nil)
        let basketItem = BasketItem(basketLineId: 32, menuItem: item, totalPrice: 10, totalPriceBeforeDiscounts: 10, price: 10, pricePaid: 10, quantity: 2, instructions: nil, size: nil, selectedOptions: nil, missedPromotions: nil, isAlcohol: false)

        let basket = Basket(
            basketToken: "nejnsfkj",
            isNewBasket: false,
            items: [basketItem],
            fulfilmentMethod: .init(
                type: .delivery,
                cost: 2,
                minSpend: 10,
                zoneFreeDeliveryMessage: nil,
                minBasketSpendForNextDeliveryTier: nil,
                nextTierSpendIsHigherThanCurrent: false,
                minAdditionalBasketSpendForNextTier: nil,
                nextTierDeliveryCost: nil),
            selectedSlot: nil,
            savings: nil,
            coupon: nil,
            fees: nil,
            tips: nil,
            addresses: nil,
            orderSubtotal: 10,
            orderTotal: 10,
            storeId: nil,
            basketItemRemoved: nil)
        
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
        let item = RetailStoreMenuItem(id: 123, name: "", eposCode: nil, outOfStock: false, ageRestriction: 0, description: nil, quickAdd: true, acceptCustomerInstructions: true, basketQuantityLimit: 0, price: RetailStoreMenuItemPrice(price: 10, fromPrice: 10, unitMetric: "", unitsInPack: 0, unitVolume: 1, wasPrice: nil), images: nil, menuItemSizes: nil, menuItemOptions: nil, availableDeals: nil, itemCaptions: nil, mainCategory: MenuItemCategory.mockedData, itemDetails: nil, deal: nil)
        let basketItem = BasketItem(basketLineId: 32, menuItem: item, totalPrice: 10, totalPriceBeforeDiscounts: 10, price: 10, pricePaid: 10, quantity: 2, instructions: nil, size: nil, selectedOptions: nil, missedPromotions: nil, isAlcohol: false)

        let basket = Basket(
            basketToken: "nejnsfkj",
            isNewBasket: false,
            items: [basketItem],
            fulfilmentMethod: .init(
                type: .delivery,
                cost: 2,
                minSpend: 10,
                zoneFreeDeliveryMessage: nil,
                minBasketSpendForNextDeliveryTier: nil,
                nextTierSpendIsHigherThanCurrent: false,
                minAdditionalBasketSpendForNextTier: nil,
                nextTierDeliveryCost: nil),
            selectedSlot: nil,
            savings: nil,
            coupon: nil,
            fees: nil,
            tips: nil,
            addresses: nil,
            orderSubtotal: 10,
            orderTotal: 10,
            storeId: nil,
            basketItemRemoved: nil)
        
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

    func makeSUT(container: DIContainer = DIContainer(appState: AppState(), eventLogger: MockedEventLogger(), services: .mocked()), menuItem: RetailStoreMenuItem, isInBasket: Bool = false, interactionLoggerHandler: ((RetailStoreMenuItem)->())? = nil) -> ProductIncrementButtonViewModel {
        let sut = ProductIncrementButtonViewModel(container: container, menuItem: menuItem, isInBasket: isInBasket, interactionLoggerHandler: interactionLoggerHandler)
        
        trackForMemoryLeaks(sut)
        
        return sut
    }
}
