//
//  AddressSearchViewModel.swift
//  SnappyV2
//
//  Created by David Bage on 08/02/2022.
//

import Combine
import SwiftUI

class AddressSearchViewModel: ObservableObject {
    
    // MARK: - View state
    
    enum RootViewState: Equatable {
        case addressCard(address: FoundAddress)
        case postcodeSearchBar
    }
    
    enum AddressSearchState {
        case postCodeSearch
        case addressManualInput
    }
    
    enum SearchType {
        case add
        case edit
    }
    
    // MARK: - Field validation
    
    // Binding fields text
    
    @Published var searchText = ""
    @Published var addressLine1Text = ""
    @Published var addressLine2Text = ""
    @Published var cityText  = ""
    @Published var countyText = ""
    @Published var postcodeText = ""
    @Published var countryText = ""
    
    // Computed validation properties
    
    // We check that submitted is set to true to avoid showing errors when view first loaded
    
    var addressLine1HasWarning: Bool {
        submitted && addressLine1Text.isEmpty
    }
    
    var cityHasWarning: Bool {
        submitted && cityText.isEmpty
    }
    
    var postcodeHasWarning: Bool {
        submitted && postcodeText.isEmpty
    }
    
    var countryHasWarning: Bool {
        submitted && countryText.isEmpty
    }
    
    var canSubmit: Bool {
        submitted && !addressLine1HasWarning && !cityHasWarning && !postcodeHasWarning && !countryHasWarning
    }
    
    var noAddressesFound: Bool {
        foundAddresses.isEmpty && !addressesAreLoading && isAddressSelectionViewPresented
    }
    
    var findButtonEnabled: Bool {
        !searchText.isEmpty
    }
    
    var manualAddressTitle: String {
        searchType == .add ? Strings.PostCodeSearch.addAddress.localized : Strings.PostCodeSearch.editAddress.localized
    }
    
    var manualAddressButtonTitle: String {
        searchType == .add ? Strings.PostCodeSearch.addAddress.localized : Strings.General.submit.localized
    }
    
    // MARK: - State control
    
    var rootViewState: RootViewState {
        if let selectedAddress = selectedAddress {
            return .addressCard(address: selectedAddress)
        }
        return .postcodeSearchBar
    }
    
    private var searchType: SearchType = .add
    
    @Published var submitted = false /// Used to avoid adding validation errors when view first loaded. Set to true when user first taps add delivery address button
    @Published var isAddressSelectionViewPresented = false
    
    @Published var viewState: AddressSearchState = .postCodeSearch
    
    // MARK: - Service call properties
    
    // Post code search
    
    @Published var foundAddressesRequest: Loadable<[FoundAddress]?> = .notRequested
    var foundAddresses = [FoundAddress]()
    @Published var selectedAddress: FoundAddress?
    
    // Countries retrieval
    
    @Published var selectionCountriesRequest: Loadable<[AddressSelectionCountry]?> = .notRequested
    private(set) var selectionCountries = [AddressSelectionCountry]()
    @Published var selectedCountry: AddressSelectionCountry?
    
    private let fulfilmentLocation: String
    let container: DIContainer
    private var cancellables = Set<AnyCancellable>()
    
    init(container: DIContainer) {
        self.container = container
        self.fulfilmentLocation = self.container.appState.value.userData.currentFulfilmentLocation?.country ?? AppV2Constants.Business.operatingCountry
        // Setup subscriptions
        setupSearchText()
        setupFoundAddresses()
        setupSelectedAddress()
        setupSelectedCountry()
        setupSelectionCountries()
        getCountries()
    }
    
    var addressesAreLoading: Bool {
        switch foundAddressesRequest {
        case .isLoading(last: _, cancelBag: _):
            return true
        default:
            return false
        }
    }
    
    // MARK: - Subscription configuration
    
    private func setupSelectedAddress() {
        $selectedAddress
            .receive(on: RunLoop.main)
            .sink { [weak self] address in
                guard let self = self, address != nil else { return }
                
                // Whenever address is selected successfully, we dismiss the view
                self.isAddressSelectionViewPresented = false
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Search text subscription
    
    private func setupSearchText() {
        $searchText
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                guard let self = self else { return }
                
                // If we have found addresses and the request has been made, we reset them when we type in the field
                // This will empty the address search results
                
                if !self.foundAddresses.isEmpty && self.foundAddressesRequest != .notRequested {
                    self.resetAddresses()
                }
            }
            .store(in: &cancellables)
    }
    
    
    // MARK: - Country fetch subscription
    
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
    
    // Country selection
    
    private func setupSelectedCountry() {
        $selectedCountry
            .receive(on: RunLoop.main)
            .sink { [weak self] country in
                guard let self = self, let country = country else { return }
                self.countryText = country.countryName
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Postcode search subscription
    
    private func setupFoundAddresses() {
        $foundAddressesRequest
            .map { result in
                return result.value
            }
            .replaceNil(with: [])
            .removeDuplicates()
            .receive(on: RunLoop.main)
            .sink { [weak self] addresses in
                guard let self = self, let foundAddresses = addresses else { return }
                
                self.foundAddresses = foundAddresses.filter { $0.addressLineSingle.isEmpty == false }
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Methods
    
    private func getCountries() {
        self.container.services.addressService.getSelectionCountries(countries: self.loadableSubject(\.selectionCountriesRequest))
    }
    
    private func changeToAddressManualInputState() {
        viewState = .addressManualInput
    }
    
    private func changeToPostcodeSearchState() {
        viewState = .postCodeSearch
    }
    
    func enterAddressManuallyTapped() {
        changeToAddressManualInputState()
    }
    
    func toPostcodeButtonTapped() {
        changeToPostcodeSearchState()
    }
    
    func findTapped() {
        isAddressSelectionViewPresented = true
        container.services.addressService.findAddresses(addresses: loadableSubject(\.foundAddressesRequest), postcode: searchText, countryCode: fulfilmentLocation)
    }
    
    func selectAddressTapped(address: FoundAddress, addressSetter: (FoundAddress) -> ()) {
        self.selectedAddress = address
        addressSetter(address)
    }
    
    func countrySelected(_ country: AddressSelectionCountry) {
        self.selectedCountry = country
    }
    
    func addAddressTapped(addressSetter: (FoundAddress) -> ()) {
        if !submitted {
            submitted = true
        }
        
        if canSubmit, let selectedCountry = self.selectedCountry {
            let addressStrings = [addressLine1Text, addressLine2Text, cityText, countyText, postcodeText, countryText]
            
            self.selectedAddress = FoundAddress(
                addressline1: self.addressLine1Text,
                addressline2: self.addressLine2Text,
                town: self.cityText,
                postcode: self.postcodeText,
                countryCode: selectedCountry.countryCode,
                county: self.countyText,
                addressLineSingle: singleLineAddress(addressStrings: addressStrings))
            if let address = self.selectedAddress {
                addressSetter(address)
            }
        }
    }
    
    // Used to populate address single line
    
    private func singleLineAddress(addressStrings: [String]) -> String {
        let validAddressStrings = addressStrings.filter { !$0.isEmpty }
        return validAddressStrings.joined(separator: ", ")
    }
    
    // MARK: - Clear state / memory methods
    
    private func clearState() {
        viewState = .postCodeSearch
        clearTextFields()
        submitted = false
        resetAddresses()
    }
    
    private func clearTextFields() {
        addressLine1Text = ""
        addressLine2Text = ""
        cityText = ""
        countyText = ""
        postcodeText = ""
    }
    
    private func resetAddresses() {
        foundAddressesRequest = .notRequested
        foundAddresses = []
    }
    
    func viewDismissed() {
        clearState()
    }
    
    func cancelButtonTapped() {
        isAddressSelectionViewPresented = false
    }
    
    func editAddressTapped(address: FoundAddress) {
        searchType = .edit
        isAddressSelectionViewPresented = true
        viewState = .addressManualInput
        setAddressFieldsText(address: address)
    }
    
    private func setAddressFieldsText(address: FoundAddress) {
        addressLine1Text = address.addressline1
        addressLine2Text = address.addressline2
        cityText = address.town
        countyText = address.county
        postcodeText = address.postcode
        searchText = address.postcode
        findTapped()
    }
}
