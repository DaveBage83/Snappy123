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
        XCTAssertEqual(sut.profileFetch, .notRequested)
        XCTAssertFalse(sut.firstNameHasError)
        XCTAssertFalse(sut.lastNameHasError)
        XCTAssertFalse(sut.phoneNumberHasError)
        XCTAssertFalse(sut.phoneNumberHasError)
        XCTAssertFalse(sut.currentPasswordHasError)
        XCTAssertFalse(sut.newPasswordHasError)
        XCTAssertFalse(sut.verifyNewPasswordHasError)
    }
    
    func test_whenProfileFetched_thenProfileSuccessfullyRetrievedAndFieldsComplete() {
        let container = DIContainer(appState: AppState(), services: .mocked(memberService: [.getProfile(filterDeliveryAddresses: false)]))
                                    
        let sut = makeSUT(container: container)
        
        let expectation = expectation(description: "getProfile")
        var cancellables = Set<AnyCancellable>()
        
        sut.$profileFetch
            .first()
            .receive(on: RunLoop.main)
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        let member = MemberProfile(
            firstname: "Alan",
            lastname: "Shearer",
            emailAddress: "alan.shearer@nufc.com",
            type: .customer,
            referFriendCode: "TESTCODE",
            referFriendBalance: 5.0,
            numberOfReferrals: 0,
            mobileContactNumber: "122334444",
            mobileValidated: false,
            acceptedMarketing: false,
            defaultBillingDetails: nil,
            savedAddresses: nil,
            fetchTimestamp: nil)
        
        sut.profileFetch = .loaded(member)
        
        wait(for: [expectation], timeout: 5)
        
        XCTAssertEqual(sut.firstName, "Alan")
        XCTAssertEqual(sut.lastName, "Shearer")
        XCTAssertEqual(sut.phoneNumber, "122334444")
        
        container.services.verify()
    }
    
    func test_whenUpdateProfileTapped_thenProfileDetailsUpdated() {
        let container = DIContainer(appState: AppState(), services: .mocked(memberService: [.getProfile(filterDeliveryAddresses: false), .updateProfile(firstname: "Alan1", lastname: "Shearer2", mobileContactNumber: "222222")]))
                                    
        let sut = makeSUT(container: container)
        
        let expectation = expectation(description: "updateProfile")
        var cancellables = Set<AnyCancellable>()
        
        sut.$profileFetch
            .first()
            .receive(on: RunLoop.main)
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        let member = MemberProfile(
            firstname: "Alan",
            lastname: "Shearer",
            emailAddress: "alan.shearer@nufc.com",
            type: .customer,
            referFriendCode: "TESTCODE",
            referFriendBalance: 5.0,
            numberOfReferrals: 0,
            mobileContactNumber: "122334444",
            mobileValidated: false,
            acceptedMarketing: false,
            defaultBillingDetails: nil,
            savedAddresses: nil,
            fetchTimestamp: nil)
        
        sut.profileFetch = .loaded(member)
        sut.firstName = "Alan1"
        sut.lastName = "Shearer2"
        sut.phoneNumber = "222222"
        
        sut.updateProfileTapped()
        
        wait(for: [expectation], timeout: 5)
        
        container.services.verify()
        XCTAssertFalse(sut.profileIsLoading)
    }
    
    func test_whenChangePasswordTappedAndVerifyPasswordMatches_thenPasswordChanged() {
        let container = DIContainer(appState: AppState(), services: .mocked(memberService: [.getProfile(filterDeliveryAddresses: false), .resetPassword(resetToken: nil, logoutFromAll: false, email: nil, password: "password2", currentPassword: "password1")]))
                                    
        let sut = makeSUT(container: container)
        
        let expectation = expectation(description: "resetProfile")
        var cancellables = Set<AnyCancellable>()
        
        sut.$profileFetch
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
        
        container.services.verify()
    }
    
    func test_whenChangePasswordTappedAndVerifyPasswordDoesNotMatch_thenPasswordChangedIsNotTriggered() {
        
        // For this test, we remove the reset password expectation as this should not trigger due to verify password not matching
        let container = DIContainer(appState: AppState(), services: .mocked(memberService: [.getProfile(filterDeliveryAddresses: false)]))
                                    
        let sut = makeSUT(container: container)
        
        let expectation = expectation(description: "resetProfile")
        var cancellables = Set<AnyCancellable>()
        
        sut.$profileFetch
            .first()
            .receive(on: RunLoop.main)
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        sut.currentPassword = "password1"
        sut.newPassword = "password2"
        sut.verifyNewPassword = "password3"
        
        sut.changePasswordTapped()
        
        wait(for: [expectation], timeout: 5)
        
        container.services.verify()
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
    
    func makeSUT(container: DIContainer = DIContainer(appState: AppState(), services: .mocked())) -> MemberDashboardProfileViewModel {
        let sut = MemberDashboardProfileViewModel(container: container)
        trackForMemoryLeaks(sut)
        return sut
    }
}
