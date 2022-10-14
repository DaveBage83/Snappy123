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
            let result = try await container.services.memberService.requestMessageWithOneTimePassword(email: email, type: type)
            
            container.eventLogger.sendEvent(for: type == .email ? .otpEmail : .otpSms, with: .appsFlyer, params: [:])
            
            isSendingOTPRequest = false
            
            if result.success {
                showOTPCodePrompt = true
            }
        } catch {
            self.container.appState.value.errors.append(error)
            
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
            try await container.services.memberService.login(email: email, oneTimePassword: otpCode)
            
            var params: [String: Any] = [:]
            if let memberUUID = container.appState.value.userData.memberProfile?.uuid {
                params["member_id"] = memberUUID
            }
            container.eventLogger.sendEvent(for: .otpLogin, with: .appsFlyer, params: params)
            
            isSendingOTPCode = false
            
            dismissOTPPrompt()
        } catch {
            self.container.appState.value.errors.append(error)
            container.eventLogger.sendEvent(for: .otpWrong, with: .appsFlyer, params: [:])

            isSendingOTPCode = false
        }
    }
}
