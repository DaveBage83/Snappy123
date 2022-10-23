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
    // MARK: - Test init
    func test_init() {
        let container = DIContainer(appState: AppState(), eventLogger: MockedEventLogger(), services: .mocked())
        let store = RetailStoreDetails.mockedData
        container.appState.value.userData.basket = Basket.mockedData
        container.appState.value.userData.selectedStore = .loaded(store)
        let sut = makeSUT(container: container)
        XCTAssertEqual(sut.checkoutState, .initial)
        XCTAssertEqual(sut.maxProgress, 2)
        XCTAssertEqual(sut.currentProgress, 0)
        XCTAssertFalse(sut.firstNameHasWarning)
        XCTAssertFalse(sut.lastnameHasWarning)
        XCTAssertFalse(sut.emailHasWarning)
        XCTAssertFalse(sut.phoneNumberHasWarning)
        XCTAssertFalse(sut.newErrorsExist)
        XCTAssertEqual(sut.orderTotalPriceString, "£23.30")
        XCTAssertFalse(sut.showOTPPrompt)
        XCTAssertTrue(sut.otpTelephone.isEmpty)
        XCTAssertFalse(sut.registrationChecked)
        XCTAssertFalse(sut.showRetailMembership)
        XCTAssertEqual(sut.retailMembershipId, "")
        XCTAssertFalse(sut.retailMembershipIdHasWarning)
        XCTAssertFalse(sut.isLoading)
    }
    
    func test_calculateRetailMembershipVariables_givenRetailMembershipSelectedStores() {
        let container = DIContainer(appState: AppState(), eventLogger: MockedEventLogger(), services: .mocked())
        let store = RetailStoreDetails.mockedDataWithRetailMembership
        container.appState.value.userData.selectedStore = .loaded(store)
        let sut = makeSUT(container: container)
        XCTAssertTrue(sut.showRetailMembershipIdWarning)
        XCTAssertEqual(sut.retailMembershipIdName, store.retailCustomer?.membershipIdFieldPlaceholder)
        XCTAssertEqual(sut.retailMembershipIdInstructions, store.retailCustomer?.membershipIdPromptText)
    }
    
    func test_calculateRetailMembershipVariables_givenSelectedStoresHasNoRetailMembership() {
        let container = DIContainer(appState: AppState(), eventLogger: MockedEventLogger(), services: .mocked())
        let store = RetailStoreDetails.mockedData
        container.appState.value.userData.selectedStore = .loaded(store)
        let sut = makeSUT(container: container)
        XCTAssertFalse(sut.showRetailMembershipIdWarning)
        XCTAssertEqual(sut.retailMembershipIdName, "")
        XCTAssertEqual(sut.retailMembershipIdInstructions, "")
    }
    
    func test_givenCurrentStateIsPaymentSelectionAndMemberWithRetailMembershipPossibility_thenCheckRetailMembershipIdAndShowFields() {

        let data = CheckRetailMembershipIdResult.mockedDataWithMembershipWithIdWithoutOrders
        
        var memberService = MockedUserService(expected: [.checkRetailMembershipId])
        memberService.checkRetailMembershipIdResponse = .success(data)
        
        let services = DIContainer.Services(
            businessProfileService: MockedBusinessProfileService(expected: []),
            retailStoreService: MockedRetailStoreService(expected: []),
            retailStoreMenuService: MockedRetailStoreMenuService(expected: []),
            basketService: MockedBasketService(expected: []),
            memberService: memberService,
            checkoutService: MockedCheckoutService(expected: []),
            addressService: MockedAddressService(expected: []),
            utilityService: MockedUtilityService(expected: []),
            imageService: MockedImageService(expected: []),
            notificationService: MockedNotificationService(expected: []),
            userPermissionsService: MockedUserPermissionsService(expected: [])
        )
        let container = DIContainer(appState: AppState(), eventLogger: MockedEventLogger(), services: services)
        container.appState.value.userData.basket = Basket.mockedData
        container.appState.value.userData.selectedStore = .loaded(RetailStoreDetails.mockedDataWithRetailMembership)
        
        let sut = makeSUT(container: container, doNotTrackMemoryLeaks: true)
        
        //sut.checkoutState = .initial
        
        let expectation = expectation(description: #function)
        var cancellables = Set<AnyCancellable>()
        
        var isLoadingWasTrue = false
        
        sut.$isLoading
            .removeDuplicates()
            .receive(on: RunLoop.main)
            .sink { isLoading in
                if isLoading {
                    isLoadingWasTrue = true
                } else if isLoadingWasTrue && isLoading == false {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        // delay setting the member until here to trigger the binding that leads to
        // proceedToDetails(profile: profile) otherwise the sut init will start
        // before the above sut.$isLoading... is ready
        sut.container.appState.value.userData.memberProfile = MemberProfile.mockedData
        
        wait(for: [expectation], timeout: 2)
        
        XCTAssertTrue(isLoadingWasTrue)
        XCTAssertTrue(sut.showRetailMembership)
        XCTAssertEqual(sut.retailMembershipId, data.retailerMembershipId)
    }
    
    func test_givenCurrentStateIsPaymentSelectionAndMemberAlreadyPlacedOrdersWithRetailMemberId_thenCheckRetailMembershipIdAndHideFields() {

        let data = CheckRetailMembershipIdResult.mockedDataWithMembershipWithIdWithOrders
        
        var memberService = MockedUserService(expected: [.checkRetailMembershipId])
        memberService.checkRetailMembershipIdResponse = .success(data)
        
        let services = DIContainer.Services(
            businessProfileService: MockedBusinessProfileService(expected: []),
            retailStoreService: MockedRetailStoreService(expected: []),
            retailStoreMenuService: MockedRetailStoreMenuService(expected: []),
            basketService: MockedBasketService(expected: []),
            memberService: memberService,
            checkoutService: MockedCheckoutService(expected: []),
            addressService: MockedAddressService(expected: []),
            utilityService: MockedUtilityService(expected: []),
            imageService: MockedImageService(expected: []),
            notificationService: MockedNotificationService(expected: []),
            userPermissionsService: MockedUserPermissionsService(expected: [])
        )
        let container = DIContainer(appState: AppState(), eventLogger: MockedEventLogger(), services: services)
        container.appState.value.userData.basket = Basket.mockedData
        container.appState.value.userData.selectedStore = .loaded(RetailStoreDetails.mockedDataWithRetailMembership)
        
        let sut = makeSUT(container: container, doNotTrackMemoryLeaks: true)
        
        sut.checkoutState = .initial
        
        let expectation = expectation(description: #function)
        var cancellables = Set<AnyCancellable>()
        
        var isLoadingWasTrue = false
        
        sut.$isLoading
            .removeDuplicates()
            .receive(on: RunLoop.main)
            .sink { isLoading in
                if isLoading {
                    isLoadingWasTrue = true
                } else if isLoadingWasTrue && isLoading == false {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        // delay setting the member until here to trigger the binding that leads to
        // proceedToDetails(profile: profile) otherwise the sut init will start
        // before the above sut.$isLoading... is ready
        sut.container.appState.value.userData.memberProfile = MemberProfile.mockedData
        
        wait(for: [expectation], timeout: 2)
        
        XCTAssertTrue(isLoadingWasTrue)
        XCTAssertFalse(sut.showRetailMembership)
        XCTAssertEqual(sut.retailMembershipId, "")
    }
    
    func test_givenErrorWhenCheckingRetailMembershipId_thenHideFields() {

        let networkError = NSError(domain: NSURLErrorDomain, code: -1009, userInfo: [:])
        
        var memberService = MockedUserService(expected: [.checkRetailMembershipId])
        memberService.checkRetailMembershipIdResponse = .failure(networkError)
        
        let services = DIContainer.Services(
            businessProfileService: MockedBusinessProfileService(expected: []),
            retailStoreService: MockedRetailStoreService(expected: []),
            retailStoreMenuService: MockedRetailStoreMenuService(expected: []),
            basketService: MockedBasketService(expected: []),
            memberService: memberService,
            checkoutService: MockedCheckoutService(expected: []),
            addressService: MockedAddressService(expected: []),
            utilityService: MockedUtilityService(expected: []),
            imageService: MockedImageService(expected: []),
            notificationService: MockedNotificationService(expected: []),
            userPermissionsService: MockedUserPermissionsService(expected: [])
        )
        let container = DIContainer(appState: AppState(), eventLogger: MockedEventLogger(), services: services)
        container.appState.value.userData.basket = Basket.mockedData
        container.appState.value.userData.selectedStore = .loaded(RetailStoreDetails.mockedDataWithRetailMembership)
        
        let sut = makeSUT(container: container, doNotTrackMemoryLeaks: true)
        
        sut.checkoutState = .initial
        
        let expectation = expectation(description: #function)
        var cancellables = Set<AnyCancellable>()
        
        var isLoadingWasTrue = false
        
        sut.$isLoading
            .removeDuplicates()
            .receive(on: RunLoop.main)
            .sink { isLoading in
                if isLoading {
                    isLoadingWasTrue = true
                } else if isLoadingWasTrue && isLoading == false {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        // delay setting the member until here to trigger the binding that leads to
        // proceedToDetails(profile: profile) otherwise the sut init will start
        // before the above sut.$isLoading... is ready
        container.appState.value.userData.memberProfile = MemberProfile.mockedData
        
        wait(for: [expectation], timeout: 2)
        
        XCTAssertTrue(isLoadingWasTrue)
        XCTAssertFalse(sut.showRetailMembership)
        XCTAssertEqual(sut.retailMembershipId, "")
    }
    
    // MARK: - Test initial view navigation
    // On init, if user not logged in then state is .initial, progress .notStarted
    func test_whenInit_givenMemberProfileIsNil_thenCheckoutStateIsInitialAndProgressIsNotStarted() {
        let container = DIContainer(appState: AppState(), eventLogger: MockedEventLogger(), services: .mocked())
        container.appState.value.userData.memberProfile = nil
        let sut = makeSUT(container: container)
        XCTAssertEqual(sut.checkoutState, .initial)
        XCTAssertEqual(sut.progressState, .notStarted)
    }
    
    // On init, if user IS logged in then state is .details, progress .details (user taken straight to details screen)
    func test_whenInit_givenMemberProfileIsNOTNil_thenCheckoutStateIsDetailsAndProgressIsDetailsAndEventSent() {
        let eventLogger = MockedEventLogger(expected: [.sendEvent(for: .viewScreen(.in, .customerDetails), with: .firebaseAnalytics, params: [:])])
        let container = DIContainer(appState: AppState(), eventLogger: eventLogger, services: .mocked())
        
        container.appState.value.userData.memberProfile = MemberProfile.mockedData
        let sut = makeSUT(container: container)
        
        let expectation = expectation(description: "progressStateSetToDetails")
        var cancellables = Set<AnyCancellable>()
        
        sut.$progressState
            .first()
            .receive(on: RunLoop.main)
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 2)
        
        XCTAssertEqual(sut.checkoutState, .details)
        XCTAssertEqual(sut.progressState, .details)
        eventLogger.verify()
    }
    
    // When state is .initial, if back button is pressed we dismiss the navigation stack
    func test_whenBackButtonPressed_givenCurrentStateIsInitial_thenKeepDismissViewClosureTriggered() {
        let sut = makeSUT()
        var dismissViewTriggered = false
        
        sut.checkoutState = .initial
        sut.backButtonPressed(dismissView: {
           dismissViewTriggered = true
        })
        sut.navigationDirection = .back
        XCTAssertTrue(dismissViewTriggered)
    }
    
    // When state is .details and memberProfile is nil (i.e. user not logged in), if back button pressed then return to .initial state
    
    func test_whenBackButtonPressed_givenCurrentStateIsDetailsAndMemberProfileIsNil_thenCheckoutStateIsInitial() {

        let sut = makeSUT()
        sut.container.appState.value.userData.memberProfile = nil
        sut.checkoutState = .details
        var dismissViewTriggered = false
        sut.backButtonPressed {
            dismissViewTriggered = true
        }
        sut.navigationDirection = .back
        XCTAssertFalse(dismissViewTriggered)
    }
    
    func test_whenBackButtonPressed_givenCurrentStateIsCreateAccount_thenCheckoutStateIsInitial() {
        let sut = makeSUT()
        sut.checkoutState = .createAccount
        var dismissViewTriggered = false
        sut.backButtonPressed {
            dismissViewTriggered = true
        }
        XCTAssertEqual(sut.checkoutState, .initial)
        XCTAssertFalse(dismissViewTriggered)
    }

    func test_whenProgressStateExceedsMaxValue_thenReturnMaxValue() {
        let sut = makeSUT()
        sut.progressState = .completeSuccess
        XCTAssertEqual(sut.currentProgress, 2)
    }
    
    func test_whenFulfilmentIsDelivery_thenIsDeliveryIsTrue() {
        let sut = makeSUT()
        sut.container.appState.value.userData.basket = Basket.mockedData
        XCTAssertTrue(sut.showDeliveryNote)
    }
    
    func test_whenMemberProfileIsNil_thenUserSignedInIsFalse() {
        let sut = makeSUT()
        sut.container.appState.value.userData.memberProfile = nil
        XCTAssertFalse(sut.showMarketingPrefs)
    }
    
    func test_whenMemberProfileIsNotNil_thenUserSignedInIsTrue() {
        let sut = makeSUT()
        sut.container.appState.value.userData.memberProfile = MemberProfile.mockedData
        XCTAssertFalse(sut.showMarketingPrefs)
    }
    
    func test_whenFulfilmentIsNotDelivery_thenIsDeliveryIsFalse() {
        let sut = makeSUT()
        sut.container.appState.value.userData.basket = Basket.mockedDataCollection
        XCTAssertFalse(sut.showDeliveryNote)
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
                id: 123, name: "Facebook"),
            AllowedMarketingChannel(
                id: 456, name: "Google")
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
            timeZone: nil,
            currency: RetailStoreCurrency.mockedGBPData,
            retailCustomer: nil,
            searchPostcode: nil)
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
            timeZone: nil,
            currency: RetailStoreCurrency.mockedGBPData,
            retailCustomer: nil,
            searchPostcode: nil)
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
    
    func test_whenBackButtonPressed_givenCurrentStateIsLogin_thenCheckoutStateIsInitial() {
        let sut = makeSUT()
        sut.checkoutState = .login
        sut.backButtonPressed(dismissView: {})
        XCTAssertEqual(sut.checkoutState, .initial)
    }
    
    func test_whenBackButtonPressed_givenCurrentStateIsDetailsAndMemberProfileIsNotNil_thenDismissViewTriggered() {
        let container = DIContainer(appState: AppState(), eventLogger: MockedEventLogger(), services: .mocked())
        container.appState.value.userData.memberProfile = MemberProfile.mockedData
        let sut = makeSUT(container: container)
        sut.checkoutState = .details
        var dismissViewTriggered = false
        sut.backButtonPressed(dismissView: {
            dismissViewTriggered = true
        })
        XCTAssertTrue(dismissViewTriggered)
    }
    
    func test_whenBackButtonPressed_givenCurrentStateIsCard_thenCheckoutStateIsInitial() {

        let sut = makeSUT()
        sut.checkoutState = .card
        var dismissViewTriggered = false
        sut.backButtonPressed(dismissView: {
            dismissViewTriggered = true
        })
        XCTAssertEqual(sut.checkoutState, .paymentSelection)
        XCTAssertFalse(dismissViewTriggered)
    }
    
    func test_whenBackButtonPressed_givenCurrentStateIsPaymentSelection_thenCheckoutStateIsDetails() {

        let sut = makeSUT()
        sut.checkoutState = .paymentSelection
        var dismissViewTriggered = false
        sut.backButtonPressed(dismissView: {
            dismissViewTriggered = true
        })
        XCTAssertFalse(dismissViewTriggered)
        XCTAssertEqual(sut.checkoutState, .details)
    }
    
    func test_whenBackButtonPressed_givenCurrentStateIsPaymentSuccess_thenCheckoutStateDoesNotChange() {

        let sut = makeSUT()
        sut.checkoutState = .paymentSuccess
        var dismissViewTriggered = false
        sut.backButtonPressed(dismissView: {
            dismissViewTriggered = true
        })
        XCTAssertFalse(dismissViewTriggered)
        XCTAssertEqual(sut.checkoutState, .paymentSuccess)
    }

    func test_whenGuestCheckoutTapped_thenNavigationDirectionIsForwardAndCheckoutStateIsDetailsAndTriggerEvent() {
        let eventLogger = MockedEventLogger(expected: [.sendEvent(for: .checkoutAsGuestChosen, with: .firebaseAnalytics, params: [:])])
        let container = DIContainer(appState: AppState(), eventLogger: eventLogger, services: .mocked())
        let sut = makeSUT(container: container)
        sut.guestCheckoutTapped()
        XCTAssertEqual(sut.navigationDirection, .forward)
        XCTAssertEqual(sut.checkoutState, .details)
        eventLogger.verify()
    }
    
    func test_whenLoginTapped_thenNavigationDirectionIsForwardAndCheckoutStateIsLogin() {
        let sut = makeSUT()
        sut.loginToAccountTapped()
        XCTAssertEqual(sut.navigationDirection, .forward)
        XCTAssertEqual(sut.checkoutState, .login)
    }
    
    func test_whenCreateAccountTapped_thenNavigationDirectionIsForwardAndCheckoutStateIsCreateAndTriggerEvent() {
        let eventLogger = MockedEventLogger(expected: [.sendEvent(for: .checkoutAsNewMemberChosen, with: .firebaseAnalytics, params: [:])])
        let container = DIContainer(appState: AppState(), eventLogger: eventLogger, services: .mocked())
        let sut = makeSUT(container: container)
        sut.createAccountTapped()
        XCTAssertEqual(sut.navigationDirection, .forward)
        XCTAssertEqual(sut.checkoutState, .createAccount)
        eventLogger.verify()
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
        await sut.goToPaymentTapped(editAddressFieldErrors: [], setDelivery: {}, updateMarketingPreferences: {})
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
        
        await sut.goToPaymentTapped(editAddressFieldErrors: [], setDelivery: {}, updateMarketingPreferences: {})
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
        sut.selectedChannel = .init(id: 123, name: "Test")
        
        
        await sut.goToPaymentTapped(editAddressFieldErrors: [], setDelivery: {
            setDeliveryTriggered = true
        }, updateMarketingPreferences: {})
        XCTAssertTrue(setDeliveryTriggered)
        container.services.verify(as: .basket)
    }
    
    func test_givenStoreWithMemberEmailCheck_whenGoToPaymentTapped_thenCheckRegistrationTriggeredAndNothingElse() async {
        let selectedStore = RetailStoreDetails.mockedDataWithMemberEmailCheck
        let basket = Basket.mockedData
        let appState = AppState(system: AppState.System(), routing: AppState.ViewRouting(), businessData: AppState.BusinessData(), userData: AppState.UserData(selectedStore: .loaded(selectedStore), selectedFulfilmentMethod: .delivery, searchResult: .notRequested, basket: basket, currentFulfilmentLocation: nil, tempTodayTimeSlot: nil, basketDeliveryAddress: nil, memberProfile: nil), staticCacheData: AppState.StaticCacheData(), notifications: AppState.Notifications())
        let email = "test@test.com"

        let mockedEvent = MockedEventLogger(expected: [.sendEvent(for: .otpPresented, with: .appsFlyer, params: ["smsPossible":true])])
        let container = DIContainer(appState: appState, eventLogger: mockedEvent, services: .mocked(memberService: [.checkRegistrationStatus(email: email)]))
        
        var setDeliveryTriggered = false
        var updateMarketingPrefsTriggered = false
        
        let sut = makeSUT(container: container)
        sut.firstname = "test"
        sut.lastname = "test"
        sut.email = email
        sut.phoneNumber = "1234556"
        sut.selectedChannel = .init(id: 123, name: "Test")
        
        await sut.goToPaymentTapped(
            editAddressFieldErrors: [], setDelivery: { setDeliveryTriggered = true },
            updateMarketingPreferences: { updateMarketingPrefsTriggered = true }
        )
        
        XCTAssertFalse(setDeliveryTriggered)
        XCTAssertFalse(updateMarketingPrefsTriggered)
        XCTAssertFalse(sut.registrationChecked)
        XCTAssertTrue(sut.showOTPPrompt)
        container.services.verify(as: .basket)
        container.services.verify(as: .member)
        mockedEvent.verify()
    }
    
    func test_givenStoreWithMemberEmailCheck_whenGoToPaymentTappedGivenFieldErrorsExist_ReturnEarly() async {
        let selectedStore = RetailStoreDetails.mockedDataWithMemberEmailCheck
        let basket = Basket.mockedData
        let appState = AppState(system: AppState.System(), routing: AppState.ViewRouting(), businessData: AppState.BusinessData(), userData: AppState.UserData(selectedStore: .loaded(selectedStore), selectedFulfilmentMethod: .delivery, searchResult: .notRequested, basket: basket, currentFulfilmentLocation: nil, tempTodayTimeSlot: nil, basketDeliveryAddress: nil, memberProfile: nil), staticCacheData: AppState.StaticCacheData(), notifications: AppState.Notifications())
        let email = "test@test.com"

        let container = DIContainer(appState: appState, eventLogger: MockedEventLogger(), services: .mocked())
        
        var setDeliveryTriggered = false
        var updateMarketingPrefsTriggered = false
        
        let sut = makeSUT(container: container)
        sut.firstname = "test"
        sut.lastname = "test"
        sut.email = email
        sut.phoneNumber = "1234556"
        sut.selectedChannel = .init(id: 123, name: "Test")
        
        await sut.goToPaymentTapped(
            editAddressFieldErrors: [.city], setDelivery: { setDeliveryTriggered = true },
            updateMarketingPreferences: { updateMarketingPrefsTriggered = true }
        )
        
        XCTAssertFalse(setDeliveryTriggered)
        XCTAssertFalse(updateMarketingPrefsTriggered)
        XCTAssertFalse(sut.registrationChecked)
        XCTAssertFalse(sut.showOTPPrompt)
    }
    
    func test_givenStoreWithMemberEmailCheckAndUserSignedIn_whenGoToPaymentTapped_thenCheckRegistrationIsNotTriggeredAndContinues() async {
        let selectedStore = RetailStoreDetails.mockedDataWithMemberEmailCheck
        let basket = Basket.mockedData
        let memberProfile = MemberProfile.mockedData
        let appState = AppState(system: AppState.System(), routing: AppState.ViewRouting(), businessData: AppState.BusinessData(), userData: AppState.UserData(selectedStore: .loaded(selectedStore), selectedFulfilmentMethod: .delivery, searchResult: .notRequested, basket: basket, currentFulfilmentLocation: nil, tempTodayTimeSlot: nil, basketDeliveryAddress: nil, memberProfile: memberProfile), staticCacheData: AppState.StaticCacheData(), notifications: AppState.Notifications())
        let email = "test@test.com"
        let request = BasketContactDetailsRequest(
            firstName: "test",
            lastName: "test",
            email: email,
            telephone: "1234556")

        let container = DIContainer(appState: appState, eventLogger: MockedEventLogger(), services: .mocked(basketService: [.setContactDetails(details: request)]))
        
        var setDeliveryTriggered = false
        var updateMarketingPrefsTriggered = false
        
        let sut = makeSUT(container: container)
        sut.firstname = "test"
        sut.lastname = "test"
        sut.email = email
        sut.phoneNumber = "1234556"
        sut.selectedChannel = .init(id: 123, name: "Test")
        
        await sut.goToPaymentTapped(
            editAddressFieldErrors: [], setDelivery: { setDeliveryTriggered = true },
            updateMarketingPreferences: { updateMarketingPrefsTriggered = true }
        )
        
        XCTAssertTrue(setDeliveryTriggered)
        XCTAssertTrue(updateMarketingPrefsTriggered)
        XCTAssertTrue(sut.registrationChecked)
        XCTAssertFalse(sut.showOTPPrompt)
        container.services.verify(as: .basket)
        container.services.verify(as: .member)
    }
    
    func test_goToPaymentTapped_givenMemberWithRetailMembershipField_thenStoreRetailMembershipId() {
        
        let retailMemberId = " SOMETHINGNEW "
        // testing against the trimmed whitespaces also helps with any unit testing flakeness
        // that would otherwise arise whilst the sut.retailMembershipId is updated by the
        // viewModel on a main thread
        let trimmedRetailMemberId = retailMemberId.trimmingCharacters(in: .whitespacesAndNewlines)

        let request = BasketContactDetailsRequest(
            firstName: "test",
            lastName: "test",
            email: "joe@blogs.co.uk",
            telephone: "1234556"
        )

        let basketService = MockedBasketService(expected: [.setContactDetails(details: request)])
        var memberService = MockedUserService(expected: [
            .checkRetailMembershipId,
            .storeRetailMembershipId(retailMemberId: trimmedRetailMemberId)
        ])
        let data = CheckRetailMembershipIdResult.mockedDataWithMembershipWithIdWithoutOrders
        memberService.checkRetailMembershipIdResponse = .success(data)
        memberService.storeRetailMembershipIdResponse = .success(true)

        let services = DIContainer.Services(
            businessProfileService: MockedBusinessProfileService(expected: []),
            retailStoreService: MockedRetailStoreService(expected: []),
            retailStoreMenuService: MockedRetailStoreMenuService(expected: []),
            basketService: basketService,
            memberService: memberService,
            checkoutService: MockedCheckoutService(expected: []),
            addressService: MockedAddressService(expected: []),
            utilityService: MockedUtilityService(expected: []),
            imageService: MockedImageService(expected: []),
            notificationService: MockedNotificationService(expected: []),
            userPermissionsService: MockedUserPermissionsService(expected: [])
        )
        let container = DIContainer(appState: AppState(), eventLogger: MockedEventLogger(), services: services)
        container.appState.value.userData.basket = Basket.mockedData
        container.appState.value.userData.selectedStore = .loaded(RetailStoreDetails.mockedDataWithRetailMembership)

        let sut = makeSUT(container: container, doNotTrackMemoryLeaks: true)

        let expectation1 = expectation(description: "isLoading")
        let expectation2 = expectation(description: "checkoutState")
        let expectation3 = expectation(description: "retailMemberId")
        var cancellables = Set<AnyCancellable>()

        var isLoadingWasTrue = false

        sut.$isLoading
            .removeDuplicates()
            .receive(on: RunLoop.main)
            .sink { isLoading in
                if isLoading {
                    isLoadingWasTrue = true
                } else if isLoadingWasTrue && isLoading == false {
                    expectation1.fulfill()
                }
            }
            .store(in: &cancellables)

        // delay setting the member until here to trigger the binding that leads to
        // proceedToDetails(profile: profile) otherwise the sut init will start
        // before the above sut.$isLoading... is ready
        sut.container.appState.value.userData.memberProfile = MemberProfile.mockedData

        wait(for: [expectation1], timeout: 2)

        sut.$checkoutState
            .filter { $0 == .paymentSelection }
            .removeDuplicates()
            .receive(on: RunLoop.main)
            .sink { _ in
                expectation2.fulfill()
            }
            .store(in: &cancellables)
        
        sut.$retailMembershipId
            .filter { $0 == trimmedRetailMemberId }
            .removeDuplicates()
            .receive(on: RunLoop.main)
            .sink { _ in
                expectation3.fulfill()
            }
            .store(in: &cancellables)
        
        sut.firstname = request.firstName
        sut.lastname = request.lastName
        sut.email = request.email
        sut.phoneNumber = request.telephone
        sut.selectedChannel = .init(id: 123, name: "Test")
        sut.retailMembershipId = retailMemberId
        
        // Theory: declaring this test_ method with "async" should be sufficient so that
        // "Task { ... }" is not needed below.
        // In practice: as soon as "async" is used with this test_method then the sut
        // checkRetailMembershipId() method Task is not called until wait is allowed to
        // expire.
        Task {

            await sut.goToPaymentTapped(
                editAddressFieldErrors: [],
                setDelivery: { },
                updateMarketingPreferences: { }
            )

        }
        
        wait(for: [expectation2, expectation3], timeout: 2)

        container.services.verify(as: .basket)
        container.services.verify(as: .member)
        XCTAssertNil(sut.container.appState.value.latestError)
        XCTAssertFalse(sut.retailMembershipIdHasWarning)
    }
    
    func test_goToPaymentTapped_givenMemberWithRetailMembershipFieldWhichHasNotChanged_thenDoNotStoreRetailMembershipId() {
        
        let request = BasketContactDetailsRequest(
            firstName: "test",
            lastName: "test",
            email: "joe@blogs.co.uk",
            telephone: "1234556"
        )
        
        let basketService = MockedBasketService(expected: [.setContactDetails(details: request)])
        var memberService = MockedUserService(expected: [
            .checkRetailMembershipId
        ])
        let data = CheckRetailMembershipIdResult.mockedDataWithMembershipWithIdWithoutOrders
        memberService.checkRetailMembershipIdResponse = .success(data)
        memberService.storeRetailMembershipIdResponse = .success(true)

        let services = DIContainer.Services(
            businessProfileService: MockedBusinessProfileService(expected: []),
            retailStoreService: MockedRetailStoreService(expected: []),
            retailStoreMenuService: MockedRetailStoreMenuService(expected: []),
            basketService: basketService,
            memberService: memberService,
            checkoutService: MockedCheckoutService(expected: []),
            addressService: MockedAddressService(expected: []),
            utilityService: MockedUtilityService(expected: []),
            imageService: MockedImageService(expected: []),
            notificationService: MockedNotificationService(expected: []),
            userPermissionsService: MockedUserPermissionsService(expected: [])
        )
        let container = DIContainer(appState: AppState(), eventLogger: MockedEventLogger(), services: services)
        container.appState.value.userData.basket = Basket.mockedData
        container.appState.value.userData.selectedStore = .loaded(RetailStoreDetails.mockedDataWithRetailMembership)

        let sut = makeSUT(container: container, doNotTrackMemoryLeaks: true)

        let expectation1 = expectation(description: "isLoading")
        let expectation2 = expectation(description: "checkoutState")
        var cancellables = Set<AnyCancellable>()

        var isLoadingWasTrue = false

        sut.$isLoading
            .removeDuplicates()
            .receive(on: RunLoop.main)
            .sink { isLoading in
                if isLoading {
                    isLoadingWasTrue = true
                } else if isLoadingWasTrue && isLoading == false {
                    expectation1.fulfill()
                }
            }
            .store(in: &cancellables)

        // delay setting the member until here to trigger the binding that leads to
        // proceedToDetails(profile: profile) otherwise the sut init will start
        // before the above sut.$isLoading... is ready
        sut.container.appState.value.userData.memberProfile = MemberProfile.mockedData

        wait(for: [expectation1], timeout: 2)
        
        // at this point the retail membership field contains the retreived value
        XCTAssertEqual(sut.retailMembershipId, data.retailerMembershipId)

        sut.$checkoutState
            .filter { $0 == .paymentSelection }
            .removeDuplicates()
            .receive(on: RunLoop.main)
            .sink { _ in
                expectation2.fulfill()
            }
            .store(in: &cancellables)
        
        sut.firstname = request.firstName
        sut.lastname = request.lastName
        sut.email = request.email
        sut.phoneNumber = request.telephone
        sut.selectedChannel = .init(id: 123, name: "Test")
        
        // Theory: declaring this test_ method with "async" should be sufficient so that
        // "Task { ... }" is not needed below.
        // In practice: as soon as "async" is used with this test_method then the sut
        // checkRetailMembershipId() method Task is not called until wait is allowed to
        // expire.
        Task {

            await sut.goToPaymentTapped(
                editAddressFieldErrors: [],
                setDelivery: { },
                updateMarketingPreferences: { }
            )

        }
        
        wait(for: [expectation2], timeout: 2)

        container.services.verify(as: .basket)
        container.services.verify(as: .member)
        XCTAssertNil(sut.container.appState.value.latestError)
        XCTAssertFalse(sut.retailMembershipIdHasWarning)
    }
    
    // Need to look at this one
    func test_goToPaymentTapped_givenMemberWithRetailMembershipField_butErrorStoreRetailMembershipId_setError() {

        let networkError = NSError(domain: NSURLErrorDomain, code: -1009, userInfo: [:])
        let retailMemberId = "SOMETHINGNEW"

        let request = BasketContactDetailsRequest(
            firstName: "test",
            lastName: "test",
            email: "joe@blogs.co.uk",
            telephone: "1234556"
        )
        var memberService = MockedUserService(expected: [
            .checkRetailMembershipId,
            .storeRetailMembershipId(retailMemberId: retailMemberId)
        ])
        let data = CheckRetailMembershipIdResult.mockedDataWithMembershipWithIdWithoutOrders
        memberService.checkRetailMembershipIdResponse = .success(data)
        memberService.storeRetailMembershipIdResponse = .failure(networkError)

        let services = DIContainer.Services(
            businessProfileService: MockedBusinessProfileService(expected: []),
            retailStoreService: MockedRetailStoreService(expected: []),
            retailStoreMenuService: MockedRetailStoreMenuService(expected: []),
            basketService: MockedBasketService(expected: []),
            memberService: memberService,
            checkoutService: MockedCheckoutService(expected: []),
            addressService: MockedAddressService(expected: []),
            utilityService: MockedUtilityService(expected: []),
            imageService: MockedImageService(expected: []),
            notificationService: MockedNotificationService(expected: []),
            userPermissionsService: MockedUserPermissionsService(expected: [])
        )
        let container = DIContainer(appState: AppState(), eventLogger: MockedEventLogger(), services: services)
        container.appState.value.userData.basket = Basket.mockedData
        container.appState.value.userData.selectedStore = .loaded(RetailStoreDetails.mockedDataWithRetailMembership)

        let sut = makeSUT(container: container, doNotTrackMemoryLeaks: true)

        let expectation1 = expectation(description: "isLoading")
        let expectation2 = expectation(description: "checkoutState")
        var cancellables = Set<AnyCancellable>()

        var isLoadingWasTrue = false

        sut.$isLoading
            .removeDuplicates()
            .receive(on: RunLoop.main)
            .sink { isLoading in
                if isLoading {
                    isLoadingWasTrue = true
                } else if isLoadingWasTrue && isLoading == false {
                    expectation1.fulfill()
                }
            }
            .store(in: &cancellables)

        // delay setting the member until here to trigger the binding that leads to
        // proceedToDetails(profile: profile) otherwise the sut init will start
        // before the above sut.$isLoading... is ready
        sut.container.appState.value.userData.memberProfile = MemberProfile.mockedData

        wait(for: [expectation1], timeout: 2)

        sut.container.appState
            .map(\.latestError)
            .map { $0 != nil } // Convert into an Equatable type
            .filter { $0 }
            .removeDuplicates()
            .receive(on: RunLoop.main)
            .sink { _ in
                expectation2.fulfill()
            }
            .store(in: &cancellables)

        sut.firstname = request.firstName
        sut.lastname = request.lastName
        sut.email = request.email
        sut.phoneNumber = request.telephone
        sut.selectedChannel = .init(id: 123, name: "Test")
        sut.retailMembershipId = retailMemberId

        // Theory: declaring this test_ method with "async" should be sufficient so that
        // "Task { ... }" is not needed below.
        // In practice: as soon as "async" is used with this test_method then the sut
        // checkRetailMembershipId() method Task is not called until wait is allowed to
        // expire.
        Task {

            await sut.goToPaymentTapped(
                editAddressFieldErrors: [],
                setDelivery: { },
                updateMarketingPreferences: { }
            )

        }

        wait(for: [expectation2], timeout: 2)

        container.services.verify(as: .basket)
        container.services.verify(as: .member)
        XCTAssertEqual(sut.container.appState.value.latestError as? NSError, networkError)
        XCTAssertTrue(sut.retailMembershipIdHasWarning)
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
    
    func test_whenSelectedRetailStoreFulfilmentSlotsSet_thenTempTodayTImeSlotPopulated() {
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
    
    func test_givenStoreInfoWithForceMemberRegistration_whenInit_thenShowGuestCheckoutButtonIsFalse() {
        let selectedStore = RetailStoreDetails.mockedDataWithGuestCheckoutDisabled
        let appState = AppState(userData: AppState.UserData(selectedStore: .loaded(selectedStore), selectedFulfilmentMethod: .delivery, searchResult: .notRequested, basket: nil, currentFulfilmentLocation: nil, tempTodayTimeSlot: nil, basketDeliveryAddress: nil, memberProfile: nil))
        let container = DIContainer(appState: appState, eventLogger: MockedEventLogger(), services: .mocked())
        let sut = makeSUT(container: container)
        
        XCTAssertFalse(sut.showGuestCheckoutButton)
    }
    
    func test_givenShowOTPPromptIsTrue_whenTriggeringDismissOTPPrompt_thenShowOTPPromptIsFalse() {
        let sut = makeSUT()
        
        sut.showOTPPrompt = true
        
        sut.dismissOTPPrompt()
        
        XCTAssertFalse(sut.showOTPPrompt)
    }
    
    func test_whenFirstNameHasWarning_thenFirstErrorIsFirstName() {
        let sut = makeSUT()
        sut.firstNameHasWarning = true
        sut.lastnameHasWarning = true
        sut.emailHasWarning = true
        sut.phoneNumberHasWarning = true
        sut.postcodeHasWarning = true
        sut.addressLine1HasWarning = true
        sut.cityHasWarning = true
        sut.timeSlotHasWarning = true
        sut.selectedChannelHasWarning = true
        
        XCTAssertEqual(sut.firstError, .firstName)
    }
    
    func test_whenLastNameHasWarning_givenFirstNameDoesNot_thenFirstErrorIsLastName() {
        let sut = makeSUT()
        sut.lastnameHasWarning = true
        sut.emailHasWarning = true
        sut.phoneNumberHasWarning = true
        sut.postcodeHasWarning = true
        sut.addressLine1HasWarning = true
        sut.cityHasWarning = true
        sut.timeSlotHasWarning = true
        sut.selectedChannelHasWarning = true
        
        XCTAssertEqual(sut.firstError, .lastName)
    }
    
    func test_whenEmailHasWarning_givenNoPrecedingErrors_thenFirstErrorIsEmail() {
        let sut = makeSUT()
        sut.emailHasWarning = true
        sut.phoneNumberHasWarning = true
        sut.postcodeHasWarning = true
        sut.addressLine1HasWarning = true
        sut.cityHasWarning = true
        sut.timeSlotHasWarning = true
        sut.selectedChannelHasWarning = true
        
        XCTAssertEqual(sut.firstError, .email)
    }
    
    func test_whenPhoneHasWarning_givenNoPrecedingErrors_thenFirstErrorIsPhone() {
        let sut = makeSUT()
        sut.phoneNumberHasWarning = true
        sut.postcodeHasWarning = true
        sut.addressLine1HasWarning = true
        sut.cityHasWarning = true
        sut.timeSlotHasWarning = true
        sut.selectedChannelHasWarning = true
        
        XCTAssertEqual(sut.firstError, .phone)
    }
    
    func test_whenPostcodeHasWarning_givenNoPrecedingErrors_thenFirstErrorIsPostcode() {
        let sut = makeSUT()
        sut.postcodeHasWarning = true
        sut.addressLine1HasWarning = true
        sut.cityHasWarning = true
        sut.timeSlotHasWarning = true
        sut.selectedChannelHasWarning = true
        
        XCTAssertEqual(sut.firstError, .postcode)
    }
    
    func test_whenAddress1HasWarning_givenNoPrecedingErrors_thenFirstErrorIsAddress1() {
        let sut = makeSUT()
        sut.addressLine1HasWarning = true
        sut.cityHasWarning = true
        sut.timeSlotHasWarning = true
        sut.selectedChannelHasWarning = true
        
        XCTAssertEqual(sut.firstError, .addressLine1)
    }
    
    func test_whenCityHasWarning_givenNoPrecedingErrors_thenFirstErrorIsCity() {
        let sut = makeSUT()
        sut.cityHasWarning = true
        sut.timeSlotHasWarning = true
        sut.selectedChannelHasWarning = true
        
        XCTAssertEqual(sut.firstError, .city)
    }
    
    func test_whenTimeslotHasWarning_givenNoPrecedingErrors_thenFirstErrorIsTimeslot() {
        let sut = makeSUT()
        sut.timeSlotHasWarning = true
        sut.selectedChannelHasWarning = true
        
        XCTAssertEqual(sut.firstError, .timeSlot)
    }
    
    func makeSUT(container: DIContainer = DIContainer(appState: AppState(), eventLogger: MockedEventLogger(), services: .mocked()), doNotTrackMemoryLeaks: Bool = false) -> CheckoutRootViewModel {
        let sut = CheckoutRootViewModel(container: container)
        if doNotTrackMemoryLeaks == false {
            trackForMemoryLeaks(sut)
        }
        return sut
    }
}
