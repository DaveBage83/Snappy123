//
//  AddressSelectionViewModel.swift
//  SnappyV2
//
//  Created by David Bage on 11/07/2022.
//

import SwiftUI // Requited for @Binding variable
import OSLog

@MainActor
class AddressSelectionViewModel: ObservableObject {
    // MARK: - Publishers
    @Published var addresses: [FoundAddress]
    @Published var postcode = ""
    @Published var postcodeHasError = false
    @Published var selectedAddress: FoundAddress?
    @Published var settingDeliveryAddress = false
    @Published var showNoSelectedAddressError = false
    @Published var showDeliveryAddressSetterError = false
        
    // MARK: - Binding
    @Binding var showAddressSelectionView: Bool

    // MARK: - Properties
    let container: DIContainer
    var addressSetterError: String?
    private let email: String
    private let phone: String
    private let firstName: String
    private let lastName: String
    let addressSelectionType: AddressType
    
    init(container: DIContainer, addressSelectionType: AddressType, addresses: [FoundAddress], showAddressSelectionView: Binding<Bool>, firstName: String, lastName: String, email: String, phone: String) {
        self.container = container
        self.addressSelectionType = addressSelectionType
        self.addresses = addresses
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
        self.phone = phone
        self._showAddressSelectionView = showAddressSelectionView
    }

    func setDelivery(address: FoundAddress) async {
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
            self.settingDeliveryAddress = false
            self.showAddressSelectionView = false
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
