//
//  ManualInputAddressViewModel.swift
//  SnappyV2
//
//  Created by David Bage on 26/07/2022.
//

import Combine
import Foundation

enum ManualInputAddressError: Swift.Error {
    case missingDetails
}

extension ManualInputAddressError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .missingDetails:
            return Strings.CheckoutDetails.Errors.Missing.subtitle.localized
        }
    }
}

@MainActor
class ManualInputAddressViewModel: ObservableObject {
    typealias AddressStrings = Strings.PostCodeSearch.Address
    
    enum ViewState {
        case addAddress
        case editAddress
        
        var navigationTitle: String {
            switch self {
            case .addAddress:
                return AddressStrings.addManually.localized
            case .editAddress:
                return AddressStrings.editAddress.localized
            }
        }
        
        var dismissType: NavigationDismissType {
            switch self {
            case .addAddress:
                return .back
            case .editAddress:
                return .close
            }
        }
        
        var submitButtonText: String {
            switch self {
            case .addAddress:
                return AddressStrings.save.localized
            case .editAddress:
                return AddressStrings.update.localized
            }
        }
    }
    
    // MARK: - Textfield publishers
    
    // Content
    @Published var addressNickname = ""
    @Published var addressLine1 = ""
    @Published var addressLine2 = ""
    @Published var town = ""
    @Published var postcode = ""
    @Published var county = ""
    
    // Errors
    @Published var addressNicknameHasError = false
    @Published var addressLine1HasError = false
    @Published var townHasError = false
    @Published var postcodeHasError = false
    @Published var error: Swift.Error?
    
    let addressType: AddressType
    
    // Default
    @Published var isDefaultAddress = false
    
    // Loading
    @Published var savingAddress = false
    
    private var selectedCountry: AddressSelectionCountry?
    
    let viewState: ViewState
    let address: Address?
    private let addressInitiallyDefault: Bool
    
    let container: DIContainer
    private var cancellables = Set<AnyCancellable>()
    
    private var errorsExist: Bool {
        addressNicknameHasError || addressLine1HasError || townHasError || postcodeHasError
    }
    
    var showDefaultToggle: Bool {
        !addressInitiallyDefault // We do not want to show the toggle if the address was already default addresss
    }
    
    // MARK: - Init
    init(container: DIContainer, address: Address?, addressType: AddressType, viewState: ViewState) {
        self.container = container
        self.address = address
        self.addressType = addressType
        self.viewState = viewState
        self.addressInitiallyDefault = address?.isDefault ?? false
        
        setupAddressLine1Error()

        setupAddressNicknameError()
        setupTownError()
        setupPostcodeError()
        
        populateFields()
    }

    // MARK: - Methods
    
    // Populate all fields
    private func populateFields() {
        guard let address = address else { return }

        if let addressName = address.addressName {
            self.addressNickname = addressName
        }
        
        self.addressLine1 = address.addressLine1
        
        if let addressLine2 = address.addressLine2 {
            self.addressLine2 = addressLine2
        }
        
        self.town = address.town
        self.postcode = address.postcode
        
        if let county = address.county {
            self.county = county
        }
    }
    
    // Save address button action
    func saveAddressTapped(addressSaved: () -> ()) async {
        guard fieldsHaveErrors() == false else {
            self.error = ManualInputAddressError.missingDetails
            return
        }
        
        savingAddress = true
        
        do {
            let address = Address(
                id: address?.id,
                isDefault: isDefaultAddress,
                addressName: addressNickname,
                firstName: nil,
                lastName: nil,
                addressLine1: addressLine1,
                addressLine2: addressLine2,
                town: town,
                postcode: postcode,
                county: county,
                countryCode: selectedCountry?.countryCode,
                type: addressType,
                location: nil,
                email: nil,
                telephone: nil)
            
            if viewState == .addAddress {
                try await self.container.services.userService.addAddress(address: address)
            } else {
                try await self.container.services.userService.updateAddress(address: address)
            }
            
            savingAddress = false
            addressSaved()
        } catch {
            savingAddress = false
            self.error = error
        }
    }
    
    private func fieldsHaveErrors() -> Bool {
        addressNicknameHasError = addressNickname.isEmpty
        addressLine1HasError = addressLine1.isEmpty
        townHasError = town.isEmpty
        postcodeHasError = postcode.isEmpty
        
        return errorsExist
    }
    
    private func setupAddressNicknameError() {
        $addressNickname
            .dropFirst()
            .receive(on: RunLoop.main)
            .sink { [weak self] value in
                guard let self = self else { return }
                self.addressNicknameHasError = value.isEmpty
            }
            .store(in: &cancellables)
    }
    
    private func setupAddressLine1Error() {
        $addressLine1
            .dropFirst()
            .receive(on: RunLoop.main)
            .sink { [weak self] value in
                guard let self = self else { return }
                self.addressLine1HasError = value.isEmpty
            }
            .store(in: &cancellables)
    }
    
    private func setupTownError() {
        $town
            .dropFirst()
            .receive(on: RunLoop.main)
            .sink { [weak self] value in
                guard let self = self else { return }
                self.townHasError = value.isEmpty
            }
            .store(in: &cancellables)
    }
    
    private func setupPostcodeError() {
        $postcode
            .dropFirst()
            .receive(on: RunLoop.main)
            .sink { [weak self] value in
                guard let self = self else { return }
                self.postcodeHasError = value.isEmpty
            }
            .store(in: &cancellables)
    }
    
    func countrySelected(_ country: AddressSelectionCountry) {
        self.selectedCountry = country
    }
}
