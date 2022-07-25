//
//  OTPPromptViewModel.swift
//  SnappyV2
//
//  Created by Henrik Gustavii on 20/07/2022.
//

import Foundation

@MainActor
class OTPPromptViewModel: ObservableObject {
    let container: DIContainer
    let dismissAction: () -> ()
    
    @Published var email = ""
    
    @Published var otpTelephone: String = ""
    @Published var showOTPTelephone: Bool = false
    @Published var showLoginView: Bool = false
    @Published var isSendingOTPRequest: Bool = false
    @Published var isSendingOTPCode: Bool = false
    @Published var showOTPCodePrompt: Bool = false
    @Published var otpCode: String = ""
    @Published var otpType: OneTimePasswordSendType = .sms
    
    var disableLogin: Bool { otpCode.isEmpty }
    
    var optCodeSendDestination: String { otpType == .sms ? otpTelephone : email }
    
    @Published var error: Error?
    
    init(container: DIContainer, email: String, otpTelephone: String, dismiss: @escaping ()->()) {
        self.container = container
        self.email = email
        self.otpTelephone = otpTelephone
        self.dismissAction = dismiss
        
        if otpTelephone.isEmpty == false { showOTPTelephone = true }
    }
    
    func sendOTP(via type: OneTimePasswordSendType) async {
        isSendingOTPRequest = true
        otpType = type
        
        do {
            let result = try await container.services.userService.requestMessageWithOneTimePassword(email: email, type: type)
            
            isSendingOTPRequest = false
            
            if result.success {
                showOTPCodePrompt = true
            }
        } catch {
            self.error = error
            
            isSendingOTPRequest = false
        }
    }
    
    func dismissOTPPrompt() {
        dismissAction()
    }
    
    func login() {
        showLoginView = true
    }
    
    func loginWithOTP() async {
        isSendingOTPCode = true
        
        do {
            try await container.services.userService.login(email: email, oneTimePassword: otpCode)
            
            isSendingOTPCode = false
            
            dismissOTPPrompt()
        } catch {
            self.error = error
            
            isSendingOTPCode = false
        }
    }
}
