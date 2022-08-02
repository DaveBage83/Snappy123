//
//  FulfilmentInfoCardViewModelTests.swift
//  SnappyV2Tests
//
//  Created by David Bage on 28/06/2022.
//

import XCTest
import Combine
import AppsFlyerLib
@testable import SnappyV2

@MainActor
class FulfilmentInfoCardViewModelTests: XCTestCase {
    
    func test_whenSlotExpiryIsBeforeCurrentTime_thenSlotExpiredIsTrue() {
        
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
        XCTAssertTrue(sut.useWarningCardFormat)
    }
    
    func test_whenSlotExpiryIsAfterCurrentTime_thenSlotExpiredIsFalse() {
        
        let basket = Basket(basketToken: "aaabbb", isNewBasket: false, items: [], fulfilmentMethod: BasketFulfilmentMethod(type: .delivery, cost: 2.5, minSpend: 10), selectedSlot: BasketSelectedSlot.mockedTodayData, savings: nil, coupon: nil, fees: nil, tips: nil, addresses: nil, orderSubtotal: 1, orderTotal: 10, storeId: nil, basketItemRemoved: nil)
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
                
        XCTAssertFalse(sut.isSlotExpired)
    }
    
    func test_whenSlotEndIsLaterThanCurrentDateTime_givenExpiryIsNil_thenSlotExpiredIsTrue() {
        
        let basket = Basket(basketToken: "aaabbb", isNewBasket: false, items: [], fulfilmentMethod: BasketFulfilmentMethod(type: .delivery, cost: 2.5, minSpend: 10), selectedSlot: BasketSelectedSlot.mockedYesterdaySlotNoExpiry, savings: nil, coupon: nil, fees: nil, tips: nil, addresses: nil, orderSubtotal: 1, orderTotal: 10, storeId: nil, basketItemRemoved: nil)
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
    
    func test_whenChangeFulfilmentTypeTriggered_givenFulfilmentMethodIsDelviery_thenFulfilmentTypeChanged() async {
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
        
        
        sut.changeFulfilmentTypeTapped()
        XCTAssertTrue(sut.isFulfilmentSlotSelectShown)
    }
    
    func test_whenChangeFulfilmentTypeTriggered_givenFulfilmentMethodIsCollection_thenFulfilmentTypeChanged() async {
        let basket = Basket(basketToken: "aaabbb", isNewBasket: false, items: [], fulfilmentMethod: BasketFulfilmentMethod(type: .collection, cost: 2.5, minSpend: 10), selectedSlot: BasketSelectedSlot.mockedYesterdaySlot, savings: nil, coupon: nil, fees: nil, tips: nil, addresses: nil, orderSubtotal: 1, orderTotal: 10, storeId: nil, basketItemRemoved: nil)
        let member = MemberProfile(uuid: "8b7b9a7e-efd9-11ec-8ea0-0242ac120002", firstname: "", lastname: "", emailAddress: "", type: .customer, referFriendCode: nil, referFriendBalance: 0, numberOfReferrals: 0, mobileContactNumber: nil, mobileValidated: false, acceptedMarketing: false, defaultBillingDetails: nil, savedAddresses: nil, fetchTimestamp: nil)
        let appState = AppState(system: .init(), routing: .init(), userData: .init(selectedStore: .notRequested, selectedFulfilmentMethod: .collection, searchResult: .notRequested, basket: basket, memberProfile: member))
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
        
        
        sut.changeFulfilmentTypeTapped()
        XCTAssertTrue(sut.isFulfilmentSlotSelectShown)
    }
    
    func test_whenSelectedFulfilmentMethodIsDelivery_givenSelectedStoreDeliveryMethodIsClodeStatus_thenShowClosedStoreWarningIsTrue() {

        let container = DIContainer(appState: AppState(), eventLogger: MockedEventLogger(), services: .mocked())
        container.appState.value.userData.selectedFulfilmentMethod = .delivery
        let sut = makeSUT(container: container)
        sut.selectedStore = RetailStoreDetails.mockedDataWithClosedDeliveryStatus
        XCTAssertTrue(sut.showStoreClosedWarning)
        XCTAssertTrue(sut.useWarningCardFormat)
    }
    
    func test_whenSelectedFulfilmentMethodIsCollection_givenSelectedStoreCollectionMethodIsClodeStatus_thenShowClosedStoreWarningIsTrue() {

        let container = DIContainer(appState: AppState(), eventLogger: MockedEventLogger(), services: .mocked())
        container.appState.value.userData.selectedFulfilmentMethod = .collection
        let sut = makeSUT(container: container)
        sut.selectedStore = RetailStoreDetails.mockedDataWithClosedCollectionStatus
        XCTAssertTrue(sut.showStoreClosedWarning)
        XCTAssertTrue(sut.useWarningCardFormat)
    }

    
    func makeSUT(container: DIContainer = DIContainer(appState: AppState(), eventLogger: MockedEventLogger(), services: .mocked())) -> FulfilmentInfoCardViewModel {
        let sut = FulfilmentInfoCardViewModel(container: container)
        
        trackForMemoryLeaks(sut)
        
        return sut
    }
}
