//
//  MemberDashboardProfileViewModel.swift
//  SnappyV2
//
//  Created by David Bage on 25/03/2022.
//

import Foundation
import Combine
import OSLog

@MainActor
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
    
    @Published private(set) var error: Error?
    
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
    private func updateMemberDetails() async {
        if canSubmitUpdateProfile {
            do {
                try await container.services.userService.updateProfile(firstname: firstName, lastname: lastName, mobileContactNumber: phoneNumber)
                Logger.member.log("Successfully updated user profile")
            } catch {
                #warning("Add alert toast to inform user of failure here")
                Logger.member.error("Failed to update profile: \(error.localizedDescription)")
            }
            self.profileIsUpdating = false
        }
    }
    
    // Change password
    private func changePassword() async throws {
        if canSubmitChangePasswordForm {
            do {
                try await container.services.userService.resetPassword(resetToken: nil, logoutFromAll: false, email: nil, password: newPassword, currentPassword: currentPassword)
                self.resetState()
                self.changePasswordLoading = false
            } catch {
                Logger.member.error("Unable to change password: \(error.localizedDescription)")
                self.changePasswordLoading = false
                throw error
            }
        }
    }
    
    // MARK: - Tap methods
    
    func updateProfileTapped() async {
        self.updateSubmitted = true
        await self.updateMemberDetails()
        self.profileIsUpdating = true
    }
    
    func changePasswordScreenRequested() {
        viewState = .changePassword
    }
    
    func changePasswordTapped() async {
        
        self.changePasswordSubmitted = true
        self.changePasswordLoading = true
        
        do {
            try await self.changePassword()
        } catch {
            self.error = error
        }
    }
    
    func backToUpdateViewTapped() {
        resetState()
    }
    
    func onAppearSendEvent() {
        container.eventLogger.sendEvent(for: .viewScreen, with: .appsFlyer, params: ["screen_reference": "edit_member_profile"])
    }
}
