//
//  ForgotPasswordViewModel.swift
//  SnappyV2
//
//  Created by Kevin Palser on 26/09/2022.
//

import OSLog

@MainActor
final class ForgotPasswordViewModel: ObservableObject {
    @Published var email = ""
    @Published var emailHasError = false
    @Published var isLoading = false
        
    let container: DIContainer
    let isInCheckout: Bool
    let dismissHandler: (String?) -> Void
    
    init(container: DIContainer, isInCheckout: Bool, dismissHandler: @escaping (String?) -> Void) {
        self.container = container
        self.isInCheckout = isInCheckout
        self.dismissHandler = dismissHandler
    }
    
    func submitTapped() async {
        emailHasError = email.isEmpty
        
        guard emailHasError == false else {
            return
        }
                
        isLoading = true
        
        do {
            try await self.container.services.memberService.resetPasswordRequest(email: email)
            Logger.member.log("Email sent to reset password")
            let successToast = SuccessToast(subtitle: Strings.ForgetPasswordCustom.confirmation.localizedFormat(email))
            dismissHandler(email)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { // Allow view to dismiss before firing success toast
                self.container.appState.value.successToasts.append(successToast)
            }

        } catch {
            self.container.appState.value.errors.append(error)
            Logger.member.error("Failed to send password reset message with error: \(error.localizedDescription)")
        }
        
        isLoading = false
    }
    
    func onAppearSendEvent() {
        container.eventLogger.sendEvent(for: .viewScreen(isInCheckout ? .in : .outside, .resetPassword), with: .appsFlyer, params: [:])
        container.eventLogger.sendEvent(for: .viewScreen(isInCheckout ? .in : .outside, .resetPassword), with: .firebaseAnalytics, params: [:])
    }
}
