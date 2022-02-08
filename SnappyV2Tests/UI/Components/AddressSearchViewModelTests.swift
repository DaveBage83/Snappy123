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
        XCTAssertEqual(sut.cityText, "")
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
    
    func test_whenEnterAddressManuallyTapped_thenViewStateChangesToAddressManualInput() {
        let sut = makeSUT()
        sut.enterAddressManuallyTapped()
        XCTAssertEqual(sut.viewState, .addressManualInput)
    }
    
    func test_whenBackButtonIsTapped_thenViewStateChangesToPostcodeSearch() {
        let sut = makeSUT()
        sut.backButtonTapped()
        XCTAssertEqual(sut.viewState, .postCodeSearch)
    }
    
    func test_whenSelectAddressTapped_thenSelectedAddressSet_andAddressSetterCallbackTriggered() {
        let sut = makeSUT()
        
        let foundAddress = FoundAddress(
            addressline1: "38 Bullers Road",
            addressline2: "",
            town: "Farnham",
            postcode: "GU9 9EP",
            countryCode: "UK",
            county: "Surrey",
            addressLineSingle: "38 Bullers Road, Farnham, GU9 9EP")
        
        var populatedAddress: FoundAddress?
        
        sut.selectAddressTapped(address: foundAddress) { foundAddress in
            populatedAddress = foundAddress
        }
        
        XCTAssertEqual(sut.selectedAddress, foundAddress)
        XCTAssertEqual(populatedAddress, foundAddress)
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
        
        sut.addDeliveryAddressTapped()
        
        XCTAssertTrue(sut.submitted)
    }
    
    func test_whenAddDeliveryAddressTapped_addressLine1IsEmpty_thenCanSubmitIsFalse() {
        let sut = makeSUT()
        
        // Address line 1 missing
        sut.addressLine2Text = "Test"
        sut.cityText = "Farnham"
        sut.countyText = "Surrey"
        sut.postcodeText = "GU9 9EP"
        sut.countryText = "United Kingdom"
        sut.addDeliveryAddressTapped()
        
        XCTAssertFalse(sut.canSubmit)
    }
    
    func test_whenAddDeliveryAddressTapped_addressLine2IsEmpty_thenCanSubmitIsTrue() {
        let sut = makeSUT()
        
        sut.addressLine1Text = "Test"
        
        // Address line 2 missing
        sut.cityText = "Farnham"
        sut.countyText = "Surrey"
        sut.postcodeText = "GU9 9EP"
        sut.countryText = "United Kingdom"
        sut.addDeliveryAddressTapped()
        
        XCTAssertTrue(sut.canSubmit)
    }
    
    func test_whenAddDeliveryAddressTapped_cityTextIsMissing_thenCanSubmitIsFalse() {
        let sut = makeSUT()
        
        sut.addressLine1Text = "Test"
        sut.addressLine2Text = "Test"
        // City text missing
        sut.countyText = "Surrey"
        sut.postcodeText = "GU9 9EP"
        sut.countryText = "United Kingdom"
        sut.addDeliveryAddressTapped()
        
        XCTAssertFalse(sut.canSubmit)
    }
    
    func test_whenAddDeliveryAddressTapped_countyTextIsMissing_thenCanSubmitIsTrue() {
        let sut = makeSUT()
        sut.addressLine1Text = "Test"
        sut.addressLine2Text = "Test"
        sut.cityText = "Test"
        // County text missing
        sut.postcodeText = "GU9 9EP"
        sut.countryText = "United Kingdom"
        sut.addDeliveryAddressTapped()
        
        XCTAssertTrue(sut.canSubmit)
    }
    
    func test_whenAddDeliveryAddressTapped_postcodeIsMissing_thenCanSubmitIsFalse() {
        let sut = makeSUT()
        
        sut.addressLine1Text = "Test"
        sut.addressLine2Text = "Test"
        sut.cityText = "Test"
        sut.countyText = "Test"
        // Postcode missing
        sut.countryText = "United Kingdom"
        sut.addDeliveryAddressTapped()
        
        XCTAssertFalse(sut.canSubmit)
    }
    
    func test_whenAddDeliveryAddressTapped_countryIsMissing_thenCanSubmitIsFalse() {
        let sut = makeSUT()
        
        sut.addressLine1Text = "Test"
        sut.addressLine2Text = "Test"
        sut.cityText = "Test"
        sut.countyText = "Test"
        sut.postcodeText = "GU9"
        // Country in missing
        sut.addDeliveryAddressTapped()
        
        XCTAssertFalse(sut.canSubmit)
    }
    
    func test_whenViewDismissed_thenStateIsCleared() {
        let sut = makeSUT()
        
        sut.viewState = .addressManualInput
        sut.addressLine1Text = "Test"
        sut.addressLine2Text = "Test"
        sut.cityText = "Test"
        sut.countyText = "Test"
        sut.postcodeText = "Test"
        sut.countryText = "test"
        sut.submitted = true
        
        sut.foundAddressesRequest = .loaded([FoundAddress(addressline1: "test", addressline2: "test", town: "test", postcode: "test", countryCode: "test", county: "test", addressLineSingle: "test")])
        
        sut.selectedAddress = FoundAddress(addressline1: "test", addressline2: "test", town: "test", postcode: "test", countryCode: "test", county: "test", addressLineSingle: "test")
        
        sut.selectionCountriesRequest = .loaded([AddressSelectionCountry(countryCode: "test", countryName: "test", billingEnabled: false, fulfilmentEnabled: false)])
        
        sut.selectedCountry = AddressSelectionCountry(countryCode: "test", countryName: "test", billingEnabled: false, fulfilmentEnabled: false)
        
        sut.viewDismissed()
        
        XCTAssertEqual(sut.foundAddressesRequest, .notRequested)
        XCTAssertEqual(sut.selectionCountriesRequest, .notRequested)
        XCTAssertEqual(sut.searchText, "")
        XCTAssertEqual(sut.addressLine1Text, "")
        XCTAssertEqual(sut.addressLine2Text, "")
        XCTAssertEqual(sut.cityText, "")
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
        
        let addresses = [FoundAddress(addressline1: "38 Bullers", addressline2: "", town: "Farnham", postcode: "GU9 9EP", countryCode: "UK", county: "Surrey", addressLineSingle: "test")]
        
        sut.foundAddressesRequest = .loaded(addresses)
        
        wait(for: [expectation], timeout: 5)
        
        XCTAssertEqual(sut.foundAddresses, addresses)
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
    
    func makeSUT(container: DIContainer = DIContainer(appState: AppState(), services: .mocked())) -> AddressSearchViewModel {
        let sut = AddressSearchViewModel(container: container)
        
        trackForMemoryLeaks(sut)
        
        return sut
    }
}
