//
//  VerifyMobileNumberViewModel.swift
//  SnappyV2
//
//  Created by Kevin Palser on 21/09/2022.
//

import Foundation
import Combine
import OSLog

@MainActor
class VerifyMobileNumberViewModel: ObservableObject {
    
    // MARK: - Typealiases
    typealias VerifyMobileNumberStrings = Strings.VerifyMobileNumber
    
    let minimumVerifyCodeCharacters = 4
    
    let container: DIContainer
    let dismissAction: (Error?, String?) -> ()
    
    @Published var isRequestingOrSendingVerificationCode: Bool = false
    @Published var verifyCode: String = ""
    @Published var submitDisabled = true
    @Published var toastMessage: String?
    
    var instructions: String {
        let mobileContactNumber = container.appState.value.userData.memberProfile?.mobileContactNumber ?? ""
        if
            let basket = container.appState.value.userData.basket,
            basket.coupon?.registeredMemberRequirement == .registeredWithVerification
        {
            return VerifyMobileNumberStrings.EnterCodeViewDynamicText.instructionsWhenCoupon.localizedFormat(mobileContactNumber)
        } else {
            return VerifyMobileNumberStrings.EnterCodeViewDynamicText.instructions.localizedFormat(mobileContactNumber)
        }
    }
    
    private var cancellables = Set<AnyCancellable>()
    
    init(container: DIContainer, dismissViewHandler: @escaping (Error?, String?)->()) {
        self.container = container
        dismissAction = dismissViewHandler
        setupBindingsToVerifyCode()
    }
    
    func filteredVerifyCode(newValue: String) {
        let filteredString = newValue.uppercased().filter { Set("0123456789ABCDEF").contains($0) }
        if filteredString != newValue {
            verifyCode = filteredString
        }
    }
    
    private func setupBindingsToVerifyCode() {
        $verifyCode.sink { [weak self] code in
            guard let self = self else { return }
            // have at least minimumVerifyCodeCharacters characters
            self.submitDisabled = code.count < self.minimumVerifyCodeCharacters
        }
        .store(in: &cancellables)
    }
    
    func resendCodeTapped() async {
        isRequestingOrSendingVerificationCode = true
        do {
            let keepViewOpen = try await container.services.memberService.requestMobileVerificationCode()
            if keepViewOpen == false {
                // Some frindge case has occurred, e.g. member has already verified, so just
                // close this view
                dismissAction(nil, nil)
            } else {
                isRequestingOrSendingVerificationCode = false
                toastMessage = VerifyMobileNumberStrings.EnterCodeViewStaticText.resendMessage.localized
            }
        } catch {
            self.container.appState.value.errors.append(error)
            isRequestingOrSendingVerificationCode = false
            Logger.member.error("Failed to request SMS Mobile verification code: \(error.localizedDescription)")
        }
    }
    
    func submitCodeTapped() async {
        isRequestingOrSendingVerificationCode = true
        do {
            try await container.services.memberService.checkMobileVerificationCode(verificationCode: verifyCode)
            dismissAction(nil, VerifyMobileNumberStrings.EnterCodeViewStaticText.verifiedMessage.localized)
        } catch {
            isRequestingOrSendingVerificationCode = false
            self.container.appState.value.errors.append(error)
            Logger.member.error("Failed to verify account code: \(error.localizedDescription)")
        }
    }
    
    func cancelTapped() {
        dismissAction(nil, nil)
    }
    
}
