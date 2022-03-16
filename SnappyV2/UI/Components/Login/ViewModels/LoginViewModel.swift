//
//  LoginViewModel.swift
//  SnappyV2
//
//  Created by David Bage on 09/03/2022.
//

import Foundation
import Combine
import AuthenticationServices

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
    
    private func login() {
        container.services.userService.login(email: email, password: password)
            .receive(on: RunLoop.main)
            .sink { completion in
                switch completion {
                case .failure:
                    #warning("Add error handling")
                    self.isLoading = false
                case .finished:
                    self.isLoading = false
                }
            } receiveValue: { _ in }
            .store(in: &cancellables)
    }
    
    #warning("Needs to be tested manually")
    private func loginWithApple(auth: ASAuthorization) {
        container.services.userService.login(appleSignInAuthorisation: auth, registeringFromScreen: .accountTab)
            .sink { [weak self] completion in
                guard let self = self else { return }
                #warning("Add error handling")
                self.isLoading = false
                
            } receiveValue: { [weak self] _ in
                guard let self = self else { return }
                self.isLoading = false
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Button tap methods
    
    func loginTapped() {
        isLoading = true
        submitted = true
        login()
    }
    
    func createAccountTapped() {
        showCreateAccountView = true
    }

    func appleLoginTapped(auth: ASAuthorization) {
        isLoading = true
        loginWithApple(auth: auth)
    }
}
