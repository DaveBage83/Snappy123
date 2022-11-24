//
//  BasketViewModelTests.swift
//  SnappyV2Tests
//
//  Created by Henrik Gustavii on 23/12/2021.
//

import XCTest
import Combine

// 3rd parties
import AppsFlyerLib
import Firebase

@testable import SnappyV2

@MainActor
class BasketViewModelTests: XCTestCase {
    
    func test_init() {
        let sut = makeSUT()
        XCTAssertEqual(sut.container.appState.value, AppState())
        XCTAssertNil(sut.basket)
        XCTAssertTrue(sut.couponCode.isEmpty)
        XCTAssertFalse(sut.applyingCoupon)
        XCTAssertFalse(sut.removingCoupon)
        XCTAssertNil(sut.successfulCouponText)
        XCTAssertFalse(sut.couponFieldHasError)
        XCTAssertFalse(sut.isUpdatingItem)
        XCTAssertFalse(sut.showingServiceFeeAlert)
        XCTAssertFalse(sut.isMemberSignedIn)
        XCTAssertFalse(sut.showDriverTips)
        XCTAssertFalse(sut.showBasketItems)
        XCTAssertEqual(sut.driverTip, 0)
        XCTAssertFalse(sut.showCouponAlert)
        XCTAssertNil(sut.unmetCouponMemberAccountRequirement)
    }
    
    func test_whenBasketIsNil_thenBasketIsEmptyIsTrue() {
        let storeDetails = RetailStoreDetails(id: 123, menuGroupId: 12, storeName: "", telephone: "", lat: 10, lng: 10, ordersPaused: false, canDeliver: true, distance: nil, pausedMessage: nil, address1: "", address2: nil, town: "", postcode: "", customerOrderNotePlaceholder: nil, memberEmailCheck: nil, guestCheckoutAllowed: true, basketOnlyTimeSelection: false, ratings: nil, tips: nil, storeLogo: nil, storeProductTypes: nil, orderMethods: nil, deliveryDays: [], collectionDays: [], paymentMethods: nil, paymentGateways: nil, allowedMarketingChannels: [], timeZone: nil, currency: RetailStoreCurrency.mockedGBPData, retailCustomer: nil, searchPostcode: nil)
        
        let userData = AppState.UserData(selectedStore: .loaded(storeDetails), selectedFulfilmentMethod: .delivery, searchResult: .notRequested, basket: nil, currentFulfilmentLocation: nil, tempTodayTimeSlot: nil, basketDeliveryAddress: nil, memberProfile: nil)
        
        let appState = AppState(system: AppState.System(), routing: AppState.ViewRouting(), businessData: AppState.BusinessData(), userData: userData)
        let container = DIContainer(appState: appState, eventLogger: MockedEventLogger(), services: .mocked())
        
        let sut = makeSUT(container: container)
        
        XCTAssertTrue(sut.basketIsEmpty)
    }
    
    func test_basketItemsAreEmpty_thenBasketIsEmptyIsTrue() {
        let storeDetails = RetailStoreDetails(id: 123, menuGroupId: 12, storeName: "", telephone: "", lat: 10, lng: 10, ordersPaused: false, canDeliver: true, distance: nil, pausedMessage: nil, address1: "", address2: nil, town: "", postcode: "", customerOrderNotePlaceholder: nil, memberEmailCheck: nil, guestCheckoutAllowed: true, basketOnlyTimeSelection: false, ratings: nil, tips: nil, storeLogo: nil, storeProductTypes: nil, orderMethods: nil, deliveryDays: [], collectionDays: [], paymentMethods: nil, paymentGateways: nil, allowedMarketingChannels: [], timeZone: nil, currency: RetailStoreCurrency.mockedGBPData, retailCustomer: nil, searchPostcode: nil)
        
        let basket = Basket(basketToken: "", isNewBasket: true, items: [], fulfilmentMethod: BasketFulfilmentMethod(type: .delivery, cost: 1, minSpend: 10), selectedSlot: nil, savings: nil, coupon: nil, fees: nil, tips: nil, addresses: nil, orderSubtotal: 8, orderTotal: 10, storeId: nil, basketItemRemoved: nil)
        
        let userData = AppState.UserData(selectedStore: .loaded(storeDetails), selectedFulfilmentMethod: .delivery, searchResult: .notRequested, basket: basket, currentFulfilmentLocation: nil, tempTodayTimeSlot: nil, basketDeliveryAddress: nil, memberProfile: nil)
        
        let appState = AppState(system: AppState.System(), routing: AppState.ViewRouting(), businessData: AppState.BusinessData(), userData: userData)
        let container = DIContainer(appState: appState, eventLogger: MockedEventLogger(), services: .mocked())
        
        let sut = makeSUT(container: container)
        
        XCTAssertTrue(sut.basketIsEmpty)
    }
    
    func test_whenStartShoppingPressed_thenSelectedTabSwitchedToMenu() {
        let sut = makeSUT()
        sut.startShoppingPressed()
        XCTAssertEqual(sut.container.appState.value.routing.selectedTab, .menu)
    }
    
    func test_whenApplyCouponTapped_givenCouponIsEmpty_thenError() async {
        let eventLogger = MockedEventLogger()
        let container = DIContainer(appState: AppState(), eventLogger: eventLogger, services: .mocked())
        let sut = makeSUT(container: container)
        
        // white spaces should be removed
        sut.couponCode = "  ";
        await sut.submitCoupon()
        
        XCTAssertTrue(sut.couponFieldHasError)
        XCTAssertEqual(sut.couponCode, "")
        // no events should be sent
        eventLogger.verify()
    }
    
    func test_basketItemsAreNotEmpty_thenBasketIsEmptyIsTrue() {
        let storeDetails = RetailStoreDetails(id: 123, menuGroupId: 12, storeName: "", telephone: "", lat: 10, lng: 10, ordersPaused: false, canDeliver: true, distance: nil, pausedMessage: nil, address1: "", address2: nil, town: "", postcode: "", customerOrderNotePlaceholder: nil, memberEmailCheck: nil, guestCheckoutAllowed: true, basketOnlyTimeSelection: false, ratings: nil, tips: nil, storeLogo: nil, storeProductTypes: nil, orderMethods: nil, deliveryDays: [], collectionDays: [], paymentMethods: nil, paymentGateways: nil, allowedMarketingChannels: [], timeZone: nil, currency: RetailStoreCurrency.mockedGBPData, retailCustomer: nil, searchPostcode: nil)
        
        let basket = Basket(basketToken: "", isNewBasket: true, items: [BasketItem.mockedData], fulfilmentMethod: BasketFulfilmentMethod(type: .delivery, cost: 1, minSpend: 10), selectedSlot: nil, savings: nil, coupon: nil, fees: nil, tips: nil, addresses: nil, orderSubtotal: 8, orderTotal: 10, storeId: nil, basketItemRemoved: nil)
        
        let userData = AppState.UserData(selectedStore: .loaded(storeDetails), selectedFulfilmentMethod: .delivery, searchResult: .notRequested, basket: basket, currentFulfilmentLocation: nil, tempTodayTimeSlot: nil, basketDeliveryAddress: nil, memberProfile: nil)
        
        let appState = AppState(system: AppState.System(), routing: AppState.ViewRouting(), businessData: AppState.BusinessData(), userData: userData)
        let container = DIContainer(appState: appState, eventLogger: MockedEventLogger(), services: .mocked())
        
        let sut = makeSUT(container: container)
        
        XCTAssertFalse(sut.basketIsEmpty)
    }
    
    func test_whenSlotExpiryIsAfterCurrentTime_thenSlotExpiredIsTrue() {
        
        let basket = Basket(basketToken: "aaabbb", isNewBasket: false, items: [], fulfilmentMethod: BasketFulfilmentMethod(type: .delivery, cost: 2.5, minSpend: 10), selectedSlot: BasketSelectedSlot.mockedYesterdaySlot, savings: nil, coupon: nil, fees: nil, tips: nil, addresses: nil, orderSubtotal: 1, orderTotal: 10, storeId: nil, basketItemRemoved: nil)
        let member = MemberProfile(uuid: "8b7b9a7e-efd9-11ec-8ea0-0242ac120002", firstname: "", lastname: "", emailAddress: "", type: .customer, referFriendCode: nil, referFriendBalance: 0, numberOfReferrals: 0, mobileContactNumber: nil, mobileValidated: false, acceptedMarketing: false, defaultBillingDetails: nil, savedAddresses: nil, fetchTimestamp: nil)
        let appState = AppState(system: .init(), routing: .init(), userData: .init(selectedStore: .notRequested, selectedFulfilmentMethod: .delivery, searchResult: .notRequested, basket: basket, memberProfile: member))
        let params: [String: Any] = [
            AFEventParamPrice:basket.orderTotal,
            AFEventParamContentId:[],
            AFEventParamCurrency:AppV2Constants.Business.currencyCode,
            AFEventParamQuantity:0,
            "member_id":member.uuid
        ]
        let eventLogger = MockedEventLogger(expected: [.sendEvent(for: .initiatedCheckout, with: .appsFlyer, params: params)])
        let container = DIContainer(appState: appState, eventLogger: eventLogger, services: .mocked())
        let sut = makeSUT(container: container)
                
        XCTAssertTrue(sut.isSlotExpired)
    }
    
    func test_whenSlotIsExpired_thenShowCheckoutButtonIsFalse() {
        
        let basket = Basket(basketToken: "aaabbb", isNewBasket: false, items: [], fulfilmentMethod: BasketFulfilmentMethod(type: .delivery, cost: 2.5, minSpend: 10), selectedSlot: BasketSelectedSlot.mockedYesterdaySlot, savings: nil, coupon: nil, fees: nil, tips: nil, addresses: nil, orderSubtotal: 1, orderTotal: 10, storeId: nil, basketItemRemoved: nil)
        let member = MemberProfile(uuid: "8b7b9a7e-efd9-11ec-8ea0-0242ac120002", firstname: "", lastname: "", emailAddress: "", type: .customer, referFriendCode: nil, referFriendBalance: 0, numberOfReferrals: 0, mobileContactNumber: nil, mobileValidated: false, acceptedMarketing: false, defaultBillingDetails: nil, savedAddresses: nil, fetchTimestamp: nil)
        let appState = AppState(system: .init(), routing: .init(), userData: .init(selectedStore: .notRequested, selectedFulfilmentMethod: .delivery, searchResult: .notRequested, basket: basket, memberProfile: member))
        let params: [String: Any] = [
            AFEventParamPrice:basket.orderTotal,
            AFEventParamContentId:[],
            AFEventParamCurrency:AppV2Constants.Business.currencyCode,
            AFEventParamQuantity:0,
            "member_id":member.uuid
        ]
        let eventLogger = MockedEventLogger(expected: [.sendEvent(for: .initiatedCheckout, with: .appsFlyer, params: params)])
        let container = DIContainer(appState: appState, eventLogger: eventLogger, services: .mocked())
        let sut = makeSUT(container: container)
                
        XCTAssertTrue(sut.isSlotExpired)
        XCTAssertFalse(sut.showCheckoutButton)
    }
    
    func test_whenMinSpendNotReached_thenMinSpendReachedIsFalse() {
        let storeDetails = RetailStoreDetails(id: 123, menuGroupId: 12, storeName: "", telephone: "", lat: 10, lng: 10, ordersPaused: false, canDeliver: true, distance: nil, pausedMessage: nil, address1: "", address2: nil, town: "", postcode: "", customerOrderNotePlaceholder: nil, memberEmailCheck: nil, guestCheckoutAllowed: true, basketOnlyTimeSelection: false, ratings: nil, tips: nil, storeLogo: nil, storeProductTypes: nil, orderMethods: nil, deliveryDays: [], collectionDays: [], paymentMethods: nil, paymentGateways: nil, allowedMarketingChannels: [], timeZone: nil, currency: RetailStoreCurrency.mockedGBPData, retailCustomer: nil, searchPostcode: nil)
        
        let basket = Basket(basketToken: "", isNewBasket: true, items: [], fulfilmentMethod: BasketFulfilmentMethod(type: .delivery, cost: 1, minSpend: 10), selectedSlot: nil, savings: nil, coupon: nil, fees: nil, tips: nil, addresses: nil, orderSubtotal: 8, orderTotal: 10, storeId: nil, basketItemRemoved: nil)
        
        let userData = AppState.UserData(selectedStore: .loaded(storeDetails), selectedFulfilmentMethod: .delivery, searchResult: .notRequested, basket: basket, currentFulfilmentLocation: nil, tempTodayTimeSlot: nil, basketDeliveryAddress: nil, memberProfile: nil)
        
        let appState = AppState(system: AppState.System(), routing: AppState.ViewRouting(), businessData: AppState.BusinessData(), userData: userData)
        let container = DIContainer(appState: appState, eventLogger: MockedEventLogger(), services: .mocked())
        
        let sut = makeSUT(container: container)
        
        XCTAssertFalse(sut.minimumSpendReached)
    }
    
    func test_unmetCouponMemberAccountRequirement_whenNoMember_thenSetToMemberRequiredForCoupon() {

        let basket = Basket.mockedDataVerifiedMemberRegisteredRequiredCoupon
        
        let appState = AppState(system: .init(), routing: .init(), userData: .init(selectedStore: .notRequested, selectedFulfilmentMethod: .delivery, searchResult: .notRequested, basket: basket, memberProfile: nil))

        let container = DIContainer(appState: appState, eventLogger: MockedEventLogger(), services: .mocked())
        let sut = makeSUT(container: container)
        
        XCTAssertEqual(sut.unmetCouponMemberAccountRequirement, BasketViewModel.BasketViewError.memberRequiredForCoupon)
    }
    
    func test_unmetCouponMemberAccountRequirement_whenMemberNotVerified_thenSetToVerifiedAccountRequiredForCouponWhenMobileNumber() {

        let basket = Basket.mockedDataVerifiedMemberRegisteredRequiredCoupon
        let member = MemberProfile.mockedDataMobileNotVerified
        
        let appState = AppState(system: .init(), routing: .init(), userData: .init(selectedStore: .notRequested, selectedFulfilmentMethod: .delivery, searchResult: .notRequested, basket: basket, memberProfile: member))

        let container = DIContainer(appState: appState, eventLogger: MockedEventLogger(), services: .mocked())
        let sut = makeSUT(container: container)
        
        XCTAssertEqual(sut.unmetCouponMemberAccountRequirement, BasketViewModel.BasketViewError.verifiedAccountRequiredForCouponWhenMobileNumber)
    }
    
    func test_unmetCouponMemberAccountRequirement_whenMemberHasNoMobile_thenSetToVerifiedAccountRequiredForCouponWhenNoMobileNumber() {

        let basket = Basket.mockedDataVerifiedMemberRegisteredRequiredCoupon
        let member = MemberProfile.mockedDataNoPhone
        
        let appState = AppState(system: .init(), routing: .init(), userData: .init(selectedStore: .notRequested, selectedFulfilmentMethod: .delivery, searchResult: .notRequested, basket: basket, memberProfile: member))

        let container = DIContainer(appState: appState, eventLogger: MockedEventLogger(), services: .mocked())
        let sut = makeSUT(container: container)
        
        XCTAssertEqual(sut.unmetCouponMemberAccountRequirement, BasketViewModel.BasketViewError.verifiedAccountRequiredForCouponWhenNoMobileNumber)
    }
    
    func test_setupBasket() {
        let basket = Basket(basketToken: "aaabbb", isNewBasket: false, items: [], fulfilmentMethod: BasketFulfilmentMethod(type: .delivery, cost: 2.5, minSpend: 10), selectedSlot: nil, savings: nil, coupon: nil, fees: nil, tips: nil, addresses: nil, orderSubtotal: 0, orderTotal: 0, storeId: nil, basketItemRemoved: nil)
        let appState = AppState(system: .init(), routing: .init(), userData: .init(selectedStore: .notRequested, selectedFulfilmentMethod: .delivery, searchResult: .notRequested, basket: basket, memberProfile: nil))
        let container = DIContainer(appState: appState, eventLogger: MockedEventLogger(), services: .mocked())
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
    
    func test_whenCheckoutTapped_givenMinSpendReached_thenIsContinueToCheckoutTappedTrueAndEventsTriggered() async {
        let storeDetails = RetailStoreDetails.mockedData
        let basket = Basket(basketToken: "aaabbb", isNewBasket: false, items: [], fulfilmentMethod: BasketFulfilmentMethod(type: .delivery, cost: 2.5, minSpend: 10), selectedSlot: nil, savings: nil, coupon: nil, fees: nil, tips: nil, addresses: nil, orderSubtotal: 10, orderTotal: 10, storeId: nil, basketItemRemoved: nil)
        let member = MemberProfile(uuid: "8b7b9a7e-efd9-11ec-8ea0-0242ac120002", firstname: "", lastname: "", emailAddress: "", type: .customer, referFriendCode: nil, referFriendBalance: 0, numberOfReferrals: 0, mobileContactNumber: nil, mobileValidated: false, acceptedMarketing: false, defaultBillingDetails: nil, savedAddresses: nil, fetchTimestamp: nil)
        let appState = AppState(system: .init(), routing: .init(), userData: .init(selectedStore: .loaded(storeDetails), selectedFulfilmentMethod: .delivery, searchResult: .notRequested, basket: basket, memberProfile: member))
        let appsFlyerParams: [String: Any] = [
            AFEventParamPrice:basket.orderTotal,
            AFEventParamContentId:[],
            AFEventParamCurrency:AppV2Constants.Business.currencyCode,
            AFEventParamQuantity:0,
            "member_id":member.uuid
        ]
        var firebaseParams: [String: Any] = [
            AnalyticsParameterItems: EventLogger.getFirebaseItemsArray(from: basket.items),
            AnalyticsParameterCurrency: storeDetails.currency.currencyCode,
            AnalyticsParameterValue: NSDecimalNumber(value: basket.orderTotal).rounding(accordingToBehavior: EventLogger.decimalBehavior).doubleValue
        ]
        if let coupon = basket.coupon {
            firebaseParams[AnalyticsParameterCoupon] = coupon.code
        }
        let eventLogger = MockedEventLogger(expected: [
            .sendEvent(for: .initiatedCheckout, with: .appsFlyer, params: appsFlyerParams),
            .sendEvent(for: .initiatedCheckout, with: .firebaseAnalytics, params: firebaseParams)
        ])
        let container = DIContainer(appState: appState, eventLogger: eventLogger, services: .mocked())
        let sut = makeSUT(container: container)
        
        await sut.checkoutTapped()
        
        XCTAssertTrue(sut.isContinueToCheckoutTapped)
        
        eventLogger.verify()
    }
    
    func test_whenCheckoutTapped_givenMinSpendNotReached_thenShowMinSpendError() async {
        let basket = Basket(basketToken: "aaabbb", isNewBasket: false, items: [], fulfilmentMethod: BasketFulfilmentMethod(type: .delivery, cost: 2.5, minSpend: 10), selectedSlot: nil, savings: nil, coupon: nil, fees: nil, tips: nil, addresses: nil, orderSubtotal: 1, orderTotal: 10, storeId: nil, basketItemRemoved: nil)
        let member = MemberProfile(uuid: "8b7b9a7e-efd9-11ec-8ea0-0242ac120002", firstname: "", lastname: "", emailAddress: "", type: .customer, referFriendCode: nil, referFriendBalance: 0, numberOfReferrals: 0, mobileContactNumber: nil, mobileValidated: false, acceptedMarketing: false, defaultBillingDetails: nil, savedAddresses: nil, fetchTimestamp: nil)
        let appState = AppState(system: .init(), routing: .init(), userData: .init(selectedStore: .notRequested, selectedFulfilmentMethod: .delivery, searchResult: .notRequested, basket: basket, memberProfile: member))
        let eventLogger = MockedEventLogger(expected: [.sendEvent(for: .checkoutBlockedByMinimumSpend, with: .firebaseAnalytics, params: [:])])
        let container = DIContainer(appState: appState, eventLogger: eventLogger, services: .mocked())
        let sut = makeSUT(container: container)
        
        await sut.checkoutTapped()
        
        XCTAssertEqual(sut.container.appState.value.latestError as? BasketViewModel.BasketViewError, BasketViewModel.BasketViewError.minimumSpendNotMet)
        eventLogger.verify()
    }
    
    func test_whenCheckoutTapped_givenUnmetCouponMemberAccountRequirement_thenSetErrorNeedsUserAction() async {
        let basket = Basket.mockedDataVerifiedMemberRegisteredRequiredCoupon
        let member = MemberProfile.mockedDataNoPhone
        
        let appState = AppState(system: .init(), routing: .init(), userData: .init(selectedStore: .notRequested, selectedFulfilmentMethod: .delivery, searchResult: .notRequested, basket: basket, memberProfile: member))

        let container = DIContainer(appState: appState, eventLogger: MockedEventLogger(), services: .mocked())
        let sut = makeSUT(container: container)
        
        await sut.checkoutTapped()
        
        XCTAssertNotNil(sut.unmetCouponMemberAccountRequirement)
        XCTAssertEqual(sut.container.appState.value.latestError as? BasketViewModel.BasketViewError, sut.unmetCouponMemberAccountRequirement)
        // check that the requestMobileVerificationCode was NOT called
        container.services.verify(as: .member)
    }
    
    func test_whenCheckoutTapped_givenVerifiedAccountRequiredForCouponWhenMobileNumber_thenRequestMobileVerificationCode() async {
        let basket = Basket.mockedDataVerifiedMemberRegisteredRequiredCoupon
        let member = MemberProfile.mockedDataMobileNotVerified
        
        let appState = AppState(system: .init(), routing: .init(), userData: .init(selectedStore: .notRequested, selectedFulfilmentMethod: .delivery, searchResult: .notRequested, basket: basket, memberProfile: member))
        
        var memberService = MockedUserService(expected: [.requestMobileVerificationCode])
        memberService.requestMobileVerificationCodeResponse = .success(true)
        
        let services = DIContainer.Services(
            businessProfileService: MockedBusinessProfileService(expected: []),
            retailStoreService: MockedRetailStoreService(expected: []),
            retailStoreMenuService: MockedRetailStoreMenuService(expected: []),
            basketService: MockedBasketService(expected: []),
            memberService: memberService,
            checkoutService: MockedCheckoutService(expected: []),
            addressService: MockedAddressService(expected: []),
            utilityService: MockedUtilityService(expected: []),
            imageService: MockedAsyncImageService(expected: []),
            notificationService: MockedNotificationService(expected: []),
            userPermissionsService: MockedUserPermissionsService(expected: [])
        )

        let container = DIContainer(appState: appState, eventLogger: MockedEventLogger(), services: services)
        let sut = makeSUT(container: container)
        
        await sut.checkoutTapped()
        
        XCTAssertEqual(sut.unmetCouponMemberAccountRequirement, BasketViewModel.BasketViewError.verifiedAccountRequiredForCouponWhenMobileNumber)
        XCTAssertNil(sut.container.appState.value.latestError)
        XCTAssertTrue(sut.container.appState.value.routing.showVerifyMobileView)
        // check that the requestMobileVerificationCode WAS called
        container.services.verify(as: .member)
    }
    
    func test_whenCheckoutTapped_givenVerifiedAccountRequiredForCouponWhenMobileNumberWithWebError_thenSetErrorNeedsUserAction() async {
        let networkError = NSError(domain: NSURLErrorDomain, code: -1009, userInfo: [:])
        let basket = Basket.mockedDataVerifiedMemberRegisteredRequiredCoupon
        let member = MemberProfile.mockedDataMobileNotVerified
        
        let appState = AppState(system: .init(), routing: .init(), userData: .init(selectedStore: .notRequested, selectedFulfilmentMethod: .delivery, searchResult: .notRequested, basket: basket, memberProfile: member))
        
        var memberService = MockedUserService(expected: [.requestMobileVerificationCode])
        memberService.requestMobileVerificationCodeResponse = .failure(networkError)
        
        let services = DIContainer.Services(
            businessProfileService: MockedBusinessProfileService(expected: []),
            retailStoreService: MockedRetailStoreService(expected: []),
            retailStoreMenuService: MockedRetailStoreMenuService(expected: []),
            basketService: MockedBasketService(expected: []),
            memberService: memberService,
            checkoutService: MockedCheckoutService(expected: []),
            addressService: MockedAddressService(expected: []),
            utilityService: MockedUtilityService(expected: []),
            imageService: MockedAsyncImageService(expected: []),
            notificationService: MockedNotificationService(expected: []),
            userPermissionsService: MockedUserPermissionsService(expected: [])
        )

        let container = DIContainer(appState: appState, eventLogger: MockedEventLogger(), services: services)
        let sut = makeSUT(container: container)
        
        await sut.checkoutTapped()
        
        XCTAssertEqual(sut.unmetCouponMemberAccountRequirement, BasketViewModel.BasketViewError.verifiedAccountRequiredForCouponWhenMobileNumber)
        XCTAssertEqual(sut.container.appState.value.latestError as? BasketViewModel.BasketViewError, sut.unmetCouponMemberAccountRequirement)
        XCTAssertFalse(sut.container.appState.value.routing.showVerifyMobileView)
        // check that the requestMobileVerificationCode WAS called
        container.services.verify(as: .member)
    }
    
    func test_givenBasketPopulated_whenSubmittingCouponCode_thenApplyingCouponChangesAndApplyCouponTriggers() async {
        // the coupon needs to be in the basket for the events because the MocketBasketService does
        // not have access to the app state to simulate updating
        let coupon = BasketCoupon.mockedData
        let basket = Basket(basketToken: "aaabbb", isNewBasket: false, items: [], fulfilmentMethod: BasketFulfilmentMethod(type: .delivery, cost: 2.5, minSpend: 10), selectedSlot: nil, savings: nil, coupon: coupon, fees: nil, tips: nil, addresses: nil, orderSubtotal: 0, orderTotal: 0, storeId: nil, basketItemRemoved: nil)
        let appState = AppState(system: .init(), routing: .init(), userData: .init(selectedStore: .notRequested, selectedFulfilmentMethod: .delivery, searchResult: .notRequested, basket: basket, memberProfile: MemberProfile.mockedData))
        
        // add whitespaces to test their automatic removal
        let code = "  " + coupon.code + "  "
        let trimmedCode = code.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        
        var basketService = MockedBasketService(expected: [.applyCoupon(code: trimmedCode)])
        basketService.applyCouponResponse = .success(true)
        
        let services = DIContainer.Services(
            businessProfileService: MockedBusinessProfileService(expected: []),
            retailStoreService: MockedRetailStoreService(expected: []),
            retailStoreMenuService: MockedRetailStoreMenuService(expected: []),
            basketService: basketService,
            memberService: MockedUserService(expected: []),
            checkoutService: MockedCheckoutService(expected: []),
            addressService: MockedAddressService(expected: []),
            utilityService: MockedUtilityService(expected: []),
            imageService: MockedAsyncImageService(expected: []),
            notificationService: MockedNotificationService(expected: []),
            userPermissionsService: MockedUserPermissionsService(expected: [])
        )
        
        let eventLogger = MockedEventLogger(expected: [
            .sendEvent(for: .applyCouponPressed, with: .firebaseAnalytics, params: [AnalyticsParameterCoupon: trimmedCode]),
            .sendEvent(for: .couponAppliedAtBaskedView, with: .firebaseAnalytics, params: [
                AnalyticsParameterCoupon: trimmedCode,
                "value": -coupon.deductCost
            ])
        ])
        let container = DIContainer(appState: appState, eventLogger: eventLogger, services: services)
        let sut = makeSUT(container: container)
        sut.couponCode = code
        
        await sut.submitCoupon()
        
        XCTAssertFalse(sut.applyingCoupon)
        XCTAssertEqual(sut.successfulCouponText, Strings.BasketView.Coupon.Customisable.successfullyAddedCoupon.localizedFormat(trimmedCode))
        XCTAssertTrue(sut.couponCode.isEmpty)
        eventLogger.verify()
        container.services.verify(as: .basket)
        // check that the requestMobileVerificationCode was NOT called
        container.services.verify(as: .member)
    }
    
    func test_givenBasketPopulated_whenSubmittingInvalidCouponCode_thenApplyingCouponChangesAndCouponAppliedUnsuccessfulltIsTrue() async {
        let basket = Basket(basketToken: "aaabbb", isNewBasket: false, items: [], fulfilmentMethod: BasketFulfilmentMethod(type: .delivery, cost: 2.5, minSpend: 10), selectedSlot: nil, savings: nil, coupon: nil, fees: nil, tips: nil, addresses: nil, orderSubtotal: 0, orderTotal: 0, storeId: nil, basketItemRemoved: nil)
        let appState = AppState(system: .init(), routing: .init(), userData: .init(selectedStore: .notRequested, selectedFulfilmentMethod: .delivery, searchResult: .notRequested, basket: basket, memberProfile: nil))
        
        let code = "FAIL"
        
        var basketService = MockedBasketService(expected: [.applyCoupon(code: code)])
        basketService.applyCouponResponse = .failure(BasketServiceError.unableToProceedWithoutBasket)
        
        let services = DIContainer.Services(
            businessProfileService: MockedBusinessProfileService(expected: []),
            retailStoreService: MockedRetailStoreService(expected: []),
            retailStoreMenuService: MockedRetailStoreMenuService(expected: []),
            basketService: basketService,
            memberService: MockedUserService(expected: []),
            checkoutService: MockedCheckoutService(expected: []),
            addressService: MockedAddressService(expected: []),
            utilityService: MockedUtilityService(expected: []),
            imageService: MockedAsyncImageService(expected: []),
            notificationService: MockedNotificationService(expected: []),
            userPermissionsService: MockedUserPermissionsService(expected: [])
        )
        
        let eventLogger = MockedEventLogger(expected: [
            .sendEvent(for: .applyCouponPressed, with: .firebaseAnalytics, params: [AnalyticsParameterCoupon: code]),
            .sendEvent(for: .couponRejectedAtBasketView, with: .firebaseAnalytics, params: [
                AnalyticsParameterCoupon: code,
                "error": BasketServiceError.unableToProceedWithoutBasket.localizedDescription
            ])
        ])
        let container = DIContainer(appState: appState, eventLogger: eventLogger, services: services)
        let sut = makeSUT(container: container)
        sut.couponCode = code
        
        await sut.submitCoupon()
        
        XCTAssertFalse(sut.applyingCoupon)
        XCTAssertTrue(sut.couponFieldHasError)
        eventLogger.verify()
        container.services.verify(as: .basket)
        // check that the requestMobileVerificationCode was NOT called
        container.services.verify(as: .member)
    }
    
    func test_givenBasketPopulated_whenSubmittingVerifiedMemberRequiredAndMemberNotVerified_thenRequestMobileVerificationCode() async {
        
        // The mocked services do not update the Basket AppState model. In this test we are relying on
        // setting the basket to have a coupon with the special requirment before sut.submitCoupon()
        // knowing that coupon data will still be there to simulate the test requirement.
        let basket = Basket(basketToken: "aaabbb", isNewBasket: false, items: [], fulfilmentMethod: BasketFulfilmentMethod(type: .delivery, cost: 2.5, minSpend: 10), selectedSlot: nil, savings: nil, coupon: BasketCoupon.mockedDataWithVerifiedRegisteredRequirement, fees: nil, tips: nil, addresses: nil, orderSubtotal: 0, orderTotal: 0, storeId: nil, basketItemRemoved: nil)
        let appState = AppState(system: .init(), routing: .init(), userData: .init(selectedStore: .notRequested, selectedFulfilmentMethod: .delivery, searchResult: .notRequested, basket: basket, memberProfile: MemberProfile.mockedDataMobileNotVerified))
        
        let code = "VerifyME"
        
        var basketService = MockedBasketService(expected: [.applyCoupon(code: code)])
        basketService.applyCouponResponse = .success(true)
        
        var memberService = MockedUserService(expected: [.requestMobileVerificationCode])
        memberService.requestMobileVerificationCodeResponse = .success(true)
        
        let services = DIContainer.Services(
            businessProfileService: MockedBusinessProfileService(expected: []),
            retailStoreService: MockedRetailStoreService(expected: []),
            retailStoreMenuService: MockedRetailStoreMenuService(expected: []),
            basketService: basketService,
            memberService: memberService,
            checkoutService: MockedCheckoutService(expected: []),
            addressService: MockedAddressService(expected: []),
            utilityService: MockedUtilityService(expected: []),
            imageService: MockedAsyncImageService(expected: []),
            notificationService: MockedNotificationService(expected: []),
            userPermissionsService: MockedUserPermissionsService(expected: [])
        )
        
        let container = DIContainer(appState: appState, eventLogger: MockedEventLogger(), services: services)
        let sut = makeSUT(container: container)
        sut.couponCode = code
        
        await sut.submitCoupon()
        
        XCTAssertFalse(sut.applyingCoupon)
        XCTAssertEqual(sut.successfulCouponText, Strings.BasketView.Coupon.Customisable.successfullyAddedCoupon.localizedFormat(code))
        XCTAssertTrue(sut.couponCode.isEmpty)
        XCTAssertTrue(sut.container.appState.value.routing.showVerifyMobileView)
        
        container.services.verify(as: .basket)
        // check that the requestMobileVerificationCode WAS called
        container.services.verify(as: .member)
    }
    
    func test_givenBasketWithCoupon_whenRemovingCouponCode_thenRemovingCouponChangesAndRemoveCouponTriggers() async {
        let basket = Basket(basketToken: "aaabbb", isNewBasket: false, items: [], fulfilmentMethod: BasketFulfilmentMethod(type: .delivery, cost: 2.5, minSpend: 10), selectedSlot: nil, savings: nil, coupon: BasketCoupon(code: "", name: "", deductCost: 1, iterableCampaignId: nil, type: "set", value: 1, freeDelivery: false, registeredMemberRequirement: nil), fees: nil, tips: nil, addresses: nil, orderSubtotal: 0, orderTotal: 0, storeId: nil, basketItemRemoved: nil)
        let appState = AppState(system: .init(), routing: .init(), userData: .init(selectedStore: .notRequested, selectedFulfilmentMethod: .delivery, searchResult: .notRequested, basket: basket, memberProfile: nil))
        let container = DIContainer(appState: appState, eventLogger: MockedEventLogger(), services: .mocked(basketService: [.removeCoupon]))
        let sut = makeSUT(container: container)
        
        await sut.removeCoupon()
        
        XCTAssertFalse(sut.removingCoupon)
        
        container.services.verify(as: .basket)
    }
    
    func test_whenShowServiceFeeAlertIsTapped_thenShowingFeeInfoAlertIsTrue() {
        let sut = makeSUT()
        
        sut.showServiceFeeAlert(title: "Test title", description: "Test description")
        
        XCTAssertTrue(sut.showingServiceFeeAlert)
    }
    
    func test_whenDismissAlertIsTapped_thenShowingFeeInfoAlertIsFalse() {
        let sut = makeSUT()
        sut.showingServiceFeeAlert = true
        
        sut.dismissAlert()
        
        XCTAssertFalse(sut.showingServiceFeeAlert)
    }
    
    func test_givenBasketWithItem_whenUpdatebasketItem_thenIsUpdatingItemTriggers() async {
        let basketItem = BasketItem.mockedData
        let container = DIContainer(appState: AppState(), eventLogger: MockedEventLogger(), services: .mocked(basketService: [.updateItem(basketItemRequest: BasketItemRequest(menuItemId: basketItem.menuItem.id, quantity: 2, sizeId: 0, bannerAdvertId: 0, options: [], instructions: nil), basketItem: basketItem)]))
        let sut = makeSUT(container: container)
        
        await sut.updateBasketItem(basketItem: basketItem, quantity: 2)
        
        XCTAssertFalse(sut.isUpdatingItem)
        
        container.services.verify(as: .basket)
    }
    
    func test_givenDriverTipsEnabledAndCorrectTypeAndIsDelivery_thenBasketDriverTipsDisplaysAndIsCorrectAmountAndDisableDecreaseTipButtonIsTrue() {
        let driverTips = RetailStoreTip(enabled: true, defaultValue: 1, type: "driver", refundDriverTipsForLateOrders: nil, refundDriverTipsAfterLateByMinutes: nil)
        let storeDetails = RetailStoreDetails(id: 123, menuGroupId: 12, storeName: "", telephone: "", lat: 10, lng: 10, ordersPaused: false, canDeliver: true, distance: nil, pausedMessage: nil, address1: "", address2: nil, town: "", postcode: "", customerOrderNotePlaceholder: nil, memberEmailCheck: nil, guestCheckoutAllowed: true, basketOnlyTimeSelection: false, ratings: nil, tips: [driverTips], storeLogo: nil, storeProductTypes: nil, orderMethods: nil, deliveryDays: [], collectionDays: [], paymentMethods: nil, paymentGateways: nil, allowedMarketingChannels: [], timeZone: nil, currency: RetailStoreCurrency.mockedGBPData, retailCustomer: nil, searchPostcode: nil)
        let userData = AppState.UserData(selectedStore: .loaded(storeDetails), selectedFulfilmentMethod: .delivery, searchResult: .notRequested, basket: nil, currentFulfilmentLocation: nil, tempTodayTimeSlot: nil, basketDeliveryAddress: nil, memberProfile: nil)
        let appState = AppState(system: AppState.System(), routing: AppState.ViewRouting(), businessData: AppState.BusinessData(), userData: userData)
        let container = DIContainer(appState: appState, eventLogger: MockedEventLogger(), services: .mocked())
        
        let sut = makeSUT(container: container)
        
        XCTAssertTrue(sut.showDriverTips)
        XCTAssertEqual(sut.driverTip, 0)
        XCTAssertTrue(sut.disableDecreaseTipButton)
    }
    
    func test_givenDriverTipsEnabledAndCorrectTypeButIsCollection_thenBasketDriverTipsDOesNotDisplay() {
        let driverTips = RetailStoreTip(enabled: true, defaultValue: 1, type: "driver", refundDriverTipsForLateOrders: nil, refundDriverTipsAfterLateByMinutes: nil)
        let storeDetails = RetailStoreDetails(id: 123, menuGroupId: 12, storeName: "", telephone: "", lat: 10, lng: 10, ordersPaused: false, canDeliver: true, distance: nil, pausedMessage: nil, address1: "", address2: nil, town: "", postcode: "", customerOrderNotePlaceholder: nil, memberEmailCheck: nil, guestCheckoutAllowed: true, basketOnlyTimeSelection: false, ratings: nil, tips: [driverTips], storeLogo: nil, storeProductTypes: nil, orderMethods: nil, deliveryDays: [], collectionDays: [], paymentMethods: nil, paymentGateways: nil, allowedMarketingChannels: [], timeZone: nil, currency: RetailStoreCurrency.mockedGBPData, retailCustomer: nil, searchPostcode: nil)
        let userData = AppState.UserData(selectedStore: .loaded(storeDetails), selectedFulfilmentMethod: .collection, searchResult: .notRequested, basket: nil, currentFulfilmentLocation: nil, tempTodayTimeSlot: nil, basketDeliveryAddress: nil, memberProfile: nil)
        let appState = AppState(system: AppState.System(), routing: AppState.ViewRouting(), businessData: AppState.BusinessData(), userData: userData)
        let container = DIContainer(appState: appState, eventLogger: MockedEventLogger(), services: .mocked())
        
        let sut = makeSUT(container: container)
        
        XCTAssertFalse(sut.showDriverTips)
    }
    
    func test_givenDriverTipsDisabledAndCorrectTypeAndIsDelivery_thenBasketDriverTipsDoesNotDisplay() {
        let driverTips = RetailStoreTip(enabled: false, defaultValue: 1, type: "driver", refundDriverTipsForLateOrders: nil, refundDriverTipsAfterLateByMinutes: nil)
        let storeDetails = RetailStoreDetails(id: 123, menuGroupId: 12, storeName: "", telephone: "", lat: 10, lng: 10, ordersPaused: false, canDeliver: true, distance: nil, pausedMessage: nil, address1: "", address2: nil, town: "", postcode: "", customerOrderNotePlaceholder: nil, memberEmailCheck: nil, guestCheckoutAllowed: true, basketOnlyTimeSelection: false, ratings: nil, tips: [driverTips], storeLogo: nil, storeProductTypes: nil, orderMethods: nil, deliveryDays: [], collectionDays: [], paymentMethods: nil, paymentGateways: nil, allowedMarketingChannels: [], timeZone: nil, currency: RetailStoreCurrency.mockedGBPData, retailCustomer: nil, searchPostcode: nil)
        let userData = AppState.UserData(selectedStore: .loaded(storeDetails), selectedFulfilmentMethod: .collection, searchResult: .notRequested, basket: nil, currentFulfilmentLocation: nil, tempTodayTimeSlot: nil, basketDeliveryAddress: nil, memberProfile: nil)
        let appState = AppState(system: AppState.System(), routing: AppState.ViewRouting(), businessData: AppState.BusinessData(), userData: userData)
        let container = DIContainer(appState: appState, eventLogger: MockedEventLogger(), services: .mocked())
        
        let sut = makeSUT(container: container)
        
        XCTAssertFalse(sut.showDriverTips)
    }
    
    func test_givenDriverTipsEnabledAndIsDeliveryButIncorrectType_thenBasketDriverTipsDoesNotDisplay() {
        let driverTips = RetailStoreTip(enabled: false, defaultValue: 1, type: "somethingelse", refundDriverTipsForLateOrders: nil, refundDriverTipsAfterLateByMinutes: nil)
        let storeDetails = RetailStoreDetails(id: 123, menuGroupId: 12, storeName: "", telephone: "", lat: 10, lng: 10, ordersPaused: false, canDeliver: true, distance: nil, pausedMessage: nil, address1: "", address2: nil, town: "", postcode: "", customerOrderNotePlaceholder: nil, memberEmailCheck: nil, guestCheckoutAllowed: true, basketOnlyTimeSelection: false, ratings: nil, tips: [driverTips], storeLogo: nil, storeProductTypes: nil, orderMethods: nil, deliveryDays: [], collectionDays: [], paymentMethods: nil, paymentGateways: nil, allowedMarketingChannels: [], timeZone: nil, currency: RetailStoreCurrency.mockedGBPData, retailCustomer: nil, searchPostcode: nil)
        let userData = AppState.UserData(selectedStore: .loaded(storeDetails), selectedFulfilmentMethod: .collection, searchResult: .notRequested, basket: nil, currentFulfilmentLocation: nil, tempTodayTimeSlot: nil, basketDeliveryAddress: nil, memberProfile: nil)
        let appState = AppState(system: AppState.System(), routing: AppState.ViewRouting(), businessData: AppState.BusinessData(), userData: userData)
        let container = DIContainer(appState: appState, eventLogger: MockedEventLogger(), services: .mocked())
        
        let sut = makeSUT(container: container)
        
        XCTAssertFalse(sut.showDriverTips)
    }
    
    func test_givenTipInBasket_thenDriverTipCorrect() {
        let basketTip = BasketTip(type: "driver", amount: 2)
        let basket = Basket(basketToken: "", isNewBasket: true, items: [], fulfilmentMethod: BasketFulfilmentMethod(type: .delivery, cost: 1, minSpend: 10), selectedSlot: nil, savings: nil, coupon: nil, fees: nil, tips: [basketTip], addresses: nil, orderSubtotal: 10, orderTotal: 10, storeId: nil, basketItemRemoved: nil)
        let driverTips = RetailStoreTip(enabled: false, defaultValue: 1, type: "somethingelse", refundDriverTipsForLateOrders: nil, refundDriverTipsAfterLateByMinutes: nil)
        let storeDetails = RetailStoreDetails(id: 123, menuGroupId: 12, storeName: "", telephone: "", lat: 10, lng: 10, ordersPaused: false, canDeliver: true, distance: nil, pausedMessage: nil, address1: "", address2: nil, town: "", postcode: "", customerOrderNotePlaceholder: nil, memberEmailCheck: nil, guestCheckoutAllowed: true, basketOnlyTimeSelection: false, ratings: nil, tips: [driverTips], storeLogo: nil, storeProductTypes: nil, orderMethods: nil, deliveryDays: [], collectionDays: [], paymentMethods: nil, paymentGateways: nil, allowedMarketingChannels: [], timeZone: nil, currency: RetailStoreCurrency.mockedGBPData, retailCustomer: nil, searchPostcode: nil)
        let userData = AppState.UserData(selectedStore: .loaded(storeDetails), selectedFulfilmentMethod: .collection, searchResult: .notRequested, basket: basket, currentFulfilmentLocation: nil, tempTodayTimeSlot: nil, basketDeliveryAddress: nil, memberProfile: nil)
        let appState = AppState(system: AppState.System(), routing: AppState.ViewRouting(), businessData: AppState.BusinessData(), userData: userData)
        let container = DIContainer(appState: appState, eventLogger: MockedEventLogger(), services: .mocked())
        
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
        let storeItem = RetailStoreMenuItem(id: 132, name: "", eposCode: nil, outOfStock: false, ageRestriction: 0, description: nil, quickAdd: true, acceptCustomerInstructions: true, basketQuantityLimit: 0, price: RetailStoreMenuItemPrice(price: 10, fromPrice: 10, unitMetric: "", unitsInPack: 0, unitVolume: 0, wasPrice: nil), images: nil, menuItemSizes: nil, menuItemOptions: nil, availableDeals: nil, itemCaptions: nil, mainCategory: MenuItemCategory(id: 345, name: ""), itemDetails: nil, deal: nil)
        let basketItem = BasketItem(basketLineId: 123, menuItem: storeItem, totalPrice: 10, totalPriceBeforeDiscounts: 10, price: 10, pricePaid: 10, quantity: 1, instructions: nil, size: nil, selectedOptions: nil, missedPromotions: nil, isAlcohol: false)
        let basket = Basket(basketToken: "", isNewBasket: true, items: [basketItem], fulfilmentMethod: BasketFulfilmentMethod(type: .delivery, cost: 1, minSpend: 10), selectedSlot: nil, savings: nil, coupon: nil, fees: nil, tips: nil, addresses: nil, orderSubtotal: 10, orderTotal: 10, storeId: nil, basketItemRemoved: nil)
        let userData = AppState.UserData(selectedStore: .notRequested, selectedFulfilmentMethod: .collection, searchResult: .notRequested, basket: basket, currentFulfilmentLocation: nil, tempTodayTimeSlot: nil, basketDeliveryAddress: nil, memberProfile: nil)
        let appState = AppState(system: AppState.System(), routing: AppState.ViewRouting(), businessData: AppState.BusinessData(), userData: userData)
        let container = DIContainer(appState: appState, eventLogger: MockedEventLogger(), services: .mocked())
        
        let sut = makeSUT(container: container)
        
        XCTAssertTrue(sut.showBasketItems)
    }
    
    func test_givenBusinessProfile_whenDriverTipIs25p_thenTipLevelIsUnhappy() {
        let tipLevel1 = TipLimitLevel(level: 1, amount: 0.5, type: "driver", title: "neutral")
        let tipLevel2 = TipLimitLevel(level: 2, amount: 1, type: "driver", title: "happy")
        let tipLevel3 = TipLimitLevel(level: 3, amount: 1.5, type: "driver", title: "very happy")
        let tipLevel4 = TipLimitLevel(level: 4, amount: 2, type: "driver", title: "insanely happy")
        let businessData = AppState.BusinessData(businessProfile: BusinessProfile(id: 12, checkoutTimeoutSeconds: nil, minOrdersForAppReview: 10, privacyPolicyLink: nil, pusherClusterServer: nil, pusherAppKey: nil, mentionMeEnabled: nil, iterableMobileApiKey: nil, useDeliveryFirms: false, driverTipIncrement: 1, tipLimitLevels: [tipLevel1, tipLevel2, tipLevel3, tipLevel4], facebook: FacebookSetting(pixelId: "", appId: ""), tikTok: TikTokSetting(pixelId: ""), paymentGateways: [PaymentGateway.mockedCheckoutcomData], postcodeRules: PostcodeRule.mockedDataArray, marketingText: nil, fetchLocaleCode: nil, fetchTimestamp: nil, colors: nil))
        let appState = AppState(system: AppState.System(), routing: AppState.ViewRouting(), businessData: businessData, userData: AppState.UserData())
        let container = DIContainer(appState: appState, eventLogger: MockedEventLogger(), services: .mocked())
        let sut = makeSUT(container: container)
        sut.driverTip = 0.25
        
        XCTAssertEqual(sut.tipLevel, .unhappy)
    }
    
    func test_givenBusinessProfile_whenDriverTipIs50p_thenTipLevelIsNeutral() {
        let tipLevel1 = TipLimitLevel(level: 1, amount: 0.5, type: "driver", title: "neutral")
        let tipLevel2 = TipLimitLevel(level: 2, amount: 1, type: "driver", title: "happy")
        let tipLevel3 = TipLimitLevel(level: 3, amount: 1.5, type: "driver", title: "very happy")
        let tipLevel4 = TipLimitLevel(level: 4, amount: 2, type: "driver", title: "insanely happy")
        let businessData = AppState.BusinessData(businessProfile: BusinessProfile(id: 12, checkoutTimeoutSeconds: nil, minOrdersForAppReview: 10, privacyPolicyLink: nil, pusherClusterServer: nil, pusherAppKey: nil, mentionMeEnabled: nil, iterableMobileApiKey: nil, useDeliveryFirms: false, driverTipIncrement: 1, tipLimitLevels: [tipLevel1, tipLevel2, tipLevel3, tipLevel4], facebook: FacebookSetting(pixelId: "", appId: ""), tikTok: TikTokSetting(pixelId: ""), paymentGateways: [PaymentGateway.mockedCheckoutcomData], postcodeRules: PostcodeRule.mockedDataArray, marketingText: nil, fetchLocaleCode: nil, fetchTimestamp: nil, colors: nil))
        let appState = AppState(system: AppState.System(), routing: AppState.ViewRouting(), businessData: businessData, userData: AppState.UserData())
        let container = DIContainer(appState: appState, eventLogger: MockedEventLogger(), services: .mocked())
        let sut = makeSUT(container: container)
        sut.driverTip = 0.5
        
        XCTAssertEqual(sut.tipLevel, .neutral)
    }
    
    func test_givenBusinessProfile_whenDriverTipIs125p_thenTipLevelIsHappy() {
        let tipLevel1 = TipLimitLevel(level: 1, amount: 0.5, type: "driver", title: "neutral")
        let tipLevel2 = TipLimitLevel(level: 2, amount: 1, type: "driver", title: "happy")
        let tipLevel3 = TipLimitLevel(level: 3, amount: 1.5, type: "driver", title: "very happy")
        let tipLevel4 = TipLimitLevel(level: 4, amount: 2, type: "driver", title: "insanely happy")
        let businessData = AppState.BusinessData(businessProfile: BusinessProfile(id: 12, checkoutTimeoutSeconds: nil, minOrdersForAppReview: 10, privacyPolicyLink: nil, pusherClusterServer: nil, pusherAppKey: nil, mentionMeEnabled: nil, iterableMobileApiKey: nil, useDeliveryFirms: false, driverTipIncrement: 1, tipLimitLevels: [tipLevel1, tipLevel2, tipLevel3, tipLevel4], facebook: FacebookSetting(pixelId: "", appId: ""), tikTok: TikTokSetting(pixelId: ""), paymentGateways: [PaymentGateway.mockedCheckoutcomData], postcodeRules: PostcodeRule.mockedDataArray, marketingText: nil, fetchLocaleCode: nil, fetchTimestamp: nil, colors: nil))
        let appState = AppState(system: AppState.System(), routing: AppState.ViewRouting(), businessData: businessData, userData: AppState.UserData())
        let container = DIContainer(appState: appState, eventLogger: MockedEventLogger(), services: .mocked())
        let sut = makeSUT(container: container)
        sut.driverTip = 1.25
        
        XCTAssertEqual(sut.tipLevel, .happy)
    }
    
    func test_givenBusinessProfile_whenDriverTipIs150p_thenTipLevelIsVeryHappy() {
        let tipLevel1 = TipLimitLevel(level: 1, amount: 0.5, type: "driver", title: "neutral")
        let tipLevel2 = TipLimitLevel(level: 2, amount: 1, type: "driver", title: "happy")
        let tipLevel3 = TipLimitLevel(level: 3, amount: 1.5, type: "driver", title: "very happy")
        let tipLevel4 = TipLimitLevel(level: 4, amount: 2, type: "driver", title: "insanely happy")
        let businessData = AppState.BusinessData(businessProfile: BusinessProfile(id: 12, checkoutTimeoutSeconds: nil, minOrdersForAppReview: 10, privacyPolicyLink: nil, pusherClusterServer: nil, pusherAppKey: nil, mentionMeEnabled: nil, iterableMobileApiKey: nil, useDeliveryFirms: false, driverTipIncrement: 1, tipLimitLevels: [tipLevel1, tipLevel2, tipLevel3, tipLevel4], facebook: FacebookSetting(pixelId: "", appId: ""), tikTok: TikTokSetting(pixelId: ""), paymentGateways: [PaymentGateway.mockedCheckoutcomData], postcodeRules: PostcodeRule.mockedDataArray, marketingText: nil, fetchLocaleCode: nil, fetchTimestamp: nil, colors: nil))
        let appState = AppState(system: AppState.System(), routing: AppState.ViewRouting(), businessData: businessData, userData: AppState.UserData())
        let container = DIContainer(appState: appState, eventLogger: MockedEventLogger(), services: .mocked())
        let sut = makeSUT(container: container)
        sut.driverTip = 1.5
        
        XCTAssertEqual(sut.tipLevel, .veryHappy)
    }
    
    func test_givenBusinessProfile_whenDriverTipIs5_thenTipLevelIsInsanelyHappy() {
        let tipLevel1 = TipLimitLevel(level: 1, amount: 0.5, type: "driver", title: "neutral")
        let tipLevel2 = TipLimitLevel(level: 2, amount: 1, type: "driver", title: "happy")
        let tipLevel3 = TipLimitLevel(level: 3, amount: 1.5, type: "driver", title: "very happy")
        let tipLevel4 = TipLimitLevel(level: 4, amount: 2, type: "driver", title: "insanely happy")
        let businessData = AppState.BusinessData(businessProfile: BusinessProfile(id: 12, checkoutTimeoutSeconds: nil, minOrdersForAppReview: 10, privacyPolicyLink: nil, pusherClusterServer: nil, pusherAppKey: nil, mentionMeEnabled: nil, iterableMobileApiKey: nil, useDeliveryFirms: false, driverTipIncrement: 1, tipLimitLevels: [tipLevel1, tipLevel2, tipLevel3, tipLevel4], facebook: FacebookSetting(pixelId: "", appId: ""), tikTok: TikTokSetting(pixelId: ""), paymentGateways: [PaymentGateway.mockedCheckoutcomData], postcodeRules: PostcodeRule.mockedDataArray, marketingText: nil, fetchLocaleCode: nil, fetchTimestamp: nil, colors: nil))
        let appState = AppState(system: AppState.System(), routing: AppState.ViewRouting(), businessData: businessData, userData: AppState.UserData())
        let container = DIContainer(appState: appState, eventLogger: MockedEventLogger(), services: .mocked())
        let sut = makeSUT(container: container)
        sut.driverTip = 5
        
        XCTAssertEqual(sut.tipLevel, .insanelyHappy)
    }
    
    func test_whenClearCouponAndContinueTriggered_thenCouponCodeClearedAndCheckoutTappedTriggered() async {
        let sut = makeSUT()
        
        sut.couponCode = "SPRING10"
        
        await sut.clearCouponAndContinue()
        
        XCTAssertTrue(sut.couponCode.isEmpty)
        XCTAssertTrue(sut.isContinueToCheckoutTapped)
    }
    
    func test_givenCouponCodeIsPopulated_whenCheckoutTapped_thenShowCouponAlertIsTrue() async {
        let sut = makeSUT()
        
        sut.couponCode = "SPRING10"
        
        await sut.checkoutTapped()
        
        XCTAssertTrue(sut.showCouponAlert)
	}

    func test_whenTriggeringIncreaseTipInQuickSuccession_thenUpdateTipIsCalledCorrectly() {
        let tipLevel1 = TipLimitLevel(level: 1, amount: 0.5, type: "driver", title: "neutral")
        let tipLevel2 = TipLimitLevel(level: 2, amount: 1, type: "driver", title: "happy")
        let tipLevel3 = TipLimitLevel(level: 3, amount: 1.5, type: "driver", title: "very happy")
        let tipLevel4 = TipLimitLevel(level: 4, amount: 2, type: "driver", title: "insanely happy")
        let businessData = AppState.BusinessData(businessProfile: BusinessProfile(id: 12, checkoutTimeoutSeconds: nil, minOrdersForAppReview: 10, privacyPolicyLink: nil, pusherClusterServer: nil, pusherAppKey: nil, mentionMeEnabled: nil, iterableMobileApiKey: nil, useDeliveryFirms: false, driverTipIncrement: 1, tipLimitLevels: [tipLevel1, tipLevel2, tipLevel3, tipLevel4], facebook: FacebookSetting(pixelId: "", appId: ""), tikTok: TikTokSetting(pixelId: ""), paymentGateways: [PaymentGateway.mockedCheckoutcomData], postcodeRules: PostcodeRule.mockedDataArray, marketingText: nil, fetchLocaleCode: nil, fetchTimestamp: nil, colors: nil))
        let appState = AppState(system: AppState.System(), routing: AppState.ViewRouting(), businessData: businessData, userData: AppState.UserData())
        let container = DIContainer(appState: appState, eventLogger: MockedEventLogger(), services: .mocked(basketService: [.updateTip(tip: 3)]))
        let sut = makeSUT(container: container, runMemoryLeakTracking: false)
        
        let exp = expectation(description: "updatingTip")
        var cancellables = Set<AnyCancellable>()

        sut.$updatingTip
            .collect(3)
            .receive(on: RunLoop.main)
            .sink { _ in
                exp.fulfill()
            }
            .store(in: &cancellables)
        
        sut.increaseTip()
        sut.increaseTip()
        sut.increaseTip()
        
        wait(for: [exp], timeout: 2)
        
        XCTAssertEqual(sut.changeTipBy, 0)
        container.services.verify(as: .basket)
    }
    
    func test_whenTriggeringDecreaseTipInQuickSuccession_thenUpdateTipIsCalledCorrectly() {
        let tipLevel1 = TipLimitLevel(level: 1, amount: 0.5, type: "driver", title: "neutral")
        let tipLevel2 = TipLimitLevel(level: 2, amount: 1, type: "driver", title: "happy")
        let tipLevel3 = TipLimitLevel(level: 3, amount: 1.5, type: "driver", title: "very happy")
        let tipLevel4 = TipLimitLevel(level: 4, amount: 2, type: "driver", title: "insanely happy")
        let businessData = AppState.BusinessData(businessProfile: BusinessProfile(id: 12, checkoutTimeoutSeconds: nil, minOrdersForAppReview: 10, privacyPolicyLink: nil, pusherClusterServer: nil, pusherAppKey: nil, mentionMeEnabled: nil, iterableMobileApiKey: nil, useDeliveryFirms: false, driverTipIncrement: 1, tipLimitLevels: [tipLevel1, tipLevel2, tipLevel3, tipLevel4], facebook: FacebookSetting(pixelId: "", appId: ""), tikTok: TikTokSetting(pixelId: ""), paymentGateways: [PaymentGateway.mockedCheckoutcomData], postcodeRules: PostcodeRule.mockedDataArray, marketingText: nil, fetchLocaleCode: nil, fetchTimestamp: nil, colors: nil))
        let appState = AppState(system: AppState.System(), routing: AppState.ViewRouting(), businessData: businessData, userData: AppState.UserData())
        let container = DIContainer(appState: appState, eventLogger: MockedEventLogger(), services: .mocked(basketService: [.updateTip(tip: 0)]))
        let sut = makeSUT(container: container, runMemoryLeakTracking: false)
        sut.driverTip = 2
        
        let exp = expectation(description: "updatingTip")
        var cancellables = Set<AnyCancellable>()
        
        sut.$updatingTip
            .dropFirst()
            .first(where: { $0 == false })
            .receive(on: RunLoop.main)
            .sink { _ in
                exp.fulfill()
            }
            .store(in: &cancellables)
        
        sut.decreaseTip()
        sut.decreaseTip()
        sut.decreaseTip()
        
        wait(for: [exp], timeout: 2)
        
        XCTAssertEqual(sut.changeTipBy, 0)
        container.services.verify(as: .basket)
    }
    
    func test_givenBasket_whenOnBasketViewSendEventTriggered_thenSendAppsFlyerEventCalled() {
        let basket = Basket.mockedData
        let store = RetailStoreDetails.mockedData
        var appState = AppState()
        appState.userData.basket = basket
        appState.userData.selectedStore = .loaded(store)
        
        var totalItemQuantity: Int = 0
        for item in basket.items {
            totalItemQuantity += item.quantity
        }
        let appsFlyerParams: [String: Any] = [
            AFEventParamPrice: basket.orderTotal,
            AFEventParamQuantity: totalItemQuantity
        ]
        let iterableParams: [String: Any] = [
            "basketTotal": basket.orderTotal
        ]
        let firebaseParams: [String: Any] = [
            AnalyticsParameterItems: EventLogger.getFirebaseItemsArray(from: basket.items),
            AnalyticsParameterCurrency: appState.userData.selectedStore.value?.currency.currencyCode ?? AppV2Constants.Business.currencyCode,
            AnalyticsParameterValue: NSDecimalNumber(value: basket.orderTotal).rounding(accordingToBehavior: EventLogger.decimalBehavior).doubleValue
        ]
        
        let eventLogger = MockedEventLogger(expected: [
            .sendEvent(for: .viewCart, with: .appsFlyer, params: appsFlyerParams),
            .sendEvent(for: .viewCart, with: .iterable, params: iterableParams),
            .sendEvent(for: .viewCart, with: .firebaseAnalytics, params: firebaseParams)
        ])
        let container = DIContainer(appState: appState, eventLogger: eventLogger, services: .mocked())
        let sut = makeSUT(container: container)
        
        sut.onBasketViewSendEvent()
        
        eventLogger.verify()
    }
    
    func test_givenNoBasket_whenOnBasketViewSendEventTriggered_thenSendAppsFlyerEventNotCalled() {
        let eventLogger = MockedEventLogger(expected: [])
        let container = DIContainer(appState: AppState(), eventLogger: eventLogger, services: .mocked())
        let sut = makeSUT(container: container)
        
        sut.onBasketViewSendEvent()
        
        eventLogger.verify()
    }
    
    func test_whenSelectedSlotIsNotClosedOrExpired_thenShowCheckoutButtonIsTrue() {
        let sut = makeSUT()
        sut.selectedStore = RetailStoreDetails.mockedData
        XCTAssertTrue(sut.showCheckoutButton)
    }
    
    func test_whenFulfilmentIsDeliveryAndDeliveryStatusIsClosed_thenShowCheckoutButtonIsTrue() {
        let container = DIContainer(appState: AppState(), eventLogger: MockedEventLogger(), services: .mocked())
        container.appState.value.userData.selectedFulfilmentMethod = .delivery
        let sut = makeSUT(container: container)
        sut.selectedStore = RetailStoreDetails.mockedDataWithClosedDeliveryStatus
        XCTAssertFalse(sut.showCheckoutButton)
    }
    
    func test_whenFulfilmentIsDeliveryAndCollectionStatusIsClosed_thenShowCheckoutButtonIsTrue() {
        let container = DIContainer(appState: AppState(), eventLogger: MockedEventLogger(), services: .mocked())
        container.appState.value.userData.selectedFulfilmentMethod = .collection
        let sut = makeSUT(container: container)
        sut.selectedStore = RetailStoreDetails.mockedDataWithClosedCollectionStatus
        XCTAssertFalse(sut.showCheckoutButton)
    }
    
    func test_whenSelectedStoreDeliveryTiersPresent_thenDeliveryTiersPresentTrue() {
        let container = DIContainer(appState: AppState(), eventLogger: MockedEventLogger(), services: .mocked())
        let sut = makeSUT(container: container)
        sut.selectedStore = RetailStoreDetails.mockedDataWithDeliveryTiers
        XCTAssertTrue(sut.hasTiers)
    }
    
    func test_whenNoSelectedStore_thenDeliveryTiersPresentFalse() {
        let container = DIContainer(appState: AppState(), eventLogger: MockedEventLogger(), services: .mocked())
        let sut = makeSUT(container: container)
        XCTAssertFalse(sut.hasTiers)
    }
    
    func test_whenSelectedStoreDeliveryTiersEmpty_thenDeliveryTiersPresentFalse() {
        let container = DIContainer(appState: AppState(), eventLogger: MockedEventLogger(), services: .mocked())
        let sut = makeSUT(container: container)
        sut.selectedStore = RetailStoreDetails.mockedDataWithEmptyDeliveryTiers
        XCTAssertFalse(sut.hasTiers)
    }
    
    func test_whenSelectedStoreDeliveryTiersNotPresent_thenDeliveryTiersPresentFalse() {
        let container = DIContainer(appState: AppState(), eventLogger: MockedEventLogger(), services: .mocked())
        let sut = makeSUT(container: container)
        sut.selectedStore = RetailStoreDetails.mockedData
        XCTAssertFalse(sut.hasTiers)
    }
    
    func test_whenSelectedStoreCurrencyPresent_thenCurrencyPopulated() {
        let container = DIContainer(appState: AppState(), eventLogger: MockedEventLogger(), services: .mocked())
        let sut = makeSUT(container: container)
        sut.selectedStore = RetailStoreDetails.mockedData
        XCTAssertEqual(sut.currency, RetailStoreCurrency.mockedGBPData)
    }
    
    func test_whenNoSelectedStore_thenCurrencyNil() {
        let container = DIContainer(appState: AppState(), eventLogger: MockedEventLogger(), services: .mocked())
        let sut = makeSUT(container: container)
        XCTAssertNil(sut.currency)
    }
    
    func makeSUT(container: DIContainer = DIContainer(appState: AppState(), eventLogger: MockedEventLogger(), services: .mocked()), runMemoryLeakTracking: Bool = true) -> BasketViewModel {
        let sut = BasketViewModel(container: container)
        
        // Tasks, in Xcode 14, trigger memory leaks, so they are stored and cancelled on deinit
        if runMemoryLeakTracking {
            trackForMemoryLeaks(sut)
        }
        
        return sut
    }
}
