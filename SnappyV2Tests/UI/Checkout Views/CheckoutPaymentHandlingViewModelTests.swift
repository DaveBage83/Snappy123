//
//  CheckoutPaymentHandlingViewModelTests.swift
//  SnappyV2Tests
//
//  Created by Henrik Gustavii on 14/03/2022.
//

import XCTest
import Combine
@testable import SnappyV2

@MainActor
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
    
    func test_whenSetBillingAddressTriggered_thenSetBillingAddressIsCalled() async {
        let firstName = "first"
        let lastName = "last"
        let addressLine1 = "line1"
        let addressLine2 = "line2"
        let town = "town"
        let postcode = "postcode"
        let countryCode = "UK"
        let type = "billing"
        let email = "email@email.com"
        let telephone = "01929"
        let county = "county"
        let billingAddressResponse = BasketAddressResponse(firstName: firstName, lastName: lastName, addressLine1: addressLine1, addressLine2: addressLine2, town: town, postcode: postcode, countryCode: countryCode, type: type, email: email, telephone: telephone, state: nil, county: county, location: nil)
        let billingAddressRequest = BasketAddressRequest(firstName: firstName, lastName: lastName, addressLine1: addressLine1, addressLine2: addressLine2, town: town, postcode: postcode, countryCode: countryCode, type: type, email: email, telephone: telephone, state: nil, county: county, location: nil)
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
        let container = DIContainer(appState: appState, eventLogger: MockedEventLogger(), services: .mocked(basketService: [.setBillingAddress(address: billingAddressRequest)]))
        let sut = makeSUT(container: container)
        
        let selectedAddress = Address(id: nil, isDefault: nil, addressName: nil, firstName: firstName, lastName: lastName, addressLine1: addressLine1, addressLine2: addressLine2, town: town, postcode: postcode, county: county, countryCode: countryCode, type: .delivery, location: nil, email: nil, telephone: nil)
        
        let expectation = expectation(description: "selectedDeliveryAddress")
        var cancellables = Set<AnyCancellable>()

        sut.$basket
            .first()
            .receive(on: RunLoop.main)
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 2)
        
        await sut.setBilling(address: selectedAddress)
        
        XCTAssertFalse(sut.continueButtonDisabled)
        XCTAssertFalse(sut.settingBillingAddress)
        container.services.verify(as: .basket)
    }
    
    func test_givenTempTimeSlot_whenContinueButtonTapped_thenIsContinueTappedTrue() {
        let today = Date().startOfDay
        let slotStartTime = today.addingTimeInterval(60*30)
        let slotEndTime = today.addingTimeInterval(60*60)
        let draftOrderTimeRequest = DraftOrderFulfilmentDetailsTimeRequest(date: today.dateOnlyString(storeTimeZone: nil), requestedTime: "\(slotStartTime.hourMinutesString(timeZone: nil)) - \(slotEndTime.hourMinutesString(timeZone: nil))")
        let draftOrderDetailRequest = DraftOrderFulfilmentDetailsRequest(time: draftOrderTimeRequest, place: nil)
        let tempTodayTimeSlot = RetailStoreSlotDayTimeSlot(slotId: "123", startTime: slotStartTime, endTime: slotEndTime, daytime: "", info: RetailStoreSlotDayTimeSlotInfo(status: "", isAsap: true, price: 5, fulfilmentIn: ""))
        let userData = AppState.UserData(selectedStore: .notRequested, selectedFulfilmentMethod: .delivery, searchResult: .notRequested, basket: nil, currentFulfilmentLocation: nil, tempTodayTimeSlot: tempTodayTimeSlot, basketDeliveryAddress: nil, memberProfile: nil)
        let appState = AppState(system: AppState.System(), routing: AppState.ViewRouting(), businessData: AppState.BusinessData(), userData: userData)
        let container = DIContainer(appState: appState, eventLogger: MockedEventLogger(), services: .mocked())
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
        let userData = AppState.UserData(selectedStore: .notRequested, selectedFulfilmentMethod: .delivery, searchResult: .notRequested, basket: basket, currentFulfilmentLocation: nil, tempTodayTimeSlot: nil, basketDeliveryAddress: nil, memberProfile: nil)
        let appState = AppState(system: AppState.System(), routing: AppState.ViewRouting(), businessData: AppState.BusinessData(), userData: userData)
        let container = DIContainer(appState: appState, eventLogger: MockedEventLogger(), services: .mocked())
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

    func makeSUT(container: DIContainer = DIContainer(appState: AppState(), eventLogger: MockedEventLogger(), services: .mocked())) -> CheckoutPaymentHandlingViewModel {
        let sut = CheckoutPaymentHandlingViewModel(container: container, instructions: nil)
        
        trackForMemoryLeaks(sut)
        
        return sut
    }
}


