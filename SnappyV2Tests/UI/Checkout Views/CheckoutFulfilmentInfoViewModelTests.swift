//
//  CheckoutFulfilmentInfoViewModelTests.swift
//  SnappyV2Tests
//
//  Created by Henrik Gustavii on 10/03/2022.
//

import XCTest
import Combine
import CoreLocation
@testable import SnappyV2
import StoreKit
import SwiftUI

@MainActor
class CheckoutFulfilmentInfoViewModelTests: XCTestCase {
    
    func test_init() {
        let sut = makeSUT()
        
        XCTAssertEqual(sut.selectedRetailStoreFulfilmentTimeSlots, .notRequested)
        XCTAssertNil(sut.basket)
        XCTAssertNil(sut.instructions)
        XCTAssertNil(sut.tempTodayTimeSlot)
        XCTAssertNil(sut.selectedDeliveryAddress)
        XCTAssertFalse(sut.showPayByCard)
        XCTAssertFalse(sut.showPayByApple)
        XCTAssertFalse(sut.showPayByCash)
        XCTAssertNil(sut.orderTotalPriceString)
    }
    
    func test_givenStoreAndBasket_whenInit_thenOrderTotalPriceStringCorrect() {
        let selectedStore = RetailStoreDetails.mockedData
        let basket = Basket.mockedData
        let container = DIContainer(appState: AppState(), eventLogger: MockedEventLogger(), services: .mocked())
        container.appState.value.userData.selectedStore = .loaded(selectedStore)
        container.appState.value.userData.basket = basket
        let sut = makeSUT(container: container)
        
        XCTAssertEqual(sut.orderTotalPriceString, basket.orderTotal.toCurrencyString(using: selectedStore.currency))
    }
    
    func test_whenConfirmCashPaymentTriggered_thenHasConfirmedCashPaymentIsTrueAndPayByCashTappedTriggered() async {
        var checkoutState: CheckoutRootViewModel.CheckoutState?
        let sut = makeSUT(checkoutState: { state in
            checkoutState = state
        })
        
        await sut.confirmCashPayment()
        
        XCTAssertEqual(checkoutState, .paymentSuccess)
    }
    
    func test_givenBasketSelectedSlotTodaySelectedTrueAndNoTempTodayTimeSlotAssigned_thenFirstAvailableTimeSlotTodayAssigned() {
        
        let basket = Basket(
            basketToken: "",
            isNewBasket: true,
            items: [],
            fulfilmentMethod: .init(
            type: .delivery,
            cost: 1.5,
            minSpend: 0,
            zoneFreeDeliveryMessage: nil,
            minBasketSpendForNextDeliveryTier: nil,
            nextTierSpendIsHigherThanCurrent: false,
            minAdditionalBasketSpendForNextTier: nil,
            nextTierDeliveryCost: nil),
            selectedSlot: BasketSelectedSlot(
                todaySelected: true,
                start: nil,
                end: nil,
                expires: nil),
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
        let sut = makeSUT(container: container)
        let today = Date().startOfDay
        let timeSlot1 = RetailStoreSlotDayTimeSlot(slotId: "123", startTime: today, endTime: today.addingTimeInterval(60*30), daytime: "", info: RetailStoreSlotDayTimeSlotInfo(status: "", isAsap: true, price: 5, fulfilmentIn: ""))
        let timeSlot2 = RetailStoreSlotDayTimeSlot(slotId: "321", startTime: today.addingTimeInterval(60*30), endTime: today.addingTimeInterval(60*60), daytime: "", info: RetailStoreSlotDayTimeSlotInfo(status: "", isAsap: true, price: 5, fulfilmentIn: ""))
        let slotDay = RetailStoreSlotDay(status: "", reason: "", slotDate: today.dateOnlyString(storeTimeZone: nil), slots: [timeSlot1, timeSlot2])
        let timeSlots = RetailStoreTimeSlots(startDate: today.startOfDay, endDate: today.endOfDay, fulfilmentMethod: "delivery", slotDays: [slotDay], searchStoreId: nil, searchLatitude: nil, searchLongitude: nil)
        sut.selectedRetailStoreFulfilmentTimeSlots = .loaded(timeSlots)
        
        let expectation = expectation(description: "tempTodayTimeSlot")
        var cancellables = Set<AnyCancellable>()
        
        sut.$tempTodayTimeSlot
            .first()
            .receive(on: RunLoop.main)
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 2)
        
        XCTAssertEqual(sut.tempTodayTimeSlot, timeSlot1)
    }
    
    func test_givenSelectedStoreWithCheckoutComPaymentGateway_whenPayByCardTapped_thenNavigateToPaymentHandlingIsCorrectAndSendEvent() {
        let selectedStore = RetailStoreDetails.mockedDataWithCheckoutComApplePay
        var appState = AppState(userData: AppState.UserData())
        appState.userData.selectedStore = .loaded(selectedStore)
        let eventLogger = MockedEventLogger(expected: [.sendEvent(for: .payByCardSelected, with: .firebaseAnalytics, params: [:])])
        let container = DIContainer(appState: appState, eventLogger: eventLogger, services: .mocked())
        var checkoutState: CheckoutRootViewModel.CheckoutState?
        let sut = makeSUT(container: container, checkoutState: { state in
            checkoutState = state
        })
        
        sut.payByCardTapped()
        
        XCTAssertEqual(checkoutState, .card)
        XCTAssertFalse(sut.handleGlobalPayment)
        eventLogger.verify()
    }
    
    func test_givenSelectedStoreWithWorldpayPaymentGateway_whenPayByCardTapped_thenNavigateToPaymentHandlingIsCorrectAndSendEvent() {
        let selectedStore = RetailStoreDetails.mockedData
        var appState = AppState(userData: AppState.UserData())
        appState.userData.selectedStore = .loaded(selectedStore)
        let eventLogger = MockedEventLogger(expected: [.sendEvent(for: .payByCardSelected, with: .firebaseAnalytics, params: [:])])
        let container = DIContainer(appState: appState, eventLogger: eventLogger, services: .mocked())
        var checkoutState: CheckoutRootViewModel.CheckoutState?
        let sut = makeSUT(container: container, checkoutState: { state in
            checkoutState = state
        })
        
        sut.payByCardTapped()
        
        XCTAssertNil(checkoutState)
        XCTAssertTrue(sut.handleGlobalPayment)
        eventLogger.verify()
    }
    
    func test_givenStoreWithApplePayGateway_whenPayByAppleTapped_thenNavigateToPaymentSuccessIsCorrectAndSendevent() async {
        let selectedStore = RetailStoreDetails.mockedDataWithCheckoutComApplePay
        let basket = Basket.mockedDataTomorrowSlot
        let timeZone = selectedStore.storeTimeZone
        let userData = AppState.UserData(selectedStore: .loaded(selectedStore), selectedFulfilmentMethod: .delivery, searchResult: .notRequested, basket: basket, currentFulfilmentLocation: nil, tempTodayTimeSlot: nil, basketDeliveryAddress: nil, memberProfile: nil)
        let appState = AppState(system: AppState.System(), routing: AppState.ViewRouting(), businessData: AppState.BusinessData(), userData: userData, staticCacheData: AppState.StaticCacheData(), notifications: AppState.Notifications())
        let requestedTime = "\(basket.selectedSlot?.start?.hourMinutesString(timeZone: timeZone) ?? "") - \(basket.selectedSlot?.end?.hourMinutesString(timeZone: timeZone) ?? "")"
        let draftOrderFulfilmentDetailsTimeRequest = DraftOrderFulfilmentDetailsTimeRequest(date: basket.selectedSlot?.start?.dateOnlyString(storeTimeZone: timeZone) ?? "", requestedTime: requestedTime)
        let draftOrderFulfilmentDetailRequest = DraftOrderFulfilmentDetailsRequest(time: draftOrderFulfilmentDetailsTimeRequest, place: nil)
        let checkoutService = MockedCheckoutService(expected: [.processApplePaymentOrder(fulfilmentDetails: draftOrderFulfilmentDetailRequest, paymentGatewayType: .checkoutcom, paymentGatewayMode: .sandbox, instructions: nil, publicKey: selectedStore.paymentGateways?[0].fields?["publicKey"] as! String, merchantId: selectedStore.paymentGateways?[0].fields?["applePayMerchantId"] as! String)])
        checkoutService.processApplePaymentOrderResult = .success(439)

        let services = DIContainer.Services(
            businessProfileService: MockedBusinessProfileService(expected: []),
            retailStoreService: MockedRetailStoreService(expected: []),
            retailStoreMenuService: MockedRetailStoreMenuService(expected: []),
            basketService: MockedBasketService(expected: []),
            memberService: MockedUserService(expected: []),
            checkoutService: checkoutService,
            addressService: MockedAddressService(expected: []),
            utilityService: MockedUtilityService(expected: []),
            imageService: MockedAsyncImageService(expected: []),
            notificationService: MockedNotificationService(expected: []),
            userPermissionsService: MockedUserPermissionsService(expected: []),
            searchHistoryService: MockedSearchHistoryService(expected: [])
        )
        let eventLogger = MockedEventLogger(expected: [.sendEvent(for: .payByApplePaySelected, with: .firebaseAnalytics, params: [:])])
        let container = DIContainer(appState: appState, eventLogger: eventLogger, services: services)
        var checkoutState: CheckoutRootViewModel.CheckoutState?
        let sut = makeSUT(container: container, checkoutState: { state in
            checkoutState = state
        })
        
        await sut.payByAppleTapped()
        
        XCTAssertEqual(checkoutState, .paymentSuccess)
        container.services.verify(as: .checkout)
        eventLogger.verify()
    }
    
    func test_givenStoreWithoutApplePayGateway_whenPayByAppleTapped_thenDefaultToBusinessProfilePaymentGatewayAndNavigateToPaymentSuccessIsCorrectAndSendEvent() async {
        let selectedStore = RetailStoreDetails.mockedData
        let businessProfile = BusinessProfile.mockedDataFromAPI
        let basket = Basket.mockedDataTomorrowSlot
        let timeZone = selectedStore.storeTimeZone
        let userData = AppState.UserData(selectedStore: .loaded(selectedStore), selectedFulfilmentMethod: .delivery, searchResult: .notRequested, basket: basket, currentFulfilmentLocation: nil, tempTodayTimeSlot: nil, basketDeliveryAddress: nil, memberProfile: nil)
        let businessData = AppState.BusinessData(businessProfile: businessProfile)
        let appState = AppState(system: AppState.System(), routing: AppState.ViewRouting(), businessData: businessData, userData: userData, staticCacheData: AppState.StaticCacheData(), notifications: AppState.Notifications())
        let requestedTime = "\(basket.selectedSlot?.start?.hourMinutesString(timeZone: timeZone) ?? "") - \(basket.selectedSlot?.end?.hourMinutesString(timeZone: timeZone) ?? "")"
        let draftOrderFulfilmentDetailsTimeRequest = DraftOrderFulfilmentDetailsTimeRequest(date: basket.selectedSlot?.start?.dateOnlyString(storeTimeZone: timeZone) ?? "", requestedTime: requestedTime)
        let draftOrderFulfilmentDetailRequest = DraftOrderFulfilmentDetailsRequest(time: draftOrderFulfilmentDetailsTimeRequest, place: nil)

        let checkoutService = MockedCheckoutService(expected: [.processApplePaymentOrder(fulfilmentDetails: draftOrderFulfilmentDetailRequest, paymentGatewayType: .checkoutcom, paymentGatewayMode: .sandbox, instructions: nil, publicKey: businessProfile.paymentGateways[0].fields?["publicKey"] as! String, merchantId: businessProfile.paymentGateways[0].fields?["applePayMerchantId"] as! String)])
        checkoutService.processApplePaymentOrderResult = .success(439)

        let services = DIContainer.Services(
            businessProfileService: MockedBusinessProfileService(expected: []),
            retailStoreService: MockedRetailStoreService(expected: []),
            retailStoreMenuService: MockedRetailStoreMenuService(expected: []),
            basketService: MockedBasketService(expected: []),
            memberService: MockedUserService(expected: []),
            checkoutService: checkoutService,
            addressService: MockedAddressService(expected: []),
            utilityService: MockedUtilityService(expected: []),
            imageService: MockedAsyncImageService(expected: []),
            notificationService: MockedNotificationService(expected: []),
            userPermissionsService: MockedUserPermissionsService(expected: []),
            searchHistoryService: MockedSearchHistoryService(expected: [])
        )
        let eventLogger = MockedEventLogger(expected: [.sendEvent(for: .payByApplePaySelected, with: .firebaseAnalytics, params: [:])])
        let container = DIContainer(appState: appState, eventLogger: eventLogger, services: services)
        var checkoutState: CheckoutRootViewModel.CheckoutState?
        let sut = makeSUT(container: container, checkoutState: { state in
            checkoutState = state
        })
        
        await sut.payByAppleTapped()
        
        XCTAssertEqual(checkoutState, .paymentSuccess)
        
        container.services.verify(as: .checkout)
        eventLogger.verify()
    }
    
    func test_givenStoreWithApplePayGateway_whenPayByAppleTappedAndReturnsNoBusinessOrderId_thenNavigateToPaymentHandlingIsCorrectAndSendEvent() async {
        let selectedStore = RetailStoreDetails.mockedDataWithCheckoutComApplePay
        let basket = Basket.mockedDataTomorrowSlot
        let timeZone = selectedStore.storeTimeZone
        let userData = AppState.UserData(selectedStore: .loaded(selectedStore), selectedFulfilmentMethod: .delivery, searchResult: .notRequested, basket: basket, currentFulfilmentLocation: nil, tempTodayTimeSlot: nil, basketDeliveryAddress: nil, memberProfile: nil)
        let appState = AppState(system: AppState.System(), routing: AppState.ViewRouting(), businessData: AppState.BusinessData(), userData: userData, staticCacheData: AppState.StaticCacheData(), notifications: AppState.Notifications())
        let requestedTime = "\(basket.selectedSlot?.start?.hourMinutesString(timeZone: timeZone) ?? "") - \(basket.selectedSlot?.end?.hourMinutesString(timeZone: timeZone) ?? "")"
        let draftOrderFulfilmentDetailsTimeRequest = DraftOrderFulfilmentDetailsTimeRequest(date: basket.selectedSlot?.start?.dateOnlyString(storeTimeZone: timeZone) ?? "", requestedTime: requestedTime)
        let draftOrderFulfilmentDetailRequest = DraftOrderFulfilmentDetailsRequest(time: draftOrderFulfilmentDetailsTimeRequest, place: nil)
        
        let appsFlyerParams: [String : Any] = [
            "price": 23.3,
            "error": "Apple pay failed - BusinessOrderId not returned",
            "order_id": 45565,
            "payment_type": "apple_pay",
            "payment_method": "checkoutcom",
            "quantity": 1
        ]
        let firebaseParams: [String : Any] = [
            "error": "Apple pay failed - BusinessOrderId not returned",
            "order_id": 45565,
            "payment_type": "apple_pay",
            "gateway": "checkoutcom"
        ]
        let eventLogger = MockedEventLogger(expected: [
            .sendEvent(for: .payByApplePaySelected, with: .firebaseAnalytics, params: [:]),
            .sendEvent(for: .paymentFailure, with: .appsFlyer, params: appsFlyerParams),
            .sendEvent(for: .paymentFailure, with: .firebaseAnalytics, params: firebaseParams)
        ])
        
        let checkoutService = MockedCheckoutService(expected: [
            .processApplePaymentOrder(fulfilmentDetails: draftOrderFulfilmentDetailRequest, paymentGatewayType: .checkoutcom, paymentGatewayMode: .sandbox, instructions: nil, publicKey: selectedStore.paymentGateways?[0].fields?["publicKey"] as! String, merchantId: selectedStore.paymentGateways?[0].fields?["applePayMerchantId"] as! String),
            .currentDraftOrderId,
            .currentDraftOrderId
        ])
        checkoutService.currentDraftOrderIdResult = 45565
        checkoutService.processApplePaymentOrderResult = .success(nil)
        let services = DIContainer.Services(
            businessProfileService: MockedBusinessProfileService(expected: []),
            retailStoreService: MockedRetailStoreService(expected: []),
            retailStoreMenuService: MockedRetailStoreMenuService(expected: []),
            basketService: MockedBasketService(expected: []),
            memberService: MockedUserService(expected: []),
            checkoutService: checkoutService,
            addressService: MockedAddressService(expected: []),
            utilityService: MockedUtilityService(expected: []),
            imageService: MockedAsyncImageService(expected: []),
            notificationService: MockedNotificationService(expected: []),
            userPermissionsService: MockedUserPermissionsService(expected: []),
            searchHistoryService: MockedSearchHistoryService(expected: [])
        )
        let container = DIContainer(appState: appState, eventLogger: eventLogger, services: services)

        var checkoutState: CheckoutRootViewModel.CheckoutState?
        let sut = makeSUT(container: container, checkoutState: { state in
            checkoutState = state
        })
        await sut.payByAppleTapped()
        
        XCTAssertNil(checkoutState)
        
        container.services.verify(as: .checkout)
        eventLogger.verify()
    }
    
    func test_givenStoreWithApplePayGateway_whenPayByAppleTappedAndThrowsError_thenNavigateToPaymentHandlingIsCorrectAndSendEvent() async {
        let thrownError = APIErrorResult(errorCode: 409, errorText: "Payment processing error", errorDisplay: "error")
        let selectedStore = RetailStoreDetails.mockedDataWithCheckoutComApplePay
        let basket = Basket.mockedDataTomorrowSlot
        let timeZone = selectedStore.storeTimeZone
        let userData = AppState.UserData(selectedStore: .loaded(selectedStore), selectedFulfilmentMethod: .delivery, searchResult: .notRequested, basket: basket, currentFulfilmentLocation: nil, tempTodayTimeSlot: nil, basketDeliveryAddress: nil, memberProfile: nil)
        let appState = AppState(system: AppState.System(), routing: AppState.ViewRouting(), businessData: AppState.BusinessData(), userData: userData, staticCacheData: AppState.StaticCacheData(), notifications: AppState.Notifications())
        let requestedTime = "\(basket.selectedSlot?.start?.hourMinutesString(timeZone: timeZone) ?? "") - \(basket.selectedSlot?.end?.hourMinutesString(timeZone: timeZone) ?? "")"
        let draftOrderFulfilmentDetailsTimeRequest = DraftOrderFulfilmentDetailsTimeRequest(date: basket.selectedSlot?.start?.dateOnlyString(storeTimeZone: timeZone) ?? "", requestedTime: requestedTime)
        let draftOrderFulfilmentDetailRequest = DraftOrderFulfilmentDetailsRequest(time: draftOrderFulfilmentDetailsTimeRequest, place: nil)
        
        let appsFlyerParams: [String : Any] = [
            "price": 23.3,
            "error": thrownError.errorDisplay,
            "order_id": 45565,
            "payment_type": "apple_pay",
            "payment_method": "checkoutcom",
            "quantity": 1
        ]
        let firebaseParams: [String : Any] = [
            "error": thrownError.errorDisplay,
            "order_id": 45565,
            "payment_type": "apple_pay",
            "gateway": "checkoutcom"
        ]
        let eventLogger = MockedEventLogger(expected: [
            .sendEvent(for: .payByApplePaySelected, with: .firebaseAnalytics, params: [:]),
            .sendEvent(for: .paymentFailure, with: .appsFlyer, params: appsFlyerParams),
            .sendEvent(for: .paymentFailure, with: .firebaseAnalytics, params: firebaseParams)
        ])
        
        let checkoutService = MockedCheckoutService(expected: [
            .processApplePaymentOrder(fulfilmentDetails: draftOrderFulfilmentDetailRequest, paymentGatewayType: .checkoutcom, paymentGatewayMode: .sandbox, instructions: nil, publicKey: selectedStore.paymentGateways?[0].fields?["publicKey"] as! String, merchantId: selectedStore.paymentGateways?[0].fields?["applePayMerchantId"] as! String),
            .currentDraftOrderId,
            .currentDraftOrderId
        ])
        checkoutService.currentDraftOrderIdResult = 45565
        checkoutService.processApplePaymentOrderResult = .failure(thrownError)
        let services = DIContainer.Services(
            businessProfileService: MockedBusinessProfileService(expected: []),
            retailStoreService: MockedRetailStoreService(expected: []),
            retailStoreMenuService: MockedRetailStoreMenuService(expected: []),
            basketService: MockedBasketService(expected: []),
            memberService: MockedUserService(expected: []),
            checkoutService: checkoutService,
            addressService: MockedAddressService(expected: []),
            utilityService: MockedUtilityService(expected: []),
            imageService: MockedAsyncImageService(expected: []),
            notificationService: MockedNotificationService(expected: []),
            userPermissionsService: MockedUserPermissionsService(expected: []),
            searchHistoryService: MockedSearchHistoryService(expected: [])
        )
        let container = DIContainer(appState: appState, eventLogger: eventLogger, services: services)
        var checkoutState: CheckoutRootViewModel.CheckoutState?
        let sut = makeSUT(container: container, checkoutState: { state in
            checkoutState = state
        })
        await sut.payByAppleTapped()
        
        XCTAssertNil(checkoutState)
        
        container.services.verify(as: .checkout)
        eventLogger.verify()
    }
    
    func test_givenStoreSupportsCheckoutCom_thenShowPayByCardIsTrue() {
        let paymentMethod = PaymentMethod(name: "checkoutcom", title: "CheckoutCom", description: nil, settings: PaymentMethodSettings(title: "CheckoutCom", instructions: nil, enabledForMethod: [.delivery], paymentGateways: ["checkoutcom"], saveCards: nil, cutOffTime: nil))
        let paymentGateway = PaymentGateway(name: "checkoutcom", mode: .sandbox, fields: nil)
        let storeDetails = RetailStoreDetails(id: 123, menuGroupId: 12, storeName: "", telephone: "", lat: 10, lng: 10, ordersPaused: false, canDeliver: true, distance: nil, pausedMessage: nil, address1: "", address2: nil, town: "", postcode: "", customerOrderNotePlaceholder: nil, memberEmailCheck: nil, guestCheckoutAllowed: true, basketOnlyTimeSelection: false, ratings: nil, tips: nil, storeLogo: nil, storeProductTypes: nil, orderMethods: nil, deliveryDays: [], collectionDays: [], paymentMethods: [paymentMethod], paymentGateways: [paymentGateway], allowedMarketingChannels: [], timeZone: nil, currency: RetailStoreCurrency.mockedGBPData, retailCustomer: nil, searchPostcode: nil, searchIsFirstOrder: nil)
        let userData = AppState.UserData(selectedStore: .loaded(storeDetails), selectedFulfilmentMethod: .delivery, searchResult: .notRequested, basket: nil, currentFulfilmentLocation: nil, tempTodayTimeSlot: nil, basketDeliveryAddress: nil, memberProfile: nil)
        let appState = AppState(system: AppState.System(), routing: AppState.ViewRouting(), businessData: AppState.BusinessData(), userData: userData)
        let sut = makeSUT(container: DIContainer(appState: appState, eventLogger: MockedEventLogger(), services: .mocked()))
                          
        XCTAssertTrue(sut.showPayByCard)
    }
    
    func test_givenStoreSupportsCash_thenShowPayByCashIsTrue() {
        let paymentMethod = PaymentMethod(name: "cash", title: "cash", description: nil, settings: PaymentMethodSettings(title: "cash", instructions: nil, enabledForMethod: [.delivery], paymentGateways: ["cash"], saveCards: nil, cutOffTime: nil))
        let paymentGateway = PaymentGateway(name: "cash", mode: .sandbox, fields: nil)
        let storeDetails = RetailStoreDetails(id: 123, menuGroupId: 12, storeName: "", telephone: "", lat: 10, lng: 10, ordersPaused: false, canDeliver: true, distance: nil, pausedMessage: nil, address1: "", address2: nil, town: "", postcode: "", customerOrderNotePlaceholder: nil, memberEmailCheck: nil, guestCheckoutAllowed: true, basketOnlyTimeSelection: false, ratings: nil, tips: nil, storeLogo: nil, storeProductTypes: nil, orderMethods: nil, deliveryDays: [], collectionDays: [], paymentMethods: [paymentMethod], paymentGateways: [paymentGateway], allowedMarketingChannels: [], timeZone: nil, currency: RetailStoreCurrency.mockedGBPData, retailCustomer: nil, searchPostcode: nil, searchIsFirstOrder: nil)
        let userData = AppState.UserData(selectedStore: .loaded(storeDetails), selectedFulfilmentMethod: .delivery, searchResult: .notRequested, basket: nil, currentFulfilmentLocation: nil, tempTodayTimeSlot: nil, basketDeliveryAddress: nil, memberProfile: nil)
        let appState = AppState(system: AppState.System(), routing: AppState.ViewRouting(), businessData: AppState.BusinessData(), userData: userData)
        let sut = makeSUT(container: DIContainer(appState: appState, eventLogger: MockedEventLogger(), services: .mocked()))
                          
        XCTAssertTrue(sut.showPayByCash)
    }
    
    func test_givenStoreSupportsCashWithCutoffTimeAndTodaySelected_whenBeforeCutoffTime_thenShowPayByCashIsTrue() {
        let date = Date()
        let cutofftime = date.addingTimeInterval(60*60)
        let paymentMethod = PaymentMethod(name: "cash", title: "cash", description: nil, settings: PaymentMethodSettings(title: "cash", instructions: nil, enabledForMethod: [.delivery], paymentGateways: ["cash"], saveCards: nil, cutOffTime: cutofftime.hourMinutesSecondsString(timeZone: nil)))
        let paymentGateway = PaymentGateway(name: "cash", mode: .sandbox, fields: nil)
        let storeDetails = RetailStoreDetails(id: 123, menuGroupId: 12, storeName: "", telephone: "", lat: 10, lng: 10, ordersPaused: false, canDeliver: true, distance: nil, pausedMessage: nil, address1: "", address2: nil, town: "", postcode: "", customerOrderNotePlaceholder: nil, memberEmailCheck: nil, guestCheckoutAllowed: true, basketOnlyTimeSelection: false, ratings: nil, tips: nil, storeLogo: nil, storeProductTypes: nil, orderMethods: nil, deliveryDays: [], collectionDays: [], paymentMethods: [paymentMethod], paymentGateways: [paymentGateway], allowedMarketingChannels: [], timeZone: nil, currency: RetailStoreCurrency.mockedGBPData, retailCustomer: nil, searchPostcode: nil, searchIsFirstOrder: nil)
        let basket = Basket.mockedDataIsAlcohol
        let userData = AppState.UserData(selectedStore: .loaded(storeDetails), selectedFulfilmentMethod: .delivery, searchResult: .notRequested, basket: basket, currentFulfilmentLocation: nil, tempTodayTimeSlot: nil, basketDeliveryAddress: nil, memberProfile: nil)
        let appState = AppState(system: AppState.System(), routing: AppState.ViewRouting(), businessData: AppState.BusinessData(), userData: userData)
        let sut = makeSUT(container: DIContainer(appState: appState, eventLogger: MockedEventLogger(), services: .mocked()))
                          
        XCTAssertTrue(sut.showPayByCash)
    }
    
    func test_givenStoreSupportsCashWithCutoffTimeAndTodaySelected_whenAfterCutoffTime_thenShowPayByCashIsFalse() {
        let date = Date()
        let cutofftime = date.addingTimeInterval(-60*60) // an hour earlier
        let paymentMethod = PaymentMethod(name: "cash", title: "cash", description: nil, settings: PaymentMethodSettings(title: "cash", instructions: nil, enabledForMethod: [.delivery], paymentGateways: ["cash"], saveCards: nil, cutOffTime: cutofftime.hourMinutesSecondsString(timeZone: nil)))
        let paymentGateway = PaymentGateway(name: "cash", mode: .sandbox, fields: nil)
        let storeDetails = RetailStoreDetails(id: 123, menuGroupId: 12, storeName: "", telephone: "", lat: 10, lng: 10, ordersPaused: false, canDeliver: true, distance: nil, pausedMessage: nil, address1: "", address2: nil, town: "", postcode: "", customerOrderNotePlaceholder: nil, memberEmailCheck: nil, guestCheckoutAllowed: true, basketOnlyTimeSelection: false, ratings: nil, tips: nil, storeLogo: nil, storeProductTypes: nil, orderMethods: nil, deliveryDays: [], collectionDays: [], paymentMethods: [paymentMethod], paymentGateways: [paymentGateway], allowedMarketingChannels: [], timeZone: nil, currency: RetailStoreCurrency.mockedGBPData, retailCustomer: nil, searchPostcode: nil, searchIsFirstOrder: nil)
        let basket = Basket.mockedDataIsAlcohol
        let userData = AppState.UserData(selectedStore: .loaded(storeDetails), selectedFulfilmentMethod: .delivery, searchResult: .notRequested, basket: basket, currentFulfilmentLocation: nil, tempTodayTimeSlot: nil, basketDeliveryAddress: nil, memberProfile: nil)
        let appState = AppState(system: AppState.System(), routing: AppState.ViewRouting(), businessData: AppState.BusinessData(), userData: userData)
        let sut = makeSUT(container: DIContainer(appState: appState, eventLogger: MockedEventLogger(), services: .mocked()))
                          
        XCTAssertFalse(sut.showPayByCash)
    }
    
    func test_givenStoreSupportsCashWithCutoffTimeAndTodayWithTempSlotSelected_whenAfterCutoffTime_thenShowPayByCashIsFalse() {
        let timeTraveler = TimeTraveler()
        let dateNow = Date().startOfDay.addingTimeInterval(60*60*13) // 13:00
        timeTraveler.date = dateNow
        let cutofftime = dateNow.addingTimeInterval(60*60*3) // 16:00
        let startTime = dateNow.addingTimeInterval(60*60*3) // 16:00
        let endTime = dateNow.addingTimeInterval(60*60*4) // 17:00
        let paymentMethod = PaymentMethod(name: "cash", title: "cash", description: nil, settings: PaymentMethodSettings(title: "cash", instructions: nil, enabledForMethod: [.delivery], paymentGateways: ["cash"], saveCards: nil, cutOffTime: cutofftime.hourMinutesSecondsString(timeZone: nil)))
        let paymentGateway = PaymentGateway(name: "cash", mode: .sandbox, fields: nil)
        let storeDetails = RetailStoreDetails(id: 123, menuGroupId: 12, storeName: "", telephone: "", lat: 10, lng: 10, ordersPaused: false, canDeliver: true, distance: nil, pausedMessage: nil, address1: "", address2: nil, town: "", postcode: "", customerOrderNotePlaceholder: nil, memberEmailCheck: nil, guestCheckoutAllowed: true, basketOnlyTimeSelection: false, ratings: nil, tips: nil, storeLogo: nil, storeProductTypes: nil, orderMethods: nil, deliveryDays: [], collectionDays: [], paymentMethods: [paymentMethod], paymentGateways: [paymentGateway], allowedMarketingChannels: [], timeZone: nil, currency: RetailStoreCurrency.mockedGBPData, retailCustomer: nil, searchPostcode: nil, searchIsFirstOrder: nil)
        let basket = Basket.mockedDataIsAlcohol
        let tempTimeSlot = RetailStoreSlotDayTimeSlot(slotId: "4323", startTime: startTime, endTime: endTime, daytime: "", info: RetailStoreSlotDayTimeSlotInfo(status: "", isAsap: true, price: 10, fulfilmentIn: ""))
        let userData = AppState.UserData(selectedStore: .loaded(storeDetails), selectedFulfilmentMethod: .delivery, searchResult: .notRequested, basket: basket, currentFulfilmentLocation: nil, tempTodayTimeSlot: tempTimeSlot, basketDeliveryAddress: nil, memberProfile: nil)
        let appState = AppState(system: AppState.System(), routing: AppState.ViewRouting(), businessData: AppState.BusinessData(), userData: userData)
        let sut = makeSUT(container: DIContainer(appState: appState, eventLogger: MockedEventLogger(), services: .mocked()), dateGenerator: timeTraveler.generateDate)

        XCTAssertFalse(sut.showPayByCash)
    }
    
    func test_givenStoreSupportsCashWithCutoffTimeAndFutureSelected_whenBeforeCutoffTime_thenShowPayByCashIsTrue() {
        let cutofftime1600 = Date().addingTimeInterval(60*60*24).startOfDay.addingTimeInterval(60*60*16)
        let paymentMethod = PaymentMethod(name: "cash", title: "cash", description: nil, settings: PaymentMethodSettings(title: "cash", instructions: nil, enabledForMethod: [.delivery], paymentGateways: ["cash"], saveCards: nil, cutOffTime: cutofftime1600.hourMinutesSecondsString(timeZone: nil)))
        let paymentGateway = PaymentGateway(name: "cash", mode: .sandbox, fields: nil)
        let storeDetails = RetailStoreDetails(id: 123, menuGroupId: 12, storeName: "", telephone: "", lat: 10, lng: 10, ordersPaused: false, canDeliver: true, distance: nil, pausedMessage: nil, address1: "", address2: nil, town: "", postcode: "", customerOrderNotePlaceholder: nil, memberEmailCheck: nil, guestCheckoutAllowed: true, basketOnlyTimeSelection: false, ratings: nil, tips: nil, storeLogo: nil, storeProductTypes: nil, orderMethods: nil, deliveryDays: [], collectionDays: [], paymentMethods: [paymentMethod], paymentGateways: [paymentGateway], allowedMarketingChannels: [], timeZone: nil, currency: RetailStoreCurrency.mockedGBPData, retailCustomer: nil, searchPostcode: nil, searchIsFirstOrder: nil)
        let basket = Basket.mockedDataIsAlcoholTomorrow
        let userData = AppState.UserData(selectedStore: .loaded(storeDetails), selectedFulfilmentMethod: .delivery, searchResult: .notRequested, basket: basket, currentFulfilmentLocation: nil, tempTodayTimeSlot: nil, basketDeliveryAddress: nil, memberProfile: nil)
        let appState = AppState(system: AppState.System(), routing: AppState.ViewRouting(), businessData: AppState.BusinessData(), userData: userData)
        let sut = makeSUT(container: DIContainer(appState: appState, eventLogger: MockedEventLogger(), services: .mocked()))
                          
        XCTAssertTrue(sut.showPayByCash)
    }
    
    func test_givenStoreSupportsCashWithCutoffTimeAndFutureSelected_whenAfterCutoffTime_thenShowPayByCashIsFalse() {
        let cutofftime1300 = Date().addingTimeInterval(60*60*24).startOfDay.addingTimeInterval(60*60*13)
        let paymentMethod = PaymentMethod(name: "cash", title: "cash", description: nil, settings: PaymentMethodSettings(title: "cash", instructions: nil, enabledForMethod: [.delivery], paymentGateways: ["cash"], saveCards: nil, cutOffTime: cutofftime1300.hourMinutesSecondsString(timeZone: nil)))
        let paymentGateway = PaymentGateway(name: "cash", mode: .sandbox, fields: nil)
        let storeDetails = RetailStoreDetails(id: 123, menuGroupId: 12, storeName: "", telephone: "", lat: 10, lng: 10, ordersPaused: false, canDeliver: true, distance: nil, pausedMessage: nil, address1: "", address2: nil, town: "", postcode: "", customerOrderNotePlaceholder: nil, memberEmailCheck: nil, guestCheckoutAllowed: true, basketOnlyTimeSelection: false, ratings: nil, tips: nil, storeLogo: nil, storeProductTypes: nil, orderMethods: nil, deliveryDays: [], collectionDays: [], paymentMethods: [paymentMethod], paymentGateways: [paymentGateway], allowedMarketingChannels: [], timeZone: nil, currency: RetailStoreCurrency.mockedGBPData, retailCustomer: nil, searchPostcode: nil, searchIsFirstOrder: nil)
        let basket = Basket.mockedDataIsAlcoholTomorrow
        let userData = AppState.UserData(selectedStore: .loaded(storeDetails), selectedFulfilmentMethod: .delivery, searchResult: .notRequested, basket: basket, currentFulfilmentLocation: nil, tempTodayTimeSlot: nil, basketDeliveryAddress: nil, memberProfile: nil)
        let appState = AppState(system: AppState.System(), routing: AppState.ViewRouting(), businessData: AppState.BusinessData(), userData: userData)
        let sut = makeSUT(container: DIContainer(appState: appState, eventLogger: MockedEventLogger(), services: .mocked()))
                          
        XCTAssertFalse(sut.showPayByCash)
    }
    
    func test_givenTempTodayTimeSlot_whenPayByCashTapped_thenCreateDraftOrderTriggersAndDoNotSendEvent() async {
        let today = Date().startOfDay
        let slotStartTime = today.addingTimeInterval(60*30)
        let slotEndTime = today.addingTimeInterval(60*60)
        let draftOrderTimeRequest = DraftOrderFulfilmentDetailsTimeRequest(date: today.dateOnlyString(storeTimeZone: nil), requestedTime: "\(slotStartTime.hourMinutesString(timeZone: nil)) - \(slotEndTime.hourMinutesString(timeZone: nil))")
        let draftOrderDetailRequest = DraftOrderFulfilmentDetailsRequest(time: draftOrderTimeRequest, place: nil)
        let tempTodayTimeSlot = RetailStoreSlotDayTimeSlot(slotId: "123", startTime: slotStartTime, endTime: slotEndTime, daytime: "", info: RetailStoreSlotDayTimeSlotInfo(status: "", isAsap: true, price: 5, fulfilmentIn: ""))
        let userData = AppState.UserData(selectedStore: .notRequested, selectedFulfilmentMethod: .delivery, searchResult: .notRequested, basket: nil, currentFulfilmentLocation: nil, tempTodayTimeSlot: tempTodayTimeSlot, basketDeliveryAddress: nil, memberProfile: nil)
        let appState = AppState(system: AppState.System(), routing: AppState.ViewRouting(), businessData: AppState.BusinessData(), userData: userData)
        let eventLogger = MockedEventLogger()
        let container = DIContainer(appState: appState, eventLogger: eventLogger, services: .mocked(checkoutService: [.createDraftOrder(fulfilmentDetails: draftOrderDetailRequest, paymentGateway: .cash, instructions: nil)]))
        var checkoutState: CheckoutRootViewModel.CheckoutState?
        let sut = makeSUT(container: container, checkoutState: { state in
            checkoutState = state
        })
        sut.hasConfirmedCashPayment = true
        
        await sut.payByCashTapped()
        
        XCTAssertFalse(sut.processingPayByCash)
        XCTAssertEqual(checkoutState, .paymentSuccess)
        container.services.verify(as: .checkout)
        eventLogger.verify()
    }
    
    func test_givenTempTodayTimeSlot_whenPayByCashNotTapped_thenDoNotCreateDraftOrderTriggersAndDoSendEvent() async {
        let today = Date().startOfDay
        let slotStartTime = today.addingTimeInterval(60*30)
        let slotEndTime = today.addingTimeInterval(60*60)
        let draftOrderTimeRequest = DraftOrderFulfilmentDetailsTimeRequest(date: today.dateOnlyString(storeTimeZone: nil), requestedTime: "\(slotStartTime.hourMinutesString(timeZone: nil)) - \(slotEndTime.hourMinutesString(timeZone: nil))")
        let draftOrderDetailRequest = DraftOrderFulfilmentDetailsRequest(time: draftOrderTimeRequest, place: nil)
        let tempTodayTimeSlot = RetailStoreSlotDayTimeSlot(slotId: "123", startTime: slotStartTime, endTime: slotEndTime, daytime: "", info: RetailStoreSlotDayTimeSlotInfo(status: "", isAsap: true, price: 5, fulfilmentIn: ""))
        let userData = AppState.UserData(selectedStore: .notRequested, selectedFulfilmentMethod: .delivery, searchResult: .notRequested, basket: nil, currentFulfilmentLocation: nil, tempTodayTimeSlot: tempTodayTimeSlot, basketDeliveryAddress: nil, memberProfile: nil)
        let appState = AppState(system: AppState.System(), routing: AppState.ViewRouting(), businessData: AppState.BusinessData(), userData: userData)
        let eventLogger = MockedEventLogger(expected: [.sendEvent(for: .payByCashSelected, with: .firebaseAnalytics, params: [:])])
        let container = DIContainer(appState: appState, eventLogger: eventLogger, services: .mocked())
        var checkoutState: CheckoutRootViewModel.CheckoutState?
        let sut = makeSUT(container: container, checkoutState: { state in
            checkoutState = state
        })
        
        await sut.payByCashTapped()
        
        XCTAssertFalse(sut.processingPayByCash)
        XCTAssertNil(checkoutState)
        container.services.verify(as: .checkout)
        eventLogger.verify()
    }
    
    func test_givenBasketTimeSlot_whenPayByCashTapped_thenCreateDraftOrderTriggersAndDoNotSendEvent() async {
        let today = Date().startOfDay
        let slotStartTime = today.addingTimeInterval(60*30)
        let slotEndTime = today.addingTimeInterval(60*60)
        let draftOrderTimeRequest = DraftOrderFulfilmentDetailsTimeRequest(date: today.dateOnlyString(storeTimeZone: nil), requestedTime: "\(slotStartTime.hourMinutesString(timeZone: nil)) - \(slotEndTime.hourMinutesString(timeZone: nil))")
        let draftOrderDetailRequest = DraftOrderFulfilmentDetailsRequest(time: draftOrderTimeRequest, place: nil)
        
        let basket = Basket(
            basketToken: "",
            isNewBasket: true,
            items: [],
            fulfilmentMethod: .init(
                type: .delivery,
                cost: 1.5,
                minSpend: 0,
                zoneFreeDeliveryMessage: nil,
                minBasketSpendForNextDeliveryTier: nil,
                nextTierSpendIsHigherThanCurrent: false,
                minAdditionalBasketSpendForNextTier: nil,
                nextTierDeliveryCost: nil),
            selectedSlot: BasketSelectedSlot(
                todaySelected: true,
                start: slotStartTime,
                end: slotEndTime,
                expires: nil),
            savings: nil,
            coupon: nil,
            fees: nil,
            tips: nil,
            addresses: nil,
            orderSubtotal: 10,
            orderTotal: 11,
            storeId: nil,
            basketItemRemoved: nil)
        
        let userData = AppState.UserData(selectedStore: .notRequested, selectedFulfilmentMethod: .delivery, searchResult: .notRequested, basket: basket, currentFulfilmentLocation: nil, tempTodayTimeSlot: nil, basketDeliveryAddress: nil, memberProfile: nil)
        let appState = AppState(system: AppState.System(), routing: AppState.ViewRouting(), businessData: AppState.BusinessData(), userData: userData)
        let eventLogger = MockedEventLogger()
        let container = DIContainer(appState: appState, eventLogger: eventLogger, services: .mocked(checkoutService: [.createDraftOrder(fulfilmentDetails: draftOrderDetailRequest, paymentGateway: .cash, instructions: nil)]))
        var checkoutState: CheckoutRootViewModel.CheckoutState?
        let sut = makeSUT(container: container, checkoutState: { state in
            checkoutState = state
        })
        sut.hasConfirmedCashPayment = true
        
        await sut.payByCashTapped()
        
        XCTAssertFalse(sut.processingPayByCash)
        XCTAssertEqual(checkoutState, .paymentSuccess)
        container.services.verify(as: .checkout)
        eventLogger.verify()
    }
    
    func test_givenBusinessOrderId_whenHandleGlobalPaymentResultCalled_thenOutcomeSuccessful() {
        var checkoutState: CheckoutRootViewModel.CheckoutState?
        let eventLogger = MockedEventLogger()
        let container = DIContainer(appState: AppState(), eventLogger: eventLogger, services: .mocked())
        let sut = makeSUT(container: container, checkoutState: { state in
            checkoutState = state
        })
        
        sut.handleGlobalPaymentResult(businessOrderId: 123, error: nil)
        
        XCTAssertEqual(checkoutState, .paymentSuccess)
        eventLogger.verify()
    }
    
    func test_givenBusinessOrderIdAsNilAndError_whenHandleGlobalPaymentResultCalled_thenOutcomeUnsuccessful() {
        
        let basket = Basket.mockedData
        let member = MemberProfile.mockedData
        var totalItemQuantity: Int = 0
        for item in basket.items {
            totalItemQuantity += item.quantity
        }
        
        let appsFlyerParams: [String: Any] = [
            "order_id": 45565,
            "quantity": totalItemQuantity,
            "price": basket.orderTotal,
            "payment_method": "globalpayments",
            "payment_type": "card",
            "member_id": member.uuid,
            "error": GlobalpaymentsHPPViewInternalError.missingSettingFields(["hppURL"]).localizedDescription
        ]
        
        let firebaseParams: [String: Any] = [
            "order_id": 45565,
            "gateway": "globalpayments",
            "payment_type": "card",
            "error": GlobalpaymentsHPPViewInternalError.missingSettingFields(["hppURL"]).localizedDescription
        ]
        
        let eventLogger = MockedEventLogger(expected: [
            .sendEvent(for: .paymentFailure, with: .appsFlyer, params: appsFlyerParams),
            .sendEvent(for: .paymentFailure, with: .firebaseAnalytics, params: firebaseParams)
        ])
        var appState = AppState()
        appState.userData.basket = basket
        appState.userData.memberProfile = member
        
        let checkoutService = MockedCheckoutService(expected: [])
        checkoutService.currentDraftOrderIdResult = 45565
        
        let services = DIContainer.Services(
            businessProfileService: MockedBusinessProfileService(expected: []),
            retailStoreService: MockedRetailStoreService(expected: []),
            retailStoreMenuService: MockedRetailStoreMenuService(expected: []),
            basketService: MockedBasketService(expected: []),
            memberService: MockedUserService(expected: []),
            checkoutService: checkoutService,
            addressService: MockedAddressService(expected: []),
            utilityService: MockedUtilityService(expected: []),
            imageService: MockedAsyncImageService(expected: []),
            notificationService: MockedNotificationService(expected: []),
            userPermissionsService: MockedUserPermissionsService(expected: []),
            searchHistoryService: MockedSearchHistoryService(expected: [])
        )
        
        let container = DIContainer(appState: appState, eventLogger: eventLogger, services: services)
        let sut = makeSUT(container: container, checkoutState: { _ in })
        
        sut.handleGlobalPaymentResult(businessOrderId: nil, error: GlobalpaymentsHPPViewInternalError.missingSettingFields(["hppURL"]))
        
        XCTAssertNotNil(sut.container.appState.value.errors.first)
        eventLogger.verify()
    }
    
    func test_givenStoreWithMultiplePaymentMethods_whenInit_thenPaymentMethodsOrderIsInCorrectOrder() {
        let store = RetailStoreDetails.mockedDataWithCheckoutComApplePay
        let container = DIContainer(appState: AppState(), eventLogger: MockedEventLogger(), services: .mocked())
        container.appState.value.userData.selectedStore = .loaded(store)
        let sut = makeSUT(container: container)
        
        XCTAssertEqual(sut.paymentMethodsOrder, [.payByCash, .payByApple, .payByCard])
    }
    
    func makeSUT(container: DIContainer = DIContainer(appState: AppState(), eventLogger: MockedEventLogger(), services: .mocked()), checkoutState: @escaping (CheckoutRootViewModel.CheckoutState) -> Void = {_ in }, dateGenerator: @escaping () -> Date = Date.init) -> CheckoutFulfilmentInfoViewModel {
        let sut = CheckoutFulfilmentInfoViewModel(container: container, checkoutState: checkoutState, dateGenerator: dateGenerator)
        
        trackForMemoryLeaks(sut)
        
        return sut
    }
    
    static let fulfilmentLocation = FulfilmentLocation(country: "UK", latitude: 0, longitude: 0, postcode: "TN223HY")
    
    static let storeSearch = RetailStoresSearch(storeProductTypes: nil, stores: nil, fulfilmentLocation: fulfilmentLocation)
}

class TimeTraveler {
    var date = Date()
    
    func travel(by timeInterval: TimeInterval) {
        date = date.addingTimeInterval(timeInterval)
    }
    
    func generateDate() -> Date {
        return date
    }
}
