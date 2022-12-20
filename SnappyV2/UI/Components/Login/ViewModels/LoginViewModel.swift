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
            return GeneralStrings.Login.appleSignInFail.localized
        }
    }
}

@MainActor
class LoginViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    
    // Used to trigger navigation view
    @Published var showCreateAccountView = false
    
    // Used to mask main login view when login is in progress
    @Published var isLoading = false

    @Published var showForgotPassword = false
    @Published var successMessage: String?
    
    private var cancellables = Set<AnyCancellable>()
    
    // Field errors
    @Published var emailHasError = false
    @Published var showInvalidEmailError = false
    @Published var passwordHasError = false
    
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
    
    // MARK: - Button tap methods
    
    func createAccountTapped() {
        showCreateAccountView = true
    }
    
    func showForgotPasswordTapped() {
        showForgotPassword = true
    }
    
    func forgotPasswordDismissed() {
        showForgotPassword = false
    }
    
    func loginTapped() async {
        self.passwordHasError = password.isEmpty
        self.emailHasError = email.isEmpty
        
        guard !emailHasError, !passwordHasError else { return }
        
        isLoading = true
        
        var loginError: Error?
        do {
            try await container.services.memberService.login(email: email, password: password, atCheckout: isInCheckout)
            Logger.member.log("Succesfully logged in")
        } catch {
            loginError = error
            Logger.member.error("Failed to log user in: \(error.localizedDescription)")
        }
        updateFinishedPublishedStates(error: loginError)
    }
    
    func onAppearSendEvent() {
        container.eventLogger.sendEvent(for: .viewScreen(isInCheckout ? .in : .outside, .accountSignIn), with: .appsFlyer, params: [:])
    }
    
    func onCreateAccountAppearSendEvent() {
        container.eventLogger.sendEvent(for: .viewScreen(isInCheckout ? .in : .outside, .registerFromAccountSignIn), with: .appsFlyer, params: [:])
    }
}
