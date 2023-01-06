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
    
    // Forget member fields
    
    @Published var showInitialForgetMemberAlert = false
    @Published var showEnterForgetMemberCodeAlert = false
    @Published var forgetMemberCode: String = ""
    @Published var enterForgetCodeTitle = ""
    @Published var enterForgetCodePrompt = ""
    @Published var forgetMemberRequestLoading = false
    var forgetMeSubmitButtonDisabled: Bool {
        forgetMemberCode.isEmpty
    }
    
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
    
    func changePassword(didResetPassword: (String) -> ()) async {
        guard passwordFieldsHaveErrors() == false else {
            self.container.appState.value.errors.append(FormError.missingDetails)
            return
        }
        
        guard newPassword == verifyNewPassword else {
            self.container.appState.value.errors.append(FormError.passwordsDoNotMatch)
            newPasswordHasError = true
            verifyNewPasswordHasError = true
            return
        }
        
        self.changePasswordLoading = true
        
        do {
            try await container.services.memberService.changePassword(logoutFromAll: false, password: newPassword, currentPassword: currentPassword)
            self.changePasswordLoading = false
            didResetPassword(Strings.MemberDashboard.Profile.successfullyResetPassword.localized)
            self.showPasswordResetView = false
        } catch {
            Logger.member.error("Unable to change password: \(error.localizedDescription)")
            self.changePasswordLoading = false
            self.container.appState.value.errors.append(error)
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
        container.eventLogger.sendEvent(for: .viewScreen(.outside, .editMemberProfile), with: .appsFlyer, params: [:])
    }
    
    func filterPhoneNumber(newValue: String) {
        let filtered = newValue.filter { "0123456789+".contains($0) }
        if filtered != newValue {
            self.phoneNumber = filtered
        }
    }
    
//    func forgetMeTapped() {
//        showInitialForgetMemberAlert = true
//    }
//    
//    func continueToForgetMeTapped() async throws {
//        forgetMemberRequestLoading = true
//        
//        do {
//            let sendForgetCodeRequest = try await container.services.memberService.sendForgetCode()
//            enterForgetCodeTitle = sendForgetCodeRequest.message_title ?? Strings.ForgetMe.defaultTitle.localized
//            enterForgetCodePrompt = sendForgetCodeRequest.message ?? Strings.ForgetMe.defaultPrompt.localized
//            showEnterForgetMemberCodeAlert = true
//        } catch {
//            container.appState.value.errors.append(error)
//        }
//        
//        forgetMemberRequestLoading = false
//    }
    
    func forgetMemberRequested() async throws {
        do {
            let _ = try await container.services.memberService.forgetMember(confirmationCode: forgetMemberCode)
        } catch {
            container.appState.value.errors.append(error)
        }
        forgetMemberCode = ""
    }
}
