//
//  OTPPromptViewModelTests.swift
//  SnappyV2Tests
//
//  Created by Henrik Gustavii on 20/07/2022.
//

import XCTest
@testable import SnappyV2

@MainActor
class OTPPromptViewModelTests: XCTestCase {
    
    func test_init() {
        let sut = makeSUT()
        
        XCTAssertTrue(sut.email.isEmpty)
        XCTAssertTrue(sut.otpTelephone.isEmpty)
        XCTAssertFalse(sut.showLoginView)
        XCTAssertFalse(sut.showOTPTelephone)
        XCTAssertFalse(sut.isSendingOTPRequest)
        XCTAssertFalse(sut.showOTPCodePrompt)
        XCTAssertTrue(sut.otpCode.isEmpty)
        XCTAssertEqual(sut.otpType, .sms)
        XCTAssertTrue(sut.disableLogin)
        XCTAssertNil(sut.error)
        XCTAssertTrue(sut.optCodeSendDestination.isEmpty)
    }
    
    func test_givenInit_whenTriggeringLogin_thenShowLoginViewIsTrue() {
        let sut = makeSUT()
        
        XCTAssertFalse(sut.showLoginView)
        
        sut.login()
        
        XCTAssertTrue(sut.showLoginView)
    }
    
    
    func test_givenEmail_whenSendOTPTriggered_thenCorrectCallTriggered() async {
        let email = "someone@domain.com"
        
        let mockedEvent = MockedEventLogger(expected: [.sendEvent(for: .otpEmail, with: .appsFlyer, params: [:])])
        let container = DIContainer(appState: AppState(), eventLogger: mockedEvent, services: .mocked(memberService: [.requestMessageWithOneTimePassword(email: email, type: .email)]))
        let sut = makeSUT(container: container, email: email)
        
        await sut.sendOTP(via: .email)
        
        XCTAssertTrue(sut.showOTPCodePrompt)
        
        container.services.verify(as: .member)
        mockedEvent.verify()
    }
    
    func test_givenTelephone_whenSendOTPTriggered_thenCorrectCallTriggered() async {
        let email = "someone@domain.com"
        let telephone = "0987654321"
        let mockedEvent = MockedEventLogger(expected: [.sendEvent(for: .otpSms, with: .appsFlyer, params: [:])])
        let container = DIContainer(appState: AppState(), eventLogger: mockedEvent, services: .mocked(memberService: [.requestMessageWithOneTimePassword(email: email, type: .sms)]))
        let sut = makeSUT(container: container, email: email, otpTelephone: telephone)
        
        XCTAssertTrue(sut.showOTPTelephone)
        
        await sut.sendOTP(via: .sms)
        
        XCTAssertTrue(sut.showOTPCodePrompt)
        
        container.services.verify(as: .member)
        mockedEvent.verify()
    }
    
    func test_whenDismissOTPPromptTriggered_thenDimissActionCalled() {
        var dismissTriggered = false
        
        func triggerDismiss() { dismissTriggered = true }
        
        let sut = makeSUT(dismiss: { triggerDismiss() })
        
        sut.dismissOTPPrompt()
        
        XCTAssertTrue(dismissTriggered)
    }
    
    func test_givenOtpCode_thenDisableLoginIsFalse() {
        let sut = makeSUT()
        
        sut.otpCode = "SOMECODE"
        
        XCTAssertFalse(sut.disableLogin)
    }
    
    func test_whenOtpTypeIsMobile_thenOptSendDestinationIsTelephone() {
        let email = "someone@domain.com"
        let telephone = "0987654321"
        let sut = makeSUT()
        
        sut.otpTelephone = telephone
        sut.email = email
        
        XCTAssertEqual(sut.optCodeSendDestination, telephone)
    }
    
    func test_whenOtpTypeIsEmail_thenOptSendDestinationIsEmail() {
        let email = "someone@domain.com"
        let telephone = "0987654321"
        let sut = makeSUT()
        
        sut.otpTelephone = telephone
        sut.email = email
        sut.otpType = .email
        
        XCTAssertEqual(sut.optCodeSendDestination, email)
    }
    
    func test_givenCorrectCode_whenLoginWithOtpTriggered_thenDismissOtpPrompt() async {
        var dismissTriggered = false
        let email = "someone@domain.com"
        let otpCode = "SOMECODE"
        
        func triggerDismiss() { dismissTriggered = true }
        
        let mockedEvent = MockedEventLogger(expected: [.sendEvent(for: .otpLogin, with: .appsFlyer, params: [:])])
        let container = DIContainer(appState: AppState(), eventLogger: mockedEvent, services: .mocked(memberService: [.login(email: email, oneTimePassword: otpCode)]))
        
        let sut = makeSUT(container: container, dismiss: { triggerDismiss() })
        sut.email = email
        sut.otpCode = otpCode
        
        await sut.loginWithOTP()
        
        XCTAssertTrue(dismissTriggered)
        
        container.services.verify(as: .member)
        mockedEvent.verify()
    }
    
    func test_givenCorrectCodeAndProfile_whenLoginWithOtpTriggered_thenDismissOtpPromptAndCorrectEvent() async {
        var dismissTriggered = false
        let email = "someone@domain.com"
        let otpCode = "SOMECODE"
        
        func triggerDismiss() { dismissTriggered = true }
        let profile = MemberProfile.mockedData
        let mockedEvent = MockedEventLogger(expected: [.sendEvent(for: .otpLogin, with: .appsFlyer, params: ["member_id":profile.uuid])])
        let container = DIContainer(appState: AppState(), eventLogger: mockedEvent, services: .mocked(memberService: [.login(email: email, oneTimePassword: otpCode)]))
        container.appState.value.userData.memberProfile = profile
        
        let sut = makeSUT(container: container, dismiss: { triggerDismiss() })
        sut.email = email
        sut.otpCode = otpCode
        
        await sut.loginWithOTP()
        
        XCTAssertTrue(dismissTriggered)
        
        container.services.verify(as: .member)
        mockedEvent.verify()
    }
    
    func makeSUT(container: DIContainer = DIContainer(appState: AppState(), eventLogger: MockedEventLogger(), services: .mocked()), email: String = "", otpTelephone: String = "", dismiss: @escaping ()->() = {}) -> OTPPromptViewModel {
        let sut = OTPPromptViewModel(container: container, email: email, otpTelephone: otpTelephone, dismiss: dismiss)
        
        trackForMemoryLeaks(sut)
        
        return sut
    }
}
