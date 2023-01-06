//
//  MemberDashboardProfileViewModelTests.swift
//  SnappyV2Tests
//
//  Created by David Bage on 28/03/2022.
//

import XCTest
import SwiftUI
@testable import SnappyV2
import Combine

@MainActor
class MemberDashboardProfileViewModelTests: XCTestCase {
    
    func test_init() {
        let sut = makeSUT()
        
        XCTAssertEqual(sut.firstName, "")
        XCTAssertEqual(sut.lastName, "")
        XCTAssertEqual(sut.phoneNumber, "")
        XCTAssertEqual(sut.currentPassword, "")
        XCTAssertEqual(sut.newPassword, "")
        XCTAssertEqual(sut.verifyNewPassword, "")
        XCTAssertFalse(sut.changePasswordLoading)
        XCTAssertFalse(sut.firstNameHasError)
        XCTAssertFalse(sut.lastNameHasError)
        XCTAssertFalse(sut.phoneHasError)
        XCTAssertFalse(sut.phoneHasError)
        XCTAssertFalse(sut.currentPasswordHasError)
        XCTAssertFalse(sut.newPasswordHasError)
        XCTAssertFalse(sut.verifyNewPasswordHasError)
    }
    
    func test_whenAppStateHasMembeProfilePresent_thenMemberProfileUpdatedInViewModel() {
        let sut = makeSUT(profile: MemberProfile.mockedData)
        let cancelbag = CancelBag()
        let expectation = expectation(description: "setupUserDetails")
        
        sut.$profile
            .first()
            .receive(on: RunLoop.main)
            .sink { profile in
                XCTAssertEqual(sut.firstName, "Harold")
                XCTAssertEqual(sut.lastName, "Brown")
                XCTAssertEqual(sut.phoneNumber, "0792334112")
                expectation.fulfill()
            }
            .store(in: cancelbag)
        wait(for: [expectation], timeout: 0.2)
    }
    
    func test_whenUpdateProfileTapped_thenProfileDetailsUpdated() async {
        let container = DIContainer(appState: AppState(), eventLogger: MockedEventLogger(), services: .mocked(memberService: [.updateProfile(firstname: "Alan1", lastname: "Shearer2", mobileContactNumber: "222222")]))
                                    
        let sut = makeSUT(container: container)
        
        let expectation = expectation(description: "updateProfile")
        var cancellables = Set<AnyCancellable>()
        
        sut.$profile
            .first()
            .receive(on: RunLoop.main)
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &cancellables)

        sut.firstName = "Alan1"
        sut.lastName = "Shearer2"
        sut.phoneNumber = "222222"
        
        await sut.updateMemberDetails(didSetError: { _ in }, didSucceed: { _ in })
        
        wait(for: [expectation], timeout: 5)
        
        container.services.verify(as: .member)
    }
    
    func test_whenChangePasswordTappedAndVerifyPasswordMatches_thenPasswordChanged() async throws {
        let container = DIContainer(appState: AppState(), eventLogger: MockedEventLogger(), services: .mocked(memberService: [.changePassword(logoutFromAll: false, password: "password2", currentPassword: "password1")]))

        let sut = makeSUT(container: container)
        
        sut.currentPassword = "password1"
        sut.newPassword = "password2"
        sut.verifyNewPassword = "password2"

        var successMessage = ""
        
        await sut.changePassword(didResetPassword: { message in
            successMessage = message
        })
                
        XCTAssertEqual(successMessage, Strings.MemberDashboard.Profile.successfullyResetPassword.localized)
        
        container.services.verify(as: .member)
    }
    
    func test_whenChangePasswordTapped_thenShowChangePasswordViewIsTrue() {
        let sut = makeSUT()
        
        sut.changePasswordScreenRequested()
        XCTAssertTrue(sut.showPasswordResetView)
    }

    func test_whenOnAppearSendEvenTriggered_thenAppsFlyerEventCalled() {
        let eventLogger = MockedEventLogger(expected: [.sendEvent(for: .viewScreen(.outside, .editMemberProfile), with: .appsFlyer, params: [:])])
        let container = DIContainer(appState: AppState(), eventLogger: eventLogger, services: .mocked())
        let sut = makeSUT(container: container)
        
        sut.onAppearSendEvent()
        
        eventLogger.verify()
    }
    
    func test_whenFirstnameIsEmpty_givenFirstInit_thenFirstNameHasErrorIsFalse() {
        let sut = makeSUT()
        XCTAssertFalse(sut.firstNameHasError)
    }
    
    func test_whenLastnameIsEmpty_givenFirstInit_thenLastNameHasErrorIsFalse() {
        let sut = makeSUT()
        XCTAssertFalse(sut.lastNameHasError)
    }
    
    func test_whenTelephoneIsEmpty_givenFirstInit_thenPhoneHasErrorIsFalse() {
        let sut = makeSUT()
        XCTAssertFalse(sut.phoneHasError)
    }
    
    func test_whenFirstnameIsEmpty_givenNotFirstInit_thenFirstNameHasErrorIsTrue() {
        let sut = makeSUT()
        sut.firstName = "test"
        sut.firstName = ""
        
        let expectation = expectation(description: "firstnameHasErrorTrue")
        var cancellables = Set<AnyCancellable>()
        
        sut.$firstName
            .first()
            .receive(on: RunLoop.main)
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 2)
        
        XCTAssertTrue(sut.firstNameHasError)
    }
    
    func test_whenLastnameIsEmpty_givenNotFirstInit_thenLastNameHasErrorIsTrue() {
        let sut = makeSUT()
        sut.lastName = "test"
        sut.lastName = ""
        
        let expectation = expectation(description: "lastNameHasErrorTrue")
        var cancellables = Set<AnyCancellable>()
        
        sut.$lastName
            .first()
            .receive(on: RunLoop.main)
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 2)
        
        XCTAssertTrue(sut.lastNameHasError)
    }
    
    func test_whenTelephoneIsEmpty_givenNotFirstInit_thenPhoneHasErrorIsTrue() {
        let sut = makeSUT()
        sut.phoneNumber = "test"
        sut.phoneNumber = ""
        
        let expectation = expectation(description: "phoneHasErrorTrue")
        var cancellables = Set<AnyCancellable>()
        
        sut.$phoneNumber
            .first()
            .receive(on: RunLoop.main)
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 2)
        
        XCTAssertTrue(sut.phoneHasError)
    }
    
    func test_whenCurrentPasswordIsEmpty_givenFirstInit_thenCurrentPasswordErrorIsFalse() {
        let sut = makeSUT()
        XCTAssertFalse(sut.currentPasswordHasError)
    }
    
    func test_whenNewPasswordIsEmpty_givenFirstInit_thenNewPasswordHasErrorIsFalse() {
        let sut = makeSUT()
        XCTAssertFalse(sut.newPasswordHasError)
    }
    
    func test_whenVerifyPasswordIsEmpty_givenFirstInit_thenVerifyPasswordHasErrorIsFalse() {
        let sut = makeSUT()
        XCTAssertFalse(sut.verifyNewPasswordHasError)
    }
    
    func test_whenCurrentPasswordIsEmpty_givenNotFirstInit_thenCurrentPasswordHasErrorIsTrue() {
        let sut = makeSUT()
        sut.currentPassword = "test"
        sut.currentPassword = ""
        
        let expectation = expectation(description: "currentPasswordHasError")
        var cancellables = Set<AnyCancellable>()
        
        sut.$currentPassword
            .first()
            .receive(on: RunLoop.main)
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 2)
        
        XCTAssertTrue(sut.currentPasswordHasError)
    }
    
    func test_whenNewPasswordIsEmpty_givenNotFirstInit_thenNewPasswordHasErrorIsTrue() {
        let sut = makeSUT()
        sut.newPassword = "test"
        sut.newPassword = ""
        
        let expectation = expectation(description: "newPasswordHasError")
        var cancellables = Set<AnyCancellable>()
        
        sut.$newPassword
            .first()
            .receive(on: RunLoop.main)
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 2)
        
        XCTAssertTrue(sut.newPasswordHasError)
    }
    
    func test_whenVerifyPasswordIsEmpty_givenNotFirstInit_thenVerifyPasswordHasErrorIsTrue() {
        let sut = makeSUT()
        sut.verifyNewPassword = "test"
        sut.verifyNewPassword = ""
        
        let expectation = expectation(description: "verifyPasswordHasError")
        var cancellables = Set<AnyCancellable>()
        
        sut.$newPassword
            .first()
            .receive(on: RunLoop.main)
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 2)
        
        XCTAssertTrue(sut.verifyNewPasswordHasError)
    }
    
    func test_whenUpdateMemberDetailsCalled_givenDetailsAreMissing_thenTriggerDidSetError() async {
        let sut = makeSUT()
        
        var successMessage = ""
        var errorText = ""
        
        await sut.updateMemberDetails(didSetError: { error in
            errorText = (error as? FormError)?.localizedDescription ?? "" // Should hit this error
        }, didSucceed: { success in
            successMessage = "Success" // Should not reach here
        })
        
        XCTAssertEqual(errorText, FormError.missingDetails.localizedDescription)
        XCTAssertEqual(successMessage, "")
    }
    
    func test_whenChangePasswordCalled_givenErrorsExist_thenPopulateError() async {
        let sut = makeSUT()
        
        var successMessage = ""
        
        await sut.changePassword(didResetPassword: { message in
            successMessage = "Success!" // Should not reach here
        })
        
        XCTAssertEqual(sut.container.appState.value.errors.first as? FormError, FormError.missingDetails)
        XCTAssertEqual(successMessage, "")
    }
    
    func test_whenChangedPasswordCalled_givenPasswordsDoNotMatch_thenTriggerError() async {
        let sut = makeSUT()
        
        var successMessage = ""
        
        sut.currentPassword = "password1"
        sut.newPassword = "password2"
        sut.verifyNewPassword = "password3"
        
        await sut.changePassword(didResetPassword: { message in
            successMessage = "Success!" // Should not reach here
        })
        
        XCTAssertEqual(sut.container.appState.value.errors.first as? FormError, FormError.passwordsDoNotMatch)
        XCTAssertTrue(sut.newPasswordHasError)
        XCTAssertTrue(sut.verifyNewPasswordHasError)
        XCTAssertEqual(successMessage, "")
    }
    
    func test_whenDismissPasswordResetViewCalled_thenShowPasswordResetViewSetToFalse() {
        let sut = makeSUT()
        sut.showPasswordResetView = true
        sut.dismissPasswordResetView()
        XCTAssertFalse(sut.showPasswordResetView)
    }
    
    func test_whenForgetMeTapped_thenShowEnterForgetMemberCodeAlertTrueAndTitleAndPromptValuesPopulated() async {
        let sut = makeSUT()
        
        do {
            try await sut.continueToForgetMeTapped()
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
        
        XCTAssertFalse(sut.forgetMemberRequestLoading)
        XCTAssertEqual(sut.enterForgetCodeTitle, Strings.ForgetMe.defaultTitle.localized)
        XCTAssertEqual(sut.enterForgetCodePrompt, Strings.ForgetMe.defaultPrompt.localized)
        XCTAssertTrue(sut.showEnterForgetMemberCodeAlert)
    }
    
    func makeSUT(container: DIContainer = DIContainer(appState: AppState(), eventLogger: MockedEventLogger(), services: .mocked()), profile: MemberProfile? = nil) -> MemberDashboardProfileViewModel {
        
        if let profile = profile {
            container.appState.value.userData.memberProfile = profile
        }
        
        let sut = MemberDashboardProfileViewModel(container: container)
        trackForMemoryLeaks(sut)
        return sut
    }
}
