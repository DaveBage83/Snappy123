//
//  AddressSelectionViewModel.swift
//  SnappyV2
//
//  Created by David Bage on 11/07/2022.
//

import SwiftUI // Required for @Binding variable
import OSLog
import Combine

@MainActor
class AddressSelectionViewModel: ObservableObject {
    // MARK: - Publishers
    @Published var addresses = [FoundAddress]()
    @Published var postcode = ""
    @Published var postcodeHasError = false
    @Published var selectedAddress: FoundAddress?
    @Published var settingDeliveryAddress = false
    @Published var showNoSelectedAddressError = false
    @Published var showDeliveryAddressSetterError = false
    @Published var searchingForAddresses = false
    @Published var showManualAddressView = false
    
    var tempPostcode = "" // Used to present searched text in 'no addresses found' view without binding to current field value
        
    // MARK: - Binding
    @Binding var showAddressSelectionView: Bool
    @Published var addressSelectionError: Swift.Error?

    // MARK: - Properties
    let container: DIContainer
    var addressSetterError: String?
    private let email: String
    private let phone: String
    private let firstName: String
    private let lastName: String
    let addressSelectionType: AddressType
    private let fulfilmentLocation: String
    let isInCheckout: Bool
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Nav title
    // Varies depending on whether we are setting billing or delivery
    var navTitle: String {
        self.addressSelectionType == .delivery ? Strings.CheckoutDetails.AddressSelectionView.navTitle.localized : Strings.CheckoutDetails.AddressSelectionView.selectBilling.localized
    }
    
    var showEnterAddressManuallyButton: Bool {
        isInCheckout == false
    }
    var showNoResultsView: Bool {
        self.tempPostcode.isEmpty == false && addresses.count == 0 && searchingForAddresses == false
    }
    
    var showResults: Bool {
        addresses.count > 0 || searchingForAddresses
    }
    
    // MARK: - Init
    init(container: DIContainer, addressSelectionType: AddressType, addresses: [FoundAddress], showAddressSelectionView: Binding<Bool>, firstName: String, lastName: String, email: String, phone: String, starterPostcode: String, isInCheckout: Bool) {
        self.container = container
        self.addressSelectionType = addressSelectionType
        self.addresses = addresses
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
        self.phone = phone
        self._showAddressSelectionView = showAddressSelectionView
        self._postcode = .init(initialValue: starterPostcode)
        self.fulfilmentLocation = self.container.appState.value.userData.currentFulfilmentLocation?.country ?? AppV2Constants.Business.operatingCountry
        self.isInCheckout = isInCheckout
        setupShowManualAddressInputView()
    }
    
    private func setupShowManualAddressInputView() {
        $showManualAddressView
            .sink { [weak self] show in
                guard let self = self else { return }
                if show == false { self.selectedAddress = nil } // Clear address when view dismissed
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Button tap methods
    func findByPostcodeTapped() async {
        self.tempPostcode = postcode
        do {
            self.searchingForAddresses = true
            self.addresses = []
            try await self.addresses = container.services.addressService.findAddressesAsync(postcode: self.postcode, countryCode: self.fulfilmentLocation) ?? []
            self.searchingForAddresses = false
        } catch {
            self.searchingForAddresses = false
        }
    }

    // MARK: - Set address
    func setAddress(address: FoundAddress, didSetAddress: (FoundAddress) -> ()) async {
        self.selectedAddress = address
        
        settingDeliveryAddress = true
        
        let basketAddressRequest = BasketAddressRequest(
            firstName: firstName,
            lastName: lastName,
            addressLine1: address.addressLine1,
            addressLine2: address.addressLine2 ,
            town: address.town,
            postcode: address.postcode,
            countryCode: address.countryCode ,
            type: AddressType.delivery.rawValue,
            email: email,
            telephone: phone,
            state: nil,
            county: address.county,
            location: nil
        )
        
        do {
            if addressSelectionType == .delivery {
                try await container.services.basketService.setDeliveryAddress(to: basketAddressRequest)
            } else {
                try await container.services.basketService.setBillingAddress(to: basketAddressRequest)
            }
            
            Logger.checkout.info("Successfully added delivery address")
            
            if let address = self.selectedAddress {
                didSetAddress(address)
            }
            
            self.settingDeliveryAddress = false
            self.showAddressSelectionView = false
        } catch {
            self.addressSelectionError = error as? APIErrorResult
            
            Logger.checkout.error("Failure to set delivery address - \(error.localizedDescription)")
            self.settingDeliveryAddress = false
        }
    }
    
    func selectTapped(address: FoundAddress, didSelectAddress: (FoundAddress) -> ()) async {
        if isInCheckout {
            await setAddress(address: address, didSetAddress: didSelectAddress)
        } else {
            selectedAddress = address
            showManualAddressView = true
        }
    }
    
    func enterManuallyTapped() {
        showManualAddressView = true
    }
}
