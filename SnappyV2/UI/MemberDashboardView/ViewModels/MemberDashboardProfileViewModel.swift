//
//  MemberDashboardProfileViewModel.swift
//  SnappyV2
//
//  Created by David Bage on 25/03/2022.
//

import Foundation
import Combine
import OSLog

class MemberDashboardProfileViewModel: ObservableObject {
    
    // MARK: - View State
    
    enum ViewState {
        case updateProfile
        case changePassword
    }
    
    @Published var viewState: ViewState = .updateProfile
    
    private let container: DIContainer
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Binding field properties - update profile
    
    @Published var firstName = ""
    @Published var lastName = ""
    @Published var phoneNumber = ""
    
    // MARK: - Binding field properties - change password
    
    @Published var currentPassword = ""
    @Published var newPassword = ""
    @Published var verifyNewPassword = ""
    
    // We use the below 2 to ensure that we do not display field errors before the form is submitted
    @Published var updateSubmitted = false
    @Published var changePasswordSubmitted = false
    
    // To display progress view when changing password
    @Published var changePasswordLoading = false
    
    @Published var profile: MemberProfile?
    
    // MARK: - Computed error variables
    
    // Update profile fields
    var firstNameHasError: Bool {
        updateSubmitted && firstName.isEmpty
    }
    
    var lastNameHasError: Bool {
        updateSubmitted && lastName.isEmpty
    }

    var phoneNumberHasError: Bool {
        updateSubmitted && phoneNumber.isEmpty
    }
    
    private var canSubmitUpdateProfile: Bool {
        updateSubmitted && (!firstNameHasError && !lastNameHasError && !phoneNumberHasError)
    }
    
    // Update password fields
    
    var currentPasswordHasError: Bool {
        changePasswordSubmitted && currentPassword.isEmpty
    }
    
    var newPasswordHasError: Bool {
        changePasswordSubmitted && (newPassword.isEmpty || newPassword != verifyNewPassword )
    }
    
    var verifyNewPasswordHasError: Bool {
        changePasswordSubmitted && (verifyNewPassword.isEmpty || verifyNewPassword != newPassword )
    }
    
    private var canSubmitChangePasswordForm: Bool {
        !currentPasswordHasError && !newPasswordHasError && !verifyNewPasswordHasError
    }
    
    @Published var profileIsUpdating = false
    
    init(container: DIContainer) {
        self.container = container
        let appState = container.appState
        
        self._profile = .init(initialValue: appState.value.userData.memberProfile)
        setupBindToProfile(with: appState)
        setupProfile()
    }
    
    // MARK: - Methods
    
    private func setupProfile() {
        $profile
            .receive(on: RunLoop.main)
            .sink { [weak self] profile in
                guard let self = self, let profile = profile else { return }
                self.firstName = profile.firstname
                self.lastName = profile.lastname
                self.phoneNumber = profile.mobileContactNumber ?? ""
            }
            .store(in: &cancellables)
    }

    private func setupBindToProfile(with appState: Store<AppState>) {
        appState
            .map(\.userData.memberProfile)
            .receive(on: RunLoop.main)
            .sink { [weak self] profile in
                guard let self = self else { return }
                self.profile = profile
            }
            .store(in: &cancellables)
    }
    
    // Reset state when navigating away
    private func resetState() {
        currentPassword = ""
        newPassword = ""
        verifyNewPassword = ""
        changePasswordSubmitted = false
        viewState = .updateProfile
    }
    
    // Upadate profile
    private func updateMemberDetails() {
        if canSubmitUpdateProfile {
            container.services.userService.updateProfile(firstname: firstName, lastname: lastName, mobileContactNumber: phoneNumber)
                .sink { completion in
                    switch completion {
                    case .failure(let err):
                        Logger.member.error("Failed to update profile: \(err.localizedDescription)")
                        self.profileIsUpdating = false
                    case .finished:
                        Logger.member.log("Successfully updated user profile")
                    }
                } receiveValue: { _ in
                    self.profileIsUpdating = false
                }
                .store(in: &cancellables)
        }
    }
    
    // Change password
    private func changePassword() {
        if canSubmitChangePasswordForm {
            container.services.userService.resetPassword(resetToken: nil, logoutFromAll: false, email: nil, password: newPassword, currentPassword: currentPassword)
                .receive(on: RunLoop.main)
                .sink { completion in
                    switch completion {
                    case .failure(let err):
                        #warning("Add error toast once designs are ready")
                        Logger.member.error("Unable to change password: \(err.localizedDescription)")
                    case .finished:
                        #warning("Add some kind of success toast either here or on the previous view once designs ready")
                        self.resetState()
                    }
                    self.changePasswordLoading = false
                }
                .store(in: &cancellables)
        } else {
            changePasswordLoading = false
        }
    }
    
    // MARK: - Tap methods
    
    func updateProfileTapped() {
        updateSubmitted = true
        updateMemberDetails()
        profileIsUpdating = true
    }
    
    func changePasswordScreenRequested() {
        viewState = .changePassword
    }
    
    func changePasswordTapped() {
        changePasswordSubmitted = true
        changePasswordLoading = true
        changePassword()
    }

    func backToUpdateViewTapped() {
        resetState()
    }
}
