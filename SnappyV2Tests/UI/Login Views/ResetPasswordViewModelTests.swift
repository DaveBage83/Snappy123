//
//  ResetPasswordViewModelTests.swift
//  SnappyV2Tests
//
//  Created by Kevin Palser on 28/09/2022.
//

import XCTest
import Combine
@testable import SnappyV2

@MainActor
final class ResetPasswordViewModelTests: XCTestCase {
    
    struct DismissHandlerCalled {
        let error: Error?
    }
    
    func test_init() {
        let sut = makeSUT()
        XCTAssertEqual(sut.newPassword, "", file: #file, line: #line)
        XCTAssertEqual(sut.confirmationPassword, "", file: #file, line: #line)
        XCTAssertFalse(sut.newPasswordHasError, file: #file, line: #line)
        XCTAssertFalse(sut.confirmationPasswordHasError, file: #file, line: #line)
        XCTAssertFalse(sut.isLoading, file: #file, line: #line)
        XCTAssertNil(sut.error, file: #file, line: #line)
        XCTAssertFalse(sut.isLoading, file: #file, line: #line)
    }
    
    func test_noMemberFound_givenAppsStateHasMember_changesToFalse() {
        let sut = makeSUT()
        XCTAssertTrue(sut.noMemberFound, file: #file, line: #line)
        sut.container.appState.value.userData.memberProfile = MemberProfile.mockedData
        XCTAssertFalse(sut.noMemberFound, file: #file, line: #line)
    }
    
    func test_confirmationPasswordDifferent_givenVariousScenarios() {
        let sut = makeSUT()
        // when both passwords are empty
        XCTAssertFalse(sut.confirmationPasswordDifferent, file: #file, line: #line)
        // when both passwords only have whitespaces
        sut.newPassword = " "
        sut.confirmationPassword = "   "
        XCTAssertFalse(sut.confirmationPasswordDifferent, file: #file, line: #line)
        // when one of the passwords is still empty
        sut.newPassword = "Test"
        XCTAssertFalse(sut.confirmationPasswordDifferent, file: #file, line: #line)
        // when both the passwords are not empty but are the same
        sut.confirmationPassword = "Test"
        XCTAssertFalse(sut.confirmationPasswordDifferent, file: #file, line: #line)
        // when the passwords are different
        sut.confirmationPassword = "different"
        XCTAssertTrue(sut.confirmationPasswordDifferent, file: #file, line: #line)
    }
    
    func test_setupPasswordFieldBindingsForHasErrors_givenEmptyNewPassword_thenNewPasswordHasErrorTrue() {
        let sut = makeSUT()
        sut.newPassword = "something"

        var cancellables = Set<AnyCancellable>()
        let expectation = expectation(description: #function)

        sut.$newPasswordHasError
            .receive(on: RunLoop.main)
            .sink { hasError in
                if hasError {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)

        sut.newPassword = ""

        wait(for: [expectation], timeout: 2)

        XCTAssertTrue(sut.newPasswordHasError)
    }
    
    func test_setupPasswordFieldBindingsForHasErrors_givenNewPasswordAndConfirmIsDifferent_thenConfirmationPasswordHasErrorTrue() {
        let sut = makeSUT()
        sut.confirmationPassword = "somethingelse"

        var cancellables = Set<AnyCancellable>()
        let expectation = expectation(description: #function)

        sut.$confirmationPasswordHasError
            .filter { $0 }
            .removeDuplicates()
            .receive(on: RunLoop.main)
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &cancellables)

        sut.newPassword = "different"

        wait(for: [expectation], timeout: 2)

        XCTAssertFalse(sut.newPasswordHasError)
        XCTAssertTrue(sut.confirmationPasswordHasError)
    }
    
    func test_setupPasswordFieldBindingsForHasErrors_givenEmptyConfirmationPassword_thenConfirmationPasswordHasErrorTrue() {
        let sut = makeSUT()
        sut.confirmationPassword = "something"

        var cancellables = Set<AnyCancellable>()
        let expectation = expectation(description: #function)

        sut.$confirmationPasswordHasError
            .receive(on: RunLoop.main)
            .sink { hasError in
                if hasError {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)

        sut.confirmationPassword = ""

        wait(for: [expectation], timeout: 2)

        XCTAssertTrue(sut.confirmationPasswordHasError)
    }
    
    func test_setupPasswordFieldBindingsForHasErrors_givenConfirmIsDifferent_thenConfirmationPasswordHasErrorTrue() {
        let sut = makeSUT()
        sut.newPassword = "different"
        
        var cancellables = Set<AnyCancellable>()
        let expectation = expectation(description: #function)

        sut.$confirmationPasswordHasError
            .filter { $0 }
            .removeDuplicates()
            .receive(on: RunLoop.main)
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &cancellables)

        sut.confirmationPassword = "somethingelse"

        wait(for: [expectation], timeout: 2)

        XCTAssertFalse(sut.newPasswordHasError)
        XCTAssertTrue(sut.confirmationPasswordHasError)
    }
    
    func test_whenSubmitTapped_givenEmailIsEmpty_thenEmailHasError() async {
        let sut = makeSUT()
        await sut.submitTapped()
        XCTAssertTrue(sut.newPasswordHasError, file: #file, line: #line)
        XCTAssertTrue(sut.confirmationPasswordHasError, file: #file, line: #line)
        XCTAssertEqual(sut.error as? ResetPasswordViewModel.ResetPasswordViewError, ResetPasswordViewModel.ResetPasswordViewError.passwordFieldErrors, file: #file, line: #line)
    }
    
    func test_whenSubmitTapped_thenIsLoadingIsTrue() async {
        let sut = makeSUT()

        var cancellables = Set<AnyCancellable>()
        var isLoadingWasTrue = false

        sut.$isLoading
            .receive(on: RunLoop.main)
            .sink { isLoading in
                if isLoading {
                    isLoadingWasTrue = true
                    //expectation.fulfill()
                }
            }
            .store(in: &cancellables)

        sut.newPassword = "Test"
        sut.confirmationPassword = "Test"

        await sut.submitTapped()

        XCTAssertTrue(isLoadingWasTrue, file: #file, line: #line)
    }
    
    func test_whenSubmitTapped_givenMemberSignedIn_thenIsLoadingIsNotTrue() async {
        
        var dismissHandlerCalled: DismissHandlerCalled?
        
        let sut = makeSUT() { error in
            dismissHandlerCalled = DismissHandlerCalled(error: error)
        }
        sut.container.appState.value.userData.memberProfile = MemberProfile.mockedData

        var cancellables = Set<AnyCancellable>()
        
        sut.$isLoading
            .filter { $0 }
            .receive(on: RunLoop.main)
            .sink { _ in
                XCTFail("Unexpected isLoading = true", file: #file, line: #line)
            }
            .store(in: &cancellables)

        sut.newPassword = "Test"
        sut.confirmationPassword = "Test"

        await sut.submitTapped()

        XCTAssertNil(dismissHandlerCalled, file: #file, line: #line)
        XCTAssertNil(sut.error, file: #file, line: #line)
        XCTAssertTrue(sut.dismiss, file: #file, line: #line)
    }
    
    func test_whenSubmitTapped_givenProblemWithPasswords_thenSetError() async {
        
        var dismissHandlerCalled: DismissHandlerCalled?
        
        let sut = makeSUT() { error in
            dismissHandlerCalled = DismissHandlerCalled(error: error)
        }

        var cancellables = Set<AnyCancellable>()
        
        sut.$isLoading
            .filter { $0 }
            .receive(on: RunLoop.main)
            .sink { _ in
                XCTFail("Unexpected isLoading = true", file: #file, line: #line)
            }
            .store(in: &cancellables)
        
        sut.newPassword = "Test"
        sut.confirmationPassword = "Different"

        await sut.submitTapped()

        XCTAssertNil(dismissHandlerCalled, file: #file, line: #line)
        XCTAssertEqual(sut.error as? ResetPasswordViewModel.ResetPasswordViewError, ResetPasswordViewModel.ResetPasswordViewError.passwordFieldErrors, file: #file, line: #line)
        XCTAssertFalse(sut.dismiss, file: #file, line: #line)
    }
    
    func test_whenOnAppearSendEvenTriggered_thenAppsFlyerEventCalled() {
        let eventLogger = MockedEventLogger(expected: [.sendEvent(for: .viewScreen, with: .appsFlyer, params: ["screen_reference": "reset_password"])])
        let container = DIContainer(appState: AppState(), eventLogger: eventLogger, services: .mocked())
        let sut = makeSUT(container: container)

        sut.onAppearSendEvent()

        eventLogger.verify()
    }
    
    func makeSUT(container: DIContainer = DIContainer(appState: AppState(), eventLogger: MockedEventLogger(), services: .mocked()), dismissHandler: @escaping (Error?) -> Void = { _ in }) -> ResetPasswordViewModel {
        let sut = ResetPasswordViewModel(container: container, resetToken: "p6rGf6KLBD", dismissHandler: dismissHandler)
        trackForMemoryLeaks(sut)
        return sut
    }
}
