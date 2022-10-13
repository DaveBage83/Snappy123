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
    @Published var showAlreadyRegisteredAlert = false
    
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
            
    @Published var firstNameHasError = false
    
    @Published var lastNameHasError = false
    
    @Published var emailHasError = false
    @Published var showEmailInvalidWarning = false
    @Published var phoneHasError = false
    
    @Published var passwordHasError = false
    
    var orderTotal: Double? {
        container.appState.value.userData.basket?.orderTotal
    }
    
    @Published var termsAndConditionsHasError = false
        
    @Published var isLoading = false
    
    private var submitted = false
    
    let isInCheckout: Bool
    var isFromInitialView: Bool {
        container.appState.value.routing.showInitialView
    }
    
    let container: DIContainer
    
    init(container: DIContainer, isPostCheckout: Bool = false, isInCheckout: Bool = false) {
        self.container = container
        self.isPostCheckout = isPostCheckout
        self.isInCheckout = isInCheckout
        setupFirstNameError()
        setupLastNameError()
        setupPhoneError()
        setupPasswordError()
        setupEmailError()
    }
    
    private func setupFirstNameError() {
        $firstName
            .dropFirst()
            .receive(on: RunLoop.main)
            .map { $0.isEmpty }
            .assignWeak(to: \.firstNameHasError, on: self)
            .store(in: &cancellables)
    }
    
    private func setupLastNameError() {
        $lastName
            .dropFirst()
            .receive(on: RunLoop.main)
            .map { $0.isEmpty }
            .assignWeak(to: \.lastNameHasError, on: self)
            .store(in: &cancellables)
    }
    
    private func setupPhoneError() {
        $phone
            .dropFirst()
            .receive(on: RunLoop.main)
            .map { $0.isEmpty }
            .assignWeak(to: \.phoneHasError, on: self)
            .store(in: &cancellables)
    }
    
    private func setupPasswordError() {
        $password
            .dropFirst()
            .receive(on: RunLoop.main)
            .map { $0.isEmpty }
            .assignWeak(to: \.passwordHasError, on: self)
            .store(in: &cancellables)
    }
    
    private func setupEmailError() {
        $email
            .dropFirst()
            .receive(on: RunLoop.main)
            .sink { [weak self] email in
                guard let self = self else { return }
                self.emailHasError = email.isEmpty || !email.isEmail
                self.showEmailInvalidWarning = !email.isEmail && !email.isEmpty
            }
            .store(in: &cancellables)
    }

    private func registerUser() async throws {
        #warning("Need to verify contents of this - is MemberProfile in fact the response object rather than request?")
        
        let member = MemberProfileRegisterRequest(
            firstname: firstName,
            lastname: lastName,
            emailAddress: email,
            referFriendCode: nil,
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
            let alreadyRegistered = try await self.container.services.memberService.register(
                member: member,
                password: password,
                referralCode: nil,
                marketingOptions: marketingPreferences
            )
            
            if alreadyRegistered {
                self.showAlreadyRegisteredAlert = true
            }
            
            Logger.member.log("Successfully registered member")
            
            container.eventLogger.sendEvent(for: .completeRegistration, with: .appsFlyer, params: [AFEventCompleteRegistration: isPostCheckout ? "postcheckout" : "precheckout"])
        } catch {
            self.container.appState.value.errors.append(error)
            Logger.member.error("Failed to register member.")
        }
        self.isLoading = false
    }
    
    func termsAgreedTapped() {
        termsAgreed.toggle()
        termsAndConditionsHasError = false
    }
    
    func createAccountTapped() async throws {
        firstNameHasError = firstName.isEmpty
        lastNameHasError = lastName.isEmpty
        emailHasError = email.isEmpty || !email.isEmail
        phoneHasError = phone.isEmpty
        passwordHasError = password.isEmpty
        
        guard !firstNameHasError, !lastNameHasError, !emailHasError, !phoneHasError, !passwordHasError else { return }
        
        #warning("Should we not be handling this server side rather than locally?")
        if !termsAgreed {
            termsAndConditionsHasError = true
        } else {
            termsAndConditionsHasError = false
            self.isLoading = true
            try await registerUser()
        }
    }
    
    func filterPhoneNumber(newValue: String) {
        let filtered = newValue.filter { "0123456789+".contains($0) }
        if filtered != newValue {
            self.phone = filtered
        }
    }
}
