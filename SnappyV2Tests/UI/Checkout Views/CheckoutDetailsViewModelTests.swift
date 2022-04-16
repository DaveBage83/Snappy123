//
//  CheckoutDetailsViewModelTests.swift
//  SnappyV2Tests
//
//  Created by David Bage on 23/02/2022.
//

import XCTest
import Combine
import SwiftUI
@testable import SnappyV2

class CheckoutDetailsViewModelTests: XCTestCase {
    typealias Checkmark = Image.General.Checkbox
    typealias MarketingStrings = Strings.CheckoutDetails.MarketingPreferences
    
    func test_init_whenNoMemberProfilePresent_thenMemberDetailsAreEmpty() {
        let sut = makeSut()
        
        XCTAssertEqual(sut.firstname, "")
        XCTAssertEqual(sut.surname, "")
        XCTAssertEqual(sut.email, "")
        XCTAssertEqual(sut.phoneNumber, "")
        XCTAssertFalse(sut.isContinueTapped)
        XCTAssertFalse(sut.firstNameHasWarning)
        XCTAssertFalse(sut.surnameHasWarning)
        XCTAssertFalse(sut.emailHasWarning)
        XCTAssertFalse(sut.phoneNumberHasWarning)
        XCTAssertTrue(sut.canSubmit)
        XCTAssertFalse(sut.showCantSetContactDetailsAlert)
        XCTAssertFalse(sut.handlingContinueUpdates)
        XCTAssertNil(sut.profile)
        XCTAssertTrue(sut.errorMessage.isEmpty)
    }
    
    func test_givenBasketWithBillingAddress_thenContactDetailsFilledAtInit() {
        let firstName = "first"
        let lastName = "last"
        let town = "town"
        let postcode = "postcode"
        let type = "billing"
        let email = "email@email.com"
        let telephone = "01929"
        let billingAddressResponse = BasketAddressResponse(firstName: firstName, lastName: lastName, addressLine1: nil, addressLine2: nil, town: town, postcode: postcode, countryCode: nil, type: type, email: email, telephone: telephone, state: nil, county: nil, location: nil)
        let basket = Basket(
            basketToken: "",
            isNewBasket: true,
            items: [],
            fulfilmentMethod: BasketFulfilmentMethod(type: .delivery, cost: 0, minSpend: 0),
            selectedSlot: nil,
            savings: nil,
            coupon: nil,
            fees: nil,
            tips: nil,
            addresses: [billingAddressResponse],
            orderSubtotal: 0,
            orderTotal: 0
        )
        let userData = AppState.UserData(selectedStore: .notRequested, selectedFulfilmentMethod: .delivery, searchResult: .notRequested, basket: basket, currentFulfilmentLocation: nil, tempTodayTimeSlot: nil, basketDeliveryAddress: nil, memberProfile: nil)
        let appState = AppState(system: AppState.System(), routing: AppState.ViewRouting(), businessData: AppState.BusinessData(), userData: userData)
        let container = DIContainer(appState: appState, eventLogger: MockedEventLogger(), services: .mocked())
        let sut = makeSut(container: container)
        
        XCTAssertEqual(sut.firstname, firstName)
        XCTAssertEqual(sut.surname, lastName)
        XCTAssertEqual(sut.email, email)
        XCTAssertEqual(sut.phoneNumber, telephone)
    }
    
    func test_whenAddingBasketWithBillingAddress_thenContactDetailsFilled() {
        let firstName = "first"
        let lastName = "last"
        let town = "town"
        let postcode = "postcode"
        let type = "billing"
        let email = "email@email.com"
        let telephone = "01929"
        let billingAddressResponse = BasketAddressResponse(firstName: firstName, lastName: lastName, addressLine1: nil, addressLine2: nil, town: town, postcode: postcode, countryCode: nil, type: type, email: email, telephone: telephone, state: nil, county: nil, location: nil)
        let basket = Basket(
            basketToken: "",
            isNewBasket: true,
            items: [],
            fulfilmentMethod: BasketFulfilmentMethod(type: .delivery, cost: 0, minSpend: 0),
            selectedSlot: nil,
            savings: nil,
            coupon: nil,
            fees: nil,
            tips: nil,
            addresses: [billingAddressResponse],
            orderSubtotal: 0,
            orderTotal: 0
        )
        let container = DIContainer(appState: AppState(), eventLogger: MockedEventLogger(), services: .mocked())
        let sut = makeSut(container: container)
        
        let exp = expectation(description: "setupDetailsFromBasket")
        var cancellables = Set<AnyCancellable>()

        sut.$phoneNumber
            .first()
            .receive(on: RunLoop.main)
            .sink { _ in
                exp.fulfill()
            }
            .store(in: &cancellables)

        sut.container.appState.value.userData.basket = basket
        
        wait(for: [exp], timeout: 2)
        
        XCTAssertEqual(sut.firstname, firstName)
        XCTAssertEqual(sut.surname, lastName)
        XCTAssertEqual(sut.email, email)
        XCTAssertEqual(sut.phoneNumber, telephone)
    }
    
    func test_init_whenMemberProfilePresent_thenMemberDetailsPopulated() {
        let cancelbag = CancelBag()
        let sut = makeSut(profile: MemberProfile.mockedData)
        let expectation = expectation(description: "userProfileDetailsPopulated")
        
        sut.$profile
            .first()
            .receive(on: RunLoop.main)
            .sink { profile in
                XCTAssertEqual(sut.firstname, "Harold")
                XCTAssertEqual(sut.surname, "Brown")
                XCTAssertEqual(sut.email, "h.brown@gmail.com")
                XCTAssertEqual(sut.phoneNumber, "0792334112")
                expectation.fulfill()
            }
            .store(in: cancelbag)
        
        wait(for: [expectation], timeout: 0.2)
    }
    
    func test_whenProfilePhoneNumberIsEmpty_thenPhoneFieldIsEmpty() {
        let sut = makeSut(profile: MemberProfile.mockedDataNoPhone)
        let cancelbag = CancelBag()
        let expectation = expectation(description: "userProfileDetailsPopulated")
        
        sut.$profile
            .first()
            .receive(on: RunLoop.main)
            .sink { profile in
                XCTAssertEqual(sut.firstname, "Harold")
                XCTAssertEqual(sut.surname, "Brown")
                XCTAssertEqual(sut.email, "h.brown@gmail.com")
                XCTAssertEqual(sut.phoneNumber, "")
                expectation.fulfill()
            }
            .store(in: cancelbag)
        
        wait(for: [expectation], timeout: 0.2)
    }
    
    func test_whenContinueButtonTapped_thenFieldWarningsSet() async {
        let sut = makeSut()
        await sut.continueButtonTapped(updateMarketingPreferences: {} )
        XCTAssertTrue(sut.emailHasWarning)
        XCTAssertTrue(sut.firstNameHasWarning)
        XCTAssertTrue(sut.surnameHasWarning)
        XCTAssertTrue(sut.phoneNumberHasWarning)
        
        sut.firstname = "Test Name"
        sut.surname = "Test Surname"
        sut.email = "test@test.com"
        sut.phoneNumber = "123456"
        
        await sut.continueButtonTapped(updateMarketingPreferences: {})
        XCTAssertFalse(sut.emailHasWarning)
        XCTAssertFalse(sut.firstNameHasWarning)
        XCTAssertFalse(sut.surnameHasWarning)
        XCTAssertFalse(sut.phoneNumberHasWarning)
    }
    
    @MainActor
    func test_givenDetails_whenContinueButtonTapped_thenServiceCallsTriggerAndHandlingFlagsAreAssigned() async throws {
        let firstName = "first"
        let lastName = "last"
        let email = "email@email.com"
        let telephone = "01929"
        
        let contactDetails = BasketContactDetailsRequest(firstName: firstName, lastName: lastName, email: email, telephone: telephone)
        
        let container = DIContainer(appState: AppState(), eventLogger: MockedEventLogger(), services: .mocked(basketService: [.setContactDetails(details: contactDetails)]))
        
        let sut = makeSut(container: container)
        
        sut.firstname = firstName
        sut.surname = lastName
        sut.email = email
        sut.phoneNumber = telephone
        
        await sut.continueButtonTapped(updateMarketingPreferences: {  })
        
        XCTAssertTrue(sut.isContinueTapped)
        
        container.services.verify(as: .basket)
    }
    
    func makeSut(container: DIContainer = DIContainer(appState: AppState(), eventLogger: MockedEventLogger(), services: .mocked()), memberSignedIn: Bool = false, profile: MemberProfile? = nil) -> CheckoutDetailsViewModel {
        
        if let profile = profile {
            container.appState.value.userData.memberProfile = profile
        }
        
        let sut = CheckoutDetailsViewModel(container: container)
        
        trackForMemoryLeaks(sut)
        
        return sut
    }
}
