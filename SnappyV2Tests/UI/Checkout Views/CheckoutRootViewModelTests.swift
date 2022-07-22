//
//  CheckoutRootViewModelTests.swift
//  SnappyV2Tests
//
//  Created by David Bage on 18/07/2022.
//

import XCTest
import Combine
@testable import SnappyV2
import SwiftUI

@MainActor
class CheckoutRootViewModelTests: XCTestCase {
    
    func test_init() {
        let sut = makeSUT()
        sut.container.appState.value.userData.basket = Basket.mockedData
        XCTAssertEqual(sut.checkoutState, .initial)
        XCTAssertEqual(sut.maxProgress, 2)
        XCTAssertEqual(sut.currentProgress, 0)
        XCTAssertFalse(sut.firstNameHasWarning)
        XCTAssertFalse(sut.lastnameHasWarning)
        XCTAssertFalse(sut.emailHasWarning)
        XCTAssertFalse(sut.phoneNumberHasWarning)
        XCTAssertFalse(sut.newErrorsExist)
        XCTAssertEqual(sut.orderTotal, 23.3)
    }
    
    func test_whenProgressStateExceedsMaxValue_thenReturnMaxValue() {
        let sut = makeSUT()
        sut.progressState = .completeSuccess
        XCTAssertEqual(sut.currentProgress, 2)
    }
    
    func test_whenSetNoAddressErrorTriggered_thenCheckoutErrorIsNoAddressesFound() {
        let sut = makeSUT()
        sut.setCheckoutError(CheckoutRootViewError.noAddressesFound)
        XCTAssertEqual(sut.checkoutError?.localizedDescription, CheckoutRootViewError.noAddressesFound.localizedDescription)
    }
    
    func test_whenFulfilmentIsDelivery_thenIsDeliveryIsTrue() {
        let sut = makeSUT()
        sut.container.appState.value.userData.basket = Basket.mockedData
        XCTAssertTrue(sut.isDelivery)
    }
    
    func test_whenMemberProfileIsNil_thenUserSignedInIsFalse() {
        let sut = makeSUT()
        sut.container.appState.value.userData.memberProfile = nil
        XCTAssertFalse(sut.isUserSignedIn)
    }
    
    func test_whenMemberProfileIsNotNil_thenUserSignedInIsTrue() {
        let sut = makeSUT()
        sut.container.appState.value.userData.memberProfile = MemberProfile.mockedData
        XCTAssertFalse(sut.isUserSignedIn)
    }
    
    func test_whenFulfilmentIsNotDelivery_thenIsDeliveryIsFalse() {
        let sut = makeSUT()
        sut.container.appState.value.userData.basket = Basket.mockedDataCollection
        XCTAssertFalse(sut.isDelivery)
    }
    
    func test_whenFirstNameHasWarningSetToTrue_thenNewWarningExistsIsTrue() {
        let sut = makeSUT()
        sut.firstNameHasWarning = true
        sut.lastnameHasWarning = true
        XCTAssertTrue(sut.newErrorsExist)
    }
    
    func test_whenLastNameHasWarningSetToTrue_thenNewWarningExistsIsTrue() {
        let sut = makeSUT()
        sut.lastnameHasWarning = true
        XCTAssertTrue(sut.newErrorsExist)
    }
    
    func test_whenCheckoutStateIsInitial_thenProgressStateIsNotStarted() {
        let sut = makeSUT()
        sut.checkoutState = .initial
        XCTAssertEqual(sut.progressState, .notStarted)
    }
    
    func test_whenCheckoutStateIsLogin_thenProgressStateIsNotStarted() {
        let sut = makeSUT()
        sut.checkoutState = .login
        
        let expectation = expectation(description: "progressSetToNotStarted")
        var cancellables = Set<AnyCancellable>()
        
        sut.$checkoutState
            .first()
            .receive(on: RunLoop.main)
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 2)
        XCTAssertEqual(sut.progressState, .notStarted)
    }
    
    func test_whenCheckoutStateIsCreateAccount_thenProgressStateIsNotStarted() {
        let sut = makeSUT()
        
        let expectation = expectation(description: "progressSetToNotStarted")
        var cancellables = Set<AnyCancellable>()
        
        sut.$checkoutState
            .first()
            .receive(on: RunLoop.main)
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        sut.checkoutState = .createAccount
        wait(for: [expectation], timeout: 2)
        XCTAssertEqual(sut.progressState, .notStarted)
    }
    
    func test_whenCheckoutStateIsDetails_thenProgressStateIsDetails() {
        let sut = makeSUT()
        sut.checkoutState = .details
        
        let expectation = expectation(description: "progressSetToDetails")
        var cancellables = Set<AnyCancellable>()
        
        sut.$checkoutState
            .first()
            .receive(on: RunLoop.main)
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        wait(for: [expectation], timeout: 2)
        XCTAssertEqual(sut.progressState, .details)
    }
    
    func test_whenCheckoutStateIsPaymentSelection_thenProgressStateIsPayment() {
        let sut = makeSUT()
        sut.checkoutState = .paymentSelection
        let expectation = expectation(description: "progressSetToPayment")
        var cancellables = Set<AnyCancellable>()
        
        sut.$checkoutState
            .first()
            .receive(on: RunLoop.main)
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        wait(for: [expectation], timeout: 2)
        XCTAssertEqual(sut.progressState, .payment)
    }
    
    func test_whenCheckoutStateIsCard_thenProgressStateIsPayment() {
        let sut = makeSUT()
        sut.checkoutState = .card
        
        let expectation = expectation(description: "progressSetToPayment")
        var cancellables = Set<AnyCancellable>()
        
        sut.$checkoutState
            .first()
            .receive(on: RunLoop.main)
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        wait(for: [expectation], timeout: 2)
        XCTAssertEqual(sut.progressState, .payment)
    }
    
    func test_whenCheckoutStateIsPaymentSuccess_thenProgressStateIsCompleteSuccess() {
        let sut = makeSUT()
        sut.checkoutState = .paymentSuccess
        
        let expectation = expectation(description: "progressSetToCompleteSuccess")
        var cancellables = Set<AnyCancellable>()
        
        sut.$checkoutState
            .first()
            .receive(on: RunLoop.main)
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        wait(for: [expectation], timeout: 2)
        XCTAssertEqual(sut.progressState, .completeSuccess)
    }
    
    func test_whenCheckoutStateIsPaymentFailure_thenProgressStateIsCompleteError() {
        let sut = makeSUT()
        sut.checkoutState = .paymentFailure
        let expectation = expectation(description: "progressSetToCompleteError")
        var cancellables = Set<AnyCancellable>()
        
        sut.$checkoutState
            .first()
            .receive(on: RunLoop.main)
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        wait(for: [expectation], timeout: 2)
        XCTAssertEqual(sut.progressState, .completeError)
    }
    
    func test_whenEmailtNameHasWarningSetToTrue_thenNewWarningExistsIsTrue() {
        let sut = makeSUT()
        sut.emailHasWarning = true
        XCTAssertTrue(sut.newErrorsExist)
    }
    
    func test_whenPhoneNumberHasWarningSetToTrue_thenNewWarningExistsIsTrue() {
        let sut = makeSUT()
        sut.phoneNumberHasWarning = true
        XCTAssertTrue(sut.newErrorsExist)
    }
    
    func test_whenFirstNameHasWarningSetToFalse_givenNoErrorsOnOtherFields_thenNewErrorsExistSetToFalse() {
        let sut = makeSUT()
        sut.firstNameHasWarning = true
        XCTAssertTrue(sut.newErrorsExist)
        sut.firstNameHasWarning = false
        XCTAssertFalse(sut.newErrorsExist)
    }
    
    func test_whenFirstNameHasWarningSetToFalse_givenErrorsStillOnOtherFields_thenNewErrorsExistSetToTrue() {
        let sut = makeSUT()
        sut.firstNameHasWarning = true
        sut.lastnameHasWarning = true
        XCTAssertTrue(sut.newErrorsExist)
        sut.firstNameHasWarning = false
        XCTAssertTrue(sut.newErrorsExist)
    }
    
    func test_whenLastNameHasWarningSetToFalse_givenNoErrorsOnOtherFields_thenNewErrorsExistSetToFalse() {
        let sut = makeSUT()
        sut.lastnameHasWarning = true
        XCTAssertTrue(sut.newErrorsExist)
        sut.lastnameHasWarning = false
        XCTAssertFalse(sut.newErrorsExist)
    }
    
    func test_whenLastNameHasWarningSetToFalse_givenErrorsStillOnOtherFields_thenNewErrorsExistSetToTrue() {
        let sut = makeSUT()
        sut.lastnameHasWarning = true
        sut.firstNameHasWarning = true
        XCTAssertTrue(sut.newErrorsExist)
        sut.lastnameHasWarning = false
        XCTAssertTrue(sut.newErrorsExist)
    }
    
    func test_whenProgressStateIsDetails_thenTitleSet() {
        let sut = makeSUT()
        sut.progressState = .details
        XCTAssertEqual(sut.progressState.title, Strings.CheckoutDetails.CheckoutProgress.details.localized)
    }
    
    func test_whenProgressStateIsPayment_thenTitleSet() {
        let sut = makeSUT()
        sut.progressState = .payment
        XCTAssertEqual(sut.progressState.title, Strings.CheckoutDetails.CheckoutProgress.payment.localized)
    }
    
    func test_whenProgressStateIsNotStarted_thenTitleIsNil() {
        let sut = makeSUT()
        sut.progressState = .notStarted
        XCTAssertNil(sut.progressState.title)
    }
    
    func test_whenProgressStateIsCompleteSuccess_thenTitleIsNil() {
        let sut = makeSUT()
        sut.progressState = .completeSuccess
        XCTAssertNil(sut.progressState.title)
    }
    
    func test_whenProgressStateIsCompleteError_thenTitleIsNil() {
        let sut = makeSUT()
        sut.progressState = .completeError
        XCTAssertNil(sut.progressState.title)
    }
    
    func test_whenEmailHasWarningSetToFalse_givenNoErrorsOnOtherFields_thenNewErrorsExistSetToFalse() {
        let sut = makeSUT()
        sut.emailHasWarning = true
        XCTAssertTrue(sut.newErrorsExist)
        sut.emailHasWarning = false
        XCTAssertFalse(sut.newErrorsExist)
    }
    
    func test_whenEmailHasWarningSetToFalse_givenErrorsStillOnOtherFields_thenNewErrorsExistSetToTrue() {
        let sut = makeSUT()
        sut.emailHasWarning = true
        sut.firstNameHasWarning = true
        XCTAssertTrue(sut.newErrorsExist)
        sut.emailHasWarning = false
        XCTAssertTrue(sut.newErrorsExist)
    }
    
    func test_whenPhoneHasWarningSetToFalse_givenNoErrorsOnOtherFields_thenNewErrorsExistSetToFalse() {
        let sut = makeSUT()
        sut.phoneNumberHasWarning = true
        XCTAssertTrue(sut.newErrorsExist)
        sut.phoneNumberHasWarning = false
        XCTAssertFalse(sut.newErrorsExist)
    }
    
    func test_whenPhoneHasWarningSetToFalse_givenErrorsStillOnOtherFields_thenNewErrorsExistSetToTrue() {
        let sut = makeSUT()
        sut.phoneNumberHasWarning = true
        sut.firstNameHasWarning = true
        XCTAssertTrue(sut.newErrorsExist)
        sut.phoneNumberHasWarning = false
        XCTAssertTrue(sut.newErrorsExist)
    }
    
    func test_whenSelectedSlotInAppStateIsNil_thenSlotIsEmptyIsTrue() {
       let sut = makeSUT()
        XCTAssertTrue(sut.slotIsEmpty)
        XCTAssertEqual(sut.selectedSlot, Strings.CheckoutDetails.ChangeFulfilmentMethod.noSlot.localized)
    }
    
    func test_whenSelectedSlotInAppStateIsNotNil_thenSlotIsEmptyIsFalse() {
        let sut = makeSUT()
        sut.container.appState.value.userData.basket = Basket.mockedData
        XCTAssertFalse(sut.slotIsEmpty)
    }
    
    func test_whenFulfilmentTypeIsDeliveryInAppState_thenFulfilmentTypeIsDeliveryy() {
        let sut = makeSUT()
        sut.container.appState.value.userData.basket = Basket.mockedData
        XCTAssertEqual(sut.fulfilmentType?.type, .delivery)
    }
    
    func test_whenFulfilmentTypeIsCollectionInAppState_thenFulfilmentTypeIsCollection() {
        let sut = makeSUT()
        sut.container.appState.value.userData.basket = Basket.mockedDataCollection
        XCTAssertEqual(sut.fulfilmentType?.type, .collection)
    }

    func test_whenEmailFieldIsNotEmpty_thenDeliveryEmailMatchesField() {
        let sut = makeSUT()
        sut.email = "test@test.com"
        XCTAssertEqual(sut.deliveryEmail, "test@test.com")
    }
    
    func test_whenEmailFieldIsEmpty_givenMemberProfileIsNotNilAndEmailValueIsPresent_thenDeliveryEmailMatchesMemberProfileVersion() {
        let container = DIContainer(appState: AppState(), eventLogger: MockedEventLogger(), services: .mocked())
        container.appState.value.userData.memberProfile = MemberProfile.mockedData
        let sut = makeSUT(container: container)
        XCTAssertEqual(sut.deliveryEmail, "h.brown@gmail.com")
    }
    
    func test_whenEmailFieldIsEmpty_givenMemberProfileIsNil_thenDeliveryEmailIsNil() {
        let sut = makeSUT()
        XCTAssertNil(sut.deliveryEmail)
    }
    
    func test_whenFirstNameFieldIsNotEmpty_thenFirstNameMatchesField() {
        let sut = makeSUT()
        sut.firstname = "Johnny"
        XCTAssertEqual(sut.deliveryFirstName, "Johnny")
    }
    
    func test_whenFirstNameIsEmpty_givenMemberProfileIsNotNilAndFirstNameValueIsPresent_thenDeliveryFirstNameMatchesMemberProfileVersion() {
        let container = DIContainer(appState: AppState(), eventLogger: MockedEventLogger(), services: .mocked())
        container.appState.value.userData.memberProfile = MemberProfile.mockedData
        let sut = makeSUT(container: container)
        XCTAssertEqual(sut.firstname, "Harold")
    }
    
    func test_whenFirstNameFieldIsEmpty_givenMemberProfileIsNil_thenDeliveryFirstNameIsNil() {
        let sut = makeSUT()
        XCTAssertNil(sut.deliveryFirstName)
    }
    
    func test_whenLastNameFieldIsNotEmpty_thenDeliveryLastNameMatchesField() {
        let sut = makeSUT()
        sut.lastname = "Bloggs"
        XCTAssertEqual(sut.deliveryLastName, "Bloggs")
    }
    
    func test_whenLastNameIsEmpty_givenMemberProfileIsNotNilAndLastNameValueIsPresent_thenDeliveryLastNameMatchesMemberProfileVersion() {
        let container = DIContainer(appState: AppState(), eventLogger: MockedEventLogger(), services: .mocked())
        container.appState.value.userData.memberProfile = MemberProfile.mockedData
        let sut = makeSUT(container: container)
        XCTAssertEqual(sut.lastname, "Brown")
    }
    
    func test_whenLastNameFieldIsEmpty_givenMemberProfileIsNil_thenDeliveryLastNameIsNil() {
        let sut = makeSUT()
        XCTAssertNil(sut.deliveryLastName)
    }
    
    func test_whenPhoneFieldIsNotEmpty_thenDeliveryPhoneMatchesField() {
        let sut = makeSUT()
        sut.phoneNumber = "01234567"
        XCTAssertEqual(sut.deliveryTelephone, "01234567")
    }
    
    func test_whenPhoneIsEmpty_givenMemberProfileIsNotNilAndPhoneValueIsPresent_thenDeliveryPhoneMatchesMemberProfileVersion() {
        let container = DIContainer(appState: AppState(), eventLogger: MockedEventLogger(), services: .mocked())
        container.appState.value.userData.memberProfile = MemberProfile.mockedData
        let sut = makeSUT(container: container)
        XCTAssertEqual(sut.deliveryTelephone, "0792334112")
    }
    
    func test_whenPhoneFieldIsEmpty_givenMemberProfileIsNil_thenDeliveryPhoneIsNil() {
        let sut = makeSUT()
        XCTAssertNil(sut.deliveryTelephone)
    }
    
    func test_whenAllowedMarketingChannelsPresentInAppState_thenAllowedMarketingChannelsPopulated() {
        let container = DIContainer(appState: AppState(), eventLogger: MockedEventLogger(), services: .mocked())
        
        let allowedMarketingChannels = [
            AllowedMarketingChannel(
                id: 123,
                name: "Facebook"),
            AllowedMarketingChannel(
                id: 456,
                name: "Google")
        ]
        
        let retailStoreDetails = RetailStoreDetails(
            id: 123,
            menuGroupId: 123,
            storeName: "Test Store",
            telephone: "123344",
            lat: 1,
            lng: 1,
            ordersPaused: false,
            canDeliver: true,
            distance: 30,
            pausedMessage: nil,
            address1: "Test address",
            address2: nil,
            town: "Test Town",
            postcode: "TEST",
            customerOrderNotePlaceholder: nil,
            memberEmailCheck: false,
            guestCheckoutAllowed: true,
            basketOnlyTimeSelection: false,
            ratings: nil,
            tips: nil,
            storeLogo: nil,
            storeProductTypes: nil,
            orderMethods: nil,
            deliveryDays: [
                RetailStoreFulfilmentDay(date: Date().trueDate.dateOnlyString(storeTimeZone: nil), holidayMessage: nil, start: nil, end: nil, storeDateStart: nil, storeDateEnd: nil),
                RetailStoreFulfilmentDay(date: Date().advanced(by: 86400).trueDate.dateOnlyString(storeTimeZone: nil), holidayMessage: nil, start: nil, end: nil, storeDateStart: nil, storeDateEnd: nil)
            ],
            collectionDays: [],
            paymentMethods: nil,
            paymentGateways: nil,
            allowedMarketingChannels: allowedMarketingChannels,
            timeZone: nil, searchPostcode: nil)
        container.appState.value.userData.selectedStore = .loaded(retailStoreDetails)
        let sut = makeSUT(container: container)
        XCTAssertEqual(sut.allowedMarketingChannels, allowedMarketingChannels)
    }
    
    func test_whenAllowedMarketingChannelsEmptyInAppState_thenAllowedMarketingChannelsNil() {
        let container = DIContainer(appState: AppState(), eventLogger: MockedEventLogger(), services: .mocked())
        
        let retailStoreDetails = RetailStoreDetails(
            id: 123,
            menuGroupId: 123,
            storeName: "Test Store",
            telephone: "123344",
            lat: 1,
            lng: 1,
            ordersPaused: false,
            canDeliver: true,
            distance: 30,
            pausedMessage: nil,
            address1: "Test address",
            address2: nil,
            town: "Test Town",
            postcode: "TEST",
            customerOrderNotePlaceholder: nil,
            memberEmailCheck: false,
            guestCheckoutAllowed: true,
            basketOnlyTimeSelection: false,
            ratings: nil,
            tips: nil,
            storeLogo: nil,
            storeProductTypes: nil,
            orderMethods: nil,
            deliveryDays: [
                RetailStoreFulfilmentDay(date: Date().trueDate.dateOnlyString(storeTimeZone: nil), holidayMessage: nil, start: nil, end: nil, storeDateStart: nil, storeDateEnd: nil),
                RetailStoreFulfilmentDay(date: Date().advanced(by: 86400).trueDate.dateOnlyString(storeTimeZone: nil), holidayMessage: nil, start: nil, end: nil, storeDateStart: nil, storeDateEnd: nil)
            ],
            collectionDays: [],
            paymentMethods: nil,
            paymentGateways: nil,
            allowedMarketingChannels: [],
            timeZone: nil, searchPostcode: nil)
        container.appState.value.userData.selectedStore = .loaded(retailStoreDetails)
        let sut = makeSUT(container: container)
        XCTAssertNil(sut.allowedMarketingChannels)
    }
    
    func test_whenSelectedSlotIsToday_thenSelectedSlotIsDeliveryToday() {
        let container = DIContainer(appState: AppState(), eventLogger: MockedEventLogger(), services: .mocked())
        
        container.appState.value.userData.basket = Basket.mockedData
        
        let sut = makeSUT(container: container)
        
        XCTAssertEqual(sut.selectedSlot, "\(sut.fulfilmentTypeString) " + GeneralStrings.today.localized)
    }
    
    func test_whenSelectedSlotIsNotToday_givenFulfilmentTypeIsDelivery_thenSelectedSlotIsDeliveryToday() {
        let container = DIContainer(appState: AppState(), eventLogger: MockedEventLogger(), services: .mocked())
        
        container.appState.value.userData.basket = Basket.mockedDataSetDate
        
        let sut = makeSUT(container: container)
        
        let slotString = container.appState.value.userData.basket?.selectedSlot?.fulfilmentString(
            container: container,
            isInCheckout: true,
            timeZone: .current)
        
        XCTAssertEqual(sut.selectedSlot, Strings.CheckoutDetails.ChangeFulfilmentMethodCustom.slotTimeDelivery.localizedFormat(slotString!))
    }
    
    func test_whenSelectedSlotIsNotToday_givenFulfilmentTypeIsCollection_thenSelectedSlotIsDeliveryToday() {
        let container = DIContainer(appState: AppState(), eventLogger: MockedEventLogger(), services: .mocked())
        
        container.appState.value.userData.basket = Basket.mockedDataSetDateCollection
        
        let sut = makeSUT(container: container)
        
        let slotString = container.appState.value.userData.basket?.selectedSlot?.fulfilmentString(
            container: container,
            isInCheckout: true,
            timeZone: .current)
        
        XCTAssertEqual(sut.selectedSlot, Strings.CheckoutDetails.ChangeFulfilmentMethodCustom.slotTimeCollection.localizedFormat(slotString!))
    }
    
    func test_whenFulfilmentTypeIsDelivery_thenFulfilmentTypeStringIsDelivery() {
        let container = DIContainer(appState: AppState(), eventLogger: MockedEventLogger(), services: .mocked())
        container.appState.value.userData.basket = Basket.mockedData
        
        let sut = makeSUT(container: container)
        XCTAssertEqual(sut.fulfilmentTypeString, GeneralStrings.delivery.localized)
    }
    
    func test_whenFulfilmentTypeIsCollection_thenFulfilmentTypeStringIsCollection() {
        let container = DIContainer(appState: AppState(), eventLogger: MockedEventLogger(), services: .mocked())
        container.appState.value.userData.basket = Basket.mockedDataCollection
        
        let sut = makeSUT(container: container)
        XCTAssertEqual(sut.fulfilmentTypeString, GeneralStrings.collection.localized)
    }
    
    func test_whenDeliverySlotEndIsAfterCurrentDate_thenDeliverySlotExpiredIsFalse() {
        let container = DIContainer(appState: AppState(), eventLogger: MockedEventLogger(), services: .mocked())
        
        container.appState.value.userData.basket = Basket.mockedData
        
        let sut = makeSUT(container: container)
        
        XCTAssertFalse(sut.deliverySlotExpired)
    }
    
    func test_whenDeliverySlotEndIsBeforeCurrentDate_thenDeliverySlotExpiredIsTrue() {
        let container = DIContainer(appState: AppState(), eventLogger: MockedEventLogger(), services: .mocked())
        
        container.appState.value.userData.basket = Basket.mockedDataWithExpiredSlot
        
        let sut = makeSUT(container: container)
        
        XCTAssertTrue(sut.deliverySlotExpired)
    }
    
    func test_whenNoSlotSelected_thenDeliverySlotExpiredIsFalse() {
        let container = DIContainer(appState: AppState(), eventLogger: MockedEventLogger(), services: .mocked())
                
        let sut = makeSUT(container: container)
        
        XCTAssertFalse(sut.deliverySlotExpired)
    }
    
    func test_whenCheckoutStateSet_thenProgressStateUpdated() {
        let sut = makeSUT()
        let expectation = expectation(description: "setProgressState")
        var cancellables = Set<AnyCancellable>()
        
        sut.checkoutState = .card
        sut.$checkoutState
            .first()
            .receive(on: RunLoop.main)
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 2)
        
        XCTAssertEqual(sut.progressState, .payment)
    }
    
    func test_whenProfileIsPresent_thenProfileSet() {
        let container = DIContainer(appState: AppState(), eventLogger: MockedEventLogger(), services: .mocked())
        
        let expectation = expectation(description: "setMemberProfile")
        var cancellables = Set<AnyCancellable>()
        
        let sut = makeSUT(container: container)
        
        XCTAssertNil(sut.memberProfile)
        
        container.appState.value.userData.memberProfile = MemberProfile.mockedData
        
        sut.$memberProfile
            .first()
            .receive(on: RunLoop.main)
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 2)
        
        XCTAssertEqual(sut.memberProfile, MemberProfile.mockedData)
    }
    
    func test_whenSlotExpiresInLessThan5Mins_thenSlotExpiringInReturnsIntValue() {
        let container = DIContainer(appState: AppState(), eventLogger: MockedEventLogger(), services: .mocked())

        container.appState.value.userData.basket = Basket.mockedDataWithSlotExpiringInLessThan5Mins
        
        let sut = makeSUT(container: container)
        
        XCTAssertNotNil(sut.slotExpiringIn)
    }
    
    func test_whenSlotDoesNotExpireInLessThan5Mins_thenSlotExpiringInReturnsNil() {
        let container = DIContainer(appState: AppState(), eventLogger: MockedEventLogger(), services: .mocked())

        container.appState.value.userData.basket = Basket.mockedDataTomorrowSlot
        
        let sut = makeSUT(container: container)
        
        XCTAssertNil(sut.slotExpiringIn)
    }
    
    func test_whenSlotIsNil_thenSlotExpiringInReturnsNil() {
        let container = DIContainer(appState: AppState(), eventLogger: MockedEventLogger(), services: .mocked())
        
        let sut = makeSUT(container: container)
        
        XCTAssertNil(sut.slotExpiringIn)
    }
    
    func test_whenBackButtonPressed_givenCurrentStateIsInitial_thenKeepAliveIsFalse() {
        let sut = makeSUT()
        sut.checkoutState = .initial
        sut.backButtonPressed()
        XCTAssertFalse(sut.keepCheckoutFlowAlive)
    }
    
    func test_whenBackButtonPressed_givenStateIsDetailsAndMemberProfilIsNotNil_thenKeepCheckoutFlowAliveIsFalse() {
        let sut = makeSUT()
        sut.container.appState.value.userData.memberProfile = MemberProfile.mockedData
        sut.checkoutState = .details
        XCTAssertFalse(sut.keepCheckoutFlowAlive)
    }
    
    func test_whenBackButtonPressed_givenCurrentStateIsLogin_thenCheckoutStateIsInitial() {
        let sut = makeSUT()
        sut.checkoutState = .login
        sut.backButtonPressed()
        XCTAssertEqual(sut.checkoutState, .initial)
    }
    
    func test_whenBackButtonPressed_givenCurrentStateIsCreateAccount_thenCheckoutStateIsInitial() {
        let sut = makeSUT()
        sut.checkoutState = .createAccount
        sut.backButtonPressed()
        XCTAssertEqual(sut.checkoutState, .initial)
    }
    
    func test_whenBackButtonPressed_givenCurrentStateIsDetailsAndMemberProfileIsNil_thenCheckoutStateIsInitial() {

        let sut = makeSUT()
        sut.checkoutState = .details
        sut.backButtonPressed()
        XCTAssertFalse(sut.keepCheckoutFlowAlive)
    }
    
    func test_whenBackButtonPressed_givenCurrentStateIsDetailsAndMemberProfileIsNotNil_thenKeepCheckoutFlowAliveIsFalse() {
        let container = DIContainer(appState: AppState(), eventLogger: MockedEventLogger(), services: .mocked())
        container.appState.value.userData.memberProfile = MemberProfile.mockedData
        let sut = makeSUT()
        sut.checkoutState = .details
        sut.backButtonPressed()
        XCTAssertFalse(sut.keepCheckoutFlowAlive)
    }
    
    func test_whenBackButtonPressed_givenCurrentStateIsCard_thenCheckoutStateIsInitial() {

        let sut = makeSUT()
        sut.checkoutState = .card
        sut.backButtonPressed()
        XCTAssertEqual(sut.checkoutState, .paymentSelection)
    }
    
    func test_whenBackButtonPressed_givenCurrentStateIsPaymentSelection_thenCheckoutStateIsDetails() {

        let sut = makeSUT()
        sut.checkoutState = .paymentSelection
        sut.backButtonPressed()
        XCTAssertEqual(sut.checkoutState, .details)
    }
    
    func test_whenBackButtonPressed_givenCurrentStateIsPaymentSuccess_thenCheckoutStateDoesNotChange() {

        let sut = makeSUT()
        sut.checkoutState = .paymentSuccess
        sut.backButtonPressed()
        XCTAssertEqual(sut.checkoutState, .paymentSuccess)
    }
    
    func test_whenBackButtonPressed_givenCurrentStateIsPaymentFailure_thenCheckoutStateDoesNotChange() {

        let sut = makeSUT()
        sut.checkoutState = .paymentFailure
        sut.backButtonPressed()
        XCTAssertEqual(sut.checkoutState, .paymentFailure)
    }
    
    func test_whenGuestCheckoutTapped_thenNavigationDirectionIsForwardAndCheckoutStateIsDetails() {
        let sut = makeSUT()
        sut.guestCheckoutTapped()
        XCTAssertEqual(sut.navigationDirection, .forward)
        XCTAssertEqual(sut.checkoutState, .details)
    }
    
    func test_whenLoginTapped_thenNavigationDirectionIsForwardAndCheckoutStateIsLogin() {
        let sut = makeSUT()
        sut.loginToAccountTapped()
        XCTAssertEqual(sut.navigationDirection, .forward)
        XCTAssertEqual(sut.checkoutState, .login)
    }
    
    func test_whenCreateAccountTapped_thenNavigationDirectionIsForwardAndCheckoutStateIsCreate() {
        let sut = makeSUT()
        sut.createAccountTapped()
        XCTAssertEqual(sut.navigationDirection, .forward)
        XCTAssertEqual(sut.checkoutState, .createAccount)
    }
    
    func test_whenFirstNameIsEmpty_givenBasketAddressFirstNameIsPopulated_thenFirstNameMatchesBasket() {
        let container = DIContainer(appState: AppState(), eventLogger: MockedEventLogger(), services: .mocked())
        
        container.appState.value.userData.basket = Basket.mockedDataWithAddresses
        
        let sut = makeSUT(container: container)
        
        XCTAssertEqual(sut.firstname, "Kevin")
    }
    
    func test_whenLastNameIsEmpty_givenBasketAddressLastNameIsPopulated_thenLastNameMatchesBasket() {
        let container = DIContainer(appState: AppState(), eventLogger: MockedEventLogger(), services: .mocked())
        
        container.appState.value.userData.basket = Basket.mockedDataWithAddresses
        
        let sut = makeSUT(container: container)
        
        XCTAssertEqual(sut.lastname, "Dover")
    }
    
    func test_whenEmailIsEmpty_givenBasketAddressEmailIsPopulated_thenEmailMatchesBasket() {
        let container = DIContainer(appState: AppState(), eventLogger: MockedEventLogger(), services: .mocked())
        
        container.appState.value.userData.basket = Basket.mockedDataWithAddresses
        
        let sut = makeSUT(container: container)
        
        XCTAssertEqual(sut.email, "kevin.dover@me.com")
    }
    
    func test_whenPhoneIsEmpty_givenBasketAddressPhoneIsPopulated_thenPhoneMatchesBasket() {
        let container = DIContainer(appState: AppState(), eventLogger: MockedEventLogger(), services: .mocked())
        
        container.appState.value.userData.basket = Basket.mockedDataWithAddresses
        
        let sut = makeSUT(container: container)
        
        XCTAssertEqual(sut.phoneNumber, "07925304522")
    }
    
    func test_whenFirstNameIsEmpty_givenBasketAddressIsEmptyAndProfileIsComplete_thenFirstNAmeMatchesProfile() {
        let container = DIContainer(appState: AppState(), eventLogger: MockedEventLogger(), services: .mocked())
        
        container.appState.value.userData.basket = Basket.mockedDataNoAddresses
        
        container.appState.value.userData.memberProfile = MemberProfile.mockedData
        
        let sut = makeSUT(container: container)
        
        XCTAssertEqual(sut.firstname, "Harold")
    }
    
    func test_whenLastNameIsEmpty_givenBasketAddressIsEmptyAndProfileIsComplete_thenLastNameMatchesProfile() {
        let container = DIContainer(appState: AppState(), eventLogger: MockedEventLogger(), services: .mocked())
        
        container.appState.value.userData.basket = Basket.mockedDataNoAddresses
        
        container.appState.value.userData.memberProfile = MemberProfile.mockedData
        
        let sut = makeSUT(container: container)
        
        XCTAssertEqual(sut.lastname, "Brown")
    }
    
    func test_whenEmailIsEmpty_givenBasketAddressIsEmptyAndProfileIsComplete_thenEmailMatchesProfile() {
        let container = DIContainer(appState: AppState(), eventLogger: MockedEventLogger(), services: .mocked())
        
        container.appState.value.userData.basket = Basket.mockedDataNoAddresses
        
        container.appState.value.userData.memberProfile = MemberProfile.mockedData
        
        let sut = makeSUT(container: container)
        
        XCTAssertEqual(sut.email, "h.brown@gmail.com")
    }
    
    func test_whenPhoneIsEmpty_givenBasketAddressIsEmptyAndProfileIsComplete_thenPhoneMatchesProfile() {
        let container = DIContainer(appState: AppState(), eventLogger: MockedEventLogger(), services: .mocked())
        
        container.appState.value.userData.basket = Basket.mockedDataNoAddresses
        
        container.appState.value.userData.memberProfile = MemberProfile.mockedData
        
        let sut = makeSUT(container: container)
        
        XCTAssertEqual(sut.phoneNumber, "0792334112")
    }
    
    func test_whenChannelIsSelected_thenSelectedChannelSet() {
        let sut = makeSUT()
        let channel = AllowedMarketingChannel(id: 123, name: "Facebook")
        sut.channelSelected(AllowedMarketingChannel(id: channel.id, name: channel.name))
        XCTAssertEqual(sut.selectedChannel, channel)
    }
    
    func test_whenChannelSet_thenThenAllowedMarketingChannelTextSet() {
        let sut = makeSUT()
        
        let expectation = expectation(description: "channelSetAndTextUpdated")
        var cancellables = Set<AnyCancellable>()
        
        sut.$selectedChannel
            .first()
            .receive(on: RunLoop.main)
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        sut.channelSelected(AllowedMarketingChannel(id: 123, name: "Facebook"))
        
        wait(for: [expectation], timeout: 2)
        
        XCTAssertEqual(sut.allowedMarketingChannelText, "Facebook")
    }
    
    func test_whenGoToPaymentTapped_givenFulfimentIsDeliveryAndContactOrAddressInfoIsMissing_thenShowFieldErrorsAlertIsTrueAndIsSubmittingIsFalse() async {
        let container = DIContainer(appState: AppState(), eventLogger: MockedEventLogger(), services: .mocked())
        
        container.appState.value.userData.basket = Basket.mockedData
        let sut = makeSUT(container: container)
        await sut.goToPaymentTapped(setDelivery: {}, updateMarketingPreferences: {})
        XCTAssertFalse(sut.isSubmitting)
    }
    
    func test_whenGoToPaymentTapped_givenFulfimentIsCollectionAndONLYAddressInfoIsMissing_thenShowFieldErrorsAlertIsFalse() async {
        let container = DIContainer(appState: AppState(), eventLogger: MockedEventLogger(), services: .mocked())
        
        container.appState.value.userData.basket = Basket.mockedDataCollection
        
        let sut = makeSUT(container: container)
        sut.firstname = "test"
        sut.lastname = "test"
        sut.email = "test@test.com"
        sut.phoneNumber = "1234556"
        
        await sut.goToPaymentTapped(setDelivery: {}, updateMarketingPreferences: {})
        XCTAssertFalse(sut.showFieldErrorsAlert)
    }
    
    func test_whenMemberProfileSet_givenBillingAddressExistsAndFirstNameEmpty_thenFirstNameSetToMemberFirstName() {
        let container = DIContainer(appState: AppState(), eventLogger: MockedEventLogger(), services: .mocked())
        container.appState.value.userData.basket = Basket.mockedDataWithAddressesEmptyContacts
        container.appState.value.userData.memberProfile = MemberProfile.mockedData
        
        let sut = makeSUT(container: container)
        
        let expectation = expectation(description: "setFirstName")
        var cancellables = Set<AnyCancellable>()
        
        sut.$memberProfile
            .first()
            .receive(on: RunLoop.main)
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 2)
        
        XCTAssertEqual(sut.firstname, "Harold")
    }
    
    func test_whenMemberProfileSet_givenBillingAddressExistsAndLastNameEmpty_thenLastNameSetToMemberLastName() {
        let container = DIContainer(appState: AppState(), eventLogger: MockedEventLogger(), services: .mocked())
        container.appState.value.userData.basket = Basket.mockedDataWithAddressesEmptyContacts
        container.appState.value.userData.memberProfile = MemberProfile.mockedData
        
        let sut = makeSUT(container: container)
        
        let expectation = expectation(description: "setLastName")
        var cancellables = Set<AnyCancellable>()
        
        sut.$memberProfile
            .first()
            .receive(on: RunLoop.main)
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 2)
        
        XCTAssertEqual(sut.lastname, "Brown")
    }
    
    func test_whenMemberProfileSet_givenBillingAddressExistsAndEmailEmpty_thenEmailSetToMemberEmail() {
        let container = DIContainer(appState: AppState(), eventLogger: MockedEventLogger(), services: .mocked())
        container.appState.value.userData.basket = Basket.mockedDataWithAddressesEmptyContacts
        container.appState.value.userData.memberProfile = MemberProfile.mockedData
        
        let sut = makeSUT(container: container)
        
        let expectation = expectation(description: "setEmail")
        var cancellables = Set<AnyCancellable>()
        
        sut.$memberProfile
            .first()
            .receive(on: RunLoop.main)
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 2)
        
        XCTAssertEqual(sut.email, "h.brown@gmail.com")
    }
    
    func test_whenMemberProfileSet_givenBillingAddressExistsAndPhone_thenPhoneSetToMemberPhone() {
        let container = DIContainer(appState: AppState(), eventLogger: MockedEventLogger(), services: .mocked())
        container.appState.value.userData.basket = Basket.mockedDataWithAddressesEmptyContacts
        container.appState.value.userData.memberProfile = MemberProfile.mockedData
        
        let sut = makeSUT(container: container)
        
        let expectation = expectation(description: "setPhone")
        var cancellables = Set<AnyCancellable>()
        
        sut.$memberProfile
            .first()
            .receive(on: RunLoop.main)
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 2)
        
        XCTAssertEqual(sut.phoneNumber, "0792334112")
    }
    
    
    func test_whenGoToPaymentTapped_givenNoFieldErrors_setDeliveryTriggered() async {
        
        let request = BasketContactDetailsRequest(
            firstName: "test",
            lastName: "test",
            email: "test@test.com",
            telephone: "1234556")

        let container = DIContainer(appState: AppState(), eventLogger: MockedEventLogger(), services: .mocked(basketService: [.setContactDetails(details: request)]))
        
        container.appState.value.userData.basket = Basket.mockedData
        
        var setDeliveryTriggered = false
        
        let sut = makeSUT(container: container)
        sut.firstname = "test"
        sut.lastname = "test"
        sut.email = "test@test.com"
        sut.phoneNumber = "1234556"
        
        
        await sut.goToPaymentTapped(setDelivery: {
            setDeliveryTriggered = true
        }, updateMarketingPreferences: {})
        XCTAssertTrue(setDeliveryTriggered)
        container.services.verify(as: .basket)
    }

    func test_whenPayByCardTapped_thenCheckoutStateIsCard() {
        let sut = makeSUT()
        sut.payByCardTapped()
        XCTAssertEqual(sut.checkoutState, .card)
    }

    func test_whenResetNewErrorsExist_thennewErrorsExistIsFalse() {
        let sut = makeSUT()
        sut.newErrorsExist = true
        sut.resetNewErrorsExist()
        XCTAssertFalse(sut.newErrorsExist)
    }
    
    func test_ifStepIsActive_thenIsStepIsActiveIsTrue() {
        let sut = makeSUT()
        sut.progressState = .details
        XCTAssertTrue(sut.stepIsActive(step: .details))
    }
    
    func test_ifStepHasBeenPassed_thenStepIsComplete() {
        let sut = makeSUT()
        sut.progressState = .payment
        XCTAssertTrue(sut.stepIsComplete(step: .details))
    }
    
    func test_whenCheckoutErrorIsMissingDetails_thenCorrectMessageAssignedToErrorDescription() {
        let error = CheckoutRootViewError.missingDetails
        XCTAssertEqual(error.errorDescription, Strings.CheckoutDetails.Errors.Missing.subtitle.localized)
    }
    
    func test_whenCheckoutErrorIsNoAddressFound_thenCorrectMessageAssignedToErrorDescription() {
        let error = CheckoutRootViewError.noAddressesFound
        XCTAssertEqual(error.errorDescription, Strings.CheckoutDetails.Errors.NoAddresses.postcodeSearch.localized)
    }
    
    func test_whenCheckoutErrorIsNoSavedAddressesFound_thenCorrectMessageAssignedToErrorDescription() {
        let error = CheckoutRootViewError.noSavedAddressesFound
        XCTAssertEqual(error.errorDescription, Strings.CheckoutDetails.Errors.NoAddresses.savedAddresses.localized)
    }
    
    func test_when_then() {
        let sut = makeSUT()
        sut.container.appState.value.userData.basket = Basket.mockedData
        sut.selectedRetailStoreFulfilmentTimeSlots = .loaded(RetailStoreTimeSlots.mockedAPIResponseData)
        
        let expectation = expectation(description: "tempTodayTimeSlot set")
        var cancellables = Set<AnyCancellable>()
        
        sut.$selectedRetailStoreFulfilmentTimeSlots
            .first()
            .receive(on: RunLoop.main)
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 2)
        
        XCTAssertNotNil(sut.tempTodayTimeSlot)
    }
    
    func test_whenAllContactDetailsAreMissing_thenContactDetailsMissingIsTrue() {
        let sut = makeSUT()
        XCTAssertTrue(sut.contactDetailsMissing())
    }
    
    func test_whenFirstNameMissing_thenContactDetailsMissingIsTrue() {
        let sut = makeSUT()
        sut.lastname = "test"
        sut.email = "test@test.com"
        sut.phoneNumber = "03003"
        XCTAssertTrue(sut.contactDetailsMissing())
    }
    
    func test_whenLastNameMissing_thenContactDetailsMissingIsTrue() {
        let sut = makeSUT()
        sut.firstname = "test"
        sut.email = "test@test.com"
        sut.phoneNumber = "03003"
        XCTAssertTrue(sut.contactDetailsMissing())
    }
    
    func test_whenEmailMissing_thenContactDetailsMissingIsTrue() {
        let sut = makeSUT()
        sut.firstname = "test"
        sut.lastname = "test"
        sut.phoneNumber = "03003"
        XCTAssertTrue(sut.contactDetailsMissing())
    }
    
    func test_whenEmailInvalid_thenContactDetailsMissingIsTrue() {
        let sut = makeSUT()
        sut.firstname = "test"
        sut.lastname = "test"
        sut.email = "ksjdlksjd"
        sut.phoneNumber = "03003"
        XCTAssertTrue(sut.contactDetailsMissing())
    }
    
    func test_whenPhoneNumberMissing_thenContactDetailsMissingIsTrue() {
        let sut = makeSUT()
        sut.firstname = "test"
        sut.lastname = "test"
        sut.email = "test@test.com"
        XCTAssertTrue(sut.contactDetailsMissing())
    }
    
    func test_whenAllContactFieldsValid_thenContactDetailsMissingIsFalse() {
        let sut = makeSUT()
        sut.firstname = "test"
        sut.lastname = "test"
        sut.email = "test@test.com"
        sut.phoneNumber = "558556"
        XCTAssertFalse(sut.contactDetailsMissing())
    }
    
    func makeSUT(container: DIContainer = DIContainer(appState: AppState(), eventLogger: MockedEventLogger(), services: .mocked())) -> CheckoutRootViewModel {
        @ObservedObject var basketViewModel = BasketViewModel(container: .preview)
        let sut = CheckoutRootViewModel(container: container, keepCheckoutFlowAlive: $basketViewModel.isContinueToCheckoutTapped)
        
        trackForMemoryLeaks(sut)
        
        return sut
    }
}
