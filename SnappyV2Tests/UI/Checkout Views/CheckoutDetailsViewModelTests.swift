//
//  CheckoutDetailsViewModelTests.swift
//  SnappyV2Tests
//
//  Created by David Bage on 23/02/2022.
//

import XCTest
import Combine
import SwiftUI
@testable import SnappyV2

class CheckoutDetailsViewModelTests: XCTestCase {
    typealias Checkmark = Image.General.Checkbox
    typealias MarketingStrings = Strings.CheckoutDetails.MarketingPreferences
    
    func test_init_whenNoMemberProfilePresent_thenMemberDetailsAreEmpty() {
        let container = DIContainer(appState: AppState(), services: .mocked(memberService: [.getMarketingOptions(isCheckout: true, notificationsEnabled: true)]))
        
        let sut = makeSut(container: container)
        
        XCTAssertEqual(sut.firstname, "")
        XCTAssertEqual(sut.surname, "")
        XCTAssertEqual(sut.email, "")
        XCTAssertEqual(sut.phoneNumber, "")
        XCTAssertFalse(sut.isContinueTapped)
        XCTAssertEqual(sut.marketingPreferencesFetch, .notRequested)
        XCTAssertEqual(sut.updateMarketingOptionsRequest, .notRequested)
        XCTAssertNil(sut.marketingOptionsResponses)
        XCTAssertNil(sut.userMarketingPreferences)
        XCTAssertFalse(sut.emailMarketingEnabled)
        XCTAssertFalse(sut.directMailMarketingEnabled)
        XCTAssertFalse(sut.notificationMarketingEnabled)
        XCTAssertFalse(sut.smsMarketingEnabled)
        XCTAssertFalse(sut.telephoneMarketingEnabled)
        XCTAssertFalse(sut.firstNameHasWarning)
        XCTAssertFalse(sut.surnameHasWarning)
        XCTAssertFalse(sut.emailHasWarning)
        XCTAssertFalse(sut.phoneNumberHasWarning)
        XCTAssertTrue(sut.canSubmit)
        XCTAssertFalse(sut.marketingPreferencesAreLoading)
        
        container.services.verify()
    }
    
    func test_givenBasketWithBillingAddress_thenContactDetailsFilledAtInit() {
        let firstName = "first"
        let lastName = "last"
        let town = "town"
        let postcode = "postcode"
        let type = "billing"
        let email = "email@email.com"
        let telephone = "01929"
        let billingAddressResponse = BasketAddressResponse(firstName: firstName, lastName: lastName, addressLine1: nil, addressLine2: nil, town: town, postcode: postcode, countryCode: nil, type: type, email: email, telephone: telephone, state: nil, county: nil, location: nil)
        let basket = Basket(
            basketToken: "",
            isNewBasket: true,
            items: [],
            fulfilmentMethod: BasketFulfilmentMethod(type: .delivery, cost: 0, minSpend: 0),
            selectedSlot: nil,
            savings: nil,
            coupon: nil,
            fees: nil,
            tips: nil,
            addresses: [billingAddressResponse],
            orderSubtotal: 0,
            orderTotal: 0
        )
        let userData = AppState.UserData(selectedStore: .notRequested, selectedFulfilmentMethod: .delivery, searchResult: .notRequested, basket: basket, currentFulfilmentLocation: nil, tempTodayTimeSlot: nil, basketDeliveryAddress: nil, memberProfile: nil)
        let appState = AppState(system: AppState.System(), routing: AppState.ViewRouting(), businessData: AppState.BusinessData(), userData: userData)
        let container = DIContainer(appState: appState, services: .mocked())
        let sut = makeSut(container: container)
        
        XCTAssertEqual(sut.firstname, firstName)
        XCTAssertEqual(sut.surname, lastName)
        XCTAssertEqual(sut.email, email)
        XCTAssertEqual(sut.phoneNumber, telephone)
    }
    
    func test_whenAddingBasketWithBillingAddress_thenContactDetailsFilled() {
        let firstName = "first"
        let lastName = "last"
        let town = "town"
        let postcode = "postcode"
        let type = "billing"
        let email = "email@email.com"
        let telephone = "01929"
        let billingAddressResponse = BasketAddressResponse(firstName: firstName, lastName: lastName, addressLine1: nil, addressLine2: nil, town: town, postcode: postcode, countryCode: nil, type: type, email: email, telephone: telephone, state: nil, county: nil, location: nil)
        let basket = Basket(
            basketToken: "",
            isNewBasket: true,
            items: [],
            fulfilmentMethod: BasketFulfilmentMethod(type: .delivery, cost: 0, minSpend: 0),
            selectedSlot: nil,
            savings: nil,
            coupon: nil,
            fees: nil,
            tips: nil,
            addresses: [billingAddressResponse],
            orderSubtotal: 0,
            orderTotal: 0
        )
        let container = DIContainer(appState: AppState(), services: .mocked())
        let sut = makeSut(container: container)
        
        let exp = expectation(description: "setupDetailsFromBasket")
        var cancellables = Set<AnyCancellable>()

        sut.$phoneNumber
            .first()
            .receive(on: RunLoop.main)
            .sink { _ in
                exp.fulfill()
            }
            .store(in: &cancellables)

        sut.container.appState.value.userData.basket = basket
        
        wait(for: [exp], timeout: 2)
        
        XCTAssertEqual(sut.firstname, firstName)
        XCTAssertEqual(sut.surname, lastName)
        XCTAssertEqual(sut.email, email)
        XCTAssertEqual(sut.phoneNumber, telephone)
    }
    
    func test_init_whenMemberProfilePresent_thenMemberDetailsPopulated() {
        let cancelbag = CancelBag()
        let sut = makeSut(profile: MemberProfile.mockedData)
        let expectation = expectation(description: "userProfileDetailsPopulated")
        
        sut.$profile
            .first()
            .receive(on: RunLoop.main)
            .sink { profile in
                XCTAssertEqual(sut.firstname, "Harold")
                XCTAssertEqual(sut.surname, "Brown")
                XCTAssertEqual(sut.email, "h.brown@gmail.com")
                XCTAssertEqual(sut.phoneNumber, "0792334112")
                expectation.fulfill()
            }
            .store(in: cancelbag)
        
        wait(for: [expectation], timeout: 0.2)
    }
    
    func test_whenProfilePhoneNumberIsEmpty_thenPhoneFieldIsEmpty() {
        let sut = makeSut(profile: MemberProfile.mockedDataNoPhone)
        let cancelbag = CancelBag()
        let expectation = expectation(description: "userProfileDetailsPopulated")
        
        sut.$profile
            .first()
            .receive(on: RunLoop.main)
            .sink { profile in
                XCTAssertEqual(sut.firstname, "Harold")
                XCTAssertEqual(sut.surname, "Brown")
                XCTAssertEqual(sut.email, "h.brown@gmail.com")
                XCTAssertEqual(sut.phoneNumber, "")
                expectation.fulfill()
            }
            .store(in: cancelbag)
        
        wait(for: [expectation], timeout: 0.2)
    }
    
    func test_whenPreferenceSettingsCalled_thenCorrectSettingsReturned() {
        let sut = makeSut()
        
        let emailPreferenceSettings = sut.preferenceSettings(type: .email)
        let directMailPreferenceSettings = sut.preferenceSettings(type: .directMail)
        let notificationPreferenceSettings = sut.preferenceSettings(type: .notification)
        let smsPreferenceSettings = sut.preferenceSettings(type: .sms)
        let telephonePreferenceSettings = sut.preferenceSettings(type: .telephone)
        
        XCTAssertEqual(emailPreferenceSettings.text, MarketingStrings.email.localized)
        XCTAssertEqual(directMailPreferenceSettings.text, MarketingStrings.directMail.localized)
        XCTAssertEqual(notificationPreferenceSettings.text, MarketingStrings.notifications.localized)
        XCTAssertEqual(smsPreferenceSettings.text, MarketingStrings.sms.localized)
        XCTAssertEqual(telephonePreferenceSettings.text, MarketingStrings.telephone.localized)
    }
    
    func test_whenEmailMarketingTapped_thenEmailMarketingEnabledToggled() {
        let sut = makeSut()
        XCTAssertFalse(sut.emailMarketingEnabled)
        sut.emailMarketingTapped()
        XCTAssertTrue(sut.emailMarketingEnabled)
        sut.emailMarketingTapped()
        XCTAssertFalse(sut.emailMarketingEnabled)
    }
    
    func test_whenDirectMailMarketingTapped_thenDirectMailMarketingEnabledToggled() {
        let sut = makeSut()
        XCTAssertFalse(sut.directMailMarketingEnabled)
        sut.directMailMarketingTapped()
        XCTAssertTrue(sut.directMailMarketingEnabled)
        sut.directMailMarketingTapped()
        XCTAssertFalse(sut.directMailMarketingEnabled)
    }
    
    func test_whenMobileNotificationsTapped_thenNotificationMarketingEnabledToggled() {
        let sut = makeSut()
        XCTAssertFalse(sut.notificationMarketingEnabled)
        sut.mobileNotificationsTapped()
        XCTAssertTrue(sut.notificationMarketingEnabled)
        sut.mobileNotificationsTapped()
        XCTAssertFalse(sut.notificationMarketingEnabled)
    }
    
    func test_whenSmsMarketingTappedTapped_thenSmsMarketingEnabledToggled() {
        let sut = makeSut()
        XCTAssertFalse(sut.smsMarketingEnabled)
        sut.smsMarketingTapped()
        XCTAssertTrue(sut.smsMarketingEnabled)
        sut.smsMarketingTapped()
        XCTAssertFalse(sut.smsMarketingEnabled)
    }
    
    func test_whenTelephoneMarketingTapped_thenTelephoneMarketingEnabledToggled() {
        let sut = makeSut()
        XCTAssertFalse(sut.telephoneMarketingEnabled)
        sut.telephoneMarketingTapped()
        XCTAssertTrue(sut.telephoneMarketingEnabled)
        sut.telephoneMarketingTapped()
        XCTAssertFalse(sut.telephoneMarketingEnabled)
    }
    
    func test_whenUpdateMarketingPreferencesTriggered_thenCorrectServiceCall() {
        let emailMarketingEnabled = false
        let directMailMarketingEnabled = true
        let notificationMarketingEnabled = false
        let smsMarketingEnabled = true
        let telephoneMarketingEnabled = false
        
        
        let preferences = [
            UserMarketingOptionRequest(type: MarketingOptions.email.rawValue, opted: emailMarketingEnabled.opted()),
            UserMarketingOptionRequest(type: MarketingOptions.directMail.rawValue, opted: directMailMarketingEnabled.opted()),
            UserMarketingOptionRequest(type: MarketingOptions.notification.rawValue, opted: notificationMarketingEnabled.opted()),
            UserMarketingOptionRequest(type: MarketingOptions.sms.rawValue, opted: smsMarketingEnabled.opted()),
            UserMarketingOptionRequest(type: MarketingOptions.telephone.rawValue, opted: telephoneMarketingEnabled.opted()),
        ]
        
        let container = DIContainer(appState: AppState(), services: .mocked(memberService: [.getMarketingOptions(isCheckout: true, notificationsEnabled: true), .updateMarketingOptions(options: preferences)]))
        
        let sut = makeSut(container: container)
        
        sut.emailMarketingEnabled = emailMarketingEnabled
        sut.directMailMarketingEnabled = directMailMarketingEnabled
        sut.notificationMarketingEnabled = notificationMarketingEnabled
        sut.smsMarketingEnabled = smsMarketingEnabled
        sut.telephoneMarketingEnabled = telephoneMarketingEnabled
        
        sut.exposeUpdateMarketingPreferences()
        
        container.services.verifyUserService()
    }
    
    func test_whenContinueButtonTapped_thenFieldWarningsSet() {
        let sut = makeSut()
        sut.continueButtonTapped()
        XCTAssertTrue(sut.emailHasWarning)
        XCTAssertTrue(sut.firstNameHasWarning)
        XCTAssertTrue(sut.surnameHasWarning)
        XCTAssertTrue(sut.phoneNumberHasWarning)
        
        sut.firstname = "Test Name"
        sut.surname = "Test Surname"
        sut.email = "test@test.com"
        sut.phoneNumber = "123456"
        
        sut.continueButtonTapped()
        XCTAssertFalse(sut.emailHasWarning)
        XCTAssertFalse(sut.firstNameHasWarning)
        XCTAssertFalse(sut.surnameHasWarning)
        XCTAssertFalse(sut.phoneNumberHasWarning)
    }
    
    func test_whenMarketingOptionsResponsesUpdated_thenMarketingEnabledFlagsUpdated() {
        let sut = makeSut()
        
        let expectation = expectation(description: "marketingPrefsFetch")
        var cancellables = Set<AnyCancellable>()
        
        sut.$marketingPreferencesFetch
            .first()
            .receive(on: RunLoop.main)
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        let preferences = [
            UserMarketingOptionResponse(type: "email", text: "Email", opted: .in),
            UserMarketingOptionResponse(type: "directMail", text: "Direct Mail", opted: .out),
            UserMarketingOptionResponse(type: "notification", text: "Notifications", opted: .in),
            UserMarketingOptionResponse(type: "sms", text: "SMS", opted: .in),
            UserMarketingOptionResponse(type: "telephone", text: "Telephone", opted: .out)
        ]
        
        let marketingFetch = UserMarketingOptionsFetch(
            marketingPreferencesIntro: "Test",
            marketingPreferencesGuestIntro: "Test",
            marketingOptions: preferences,
            fetchIsCheckout: true,
            fetchNotificationsEnabled: true,
            fetchBasketToken: nil,
            fetchTimestamp: nil)
        
        sut.marketingPreferencesFetch = .loaded(marketingFetch)

        wait(for: [expectation], timeout: 5)
        
        XCTAssertTrue(sut.emailMarketingEnabled)
        XCTAssertFalse(sut.directMailMarketingEnabled)
        XCTAssertTrue(sut.notificationMarketingEnabled)
        XCTAssertTrue(sut.smsMarketingEnabled)
        XCTAssertFalse(sut.telephoneMarketingEnabled)
    }
    
    func test_whenMarketingPreferencesAreLoading_thenMarketingPreferencesAreLoadingReturnsTrue() {
        let sut = makeSut()
        
        let preferences = [
            UserMarketingOptionResponse(type: "email", text: "Email", opted: .in),
            UserMarketingOptionResponse(type: "directMail", text: "Direct Mail", opted: .out),
            UserMarketingOptionResponse(type: "notification", text: "Notifications", opted: .in),
            UserMarketingOptionResponse(type: "sms", text: "SMS", opted: .in),
            UserMarketingOptionResponse(type: "telephone", text: "Telephone", opted: .out)
        ]
        
        let marketingFetch = UserMarketingOptionsFetch(
            marketingPreferencesIntro: "Test",
            marketingPreferencesGuestIntro: "Test",
            marketingOptions: preferences,
            fetchIsCheckout: true,
            fetchNotificationsEnabled: true,
            fetchBasketToken: nil,
            fetchTimestamp: nil)
        
        sut.marketingPreferencesFetch = .isLoading(last: marketingFetch, cancelBag: CancelBag())
        
        XCTAssertTrue(sut.marketingPreferencesAreLoading)
    }

    func test_whenMarketingPreferencesUpdated_thenUserMarketingPreferencesUpdated() {
        let sut = makeSut()
        
        let expectation = expectation(description: "marketingPreferencesUpdated")
        var cancellables = Set<AnyCancellable>()
        
        sut.$updateMarketingOptionsRequest
            .first()
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        let marketingUpdateResponse = UserMarketingOptionsUpdateResponse(
            email: .in,
            directMail: .out,
            notification: .in,
            telephone: .out,
            sms: .in)
        
        sut.updateMarketingOptionsRequest = .loaded(marketingUpdateResponse)
        
        wait(for: [expectation], timeout: 5)
        
        XCTAssertEqual(sut.userMarketingPreferences, marketingUpdateResponse)
    }
    
    func makeSut(container: DIContainer = DIContainer(appState: AppState(), services: .mocked()), memberSignedIn: Bool = false, profile: MemberProfile? = nil) -> CheckoutDetailsViewModel {
        
        if let profile = profile {
            container.appState.value.userData.memberProfile = profile
        }
        
        let sut = CheckoutDetailsViewModel(container: container)
        
        trackForMemoryLeaks(sut)
        
        return sut
    }
}
