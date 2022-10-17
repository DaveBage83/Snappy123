//
//  SocialMediaLoginViewModel.swift
//  SnappyV2
//
//  Created by David Bage on 26/05/2022.
//

import SwiftUI
import AuthenticationServices
import OSLog

@MainActor
class SocialMediaLoginViewModel: ObservableObject {
    let container: DIContainer
    let isInCheckout: Bool
    
    @Published var isLoading = false
    @Published var error: Error?
    
    private var registeringFromScreen: RegisteringFromScreenType {
        if container.appState.value.routing.showInitialView {
            return .startScreen
        }
        return isInCheckout ? .billingCheckout : .accountTab
    }
        
    init(container: DIContainer, isInCheckout: Bool) {
        self.container = container
        self.isInCheckout = isInCheckout
    }
    
    func updateFinishedPublishedStates(error: Error?) {
        self.isLoading = false
        if let error = error {
            self.container.appState.value.errors.append(error)
        }
    }
    
    #warning("These need to be tested manually")
    
    func googleSignInTapped() {
        isLoading = true
        Task {
            var loginError: Error?
            do {
                try await container.services.memberService.loginWithGoogle(registeringFromScreen: registeringFromScreen)
                Logger.member.log("Succesfully logged in with Google")
            } catch {
                loginError = error
                Logger.member.error("Failed to log user in with Google: \(error.localizedDescription)")
            }
            updateFinishedPublishedStates(error: loginError)
        }
    }
    
    func loginWithFacebook() async {
        isLoading = true
        do {
            try await container.services.memberService.loginWithFacebook(registeringFromScreen: registeringFromScreen)
            self.isLoading = false
        } catch {
            self.container.appState.value.errors.append(error)
            Logger.member.error("Failed to log in with Facebook: \(error.localizedDescription)")
            self.isLoading = false
        }
    }
    
    func handleAppleLoginResult(result: Result<ASAuthorization, Error>) {
        switch result {
        case let .success(authResults):
            isLoading = true
            Task {
                var loginError: Error?
                do {
                    try await container.services.memberService.login(appleSignInAuthorisation: authResults, registeringFromScreen: registeringFromScreen)
                    Logger.member.log("Succesfully logged in with Apple")
                } catch {
                    loginError = error
                    Logger.member.error("Failed to log user in with Apple: \(error.localizedDescription)")
                }
                updateFinishedPublishedStates(error: loginError)
            }
            
        case .failure:
            self.error = error
            if let error = error {
                self.container.appState.value.errors.append(error)
            }
            Logger.member.error("Unable to sign in with Apple")
        }
    }
}
