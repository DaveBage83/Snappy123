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

class LoginViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published var passwordRevealed = false // Used for show/hide password functionality
    
    // Used to trigger navigation view
    @Published var showCreateAccountView = false
    
    // Used to mask main login view when login is in progress
    @Published var isLoading = false
       
    // We set to true once login is tapped once. This avoids field errors being shown when view is first loaded
    private var submitted = false
    
    // Field errors
    var emailHasError: Bool {
        submitted && email.isEmpty
    }
    
    var passwordHasError: Bool {
        submitted && password.isEmpty
    }

    private var cancellables = Set<AnyCancellable>()
    
    let container: DIContainer
    
    init(container: DIContainer) {
        self.container = container
    }
    
    // MARK: - Login methods
    
    #warning("Needs to be tested manually")
    private func loginWithApple(auth: ASAuthorization) async throws {
        do {
            try await container.services.userService.login(appleSignInAuthorisation: auth, registeringFromScreen: .accountTab)
            Logger.member.log("Succesfully logged in to Apple")
            self.isLoading = false
        } catch {
            self.isLoading = false
            throw error
        }
    }
    
    func handleAppleLoginResult(result: Result<ASAuthorization, Error>) {
        switch result {
        case let .success(authResults):
            appleLoginTapped(auth: authResults)
            
        case .failure:
            #warning("Error handling required")
            Logger.member.error("Unable to sign in with Apple")
        }
    }
    
    // MARK: - Button tap methods
    
    func loginTapped() {
        isLoading = true
        submitted = true
        Task {
            do {
                try await container.services.userService.login(email: email, password: password)
                isLoading = false
            } catch {
                #warning("Toast to be added")
                Logger.member.error("Failed to log user in: \(error.localizedDescription)")
                guaranteeMainThread { [weak self] in
                    guard let self = self else { return }
                    self.isLoading = false
                }
            }
        }
    }
    
    func createAccountTapped() {
        showCreateAccountView = true
    }
    
    func appleLoginTapped(auth: ASAuthorization) {
        isLoading = true
        
        Task {
            try await loginWithApple(auth: auth)
        }
    }
}