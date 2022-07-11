//
//  CheckoutRootViewModel.swift
//  SnappyV2
//
//  Created by David Bage on 07/07/2022.
//

import Foundation
import Combine
import OSLog

@MainActor
class CheckoutRootViewModel: ObservableObject {

    // MARK: - Checkout root view state control
    enum CheckoutState {
        case initial
        case login
        case createAccount
        case details
        case paymentSelection
        case card
        case paymentSuccess
        case paymentFailure
        
        var progress: CheckoutProgressViewModel.ProgressState {
            switch self {
            case .initial:
                return .notStarted
            case .login:
                return .notStarted
            case .createAccount:
                return .notStarted
            case .details:
                return .details
            case .paymentSelection:
                return .payment
            case .card:
                return .payment
            case .paymentSuccess:
                return .completeSuccess
            case .paymentFailure:
                return .completeError
            }
        }
    }
    
    /// Used to determin in which direction we are navigating. This allows us to control the animation direction for views entering and leaving
    enum NavigationDirection {
        case back
        case forward
    }
    
    // MARK: - General properties
    private var cancellables = Set<AnyCancellable>()
    let container: DIContainer
    
    // MARK: - General publishers
    @Published var checkoutState: CheckoutState
    @Published var navigationDirection: NavigationDirection = .forward
    @Published var memberProfile: MemberProfile?
    @Published var fulfilmentTimeSlotSelectionPresented = false
    @Published var progressState: CheckoutProgressViewModel.ProgressState
    
    var fulfilmentType: BasketFulfilmentMethod? {
        container.appState.value.userData.basket?.fulfilmentMethod
    }
    
    // MARK: - Textfield publishers
    
    // Your details
    @Published var firstname = ""
    @Published var lastname = ""
    @Published var email = ""
    @Published var phoneNumber = ""
    
    // Your details - error handling
    @Published var firstNameHasWarning = false
    @Published var lastnameHasWarning = false
    @Published var emailHasWarning = false
    @Published var phoneNumberHasWarning = false
    @Published var showCantSetContactDetailsAlert = false
    @Published var handlingContinueUpdates = false
    @Published var showMissingDetailsWarning = false
    @Published var showEmailInvalidWarning = false
    @Published var showFieldErrorsAlert = false
    var addressWarning: (title: String, body: String) = ("", "")
    
    // These are used to automatically take the user to the first error in the view
    let firstnameId = 1
    let lastnameId = 2
    let emailId = 3
    let phoneId = 4

    var firstErrorId: Int? {
        if firstNameHasWarning {
            return firstnameId
        }
        
        if lastnameHasWarning {
            return lastnameId
        }
        
        if emailHasWarning {
            return emailId
        }
        
        if phoneNumberHasWarning {
            return phoneId
        }
        
        return nil
    }
    
    // Delivery note
    @Published var deliveryNote = ""
    
    // Marketing
    @Published var marketingSelected = false
    @Published var termsAgreed = false
    @Published var marketingPreferencesFetch: UserMarketingOptionsFetch?
    @Published var marketingOptionsResponses: [UserMarketingOptionResponse]?
    @Published var allowedMarketingChannelText = "Select a channel ..."
    @Published var selectedChannel: AllowedMarketingChannel?
    
    // Submitting form
    @Published var isSubmitting = false
    @Published var showFormSubmissionError = false
    var formSubmissionError: String?
    
    var orderTotal: Double? {
        container.appState.value.userData.basket?.orderTotal
    }

    // MARK: - Required user details
    // The following 4 computed variables are all required to set a delivery address. We therefore pass these into the address selection views
    // to avoid hitting an error once inside the views themselves.

    var deliveryEmail: String? {
        checkForUserDetail(valueToCheck: email, memberProfileValueToCheck: memberProfile?.emailAddress)
    }
    
    var deliveryFirstName: String? {
        checkForUserDetail(valueToCheck: firstname, memberProfileValueToCheck: memberProfile?.firstname)
    }

    var deliveryLastName: String? {
        checkForUserDetail(valueToCheck: lastname, memberProfileValueToCheck: memberProfile?.lastname)
    }
    
    var deliveryTelephone: String? {
        checkForUserDetail(valueToCheck: phoneNumber, memberProfileValueToCheck: memberProfile?.mobileContactNumber)
    }
    
    var allowedMarketingChannels: [AllowedMarketingChannel]? {
        if let channels = container.appState.value.userData.selectedStore.value?.allowedMarketingChannels, channels.count > 0 {
            return channels
        }
        return nil
    }

    // MARK: - Change fulfilment
    var selectedSlot: String {
        let slotString = container.appState.value.userData.basket?.selectedSlot?.fulfilmentString(
            container: container,
            isInCheckout: true,
            timeZone: .current) ?? Strings.CheckoutDetails.ChangeFulfilmentMethod.noSlot.localized
        
        if container.appState.value.userData.basket?.selectedSlot?.todaySelected == true {
            return slotString
        } else {
            return Strings.CheckoutDetails.ChangeFulfilmentMethodCustom.slotTime.localizedFormat(fulfilmentTypeString, slotString)
        }
    }
    
    var fulfilmentTypeString: String {
        if container.appState.value.userData.selectedFulfilmentMethod == .collection {
            return GeneralStrings.collection.localized
        }
        return GeneralStrings.delivery.localized
    }
    
    // Slot expiry
    var deliverySlotExpired: Bool {
        guard let slot = container.appState.value.userData.basket?.selectedSlot else { return false }
        
        if let expires = slot.end, expires.trueDate < Date().trueDate {
            return true
        }
        
        return false
    }
    
    var slotExpiringIn: Int? {
        let slotExpiryLimit: Double = 360 // 5 mins

        guard let slot = container.appState.value.userData.basket?.selectedSlot, let expires = slot.end else {
            return nil
        }

        let timeUntilExpiry = expires.timeIntervalSince1970 - Date().trueDate.timeIntervalSince1970
        
        if timeUntilExpiry < slotExpiryLimit {
            return Int(timeUntilExpiry / 60) // To mins
        }
        return nil
    }

    init(container: DIContainer) {
        self.container = container
        let appState = container.appState
        self._memberProfile = .init(initialValue: appState.value.userData.memberProfile)
        self.checkoutState = .initial
        self._progressState = .init(initialValue: .notStarted)
 
        setupBindToProfile(with: appState)
        setupMemberProfile()
        setupSelectedChannel()
        setupProgressState()
        
        if let memberProfile = memberProfile {
            populateContactDetails(profile: memberProfile)
        }
    }
    
    private func setupProgressState() {
        $checkoutState
            .receive(on: RunLoop.main)
            .sink { [weak self] state in
                guard let self = self else { return }
                self.progressState = state.progress
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Profile binding
    private func setupBindToProfile(with appState: Store<AppState>) {
        appState
            .map(\.userData.memberProfile)
            .receive(on: RunLoop.main)
            .sink { [weak self] profile in
                guard let self = self else { return }
                if let profile = profile {
                    self.memberProfile = profile
                } else {
                    self.memberProfile = nil
                }
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Profile setup
    private func setupMemberProfile() {
        $memberProfile
            .sink { [weak self] profile in
                guard let self = self else { return }
                
                if self.checkoutState == .initial || self.checkoutState == .login || self.checkoutState == .createAccount {
                    self.checkoutState = .details // If we have a profile, then set the
                }
            }
            .store(in: &cancellables)
    }

    // MARK: - Navigation control
    func backButtonPressed() {
        navigationDirection = .back
        switch checkoutState {
        case .initial:
            print("Back button pressed")
        case .login:
            checkoutState = .initial
        case .createAccount:
            checkoutState = .initial
        case .details:
            checkoutState = .initial
        case .card:
            checkoutState = .paymentSelection
        case .paymentSelection:
            checkoutState = .details
        case .paymentSuccess:
            print("back button pressed")
        case .paymentFailure:
            checkoutState = .card
        }
    }
        
    func guestCheckoutTapped() {
        navigationDirection = .forward
        checkoutState = .details
    }
    
    func loginToAccountTapped() {
        navigationDirection = .forward
        checkoutState = .login
    }
    
    func createAccountTapped() {
        navigationDirection = .forward
        checkoutState = .createAccount
    }
    
    // MARK: - Populate fields

    // Contact details
    private func populateContactDetails(profile: MemberProfile) {
        if let basketAddresses = container.appState.value.userData.basket?.addresses,
           let basketAddress = basketAddresses.first
        {
            if let firstname = basketAddress.firstName, !firstname.isEmpty {
                self.firstname = firstname
            } else {
                self.firstname = profile.firstname
            }
            
            if let lastname = basketAddress.lastName, !lastname.isEmpty {
                self.lastname = lastname
            } else {
                self.lastname = profile.lastname
            }
            
            if let email = basketAddress.email, !email.isEmpty {
                self.email = email
            } else {
                self.email = profile.emailAddress
            }

            if let phone = basketAddress.telephone, phone.isEmpty {
                self.phoneNumber = phone
            } else {
                self.phoneNumber = profile.mobileContactNumber ?? ""
            }
            
            return
        }
        
        self.firstname = profile.firstname
        self.lastname = profile.lastname
        self.email = profile.emailAddress
        self.phoneNumber = profile.mobileContactNumber ?? ""
    }
 
    private func userDetailsAreMissing() -> Bool {
        firstNameHasWarning = deliveryFirstName == nil
        lastnameHasWarning = deliveryLastName == nil
        emailHasWarning = deliveryEmail == nil
        phoneNumberHasWarning = deliveryTelephone == nil
        
        for warning in [firstNameHasWarning, lastnameHasWarning, emailHasWarning, phoneNumberHasWarning] {
            if warning == true {
                self.showMissingDetailsWarning = true
                return true
            }
        }
        return false
    }

    // MARK: - Helper functions
    /// Check whether field is populated, if not default to memberProfile equivalent of this value. Otherwise return nil
    private func checkForUserDetail(valueToCheck: String, memberProfileValueToCheck: String?) -> String? {
        // Is field empty? If not return value
        if valueToCheck.isEmpty == false {
            return valueToCheck
        }
        
        // If field is empty, check for equivalent value in memberProfile. If present, use this value ...
        if let memberProfileValueToCheck = memberProfileValueToCheck, memberProfileValueToCheck.isEmpty == false {
            return memberProfileValueToCheck
        }
        
        // ... else return nil
        return nil
    }
    
    // MARK: - Marketing channel selection
    func channelSelected(_ channel: AllowedMarketingChannel) {
        self.selectedChannel = channel
    }
    
    private func setupSelectedChannel() {
        $selectedChannel
            .receive(on: RunLoop.main)
            .sink { [weak self] channel in
                guard let self = self else { return }
                if let channel = channel {
                    self.allowedMarketingChannelText = channel.name
                }
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Form validation
    
    private func areContactFieldsCompleteAndErrorFree() -> Bool {
        firstNameHasWarning = firstname.isEmpty
        lastnameHasWarning = lastname.isEmpty
        emailHasWarning = email.isEmpty || !email.isEmail
        phoneNumberHasWarning = phoneNumber.isEmpty
        
        return !firstNameHasWarning && !lastnameHasWarning && !emailHasWarning && !phoneNumberHasWarning
    }

    private func areAllFieldsCompleteAndErrorFree() -> Bool {
        return areContactFieldsCompleteAndErrorFree()
    }
    
    // MARK: - Form submit methods
    func goToPaymentTapped(setDelivery: @escaping () async throws -> (), updateMarketingPreferences: @escaping () async throws -> ()) async {
        isSubmitting = true
        guard areAllFieldsCompleteAndErrorFree() else {
            showFieldErrorsAlert = true
            isSubmitting = false
            return
        }
                
        do {
            if fulfilmentType?.type == .delivery {
                try await setDelivery()
            }
            
            try await updateMarketingPreferences()
            try await setContactDetails()

            isSubmitting = false

            checkoutState = .paymentSelection
        } catch {
            isSubmitting = false
            
            if let error = error as? APIErrorResult {
                formSubmissionError = error.errorText
            }
            
            showFormSubmissionError = true
        }
    }
    
    
    private func setContactDetails() async throws {
        let contactDetailsRequest = BasketContactDetailsRequest(firstName: firstname, lastName: lastname, email: email, telephone: phoneNumber)
        
        return try await self.container.services.basketService.setContactDetails(to: contactDetailsRequest)
    }
    
    // MARK: - Realtime field validation
    
    // Following methods fired onChange of their relative string values allowing us
    // to check for field errors in realtime
    func checkFirstname() {
        firstNameHasWarning = firstname.isEmpty
    }
    
    func checkLastname() {
        lastnameHasWarning = lastname.isEmpty
    }
    
    func checkEmailValidity() {
        if email.isEmpty {
            emailHasWarning = true
            showEmailInvalidWarning = false
        } else if email.isEmail == false {
            emailHasWarning = true
            showEmailInvalidWarning = true
        } else {
            emailHasWarning = false
            showEmailInvalidWarning = false
        }
    }
    
    func checkPhoneValidity() {
        phoneNumberHasWarning = phoneNumber.isEmpty
    }

    // MARK: - Payment
    func payByCardTapped() {
        checkoutState = .card
    }
}
