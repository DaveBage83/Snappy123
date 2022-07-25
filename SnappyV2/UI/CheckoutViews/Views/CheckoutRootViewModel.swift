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
import CoreLocation

enum CheckoutRootViewError: Swift.Error {
    case missingDetails
    case noAddressesFound
    case noSavedAddressesFound
    case noTimeSlots
}

extension CheckoutRootViewError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .missingDetails:
            return Strings.CheckoutDetails.Errors.Missing.subtitle.localized
        case .noAddressesFound:
            return Strings.CheckoutDetails.Errors.NoAddresses.postcodeSearch.localized
        case .noSavedAddressesFound:
            return Strings.CheckoutDetails.Errors.NoAddresses.savedAddresses.localized
        case .noTimeSlots:
            return Strings.CheckoutDetails.Errors.NoSlots.title.localized
        }
    }
}

@MainActor
class CheckoutRootViewModel: ObservableObject {
    
    @Published var checkoutError: Swift.Error?
    
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
            case .initial, .login, .createAccount:
                return .notStarted
            case .details:
                return .details
            case .paymentSelection, .card:
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
            case .notStarted, .completeSuccess, .completeError:
                return false
            case .details, .payment:
                return true
            }
        }
        
        // Get the max progress value
        var maxValue: Int {
            ProgressState.allCases.filter { $0.isProgression }.count
        }
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
    
    var showDeliveryNote: Bool {
        fulfilmentType?.type == .delivery
    }
    
    var showMarketingPrefs: Bool {
        memberProfile != nil
    }
    
    // MARK: - General publishers
    @Published var checkoutState: CheckoutState
    @Published var navigationDirection: NavigationDirection = .forward // Controls the custom navigation flow animation direction.
    @Published var memberProfile: MemberProfile?
    private var selectedStore: RetailStoreDetails?
    @Published var progressState: ProgressState // Controls the progress bar value
    @Published var basket: Basket?
    
    // MARK: - Time slot publishers
    @Published var selectedRetailStoreFulfilmentTimeSlots: Loadable<RetailStoreTimeSlots> = .notRequested
    @Published var tempTodayTimeSlot: RetailStoreSlotDayTimeSlot?
    
    // MARK: - Presentation publishers
    @Published var fulfilmentTimeSlotSelectionPresented = false
    @Binding var keepCheckoutFlowAlive: Bool // This binding property is used to dismiss the entire stack and return to basket view
    @Published var showCantSetContactDetailsAlert = false
    @Published var showMissingDetailsWarning = false
    @Published var showEmailInvalidWarning = false
    @Published var showFieldErrorsAlert = false
    
    // MARK: - Registration properties
    var registrationChecked: Bool = false
    @Published var showOTPPrompt: Bool = false
    @Published var otpTelephone: String = ""
    
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
        
        // If no slot, just return the slotString as is (i.e. "No slot selected")
        guard container.appState.value.userData.basket?.selectedSlot != nil else { return slotString }
        
        // Otherwise we concatenate string with time
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
    
    var slotExpiringIn: String? {
        let slotExpiryLimit: Double = 360 // 5 mins
        
        guard let slot = container.appState.value.userData.basket?.selectedSlot, let expires = slot.end else {
            return nil
        }
        
        let timeUntilExpiry = expires.timeIntervalSince1970 - Date().trueDate.timeIntervalSince1970
        
        if timeUntilExpiry < slotExpiryLimit {
            return String(Int(timeUntilExpiry / 60)) // To mins
        }
        return nil
    }
    
    // MARK: - Checkout button
    var showGuestCheckoutButton: Bool {
        if let selectedStore = selectedStore {
            return selectedStore.guestCheckoutAllowed
        }
        return true
    }
    
    // MARK: - Init
    init(container: DIContainer, keepCheckoutFlowAlive: Binding<Bool>) {
        self.container = container
        let appState = container.appState
        self._memberProfile = .init(initialValue: appState.value.userData.memberProfile)
        self.checkoutState = .initial
        self._progressState = .init(initialValue: .notStarted)
        self._keepCheckoutFlowAlive = keepCheckoutFlowAlive
        self._tempTodayTimeSlot = .init(initialValue: appState.value.userData.tempTodayTimeSlot)
        basket = appState.value.userData.basket
        selectedStore = appState.value.userData.selectedStore.value
        
        // Setup
        setupBindToProfile(with: appState)
        setupSelectedChannel()
        setupProgressState()
        setupTempTodayTimeSlot(with: appState)
        setupAutoAssignASAPTimeSlot()
        setupBasket(with: appState)
        setupCheckFirstName()
        setupCheckLastName()
        setupCheckEmail()
        setupPhoneCheck()
        setupSelectedStore(with: appState)
        
        // Populate fields
        populateContactDetails(profile: memberProfile)
        
        self.proceedToDetails(profile: memberProfile)
    }
    
    // Setup basket
    private func setupBasket(with appState: Store<AppState>) {
        appState
            .map(\.userData.basket)
            .receive(on: RunLoop.main)
            .assignWeak(to: \.basket, on: self)
            .store(in: &cancellables)
    }
    
    // Set up temp time slot
    private func setupTempTodayTimeSlot(with appState: Store<AppState>) {
        $tempTodayTimeSlot
            .removeDuplicates()
            .sink { appState.value.userData.tempTodayTimeSlot = $0 }
            .store(in: &cancellables)
        
        appState
            .map(\.userData.tempTodayTimeSlot)
            .removeDuplicates()
            .sink(receiveValue: { [weak self] timeSlot in
                guard let self = self else { return }
                self.tempTodayTimeSlot = timeSlot
            })
            .store(in: &cancellables)
    }
    
    private func setupAutoAssignASAPTimeSlot() {
        $selectedRetailStoreFulfilmentTimeSlots
            .removeDuplicates()
            .receive(on: RunLoop.main)
            .sink { [weak self] timeSlots in
                guard let self = self else { return }
                if self.basket?.selectedSlot?.todaySelected == true, self.tempTodayTimeSlot == nil {
                    if let tempTimeSlot = timeSlots.value?.slotDays?.first?.slots?.first {
                        self.tempTodayTimeSlot = tempTimeSlot
                    }
                }
            }
            .store(in: &cancellables)
    }
    
    func setupSelectedStore(with appState: Store<AppState>) {
        appState
            .map(\.userData.selectedStore)
            .receive(on: RunLoop.main)
            .sink { [weak self] store in
                guard let self = self else { return }
                self.selectedStore = store.value
            }
            .store(in: &cancellables)
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
                self.memberProfile = profile
                
                if let profile = profile {
                    self.populateContactDetails(profile: profile)
                }
                
                self.proceedToDetails(profile: profile)
            }
            .store(in: &cancellables)
    }
    
    private func proceedToDetails(profile: MemberProfile?) {
        if self.checkoutState == .initial || self.checkoutState == .login || self.checkoutState == .createAccount {
            self.checkoutState = profile == nil ? .initial : .details // If we have a profile, then set the state to details
        }
    }
    
    // MARK: - Navigation control
    func backButtonPressed() {
        navigationDirection = .back
        switch checkoutState {
        case .initial:
            keepCheckoutFlowAlive = false // Dismiss checkout navigation stack
        case .login, .createAccount:
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
    
    func contactDetailsMissing() -> Bool {
        guard !firstname.isEmpty, !lastname.isEmpty, !email.isEmpty, !phoneNumber.isEmpty, email.isEmail else {
            setFieldWarnings()
            self.checkoutError = CheckoutRootViewError.missingDetails
            return true
        }
        
        return false
    }
    
    private func setFieldWarnings() {
        firstNameHasWarning = firstname.isEmpty
        lastnameHasWarning = lastname.isEmpty
        emailHasWarning = email.isEmpty || !email.isEmail
        phoneNumberHasWarning = phoneNumber.isEmpty
        
        self.newErrorsExist = true
    }
    
    // MARK: - Populate fields
    
    // Contact details
    private func populateContactDetails(profile: MemberProfile?) {
        // First we check the basket address. If this is present, we use this to perform field population
        if let basketAddresses = container.appState.value.userData.basket?.addresses,
           let basketAddress = basketAddresses.first(where: { $0.type == "billing" })
        {
            if firstname.isEmpty, let basketFirstName = basketAddress.firstName, !basketFirstName.isEmpty {
                self.firstname = basketFirstName
            } else if firstname.isEmpty, let profileFirstName = profile?.firstname {
                self.firstname = profileFirstName
            }
            
            if lastname.isEmpty, let basketLastName = basketAddress.lastName, !basketLastName.isEmpty {
                self.lastname = basketLastName
            } else if lastname.isEmpty, let profileLastname = profile?.lastname {
                self.lastname = profileLastname
            }
            
            if email.isEmpty, let basketEmail = basketAddress.email, !basketEmail.isEmpty {
                self.email = basketEmail
            } else if email.isEmpty, let profileEmail = profile?.emailAddress {
                self.email = profileEmail
            }
            
            if phoneNumber.isEmpty, let basketPhone = basketAddress.telephone, !basketPhone.isEmpty {
                self.phoneNumber = basketPhone
            } else if phoneNumber.isEmpty, let profilePhone = profile?.mobileContactNumber {
                self.phoneNumber = profilePhone
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
    
    private func areAllFieldsCompleteAndFreeFromErrors() -> Bool {
        firstNameHasWarning = firstname.isEmpty
        lastnameHasWarning = lastname.isEmpty
        emailHasWarning = email.isEmpty || !email.isEmail
        phoneNumberHasWarning = phoneNumber.isEmpty
        
        if fulfilmentType?.type == .delivery { // We omit the address check if fulfilmentType is collection
            return !firstNameHasWarning && !lastnameHasWarning && !emailHasWarning && !phoneNumberHasWarning && !slotIsEmpty
        }
        
        return !firstNameHasWarning && !lastnameHasWarning && !emailHasWarning && !phoneNumberHasWarning && !slotIsEmpty
    }
    
    #warning("Replace store location with one returned from basket addresses")
    private func checkAndAssignASAP() {
        if basket?.selectedSlot?.todaySelected == true, tempTodayTimeSlot == nil, let selectedStore = selectedStore {
            let todayDate = Date().trueDate
            
            if fulfilmentType?.type == .delivery, let fulfilmentLocation = container.appState.value.userData.searchResult.value?.fulfilmentLocation {
                container.services.retailStoresService.getStoreDeliveryTimeSlots(slots: loadableSubject(\.selectedRetailStoreFulfilmentTimeSlots), storeId: selectedStore.id, startDate: todayDate.startOfDay, endDate: todayDate.endOfDay, location: CLLocationCoordinate2D(latitude: CLLocationDegrees(Float(fulfilmentLocation.latitude)), longitude: CLLocationDegrees(Float(fulfilmentLocation.longitude))))
            } else if fulfilmentType?.type == .collection {
                container.services.retailStoresService.getStoreCollectionTimeSlots(slots: loadableSubject(\.selectedRetailStoreFulfilmentTimeSlots), storeId: selectedStore.id, startDate: todayDate.startOfDay, endDate: todayDate.endOfDay)
            } else {
                Logger.checkout.fault("'checkoutAndAssignASAP' failed - Fulfilment method: \(self.fulfilmentTypeString)")
            }
        } else {
            Logger.checkout.fault("'checkoutAndAssignASAP' failed checks")
        }
    }
    
    // MARK: - Form submit methods
    func goToPaymentTapped(setDelivery: @escaping () async throws -> (), updateMarketingPreferences: @escaping () async throws -> ()) async {
        isSubmitting = true
        
        // Check all fields errors
        guard areAllFieldsCompleteAndFreeFromErrors() else {
            checkoutError = CheckoutRootViewError.missingDetails
            isSubmitting = false
            return
        }
        
        if memberProfile == nil {
            if registrationChecked == false {
                do {
                    try await checkRegistrationStatus()
                    
                    if showOTPPrompt {
                        isSubmitting = false
                        return
                    }
                    
                    registrationChecked = true
                } catch {
                    self.checkoutError = error
                }
            }
        } else {
            registrationChecked = true
        }
        
        if registrationChecked {
            do {
                try await updateMarketingPreferences()
                
                try await setContactDetails()
                
                if fulfilmentType?.type == .delivery {
                    try await setDelivery()
                }
                self.checkAndAssignASAP()
                
                isSubmitting = false
                checkoutState = .paymentSelection
            } catch {
                isSubmitting = false
                #warning("Ideally we would set field errors here and scroll the the relevant section. However, with the API error codes unintuitive, this is not currently possible")
                if let error = error as? APIErrorResult {
                    self.checkoutError = error
                } else {
                    self.checkoutError = error
                }
            }
        }
    }
    
    func setContactDetails() async throws {
        guard contactDetailsMissing() == false else {
            self.checkoutError = CheckoutRootViewError.missingDetails
            throw CheckoutRootViewError.missingDetails
        }
        
        let contactDetailsRequest = BasketContactDetailsRequest(firstName: firstname, lastName: lastname, email: email, telephone: phoneNumber)
        
        try await self.container.services.basketService.setContactDetails(to: contactDetailsRequest)
    }
    
    // MARK: - Realtime field validation
    
    // Following methods fired onChange of their relative string values allowing us
    // to check for field errors in realtime
    
    func setupCheckFirstName() {
        $firstname
            .dropFirst()
            .sink { [weak self] firstname in
                guard let self = self else { return }
                self.firstNameHasWarning = firstname.isEmpty
            }
            .store(in: &cancellables)
    }
    
    func setupCheckLastName() {
        $lastname
            .dropFirst()
            .sink { [weak self] lastname in
                guard let self = self else { return }
                self.lastnameHasWarning = lastname.isEmpty
            }
            .store(in: &cancellables)
    }
    
    func setupCheckEmail() {
        $email
            .dropFirst()
            .sink { [weak self] email in
                guard let self = self else { return }
                self.emailHasWarning = email.isEmpty || email.isEmail == false
                
                self.showEmailInvalidWarning = !email.isEmail
            }
            .store(in: &cancellables)
    }
    
    func setupPhoneCheck() {
        $phoneNumber
            .dropFirst()
            .sink { [weak self] phone in
                guard let self = self else { return }
                self.phoneNumberHasWarning = phone.isEmpty
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Payment
    func payByCardTapped() {
        checkoutState = .card
    }
    
    func resetNewErrorsExist() {
        newErrorsExist = false
    }
    
    // MARK: - One Time Password
    private func checkRegistrationStatus() async throws {
        guard registrationChecked == false else { return }
        
        if let storeDetails = selectedStore, let memberEmailCheck = storeDetails.memberEmailCheck, memberEmailCheck {
            
            let result = try await container.services.userService.checkRegistrationStatus(email: email)
            
            otpTelephone = result.contacts?.first(where: { $0.type == .mobile })?.display ?? ""
            
            if result.loginRequired {
                showOTPPrompt = true
            }
        }
    }
    
    func dismissOTPPrompt() {
        showOTPPrompt = false
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
    
    func setCheckoutError(_ error: Swift.Error) {
        self.checkoutError = error
    }
}