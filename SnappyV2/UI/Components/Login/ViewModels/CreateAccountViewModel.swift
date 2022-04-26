//
//  CreateAccountViewModel.swift
//  SnappyV2
//
//  Created by David Bage on 14/03/2022.
//

import Combine
import Foundation
import OSLog

class CreateAccountViewModel: ObservableObject {
    // MARK: - Textfields content
    @Published var firstName = ""
    @Published var lastName = ""
    @Published var email = ""
    @Published var phone = ""
    @Published var password = ""
    @Published var referralCode = ""
    
    // Controls show / hide password functionality
    @Published var passwordRevealed = false
    
    // MARK: - Marketing preferences
    @Published var emailMarketingEnabled = false
    @Published var directMailMarketingEnabled = false
    @Published var notificationMarketingEnabled = false
    @Published var smsMarketingEnabled = false
    @Published var telephoneMarketingEnabled = false
    @Published var termsAgreed = false

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
    
    init(container: DIContainer) {
        self.container = container
    }

    private func registerUser() {
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
        
        Task { @MainActor [weak self] in
            guard let self = self else { return }
            do {
                try await self.container.services.userService.register(
                    member: member,
                    password: password,
                    referralCode: referralCode,
                    marketingOptions: marketingPreferences
                )
                
                Logger.member.log("Successfully registered member")
            } catch {
                #warning("Add error handing")
                Logger.member.error("Failed to register member.")
            }
            self.isLoading = false
        }
    }
    
    func termsAgreedTapped() {
        termsAgreed.toggle()
        termsAndConditionsHasError = false
    }
    
    func createAccountTapped() {
        submitted = true
        
        #warning("Should we not be handling this server side rather than locally?")
        if !termsAgreed {
            termsAndConditionsHasError = true
        } else {
            termsAndConditionsHasError = false
            self.isLoading = true
            registerUser()
        }
    }
}
