//
//  EditAddressViewModelTests.swift
//  SnappyV2Tests
//
//  Created by David Bage on 18/07/2022.
//

import XCTest
import Combine
@testable import SnappyV2
import SwiftUI

@MainActor
class EditAddressViewModelTests: XCTestCase {
    
    func test_whenBasketAddressIsPresent_thenDeliveryEmailMatches() {
        let container = DIContainer(appState: AppState(), eventLogger: MockedEventLogger(), services: .mocked())
        container.appState.value.userData.basket = Basket.mockedDataWithAddresses
        let sut = makeSUT(container: container, addressType: .delivery)
        
        XCTAssertEqual(sut.contactEmail, "kevin.dover@me.com")
    }
    
    func test_whenBasketAddressIsPresent_thenDeliveryPhoneMatches() {
        let container = DIContainer(appState: AppState(), eventLogger: MockedEventLogger(), services: .mocked())
        container.appState.value.userData.basket = Basket.mockedDataWithAddresses
        let sut = makeSUT(container: container, addressType: .delivery)
        
        XCTAssertEqual(sut.contactPhone, "07925304522")
    }
    
    func test_whenFulfilmentMethodPopulateInAppState_thenFulfilmentTypePopulated() {
        let container = DIContainer(appState: AppState(), eventLogger: MockedEventLogger(), services: .mocked())
        container.appState.value.userData.selectedFulfilmentMethod = .collection
        
        let sut = makeSUT(container: container, addressType: .delivery)
        XCTAssertEqual(sut.fulfilmentType, .collection)
    }
    
    func test_whenMemberProfileIsNil_thenSavedAddressesIsNil() {
        let sut = makeSUT(addressType: .delivery)
        XCTAssertEqual(sut.savedAddresses, [])
    }
    
    func test_whenProfileIsPresent_givenNoAddresses_thenSavedAddressesIsNil() {
        let container = DIContainer(appState: AppState(), eventLogger: MockedEventLogger(), services: .mocked())
        
        container.appState.value.userData.memberProfile = MemberProfile.mockedDataNoAddresses
        
        let sut = makeSUT(container: container, addressType: .delivery)
        XCTAssertEqual(sut.savedAddresses, [])
    }
    
    func test_whenMemberProfileIsPresentAndSavedAddressesPresent_givenAddressTypeIsDelivery_thenSavedAddressesSetToSavedDeliveryAddresses() {
        let container = DIContainer(appState: AppState(), eventLogger: MockedEventLogger(), services: .mocked())
        container.appState.value.userData.memberProfile = MemberProfile.mockedData
        let sut = makeSUT(container: container, addressType: .delivery)
        
        let deliveryAddresses = Address.mockedSavedAddressesArray.filter { $0.type == .delivery }
        
        XCTAssertEqual(sut.savedAddresses, deliveryAddresses)
    }
    
    func test_whenMemberProfileIsPresentAndSavedAddressesPresent_givenAddressTypeIsBilling_thenSavedAddressesSetToSavedBillingAddresses() {
        let container = DIContainer(appState: AppState(), eventLogger: MockedEventLogger(), services: .mocked())
        container.appState.value.userData.memberProfile = MemberProfile.mockedData
        let sut = makeSUT(container: container, addressType: .billing)
        
        let billingAddresses = Address.mockedSavedAddressesArray.filter { $0.type == .billing }
        
        XCTAssertEqual(sut.savedAddresses, billingAddresses)
    }
    
    func test_whenMemberProfileIsPresentAndSavedAddressesIsEmpty_thenSavedAddressesIsNil() {
        let container = DIContainer(appState: AppState(), eventLogger: MockedEventLogger(), services: .mocked())
        container.appState.value.userData.memberProfile = MemberProfile.mockedDataEmptySavedAddresses
        let sut = makeSUT(container: container, addressType: .billing)

        XCTAssertEqual(sut.savedAddresses, [])
    }
    
    func test_whenMemberProfilePresent_thenUserLoggedInIsTrue() {
        let container = DIContainer(appState: AppState(), eventLogger: MockedEventLogger(), services: .mocked())
        container.appState.value.userData.memberProfile = MemberProfile.mockedDataEmptySavedAddresses
        let sut = makeSUT(container: container, addressType: .delivery)
        XCTAssertTrue(sut.userLoggedIn)
    }
    
    func test_whenMemberProfileNotPresent_thenUserLoggedInIsFalse() {
        let container = DIContainer(appState: AppState(), eventLogger: MockedEventLogger(), services: .mocked())
        let sut = makeSUT(container: container, addressType: .delivery)
        XCTAssertFalse(sut.userLoggedIn)
    }
    
    func test_whenMemberprofileUpdatedInAppState_thenLocalMemberProfileSet() {
        let container = DIContainer(appState: AppState(), eventLogger: MockedEventLogger(), services: .mocked())
        let sut = makeSUT(container: container, addressType: .delivery)
        
        let expectation = expectation(description: "memberProfileUpdated")
        var cancellables = Set<AnyCancellable>()
        
        container.appState.value.userData.memberProfile = MemberProfile.mockedData
        
        sut.$memberProfile
            .first()
            .receive(on: RunLoop.main)
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 2)
        
        XCTAssertEqual(sut.memberProfile, MemberProfile.mockedData)
    }
    
    func test_whenMemberprofileUpdatedToNilInAppState_thenLocalMemberProfileSetToNil() {
        let container = DIContainer(appState: AppState(), eventLogger: MockedEventLogger(), services: .mocked())
        let sut = makeSUT(container: container, addressType: .delivery)
        
        let expectation = expectation(description: "memberProfileUpdated")
        var cancellables = Set<AnyCancellable>()
        
        container.appState.value.userData.memberProfile = nil

        sut.$memberProfile
            .first()
            .receive(on: RunLoop.main)
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 2)
        
        XCTAssertNil(sut.memberProfile)
    }

    func test_whenFindByPostcodeTapped_givenContactDetailsAreAllPresent_PostcodeHasWarningIsFalseSearchingForAddressesIsTrueAndCallsTriggered() async {
        let container = DIContainer(appState: AppState(), eventLogger: MockedEventLogger(), services: .mocked(addressService: [.getSelectionCountries, .findAddressesAsync(postcode: "GU99EP", countryCode: "UK")]))
        
        container.appState.value.userData.basket = Basket.mockedData
        
        let sut = makeSUT(container: container, addressType: .delivery)

        sut.postcodeText = "GU99EP"
        await sut.findByPostcodeTapped(setContactDetails: {}, errorHandler: {_ in })
        
        container.services.verify(as: .address)
    }
    
    func test_whenFindByPostcodeTapped_givenContactDetailsAreMissing_thenShowMissingDetailsAlertTrue() async {
        let container = DIContainer(appState: AppState(), eventLogger: MockedEventLogger(), services: .mocked())
        let sut = makeSUT(container: container, addressType: .delivery)
        
        var errorSet = false
        var contactDetailsSet = false
        
        await sut.findByPostcodeTapped(setContactDetails: {
            contactDetailsSet = true
        }, errorHandler: {_ in 
            errorSet = true
        })
        
        XCTAssertFalse(errorSet)
        XCTAssertTrue(contactDetailsSet)
    }
    
    func test_whenCountrySelectedCalled_thenCountrySet() {
        let container = DIContainer(appState: AppState(), eventLogger: MockedEventLogger(), services: .mocked())
        let sut = makeSUT(container: container, addressType: .delivery)
        
        let country = AddressSelectionCountry(countryCode: "ES", countryName: "Spain", billingEnabled: true, fulfilmentEnabled: true)
        
        sut.countrySelected(country)
        
        XCTAssertEqual(sut.selectedCountry, country)
    }
    
    func test_whenSetAddressCalled_givenAddressTypeIsDelivery_thenSetDelivery() async {
        let country = AddressSelectionCountry(countryCode: "UK", countryName: "United Kingdom", billingEnabled: true, fulfilmentEnabled: true)
        
        let basketAddressRequest = BasketAddressRequest(
            firstName: "Johnny",
            lastName: "BGood",
            addressLine1: "Test Address Line 1",
            addressLine2: "Test Address Line 2",
            town: "Test City",
            postcode: "TES TING",
            countryCode: country.countryCode,
            type: "delivery",
            email: "test@test.com",
            telephone: "02929292929",
            state: nil,
            county: "",
            location: nil)
        
        let container = DIContainer(appState: AppState(), eventLogger: MockedEventLogger(), services: .mocked(basketService: [.setDeliveryAddress(address: basketAddressRequest)]))
        
        container.appState.value.userData.basket = Basket.mockedData
        
        let sut = makeSUT(container: container, addressType: .delivery)
        
        sut.firstNameText = "Johnny"
        sut.lastNameText = "BGood"
        sut.addressLine1Text = "Test Address Line 1"
        sut.addressLine2Text = "Test Address Line 2"
        sut.cityText = "Test City"
        sut.postcodeText = "TES TING"
        sut.selectedCountry = country
        sut.countryText = "GB"
        
        do {
            try await sut.setAddress(email: "test@test.com", phone: "02929292929")
            container.services.verify(as: .basket)
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
    
    func test_whenSetAddressCalled_givenAddressTypeIsBillingAndBillingSameAsDeliveryIsFalse_thenSetBilling() async {
        let country = AddressSelectionCountry(countryCode: "UK", countryName: "United Kingdom", billingEnabled: true, fulfilmentEnabled: true)
        
        let basketAddressRequest = BasketAddressRequest(
            firstName: "Johnny",
            lastName: "BGood",
            addressLine1: "Test Address Line 1",
            addressLine2: "Test Address Line 2",
            town: "Test City",
            postcode: "TES TING",
            countryCode: country.countryCode,
            type: "billing",
            email: "test@test.com",
            telephone: "02929292929",
            state: nil,
            county: "",
            location: nil)
        
        let container = DIContainer(appState: AppState(), eventLogger: MockedEventLogger(), services: .mocked(basketService: [.setBillingAddress(address: basketAddressRequest)]))
        
        container.appState.value.userData.basket = Basket.mockedData
        
        let sut = makeSUT(container: container, addressType: .billing)
        sut.useSameBillingAddressAsDelivery = false
        
        sut.firstNameText = "Johnny"
        sut.lastNameText = "BGood"
        sut.addressLine1Text = "Test Address Line 1"
        sut.addressLine2Text = "Test Address Line 2"
        sut.cityText = "Test City"
        sut.postcodeText = "TES TING"
        sut.selectedCountry = country
        sut.countryText = "GB"
        
        do {
            try await sut.setAddress(email: "test@test.com", phone: "02929292929")
            container.services.verify(as: .basket)
        } catch {
            
            XCTFail(error.localizedDescription)
        }
    }
    
    func test_whenSetAddressCalled_givenAddressTypeIsBillingAndBillingSameAsDeliveryIsTrue_thenSetBillingToDeliveryAddress() async {
        let country = AddressSelectionCountry(countryCode: "UK", countryName: "United Kingdom", billingEnabled: true, fulfilmentEnabled: true)
        
        let basketAddressRequest = BasketAddressRequest(
            firstName: "",
            lastName: "",
            addressLine1: "274E Blackness Road",
            addressLine2: "",
            town: "Dundee",
            postcode: "DD2 1RW",
            countryCode: "UK",
            type: "billing",
            email: "test@test.com",
            telephone: "02929292929",
            state: nil,
            county: "",
            location: nil)
        
        let container = DIContainer(appState: AppState(), eventLogger: MockedEventLogger(), services: .mocked(basketService: [.setBillingAddress(address: basketAddressRequest)]))
        
        container.appState.value.userData.basket = Basket.mockedData
        
        let sut = makeSUT(container: container, addressType: .billing)
        sut.useSameBillingAddressAsDelivery = true
        
        sut.firstNameText = "Johnny"
        sut.lastNameText = "BGood"
        sut.addressLine1Text = "Test Address Line 1"
        sut.addressLine2Text = "Test Address Line 2"
        sut.cityText = "Test City"
        sut.postcodeText = "TES TING"
        sut.selectedCountry = country
        
        do {
            try await sut.setAddress(email: "test@test.com", phone: "02929292929")
            container.services.verify(as: .basket)
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
    
    func test_whenResetFieldErrorsPresentCalled_thenFieldErrorsReset() {
        let container = DIContainer(appState: AppState(), eventLogger: MockedEventLogger(), services: .mocked())
        
        container.appState.value.userData.basket = Basket.mockedData
        
        let sut = makeSUT(container: container, addressType: .billing)
        
        sut.resetFieldErrorsPresent()
        XCTAssertFalse(sut.fieldErrorsPresent)
    }
    
    func test_whenCheckFieldCalled_givenFieldIsEmpty_thenRelevantWarningSet() {
        let container = DIContainer(appState: AppState(), eventLogger: MockedEventLogger(), services: .mocked())
        
        container.appState.value.userData.basket = Basket.mockedData
        
        let sut = makeSUT(container: container, addressType: .billing)
        
        sut.checkField(stringToCheck: sut.emailText, fieldHasWarning: &sut.emailHasWarning)
        
        XCTAssertTrue(sut.emailHasWarning)
        
        sut.emailText = "test@test.com"
        
        sut.checkField(stringToCheck: sut.emailText, fieldHasWarning: &sut.emailHasWarning)
        
        XCTAssertFalse(sut.emailHasWarning)
    }
    
    func makeSUT(container: DIContainer = DIContainer(appState: AppState(), eventLogger: MockedEventLogger(), services: .mocked()), addressType: AddressType) -> EditAddressViewModel {
        @ObservedObject var basketViewModel = BasketViewModel(container: .preview)
        let sut = EditAddressViewModel(container: container, addressType: addressType)
        
        trackForMemoryLeaks(sut)
        
        return sut
    }
}
