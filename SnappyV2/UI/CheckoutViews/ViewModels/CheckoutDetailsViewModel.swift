//
//  CheckoutDetailsViewModel.swift
//  SnappyV2
//
//  Created by David Bage on 21/02/2022.
//

import SwiftUI
import Combine
import OSLog

struct MarketingPreferenceSettings {
    let image: Image
    let text: String
    let action: () -> Void
}

class CheckoutDetailsViewModel: ObservableObject {
    typealias Checkmark = Image.General.Checkbox
    typealias MarketingStrings = Strings.CheckoutDetails.MarketingPreferences
    
    let container: DIContainer
    
    // MARK: - Publishers
    
    @Published var firstname = ""
    @Published var surname = ""
    @Published var email = ""
    @Published var phoneNumber = ""
    @Published var isContinueTapped: Bool = false
        
    @Published var marketingPreferencesFetch: Loadable<UserMarketingOptionsFetch> = .notRequested
    @Published var updateMarketingOptionsRequest: Loadable<UserMarketingOptionsUpdateResponse> = .notRequested
    
    @Published var marketingOptionsResponses: [UserMarketingOptionResponse]?
    @Published var userMarketingPreferences: UserMarketingOptionsUpdateResponse?
    @Published var basketContactDetails: BasketContactDetailsRequest?
    
    @Published var emailMarketingEnabled = false
    @Published var directMailMarketingEnabled = false
    @Published var notificationMarketingEnabled = false
    @Published var smsMarketingEnabled = false
    @Published var telephoneMarketingEnabled = false
        
    @Published var firstNameHasWarning = false
    @Published var surnameHasWarning = false
    @Published var emailHasWarning = false
    @Published var phoneNumberHasWarning = false
    @Published var profile: MemberProfile?
    
    var canSubmit: Bool {
        !firstNameHasWarning && !surnameHasWarning && !emailHasWarning && !phoneNumberHasWarning
    }
    
    private var cancellables = Set<AnyCancellable>()
    
    var marketingPreferencesAreLoading: Bool {
        switch marketingPreferencesFetch {
        case .isLoading(last: _, cancelBag: _):
            return true
        default:
            return false
        }
    }
    
    init(container: DIContainer) {
        self.container = container
        let appState = container.appState
        setupBindToProfile(with: appState)
        
        getMarketingPreferences()
        setupInitialContactDetails(with: appState)

        // Set up publishers
        setupMarketingPreferences()
        setupMarketingPreferencesUpdate()
        setupMarketingOptionsResponses()
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
                if let details = basket?.addresses?.first(where: { $0.type == "billing" }) {
                    self.firstname = details.firstName ?? ""
                    self.surname = details.lastName ?? ""
                    self.email = details.email ?? ""
                    self.phoneNumber = details.telephone ?? ""
                }
            }
            .store(in: &cancellables)
    }
    
    private func setupInitialContactDetails(with appState: Store<AppState>) {
        if let basket = appState.value.userData.basket, let details = basket.addresses?.first(where: { $0.type == "billing" }) {
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

    private func setupMarketingOptionsResponses() {
        $marketingOptionsResponses
            .receive(on: RunLoop.main)
            .sink { [weak self] marketingResponses in
                guard let self = self else { return }
                // Set marketing properties
                self.emailMarketingEnabled = marketingResponses?.filter { $0.type == MarketingOptions.email.rawValue }.first?.opted == .in
                self.directMailMarketingEnabled = marketingResponses?.filter { $0.type == MarketingOptions.directMail.rawValue }.first?.opted == .in
                self.notificationMarketingEnabled = marketingResponses?.filter { $0.type == MarketingOptions.notification.rawValue }.first?.opted == .in
                self.smsMarketingEnabled = marketingResponses?.filter { $0.type == MarketingOptions.sms.rawValue }.first?.opted == .in
                self.telephoneMarketingEnabled = marketingResponses?.filter { $0.type == MarketingOptions.telephone.rawValue }.first?.opted == .in
            }
            .store(in: &cancellables)
    }

    private func setupMarketingPreferences() {
        $marketingPreferencesFetch
            .map { preferencesFetch in
                return preferencesFetch.value?.marketingOptions
            }
            .assignWeak(to: \.marketingOptionsResponses, on: self)
            .store(in: &cancellables)
    }
    
    private func setupMarketingPreferencesUpdate() {
        $updateMarketingOptionsRequest
            .sink(receiveValue: { [weak self] updatedPreferences in
                guard let self = self else { return }
                
                if let updatedPreferences = updatedPreferences.value {
                    self.userMarketingPreferences = updatedPreferences
                }
            })
            .store(in: &cancellables)
    }
    
    private func getMarketingPreferences() {
        container.services.userService.getMarketingOptions(options: loadableSubject(\.marketingPreferencesFetch), isCheckout: true, notificationsEnabled: true)
    }
    
    private func updateUserMarketingOptions(options: [UserMarketingOptionRequest]) {
        container.services.userService.updateMarketingOptions(result: loadableSubject(\.updateMarketingOptionsRequest), options: options)
    }
    
    // MARK: - Button tap methods
    
    func emailMarketingTapped() {
        self.emailMarketingEnabled.toggle()
    }
    
    func directMailMarketingTapped() {
        self.directMailMarketingEnabled.toggle()
    }
    
    func mobileNotificationsTapped() {
        self.notificationMarketingEnabled.toggle()
    }
    
    func smsMarketingTapped() {
        self.smsMarketingEnabled.toggle()
    }
    
    func telephoneMarketingTapped() {
        self.telephoneMarketingEnabled.toggle()
    }
    
    func preferenceSettings(type: MarketingOptions) -> MarketingPreferenceSettings {
        switch type {
        case .email:
            return  MarketingPreferenceSettings(
                image: emailMarketingEnabled ? Checkmark.checked : Checkmark.unChecked,
                text: MarketingStrings.email.localized,
                action: emailMarketingTapped)
            
        case .notification:
            return MarketingPreferenceSettings(
                image: directMailMarketingEnabled ? Checkmark.checked : Checkmark.unChecked,
                text: MarketingStrings.notifications.localized,
                action: directMailMarketingTapped)
        case .sms:
            return MarketingPreferenceSettings(
                image: notificationMarketingEnabled ? Checkmark.checked : Checkmark.unChecked,
                text: MarketingStrings.sms.localized,
                action: mobileNotificationsTapped)
        case .telephone:
            return MarketingPreferenceSettings(
                image: smsMarketingEnabled ? Checkmark.checked : Checkmark.unChecked,
                text: MarketingStrings.telephone.localized,
                action: smsMarketingTapped)
        case .directMail:
            return MarketingPreferenceSettings(
                image: telephoneMarketingEnabled ? Checkmark.checked : Checkmark.unChecked,
                text: MarketingStrings.directMail.localized,
                action: telephoneMarketingTapped)
        }
    }
    
    private func updateMarketingPreferences() {
        let preferences = [
            UserMarketingOptionRequest(type: MarketingOptions.email.rawValue, opted: emailMarketingEnabled.opted()),
            UserMarketingOptionRequest(type: MarketingOptions.directMail.rawValue, opted: directMailMarketingEnabled.opted()),
            UserMarketingOptionRequest(type: MarketingOptions.notification.rawValue, opted: notificationMarketingEnabled.opted()),
            UserMarketingOptionRequest(type: MarketingOptions.sms.rawValue, opted: smsMarketingEnabled.opted()),
            UserMarketingOptionRequest(type: MarketingOptions.telephone.rawValue, opted: telephoneMarketingEnabled.opted()),
        ]
        
        updateUserMarketingOptions(options: preferences)
    }
    
    private func setContactDetails() {
        setBasketContactDetails()
        
        let contactDetailsRequest = BasketContactDetailsRequest(firstName: firstname, lastName: surname, email: email, telephone: phoneNumber)
        container.services.basketService.setContactDetails(to: contactDetailsRequest)
            .sink { completion in
                switch completion {
                case .finished:
                    Logger.checkout.info("Successfully set contact details")
                case .failure(let error):
                    Logger.checkout.error("Failed to set contact details - Error: \(error.localizedDescription)")
                }
            }
            .store(in: &cancellables)
    }
    
    private func setBasketContactDetails() {
        self.basketContactDetails = BasketContactDetailsRequest(
            firstName: firstname,
            lastName: surname,
            email: email,
            telephone: phoneNumber)
    }
    
    private func setFieldWarnings() {
        firstNameHasWarning = firstname.isEmpty
        surnameHasWarning = surname.isEmpty
        emailHasWarning = email.isEmpty
        phoneNumberHasWarning = phoneNumber.isEmpty
    }

    func continueButtonTapped() {
        setFieldWarnings()
        
        guard canSubmit else { return }
        setContactDetails()
        isContinueTapped = true
    }
}

#if DEBUG
extension CheckoutDetailsViewModel {
    func exposeSetContactDetails() {
        return self.setContactDetails()
    }
    
    func exposeUpdateMarketingPreferences() {
        return self.updateMarketingPreferences()
    }
}
#endif
