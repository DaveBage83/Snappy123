//
//  ForgotPasswordViewModel.swift
//  SnappyV2
//
//  Created by Kevin Palser on 26/09/2022.
//

import Combine
import OSLog

@MainActor
class ForgotPasswordViewModel: ObservableObject {
    @Published var email = ""
    @Published var emailHasError = false
    @Published var isLoading = false
    @Published private(set) var error: Error?
        
    let container: DIContainer
    let dismissHandler: (String?) -> Void
    private var cancellables = Set<AnyCancellable>()
    
    init(container: DIContainer, dismissHandler: @escaping (String?) -> Void) {
        self.container = container
        self.dismissHandler = dismissHandler
    }
    
    private func resetPassword() {
        Task { @MainActor [weak self] in
            guard let self = self else { return }
            do {
                try await self.container.services.memberService.resetPasswordRequest(email: email)
                Logger.member.log("Email sent to reset password")
                dismissHandler(email)
            } catch {
                self.error = error
                Logger.member.error("Failed to send password reset message with error: \(error.localizedDescription)")
            }
            self.isLoading = false
        }
    }
    
    func submitTapped() {
        emailHasError = email.isEmpty
        isLoading = true
        resetPassword()
    }
    
    func onAppearSendEvent() {
        container.eventLogger.sendEvent(for: .viewScreen, with: .appsFlyer, params: ["screen_reference": "reset_password"])
    }
}
