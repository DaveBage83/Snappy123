//
//  ForgotPasswordViewModel.swift
//  SnappyV2
//
//  Created by Kevin Palser on 26/09/2022.
//

import Combine
import OSLog

@MainActor
final class ForgotPasswordViewModel: ObservableObject {
    @Published var email = ""
    @Published var emailHasError = false
    @Published var isLoading = false
        
    let container: DIContainer
    let dismissHandler: (String?) -> Void
    private var cancellables = Set<AnyCancellable>()
    
    init(container: DIContainer, dismissHandler: @escaping (String?) -> Void) {
        self.container = container
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
            container.appState.value.successToastStrings.append(Strings.ForgetPasswordCustom.confirmation.localizedFormat(email))
            dismissHandler(email)
        } catch {
            self.container.appState.value.errors.append(error)
            Logger.member.error("Failed to send password reset message with error: \(error.localizedDescription)")
        }
        
        isLoading = false
    }
    
    func onAppearSendEvent() {
        container.eventLogger.sendEvent(for: .viewScreen, with: .appsFlyer, params: ["screen_reference": "reset_password"])
    }
}
