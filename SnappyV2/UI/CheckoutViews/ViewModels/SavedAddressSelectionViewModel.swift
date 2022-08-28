//
//  SavedAddressSelectionViewModel.swift
//  SnappyV2
//
//  Created by David Bage on 11/07/2022.
//

import OSLog

@MainActor
class SavedAddressesSelectionViewModel: ObservableObject  {
    typealias SavedAddressStrings = Strings.CheckoutDetails.SavedAddressesSelectionView
    
    // MARK: - Properties
    var addresses: [Address]
    let container: DIContainer
    
    let savedAddressType: AddressType
    
    // MARK: - Publishers
    @Published var selectedAddress: Address?
    @Published var settingDeliveryAddress = false
    @Published var basket: Basket?
    @Published var showDeliveryAddressSetterError = false
    @Published var showNoSelectedAddressError = false
    
    // MARK: - Error
    var addressSetterError: String?
    
    // MARK: - Required values
    let firstName: String
    let lastName: String
    let email: String // needed in order to set delivery/billing so must be injected here and is not optional
    let phone: String // needed in order to set delivery/billing so must be injected here and is not optional
    
    var title: String {
        self.savedAddressType == .delivery ? SavedAddressStrings.title.localized : SavedAddressStrings.titleBilling.localized
    }
    
    var buttonTitle: String {
        if self.savedAddressType == .delivery {
            return SavedAddressStrings.setAsDeliveryAddressButton.localized
        } else if self.savedAddressType == .billing {
            return SavedAddressStrings.setAsBillingAddressButton.localized
        } else {
            return SavedAddressStrings.setAsCardAddressButton.localized
        }
    }
    
    var navTitle: String {
        if savedAddressType == .delivery {
            return SavedAddressStrings.navTitle.localized
        } else if savedAddressType == .billing {
            return SavedAddressStrings.navTitleBilling.localized
        } else {
            return SavedAddressStrings.navTitleCard.localized
        }
    }
    
    // MARK: - Init
    init(container: DIContainer, savedAddressType: AddressType, addresses: [Address], firstName: String, lastName: String, email: String, phone: String) {
        self.container = container
        self.savedAddressType = savedAddressType
        self.addresses = addresses
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
        self.phone = phone
        let appState = container.appState
        basket = appState.value.userData.basket
        setInitialSelectedAddress()
    }
    
    // MARK: - Initial set up
    private func setInitialSelectedAddress() {
        // If we have addresses in the basket and there is an address that matches one of the saved address, select it as default
        if let basketAddresses = basket?.addresses?.filter({ $0.type == (savedAddressType == .billing ? "billing" : "delivery") }),
           let address = addresses.first(where: { $0.addressLine1 == basketAddresses.first?.addressLine1 })
        {
            self._selectedAddress = .init(initialValue: address)
        // Otherwise if there is a default address then use this one
        } else if let defaultAddress = defaultAddress() {
            self._selectedAddress = .init(initialValue: defaultAddress)
        // Otherwise if no matching address from the basket OR default address, select the first one in the list (in theory
        // we should not be here as at least 1 default of each type is required)
        } else {
            self._selectedAddress = .init(initialValue: addresses.first)
        }
    }
    
    // MARK: - Get default address
    private func defaultAddress() -> Address? {
        addresses.first(where: { $0.isDefault == true })
    }
    
    // MARK: - Set selectedAddress
    func selectAddress(_ address: Address) {
        self.selectedAddress = address
    }
    
    // MARK: - Set delivery address
    func setAddress(address: Address?, didSetAddress: (FoundAddress) -> ()) async {
        guard let address = selectedAddress else {
            showNoSelectedAddressError = true
            return
        }
                
        self.selectedAddress = address
        
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
            
            if let address = self.selectedAddress {
                didSetAddress(address.mapToFoundAddress())
            }
            
            self.settingDeliveryAddress = false
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
