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
    
    let container: DIContainer
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Binding field properties - update profile
    
    @Published var firstName = ""
    @Published var lastName = ""
    @Published var phoneNumber = ""
    
    // MARK: - Binding field properties - change password
    
    @Published var currentPassword = ""
    @Published var newPassword = ""
    @Published var verifyNewPassword = ""
    
    // To display progress view when changing password
    @Published var changePasswordLoading = false
    
    @Published var profile: MemberProfile?
    
    @Published var resetPasswordError: Swift.Error?
    
    // MARK: - Computed error variables
    
    // Update profile fields
    @Published var firstNameHasError = false
    @Published var lastNameHasError = false
    @Published var phoneHasError = false
    
    @Published var showPasswordResetView = false
    
    // Update password field errors
    
    @Published var currentPasswordHasError = false
    @Published var newPasswordHasError = false
    @Published var verifyNewPasswordHasError = false
    @Published var profileIsUpdating = false
    
    init(container: DIContainer) {
        self.container = container
        let appState = container.appState
        
        self._profile = .init(initialValue: appState.value.userData.memberProfile)
        setupBindToProfile(with: appState)
        setupProfile()
        setupFirstNameHasError()
        setupLastNameHasError()
        setupPhoneNumberHasError()
        setupCurrentPasswordHasError()
        setupNewPasswordHasError()
        setupVerifyPasswordHasError()
    }
    
    // MARK: - Methods
    
    private func setupFirstNameHasError() {
        $firstName
            .dropFirst()
            .receive(on: RunLoop.main)
            .sink { [weak self] value in
                guard let self = self else { return }
                self.firstNameHasError = value.isEmpty
            }
            .store(in: &cancellables)
    }
    
    private func setupLastNameHasError() {
        $lastName
            .dropFirst()
            .receive(on: RunLoop.main)
            .sink { [weak self] value in
                guard let self = self else { return }
                self.lastNameHasError = value.isEmpty
            }
            .store(in: &cancellables)
    }
    
    private func setupPhoneNumberHasError() {
        $phoneNumber
            .dropFirst()
            .receive(on: RunLoop.main)
            .sink { [weak self] value in
                guard let self = self else { return }
                self.phoneHasError = value.isEmpty
            }
            .store(in: &cancellables)
    }
    
    private func setupCurrentPasswordHasError() {
        $currentPassword
            .dropFirst()
            .receive(on: RunLoop.main)
            .sink { [weak self] value in
                guard let self = self else { return }
                self.currentPasswordHasError = value.isEmpty
            }
            .store(in: &cancellables)
    }
    
    private func setupNewPasswordHasError() {
        $newPassword
            .dropFirst()
            .receive(on: RunLoop.main)
            .sink { [weak self] value in
                guard let self = self else { return }
                self.newPasswordHasError = value.isEmpty
            }
            .store(in: &cancellables)
    }
    
    private func setupVerifyPasswordHasError() {
        $verifyNewPassword
            .dropFirst()
            .receive(on: RunLoop.main)
            .sink { [weak self] value in
                guard let self = self else { return }
                self.verifyNewPasswordHasError = value.isEmpty
            }
            .store(in: &cancellables)
    }
    
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
    
    private func fieldsHaveErrors() -> Bool {
        firstNameHasError = firstName.isEmpty
        lastNameHasError = lastName.isEmpty
        phoneHasError = phoneNumber.isEmpty
        
        return (firstNameHasError || lastNameHasError || phoneHasError)
    }
    
    // Upadate profile
    func updateMemberDetails(didSetError: (Swift.Error) -> (), didSucceed: (String) -> ()) async {
        guard fieldsHaveErrors() == false else {
            didSetError(FormError.missingDetails)
            return
        }
        
        profileIsUpdating = true
        
        do {
            try await container.services.memberService.updateProfile(firstname: firstName, lastname: lastName, mobileContactNumber: phoneNumber)
            profileIsUpdating = false
            didSucceed(Strings.MemberDashboard.Profile.successfullyUpdated.localized)
            Logger.member.log("Successfully updated user profile")
        } catch {
            didSetError(error)
            profileIsUpdating = false
            Logger.member.error("Failed to update profile: \(error.localizedDescription)")
        }
    }
    
    private func passwordFieldsHaveErrors() -> Bool {
        currentPasswordHasError = currentPassword.isEmpty
        newPasswordHasError = newPassword.isEmpty
        verifyNewPasswordHasError = verifyNewPassword.isEmpty
        
        return (currentPasswordHasError || newPasswordHasError || verifyNewPasswordHasError)
    }
    
    // Change password
    func changePassword(didResetPassword: (String) -> ()) async {
        guard passwordFieldsHaveErrors() == false else {
            resetPasswordError = FormError.missingDetails
            return
        }
        
        guard newPassword == verifyNewPassword else {
            resetPasswordError = FormError.passwordsDoNotMatch
            newPasswordHasError = true
            verifyNewPasswordHasError = true
            return
        }
        
        self.changePasswordLoading = true
        
        do {
            try await container.services.memberService.resetPassword(resetToken: nil, logoutFromAll: false, email: nil, password: newPassword, currentPassword: currentPassword)
            self.changePasswordLoading = false
            didResetPassword(Strings.MemberDashboard.Profile.successfullyResetPassword.localized)
            self.showPasswordResetView = false
        } catch {
            Logger.member.error("Unable to change password: \(error.localizedDescription)")
            self.changePasswordLoading = false
            self.resetPasswordError = error
        }
    }
    
    // MARK: - Tap methods
    
    func changePasswordScreenRequested() {
        showPasswordResetView = true
    }
    
    func dismissPasswordResetView() {
        showPasswordResetView = false
    }
    
    func onAppearSendEvent() {
        container.eventLogger.sendEvent(for: .viewScreen, with: .appsFlyer, params: ["screen_reference": "edit_member_profile"])
    }
}
