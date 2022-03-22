//
//  CheckoutPaymentHandlingViewModelTests.swift
//  SnappyV2Tests
//
//  Created by Henrik Gustavii on 14/03/2022.
//

import XCTest
import Combine
@testable import SnappyV2

class CheckoutPaymentHandlingViewModelTests: XCTestCase {
    
    func test_init() {
        let sut = makeSUT()
        
        XCTAssertNil(sut.paymentOutcome)
        XCTAssertTrue(sut.deliveryAddress.isEmpty)
        XCTAssertFalse(sut.isContinueTapped)
        XCTAssertFalse(sut.settingBillingAddress)
        XCTAssertNil(sut.prefilledAddressName)
        XCTAssertNil(sut.instructions)
        XCTAssertNil(sut.draftOrderFulfilmentDetails)
    }
    
    func test_whenSetBillingAddressTriggered_thenSetBillingAddressIsCalled() {
        let billingAddress = BasketAddressRequest(firstName: "first", lastName: "last", addressline1: "line1", addressline2: "line2", town: "town", postcode: "postcode", countryCode: "UK", type: "billing", email: "email@email.com", telephone: "01929", state: nil, county: "county", location: nil)
        let basketContactDetails = BasketContactDetails(firstName: billingAddress.firstName, surname: billingAddress.lastName, email: billingAddress.email, telephoneNumber: billingAddress.telephone)
        let userData = AppState.UserData(selectedStore: .notRequested, selectedFulfilmentMethod: .delivery, searchResult: .notRequested, basket: nil, currentFulfilmentLocation: nil, memberSignedIn: false, basketContactDetails: basketContactDetails, tempTodayTimeSlot: nil, basketDeliveryAddress: nil)
        let appState = AppState(system: AppState.System(), routing: AppState.ViewRouting(), businessData: AppState.BusinessData(), userData: userData)
        let container = DIContainer(appState: appState, services: .mocked(basketService: [.setBillingAddress(address: billingAddress)]))
        let sut = makeSUT(container: container)
        
        let selectedAddress = Address(id: nil, isDefault: nil, addressName: nil, firstName: billingAddress.firstName, lastName: billingAddress.lastName, addressline1: billingAddress.addressline1, addressline2: billingAddress.addressline2, town: billingAddress.town, postcode: billingAddress.postcode, county: billingAddress.county, countryCode: billingAddress.countryCode, type: .delivery, location: nil)

        sut.setBilling(address: selectedAddress)
        
        XCTAssertTrue(sut.settingBillingAddress)
        
        let expectation = expectation(description: "selectedDeliveryAddress")
        var cancellables = Set<AnyCancellable>()

        sut.$settingBillingAddress
            .first()
            .receive(on: RunLoop.main)
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 2)
        
        XCTAssertFalse(sut.continueButtonDisabled)
        XCTAssertFalse(sut.settingBillingAddress)
        container.services.verify()
    }
    
    func test_givenTempTimeSlot_whenContinueButtonTapped_thenIsContinueTappedTrue() {
        let today = Date().startOfDay
        let slotStartTime = today.addingTimeInterval(60*30)
        let slotEndTime = today.addingTimeInterval(60*60)
        let draftOrderTimeRequest = DraftOrderFulfilmentDetailsTimeRequest(date: today.dateOnlyString(storeTimeZone: nil), requestedTime: "\(slotStartTime.hourMinutesString(timeZone: nil)) - \(slotEndTime.hourMinutesString(timeZone: nil))")
        let draftOrderDetailRequest = DraftOrderFulfilmentDetailsRequest(time: draftOrderTimeRequest, place: nil)
        let tempTodayTimeSlot = RetailStoreSlotDayTimeSlot(slotId: "123", startTime: slotStartTime, endTime: slotEndTime, daytime: "", info: RetailStoreSlotDayTimeSlotInfo(status: "", isAsap: true, price: 5, fulfilmentIn: ""))
        let userData = AppState.UserData(selectedStore: .notRequested, selectedFulfilmentMethod: .delivery, searchResult: .notRequested, basket: nil, currentFulfilmentLocation: nil, memberSignedIn: false, basketContactDetails: nil, tempTodayTimeSlot: tempTodayTimeSlot, basketDeliveryAddress: nil)
        let appState = AppState(system: AppState.System(), routing: AppState.ViewRouting(), businessData: AppState.BusinessData(), userData: userData)
        let container = DIContainer(appState: appState, services: .mocked())
        let sut = makeSUT(container: container)
        
        sut.continueButtonTapped()
        
        XCTAssertTrue(sut.isContinueTapped)
        XCTAssertEqual(sut.draftOrderFulfilmentDetails, draftOrderDetailRequest)
    }
    
    func test_givenBasketTimeSlot_whenContinueButtonTapped_thenIsContinueTappedTrue() {
        let today = Date().startOfDay
        let slotStartTime = today.addingTimeInterval(60*30)
        let slotEndTime = today.addingTimeInterval(60*60)
        let draftOrderTimeRequest = DraftOrderFulfilmentDetailsTimeRequest(date: today.dateOnlyString(storeTimeZone: nil), requestedTime: "\(slotStartTime.hourMinutesString(timeZone: nil)) - \(slotEndTime.hourMinutesString(timeZone: nil))")
        let draftOrderDetailRequest = DraftOrderFulfilmentDetailsRequest(time: draftOrderTimeRequest, place: nil)
        let basket = Basket(basketToken: "", isNewBasket: true, items: [], fulfilmentMethod: BasketFulfilmentMethod(type: .delivery, cost: 1.5, minSpend: 0), selectedSlot: BasketSelectedSlot(todaySelected: true, start: slotStartTime, end: slotEndTime, expires: nil), savings: nil, coupon: nil, fees: nil, tips: nil, addresses: nil, orderSubtotal: 10, orderTotal: 11)
        let userData = AppState.UserData(selectedStore: .notRequested, selectedFulfilmentMethod: .delivery, searchResult: .notRequested, basket: basket, currentFulfilmentLocation: nil, memberSignedIn: false, basketContactDetails: nil, tempTodayTimeSlot: nil, basketDeliveryAddress: nil)
        let appState = AppState(system: AppState.System(), routing: AppState.ViewRouting(), businessData: AppState.BusinessData(), userData: userData)
        let container = DIContainer(appState: appState, services: .mocked())
        let sut = makeSUT(container: container)
        
        sut.continueButtonTapped()
        
        XCTAssertTrue(sut.isContinueTapped)
        XCTAssertEqual(sut.draftOrderFulfilmentDetails, draftOrderDetailRequest)
    }
    
    func test_givenBusinessOrderId_whenHandleGlobalPaymentResultCalled_thenOutcomeSuccessful() {
        let sut = makeSUT()
        
        sut.handleGlobalPaymentResult(businessOrderId: 123, error: nil)
        
        XCTAssertEqual(sut.paymentOutcome, .successful)
    }
    
    func test_givenBusinessOrderIdAsNilAndError_whenHandleGlobalPaymentResultCalled_thenOutcomeUnsuccessful() {
        let sut = makeSUT()
        
        sut.handleGlobalPaymentResult(businessOrderId: nil, error: GlobalpaymentsHPPViewInternalError.missingSettingFields(["hppURL"]))
        
        XCTAssertEqual(sut.paymentOutcome, .unsuccessful)
    }

    func makeSUT(container: DIContainer = DIContainer(appState: AppState(), services: .mocked())) -> CheckoutPaymentHandlingViewModel {
        let sut = CheckoutPaymentHandlingViewModel(container: container, instructions: nil)
        
        trackForMemoryLeaks(sut)
        
        return sut
    }
}


