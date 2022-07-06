//
//  CreateAccountViewModelTests.swift
//  SnappyV2Tests
//
//  Created by David Bage on 16/03/2022.
//

import XCTest
import Combine
import AppsFlyerLib
@testable import SnappyV2

@MainActor
class CreateAccountViewModelTests: XCTestCase {
    func test_init() {
        let sut = makeSUT()
        
        XCTAssertEqual(sut.firstName, "")
        XCTAssertEqual(sut.lastName, "")
        XCTAssertEqual(sut.email, "")
        XCTAssertEqual(sut.phone, "")
        XCTAssertEqual(sut.password, "")
        XCTAssertEqual(sut.referralCode, "")
        XCTAssertFalse(sut.passwordRevealed)
        
        XCTAssertFalse(sut.emailMarketingEnabled)
        XCTAssertFalse(sut.directMailMarketingEnabled)
        XCTAssertFalse(sut.notificationMarketingEnabled)
        XCTAssertFalse(sut.smsMarketingEnabled)
        XCTAssertFalse(sut.telephoneMarketingEnabled)
        
        XCTAssertFalse(sut.termsAgreed)
        
        XCTAssertFalse(sut.firstNameHasError)
        XCTAssertFalse(sut.lastNameHasError)
        XCTAssertFalse(sut.emailHasError)
        XCTAssertFalse(sut.phoneHasError)
        XCTAssertFalse(sut.passwordHasError)
        XCTAssertFalse(sut.termsAndConditionsHasError)
        XCTAssertFalse(sut.isLoading)
        XCTAssertFalse(sut.isInCheckout)
    }
    
    func test_basketTotalHasValue_thenOrderTotalPopulated() async throws {
        let container = DIContainer.preview
        container.appState.value.userData.basket = Basket.mockedData
        let sut = makeSUT(container: container)
        
        XCTAssertEqual(sut.orderTotal, 23.3)
    }
    
    func test_whenCreateAccountTapped_givenFieldsAreValid_thenCreateUser() async throws {
        
        let member = MemberProfileRegisterRequest(
            firstname: "TestName",
            lastname: "TestLastName",
            emailAddress: "test@test.com",
            referFriendCode: nil,
            mobileContactNumber: "07798696066",
            defaultBillingDetails: nil,
            savedAddresses: nil
        )
        
        let marketingPreferences = [
            UserMarketingOptionResponse(type: MarketingOptions.email.rawValue, text: "", opted: .in),
            UserMarketingOptionResponse(type: MarketingOptions.directMail.rawValue, text: "", opted: .in),
            UserMarketingOptionResponse(type: MarketingOptions.notification.rawValue, text: "", opted: .in),
            UserMarketingOptionResponse(type: MarketingOptions.sms.rawValue, text: "", opted: .in),
            UserMarketingOptionResponse(type: MarketingOptions.telephone.rawValue, text: "", opted: .in),
        ]
        let eventLogger = MockedEventLogger(expected: [.sendEvent(for: .completeRegistration, with: .appsFlyer, params: [AFEventCompleteRegistration:"precheckout"])])
        
        let container = DIContainer(appState: AppState(), eventLogger: eventLogger, services: .mocked(memberService: [.register(member: member, password: "password1", referralCode: "", marketingOptions: marketingPreferences)]))
        
        let sut = makeSUT(container: container)
        
        sut.firstName = "TestName"
        sut.lastName = "TestLastName"
        sut.email = "test@test.com"
        sut.phone = "07798696066"
        sut.password = "password1"
        sut.emailMarketingEnabled = true
        sut.directMailMarketingEnabled = true
        sut.notificationMarketingEnabled = true
        sut.smsMarketingEnabled = true
        sut.telephoneMarketingEnabled = true
        sut.termsAgreed = true

        try await sut.createAccountTapped()
                
        XCTAssertFalse(sut.isLoading)
        container.services.verify(as: .user)
        eventLogger.verify()
    }
    
    func test_whenCreateAccountTapped_givenFieldsAreEmpty_thenFieldsHaveErrors() async throws {
        let sut = makeSUT()
        
        try await sut.createAccountTapped()
        
        XCTAssertTrue(sut.firstNameHasError)
        XCTAssertTrue(sut.emailHasError)
        XCTAssertTrue(sut.lastNameHasError)
        XCTAssertTrue(sut.emailHasError)
        XCTAssertTrue(sut.phoneHasError)
        XCTAssertTrue(sut.passwordHasError)
    }
    
    func test_whenTermsAgreedTapped_thenTermsAgreedToggledAndTermsAndConditgionsHasErrorIsFalse() {
        let sut = makeSUT()
        
        sut.termsAgreedTapped()
        XCTAssertTrue(sut.termsAgreed)
        
        sut.termsAgreedTapped()
        XCTAssertFalse(sut.termsAgreed)
    }
    
    func makeSUT(container: DIContainer = DIContainer(appState: AppState(), eventLogger: MockedEventLogger(), services: .mocked())) -> CreateAccountViewModel {
        let sut = CreateAccountViewModel(container: container)
        
        return sut
    }
}
