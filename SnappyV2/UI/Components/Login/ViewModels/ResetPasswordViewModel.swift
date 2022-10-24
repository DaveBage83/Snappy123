//
//  ResetPasswordViewModel.swift
//  SnappyV2
//
//  Created by Kevin Palser on 26/09/2022.
//

import Combine
import OSLog

@MainActor
class ResetPasswordViewModel: ObservableObject {
    
    typealias ResetPasswordStrings = Strings.ResetPassword
    
    enum ResetPasswordViewError: LocalizedError {
        case passwordFieldErrors
        
        var errorDescription: String? {
            switch self {
            case .passwordFieldErrors:
                return ResetPasswordStrings.passwordFieldErrors.localized
            }
        }
    }
        
    @Published var newPassword = ""
    @Published var confirmationPassword = ""
    @Published private(set) var newPasswordHasError = false
    @Published private(set) var confirmationPasswordHasError = false
    @Published var isLoading = false
    @Published var dismiss = false
        
    let container: DIContainer
    let isInCheckout: Bool
    private let resetToken: String
    private let dismissHandler: (Error) -> Void
    private var cancellables = Set<AnyCancellable>()
    
    var noMemberFound: Bool {
        return container.appState.value.userData.memberProfile == nil
    }
    
    var confirmationPasswordDifferent: Bool {
        let trimmedConfirmationPassword = confirmationPassword.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedPassword = newPassword.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmedConfirmationPassword.isEmpty == false && trimmedPassword.isEmpty == false && trimmedConfirmationPassword != trimmedPassword
    }
    
    init(container: DIContainer, isInCheckout: Bool, resetToken: String, dismissHandler: @escaping (Error) -> Void) {
        self.container = container
        self.isInCheckout = isInCheckout
        self.resetToken = resetToken
        self.dismissHandler = dismissHandler
        
        // clear the app state because this view is now handling the token
        container.appState.value.passwordResetCode = nil
        
       if noMemberFound {
           setupPasswordFieldBindingsForHasErrors()
        }
    }
    
    private func setupPasswordFieldBindingsForHasErrors() {
        $newPassword
            .removeDuplicates()
            .dropFirst()
            .receive(on: RunLoop.main)
            .sink { [weak self] newValue in
                guard let self = self else { return }
                let trimmedPassword = newValue.trimmingCharacters(in: .whitespacesAndNewlines)
                self.newPasswordHasError = trimmedPassword.isEmpty
                if self.confirmationPasswordDifferent {
                    self.confirmationPasswordHasError = true
                }
            }.store(in: &cancellables)
        
        $confirmationPassword
            .removeDuplicates()
            .dropFirst()
            .receive(on: RunLoop.main)
            .sink { [weak self] newValue in
                guard let self = self else { return }
                let trimmedConfirmationPassword = newValue.trimmingCharacters(in: .whitespacesAndNewlines)
                // if there is something to compare in the new password field
                self.confirmationPasswordHasError = trimmedConfirmationPassword.isEmpty || self.confirmationPasswordDifferent
            }.store(in: &cancellables)
    }
    
    func submitTapped() async {
        
        guard noMemberFound else {
            dismiss = true
            return
        }
        
        // remove any leading or trailing spaces in the password field
        newPassword = newPassword.trimmingCharacters(in: .whitespacesAndNewlines)
        confirmationPassword = confirmationPassword.trimmingCharacters(in: .whitespacesAndNewlines)

        newPasswordHasError = newPassword.isEmpty
        confirmationPasswordHasError = confirmationPassword.isEmpty || confirmationPasswordDifferent
        
        guard newPasswordHasError == false && confirmationPasswordHasError == false else {
            self.container.appState.value.errors.append(ResetPasswordViewError.passwordFieldErrors)
            return
        }
        
        isLoading = true
        
        do {
            try await self.container.services.memberService.resetPassword(
                resetToken: self.resetToken,
                logoutFromAll: false,
                email: nil,
                password: newPassword,
                currentPassword: nil,
                atCheckout: isInCheckout
            )
            Logger.member.log("Reset password")
            dismiss = true
        } catch {
            switch error {
            case UserServiceError.unableToLoginAfterResetingPassword:
                // close the reset password view but show the failed to login error
                Logger.member.error("Failed to login after resetting password with error: \(error.localizedDescription)")
                dismiss = true
                dismissHandler(error)
            default:
                Logger.member.error("Failed to reset password with error: \(error.localizedDescription)")
                self.container.appState.value.errors.append(error)
            }
        }
        
        self.isLoading = false
    }
}
