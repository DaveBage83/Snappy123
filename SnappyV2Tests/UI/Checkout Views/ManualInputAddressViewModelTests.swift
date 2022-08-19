//
//  ManualInputAddressViewModelTests.swift
//  SnappyV2Tests
//
//  Created by David Bage on 26/07/2022.
//

import XCTest
import Combine
@testable import SnappyV2

@MainActor
class ManualInputAddressViewModelTests: XCTestCase {
    
    func test_whenInit_thenFieldsPopulatedWithAddressDetails() {
        let address = FoundAddress(
            addressLine1: "10 Downing Street",
            addressLine2: "Party Town",
            town: "London",
            postcode: "SW11EP",
            countryCode: "GB",
            county: "London",
            addressLineSingle: "").mapToAddress(type: .delivery)
        
        let sut = makeSUT(address: address)
        
        XCTAssertEqual(sut.addressLine1, address.addressLine1)
        XCTAssertEqual(sut.addressLine2, address.addressLine2)
        XCTAssertEqual(sut.town, address.town)
        XCTAssertEqual(sut.postcode, address.postcode)
        XCTAssertEqual(sut.county, address.county)
    }
    
    // Test when addressNickname set to empty, then addressNickname has error is true
    func test_whenAddressNicknameSetEmpty_thenAddressNicknameHasErrorIsTrue() {
        let address = FoundAddress(addressLine1: "Test", addressLine2: "Test", town: "Test", postcode: "TEST", countryCode: "UK", county: "Surrey", addressLineSingle: "")
            .mapToAddress(type: .delivery)
        
        let sut = makeSUT(address: address)
        
        let expectation = expectation(description: "addressNicknameErrorSet")
        var cancellables = Set<AnyCancellable>()
        
        XCTAssertFalse(sut.addressNicknameHasError)
        sut.addressNickname = "test"
        sut.addressNickname = ""
        
        sut.$addressNickname
            .first()
            .receive(on: RunLoop.main)
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 2)
        
        XCTAssertTrue(sut.addressNicknameHasError)
    }
    
    // Test when addressLine1 set to empty, then addressLine1 has error is true
    func test_whenAddressLine1SetEmpty_thenAddressLine1HasErrorIsTrue() {
        let address = FoundAddress(addressLine1: "Test", addressLine2: "Test", town: "Test", postcode: "TEST", countryCode: "UK", county: "Surrey", addressLineSingle: "")
            .mapToAddress(type: .delivery)
        
        let sut = makeSUT(address: address)
        
        let expectation = expectation(description: "addressLine1ErrorSet")
        var cancellables = Set<AnyCancellable>()
        
        XCTAssertFalse(sut.addressLine1HasError)
        sut.addressLine1 = "test"
        sut.addressLine1 = ""
        
        sut.$addressLine1
            .first()
            .receive(on: RunLoop.main)
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 2)
        
        XCTAssertTrue(sut.addressLine1HasError)
    }
    
    // Test when town set to empty, then town has error is true
    func test_whenTownSetEmpty_thenTownHasErrorIsTrue() {
        let address = FoundAddress(addressLine1: "Test", addressLine2: "Test", town: "Test", postcode: "TEST", countryCode: "UK", county: "Surrey", addressLineSingle: "")
            .mapToAddress(type: .delivery)
        
        let sut = makeSUT(address: address)
        
        let expectation = expectation(description: "townErrorSet")
        var cancellables = Set<AnyCancellable>()
        
        XCTAssertFalse(sut.townHasError)
        sut.town = "test"
        sut.town = ""
        
        sut.$town
            .first()
            .receive(on: RunLoop.main)
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 2)
        
        XCTAssertTrue(sut.townHasError)
    }
    
    // Test when postcode set to empty, then postcode has error is true
    func test_whenPostcodeSetEmpty_thenPostcodeHasErrorIsTrue() {
        let address = FoundAddress(addressLine1: "Test", addressLine2: "Test", town: "Test", postcode: "TEST", countryCode: "UK", county: "Surrey", addressLineSingle: "")
            .mapToAddress(type: .delivery)
        
        let sut = makeSUT(address: address)
        
        let expectation = expectation(description: "postcodeErrorSet")
        var cancellables = Set<AnyCancellable>()
        
        XCTAssertFalse(sut.postcodeHasError)
        sut.postcode = "test"
        sut.postcode = ""
        
        sut.$postcode
            .first()
            .receive(on: RunLoop.main)
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 2)
        
        XCTAssertTrue(sut.postcodeHasError)
    }
    
    // Test if saved addresses tapped and addressNicknameIsEmpty then set errors
    func test_whenSaveAddressesTapped_givenAddressNicknameIsEmpty_thenSetErrors() async {
        let address = FoundAddress(addressLine1: "Test", addressLine2: "Test", town: "Test", postcode: "TEST", countryCode: "UK", county: "Surrey", addressLineSingle: "")
            .mapToAddress(type: .delivery)
        
        let sut = makeSUT(address: address)
        
        sut.addressNickname = ""
        sut.addressLine1 = "test"
        sut.town = "test"
        sut.postcode = "test"
        
        XCTAssertFalse(sut.addressNicknameHasError)
        
        var addressSaved = false
        
        await sut.saveAddressTapped(addressSaved: {
            addressSaved = true // shoud not reach this
        })
        
        XCTAssertFalse(addressSaved)
        XCTAssertTrue(sut.addressNicknameHasError)
        XCTAssertEqual(sut.error as? FormError, FormError.missingDetails)
    }
    
    // Test if saved addresses tapped and addressLine1 then set errors
    func test_whenSaveAddressesTapped_givenAddressLine1IsEmpty_thenSetErrors() async {
        let address = FoundAddress(addressLine1: "Test", addressLine2: "Test", town: "Test", postcode: "TEST", countryCode: "UK", county: "Surrey", addressLineSingle: "")
            .mapToAddress(type: .delivery)
        
        let sut = makeSUT(address: address)
        
        sut.addressNickname = "test"
        sut.addressLine1 = ""
        sut.town = "test"
        sut.postcode = "test"
        
        XCTAssertFalse(sut.addressLine1HasError)
        
        var addressSaved = false
        
        await sut.saveAddressTapped(addressSaved: {
            addressSaved = true // shoud not reach this
        })
        
        XCTAssertFalse(addressSaved)
        XCTAssertTrue(sut.addressLine1HasError)
        XCTAssertEqual(sut.error as? FormError, FormError.missingDetails)
    }
    
    // Test if saved addresses tapped and town then set errors
    func test_whenSaveAddressesTapped_givenTownIsEmpty_thenSetErrors() async {
        let address = FoundAddress(addressLine1: "Test", addressLine2: "Test", town: "Test", postcode: "TEST", countryCode: "UK", county: "Surrey", addressLineSingle: "")
            .mapToAddress(type: .delivery)
        
        let sut = makeSUT(address: address)
        
        sut.addressNickname = "test"
        sut.addressLine1 = "test"
        sut.town = ""
        sut.postcode = "test"
        
        XCTAssertFalse(sut.townHasError)
        var addressSaved = false
        
        await sut.saveAddressTapped(addressSaved: {
            addressSaved = true // shoud not reach this
        })
        
        XCTAssertFalse(addressSaved)
        XCTAssertTrue(sut.townHasError)
        XCTAssertEqual(sut.error as? FormError, FormError.missingDetails)
    }
    
    // Test if saved addresses tapped and postcode then set errors
    func test_whenSaveAddressesTapped_givenPostcodeIsEmpty_thenSetErrors() async {
        let address = FoundAddress(addressLine1: "Test", addressLine2: "Test", town: "Test", postcode: "TEST", countryCode: "UK", county: "Surrey", addressLineSingle: "")
            .mapToAddress(type: .delivery)
        
        let sut = makeSUT(address: address)
        
        sut.addressNickname = "test"
        sut.addressLine1 = "test"
        sut.town = "test"
        sut.postcode = ""
        
        XCTAssertFalse(sut.postcodeHasError)
        
        var addressSaved = false
        
        await sut.saveAddressTapped(addressSaved: {
            addressSaved = true // shoud not reach this
        })
        
        XCTAssertFalse(addressSaved)
        XCTAssertTrue(sut.postcodeHasError)
        XCTAssertEqual(sut.error as? FormError, FormError.missingDetails)
    }
    
    // Add delivery address when all details complete
    func test_whenSaveAddressTapped_givenNoFieldErrorsAndTypeIsDelivery_thenAddAddressCalled() async {
        let address = FoundAddress(addressLine1: "Test", addressLine2: "Test", town: "Test", postcode: "TEST", countryCode: "UK", county: "Surrey", addressLineSingle: "")
            .mapToAddress(isDefault: false, addressName: "Home Address", type: .delivery)
        
        let container = DIContainer(appState: AppState(), eventLogger: MockedEventLogger(), services: .mocked(memberService: [.addAddress(address: address)]))
        
        let sut = makeSUT(container: container, address: address)
        
        let country = AddressSelectionCountry(countryCode: "UK", countryName: "United Kingdom", billingEnabled: true, fulfilmentEnabled: true)
        
        sut.addressNickname = "Home Address"
        sut.addressLine1 = "Test"
        sut.town = "Test"
        sut.postcode = "TEST"
        sut.countrySelected(country)

        var addressSaved = false
        
        await sut.saveAddressTapped(addressSaved: {
            addressSaved = true // should trigger
        })
        
        XCTAssertTrue(addressSaved)
        container.services.verify(as: .member)
    }
    
    
    // Add billing address when all details complete
    func test_whenSaveAddressTapped_givenNoFieldErrorsAndTypeIsBilling_thenAddAddressCalled() async {
        let address = FoundAddress(addressLine1: "Test", addressLine2: "Test", town: "Test", postcode: "TEST", countryCode: "UK", county: "Surrey", addressLineSingle: "")
            .mapToAddress(isDefault: false, addressName: "Home Address", type: .billing)
        
        let container = DIContainer(appState: AppState(), eventLogger: MockedEventLogger(), services: .mocked(memberService: [.addAddress(address: address)]))
        
        let sut = makeSUT(container: container, address: address, addressType: .billing)
        
        let country = AddressSelectionCountry(countryCode: "UK", countryName: "United Kingdom", billingEnabled: true, fulfilmentEnabled: true)
        
        sut.addressNickname = "Home Address"
        sut.addressLine1 = "Test"
        sut.town = "Test"
        sut.postcode = "TEST"
        sut.countrySelected(country)

        var addressSaved = false
        
        await sut.saveAddressTapped(addressSaved: {
            addressSaved = true // should trigger
        })
        
        XCTAssertTrue(addressSaved)
        container.services.verify(as: .member)
    }
    
    // Update billing address when all details complete
    func test_whenSaveAddressTapped_givenNoFieldErrorsAndTypeIsBillingAndViewStateIsEdit_thenUpdateAddressCalled() async {
        let address = FoundAddress(addressLine1: "Test", addressLine2: "Test", town: "Test", postcode: "TEST", countryCode: "UK", county: "Surrey", addressLineSingle: "")
            .mapToAddress(isDefault: false, addressName: "Home Address", type: .billing)
        
        let container = DIContainer(appState: AppState(), eventLogger: MockedEventLogger(), services: .mocked(memberService: [.updateAddress(address: address)]))
        
        let sut = makeSUT(container: container, address: address, addressType: .billing, viewState: .editAddress)
        
        let country = AddressSelectionCountry(countryCode: "UK", countryName: "United Kingdom", billingEnabled: true, fulfilmentEnabled: true)
        
        sut.addressNickname = "Home Address"
        sut.addressLine1 = "Test"
        sut.town = "Test"
        sut.postcode = "TEST"
        sut.countrySelected(country)

        var addressSaved = false
        
        await sut.saveAddressTapped(addressSaved: {
            addressSaved = true // should trigger
        })
        
        XCTAssertTrue(addressSaved)
        container.services.verify(as: .member)
    }
    
    // Update delivery address when all details complete
    func test_whenSaveAddressTapped_givenNoFieldErrorsAndTypeIsDeliveryAndViewStateIsEdit_thenUpdateAddressCalled() async {
        let address = FoundAddress(addressLine1: "Test", addressLine2: "Test", town: "Test", postcode: "TEST", countryCode: "UK", county: "Surrey", addressLineSingle: "")
            .mapToAddress(isDefault: false, addressName: "Home Address", type: .delivery)
        
        let container = DIContainer(appState: AppState(), eventLogger: MockedEventLogger(), services: .mocked(memberService: [.updateAddress(address: address)]))
        
        let sut = makeSUT(container: container, address: address, addressType: .delivery, viewState: .editAddress)
        
        let country = AddressSelectionCountry(countryCode: "UK", countryName: "United Kingdom", billingEnabled: true, fulfilmentEnabled: true)
        
        sut.addressNickname = "Home Address"
        sut.addressLine1 = "Test"
        sut.town = "Test"
        sut.postcode = "TEST"
        sut.countrySelected(country)

        var addressSaved = false
        
        await sut.saveAddressTapped(addressSaved: {
            addressSaved = true // should trigger
        })
        
        XCTAssertTrue(addressSaved)
        container.services.verify(as: .member)
    }
    
    func makeSUT(container: DIContainer = DIContainer(appState: AppState(), eventLogger: MockedEventLogger(), services: .mocked()), address: Address, addressType: AddressType = .delivery, viewState: ManualInputAddressViewModel.ViewState = .addAddress) -> ManualInputAddressViewModel {
        let sut = ManualInputAddressViewModel(container: container, address: address, addressType: addressType, viewState: viewState)
        
        trackForMemoryLeaks(sut)
        
        return sut
    }
}
