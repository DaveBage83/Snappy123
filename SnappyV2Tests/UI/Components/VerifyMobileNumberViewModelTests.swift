//
//  VerifyMobileNumberViewModelTests.swift
//  SnappyV2Tests
//
//  Created by Kevin Palser on 23/09/2022.
//

import XCTest
import Combine
@testable import SnappyV2

@MainActor
final class VerifyMobileNumberViewModelTests: XCTestCase {
    
    typealias VerifyMobileNumberStrings = Strings.VerifyMobileNumber
    
    func test_init() {
        let sut = makeSUT()
        XCTAssertFalse(sut.isRequestingOrSendingVerificationCode, file: #file, line: #line)
        XCTAssertEqual(sut.verifyCode, "", file: #file, line: #line)
        XCTAssertTrue(sut.submitDisabled, file: #file, line: #line)
        XCTAssertNil(sut.toastMessage, file: #file, line: #line)
    }
    
    func test_instructions_whenCouponWithVerificationRequired() {
        let member = MemberProfile.mockedData
        let mobileContactNumber = member.mobileContactNumber ?? ""
        
        var appState: AppState = AppState()
        appState.userData.basket = Basket.mockedDataVerifiedMemberRegisteredRequiredCoupon
        appState.userData.memberProfile = member

        let sut = makeSUT(appState: appState)
        XCTAssertEqual(sut.instructions, VerifyMobileNumberStrings.EnterCodeViewDynamicText.instructionsWhenCoupon.localizedFormat(mobileContactNumber), file: #file, line: #line)
    }
    
    func test_instructions_whenNoCouponWithVerificationRequired() {
        let member = MemberProfile.mockedData
        let mobileContactNumber = member.mobileContactNumber ?? ""
        
        var appState: AppState = AppState()
        appState.userData.basket = Basket.mockedDataMemberRegisteredRequiredCoupon
        appState.userData.memberProfile = member

        let sut = makeSUT(appState: appState)
        XCTAssertEqual(sut.instructions, VerifyMobileNumberStrings.EnterCodeViewDynamicText.instructions.localizedFormat(mobileContactNumber), file: #file, line: #line)
    }
    
    func test_filteredVerifyCode() {
        let sut = makeSUT()
        sut.filteredVerifyCode(newValue: " #&ZbAR45 ")
        XCTAssertEqual(sut.verifyCode, "BA45", file: #file, line: #line)
    }
    
    func test_setupBindingsToVerifyCode_whenSufficientCharacters_thenSubmitDisabledFalse() {
        
        let characters = "0123456789ABCDEF"
        let sut = makeSUT()
        
        let testCodeMeetMinimumLength = String((0..<(sut.minimumVerifyCodeCharacters)).map{ _ in characters.randomElement()! })
        
        var cancellables = Set<AnyCancellable>()
        let expectation = expectation(description: #function)

        sut.$submitDisabled
            .receive(on: RunLoop.main)
            .sink { disabled in
                if disabled == false {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)

        sut.verifyCode = testCodeMeetMinimumLength

        wait(for: [expectation], timeout: 2.0)
        
        XCTAssertFalse(sut.submitDisabled, file: #file, line: #line)
    }
    
    func test_setupBindingsToVerifyCode_whenInsufficientCharacters_thenSubmitDisabledTrue() {
        
        let characters = "0123456789ABCDEF"
        let sut = makeSUT()
        
        let testCodeMeetMinimumLength = String((0..<(sut.minimumVerifyCodeCharacters)).map{ _ in characters.randomElement()! })
        let testCodeTooShort = String((0..<(sut.minimumVerifyCodeCharacters - 1)).map{ _ in characters.randomElement()! })
        
        var cancellables = Set<AnyCancellable>()
        let expectation = expectation(description: #function)

        var wasFalse = false
        
        sut.$submitDisabled
            .receive(on: RunLoop.main)
            .sink { disabled in
                if disabled == false {
                    wasFalse = true
                } else if wasFalse {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)

        // test by first toggling to true
        sut.verifyCode = testCodeMeetMinimumLength
        sut.verifyCode = testCodeTooShort

        wait(for: [expectation], timeout: 2.0)
        
        XCTAssertTrue(sut.submitDisabled, file: #file, line: #line)
    }

    func test_resendCodeTapped_whenResponseTellsViewToDisplaySuccessToast() async {
        
        var memberService = MockedUserService(expected: [.requestMobileVerificationCode])
        memberService.requestMobileVerificationCodeResponse = .success(true)
        
        var dismissViewHandlerResult: (Error?, String?)?
        let sut = makeSUT(memberService: memberService) { error, string in
            dismissViewHandlerResult = (error, string)
        }
    
        var cancellables = Set<AnyCancellable>()
        
        var isRequestingOrSendingVerificationCodeWasTrue = false
    
        sut.$isRequestingOrSendingVerificationCode
            .receive(on: RunLoop.main)
            .sink { isRequestingOrSendingVerificationCode in
                if isRequestingOrSendingVerificationCode {
                    isRequestingOrSendingVerificationCodeWasTrue = true
                }
            }
            .store(in: &cancellables)
        
        await sut.resendCodeTapped()
        
        XCTAssertTrue(isRequestingOrSendingVerificationCodeWasTrue, file: #file, line: #line)
        XCTAssertFalse(sut.isRequestingOrSendingVerificationCode, file: #file, line: #line)
        XCTAssertEqual(sut.toastMessage, VerifyMobileNumberStrings.EnterCodeViewStaticText.resendMessage.localized, file: #file, line: #line)
        XCTAssertNil(sut.container.appState.value.latestError, file: #file, line: #line)
        XCTAssertNil(dismissViewHandlerResult, file: #file, line: #line)
        memberService.verify()
    }
    
    func test_resendCodeTapped_whenResponseTellsViewToClose() async {
        
        var memberService = MockedUserService(expected: [.requestMobileVerificationCode])
        memberService.requestMobileVerificationCodeResponse = .success(false)
        
        var dismissViewHandlerResult: (Error?, String?)?
        let sut = makeSUT(memberService: memberService) { error, string in
            dismissViewHandlerResult = (error, string)
        }
    
        var cancellables = Set<AnyCancellable>()
        
        var isRequestingOrSendingVerificationCodeWasTrue = false
    
        sut.$isRequestingOrSendingVerificationCode
            .receive(on: RunLoop.main)
            .sink { isRequestingOrSendingVerificationCode in
                if isRequestingOrSendingVerificationCode {
                    isRequestingOrSendingVerificationCodeWasTrue = true
                }
            }
            .store(in: &cancellables)
        
        await sut.resendCodeTapped()
        
        XCTAssertTrue(isRequestingOrSendingVerificationCodeWasTrue, file: #file, line: #line)
        XCTAssertNil(sut.toastMessage, file: #file, line: #line)
        XCTAssertNil(sut.container.appState.value.latestError, file: #file, line: #line)
        XCTAssertNotNil(dismissViewHandlerResult, file: #file, line: #line)
        if let dismissViewHandlerResult = dismissViewHandlerResult {
            XCTAssertNil(dismissViewHandlerResult.0, file: #file, line: #line)
            XCTAssertNil(dismissViewHandlerResult.1, file: #file, line: #line)
        }
        memberService.verify()
    }
    
    func test_resendCodeTapped_whenError() async {
        
        let networkError = NSError(domain: NSURLErrorDomain, code: -1009, userInfo: [:])
        
        var memberService = MockedUserService(expected: [.requestMobileVerificationCode])
        memberService.requestMobileVerificationCodeResponse = .failure(networkError)
        
        var dismissViewHandlerResult: (Error?, String?)?
        let sut = makeSUT(memberService: memberService) { error, string in
            dismissViewHandlerResult = (error, string)
        }
    
        var cancellables = Set<AnyCancellable>()
        
        var isRequestingOrSendingVerificationCodeWasTrue = false
    
        sut.$isRequestingOrSendingVerificationCode
            .receive(on: RunLoop.main)
            .sink { isRequestingOrSendingVerificationCode in
                if isRequestingOrSendingVerificationCode {
                    isRequestingOrSendingVerificationCodeWasTrue = true
                }
            }
            .store(in: &cancellables)
        
        await sut.resendCodeTapped()
        
        XCTAssertTrue(isRequestingOrSendingVerificationCodeWasTrue, file: #file, line: #line)
        XCTAssertFalse(sut.isRequestingOrSendingVerificationCode, file: #file, line: #line)
        XCTAssertNil(sut.toastMessage, file: #file, line: #line)
        XCTAssertNil(dismissViewHandlerResult, file: #file, line: #line)
        XCTAssertEqual(sut.container.appState.value.latestError as? NSError, networkError, file: #file, line: #line)
        memberService.verify()
    }
    
    func test_submitCodeTapped_whenNoError_dismissViewAndSetToast() async {
        
        let code = "A01234"
        
        var memberService = MockedUserService(expected: [.checkMobileVerificationCode(verificationCode: code)])
        memberService.checkMobileVerificationCodeResponse = .success(true)
        
        var dismissViewHandlerResult: (Error?, String?)?
        let sut = makeSUT(memberService: memberService) { error, string in
            dismissViewHandlerResult = (error, string)
        }
    
        var cancellables = Set<AnyCancellable>()
        
        var isRequestingOrSendingVerificationCodeWasTrue = false
    
        sut.$isRequestingOrSendingVerificationCode
            .receive(on: RunLoop.main)
            .sink { isRequestingOrSendingVerificationCode in
                if isRequestingOrSendingVerificationCode {
                    isRequestingOrSendingVerificationCodeWasTrue = true
                }
            }
            .store(in: &cancellables)
        
        sut.verifyCode = code
        await sut.submitCodeTapped()
        
        XCTAssertTrue(isRequestingOrSendingVerificationCodeWasTrue, file: #file, line: #line)
        XCTAssertNil(sut.toastMessage, file: #file, line: #line)
        XCTAssertNil(sut.container.appState.value.latestError, file: #file, line: #line)
        XCTAssertNotNil(dismissViewHandlerResult, file: #file, line: #line)
        if let dismissViewHandlerResult = dismissViewHandlerResult {
            XCTAssertNil(dismissViewHandlerResult.0, file: #file, line: #line)
            XCTAssertEqual(dismissViewHandlerResult.1, VerifyMobileNumberStrings.EnterCodeViewStaticText.verifiedMessage.localized, file: #file, line: #line)
        }
        memberService.verify()
    }
    
    func test_submitCodeTapped_whenError() async {
        
        let code = "A01234"
        let networkError = NSError(domain: NSURLErrorDomain, code: -1009, userInfo: [:])
        
        var memberService = MockedUserService(expected: [.checkMobileVerificationCode(verificationCode: code)])
        memberService.checkMobileVerificationCodeResponse = .failure(networkError)
        
        var dismissViewHandlerResult: (Error?, String?)?
        let sut = makeSUT(memberService: memberService) { error, string in
            dismissViewHandlerResult = (error, string)
        }
    
        var cancellables = Set<AnyCancellable>()
        
        var isRequestingOrSendingVerificationCodeWasTrue = false
    
        sut.$isRequestingOrSendingVerificationCode
            .receive(on: RunLoop.main)
            .sink { isRequestingOrSendingVerificationCode in
                if isRequestingOrSendingVerificationCode {
                    isRequestingOrSendingVerificationCodeWasTrue = true
                }
            }
            .store(in: &cancellables)
        
        sut.verifyCode = code
        await sut.submitCodeTapped()
        
        XCTAssertTrue(isRequestingOrSendingVerificationCodeWasTrue, file: #file, line: #line)
        XCTAssertFalse(sut.isRequestingOrSendingVerificationCode, file: #file, line: #line)
        XCTAssertNil(sut.toastMessage, file: #file, line: #line)
        XCTAssertNil(dismissViewHandlerResult, file: #file, line: #line)
        XCTAssertEqual(sut.container.appState.value.latestError as? NSError, networkError, file: #file, line: #line)
        memberService.verify()
    }
    
    func test_cancelTapped() {
        var dismissViewHandlerResult: (Error?, String?)?
        let sut = makeSUT() { error, string in
            dismissViewHandlerResult = (error, string)
        }
        
        sut.cancelTapped()
        
        XCTAssertNotNil(dismissViewHandlerResult, file: #file, line: #line)
        if let dismissViewHandlerResult = dismissViewHandlerResult {
            XCTAssertNil(dismissViewHandlerResult.0, file: #file, line: #line)
            XCTAssertNil(dismissViewHandlerResult.1, file: #file, line: #line)
        }
    }
    
    func makeSUT(
        appState: AppState = AppState(),
        memberService: MockedUserService = MockedUserService(expected: []),
        dismissViewHandler: @escaping (Error?, String?) -> () = { _, _ in }
    ) -> VerifyMobileNumberViewModel {

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
            userPermissionsService: MockedUserPermissionsService(expected: []),
            searchHistoryService: MockedSearchHistoryService(expected: [])
        )

        let sut = VerifyMobileNumberViewModel(
            container: DIContainer(appState: appState, eventLogger: MockedEventLogger(), services: services),
            dismissViewHandler: dismissViewHandler
        )
        trackForMemoryLeaks(sut)
        return sut
    }

}

