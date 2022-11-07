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
        let container = DIContainer(appState: AppState(), eventLogger: MockedEventLogger(), services: .mocked(addressService: [.findAddressesAsync(postcode: "GU99EP", countryCode: "UK")]))
        
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
            county: "Surrey",
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
            county: "Surrey",
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
            county: "Surrey",
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
    
    func test_whenAppStateHasBillingAddressInBasket_thenPopulateContactDetails() {
        let container = DIContainer(appState: AppState(), eventLogger: MockedEventLogger(), services: .mocked())
        container.appState.value.userData.basket = .mockedData
        let sut = makeSUT(container: container, addressType: .billing)
        XCTAssertEqual(sut.contactFirstName, "Kevin")
        XCTAssertEqual(sut.contactLastName, "Dover")
        XCTAssertEqual(sut.contactEmail, "kevin.dover@me.com")
        XCTAssertEqual(sut.contactPhone, "07925304522")
    }
    
    func test_whenAppStateHasNoBillingAddressInBasket_thenContactDetailsSetToEmptyStrings() {
        let container = DIContainer(appState: AppState(), eventLogger: MockedEventLogger(), services: .mocked())
        container.appState.value.userData.basket = .mockedDataNoAddresses
        let sut = makeSUT(container: container, addressType: .billing)
        XCTAssertEqual(sut.contactFirstName, "")
        XCTAssertEqual(sut.contactLastName, "")
        XCTAssertEqual(sut.contactEmail, "")
        XCTAssertEqual(sut.contactPhone, "")
    }
    
    func test_whenAddressTypeIsBillingAndFulfilmentIsDelivery_thenShowUseDeliveryAddressForBillingButtonIsTrue() {
        let container = DIContainer(appState: AppState(), eventLogger: MockedEventLogger(), services: .mocked())
        container.appState.value.userData.selectedFulfilmentMethod = .delivery
        let sut = makeSUT(container: container, addressType: .billing)
        XCTAssertTrue(sut.showUseDeliveryAddressForBillingButton)
    }
    
    func test_whenAddressTypeIsDeliveryAndFulfilmentIsDelivery_thenShowUseDeliveryAddressForBillingButtonIsFalse() {
        let container = DIContainer(appState: AppState(), eventLogger: MockedEventLogger(), services: .mocked())
        container.appState.value.userData.selectedFulfilmentMethod = .delivery
        let sut = makeSUT(container: container, addressType: .delivery)
        XCTAssertFalse(sut.showUseDeliveryAddressForBillingButton)
    }
    
    func test_whenAddressTypeIsBillingAndFulfilmentIsCollection_thenShowUseDeliveryAddressForBillingButtonIsFalse() {
        let container = DIContainer(appState: AppState(), eventLogger: MockedEventLogger(), services: .mocked())
        container.appState.value.userData.selectedFulfilmentMethod = .collection
        let sut = makeSUT(container: container, addressType: .billing)
        XCTAssertFalse(sut.showUseDeliveryAddressForBillingButton)
    }
    
    func test_whenAddressTypeIsDelivery_thenShowEditDeliveryAddressOptionTrue() {
        let container = DIContainer(appState: AppState(), eventLogger: MockedEventLogger(), services: .mocked())
        container.appState.value.userData.selectedFulfilmentMethod = .delivery
        let sut = makeSUT(container: container, addressType: .delivery)
        XCTAssertTrue(sut.showEditDeliveryAddressOption)
    }
    
    func test_whenAddressTypeIsBilling_thenShowEditDeliveryAddressOptionFalse() {
        let container = DIContainer(appState: AppState(), eventLogger: MockedEventLogger(), services: .mocked())
        let sut = makeSUT(container: container, addressType: .billing)
        XCTAssertFalse(sut.showEditDeliveryAddressOption)
    }
    
    func test_whenAddressTypeIsDelivery_thenShowAddressFieldsIsTrue() {
        let container = DIContainer(appState: AppState(), eventLogger: MockedEventLogger(), services: .mocked())
        let sut = makeSUT(container: container, addressType: .delivery)
        XCTAssertTrue(sut.showAddressFields)
    }
    
    func test_whenAddressTypeIsBilling_givenUseSameBillingAddressAsDeliveryIsFalse_thenShowAddressFieldsIsTrue() {
        let container = DIContainer(appState: AppState(), eventLogger: MockedEventLogger(), services: .mocked())
        let sut = makeSUT(container: container, addressType: .delivery)
        sut.useSameBillingAddressAsDelivery = false
        XCTAssertTrue(sut.showAddressFields)
    }
    
    func test_whenAddressTypeIsBilling_givengivenUseSameBillingAddressAsDeliveryIsTrue_thenShowAddressFieldsIsFalse() {
        let container = DIContainer(appState: AppState(), eventLogger: MockedEventLogger(), services: .mocked())
        let sut = makeSUT(container: container, addressType: .billing)
        sut.useSameBillingAddressAsDelivery = true
        XCTAssertFalse(sut.showAddressFields)
    }
    
    func test_whenAddressTypeIsCard_givenUseSameCardAddressAsDefaultBillingFalse_thenShowAddressFieldsIsFalse() {
        let container = DIContainer(appState: AppState(), eventLogger: MockedEventLogger(), services: .mocked())
        let sut = makeSUT(container: container, addressType: .card)
        sut.useSameCardAddressAsDefaultBilling = false
        XCTAssertTrue(sut.showAddressFields)
    }
    
    func test_whenAddressTypeIsCard_givenUseSameCardAddressAsDefaultBillingTrue_thenShowAddressFieldsIsFalse() {
        let container = DIContainer(appState: AppState(), eventLogger: MockedEventLogger(), services: .mocked())
        let sut = makeSUT(container: container, addressType: .card)
        sut.useSameCardAddressAsDefaultBilling = true
        XCTAssertFalse(sut.showAddressFields)
    }
    
    func test_whenAddressTypeIsCard_thenShowUseDefaultBillingAddressForCardButtonIsTrue() {
        let container = DIContainer(appState: AppState(), eventLogger: MockedEventLogger(), services: .mocked())
        let sut = makeSUT(container: container, addressType: .card)
        XCTAssertTrue(sut.showUseDefaultBillingAddressForCardButton)
    }
    
    func test_whenAddressTypeIsBilling_thenShowUseDefaultBillingAddressForCardButtonIsTrue() {
        let container = DIContainer(appState: AppState(), eventLogger: MockedEventLogger(), services: .mocked())
        let sut = makeSUT(container: container, addressType: .billing)
        XCTAssertFalse(sut.showUseDefaultBillingAddressForCardButton)
    }
    
    func test_whenAddressTypeIsDelivery_thenShowUseDefaultBillingAddressForCardButtonIsTrue() {
        let container = DIContainer(appState: AppState(), eventLogger: MockedEventLogger(), services: .mocked())
        let sut = makeSUT(container: container, addressType: .delivery)
        XCTAssertFalse(sut.showUseDefaultBillingAddressForCardButton)
    }
    
    func test_whenPostcodeHasWarning_thenFirstErrorIsPostcode() {
        let container = DIContainer(appState: AppState(), eventLogger: MockedEventLogger(), services: .mocked())
        let sut = makeSUT(container: container, addressType: .delivery)
        sut.postcodeHasWarning = true
        sut.addressLine1HasWarning = true
        sut.cityHasWarning = true
        XCTAssertEqual(sut.firstError, .postcode)
    }
    
    func test_whenAddressLine1HasWarning_givenPostcodeDoesNotHaveWarning_thenFirstErrorIsAddressLine1() {
        let container = DIContainer(appState: AppState(), eventLogger: MockedEventLogger(), services: .mocked())
        let sut = makeSUT(container: container, addressType: .delivery)
        sut.addressLine1HasWarning = true
        sut.cityHasWarning = true
        XCTAssertEqual(sut.firstError, .addressLine1)
    }
    
    func test_whenCityHasWarning_givenNeitherPostcodeORAddressLine1HaveWarnings_thenFirstErrorIsCity() {
        let container = DIContainer(appState: AppState(), eventLogger: MockedEventLogger(), services: .mocked())
        let sut = makeSUT(container: container, addressType: .delivery)
        sut.cityHasWarning = true
        XCTAssertEqual(sut.firstError, .city)
    }
    
    func test_whenNoFieldsHaveWarnings_thenFirstErrorIsNil() {
        let container = DIContainer(appState: AppState(), eventLogger: MockedEventLogger(), services: .mocked())
        let sut = makeSUT(container: container, addressType: .delivery)
        XCTAssertNil(sut.firstError)
    }
    
    func test_whenAddressTypeIsCard_thenShowBillingOrDeliveryFieldsIsFalse() {
        let container = DIContainer(appState: AppState(), eventLogger: MockedEventLogger(), services: .mocked())
        let sut = makeSUT(container: container, addressType: .card)
        XCTAssertFalse(sut.showBillingOrDeliveryFields)
    }
    
    func test_whenAddressTypeIsDelivery_thenShowBillingOrDeliveryFieldsIsTrue() {
        let container = DIContainer(appState: AppState(), eventLogger: MockedEventLogger(), services: .mocked())
        let sut = makeSUT(container: container, addressType: .delivery)
        XCTAssertTrue(sut.showBillingOrDeliveryFields)
    }
    
    func test_whenAddressTypeIsBilling_thenShowBillingOrDeliveryFieldsIsTrue() {
        let container = DIContainer(appState: AppState(), eventLogger: MockedEventLogger(), services: .mocked())
        let sut = makeSUT(container: container, addressType: .billing)
        XCTAssertTrue(sut.showBillingOrDeliveryFields)
    }
    
    func test_whenAddressTypeIsBillingAndAddressPassedIn_thenPopulateAddressAccordingly() {
        let sut = makeSUT(addressType: .billing)
        let address = FoundAddress(
            addressLine1: "38 The Comblings",
            addressLine2: "Hattingate Road",
            town: "LemonField",
            postcode: "LEM 02F",
            countryCode: "GB",
            county: "Surrey",
            addressLineSingle: "38 The Comblings, Hattingate Road")
        
        sut.populateFields(address: address)
        XCTAssertEqual(sut.postcodeText, address.postcode)
        XCTAssertEqual(sut.addressLine1Text, address.addressLine1)
        XCTAssertEqual(sut.addressLine2Text, address.addressLine2)
        XCTAssertEqual(sut.cityText, address.town)
        XCTAssertEqual(sut.countyText, address.county)
    }
    
    func test_whenAddressTypeIsBillingAndAddressNotPassedIn_givenBillingAddressPresentinBasketAppState_thenPopulateAddressWithAppStateAddressAccordingly() {
        let container = DIContainer(appState: AppState(), eventLogger: MockedEventLogger(), services: .mocked())
        container.appState.value.userData.basket = .mockedData
        let sut = makeSUT(container: container,
                          addressType: .billing)
        
        sut.populateFields(address: nil)
        XCTAssertEqual(sut.postcodeText, "DD2 1RW")
        XCTAssertEqual(sut.addressLine1Text, "274E Blackness Road")
        XCTAssertEqual(sut.addressLine2Text, "")
        XCTAssertEqual(sut.cityText, "Dundee")
        XCTAssertEqual(sut.countyText, "Surrey")
    }
    
    func test_whenAddressTypeIsDeliveryAndAddressPassedIn_thenPopulateAddressAccordingly() {
        let sut = makeSUT(addressType: .delivery)
        let address = FoundAddress(
            addressLine1: "38 The Comblings",
            addressLine2: "Hattingate Road",
            town: "LemonField",
            postcode: "LEM 02F",
            countryCode: "GB",
            county: "Surrey",
            addressLineSingle: "38 The Comblings, Hattingate Road")
        
        sut.populateFields(address: address)
        XCTAssertEqual(sut.postcodeText, address.postcode)
        XCTAssertEqual(sut.addressLine1Text, address.addressLine1)
        XCTAssertEqual(sut.addressLine2Text, address.addressLine2)
        XCTAssertEqual(sut.cityText, address.town)
        XCTAssertEqual(sut.countyText, address.county)
    }

    func test_whenAddressTypeIsDeliveryAndAddressNotPassedIn_giveDeliveryAddressPresentinBasketAppState_thenPopulateAddressWithAppStateAddressAccordingly() {
        let container = DIContainer(appState: AppState(), eventLogger: MockedEventLogger(), services: .mocked())
        container.appState.value.userData.basket = .mockedData
        let sut = makeSUT(container: container,
                          addressType: .billing)
        
        sut.populateFields(address: nil)
        
        XCTAssertEqual(sut.postcodeText, "DD2 1RW")
        XCTAssertEqual(sut.addressLine1Text, "274E Blackness Road")
        XCTAssertEqual(sut.addressLine2Text, "")
        XCTAssertEqual(sut.cityText, "Dundee")
        XCTAssertEqual(sut.countyText, "Surrey")
    }
    
    func test_whenAddressTypeIsDeliveryAndAddressNotPassedIn_giveNoDeliveryAddressesInBasketAppStateButProfileAddressesPresent_thenPopulateAddressWithProfileDefaultAddress() {
        let container = DIContainer(appState: AppState(), eventLogger: MockedEventLogger(), services: .mocked())
        container.appState.value.userData.memberProfile = .mockedDataWithDefaultAddresses
        let sut = makeSUT(container: container,
                          addressType: .delivery)
        
        sut.populateFields(address: nil)
        
        XCTAssertEqual(sut.postcodeText, "PA34 4AG")
        XCTAssertEqual(sut.addressLine1Text, "SKILLS DEVELOPMENT SCOTLAND")
        XCTAssertEqual(sut.addressLine2Text, "ALBANY STREET")
        XCTAssertEqual(sut.cityText, "OBAN")
        XCTAssertEqual(sut.countyText, "")
    }
    
    func test_whenFieldErrorsPresent_givenAddressTypeBillingAndUseSameBillingAddressAsDeliveryIsFalse_thenReturnErrorTypes() {
        let sut = makeSUT(addressType: .billing)
        sut.useSameBillingAddressAsDelivery = false
        let errors = sut.fieldErrors()
        
        let expectedErrors: [CheckoutRootViewModel.DetailsFormElements] = [
            .postcode, .addressLine1, .city, .firstName, .lastName
        ]
        
        XCTAssertEqual(errors, expectedErrors)
    }
    
    func test_whenFieldErrorsPresent_givenAddressTypeBillingAndUseSameBillingAddressAsDeliveryIsTrue_thenReturnEmptyArray() {
        let sut = makeSUT(addressType: .billing)
        sut.useSameBillingAddressAsDelivery = true
        let errors = sut.fieldErrors()
        
        let expectedErrors = [CheckoutRootViewModel.DetailsFormElements]()
        
        XCTAssertEqual(errors, expectedErrors)
    }
    
    
    func test_whenFieldErrorsPresent_givenAddressTypeDelivery_thenReturnErrorTypes() {
        let sut = makeSUT(addressType: .delivery)
        let errors = sut.fieldErrors()
        
        let expectedErrors: [CheckoutRootViewModel.DetailsFormElements] = [
            .postcode, .addressLine1, .city
        ]
        
        XCTAssertEqual(errors, expectedErrors)
    }
    
    func makeSUT(container: DIContainer = DIContainer(appState: AppState(), eventLogger: MockedEventLogger(), services: .mocked()), addressType: AddressType) -> EditAddressViewModel {
        @ObservedObject var basketViewModel = BasketViewModel(container: .preview)
        let sut = EditAddressViewModel(container: container, addressType: addressType, includeSavedAddressButton: true)
        
        trackForMemoryLeaks(sut)
        
        return sut
    }
}
