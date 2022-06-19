//
//  CreateAccountViewModel.swift
//  SnappyV2
//
//  Created by David Bage on 14/03/2022.
//

import Combine
import Foundation
import OSLog
import AuthenticationServices
import AppsFlyerLib

@MainActor
class CreateAccountViewModel: ObservableObject {
    // MARK: - Textfields content
    @Published var firstName = ""
    @Published var lastName = ""
    @Published var email = ""
    @Published var phone = ""
    @Published var password = ""
    @Published var referralCode = ""
    @Published private(set) var error: Error?
    
    // Controls show / hide password functionality
    @Published var passwordRevealed = false
    
    // MARK: - Marketing preferences
    @Published var emailMarketingEnabled = false
    @Published var directMailMarketingEnabled = false
    @Published var notificationMarketingEnabled = false
    @Published var smsMarketingEnabled = false
    @Published var telephoneMarketingEnabled = false
    @Published var termsAgreed = false
    private let isPostCheckout: Bool

    private var cancellables = Set<AnyCancellable>()
            
    var firstNameHasError: Bool {
        submitted && firstName.isEmpty
    }
    
    var lastNameHasError: Bool {
        submitted && lastName.isEmpty
    }
    
    var emailHasError: Bool {
        submitted && email.isEmpty
    }
    
    var phoneHasError: Bool {
        submitted && phone.isEmpty
    }
    
    var passwordHasError: Bool {
        submitted && password.isEmpty
    }
    
    @Published var termsAndConditionsHasError = false
        
    @Published var isLoading = false
    
    private var submitted = false
        
    let container: DIContainer
    
    init(container: DIContainer, isPostCheckout: Bool = false) {
        self.container = container
        self.isPostCheckout = isPostCheckout
    }

    private func registerUser() async throws {
        #warning("Need to verify contents of this - is MemberProfile in fact the response object rather than request?")
        
        let member = MemberProfileRegisterRequest(
            firstname: firstName,
            lastname: lastName,
            emailAddress: email,
            referFriendCode: referralCode.isEmpty ? nil : referralCode,
            mobileContactNumber: phone,
            defaultBillingDetails: nil,
            savedAddresses: nil
        )
        
        let marketingPreferences = [
            UserMarketingOptionResponse(type: MarketingOptions.email.rawValue, text: "", opted: emailMarketingEnabled ? .in : .out),
            UserMarketingOptionResponse(type: MarketingOptions.directMail.rawValue, text: "", opted: directMailMarketingEnabled ? .in : .out),
            UserMarketingOptionResponse(type: MarketingOptions.notification.rawValue, text: "", opted: notificationMarketingEnabled ? .in : .out),
            UserMarketingOptionResponse(type: MarketingOptions.sms.rawValue, text: "", opted: smsMarketingEnabled ? .in : .out),
            UserMarketingOptionResponse(type: MarketingOptions.telephone.rawValue, text: "", opted: telephoneMarketingEnabled ? .in : .out),
        ]
        
        do {
            try await self.container.services.userService.register(
                member: member,
                password: password,
                referralCode: referralCode,
                marketingOptions: marketingPreferences
            )
            Logger.member.log("Successfully registered member")
            
            container.eventLogger.sendEvent(for: .completeRegistration, with: .appsFlyer, params: [AFEventCompleteRegistration: isPostCheckout ? "postcheckout" : "precheckout"])
        } catch {
            self.error = error
            Logger.member.error("Failed to register member.")
        }
        self.isLoading = false
    }
    
    func termsAgreedTapped() {
        termsAgreed.toggle()
        termsAndConditionsHasError = false
    }
    
    func createAccountTapped() async throws {
        submitted = true
        
        #warning("Should we not be handling this server side rather than locally?")
        if !termsAgreed {
            termsAndConditionsHasError = true
        } else {
            termsAndConditionsHasError = false
            self.isLoading = true
            try await registerUser()
        }
    }
}
