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
        let sut = makeSut()
        
        XCTAssertEqual(sut.firstname, "")
        XCTAssertEqual(sut.surname, "")
        XCTAssertEqual(sut.email, "")
        XCTAssertEqual(sut.phoneNumber, "")
        XCTAssertFalse(sut.isContinueTapped)
        XCTAssertEqual(sut.marketingPreferencesFetch, .notRequested)
        XCTAssertEqual(sut.updateMarketingOptionsRequest, .notRequested)
        XCTAssertEqual(sut.profileFetch, .notRequested)
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
    
    func test_whenAppStateContainsBasketContactDetails_thenInitialContactDetailsSet() {
        let basketContactDetails = BasketContactDetails(
            firstName: "Test First Name",
            surname: "Test Surname",
            email: "test@test.com",
            telephoneNumber: "8282292")
        
        let sut = makeSut(basketContactDetails: basketContactDetails)
        
        XCTAssertEqual(sut.firstname, "Test First Name")
        XCTAssertEqual(sut.surname, "Test Surname")
        XCTAssertEqual(sut.email, "test@test.com")
        XCTAssertEqual(sut.phoneNumber, "8282292")
    }
    
    func test_whenBasketContactDetailsSet_thenBasketContactDetailsInAppStateSet() {
        let sut = makeSut()
        
        let expectation = expectation(description: "basketContactDetailsUpdated")
        var cancellables = Set<AnyCancellable>()
        
        sut.$basketContactDetails
            .first()
            .receive(on: RunLoop.main)
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        let basketContactDetails = BasketContactDetails(
            firstName: "Test First Name",
            surname: "Test Surname",
            email: "test@test.com",
            telephoneNumber: "8282292")
        
        sut.basketContactDetails = basketContactDetails
        
        wait(for: [expectation], timeout: 5)
        
        XCTAssertEqual(sut.container.appState.value.userData.basketContactDetails, basketContactDetails)
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
    
    func makeSut(container: DIContainer = DIContainer(appState: AppState(), services: .mocked()), memberSignedIn: Bool = false, basketContactDetails: BasketContactDetails? = nil, profile: MemberProfile? = nil) -> CheckoutDetailsViewModel {
        
        if let profile = profile {
            container.appState.value.userData.memberProfile = profile
        }
        
        if let basketContactDetails = basketContactDetails {
            container.appState.value.userData.basketContactDetails = basketContactDetails
        }
        
        let sut = CheckoutDetailsViewModel(container: container)
        
        trackForMemoryLeaks(sut)
        
        return sut
    }
}
