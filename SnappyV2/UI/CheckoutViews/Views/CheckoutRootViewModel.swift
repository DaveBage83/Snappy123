//
//  CheckoutRootViewModel.swift
//  SnappyV2
//
//  Created by David Bage on 07/07/2022.
//

import Foundation
import Combine
import OSLog
import SwiftUI

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
        
        var progress: ProgressState {
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
    
    // MARK: - Progress state
    enum ProgressState: Int, CaseIterable {
        case notStarted = 0
        case details
        case payment
        case completeSuccess
        case completeError
        
        var title: String? {
            switch self {
            case .details:
                return Strings.CheckoutDetails.CheckoutProgress.details.localized
            case .payment:
                return Strings.CheckoutDetails.CheckoutProgress.payment.localized
            default:
                return nil
            }
        }
        
        // Not all states count as progression. We actually only have 2 states currently which should change the % value of the progress bar.
        // The others are used to configure checkmark icons and progress bar colour
        var isProgression: Bool {
            switch self {
            case .notStarted:
                return false
            case .details:
                return true
            case .payment:
                return true
            case .completeSuccess:
                return false
            case .completeError:
                return false
            }
        }
        
        // Get the max progress value
        var maxValue: Int {
            ProgressState.allCases.filter { $0.isProgression }.count
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
    
    // MARK: - Progress state properties
    var maxProgress: Double {
        Double(progressState.maxValue)
    }
    
    var currentProgress: Double {
        if Double(progressState.rawValue) > maxProgress {
            return maxProgress
        }
        return Double(progressState.rawValue)
    }
    
    // MARK: - General publishers
    @Published var checkoutState: CheckoutState
    @Published var navigationDirection: NavigationDirection = .forward // Controls the custom navigation flow animation direction.
    @Published var memberProfile: MemberProfile?
    @Published var progressState: ProgressState // Controls the progress bar value
    
    // MARK: - Presentation publishers
    @Published var fulfilmentTimeSlotSelectionPresented = false
    @Binding var keepCheckoutFlowAlive: Bool // This binding property is used to dismiss the entire stack and return to basket view
    @Published var showCantSetContactDetailsAlert = false
    @Published var showMissingDetailsWarning = false
    @Published var showEmailInvalidWarning = false
    @Published var showFieldErrorsAlert = false
    
    // MARK: - Textfield publishers
    
    // Your details
    @Published var firstname = ""
    @Published var lastname = ""
    @Published var email = ""
    @Published var phoneNumber = ""
    
    // Delivery note
    @Published var deliveryNote = ""
    
    // MARK: - Error handling
    
    @Published var newErrorsExist = false // We use this boolean to trigger the onChange event in the main view to scroll to the contact section if field errors are detected
    
    @Published var firstNameHasWarning = false {
        didSet {
            if firstNameHasWarning {
                newErrorsExist = true
            } else if noErrors() {
                newErrorsExist = false
            }
        }
    }
    
    @Published var lastnameHasWarning = false {
        didSet {
            if lastnameHasWarning {
                newErrorsExist = true
            } else if noErrors() {
                newErrorsExist = false
            }
        }
    }
    
    @Published var emailHasWarning = false {
        didSet {
            if emailHasWarning {
                newErrorsExist = true
            } else if noErrors() {
                newErrorsExist = false
            }
        }
    }
    
    @Published var phoneNumberHasWarning = false {
        didSet {
            if phoneNumberHasWarning {
                newErrorsExist = true
            } else if noErrors() {
                newErrorsExist = false
            }
        }
    }
    
    @Published var showFormSubmissionError = false
    var formSubmissionError: String?
    
    // Using this tuple, we can set the title and body of the toast alert with a suitable error message
    var addressWarning: (title: String, body: String) = ("", "")
    
    // Marketing
    @Published var marketingSelected = false
    @Published var termsAgreed = false
    @Published var marketingPreferencesFetch: UserMarketingOptionsFetch?
    @Published var marketingOptionsResponses: [UserMarketingOptionResponse]?
    @Published var allowedMarketingChannelText = Strings.CheckoutDetails.WhereDidYouHear.placeholder.localized
    @Published var selectedChannel: AllowedMarketingChannel?
    
    // Submitting form - to control loading state
    @Published var isSubmitting = false
    
    var orderTotal: Double? {
        container.appState.value.userData.basket?.orderTotal
    }
    
    var slotIsEmpty: Bool {
        container.appState.value.userData.basket?.selectedSlot == nil
    }
    
    var fulfilmentType: BasketFulfilmentMethod? {
        container.appState.value.userData.basket?.fulfilmentMethod
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
    
    // MARK: - Allowed marketing
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
            if fulfilmentType?.type == .delivery {
                return Strings.CheckoutDetails.ChangeFulfilmentMethodCustom.slotTimeDelivery.localizedFormat(slotString)
            }
            return Strings.CheckoutDetails.ChangeFulfilmentMethodCustom.slotTimeCollection.localizedFormat(slotString)
        }
    }
    
    var fulfilmentTypeString: String {
        if container.appState.value.userData.basket?.fulfilmentMethod.type == .collection {
            return GeneralStrings.collection.localized
        }
        return GeneralStrings.delivery.localized
    }
    
    // MARK: - Slot expiry
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
    
    // MARK: - Init
    init(container: DIContainer, keepCheckoutFlowAlive: Binding<Bool>) {
        self.container = container
        let appState = container.appState
        self._memberProfile = .init(initialValue: appState.value.userData.memberProfile)
        self.checkoutState = .initial
        self._progressState = .init(initialValue: .notStarted)
        self._keepCheckoutFlowAlive = keepCheckoutFlowAlive
        
        // Setup
        setupBindToProfile(with: appState)
        setupMemberProfile()
        setupSelectedChannel()
        setupProgressState()
        
        // Populate fields
        populateContactDetails(profile: memberProfile)
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
                    self.populateContactDetails(profile: profile)
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
                    self.checkoutState = self.memberProfile == nil ? .initial : .details // If we have a profile, then set the
                }
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Navigation control
    func backButtonPressed() {
        navigationDirection = .back
        switch checkoutState {
        case .initial:
            keepCheckoutFlowAlive = false // Dismiss checkout navigation stack
        case .login:
            checkoutState = .initial
        case .createAccount:
            checkoutState = .initial
        case .details:
            if memberProfile == nil {
                checkoutState = .initial
            } else {
                keepCheckoutFlowAlive = false // Dismiss checkout navigation stack
            }
            
        case .card:
            checkoutState = .paymentSelection
        case .paymentSelection:
            checkoutState = .details
        case .paymentSuccess:
            return // Do not allow backwards navigation at this point
        case .paymentFailure:
            return // Do not allow backwards navigation at this point
        }
    }
    
    // MARK: - Simple navigation methods
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
    
    // MARK: - Field error setting
    // We return the contact details here for use in submission errors. If contact details are nil at this point, we can pass this into the relevant
    // viewModel that is handling the form submission, and trigger errors from there
    func contactDetails() -> (firstName: String, lastName: String, email: String, phone: String)? {
        guard !firstname.isEmpty, !lastname.isEmpty, !email.isEmpty, !phoneNumber.isEmpty, email.isEmail else {
            setFieldWarnings()
            return nil
        }
        
        return (firstname, lastname, email, phoneNumber)
    }
    
    private func setFieldWarnings() {
        firstNameHasWarning = firstname.isEmpty
        lastnameHasWarning = lastname.isEmpty
        emailHasWarning = email.isEmpty || !email.isEmail
        phoneNumberHasWarning = phoneNumber.isEmpty
    }
    
    // MARK: - Populate fields
    
    // Contact details
    private func populateContactDetails(profile: MemberProfile?) {
        guard isSubmitting == false else { return } // Avoid populating fields whilst API changes are being made
        
        // First we check the basket address. If this is present, we use this to perform field population
        if let basketAddresses = container.appState.value.userData.basket?.addresses,
           let basketAddress = basketAddresses.first
        {
            if firstname.isEmpty, let firstname = basketAddress.firstName, !firstname.isEmpty {
                self.firstname = firstname
            } else if firstname.isEmpty, let firstname = profile?.firstname {
                self.firstname = firstname
            }
            
            if lastname.isEmpty, let lastname = basketAddress.lastName, !lastname.isEmpty {
                self.lastname = lastname
            } else if lastname.isEmpty, let lastname = profile?.lastname {
                self.lastname = lastname
            }
            
            if email.isEmpty, let email = basketAddress.email, !email.isEmpty {
                self.email = email
            } else if email.isEmpty, let email = profile?.emailAddress {
                self.email = email
            }
            
            if phoneNumber.isEmpty, let phone = basketAddress.telephone, !phone.isEmpty {
                self.phoneNumber = phone
            } else if phoneNumber.isEmpty, let phone = profile?.mobileContactNumber {
                self.phoneNumber = phone
            }
            
            return
        }
        
        // If no basket we check if there is a profile. If not, we return early...
        guard let profile = profile else {
            return
        }
        
        // ... otherwise we populate the fiels with the relevant profile values
        self.firstname = profile.firstname
        self.lastname = profile.lastname
        self.email = profile.emailAddress
        
        // We do not nil coelesce here as this will cause the floating label of the field to move regardless
        if let phone = profile.mobileContactNumber {
            self.phoneNumber = phone
        }
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
    
    private func areAllFieldsCompleteAndFreeFromErrors(addressErrorsPresent: Bool) -> Bool {
        firstNameHasWarning = firstname.isEmpty
        lastnameHasWarning = lastname.isEmpty
        emailHasWarning = email.isEmpty || !email.isEmail
        phoneNumberHasWarning = phoneNumber.isEmpty
        
        if fulfilmentType?.type == .delivery { // We omit the address check if fulfilmentType is collection
            return !firstNameHasWarning && !lastnameHasWarning && !emailHasWarning && !phoneNumberHasWarning && !addressErrorsPresent && !slotIsEmpty
        }
        
        return !firstNameHasWarning && !lastnameHasWarning && !emailHasWarning && !phoneNumberHasWarning && !slotIsEmpty
    }
    
    // MARK: - Form submit methods
    func goToPaymentTapped(addressErrors: Bool, setDelivery: @escaping () async throws -> (), updateMarketingPreferences: @escaping () async throws -> ()) async {
        isSubmitting = true
        
        // Check all fields errors
        guard areAllFieldsCompleteAndFreeFromErrors(addressErrorsPresent: addressErrors) else {
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
    
    func resetNewErrorsExist() {
        newErrorsExist = false
    }
    
    // MARK: - Progress state methods
    func stepIsActive(step: ProgressState) -> Bool {
        return progressState.rawValue >= step.rawValue
    }
    
    func stepIsComplete(step: ProgressState) -> Bool {
        return progressState.rawValue > step.rawValue
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
    
    func noErrors() -> Bool {
        return !firstNameHasWarning && !lastnameHasWarning && !emailHasWarning && !phoneNumberHasWarning
    }
}
