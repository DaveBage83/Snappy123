//
//  BasketViewModelTests.swift
//  SnappyV2Tests
//
//  Created by Henrik Gustavii on 23/12/2021.
//

import XCTest
import Combine
@testable import SnappyV2

class BasketViewModelTests: XCTestCase {
    
    func test_init() {
        let sut = makeSUT()
        
        XCTAssertEqual(sut.container.appState.value, AppState())
        XCTAssertNil(sut.basket)
        XCTAssertTrue(sut.couponCode.isEmpty)
        XCTAssertFalse(sut.applyingCoupon)
        XCTAssertFalse(sut.removingCoupon)
        XCTAssertFalse(sut.couponAppliedSuccessfully)
        XCTAssertFalse(sut.couponAppliedUnsuccessfully)
        XCTAssertFalse(sut.isUpdatingItem)
        XCTAssertFalse(sut.showingServiceFeeAlert)
        XCTAssertFalse(sut.isMemberSignedIn)
        XCTAssertFalse(sut.showDriverTips)
        XCTAssertFalse(sut.showBasketItems)
        XCTAssertEqual(sut.driverTip, 0)
    }
    
    func test_setupBasket() {
        let basket = Basket(basketToken: "aaabbb", isNewBasket: false, items: [], fulfilmentMethod: BasketFulfilmentMethod(type: .delivery, cost: 2.5, minSpend: 10), selectedSlot: nil, savings: nil, coupon: nil, fees: nil, tips: nil, addresses: nil, orderSubtotal: 0, orderTotal: 0)
        let appState = AppState(system: .init(), routing: .init(), userData: .init(selectedStore: .notRequested, selectedFulfilmentMethod: .delivery, searchResult: .notRequested, basket: basket, memberSignedIn: false))
        let container = DIContainer(appState: appState, services: .mocked())
        let sut = makeSUT(container: container)
        
        let expectation = expectation(description: "setupBasket")
        var cancellables = Set<AnyCancellable>()
        
        sut.$basket
            .first()
            .receive(on: RunLoop.main)
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 5)
        
        XCTAssertEqual(sut.basket, basket)
    }
    
    func test_whenCheckoutTapped_thenIsContinueToCheckoutTappedTrue() {
        let sut = makeSUT()
        
        sut.checkoutTapped()
        
        XCTAssertTrue(sut.isContinueToCheckoutTapped)
    }
    
    func test_givenBasketPopulated_whenSubmittingCouponCode_thenApplyingCouponChangesAndApplyCouponTriggers() {
        let basket = Basket(basketToken: "aaabbb", isNewBasket: false, items: [], fulfilmentMethod: BasketFulfilmentMethod(type: .delivery, cost: 2.5, minSpend: 10), selectedSlot: nil, savings: nil, coupon: nil, fees: nil, tips: nil, addresses: nil, orderSubtotal: 0, orderTotal: 0)
        let appState = AppState(system: .init(), routing: .init(), userData: .init(selectedStore: .notRequested, selectedFulfilmentMethod: .delivery, searchResult: .notRequested, basket: basket, memberSignedIn: false))
        let container = DIContainer(appState: appState, services: .mocked(basketService: [.applyCoupon(code: "SPRING10")]))
        let sut = makeSUT(container: container)
        sut.couponCode = "SPRING10"
        
        let expectation = expectation(description: "submitCoupon")
        var cancellables = Set<AnyCancellable>()
        
        sut.$applyingCoupon
            .collect(2)
            .receive(on: RunLoop.main)
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        sut.submitCoupon()
        
        wait(for: [expectation], timeout: 5)
        
        XCTAssertFalse(sut.applyingCoupon)
        XCTAssertTrue(sut.couponAppliedSuccessfully)
        
        container.services.verify()
    }
    
    func test_givenBasketPopulated_whenSubmittingInvalidCouponCode_thenApplyingCouponChangesAndCouponAppliedUnsuccessfulltIsTrue() {
        let basket = Basket(basketToken: "aaabbb", isNewBasket: false, items: [], fulfilmentMethod: BasketFulfilmentMethod(type: .delivery, cost: 2.5, minSpend: 10), selectedSlot: nil, savings: nil, coupon: nil, fees: nil, tips: nil, addresses: nil, orderSubtotal: 0, orderTotal: 0)
        let appState = AppState(system: .init(), routing: .init(), userData: .init(selectedStore: .notRequested, selectedFulfilmentMethod: .delivery, searchResult: .notRequested, basket: basket, memberSignedIn: false))
        let container = DIContainer(appState: appState, services: .mocked())
        let sut = makeSUT(container: container)
        sut.couponCode = "FAIL"
        
        let expectation = expectation(description: "submitCoupon")
        var cancellables = Set<AnyCancellable>()
        
        sut.$applyingCoupon
            .collect(2)
            .receive(on: RunLoop.main)
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        sut.submitCoupon()
        
        wait(for: [expectation], timeout: 5)
        
        XCTAssertFalse(sut.applyingCoupon)
        XCTAssertTrue(sut.couponAppliedUnsuccessfully)
    }
    
    func test_givenBasketWithCoupon_whenRemovingCouponCode_thenRemovingCouponChangesAndremoveCouponTriggers() {
        let basket = Basket(basketToken: "aaabbb", isNewBasket: false, items: [], fulfilmentMethod: BasketFulfilmentMethod(type: .delivery, cost: 2.5, minSpend: 10), selectedSlot: nil, savings: nil, coupon: BasketCoupon(code: "", name: "", deductCost: 1), fees: nil, tips: nil, addresses: nil, orderSubtotal: 0, orderTotal: 0)
        let appState = AppState(system: .init(), routing: .init(), userData: .init(selectedStore: .notRequested, selectedFulfilmentMethod: .delivery, searchResult: .notRequested, basket: basket, memberSignedIn: false))
        let container = DIContainer(appState: appState, services: .mocked(basketService: [.removeCoupon]))
        let sut = makeSUT(container: container)
        
        let expectation = expectation(description: "removeCoupon")
        var cancellables = Set<AnyCancellable>()
        
        sut.$removingCoupon
            .collect(2)
            .receive(on: RunLoop.main)
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        sut.removeCoupon()
        
        wait(for: [expectation], timeout: 5)
        
        XCTAssertFalse(sut.removingCoupon)
        
        container.services.verify()
    }
    
    func test_whenShowServiceFeeAlertIsTapped_thenShowingFeeInfoAlertIsTrue() {
        let sut = makeSUT()
        
        sut.showServiceFeeAlert()
        
        XCTAssertTrue(sut.showingServiceFeeAlert)
    }
    
    func test_whenDismissAlertIsTapped_thenShowingFeeInfoAlertIsFalse() {
        let sut = makeSUT()
        sut.showingServiceFeeAlert = true
        
        sut.dismissAlert()
        
        XCTAssertFalse(sut.showingServiceFeeAlert)
    }
    
    func test_givenBasketWithItem_whenUpdatebasketItem_thenIsUpdatingItemTriggers() {
        let container = DIContainer(appState: AppState(), services: .mocked(basketService: [.updateItem(item: BasketItemRequest(menuItemId: 123, quantity: 2, changeQuantity: nil, sizeId: 0, bannerAdvertId: 0, options: [], instructions: nil), basketLineId: 234)]))
        let sut = makeSUT(container: container)
        
        let expectation = expectation(description: "updateBasketItem")
        var cancellables = Set<AnyCancellable>()
        
        sut.$isUpdatingItem
            .collect(2)
            .receive(on: RunLoop.main)
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        sut.updateBasketItem(itemId: 123, quantity: 2, basketLineId: 234)
        
        wait(for: [expectation], timeout: 5)
        
        XCTAssertFalse(sut.isUpdatingItem)
        
        container.services.verify()
    }
    
    func test_givenDriverTipsEnabledAndCorrectTypeAndIsDelivery_thenBasketDriverTipsDisplaysAndIsCorrectAmount() {
        let driverTips = RetailStoreTip(enabled: true, defaultValue: 1, type: "driver", refundDriverTipsForLateOrders: nil, refundDriverTipsAfterLateByMinutes: nil)
        let storeDetails = RetailStoreDetails(id: 123, menuGroupId: 12, storeName: "", telephone: "", lat: 10, lng: 10, ordersPaused: false, canDeliver: true, distance: nil, pausedMessage: nil, address1: "", address2: nil, town: "", postcode: "", customerOrderNotePlaceholder: nil, memberEmailCheck: nil, guestCheckoutAllowed: true, basketOnlyTimeSelection: false, ratings: nil, tips: [driverTips], storeLogo: nil, storeProductTypes: nil, orderMethods: nil, deliveryDays: nil, collectionDays: nil, paymentMethods: nil, paymentGateways: nil, timeZone: nil, searchPostcode: nil)
        let userData = AppState.UserData(selectedStore: .loaded(storeDetails), selectedFulfilmentMethod: .delivery, searchResult: .notRequested, basket: nil, currentFulfilmentLocation: nil, memberSignedIn: false, basketContactDetails: nil, tempTodayTimeSlot: nil, basketDeliveryAddress: nil)
        let appState = AppState(system: AppState.System(), routing: AppState.ViewRouting(), businessData: AppState.BusinessData(), userData: userData)
        let container = DIContainer(appState: appState, services: .mocked())
        
        let sut = makeSUT(container: container)
        
        XCTAssertTrue(sut.showDriverTips)
        XCTAssertEqual(sut.driverTip, 1)
    }
    
    func test_givenDriverTipsEnabledAndCorrectTypeButIsCollection_thenBasketDriverTipsDOesNotDisplay() {
        let driverTips = RetailStoreTip(enabled: true, defaultValue: 1, type: "driver", refundDriverTipsForLateOrders: nil, refundDriverTipsAfterLateByMinutes: nil)
        let storeDetails = RetailStoreDetails(id: 123, menuGroupId: 12, storeName: "", telephone: "", lat: 10, lng: 10, ordersPaused: false, canDeliver: true, distance: nil, pausedMessage: nil, address1: "", address2: nil, town: "", postcode: "", customerOrderNotePlaceholder: nil, memberEmailCheck: nil, guestCheckoutAllowed: true, basketOnlyTimeSelection: false, ratings: nil, tips: [driverTips], storeLogo: nil, storeProductTypes: nil, orderMethods: nil, deliveryDays: nil, collectionDays: nil, paymentMethods: nil, paymentGateways: nil, timeZone: nil, searchPostcode: nil)
        let userData = AppState.UserData(selectedStore: .loaded(storeDetails), selectedFulfilmentMethod: .collection, searchResult: .notRequested, basket: nil, currentFulfilmentLocation: nil, memberSignedIn: false, basketContactDetails: nil, tempTodayTimeSlot: nil, basketDeliveryAddress: nil)
        let appState = AppState(system: AppState.System(), routing: AppState.ViewRouting(), businessData: AppState.BusinessData(), userData: userData)
        let container = DIContainer(appState: appState, services: .mocked())
        
        let sut = makeSUT(container: container)
        
        XCTAssertFalse(sut.showDriverTips)
    }
    
    func test_givenDriverTipsDisabledAndCorrectTypeAndIsDelivery_thenBasketDriverTipsDoesNotDisplay() {
        let driverTips = RetailStoreTip(enabled: false, defaultValue: 1, type: "driver", refundDriverTipsForLateOrders: nil, refundDriverTipsAfterLateByMinutes: nil)
        let storeDetails = RetailStoreDetails(id: 123, menuGroupId: 12, storeName: "", telephone: "", lat: 10, lng: 10, ordersPaused: false, canDeliver: true, distance: nil, pausedMessage: nil, address1: "", address2: nil, town: "", postcode: "", customerOrderNotePlaceholder: nil, memberEmailCheck: nil, guestCheckoutAllowed: true, basketOnlyTimeSelection: false, ratings: nil, tips: [driverTips], storeLogo: nil, storeProductTypes: nil, orderMethods: nil, deliveryDays: nil, collectionDays: nil, paymentMethods: nil, paymentGateways: nil, timeZone: nil, searchPostcode: nil)
        let userData = AppState.UserData(selectedStore: .loaded(storeDetails), selectedFulfilmentMethod: .collection, searchResult: .notRequested, basket: nil, currentFulfilmentLocation: nil, memberSignedIn: false, basketContactDetails: nil, tempTodayTimeSlot: nil, basketDeliveryAddress: nil)
        let appState = AppState(system: AppState.System(), routing: AppState.ViewRouting(), businessData: AppState.BusinessData(), userData: userData)
        let container = DIContainer(appState: appState, services: .mocked())
        
        let sut = makeSUT(container: container)
        
        XCTAssertFalse(sut.showDriverTips)
    }
    
    func test_givenDriverTipsEnabledAndIsDeliveryButIncorrectType_thenBasketDriverTipsDoesNotDisplay() {
        let driverTips = RetailStoreTip(enabled: false, defaultValue: 1, type: "somethingelse", refundDriverTipsForLateOrders: nil, refundDriverTipsAfterLateByMinutes: nil)
        let storeDetails = RetailStoreDetails(id: 123, menuGroupId: 12, storeName: "", telephone: "", lat: 10, lng: 10, ordersPaused: false, canDeliver: true, distance: nil, pausedMessage: nil, address1: "", address2: nil, town: "", postcode: "", customerOrderNotePlaceholder: nil, memberEmailCheck: nil, guestCheckoutAllowed: true, basketOnlyTimeSelection: false, ratings: nil, tips: [driverTips], storeLogo: nil, storeProductTypes: nil, orderMethods: nil, deliveryDays: nil, collectionDays: nil, paymentMethods: nil, paymentGateways: nil, timeZone: nil, searchPostcode: nil)
        let userData = AppState.UserData(selectedStore: .loaded(storeDetails), selectedFulfilmentMethod: .collection, searchResult: .notRequested, basket: nil, currentFulfilmentLocation: nil, memberSignedIn: false, basketContactDetails: nil, tempTodayTimeSlot: nil, basketDeliveryAddress: nil)
        let appState = AppState(system: AppState.System(), routing: AppState.ViewRouting(), businessData: AppState.BusinessData(), userData: userData)
        let container = DIContainer(appState: appState, services: .mocked())
        
        let sut = makeSUT(container: container)
        
        XCTAssertFalse(sut.showDriverTips)
    }
    
    func test_givenTipInBasket_thenDriverTipCorrect() {
        let basketTip = BasketTip(type: "driver", amount: 2)
        let basket = Basket(basketToken: "", isNewBasket: true, items: [], fulfilmentMethod: BasketFulfilmentMethod(type: .delivery, cost: 1, minSpend: 10), selectedSlot: nil, savings: nil, coupon: nil, fees: nil, tips: [basketTip], addresses: nil, orderSubtotal: 10, orderTotal: 10)
        let driverTips = RetailStoreTip(enabled: false, defaultValue: 1, type: "somethingelse", refundDriverTipsForLateOrders: nil, refundDriverTipsAfterLateByMinutes: nil)
        let storeDetails = RetailStoreDetails(id: 123, menuGroupId: 12, storeName: "", telephone: "", lat: 10, lng: 10, ordersPaused: false, canDeliver: true, distance: nil, pausedMessage: nil, address1: "", address2: nil, town: "", postcode: "", customerOrderNotePlaceholder: nil, memberEmailCheck: nil, guestCheckoutAllowed: true, basketOnlyTimeSelection: false, ratings: nil, tips: [driverTips], storeLogo: nil, storeProductTypes: nil, orderMethods: nil, deliveryDays: nil, collectionDays: nil, paymentMethods: nil, paymentGateways: nil, timeZone: nil, searchPostcode: nil)
        let userData = AppState.UserData(selectedStore: .loaded(storeDetails), selectedFulfilmentMethod: .collection, searchResult: .notRequested, basket: basket, currentFulfilmentLocation: nil, memberSignedIn: false, basketContactDetails: nil, tempTodayTimeSlot: nil, basketDeliveryAddress: nil)
        let appState = AppState(system: AppState.System(), routing: AppState.ViewRouting(), businessData: AppState.BusinessData(), userData: userData)
        let container = DIContainer(appState: appState, services: .mocked())
        
        let sut = makeSUT(container: container)
        
        let exp = expectation(description: "driverTips")
        var cancellables = Set<AnyCancellable>()
        
        sut.$driverTip
            .first()
            .receive(on: RunLoop.main)
            .sink { _ in
                exp.fulfill()
            }
            .store(in: &cancellables)
        
        wait(for: [exp], timeout: 2)
        
        XCTAssertEqual(sut.driverTip, 2)
    }
    
    func test_givenBasket_thenShowBasketItemsIsTrue() {
        let storeItem = RetailStoreMenuItem(id: 132, name: "", eposCode: nil, outOfStock: false, ageRestriction: 0, description: nil, quickAdd: true, acceptCustomerInstructions: true, basketQuantityLimit: 0, price: RetailStoreMenuItemPrice(price: 10, fromPrice: 10, unitMetric: "", unitsInPack: 0, unitVolume: 0, wasPrice: nil), images: nil, menuItemSizes: nil, menuItemOptions: nil, availableDeals: nil)
        let basketItem = BasketItem(basketLineId: 123, menuItem: storeItem, totalPrice: 10, totalPriceBeforeDiscounts: 10, price: 10, pricePaid: 10, quantity: 1, instructions: nil, size: nil, selectedOptions: nil, missedPromotions: nil)
        let basket = Basket(basketToken: "", isNewBasket: true, items: [basketItem], fulfilmentMethod: BasketFulfilmentMethod(type: .delivery, cost: 1, minSpend: 10), selectedSlot: nil, savings: nil, coupon: nil, fees: nil, tips: nil, addresses: nil, orderSubtotal: 10, orderTotal: 10)
        let userData = AppState.UserData(selectedStore: .notRequested, selectedFulfilmentMethod: .collection, searchResult: .notRequested, basket: basket, currentFulfilmentLocation: nil, memberSignedIn: false, basketContactDetails: nil, tempTodayTimeSlot: nil, basketDeliveryAddress: nil)
        let appState = AppState(system: AppState.System(), routing: AppState.ViewRouting(), businessData: AppState.BusinessData(), userData: userData)
        let container = DIContainer(appState: appState, services: .mocked())
        
        let sut = makeSUT(container: container)
        
        XCTAssertTrue(sut.showBasketItems)
    }

    func makeSUT(container: DIContainer = DIContainer(appState: AppState(), services: .mocked())) -> BasketViewModel {
        let sut = BasketViewModel(container: container)
        
        trackForMemoryLeaks(sut)
        
        return sut
    }

}
