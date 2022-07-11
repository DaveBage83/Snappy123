//
//  SavedAddressSelectionViewModel.swift
//  SnappyV2
//
//  Created by David Bage on 11/07/2022.
//

import SwiftUI // required for @Binding property
import OSLog

@MainActor
class SavedAddressesSelectionViewModel: ObservableObject  {
    // MARK: - Properties
    var addresses: [Address]
    let container: DIContainer
    
    let savedAddressType: AddressType
    
    // MARK: - Binding
    @Binding var showSavedAddressSelectionView: Bool
    
    // MARK: - Publishers
    @Published var selectedAddress: Address?
    @Published var settingDeliveryAddress = false
    @Published var basket: Basket?
    @Published var showDeliveryAddressSetterError = false
    @Published var showNoSelectedAddressError = false
    
    // MARK: - Error
    var addressSetterError: String?
    
    // MARK: - Required values
    let email: String // needed in order to set delivery so must be injected here and is not optional
    let phone: String // needed in order to set delivery so must be injected here and is not optional
    
    // MARK: - Init
    init(container: DIContainer, savedAddressType: AddressType, addresses: [Address], showSavedAddressSelectionView: Binding<Bool>, email: String, phone: String) {
        self.container = container
        self.savedAddressType = savedAddressType
        self.addresses = addresses
        self.email = email
        self.phone = phone
        self._showSavedAddressSelectionView = showSavedAddressSelectionView
        let appState = container.appState
        basket = appState.value.userData.basket
        setInitialSelectedAddress()
    }
    
    // MARK: - Initial set up
    private func setInitialSelectedAddress() {
        if let basketAddresses = basket?.addresses, basketAddresses.count > 0,
           addresses.filter({ $0.addressLine1 == basketAddresses[0].addressLine1 }).count > 0
        {
            self._selectedAddress = .init(initialValue: addresses.filter { $0.addressLine1 == basketAddresses[0].addressLine1 }[0])
        } else if let defaultAddress = defaultAddress() {
            self._selectedAddress = .init(initialValue: defaultAddress)
        } else {
            self._selectedAddress = .init(initialValue: addresses[0])
        }
    }
    
    // MARK: - Get default address
    private func defaultAddress() -> Address? {
        let defaultAddresses = addresses.filter { $0.isDefault == true }
        
        if defaultAddresses.count > 0 {
            return defaultAddresses[0]
        }
        return nil
    }
    
    // MARK: - Set selectedAddress
    func selectAddress(_ address: Address) {
        self.selectedAddress = address
    }
    
    // MARK: - Set delivery address
    func setDelivery(address: Address?) async {
        guard let address = selectedAddress else {
            showNoSelectedAddressError = true
            return
        }
        
        settingDeliveryAddress = true
        
        let basketAddressRequest = BasketAddressRequest(
            firstName: address.firstName ?? "",
            lastName: address.lastName ?? "",
            addressLine1: address.addressLine1,
            addressLine2: address.addressLine2 ?? "",
            town: address.town,
            postcode: address.postcode,
            countryCode: address.countryCode ?? "",
            type: AddressType.delivery.rawValue,
            email: email,
            telephone: phone,
            state: nil,
            county: address.county,
            location: nil
        )
        
        do {
            if savedAddressType == .delivery {
                try await container.services.basketService.setDeliveryAddress(to: basketAddressRequest)
            } else {
                try await container.services.basketService.setBillingAddress(to: basketAddressRequest)
            }
            
            Logger.checkout.info("Successfully added delivery address")
            self.settingDeliveryAddress = false
            self.showSavedAddressSelectionView = false
        } catch {
            if let error = error as? APIErrorResult {
                self.addressSetterError = error.errorText
            }
            
            self.showDeliveryAddressSetterError = true
            Logger.checkout.error("Failure to set delivery address - \(error.localizedDescription)")
            self.settingDeliveryAddress = false
        }
    }
}
