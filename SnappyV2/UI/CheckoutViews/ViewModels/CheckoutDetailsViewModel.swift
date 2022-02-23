//
//  CheckoutDetailsViewModel.swift
//  SnappyV2
//
//  Created by David Bage on 21/02/2022.
//

import SwiftUI
import Combine

struct MarketingPreference {
    let image: Image
    let text: String
    let action: () -> Void
}

class CheckoutDetailsViewModel: ObservableObject {
    typealias Checkmark = Image.General.Checkbox
    typealias MarketingStrings = Strings.CheckoutDetails.MarketingPreferences
    
    let container: DIContainer
    let memberSignedIn: Bool
    
    // MARK: - Publishers
    
    @Published var firstname = ""
    @Published var surname = ""
    @Published var email = ""
    @Published var phoneNumber = ""
    @Published var isContinueTapped: Bool = false
        
    @Published var marketingPreferencesFetch: Loadable<UserMarketingOptionsFetch> = .notRequested
    @Published var updateMarketingOptionsRequest: Loadable<UserMarketingOptionsUpdateResponse> = .notRequested
    @Published var profileFetch: Loadable<MemberProfile> = .notRequested
    
    @Published var marketingOptionsResponses: [UserMarketingOptionResponse]?
    @Published var userMarketingPreferences: UserMarketingOptionsUpdateResponse?
    @Published var basketContactDetails: BasketContactDetails?
    
    @Published var emailMarketingEnabled = false
    @Published var directMailMarketingEnabled = false
    @Published var notificationMarketingEnabled = false
    @Published var smsMarketingEnabled = false
    @Published var telephoneMarketingEnabled = false
        
    @Published var firstNameHasWarning = false
    @Published var surnameHasWarning = false
    @Published var emailHasWarning = false
    @Published var phoneNumberHasWarning = false
    
    var canSubmit: Bool {
        !firstNameHasWarning && !surnameHasWarning && !emailHasWarning && !phoneNumberHasWarning
    }
    
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Computed properties - marketing preference details
    
    var emailPreference: MarketingPreference {
        MarketingPreference(
            image: emailMarketingEnabled ? Checkmark.checked : Checkmark.unChecked,
            text: MarketingStrings.email.localized,
            action: emailMarketingTapped)
    }
    
    var directMailPreference: MarketingPreference {
        MarketingPreference(
            image: directMailMarketingEnabled ? Checkmark.checked : Checkmark.unChecked,
            text: MarketingStrings.directMail.localized,
            action: directMailMarketingTapped)
    }
    
    var notificationsPreference: MarketingPreference {
        MarketingPreference(
            image: notificationMarketingEnabled ? Checkmark.checked : Checkmark.unChecked,
            text: MarketingStrings.notifications.localized,
            action: mobileNotificationsTapped)
    }
    
    var smsPreference: MarketingPreference {
        MarketingPreference(
            image: smsMarketingEnabled ? Checkmark.checked : Checkmark.unChecked,
            text: MarketingStrings.sms.localized,
            action: smsMarketingTapped)
    }
    
    var telephonePreference: MarketingPreference {
        MarketingPreference(
            image: telephoneMarketingEnabled ? Checkmark.checked : Checkmark.unChecked,
            text: MarketingStrings.telephone.localized,
            action: telephoneMarketingTapped)
    }
    
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
        
        self.memberSignedIn = appState.value.userData.memberSignedIn
        
        if memberSignedIn {
            container.services.userService.getProfile(profile: loadableSubject(\.profileFetch))
        }
        
        getMarketingPreferences()
        setupMarketingPreferences()
        setupMarketingPreferencesUpdate()
        
        setupMarketingOptionsResponses()
        setupProfileFetch()
        setupBasketContactDetails()
    }

    private func setupProfileFetch() {
        $profileFetch
            .sink { [weak self] profile in
                guard let self = self, let profile = profile.value else { return }
                self.firstname = profile.firstName
                self.surname = profile.lastName
                self.email = profile.emailAddress
            }
            .store(in: &cancellables)
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
            .receive(on: RunLoop.main)
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
    
    private func setupBasketContactDetails() {
        $basketContactDetails
            .sink { [weak self] basketContactDetails in
                guard let self = self, let basketContactDetails = basketContactDetails else { return }
                self.container.appState.value.userData.basketContactDetails = basketContactDetails
                self.firstname = basketContactDetails.firstName
                self.surname = basketContactDetails.surname
                self.email = basketContactDetails.email
                self.phoneNumber = basketContactDetails.telephoneNumber
            }
            .store(in: &cancellables)
        
        container.appState
            .map(\.userData.basketContactDetails)
            .receive(on: RunLoop.main)
            .assignWeak(to: \.basketContactDetails, on: self)
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
    
    private func setBasketContactDetailsToAppState() {
        self.basketContactDetails = BasketContactDetails(
            firstName: firstname,
            surname: surname,
            email: email,
            telephoneNumber: phoneNumber)
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
        updateMarketingPreferences()
        setBasketContactDetailsToAppState()
        isContinueTapped = true
    }
}

extension Bool {
    func opted() -> UserMarketingOptionState {
        self ? .in : .out
    }
}
