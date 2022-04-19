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
    enum LoginViewModelError: Swift.Error {
        case failedToLogin

        var errorDescription: String? {
            switch self {
            case .failedToLogin:
                return GeneralStrings.Login.loginFailure.localized
            }
        }
    }
    
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
    private func loginWithApple(auth: ASAuthorization) {
        container.services.userService.login(appleSignInAuthorisation: auth, registeringFromScreen: .accountTab)
            .sink { [weak self] completion in
                guard let self = self else { return }
                #warning("Add UI error handling")
                
                switch completion {
                case .finished:
                    Logger.member.log("Succesfully logged in to Apple")
                case .failure:
                    Logger.member.error("Failed to log in to Apple")
                }
                self.isLoading = false
                
            } receiveValue: { [weak self] _ in
                guard let self = self else { return }
                self.isLoading = false
            }
            .store(in: &cancellables)
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
                try await container.services.userService.login(email: email, password: password).singleOutput()
            } catch {
                throw LoginViewModelError.failedToLogin
            }
            isLoading = false
        }
    }
    
    func createAccountTapped() {
        showCreateAccountView = true
    }

    func appleLoginTapped(auth: ASAuthorization) {
        isLoading = true
        loginWithApple(auth: auth)
    }
}
