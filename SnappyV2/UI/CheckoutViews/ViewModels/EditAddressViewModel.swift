//
//  EditAddressViewModel.swift
//  SnappyV2
//
//  Created by David Bage on 14/07/2022.
//

import Combine
import OSLog

@MainActor
class EditAddressViewModel: ObservableObject {
    // MARK: - General properties
    let container: DIContainer
    let addressType: AddressType
    var cancellables = Set<AnyCancellable>()
    private let fulfilmentLocation: String
    @Published var fieldErrorsPresent = false
    @Published var basket: Basket?

    @Published var firstNameText = ""
    @Published var firstNameHasWarning = false
    
    @Published var lastNameText = ""
    @Published var lastNameHasWarning = false
    
    @Published var emailText = ""
    @Published var emailHasWarning = false
    
    @Published var phoneText = ""
    @Published var phoneHasWarning = false
    
    @Published var postcodeText = ""
    @Published var postcodeHasWarning = false
    
    @Published var addressLine1Text = ""
    @Published var addressLine1HasWarning = false
    
    @Published var addressLine2Text = ""
    @Published var addressLine2HasWarning = false
    
    @Published var cityText = ""
    @Published var cityHasWarning = false
    
    @Published var countyText = ""
    @Published var countyHasWarning = false
    
    @Published var countryText = ""
    @Published var countryHasWarning = false
    
    // MARK: - General publishers
    @Published var memberProfile: MemberProfile?
    
    // MARK: - Address search publishers / properties
    @Published var searchingForAddresses = false
    @Published var showNoAddressesFoundError = false
    @Published var showMissingDetailsAlert = false
    @Published var showAddressSelector = false // triggers the postcode search view
    @Published var showSavedAddressSelector = false // triggers the saved address selection view
    @Published var settingAddress = false
    @Published var showEnterAddressManuallyError = false
    
    var foundAddresses: [FoundAddress]?
    var addressWarning: (title: String, body: String) = ("", "")
    
    // Following 2 are used when setting the billing address. We do not ask the user to complete email and phone
    // again as we have already gathered these when setting the contact details
    var deliveryEmail: String? {
        container.appState.value.userData.basket?.addresses?.first?.email
    }
    
    var deliveryPhone: String? {
        container.appState.value.userData.basket?.addresses?.first?.telephone
    }
    
    var fulfilmentType: RetailStoreOrderMethodType {
        container.appState.value.userData.selectedFulfilmentMethod
    }
    
    // MARK: - Country selection
    @Published var selectedCountry: AddressSelectionCountry?
    @Published var selectionCountriesRequest: Loadable<[AddressSelectionCountry]?> = .notRequested
    @Published var selectionCountries = [AddressSelectionCountry]()
    
    // MARK: - Saved address selector
    var savedAddresses: [Address]? {
        guard let profile = memberProfile, let addresses = profile.savedAddresses else { return nil }
        
        let savedAddresses = addresses.filter { $0.type == (addressType == .delivery ? .delivery : .billing) }
        
        if savedAddresses.count > 0 {
            return savedAddresses
        }
        
        return nil
    }

    // MARK: - Billing-specific publishers
    @Published var useSameBillingAddressAsDelivery: Bool
    
    // MARK: - Computed variables
    var userLoggedIn: Bool {
        container.appState.value.userData.memberProfile != nil
    }

    // MARK: - Initialisation
    init(container: DIContainer, firstName: String? = nil, addressType: AddressType) {
        self.container = container
        let appState = container.appState
        self._memberProfile = .init(initialValue: appState.value.userData.memberProfile)
        self.fulfilmentLocation = self.container.appState.value.userData.currentFulfilmentLocation?.country ?? AppV2Constants.Business.operatingCountry
        self._basket = .init(initialValue: self.container.appState.value.userData.basket)
        self._useSameBillingAddressAsDelivery = .init(initialValue: appState.value.userData.selectedFulfilmentMethod == .delivery)
        
        self.addressType = addressType
        
        setupBindToProfile(with: appState)
        setupBindToBasket(with: appState)
        
        getCountries()
        setupSelectionCountries()
        setupSelectedCountry()
        setupBasket()
        
        if addressType == .billing {
            populateContactFields()
        }
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
    
    private func setupBasket() {
        $basket
            .receive(on: RunLoop.main)
            .sink { [weak self] basket in
                guard let self = self else { return }
                self.populateFields(profile: self.memberProfile)
            }
            .store(in: &cancellables)
    }
    
    private func setupBindToBasket(with appState: Store<AppState>) {
        appState
            .map(\.userData.basket)
            .assignWeak(to: \.basket, on: self)
            .store(in: &cancellables)
    }

    
    // MARK: - Populate fields
    private func populateFields(profile: MemberProfile?) {
        if addressType == .billing {
            populateBillingAddressFields()
        } else {
            populateDeliveryAddressFields(profile: profile)
        }
    }
    
    // Contact fields
    private func populateContactFields() {
        guard let memberProfile = memberProfile else { return }
        
        firstNameText = memberProfile.firstname
        lastNameText = memberProfile.lastname
    }
    
    // Billing address fields
    private func populateBillingAddressFields() {
        if let billingAddress = container.appState.value.userData.basket?.addresses?.first(where: { $0.type == "billing" }) {
            self.postcodeText = billingAddress.postcode
            
            self.addressLine1Text = billingAddress.addressLine1 ?? ""
            
            self.addressLine2Text = billingAddress.addressLine2 ?? ""
            
            self.cityText = billingAddress.town
            
            self.countyText = billingAddress.county ?? ""
            
            if let country = selectionCountries.first(where: { $0.countryCode == billingAddress.countryCode }) {
                self.countryText = country.countryName
            }
        }
    }
    
    // Delivery address fields
    private func populateDeliveryAddressFields(profile: MemberProfile?) {
        // If there are saved addresses in the basket, use the first one
        if let basketAddresses = container.appState.value.userData.basket?.addresses,
           basketAddresses.count > 0
        {
            guard let basketAddress = basketAddresses.first(where: { $0.type == "delivery" }) else { return }
            
            self.postcodeText = basketAddress.postcode
            
            self.addressLine1Text = basketAddress.addressLine1 ?? ""
            
            self.addressLine2Text = basketAddress.addressLine2 ?? ""
            
            self.cityText = basketAddress.town
            
            self.countyText =  basketAddress.county ?? ""
            
            if countryText.isEmpty {
                self.selectedCountry = selectionCountries.first(where: { $0.countryCode == fulfilmentLocation })
            } else {
                self.selectedCountry = selectionCountries.first(where: { $0.countryName == countryText })
            }

            return
        }
        
        // Otherwise check the user has saved addresses on their profile and use the default one
        
        guard let profile = profile, let savedAddress = profile.savedAddresses else { return }
        
        let defaultAddresses = savedAddress.filter { $0.isDefault == true }
        
        if let defautltDeliveryAddress = defaultAddresses.first(where: { $0.type == .delivery }) {
            self.postcodeText = defautltDeliveryAddress.postcode
            self.addressLine1Text = defautltDeliveryAddress.addressLine1
            self.addressLine2Text = defautltDeliveryAddress.addressLine2 ?? ""
            self.cityText = defautltDeliveryAddress.town
            self.countyText = defautltDeliveryAddress.county ?? ""
        }
    }
    
    // MARK: - Country methods
    private func getCountries() {
        self.container.services.addressService.getSelectionCountries(countries: self.loadableSubject(\.selectionCountriesRequest))
    }
    
    private func setupSelectionCountries() {
        $selectionCountriesRequest
            .map { result in
                return result.value
            }
            .replaceNil(with: [])
            .receive(on: RunLoop.main)
            .sink { [weak self] countries in
                guard let self = self, let countries = countries else { return }
                self.selectionCountries = countries
                
                // Set default country if we have it stored in the userData
                
                self.selectedCountry = countries.filter { $0.countryCode == self.fulfilmentLocation }.first
            }
            .store(in: &cancellables)
    }
    
    private func setupSelectedCountry() {
        $selectedCountry
            .receive(on: RunLoop.main)
            .sink { [weak self] country in
                guard let self = self, let country = country else { return }
                self.countryText = country.countryName
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Address selector methods
    func findByPostcodeTapped(contactDetailsPresent: Bool) async {
        // Check if postcode is empty. If it is, return early and present error. This means we can avoid hitting the endpoint in these cases.
        guard contactDetailsPresent else {
            self.showMissingDetailsAlert = true
            return
        }

        // If we are here, then we reset postcodeHasWarningToFalse and begin search
        postcodeHasWarning = false
        searchingForAddresses = true
        
        do {
            try await foundAddresses = container.services.addressService.findAddressesAsync(postcode: postcodeText, countryCode: fulfilmentLocation)
            
            if let foundAddresses = foundAddresses, foundAddresses.count > 0 {
                self.showAddressSelector = true
            } else {
                self.postcodeHasWarning = true
                self.showNoAddressesFoundError = true
            }
            
            searchingForAddresses = false
            
        } catch {
            searchingForAddresses = false
            setAddressWarning(error: (
                Strings.CheckoutDetails.EditAddress.noAddresses.localized,
                error.localizedDescription))
        }
    }
    
    // Populate address warning body
    private func setAddressWarning(error: (title: String, body: String)) {
        addressWarning = (error.title, error.body)
        showNoAddressesFoundError = true
        postcodeHasWarning = true
    }
    
    // Select country
    func countrySelected(_ country: AddressSelectionCountry) {
        self.selectedCountry = country
    }
    
    func setAddress(firstName: String? = nil, lastName: String? = nil, email: String? = nil, phone: String? = nil) async throws {
        self.settingAddress = true
        
        let deliveryAddress = container.appState.value.userData.basket?.addresses?.first(where: { $0.type == "delivery" })
        
        let billingSameAsDeliveryAddressRequest = BasketAddressRequest(
            firstName: deliveryAddress?.firstName ?? "",
            lastName: deliveryAddress?.lastName ?? "",
            addressLine1: deliveryAddress?.addressLine1 ?? "",
            addressLine2: deliveryAddress?.addressLine2 ?? "",
            town: deliveryAddress?.town ?? "",
            postcode: deliveryAddress?.postcode ?? "",
            countryCode: selectedCountry?.countryCode ?? "",
            type: AddressType.billing.rawValue,
            email: email ?? emailText,
            telephone: phone ?? phoneText,
            state: nil,
            county: deliveryAddress?.county ?? "",
            location: nil
        )
        
        let basketAddressRequest = BasketAddressRequest(
            firstName: firstName ?? firstNameText,
            lastName: lastName ?? lastNameText,
            addressLine1: addressLine1Text,
            addressLine2: addressLine2Text,
            town: cityText,
            postcode: postcodeText,
            countryCode: selectedCountry?.countryCode ?? "",
            type: addressType == .billing ? AddressType.billing.rawValue : AddressType.delivery.rawValue,
            email: email ?? emailText,
            telephone: phone ?? phoneText,
            state: nil,
            county: countyText,
            location: nil
        )
        
        do {
            if addressType == .delivery {
                try await container.services.basketService.setDeliveryAddress(to: basketAddressRequest)
            } else {
                try await container.services.basketService.setBillingAddress(to: useSameBillingAddressAsDelivery ? billingSameAsDeliveryAddressRequest : basketAddressRequest)
            }
            
            self.settingAddress = false
            Logger.checkout.info("Successfully added delivery address")
            
        } catch {
            Logger.checkout.error("Failure to set delivery address - \(error.localizedDescription)")
            
            if addressType == .billing {
                showEnterAddressManuallyError = true
                useSameBillingAddressAsDelivery = false
            }
            
            self.settingAddress = false
            throw error
        }
    }
    
    func fieldsHaveErrors() -> Bool {
        postcodeHasWarning = postcodeText.isEmpty
        addressLine1HasWarning = addressLine1Text.isEmpty
        cityHasWarning = cityText.isEmpty
        countryHasWarning = countryText.isEmpty
        
        if addressType == .billing {
            firstNameHasWarning = firstNameText.isEmpty
            lastNameHasWarning = lastNameText.isEmpty
            
            if postcodeHasWarning || addressLine1HasWarning || cityHasWarning || countryHasWarning || firstNameHasWarning || lastNameHasWarning {
                fieldErrorsPresent = true
                showMissingDetailsAlert = true
                return true
            }
        } else {
            if postcodeHasWarning || addressLine1HasWarning || cityHasWarning || countryHasWarning {
                fieldErrorsPresent = true
                return true
            }
        }
        
        fieldErrorsPresent = false
        return false
    }
    
    func resetFieldErrorsPresent() {
        fieldErrorsPresent = false
    }
    
    
    func checkField(stringToCheck: String, fieldHasWarning: inout Bool) {
        fieldHasWarning = stringToCheck.isEmpty
    }
}
