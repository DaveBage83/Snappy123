//
//  AddressSearchViewModel.swift
//  SnappyV2
//
//  Created by David Bage on 08/02/2022.
//

import Combine
import Foundation
import OSLog

class AddressSearchViewModel: ObservableObject {
    typealias AddressStrings = Strings.PostCodeSearch
    
    enum InitialSearchActionType {
        case searchBar
        case button
    }
    
    // MARK: - View state
    
    enum RootViewState: Equatable {
        case addressCard(address: Address)
        case postcodeSearchBar
    }
    
    // Defines what state we are in -> postcode search or address entry form
    enum AddressSearchState {
        case postCodeSearch
        case addressManualInput
    }
    
    // Behaviour and layout of views is different depending on whether we are adding or editting an address
    enum AddressSearchType {
        case add
        case edit
    }
    
    // Defines the current search outcome state. We use this to control the view displayed for empty search results
    enum SearchOutcome {
        case noAddressesFound
        case newSearch
        case addressesFound
        case other
    }

    // MARK: - Binding text field text
    
    @Published var firstNameText = ""
    @Published var lastNameText = ""
    @Published var searchText = ""
    @Published var addressLine1Text = ""
    @Published var addressLine2Text = ""
    @Published var townText  = ""
    @Published var countyText = ""
    @Published var postcodeText = ""
    @Published var countryText = ""
    @Published var addressNicknameText = ""
    
    @Published var isDefaultAddressSelected = false // Controls default address selction checkbox (for adding addresses only)
    @Published var submitted = false /// Used to avoid adding validation errors when view first loaded. Set to true when user first taps add delivery address button
    @Published var isAddressSelectionViewPresented = false
    @Published var viewState: AddressSearchState = .postCodeSearch
    var searchType: AddressSearchType = .add
    
    // Controls whether the initial search is triggered by a button or a searchbar
    let initialSearchActionType: InitialSearchActionType
    private var newSearch = false // set to true in init if we are in .button mode
    let addressType: AddressType

    // MARK: - Validation
    
    // We check that submitted is set to true to avoid showing errors when view first loaded
    
    var firstNameHasWarning: Bool {
        submitted && firstNameText.isEmpty
    }
    
    var lastNameHasWarning: Bool {
        submitted && lastNameText.isEmpty
    }
    
    var addressLine1HasWarning: Bool {
        submitted && addressLine1Text.isEmpty
    }
    
    var cityHasWarning: Bool {
        submitted && townText.isEmpty
    }
    
    var postcodeHasWarning: Bool {
        submitted && postcodeText.isEmpty
    }
    
    var countryHasWarning: Bool {
        submitted && countryText.isEmpty
    }
    
    var canSubmit: Bool {
        submitted && !firstNameHasWarning && !lastNameHasWarning && !addressLine1HasWarning && !cityHasWarning && !postcodeHasWarning && !countryHasWarning
    }

    // When text is empty, we disable the find button
    var findButtonEnabled: Bool {
        !searchText.isEmpty
    }
    
    // We only display this when the searchType is .add i.e. new address being added. For edit, this functionality is set
    // on the main view where all addresses listed
    var showSetAddressToDefaultCheckbox: Bool {
        searchType == .add
    }
    
    // For editing addresses, this ID will be present when we pass the address object into the form. We do not want to replace
    // with nil when returning the edited address
    private var addressID: Int? {
        selectedAddress?.id
    }
    
    // The following 2 are only allowed if user is logged in
    var allowAdmin: Bool {
        container.appState.value.userData.memberProfile != nil
    }
    
    var showAddressNickname: Bool {
        container.appState.value.userData.memberProfile != nil
    }

    // MARK: - Dynamic text
    
    var manualAddressTitle: String {
        switch addressType {
        case .delivery:
            return searchType == .add ? Strings.PostCodeSearch.addDeliveryTitle.localized : Strings.PostCodeSearch.editDeliveryTitle.localized
        case .billing:
            return searchType == .add ? Strings.PostCodeSearch.addBillingTitle.localized : Strings.PostCodeSearch.editBillingTitle.localized
        }
    }
    
    var manualAddressButtonTitle: String {
        searchType == .add ? Strings.PostCodeSearch.addAddress.localized : Strings.General.submit.localized
    }
    
    var buttonText: String {
        return addressType == .delivery ? Strings.PostCodeSearch.addDeliveryTitle.localized : Strings.PostCodeSearch.addBillingTitle.localized
    }
    
    // MARK: - State control
    
    var rootViewState: RootViewState {
        if let selectedAddress = selectedAddress {
            return .addressCard(address: selectedAddress)
        }
        return .postcodeSearchBar
    }
    
    // Used to display correct view when search results are empty. When the initialSearchActionType is set to .button
    // then we do not want to display the 'no found addresses' error immediatey as no search has yet been performed.
    
    var searchOutcomeState: SearchOutcome {
        newSearch ? .newSearch  :
        foundAddresses.isEmpty && !addressesAreLoading && isAddressSelectionViewPresented ? .noAddressesFound :
        !foundAddresses.isEmpty ? .addressesFound :
            .other
    }

    // MARK: - Service call properties
    
    // Post code search
    
    @Published var foundAddressesRequest: Loadable<[FoundAddress]?> = .notRequested
    @Published var profileFetch: Loadable<MemberProfile> = .notRequested
    var foundAddresses = [FoundAddress]()
    @Published var selectedAddress: Address?
    
    // Countries retrieval
    
    @Published var selectionCountriesRequest: Loadable<[AddressSelectionCountry]?> = .notRequested
    private(set) var selectionCountries = [AddressSelectionCountry]()
    @Published var selectedCountry: AddressSelectionCountry?
    
    private let fulfilmentLocation: String
    let container: DIContainer
    private var cancellables = Set<AnyCancellable>()

    var addressesAreLoading: Bool {
        switch foundAddressesRequest {
        case .isLoading(last: _, cancelBag: _):
            return true
        default:
            return false
        }
    }
    
    init(container: DIContainer, name: Name? = nil, address: Address? = nil, type: AddressType, initialSearchActionType: InitialSearchActionType = .searchBar) {
        self.container = container
        self.fulfilmentLocation = self.container.appState.value.userData.currentFulfilmentLocation?.country ?? AppV2Constants.Business.operatingCountry
        
        self.addressType = type
        self.selectedAddress = address
        self.initialSearchActionType = initialSearchActionType
     
        if let name = name {
            self.firstNameText = name.firstName
            self.lastNameText = name.secondName
        }
        
        if initialSearchActionType == .button { // Ensures we do not display error text when postcode search first appears and is empty
            newSearch = true
        }
        
        getCountries()
        
        // Setup subscriptions
        setupSearchText()
        setupFoundAddresses()
        setupSelectedAddress()
        setupSelectedCountry()
        setupSelectionCountries()
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
        newSearch = false
        isAddressSelectionViewPresented = true
        container.services.addressService.findAddresses(addresses: loadableSubject(\.foundAddressesRequest), postcode: searchText, countryCode: fulfilmentLocation)
    }
    
    func initialAddAddressButtonTapped() {
        isAddressSelectionViewPresented = true
    }
    
    func selectAddressTapped(_ address: Address) {
        changeToAddressManualInputState()
        setAddressFieldsText(address: address)
    }
    
    func countrySelected(_ country: AddressSelectionCountry) {
        self.selectedCountry = country
    }
    
    func addAddressTapped(addressSetter: (Address) -> ()) {
        if !submitted {
            submitted = true
        }
        
        if canSubmit, let selectedCountry = self.selectedCountry {
            self.selectedAddress = Address(
                id: addressID, // ID required for update address functionality
                isDefault: isDefaultAddressSelected,
                addressName: addressNicknameText,
                firstName: firstNameText,
                lastName: lastNameText,
                addressLine1: addressLine1Text,
                addressLine2: addressLine2Text,
                town: townText,
                postcode: postcodeText,
                county: countyText,
                countryCode: selectedCountry.countryCode,
                type: addressType,
                location: nil,
                email: nil,
                telephone: nil
            )
                        
            if let address = self.selectedAddress {
                addressSetter(address)
            }
        }
    }

    // MARK: - Clear state / memory methods
    
    private func clearState() {
        viewState = .postCodeSearch
        clearTextFields()
        submitted = false
        resetAddresses()
    }
    
    private func clearTextFields() {
        addressNicknameText = ""
        firstNameText = ""
        lastNameText = ""
        addressLine1Text = ""
        addressLine2Text = ""
        townText = ""
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
    
    func editAddressTapped(address: Address) {
        isDefaultAddressSelected = address.isDefault == true
        searchType = .edit
        isAddressSelectionViewPresented = true
        viewState = .addressManualInput
        setAddressFieldsText(address: address)
    }
    
    private func setAddressFieldsText(address: Address) {
        addressLine1Text = address.addressLine1
        addressLine2Text = address.addressLine2 ?? ""
        addressNicknameText = address.addressName ?? ""
        firstNameText = address.firstName ?? ""
        lastNameText = address.lastName ?? ""
        townText = address.town
        countyText = address.county ?? ""
        postcodeText = address.postcode
        
        if foundAddresses.isEmpty {
            searchText = address.postcode
            findTapped()
        }
    }
    
    func setAddressToDefaultTapped() {
        self.isDefaultAddressSelected.toggle()
    }
}
