//
//  AddressSearchViewModelTests.swift
//  SnappyV2Tests
//
//  Created by David Bage on 08/02/2022.
//

import XCTest
@testable import SnappyV2
import Combine

class AddressSearchViewModelTests: XCTestCase {
    func test_init() {
        let sut = makeSUT()
        XCTAssertEqual(sut.foundAddressesRequest, .notRequested)
        XCTAssertEqual(sut.selectionCountriesRequest, .notRequested)
        XCTAssertEqual(sut.searchText, "")
        XCTAssertEqual(sut.addressLine1Text, "")
        XCTAssertEqual(sut.addressLine2Text, "")
        XCTAssertEqual(sut.townText, "")
        XCTAssertEqual(sut.countyText, "")
        XCTAssertEqual(sut.postcodeText, "")
        XCTAssertEqual(sut.countryText, "")
        XCTAssertFalse(sut.addressLine1HasWarning)
        XCTAssertFalse(sut.cityHasWarning)
        XCTAssertFalse(sut.postcodeHasWarning)
        XCTAssertFalse(sut.countryHasWarning)
        XCTAssertFalse(sut.canSubmit)
        XCTAssertFalse(sut.submitted)
        XCTAssertEqual(sut.viewState, .postCodeSearch)
        XCTAssertEqual(sut.foundAddresses, [])
        XCTAssertNil(sut.selectedAddress)
        XCTAssertEqual(sut.selectionCountries, [])
        XCTAssertNil(sut.selectedAddress)
        XCTAssertEqual(sut.container.appState.value, AppState())
    }
    
    func test_whenNamePassedIntoInit_thenNameTextIsPopulated() {
        let sut = makeSUT(name: Name(firstName: "Alex", secondName: "Bart"))
        XCTAssertEqual(sut.firstNameText, "Alex")
        XCTAssertEqual(sut.lastNameText, "Bart")
    }
    
    func test_whenEnterAddressManuallyTapped_thenViewStateChangesToAddressManualInput() {
        let sut = makeSUT()
        sut.enterAddressManuallyTapped()
        XCTAssertEqual(sut.viewState, .addressManualInput)
    }
    
    func test_whenBackButtonIsTapped_thenViewStateChangesToPostcodeSearch() {
        let sut = makeSUT()
        sut.toPostcodeButtonTapped()
        XCTAssertEqual(sut.viewState, .postCodeSearch)
    }
    
    func test_whenAddAddressTappedAndSelectedCountryIsNotNil_theSelectedAddressIsSet() {
        let sut = makeSUT()
        
        sut.firstNameText = "Alex"
        sut.lastNameText = "Bart"
        sut.addressLine1Text = "40 Bingers"
        sut.addressLine2Text = ""
        sut.townText = "Falclow"
        sut.countryText = "United Kingdom"
        sut.postcodeText = "GI26EP"
        sut.selectedCountry = AddressSelectionCountry(countryCode: "UK", countryName: "United Kingdom", billingEnabled: false, fulfilmentEnabled: false)
        
        let address = Address(
            id: nil,
            isDefault: false,
            addressName: nil,
            firstName: sut.firstNameText,
            lastName: sut.lastNameText,
            addressline1: sut.addressLine1Text,
            addressline2: sut.addressLine2Text,
            town: sut.townText,
            postcode: sut.postcodeText,
            county: sut.countyText,
            countryCode: "UK",
            type: .delivery,
            location: nil)

        sut.addAddressTapped { _ in }
        
        XCTAssertEqual(sut.selectedAddress, address)
    }
    
    func test_whenCountrySelected_thenSelectedCountryPopulated() {
        let sut = makeSUT()
        
        let country = AddressSelectionCountry(
            countryCode: "UK",
            countryName: "United Kingdom",
            billingEnabled: true,
            fulfilmentEnabled: true)
        
        sut.countrySelected(country)
        
        XCTAssertEqual(sut.selectedCountry, country)
    }
    
    func test_whenAddDeliveryAddressTapped_thenSubmittedChangesToTrue() {
        let sut = makeSUT()
        
        XCTAssertFalse(sut.submitted)
        
        let addressSetter: (Address) -> Void = { address in
            print("Test")
        }
        
        sut.addAddressTapped(addressSetter: addressSetter)
        
        XCTAssertTrue(sut.submitted)
    }
    
    func test_whenAddDeliveryAddressTappedAndfirstNameEmpty_thenCanSubmitIsFalse() {
        let sut = makeSUT()
        let addressSetter: (Address) -> Void = { address in
            print("Test")
        }
        
        // First name empty
        sut.lastNameText = "Bart"
        sut.addressLine2Text = "Test"
        sut.townText = "Falcom"
        sut.countyText = "Surrey"
        sut.postcodeText = "GU26EP"
        sut.countryText = "United Kingdom"
        sut.addAddressTapped(addressSetter: addressSetter)
        
        XCTAssertFalse(sut.canSubmit)
    }
    
    func test_whenAddDeliveryAddressTappedAndLastNameEmpty_thenCanSubmitIsFalse() {
        let sut = makeSUT()
        let addressSetter: (Address) -> Void = { address in
            print("Test")
        }
        
        sut.firstNameText = "Alex"
        // Second name empty
        sut.addressLine2Text = "Test"
        sut.townText = "Falcom"
        sut.countyText = "Surrey"
        sut.postcodeText = "GU26EP"
        sut.countryText = "United Kingdom"
        sut.addAddressTapped(addressSetter: addressSetter)
        
        XCTAssertFalse(sut.canSubmit)
    }
    
    func test_whenAddDeliveryAddressTapped_addressLine1IsEmpty_thenCanSubmitIsFalse() {
        let sut = makeSUT()
        let addressSetter: (Address) -> Void = { address in
            print("Test")
        }
        
        // Address line 1 missing
        sut.addressLine2Text = "Test"
        sut.townText = "Falcom"
        sut.countyText = "Surrey"
        sut.postcodeText = "GU26EP"
        sut.countryText = "United Kingdom"
        sut.addAddressTapped(addressSetter: addressSetter)
        
        XCTAssertFalse(sut.canSubmit)
    }
    
    func test_whenAddDeliveryAddressTapped_addressLine2IsEmpty_thenCanSubmitIsTrue() {
        let sut = makeSUT()
        let addressSetter: (Address) -> Void = { address in
            print("Test")
        }
        
        sut.addressLine1Text = "Test"
        
        // Address line 2 missing
        sut.firstNameText = "Alex"
        sut.lastNameText = "Bart"
        sut.townText = "Falcom"
        sut.countyText = "Surrey"
        sut.postcodeText = "GU26EP"
        sut.countryText = "United Kingdom"
        sut.addAddressTapped(addressSetter: addressSetter)
        
        XCTAssertTrue(sut.canSubmit)
    }
    
    func test_whenAddDeliveryAddressTapped_cityTextIsMissing_thenCanSubmitIsFalse() {
        let sut = makeSUT()
        let addressSetter: (Address) -> Void = { address in
            print("Test")
        }
        
        sut.addressLine1Text = "Test"
        sut.addressLine2Text = "Test"
        // City text missing
        sut.countyText = "Surrey"
        sut.postcodeText = "GU26EP"
        sut.countryText = "United Kingdom"
        sut.addAddressTapped(addressSetter: addressSetter)
        
        XCTAssertFalse(sut.canSubmit)
    }
    
    func test_whenAddDeliveryAddressTapped_countyTextIsMissing_thenCanSubmitIsTrue() {
        let sut = makeSUT()
        let addressSetter: (Address) -> Void = { address in
            print("Test")
        }
        
        sut.firstNameText = "Alex"
        sut.lastNameText = "Bart"
        sut.addressLine1Text = "Test"
        sut.addressLine2Text = "Test"
        sut.townText = "Test"
        // County text missing
        sut.postcodeText = "GU26EP"
        sut.countryText = "United Kingdom"
        sut.addAddressTapped(addressSetter: addressSetter)
        
        XCTAssertTrue(sut.canSubmit)
    }
    
    func test_whenAddDeliveryAddressTapped_postcodeIsMissing_thenCanSubmitIsFalse() {
        let sut = makeSUT()
        let addressSetter: (Address) -> Void = { address in
            print("Test")
        }
        
        sut.addressLine1Text = "Test"
        sut.addressLine2Text = "Test"
        sut.townText = "Test"
        sut.countyText = "Test"
        // Postcode missing
        sut.countryText = "United Kingdom"
        sut.addAddressTapped(addressSetter: addressSetter)
        
        XCTAssertFalse(sut.canSubmit)
    }
    
    func test_whenAddDeliveryAddressTapped_countryIsMissing_thenCanSubmitIsFalse() {
        let sut = makeSUT()
        let addressSetter: (Address) -> Void = { address in
            print("Test")
        }
        
        sut.addressLine1Text = "Test"
        sut.addressLine2Text = "Test"
        sut.townText = "Test"
        sut.countyText = "Test"
        sut.postcodeText = "GU9"
        // Country in missing
        sut.addAddressTapped(addressSetter: addressSetter)
        
        XCTAssertFalse(sut.canSubmit)
    }
    
    func test_whenAddressIncludedInInit_thenAddressPopulated() {
        let address = Address(id: nil, isDefault: nil, addressName: nil, firstName: "Test First Name", lastName: "Test Second Name", addressline1: "10 Test Road", addressline2: "", town: "Testingham", postcode: "TES T01", county: "Surrey", countryCode: "UK", type: .delivery, location: nil)

        let sut = makeSUT(address: address)
        
        XCTAssertEqual(sut.rootViewState, .addressCard(address: address))
    }
    
    func test_whenViewDismissed_thenStateIsCleared() {
        let sut = makeSUT()
        
        sut.viewState = .addressManualInput
        sut.addressLine1Text = "Test"
        sut.addressLine2Text = "Test"
        sut.townText = "Test"
        sut.countyText = "Test"
        sut.postcodeText = "Test"
        sut.countryText = "test"
        sut.submitted = true
        
        sut.foundAddressesRequest = .loaded([FoundAddress(addressline1: "test", addressline2: "test", town: "test", postcode: "test", countryCode: "test", county: "test", addressLineSingle: "test")])
        
        sut.selectedAddress = Address(id: nil, isDefault: nil, addressName: nil, firstName: "", lastName: "", addressline1: "test", addressline2: "test", town: "test", postcode: "test", county: "test", countryCode: "test", type: .delivery, location: nil)

        sut.selectionCountriesRequest = .loaded([AddressSelectionCountry(countryCode: "test", countryName: "test", billingEnabled: false, fulfilmentEnabled: false)])
        
        sut.selectedCountry = AddressSelectionCountry(countryCode: "test", countryName: "test", billingEnabled: false, fulfilmentEnabled: false)
        
        sut.viewDismissed()
        
        XCTAssertEqual(sut.foundAddressesRequest, .notRequested)
        XCTAssertEqual(sut.searchText, "")
        XCTAssertEqual(sut.addressLine1Text, "")
        XCTAssertEqual(sut.addressLine2Text, "")
        XCTAssertEqual(sut.townText, "")
        XCTAssertEqual(sut.countyText, "")
        XCTAssertEqual(sut.postcodeText, "")
        XCTAssertFalse(sut.addressLine1HasWarning)
        XCTAssertFalse(sut.cityHasWarning)
        XCTAssertFalse(sut.postcodeHasWarning)
        XCTAssertFalse(sut.countryHasWarning)
        XCTAssertFalse(sut.canSubmit)
        XCTAssertFalse(sut.submitted)
        XCTAssertEqual(sut.viewState, .postCodeSearch)
        XCTAssertEqual(sut.foundAddresses, [])
        XCTAssertEqual(sut.selectionCountries, [])
    }
    
    func test_whenAddressesAreLoaded_thenAddressesAreLoadingReturnsFalse() {
        let sut = makeSUT()
        
        sut.foundAddressesRequest = .loaded([FoundAddress(addressline1: "test", addressline2: "test", town: "test", postcode: "test", countryCode: "test", county: "test", addressLineSingle: "test")])
        
        XCTAssertFalse(sut.addressesAreLoading)
    }
    
    func test_whenAddressesAreLoading_thenAddressesAreLoadingReturnsTrue() {
        let sut = makeSUT()
        
        sut.foundAddressesRequest = .isLoading(last: nil, cancelBag: CancelBag())
        XCTAssertTrue(sut.addressesAreLoading)
    }
    
    func test_whenAddressesHaveLoadingWithResult_thenFoundAddressesIsPopulated() {
        let sut = makeSUT()
        
        let expectation = expectation(description: "setupFoundAddresses")
        var cancellables = Set<AnyCancellable>()
        
        sut.$foundAddressesRequest
            .first()
            .receive(on: RunLoop.main)
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        let addresses = [FoundAddress(addressline1: "40 Bingers", addressline2: "", town: "Falcom", postcode: "GU26EP", countryCode: "UK", county: "Surrey", addressLineSingle: "test")]
        
        sut.foundAddressesRequest = .loaded(addresses)
        
        wait(for: [expectation], timeout: 5)
        
        XCTAssertEqual(sut.foundAddresses, addresses)
    }
    
    func test_whenAddressesHaveLoadedWithResult_givenThatAddressHasEmptyAddressSingleLineField_thenAddressNotAddedToFoundAddresses() {
        let sut = makeSUT()
        
        let expectation = expectation(description: "setupFoundAddresses")
        var cancellables = Set<AnyCancellable>()
        
        sut.$foundAddressesRequest
            .first()
            .receive(on: RunLoop.main)
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        let addresses = [FoundAddress(addressline1: "40 Bingers", addressline2: "", town: "Falcom", postcode: "GU26EP", countryCode: "UK", county: "Surrey", addressLineSingle: "")]
        
        sut.foundAddressesRequest = .loaded(addresses)
        
        wait(for: [expectation], timeout: 5)
        
        XCTAssertEqual(sut.foundAddresses, [])
    }
    
    func test_whenAddressSelected_isAddressSelectionViewPresentedIsFalse() {
        let sut = makeSUT()
        
        let expectation = expectation(description: "setupFoundAddresses")
        var cancellables = Set<AnyCancellable>()
        
        sut.$selectedAddress
            .first()
            .receive(on: RunLoop.main)
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        let address = Address(id: nil, isDefault: nil, addressName: "", firstName: "", lastName: "", addressline1: "40 Bingers", addressline2: "", town: "Falcom", postcode: "GU26EP", county: "Surrey", countryCode: "UK", type: .delivery, location: nil)
                
        sut.selectedAddress = address
        
        wait(for: [expectation], timeout: 5)
        
        XCTAssertFalse(sut.isAddressSelectionViewPresented)
    }
    
    func test_whenSearchTextIsEditedAndFoundAddressesIsEmptyAndFoundAddressRequestIsNotNotRequested_thenAddressesAreReset() {
        let sut = makeSUT()
        
        let expectation = expectation(description: "setupFoundAddresses")
        var cancellables = Set<AnyCancellable>()
        
        sut.$searchText
            .first()
            .receive(on: RunLoop.main)
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        sut.searchText = "testing"
        
        let addresses = [FoundAddress(addressline1: "", addressline2: "", town: "", postcode: "", countryCode: "", county: "", addressLineSingle: "")]
        
        sut.foundAddresses = addresses
        sut.foundAddressesRequest = .loaded(addresses)
        
        wait(for: [expectation], timeout: 5)
        
        XCTAssertEqual(sut.foundAddressesRequest, .notRequested)
        XCTAssertEqual(sut.foundAddresses, [])
    }
    
    func test_whenCountriesHaveLoadingWithResult_thenSelectionCountriesIsPopulated() {
        let sut = makeSUT()
        
        sut.enterAddressManuallyTapped()
        let expectation = expectation(description: "setupSelectionCountries")
        var cancellables = Set<AnyCancellable>()
        
        sut.$selectionCountriesRequest
            .first()
            .receive(on: RunLoop.main)
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        let countries = [AddressSelectionCountry(countryCode: "UK", countryName: "United Kingdom", billingEnabled: true, fulfilmentEnabled: true)]
        sut.selectionCountriesRequest = .loaded(countries)
        
        wait(for: [expectation], timeout: 5)
        
        XCTAssertEqual(sut.selectionCountries, countries)
    }
    
    func test_whenSearchTextIsEmpty_theButtonIsDisabled() {
        let sut = makeSUT()
        
        sut.searchText = ""
        XCTAssertFalse(sut.findButtonEnabled)
    }
    
    func test_whenSearchTextIsPopulated_theButtonIsEnabled() {
        let sut = makeSUT()
        
        sut.searchText = "Test"
        XCTAssertTrue(sut.findButtonEnabled)
    }
    
    func test_whenCloseButtonPressed_thenIsAddressSelectionViewPresentedSetToFalse() {
        let sut = makeSUT()
        
        sut.cancelButtonTapped()
        XCTAssertFalse(sut.isAddressSelectionViewPresented)
    }
    
    func test_whenAddressCardTapped_thenAddressSelectionViewPresentedAndViewStateIsAddressManualInputAndTestFieldsPopulated() {
        let sut = makeSUT()
        
        let address = Address(id: nil, isDefault: nil, addressName: "", firstName: "", lastName: "", addressline1: "40 Bingers", addressline2: "", town: "Falcom", postcode: "GU26EP", county: "Surrey", countryCode: "UK", type: .delivery, location: nil)
        
        sut.editAddressTapped(address: address)
        XCTAssertTrue(sut.isAddressSelectionViewPresented)
        XCTAssertEqual(sut.addressLine1Text, "40 Bingers")
        XCTAssertEqual(sut.addressLine2Text, "")
        XCTAssertEqual(sut.townText, "Falcom")
        XCTAssertEqual(sut.postcodeText, "GU26EP")
        XCTAssertEqual(sut.searchText, "GU26EP")
        XCTAssertEqual(sut.viewState, .addressManualInput)
    }
    
    func test_whenFoundAddressesAreEmptyAndAddressesAreNotLoadingAndIsAddressSelectionViewPresentedIsTrue_thenNoAddressesFoundIsTrue() {
        let sut = makeSUT()
        
        sut.isAddressSelectionViewPresented = true
        
        XCTAssertTrue(sut.noAddressesFound)
    }
    
    func test_whenFoundAddressesAreNotEmptyAndAddressesAreNotLoadingAndIsAddressSelectionViewPresentedIsTrue_thenNoAddressesFoundIsFalse() {
        let sut = makeSUT()
        
        sut.isAddressSelectionViewPresented = true
        sut.foundAddresses = [FoundAddress(addressline1: "", addressline2: "", town: "", postcode: "", countryCode: "", county: "", addressLineSingle: "")]
        
        XCTAssertFalse(sut.noAddressesFound)
    }
    
    func test_whenFoundAddressesAreEmptyAndAddressesAreLoadingAndIsAddressSelectionViewPresentedIsTrue_thenNoAddressesFoundIsFalse() {
        let sut = makeSUT()
        
        sut.isAddressSelectionViewPresented = true
        sut.foundAddressesRequest = .isLoading(last: nil, cancelBag: CancelBag())
        
        XCTAssertFalse(sut.noAddressesFound)
    }
    
    func test_whenFoundAddressesAreEmptyAndAddressesAreNotLoadingAndIsAddressSelectionViewPresentedIsFalse_thenNoAddressesFoundIsFalse() {
        let sut = makeSUT()
        
        sut.isAddressSelectionViewPresented = false
        
        XCTAssertFalse(sut.noAddressesFound)
    }
    
    func test_whenSelectedAddressIsNil_thenInitialViewStateIsPostcodeSearchBar() {
        let sut = makeSUT()
        
        XCTAssertEqual(sut.rootViewState, .postcodeSearchBar)
    }
    
    func test_whenSelectedAddressIsNotNil_thenInitialViewStateIsPostcodeSearchBar() {
        let sut = makeSUT()

        let address = Address(id: nil, isDefault: nil, addressName: "", firstName: "", lastName: "", addressline1: "40 Bingers", addressline2: "", town: "Falcom", postcode: "GU26EP", county: "Surrey", countryCode: "UK", type: .delivery, location: nil)
        
        sut.selectedAddress = address
        XCTAssertEqual(sut.rootViewState, .addressCard(address: address))
    }
    
    func test_whenAddAddressTapped_givenSubmittedIsFalse_theSubbmittedIsTrue() {
      let sut = makeSUT()
        
        sut.submitted = false
        sut.addAddressTapped { _ in }
        
        XCTAssertTrue(sut.submitted)
    }
    
    func test_whenAddAddressTapped_givenCanSubmitIsFalse_thenSelectedAddressRemainsNil() {
        let sut = makeSUT()
        
        sut.addAddressTapped { _ in }
        XCTAssertNil(sut.selectedAddress)
    }
    
    func test_whenAddAddressTapped_givenSelectedCountryIsNilAndCanSubmitIsTrue_thenSelectedAddressRemainsNil() {
        let sut = makeSUT()
        
        sut.submitted = true
        sut.selectedCountry = nil
        
        sut.addAddressTapped { _ in }
        XCTAssertNil(sut.selectedAddress)
    }
    
    func test_whenAddAddressTapped_thenStateChangedToAddressManualInput() {
        let sut = makeSUT()
        
        let address = Address(id: nil, isDefault: nil, addressName: "", firstName: "", lastName: "", addressline1: "40 Bingers", addressline2: "", town: "Falcom", postcode: "GU26EP", county: "Surrey", countryCode: "UK", type: .delivery, location: nil)
        
        sut.selectAddressTapped(address)
        
        XCTAssertEqual(sut.viewState, .addressManualInput)
    }
    
    func test_whenSearchTypeIsAdd_theManualAddressTitleIsAddAddressAndManualAddressButtonTitleIsAddAddress() {
        let sut = makeSUT()
        
        XCTAssertEqual(sut.manualAddressTitle, Strings.PostCodeSearch.addAddress.localized)
        XCTAssertEqual(sut.manualAddressButtonTitle, Strings.PostCodeSearch.addAddress.localized)
    }
    
    func test_whenSearchTypeIsEdit_theManualAddressTitleIsAddAddressAndManualAddressButtonTitleIsSubmit() {
        let sut = makeSUT()
        let address = Address(id: nil, isDefault: nil, addressName: "", firstName: "", lastName: "", addressline1: "40 Bingers", addressline2: "", town: "Falcom", postcode: "GU26EP", county: "Surrey", countryCode: "UK", type: .delivery, location: nil)
        
        sut.editAddressTapped(address: address)
        XCTAssertEqual(sut.manualAddressTitle, Strings.PostCodeSearch.editAddress.localized)
        XCTAssertEqual(sut.manualAddressButtonTitle, GeneralStrings.submit.localized)
    }
    
    func makeSUT(container: DIContainer = DIContainer(appState: AppState(), services: .mocked()), name: Name? = nil, address: Address? = nil) -> AddressSearchViewModel {
        let sut = AddressSearchViewModel(container: container, name: name, address: address)
        
        trackForMemoryLeaks(sut)
        
        return sut
    }
}
