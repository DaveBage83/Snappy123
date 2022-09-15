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

@MainActor
class LoginViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published var passwordRevealed = false // Used for show/hide password functionality
    
    // Used to trigger navigation view
    @Published var showCreateAccountView = false
    
    // Used to mask main login view when login is in progress
    @Published var isLoading = false
    
    @Published private(set) var error: Error?
       
    // We set to true once login is tapped once. This avoids field errors being shown when view is first loaded
    private var submitted = false
    
    // Field errors
    var emailHasError: Bool {
        submitted && email.isEmpty
    }
    
    var passwordHasError: Bool {
        submitted && password.isEmpty
    }
    
    var orderTotal: Double? {
        container.appState.value.userData.basket?.orderTotal
    }

    private var cancellables = Set<AnyCancellable>()
    
    let isInCheckout: Bool
    
    let container: DIContainer
    
    init(container: DIContainer, isInCheckout: Bool = false) {
        self.container = container
        self.isInCheckout = isInCheckout
    }
    
    // MARK: - Private helper methods
    
    func updateFinishedPublishedStates(error: Error?) {
        guaranteeMainThread { [weak self] in
            guard let self = self else { return }
            self.isLoading = false
            if let error = error {
                self.error = error
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
            self.error = error
            Logger.member.error("Unable to sign in with Apple")
        }
    }
    
    // MARK: - Button tap methods
    
    func createAccountTapped() {
        showCreateAccountView = true
    }
    
    #warning("Needs to be tested manually")
    
    func loginTapped() async {
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
