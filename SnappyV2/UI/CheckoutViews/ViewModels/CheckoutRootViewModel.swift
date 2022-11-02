//
//  CheckoutRootViewModel.swift
//  SnappyV2
//
//  Created by David Bage on 07/07/2022.
//

import Foundation
import Combine
import OSLog
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
        
    // MARK: - Checkout root view state control
    enum CheckoutState {
        case initial
        case login
        case createAccount
        case details
        case paymentSelection
        case card
        case paymentSuccess
        
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
            }
        }
    }
    
    enum DetailsFormElements {
        case retailMembershipId
        case firstName
        case lastName
        case email
        case phone
        case deliveryAddress
        case postcode
        case addressLine1
        case city
        case country
        case timeSlot
        case whereDidYouHear
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
    private var checkRetailMembershipIdTask: Task<Void, Never>?
    let container: DIContainer
    
    // MARK: - Progress state properties
    var maxProgress: Double {
        Double(progressState.maxValue)
    }
    
    var firstError: DetailsFormElements? {
        if retailMembershipIdHasWarning {
            return DetailsFormElements.retailMembershipId
        } else if firstNameHasWarning {
            return DetailsFormElements.firstName
        } else if lastnameHasWarning {
            return DetailsFormElements.lastName
        } else if emailHasWarning {
            return DetailsFormElements.email
        } else if phoneNumberHasWarning {
            return DetailsFormElements.phone
        } else if postcodeHasWarning {
            return DetailsFormElements.postcode
        } else if addressLine1HasWarning {
            return DetailsFormElements.addressLine1
        } else if cityHasWarning {
            return DetailsFormElements.city
        } else if timeSlotHasWarning {
            return DetailsFormElements.timeSlot
        } else if selectedChannelHasWarning {
            return DetailsFormElements.whereDidYouHear
        }
        return nil
    }
    
    var currentProgress: Double {
        if Double(progressState.rawValue) > maxProgress {
            return maxProgress
        }
        return Double(progressState.rawValue)
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
    #warning("Need to add *proper* phone number validation with country codes, but this requires API work")
    @Published var phoneNumber = ""
    
    // Delivery note
    @Published var deliveryNote = ""
    
    // MARK: - Error handling
    
    @Published var newErrorsExist = false // We use this boolean to trigger the onChange event in the main view to scroll to the contact section if field errors are detected
    
    @Published var firstNameHasWarning = false
    
    @Published var lastnameHasWarning = false
    
    @Published var emailHasWarning = false
    
    @Published var phoneNumberHasWarning = false
    
    @Published var timeSlotHasWarning = false
    
    @Published var showFormSubmissionError = false
    
    @Published var selectedChannelHasWarning = false
    
    @Published var postcodeHasWarning = false
    @Published var addressLine1HasWarning = false
    @Published var cityHasWarning = false
    
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
    @Published var hideSelectedChannel: Bool = false
    
    // Retail Membership
    private var fetchedRetailMembershipResult: CheckRetailMembershipIdResult?
    @Published var showRetailMembership = false
    @Published var retailMembershipId = ""
    @Published var retailMembershipIdHasWarning = false
    
    // Submitting form - to control loading state
    @Published var isLoading = false
    @Published var isSubmitting = false
    
    var orderTotalPriceString: String? {
        guard
            let orderTotal = container.appState.value.userData.basket?.orderTotal,
            let currency = container.appState.value.userData.selectedStore.value?.currency
        else {
            return nil
        }
        return orderTotal.toCurrencyString(using: currency)
    }

    private func setupSlotError(with appState: Store<AppState>) {
        appState
            .map(\.userData.basket?.selectedSlot)
            .receive(on: RunLoop.main)
            .sink { [weak self] slot in
                guard let self = self else { return }
                self.timeSlotHasWarning = (slot?.start == nil && slot?.todaySelected == nil)
            }
            .store(in: &cancellables)
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
        //Filter the marketing channels so we only get entries which begin with an "ios" string
        if let channels = container.appState.value.userData.selectedStore.value?.allowedMarketingChannels.filter({$0.name.lowercased().contains("ios")}),
            channels.count > 0 {
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
        } else if let basketSlot = container.appState.value.userData.basket?.selectedSlot, basketSlot.start == nil, (basketSlot.todaySelected == nil || basketSlot.todaySelected == false) {
            return Strings.CheckoutDetails.ChangeFulfilmentMethod.noSlot.localized
        } else if fulfilmentType?.type == .delivery {
            return Strings.CheckoutDetails.ChangeFulfilmentMethodCustom.slotTimeDelivery.localizedFormat(slotString)
        }
        return Strings.CheckoutDetails.ChangeFulfilmentMethodCustom.slotTimeCollection.localizedFormat(slotString)
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
    
    var showRetailMembershipIdWarning: Bool {
        return selectedStore?.retailCustomer?.hasMembership ?? false
    }
    
    var retailMembershipIdName: String {
        return selectedStore?.retailCustomer?.membershipIdFieldPlaceholder ?? ""
    }
    
    var retailMembershipIdInstructions: String {
        return selectedStore?.retailCustomer?.membershipIdPromptText ?? ""
    }
    
    var userConfirmedSelectedChannelKey = "userConfirmedSelectedChannel"
    
    // MARK: - Init
    init(container: DIContainer) {
        self.container = container
        let appState = container.appState
        self._memberProfile = .init(initialValue: appState.value.userData.memberProfile)
        self.checkoutState = .initial
        self._progressState = .init(initialValue: .notStarted)
        self._tempTodayTimeSlot = .init(initialValue: appState.value.userData.tempTodayTimeSlot)
        basket = appState.value.userData.basket
        selectedStore = appState.value.userData.selectedStore.value
        
        // Setup
        setupBindToProfile(with: appState)
        setupSelectedChannel()
        setupProgressStateAndTrigerEvents()
        setupTempTodayTimeSlot(with: appState)
        setupAutoAssignASAPTimeSlot()
        setupBasket(with: appState)
        setupCheckFirstName()
        setupCheckLastName()
        setupCheckEmail()
        setupPhoneCheck()
        setupSelectedStore(with: appState)
        setupSlotError(with: appState)
        setupSelectedChannelError()
        setupSelectedChannelVisiblity()
        
        // Populate fields
        populateContactDetails(profile: memberProfile)
        
        self.proceedToDetails(profile: memberProfile)
    }
    
    deinit {
        checkRetailMembershipIdTask?.cancel()
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
            .receive(on: RunLoop.main)
            .sink { appState.value.userData.tempTodayTimeSlot = $0 }
            .store(in: &cancellables)
        
        appState
            .map(\.userData.tempTodayTimeSlot)
            .removeDuplicates()
            .receive(on: RunLoop.main)
            .sink { [weak self] timeSlot in
                guard let self = self else { return }
                self.tempTodayTimeSlot = timeSlot
            }
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
    
    private func setupProgressStateAndTrigerEvents() {
        $checkoutState
            .removeDuplicates()
            .receive(on: RunLoop.main)
            .sink { [weak self] state in
                guard let self = self else { return }
                self.sendCheckoutReachedStateEvent(for: state)
                self.progressState = state.progress
            }
            .store(in: &cancellables)
    }
    
    private func sendCheckoutReachedStateEvent(for state: CheckoutState) {
        switch state {
        case .details:
            container.eventLogger.sendEvent(for: .viewScreen(.in, .customerDetails), with: .firebaseAnalytics, params: [:])
        case .paymentSelection:
            container.eventLogger.sendEvent(for: .viewScreen(.in, .paymentOptions), with: .firebaseAnalytics, params: [:])
        default:
            break
        }
    }
    
    // MARK: - Profile binding
    private func setupBindToProfile(with appState: Store<AppState>) {
        appState
            .map(\.userData.memberProfile)
            .removeDuplicates()
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
    
    private func checkRetailMembershipId() {
        if
            let selectedStore = selectedStore,
            let retailCustomer = selectedStore.retailCustomer,
            retailCustomer.hasMembership
        {
            isLoading = true
            showRetailMembership = false
            checkRetailMembershipIdTask = Task { @MainActor in
                do {
                    fetchedRetailMembershipResult = try await container.services.memberService.checkRetailMembershipId()
                    if
                        let fetchedRetailMembershipResult = fetchedRetailMembershipResult,
                        fetchedRetailMembershipResult.retailerHasMembership,
                        fetchedRetailMembershipResult.placedOrdersWithRetailerMembership == 0
                    {
                        showRetailMembership = true
                        retailMembershipId = fetchedRetailMembershipResult.retailerMembershipId ?? ""
                    }
                    isLoading = false
                } catch {
                    // Retail Membership field capture is extremely low priority, so if there is some sort of
                    // failure checking with our server do not display the error nor offer any retry functionality.
                    // Instead the field is simply not displayed rather than interrupt checkout.
                    isLoading = false
                    Logger.checkout.error("checkRetailMembershipId error: \(error.localizedDescription)")
                }
            }
        }
    }
    
    private func proceedToDetails(profile: MemberProfile?) {
        if checkoutState == .initial || checkoutState == .login || checkoutState == .createAccount {
            // If we have a profile, then set the state to details
            if profile == nil {
                checkoutState = .initial
            } else {
                checkRetailMembershipId()
                checkoutState = .details
            }
        }
    }
    
    // MARK: - Navigation control
    func backButtonPressed(dismissView: () -> Void) {
        navigationDirection = .back
        switch checkoutState {
        case .initial:
            dismissView()
        case .login, .createAccount:
            checkoutState = .initial
        case .details:
            if memberProfile == nil {
                checkoutState = .initial
            } else {
                dismissView()
            }
            
        case .card:
            checkoutState = .paymentSelection
        case .paymentSelection:
            if memberProfile != nil {
                checkRetailMembershipId()
            }
            checkoutState = .details
        case .paymentSuccess:
            return // Do not allow backwards navigation at this point
        }
    }
    
    // MARK: - Simple navigation methods
    func guestCheckoutTapped() {
        navigationDirection = .forward
        checkoutState = .details
        container.eventLogger.sendEvent(for: .checkoutAsGuestChosen, with: .firebaseAnalytics, params: [:])
    }
    
    func loginToAccountTapped() {
        navigationDirection = .forward
        checkoutState = .login
    }
    
    func createAccountTapped() {
        navigationDirection = .forward
        checkoutState = .createAccount
        container.eventLogger.sendEvent(for: .checkoutAsNewMemberChosen, with: .firebaseAnalytics, params: [:])
    }
    
    // MARK: - Field error setting
    
    func contactDetailsMissing() -> Bool {
        guard !firstname.isEmpty, !lastname.isEmpty, !email.isEmpty, !phoneNumber.isEmpty, email.isEmail else {
            setFieldWarnings()
            return true
        }
        
        return false
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
    
    private func areAllFieldsCompleteAndFreeFromErrors(editAddressFieldErrors: [DetailsFormElements]) -> Bool {
        firstNameHasWarning = firstname.isEmpty
        lastnameHasWarning = lastname.isEmpty
        emailHasWarning = email.isEmpty || !email.isEmail
        phoneNumberHasWarning = phoneNumber.isEmpty
        
        let userDefaults = UserDefaults.standard
        if !userDefaults.bool(forKey: userConfirmedSelectedChannelKey) {
            //Only check for selected channel if user has never confirmed it in the past
            selectedChannelHasWarning = (selectedChannel == nil)
        } else {
            selectedChannelHasWarning = false
        }
                
        postcodeHasWarning = editAddressFieldErrors.contains(.postcode)
        addressLine1HasWarning = editAddressFieldErrors.contains(.addressLine1)
        cityHasWarning = editAddressFieldErrors.contains(.city)
        retailMembershipIdHasWarning = false
        
        if fulfilmentType?.type == .delivery { // We omit the address check if fulfilmentType is collection
            return !firstNameHasWarning && !lastnameHasWarning && !emailHasWarning && !phoneNumberHasWarning && !timeSlotHasWarning && !selectedChannelHasWarning && editAddressFieldErrors.isEmpty
        }
        
        //should editAddressFieldErrors.isEmpty be removed from the below?
        return !firstNameHasWarning && !lastnameHasWarning && !emailHasWarning && !phoneNumberHasWarning && !timeSlotHasWarning && !selectedChannelHasWarning && editAddressFieldErrors.isEmpty
    }
    
    func setupSelectedChannelVisiblity() {
        UserDefaults.standard
            .publisher(for: \.userConfirmedSelectedChannel)
            .handleEvents(receiveOutput: { [weak self] channelVisibilityStatus in
                guard let self = self else { return }
                print("Setting hideSelectedChannel status to \(channelVisibilityStatus)")
                self.hideSelectedChannel = channelVisibilityStatus
            })
            .sink { _ in }
            .store(in: &cancellables)
    }
    
    func setUserConfirmedSelectedChannel() {
        let userDefaults = UserDefaults.standard
        if !userDefaults.bool(forKey: userConfirmedSelectedChannelKey) {
            userDefaults.userConfirmedSelectedChannel = true
        }
    }
    
    func setError(_ err: Error) {
        container.appState.value.errors.append(err)
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
    func goToPaymentTapped(editAddressFieldErrors: [DetailsFormElements], setDelivery: @escaping () async throws -> (), updateMarketingPreferences: @escaping () async throws -> ()) async {
        isSubmitting = true
        newErrorsExist = false
        
        // Check all fields errors
        guard areAllFieldsCompleteAndFreeFromErrors(editAddressFieldErrors: editAddressFieldErrors) else {
            newErrorsExist = true
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
                    self.setError(error)
                }
            }
        } else {
            registrationChecked = true
            if showRetailMembership {
                let trimmedRetailMembershipId = retailMembershipId.trimmingCharacters(in: .whitespacesAndNewlines)
                // update any trimmed characters in the displayed field
                if trimmedRetailMembershipId != retailMembershipId {
                    guaranteeMainThread { [weak self] in
                        guard let self = self else { return }
                        self.retailMembershipId = trimmedRetailMembershipId
                    }
                }
                let previousRetailMembership = fetchedRetailMembershipResult?.retailerMembershipId ?? ""
                // only save the field if it has changed
                if trimmedRetailMembershipId != previousRetailMembership {
                    do {
                        try await container.services.memberService.storeRetailMembershipId(retailMemberId: trimmedRetailMembershipId)
                    } catch {
                        Logger.checkout.error("storeRetailMembershipId error: \(error.localizedDescription)")
                        retailMembershipIdHasWarning = true
                        setError(error)
                        isSubmitting = false
                        return
                    }
                }
            }
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
                
                let userDefaults = UserDefaults.standard
                if !userDefaults.bool(forKey: userConfirmedSelectedChannelKey) {
                    userDefaults.set(true, forKey: userConfirmedSelectedChannelKey)
                }
                
            } catch {
                isSubmitting = false
                #warning("Ideally we would set field errors here and scroll the the relevant section. However, with the API error codes unintuitive, this is not currently possible")
                if let error = error as? APIErrorResult {
                    self.setError(error)
                } else {
                    self.setError(error)
                }
            }
        }
    }
    
    func setContactDetails() async throws {
        guard contactDetailsMissing() == false else {
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
                
                self.showEmailInvalidWarning = !email.isEmail && !email.isEmpty
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
    
    func setupSelectedChannelError() {
        $selectedChannel
            .dropFirst()
            .receive(on: RunLoop.main)
            .map { $0 == nil }
            .sink { [weak self] channelSelected in
                guard let self = self else { return }
                self.selectedChannelHasWarning = channelSelected
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
            
            let result = try await container.services.memberService.checkRegistrationStatus(email: email)
            
            otpTelephone = result.contacts?.first(where: { $0.type == .mobile })?.display ?? ""
            
            if result.loginRequired {
                showOTPPrompt = true
                
                let params: [String: Any] = [
                    "smsPossible": otpTelephone.isEmpty == false
                ]
                container.eventLogger.sendEvent(for: .otpPresented, with: .appsFlyer, params: params)
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
    
    func filterPhoneNumber(newValue: String) {
        let filtered = newValue.filter { "0123456789+".contains($0) }
        if filtered != newValue {
            self.phoneNumber = filtered
        }
    }
    
    func noErrors() -> Bool {
        return !firstNameHasWarning && !lastnameHasWarning && !emailHasWarning && !phoneNumberHasWarning
    }
    
    func setCheckoutState(state: CheckoutRootViewModel.CheckoutState) {
        self.checkoutState = state
    }
}
