//
//  EditAddressViewModel.swift
//  SnappyV2
//
//  Created by David Bage on 14/07/2022.
//

import SwiftUI
import Combine
import OSLog

@MainActor
class EditAddressViewModel: ObservableObject {
    // MARK: - Addressfield class
    class AddressField: ObservableObject {
        @Published var textValue = ""
        @Published var hasWarning = false
        
        func checkValidity() {
            hasWarning = textValue.isEmpty
        }
    }
    
    // MARK: - General properties
    let container: DIContainer
    let addressType: AddressType
    var cancellables = Set<AnyCancellable>()
    private let fulfilmentLocation: String
    
    // MARK: - Fields
    var firstNameField = AddressField()
    var lastNameField = AddressField()
    var postcodeField = AddressField()
    var addressLine1Field = AddressField()
    var addressLine2Field = AddressField()
    var cityField = AddressField()
    var countyField = AddressField()
    var countryField = AddressField()
    
    // We need email and phone is order to set delivery address. As they are not part
    // of this form, we pass them into the viewModel here and they are not optional
    let firstName: String?
    let lastName: String?
    let email: String
    let phone: String
    
    // MARK: - General publishers
    @Published var memberProfile: MemberProfile?
    
    // MARK: - Address search publishers / properties
    @Published var searchingForAddresses = false
    @Published var showNoAddressesFoundError = false
    @Published var showAddressSelector = false // triggers the postcode search view
    @Published var showSavedAddressSelector = false // triggers the saved address selection view
    @Published var settingAddress = false
    
    var foundAddresses: [FoundAddress]?
    var addressWarning: (title: String, body: String) = ("", "")
    
    // MARK: - Country selection
    @Published var selectedCountry: AddressSelectionCountry?
    @Published var selectionCountriesRequest: Loadable<[AddressSelectionCountry]?> = .notRequested
    private(set) var selectionCountries = [AddressSelectionCountry]()
    
    // MARK: - Saved address selector
    var savedAddresses: [Address]? {
        guard let profile = memberProfile, let addresses = profile.savedAddresses else { return nil }
        
        let deliveryAddresses = addresses.filter { $0.type == (addressType == .delivery ? .delivery : .billing) }
        
        if deliveryAddresses.count > 0 {
            return deliveryAddresses
        }
        
        return nil
    }

    // MARK: - Billing-specific publishers
    @Published var useSameBillingAddressAsDelivery = true
    
    // MARK: - Initialisation
    init(container: DIContainer, firstName: String? = nil, lastName: String? = nil, email: String, phone: String, addressType: AddressType) {
        self.container = container
        let appState = container.appState
        self._memberProfile = .init(initialValue: appState.value.userData.memberProfile)
        self.fulfilmentLocation = self.container.appState.value.userData.currentFulfilmentLocation?.country ?? AppV2Constants.Business.operatingCountry
        self.email = email
        self.phone = phone
        self.addressType = addressType
        self.firstName = firstName
        self.lastName = lastName
        
        setupBindToProfile(with: appState)
        setupMemberProfile()
        
        getCountries()
        setupSelectionCountries()
        setupSelectedCountry()
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
                guard let profile = profile else { return }
                
                self.populateFields(profile: profile) // Populate contact and address fields with relevant values from profile
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Populate fields
    private func populateFields(profile: MemberProfile) {
        if addressType == .billing {
            populateContactFields()
            populateBillingAddressFields()
        } else {
            populateDeliveryAddressFields(profile: profile)
        }
    }
    
    // Contact fields
    private func populateContactFields() {
        guard let memberProfile = memberProfile else { return }
        
        firstNameField.textValue = memberProfile.firstname
        lastNameField.textValue = memberProfile.lastname
    }
    
    // Billing address fields
    private func populateBillingAddressFields() {
        if let billingAddress = container.appState.value.userData.basket?.addresses?.first(where: { $0.type == "billing" }) {
            self.postcodeField.textValue = billingAddress.postcode
            self.addressLine1Field.textValue = billingAddress.addressLine1 ?? ""
            self.addressLine2Field.textValue = billingAddress.addressLine2 ?? ""
            self.cityField.textValue = billingAddress.town
            self.countyField.textValue = billingAddress.county ?? ""
            
            if let country = selectionCountries.first(where: { $0.countryCode == billingAddress.countryCode }) {
                self.countryField.textValue = country.countryName
            }
        }
    }
    
    // Delivery address fields
    private func populateDeliveryAddressFields(profile: MemberProfile) {
        // If there are saved addresses in the basket, use the first one
        if let basketAddresses = container.appState.value.userData.basket?.addresses,
           basketAddresses.count > 0
        {
            guard let basketAddress = basketAddresses.first(where: { $0.type == "delivery" }) else { return }
            
            self.postcodeField.textValue = basketAddress.postcode
            self.addressLine1Field.textValue = basketAddress.addressLine1 ?? ""
            self.addressLine2Field.textValue = basketAddress.addressLine2 ?? ""
            self.cityField.textValue = basketAddress.town
            self.countyField.textValue = basketAddress.county ?? ""
            
            if countryField.textValue.isEmpty {
                self.selectedCountry = selectionCountries.first(where: { $0.countryCode == basketAddress.countryCode })
            } else {
                self.selectedCountry = selectionCountries.first(where: { $0.countryName == countryField.textValue })
            }
            
            if let selectedCountry = selectedCountry {
                self.countryField.textValue = selectedCountry.countryName
            }
            
            return
        }
        
        // Otherwise check the user has saved addresses on their profile and use the default one
        guard let savedAddress = profile.savedAddresses else { return }
        
        let defaultAddresses = savedAddress.filter { $0.isDefault == true }
        
        if let defautltDeliveryAddress = defaultAddresses.first(where: { $0.type == .delivery }) {
            self.postcodeField.textValue = defautltDeliveryAddress.postcode
            self.addressLine1Field.textValue = defautltDeliveryAddress.addressLine1
            self.addressLine2Field.textValue = defautltDeliveryAddress.addressLine2 ?? ""
            self.cityField.textValue = defautltDeliveryAddress.town
            self.countyField.textValue = defautltDeliveryAddress.county ?? ""
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
                self.countryField.textValue = country.countryName
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Address selector methods
    func findByPostcodeTapped() async {
        // Check if postcode is empty. If it is, return early and present error. This means we can avoid hitting the endpoint in these cases.
        guard postcodeField.textValue.isEmpty == false else {
            setAddressWarning(error: (
                Strings.CheckoutDetails.EditAddress.noPostcodeErrorTitle.localized,
                Strings.CheckoutDetails.EditAddress.noPostcodeErrorSubtitle.localized))
            return
        }
        
        // If we are here, then we reset postcodeHasWarningToFalse and begin search
        postcodeField.hasWarning = false
        searchingForAddresses = true
        
        do {
            try await foundAddresses = container.services.addressService.findAddressesAsync(postcode: postcodeField.textValue, countryCode: fulfilmentLocation)
            
            if let foundAddresses = foundAddresses, foundAddresses.count > 0 {
                self.showAddressSelector = true
            } else {
                self.postcodeField.hasWarning = true
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
        postcodeField.hasWarning = true
    }
    
    // Select country
    func countrySelected(_ country: AddressSelectionCountry) {
        self.selectedCountry = country
    }
    
    func setAddress() async throws {
        self.settingAddress = true
        
        let basketAddressRequest = BasketAddressRequest(
            firstName: firstName ?? firstNameField.textValue,
            lastName: lastName ?? lastNameField.textValue,
            addressLine1: addressLine1Field.textValue,
            addressLine2: addressLine2Field.textValue,
            town: cityField.textValue,
            postcode: postcodeField.textValue,
            countryCode: selectedCountry?.countryCode ?? "",
            type: AddressType.delivery.rawValue,
            email: email,
            telephone: phone,
            state: nil,
            county: countyField.textValue,
            location: nil
        )
        
        do {
            if addressType == .delivery {
                try await container.services.basketService.setDeliveryAddress(to: basketAddressRequest)
            } else {
                try await container.services.basketService.setBillingAddress(to: basketAddressRequest)
            }
            
            self.settingAddress = false
            Logger.checkout.info("Successfully added delivery address")
            
        } catch {
            Logger.checkout.error("Failure to set delivery address - \(error.localizedDescription)")
            
            self.settingAddress = false
            throw error
        }
    }
    
    private func setAllAddressFieldsAsError() {
        addressLine1Field.hasWarning = true
        addressLine2Field.hasWarning = true
        cityField.hasWarning = true
        countyField.hasWarning = true
        countryField.hasWarning = true
    }
}
