//
//  LoginViewModel.swift
//  SnappyV2
//
//  Created by David Bage on 09/03/2022.
//

import Foundation
import Combine
import AuthenticationServices
import OSLog

enum LoginError: Swift.Error {
    case appleLoginFailure

}

extension LoginError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .appleLoginFailure:
            return "Unable to complete Apple sign in"
        }
    }
}

@MainActor
class LoginViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published var passwordRevealed = false // Used for show/hide password functionality
    @Published var showSettingsView = false
    
    // Used to trigger navigation view
    @Published var showCreateAccountView = false
    
    // Used to mask main login view when login is in progress
    @Published var isLoading = false

    @Published var showForgotPassword = false
    @Published var successMessage: String?
//    @Published var error: Error?
    
    private var cancellables = Set<AnyCancellable>()
       
    // We set to true once login is tapped once. This avoids field errors being shown when view is first loaded
    private var submitted = false
    
    // Field errors
    @Published var emailHasError = false
    @Published var showInvalidEmailError = false
    @Published var passwordHasError = false
    
    var orderTotal: Double? {
        container.appState.value.userData.basket?.orderTotal
    }
    
    let isInCheckout: Bool
    
    var isFromInitialView: Bool {
        container.appState.value.routing.showInitialView
    }

    let container: DIContainer
    
    init(container: DIContainer, isInCheckout: Bool = false) {
        self.container = container
        self.isInCheckout = isInCheckout
        setupEmailError()
        setupPasswordError()
    }
    
    // Realtime email validation
    private func setupEmailError() {
        $email
            .dropFirst()
            .receive(on: RunLoop.main)
            .sink { [weak self] email in
                guard let self = self else { return }
                self.showInvalidEmailError = !email.isEmail && !email.isEmpty
                self.emailHasError = email.isEmpty || !email.isEmail
            }
            .store(in: &cancellables)
    }
    
    private func setupPasswordError() {
        $password
            .dropFirst()
            .receive(on: RunLoop.main)
            .map { $0.isEmpty }
            .assignWeak(to: \.passwordHasError, on: self)
            .store(in: &cancellables)
    }
    // MARK: - Private helper methods
    
    func updateFinishedPublishedStates(error: Error?) {
        guaranteeMainThread { [weak self] in
            guard let self = self else { return }
            self.isLoading = false
            if let error = error {
                self.container.appState.value.errors.append(error)
            }
        }
    }
    
    // MARK: - Login methods
    
    #warning("Needs to be tested manually")

    func handleAppleLoginResult(result: Result<ASAuthorization, Error>) {
        switch result {
        case let .success(authResults):
            isLoading = true
            Task {
                var loginError: Error?
                do {
                    try await container.services.memberService.login(appleSignInAuthorisation: authResults, registeringFromScreen: .accountTab)
                    Logger.member.log("Succesfully logged in with Apple")
                } catch {
                    loginError = error
                    Logger.member.error("Failed to log user in with Apple: \(error.localizedDescription)")
                }
                updateFinishedPublishedStates(error: loginError)
            }
            
        case .failure:
            container.appState.value.errors.append(LoginError.appleLoginFailure)
            Logger.member.error("Unable to sign in with Apple")
        }
    }
    
    // MARK: - Button tap methods
    
    func createAccountTapped() {
        showCreateAccountView = true
    }
    
    func showForgotPasswordTapped() {
        showForgotPassword = true
    }
    
    func forgotPasswordDismissed(sendingEmail: String?) {
        showForgotPassword = false
        if let sendingEmail = sendingEmail {
            successMessage = Strings.ForgetPasswordCustom.confirmation.localizedFormat(sendingEmail)
        }
    }
    
    #warning("Needs to be tested manually")
    
    func loginTapped() async {
        self.passwordHasError = password.isEmpty
        self.emailHasError = email.isEmpty
        
        guard !emailHasError, !passwordHasError else { return }
        
        isLoading = true
        submitted = true
        
        var loginError: Error?
        do {
            try await container.services.memberService.login(email: email, password: password)
            Logger.member.log("Succesfully logged in")
        } catch {
            loginError = error
            Logger.member.error("Failed to log user in: \(error.localizedDescription)")
        }
        updateFinishedPublishedStates(error: loginError)
    }
    
    func googleSignInTapped() {
        isLoading = true
        Task {
            var loginError: Error?
            do {
                try await container.services.memberService.loginWithGoogle(registeringFromScreen: .accountTab)
                Logger.member.log("Succesfully logged in with Google")
            } catch {
                loginError = error
                Logger.member.error("Failed to log user in with Google: \(error.localizedDescription)")
            }
            updateFinishedPublishedStates(error: loginError)
        }
    }
    
    func onAppearSendEvent() {
        container.eventLogger.sendEvent(for: .viewScreen, with: .appsFlyer, params: ["screen_reference": "account_sign_in"])
    }
    
    func onCreateAccountAppearSendEvent() {
        container.eventLogger.sendEvent(for: .viewScreen, with: .appsFlyer, params: ["screen_reference": "register_from_account_sign_in"])
    }
}
