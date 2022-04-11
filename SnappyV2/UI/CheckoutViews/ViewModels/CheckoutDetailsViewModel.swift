//
//  CheckoutDetailsViewModel.swift
//  SnappyV2
//
//  Created by David Bage on 21/02/2022.
//

import Foundation
import Combine

class CheckoutDetailsViewModel: ObservableObject {
    
    let container: DIContainer
    
    // MARK: - Publishers
    
    @Published var firstname = ""
    @Published var surname = ""
    @Published var email = ""
    @Published var phoneNumber = ""
    @Published var isContinueTapped: Bool = false
    var errorMessage: String
        
    @Published var firstNameHasWarning = false
    @Published var surnameHasWarning = false
    @Published var emailHasWarning = false
    @Published var phoneNumberHasWarning = false
    @Published var showCantSetContactDetailsAlert = false
    @Published var handlingContinueUpdates = false
    @Published var profile: MemberProfile?
    
    var canSubmit: Bool {
        !firstNameHasWarning && !surnameHasWarning && !emailHasWarning && !phoneNumberHasWarning
    }
    
    private var cancellables = Set<AnyCancellable>()
    
    init(container: DIContainer) {
        self.container = container
        let appState = container.appState
        errorMessage = ""
        setupBindToProfile(with: appState)
        
        setupInitialContactDetails(with: appState)
        setupDetailsFromBasket(with: appState)
    }
    
    private func setupBindToProfile(with appState: Store<AppState>) {
        appState
            .map(\.userData.memberProfile)
            .receive(on: RunLoop.main)
            .sink { [weak self] profile in
                guard let self = self else { return }
                self.profile = profile
            }
            .store(in: &cancellables)
    }
    
    private func setupDetailsFromBasket(with appState: Store<AppState>) {
        appState
            .map(\.userData.basket)
            .receive(on: RunLoop.main)
            .sink { [weak self] basket in
                guard let self = self else { return }
                if let details = basket?.addresses?.first(where: { $0.type == AddressType.billing.rawValue }) {
                    self.firstname = details.firstName ?? ""
                    self.surname = details.lastName ?? ""
                    self.email = details.email ?? ""
                    self.phoneNumber = details.telephone ?? ""
                }
            }
            .store(in: &cancellables)
    }
    
    private func setupInitialContactDetails(with appState: Store<AppState>) {
        if let basket = appState.value.userData.basket, let details = basket.addresses?.first(where: { $0.type == AddressType.billing.rawValue }) {
            firstname = details.firstName ?? ""
            surname = details.lastName ?? ""
            email = details.email ?? ""
            phoneNumber = details.telephone ?? ""
        } else if let profile = appState.value.userData.memberProfile {
            firstname = profile.firstname
            surname = profile.lastname
            email = profile.emailAddress
            phoneNumber = profile.mobileContactNumber ?? ""
        }
    }
    
    private func setContactDetails() async throws {
        let contactDetailsRequest = BasketContactDetailsRequest(firstName: firstname, lastName: surname, email: email, telephone: phoneNumber)
        
        return try await container.services.basketService.setContactDetails(to: contactDetailsRequest)
            .singleOutput()
    }
    
    private func setFieldWarnings() {
        firstNameHasWarning = firstname.isEmpty
        surnameHasWarning = surname.isEmpty
        emailHasWarning = email.isEmpty
        phoneNumberHasWarning = phoneNumber.isEmpty
    }

    @MainActor
    func continueButtonTapped(updateMarketingPreferences: @escaping () async throws -> ()) async {
        errorMessage = ""
        setFieldWarnings()
        guard canSubmit else { return }
        
        do {
            handlingContinueUpdates = true
            try await updateMarketingPreferences()
            try await setContactDetails()
            handlingContinueUpdates = false
            isContinueTapped = true
        } catch {
            errorMessage = error.localizedDescription
            handlingContinueUpdates = false
            showCantSetContactDetailsAlert = true
        }
    }
}


