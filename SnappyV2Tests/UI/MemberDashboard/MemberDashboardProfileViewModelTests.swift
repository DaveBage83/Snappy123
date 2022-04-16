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

class MemberDashboardProfileViewModelTests: XCTestCase {
    
    func test_init() {
        let sut = makeSUT()
        
        XCTAssertEqual(sut.viewState, .updateProfile)
        XCTAssertEqual(sut.firstName, "")
        XCTAssertEqual(sut.lastName, "")
        XCTAssertEqual(sut.phoneNumber, "")
        XCTAssertEqual(sut.currentPassword, "")
        XCTAssertEqual(sut.newPassword, "")
        XCTAssertEqual(sut.verifyNewPassword, "")
        XCTAssertFalse(sut.updateSubmitted)
        XCTAssertFalse(sut.changePasswordSubmitted)
        XCTAssertFalse(sut.changePasswordLoading)
        XCTAssertFalse(sut.firstNameHasError)
        XCTAssertFalse(sut.lastNameHasError)
        XCTAssertFalse(sut.phoneNumberHasError)
        XCTAssertFalse(sut.phoneNumberHasError)
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
    
    func test_whenUpdateProfileTapped_thenProfileDetailsUpdated() {
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
        
        sut.updateProfileTapped()
        
        wait(for: [expectation], timeout: 5)
        
        container.services.verify(as: .user)
    }
    
    func test_whenChangePasswordTappedAndVerifyPasswordMatches_thenPasswordChanged() {
        let container = DIContainer(appState: AppState(), eventLogger: MockedEventLogger(), services: .mocked(memberService: [.resetPassword(resetToken: nil, logoutFromAll: false, email: nil, password: "password2", currentPassword: "password1")]))
                                    
        let sut = makeSUT(container: container)
        
        let expectation = expectation(description: "resetProfile")
        var cancellables = Set<AnyCancellable>()
        
        sut.$profile
            .first()
            .receive(on: RunLoop.main)
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        sut.currentPassword = "password1"
        sut.newPassword = "password2"
        sut.verifyNewPassword = "password2"
        
        sut.changePasswordTapped()
        
        wait(for: [expectation], timeout: 5)
        
        container.services.verify(as: .user)
    }
    
    func test_whenChangePasswordScreenRequested_thenViewStateChangedToChangePassword() {
        let sut = makeSUT()
        
        sut.changePasswordScreenRequested()
        XCTAssertEqual(sut.viewState, .changePassword)
    }
    
    func test_whenBackToUpdateViewTapped_thenAllValuesReset() {
        let sut = makeSUT()
        
        sut.currentPassword = "password1"
        sut.newPassword = "password2"
        sut.verifyNewPassword = "password3"
        sut.viewState = .changePassword
        sut.changePasswordSubmitted = true
        
        sut.backToUpdateViewTapped()
        
        XCTAssertEqual(sut.currentPassword, "")
        XCTAssertEqual(sut.newPassword, "")
        XCTAssertEqual(sut.verifyNewPassword, "")
        XCTAssertEqual(sut.viewState, .updateProfile)
        XCTAssertFalse(sut.changePasswordSubmitted)
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
