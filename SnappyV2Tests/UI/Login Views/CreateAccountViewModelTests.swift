//
//  CreateAccountViewModelTests.swift
//  SnappyV2Tests
//
//  Created by David Bage on 16/03/2022.
//

import XCTest
import Combine
@testable import SnappyV2

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
    }
    
    func test_whenCreateAccountTapped_givenFieldsAreValid_thenCreateUser() {
        let member = MemberProfile(
            firstname: "TestName",
            lastname: "TestLastName",
            emailAddress: "test@test.com",
            type: .customer,
            referFriendCode: "",
            referFriendBalance: 5.0,
            numberOfReferrals: 0,
            mobileContactNumber: "07798696066",
            mobileValidated: true,
            acceptedMarketing: true,
            defaultBillingDetails: nil,
            savedAddresses: nil,
            fetchTimestamp: nil)
        
        let marketingPreferences = [
            UserMarketingOptionResponse(type: MarketingOptions.email.rawValue, text: "", opted: .in),
            UserMarketingOptionResponse(type: MarketingOptions.directMail.rawValue, text: "", opted: .in),
            UserMarketingOptionResponse(type: MarketingOptions.notification.rawValue, text: "", opted: .in),
            UserMarketingOptionResponse(type: MarketingOptions.sms.rawValue, text: "", opted: .in),
            UserMarketingOptionResponse(type: MarketingOptions.telephone.rawValue, text: "", opted: .in),
        ]
        
        let container = DIContainer(appState: AppState(), services: .mocked(memberService: [.register(member: member, password: "password1", referralCode: "", marketingOptions: marketingPreferences)]))
        
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
        
        let expectation = expectation(description: "createUser")
        var cancellables = Set<AnyCancellable>()
        
        sut.$isLoading
            .first()
            .receive(on: RunLoop.main)
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        sut.createAccountTapped()
        
        wait(for: [expectation], timeout: 5)
        
        XCTAssertFalse(sut.isLoading)
        sut.container.services.verify()
    }
    
    func test_whenCreateAccountTapped_givenFieldsAreEmpty_thenFieldsHaveErrors() {
        let sut = makeSUT()
        
        sut.createAccountTapped()
        
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
    
    func makeSUT(container: DIContainer = DIContainer(appState: AppState(), services: .mocked())) -> CreateAccountViewModel {
        let sut = CreateAccountViewModel(container: container)
        
        return sut
    }
}
