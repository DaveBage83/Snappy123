//
//  ForgotPasswordViewModelTests.swift
//  SnappyV2Tests
//
//  Created by David Bage on 16/03/2022.
//

import XCTest
import Combine
@testable import SnappyV2

@MainActor
final class ForgotPasswordViewModelTests: XCTestCase {
    func test_init() {
        let sut = makeSUT()
        
        XCTAssertFalse(sut.emailHasError)
        XCTAssertFalse(sut.isLoading)
        XCTAssertEqual(sut.email, "")
        XCTAssertNil(sut.error)
    }
    
    func test_whenSubmitTapped_givenEmailIsEmpty_thenEmailHasError() async {
        let sut = makeSUT()
        
        await sut.submitTapped()
        XCTAssertTrue(sut.emailHasError)
    }
    
    func test_whenSubmitTapped_thenIsLoadingIsTrue() async {
        let sut = makeSUT()
        
        var cancellables = Set<AnyCancellable>()
        let expectation = expectation(description: #function)
        var isLoadingWasTrue = false
        
        sut.$isLoading
            .receive(on: RunLoop.main)
            .sink { isLoading in
                if isLoading {
                    isLoadingWasTrue = true
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        sut.email = "test@test.com"
        
        await sut.submitTapped()
        
        wait(for: [expectation], timeout: 2)
        
        XCTAssertTrue(isLoadingWasTrue)
    }
    
    func test_whenSubmitTapped_givenThatEmailIsPresent_thenResetPasswordEmailSent() async {
        let container = DIContainer(appState: AppState(), eventLogger: MockedEventLogger(), services: .mocked(memberService: [.resetPasswordRequest(email: "test@test.com")]))
        
        var dismissHandlerCalled = false
        let sut = makeSUT(container: container) { string in
            dismissHandlerCalled = true
        }
        
        sut.email = "test@test.com"
        
        await sut.submitTapped()

        XCTAssertFalse(sut.isLoading)
        XCTAssertTrue(dismissHandlerCalled)
        container.services.verify(as: .member)
    }
    
    func test_whenOnAppearSendEvenTriggered_thenAppsFlyerEventCalled() {
        let eventLogger = MockedEventLogger(expected: [.sendEvent(for: .viewScreen, with: .appsFlyer, params: ["screen_reference": "reset_password"])])
        let container = DIContainer(appState: AppState(), eventLogger: eventLogger, services: .mocked())
        let sut = makeSUT(container: container)
        
        sut.onAppearSendEvent()
        
        eventLogger.verify()
    }
    
    func makeSUT(container: DIContainer = DIContainer(appState: AppState(), eventLogger: MockedEventLogger(), services: .mocked()), dismissHandler: @escaping (String?) -> Void = { _ in }) -> ForgotPasswordViewModel {
        let sut = ForgotPasswordViewModel(container: container, dismissHandler: dismissHandler)
        
        return sut
    }
}
