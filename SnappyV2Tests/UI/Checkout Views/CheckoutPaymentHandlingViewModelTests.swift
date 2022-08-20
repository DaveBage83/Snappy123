//
//  CheckoutPaymentHandlingViewModelTests.swift
//  SnappyV2Tests
//
//  Created by Henrik Gustavii on 14/03/2022.
//

import XCTest
import Combine
@testable import SnappyV2

import Frames

@MainActor
class CheckoutPaymentHandlingViewModelTests: XCTestCase {
    
    func test_init() {
        let sut = makeSUT()
        
        XCTAssertNil(sut.paymentOutcome)
        XCTAssertTrue(sut.deliveryAddress.isEmpty)
        XCTAssertFalse(sut.settingBillingAddress)
        XCTAssertNil(sut.prefilledAddressName)
        XCTAssertNil(sut.instructions)
        XCTAssertNil(sut.draftOrderFulfilmentDetails)
        XCTAssertTrue(sut.creditCardNumber.isEmpty)
        XCTAssertTrue(sut.creditCardName.isEmpty)
        XCTAssertTrue(sut.creditCardExpiryYear.isEmpty)
        XCTAssertTrue(sut.creditCardExpiryMonth.isEmpty)
        XCTAssertTrue(sut.creditCardCVV.isEmpty)
        XCTAssertNil(sut.shownCardType)
        XCTAssertTrue(sut.showVisaCard)
        XCTAssertTrue(sut.showMasterCardCard)
        XCTAssertTrue(sut.showDiscoverCard)
        XCTAssertTrue(sut.showJCBCard)
        XCTAssertNil(sut.basketTotal)
    }
    
    func test_givenCardTypeIsVisa_whenVisaNumberIsPopulated_thenShowVisaCardIsTrue() {
        let sut = makeSUT()
        sut.creditCardNumber = "4242424242424242" // Visa test number
        
        let expectation = expectation(description: "setupCreditCardNUmber")
        var cancellables = Set<AnyCancellable>()
        
        sut.$creditCardNumber
            .receive(on: RunLoop.main)
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 2)
        
        XCTAssertTrue(sut.showVisaCard)
        XCTAssertFalse(sut.showMasterCardCard)
        XCTAssertFalse(sut.showDiscoverCard)
        XCTAssertFalse(sut.showJCBCard)
    }
    
    func test_givenCardTypeIsMasterCard_whenCardNumberIsPopulated_thenShowMastercardCardIsTrue() {
        let sut = makeSUT()
        sut.creditCardNumber = "5436031030606378" // Mastercard test number
        
        let expectation = expectation(description: "setupCreditCardNUmber")
        var cancellables = Set<AnyCancellable>()
        
        sut.$creditCardNumber
            .receive(on: RunLoop.main)
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 2)
        
        XCTAssertFalse(sut.showVisaCard)
        XCTAssertTrue(sut.showMasterCardCard)
        XCTAssertFalse(sut.showDiscoverCard)
        XCTAssertFalse(sut.showJCBCard)
    }
    
    func test_givenCardTypeIsDiscover_whenCardNumberIsPopulated_thenShowDiscoverCardIsTrue() {
        let sut = makeSUT()
        sut.creditCardNumber = "6011111111111117" // Discover test number
        
        let expectation = expectation(description: "setupCreditCardNUmber")
        var cancellables = Set<AnyCancellable>()
        
        sut.$creditCardNumber
            .receive(on: RunLoop.main)
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 2)
        
        XCTAssertFalse(sut.showVisaCard)
        XCTAssertFalse(sut.showMasterCardCard)
        XCTAssertTrue(sut.showDiscoverCard)
        XCTAssertFalse(sut.showJCBCard)
    }
    
    func test_givenCardTypeIsJCB_whenCardNumberIsPopulated_thenShowJCBCardIsTrue() {
        let sut = makeSUT()
        sut.creditCardNumber = "3530111333300000" // JCB test number
        
        let expectation = expectation(description: "setupCreditCardNUmber")
        var cancellables = Set<AnyCancellable>()
        
        sut.$creditCardNumber
            .receive(on: RunLoop.main)
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 2)
        
        XCTAssertFalse(sut.showVisaCard)
        XCTAssertFalse(sut.showMasterCardCard)
        XCTAssertFalse(sut.showDiscoverCard)
        XCTAssertTrue(sut.showJCBCard)
    }
    
    func test_givenBasketAndStore_whenInit_thenBasketTotalShowsCorrect() {
        var appState = AppState(system: AppState.System(), routing: AppState.ViewRouting(), openViews: AppState.OpenViews(), businessData: AppState.BusinessData(), userData: AppState.UserData(), staticCacheData: AppState.StaticCacheData(), notifications: AppState.Notifications(), pushNotifications: AppState.PushNotifications())
        let basket = Basket.mockedData
        appState.userData.basket = basket
        let selectedStore = RetailStoreDetails.mockedData
        appState.userData.selectedStore = .loaded(selectedStore)
        let container = DIContainer(appState: appState, eventLogger: MockedEventLogger(), services: .mocked())
        let sut = makeSUT(container: container)
        
        XCTAssertEqual(sut.basketTotal, basket.orderTotal.toCurrencyString(using: selectedStore.currency))
    }
    
    func test_givenBasketAndNoStore_whenInit_thenBasketTotalIsNil() {
        var appState = AppState(system: AppState.System(), routing: AppState.ViewRouting(), openViews: AppState.OpenViews(), businessData: AppState.BusinessData(), userData: AppState.UserData(), staticCacheData: AppState.StaticCacheData(), notifications: AppState.Notifications(), pushNotifications: AppState.PushNotifications())
        let basket = Basket.mockedData
        appState.userData.basket = basket
        let container = DIContainer(appState: appState, eventLogger: MockedEventLogger(), services: .mocked())
        let sut = makeSUT(container: container)
        
        XCTAssertNil(sut.basketTotal)
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
            orderTotal: 0,
            storeId: nil,
            basketItemRemoved: nil
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
    
    func test_givenTempTimeSlot_whenContinueButtonTapped_thenSetBillingIsTriggered() async {
        let today = Date().startOfDay
        let slotStartTime = today.addingTimeInterval(60*30)
        let slotEndTime = today.addingTimeInterval(60*60)
        let draftOrderTimeRequest = DraftOrderFulfilmentDetailsTimeRequest(date: today.dateOnlyString(storeTimeZone: nil), requestedTime: "\(slotStartTime.hourMinutesString(timeZone: nil)) - \(slotEndTime.hourMinutesString(timeZone: nil))")
        let draftOrderDetailRequest = DraftOrderFulfilmentDetailsRequest(time: draftOrderTimeRequest, place: nil)
        let tempTodayTimeSlot = RetailStoreSlotDayTimeSlot(slotId: "123", startTime: slotStartTime, endTime: slotEndTime, daytime: "", info: RetailStoreSlotDayTimeSlotInfo(status: "", isAsap: true, price: 5, fulfilmentIn: ""))
        let userData = AppState.UserData(selectedStore: .notRequested, selectedFulfilmentMethod: .delivery, searchResult: .notRequested, basket: nil, currentFulfilmentLocation: nil, tempTodayTimeSlot: tempTodayTimeSlot, basketDeliveryAddress: nil, memberProfile: nil)
        let appState = AppState(system: AppState.System(), routing: AppState.ViewRouting(), businessData: AppState.BusinessData(), userData: userData)
        let container = DIContainer(appState: appState, eventLogger: MockedEventLogger(), services: .mocked())
        var setBillingTriggered: Bool = false
        let sut = makeSUT(container: container)
        
        await sut.continueButtonTapped(setBilling: { setBillingTriggered = true }, errorHandler: {_ in })
        
        XCTAssertTrue(setBillingTriggered)
        XCTAssertEqual(sut.draftOrderFulfilmentDetails, draftOrderDetailRequest)
    }
    
    func test_givenBasketTimeSlotAndStoreWithCheckoutcom_whenContinueButtonTappedAndBusinessOrderIdReturned_thenCorrectCallsAreMadeAndStateSuccessful() async {
        let selectedStore = RetailStoreDetails.mockedDataWithCheckoutComApplePay
        let cardDetails = CardDetails.mockedCard
        let today = Date().startOfDay
        let slotStartTime = today.addingTimeInterval(60*30)
        let slotEndTime = today.addingTimeInterval(60*60)
        let draftOrderTimeRequest = DraftOrderFulfilmentDetailsTimeRequest(date: today.dateOnlyString(storeTimeZone: nil), requestedTime: "\(slotStartTime.hourMinutesString(timeZone: nil)) - \(slotEndTime.hourMinutesString(timeZone: nil))")
        let draftOrderDetailRequest = DraftOrderFulfilmentDetailsRequest(time: draftOrderTimeRequest, place: nil)
        let basket = Basket(basketToken: "", isNewBasket: true, items: [], fulfilmentMethod: BasketFulfilmentMethod(type: .delivery, cost: 1.5, minSpend: 0), selectedSlot: BasketSelectedSlot(todaySelected: true, start: slotStartTime, end: slotEndTime, expires: nil), savings: nil, coupon: nil, fees: nil, tips: nil, addresses: nil, orderSubtotal: 10, orderTotal: 11, storeId: nil, basketItemRemoved: nil)
        let userData = AppState.UserData(selectedStore: .loaded(selectedStore), selectedFulfilmentMethod: .delivery, searchResult: .notRequested, basket: basket, currentFulfilmentLocation: nil, tempTodayTimeSlot: nil, basketDeliveryAddress: nil, memberProfile: nil)
        let appState = AppState(system: AppState.System(), routing: AppState.ViewRouting(), businessData: AppState.BusinessData(), userData: userData)
        let checkoutService = MockedCheckoutService(expected: [.processCardPaymentOrder(fulfilmentDetails: draftOrderDetailRequest, paymentGatewayType: PaymentGatewayType.checkoutcom, paymentGatewayMode: .sandbox, instructions: nil, publicKey: selectedStore.paymentGateways?.first?.fields?["publicKey"] as? String ?? "", cardDetails: cardDetails)])
        checkoutService.processCardPaymentOrderResult = (1234, nil)
        let services = DIContainer.Services(
            businessProfileService: MockedBusinessProfileService(expected: []),
            retailStoreService: MockedRetailStoreService(expected: []),
            retailStoreMenuService: MockedRetailStoreMenuService(expected: []),
            basketService: MockedBasketService(expected: []),
            userService: MockedUserService(expected: []),
            checkoutService: checkoutService,
            addressService: MockedAddressService(expected: []),
            utilityService: MockedUtilityService(expected: []),
            imageService: MockedImageService(expected: []),
            notificationService: MockedNotificationService(expected: [])
        )
        let container = DIContainer(appState: appState, eventLogger: MockedEventLogger(), services: services)
        var setBillingTriggered: Bool = false
        let sut = makeSUT(container: container)
        sut.creditCardName = cardDetails.cardName
        sut.creditCardNumber = cardDetails.number
        sut.creditCardExpiryMonth = cardDetails.expiryMonth
        sut.creditCardExpiryYear = cardDetails.expiryYear
        sut.creditCardCVV = cardDetails.cvv
        
        await sut.continueButtonTapped(setBilling: { setBillingTriggered = true }, errorHandler: {_ in })
        
        XCTAssertTrue(setBillingTriggered)
        XCTAssertEqual(sut.draftOrderFulfilmentDetails, draftOrderDetailRequest)
        XCTAssertEqual(sut.paymentOutcome, .successful)
        container.services.verify(as: .checkout)
    }
    
    func test_givenBasketTimeSlotAndStoreWithCheckoutcom_whenContinueButtonTappedAndUrlsReturned_thenCorrectCallsAreMadeAndUrlsAreFilledAndStateDoesNotChange() async {
        let selectedStore = RetailStoreDetails.mockedDataWithCheckoutComApplePay
        let cardDetails = CardDetails.mockedCard
        let today = Date().startOfDay
        let slotStartTime = today.addingTimeInterval(60*30)
        let slotEndTime = today.addingTimeInterval(60*60)
        let draftOrderTimeRequest = DraftOrderFulfilmentDetailsTimeRequest(date: today.dateOnlyString(storeTimeZone: nil), requestedTime: "\(slotStartTime.hourMinutesString(timeZone: nil)) - \(slotEndTime.hourMinutesString(timeZone: nil))")
        let draftOrderDetailRequest = DraftOrderFulfilmentDetailsRequest(time: draftOrderTimeRequest, place: nil)
        let basket = Basket(basketToken: "", isNewBasket: true, items: [], fulfilmentMethod: BasketFulfilmentMethod(type: .delivery, cost: 1.5, minSpend: 0), selectedSlot: BasketSelectedSlot(todaySelected: true, start: slotStartTime, end: slotEndTime, expires: nil), savings: nil, coupon: nil, fees: nil, tips: nil, addresses: nil, orderSubtotal: 10, orderTotal: 11, storeId: nil, basketItemRemoved: nil)
        let userData = AppState.UserData(selectedStore: .loaded(selectedStore), selectedFulfilmentMethod: .delivery, searchResult: .notRequested, basket: basket, currentFulfilmentLocation: nil, tempTodayTimeSlot: nil, basketDeliveryAddress: nil, memberProfile: nil)
        let appState = AppState(system: AppState.System(), routing: AppState.ViewRouting(), businessData: AppState.BusinessData(), userData: userData)
        let checkoutService = MockedCheckoutService(expected: [.processCardPaymentOrder(fulfilmentDetails: draftOrderDetailRequest, paymentGatewayType: PaymentGatewayType.checkoutcom, paymentGatewayMode: .sandbox, instructions: nil, publicKey: selectedStore.paymentGateways?.first?.fields?["publicKey"] as? String ?? "", cardDetails: cardDetails)])
        let urls = CheckoutCom3DSURLs(redirectUrl: URL(string: "redirectURL")!, successUrl: URL(string: "successURL")!, failUrl: URL(string: "failURL")!)
        checkoutService.processCardPaymentOrderResult = (nil, urls)
        let services = DIContainer.Services(
            businessProfileService: MockedBusinessProfileService(expected: []),
            retailStoreService: MockedRetailStoreService(expected: []),
            retailStoreMenuService: MockedRetailStoreMenuService(expected: []),
            basketService: MockedBasketService(expected: []),
            userService: MockedUserService(expected: []),
            checkoutService: checkoutService,
            addressService: MockedAddressService(expected: []),
            utilityService: MockedUtilityService(expected: []),
            imageService: MockedImageService(expected: []),
            notificationService: MockedNotificationService(expected: [])
        )
        let container = DIContainer(appState: appState, eventLogger: MockedEventLogger(), services: services)
        var setBillingTriggered: Bool = false
        let sut = makeSUT(container: container)
        sut.creditCardName = cardDetails.cardName
        sut.creditCardNumber = cardDetails.number
        sut.creditCardExpiryMonth = cardDetails.expiryMonth
        sut.creditCardExpiryYear = cardDetails.expiryYear
        sut.creditCardCVV = cardDetails.cvv
        
        await sut.continueButtonTapped(setBilling: { setBillingTriggered = true }, errorHandler: {_ in })
        
        XCTAssertTrue(setBillingTriggered)
        XCTAssertEqual(sut.draftOrderFulfilmentDetails, draftOrderDetailRequest)
        XCTAssertNil(sut.paymentOutcome)
        XCTAssertEqual(sut.threeDSWebViewURLs, urls)
        container.services.verify(as: .checkout)
    }
    
    func test_givenBasketTimeSlotAndStoreWithCheckoutcom_whenContinueButtonTappedAndNilsReturned_thenCorrectCallsAndStateIsUnsuccessful() async {
        let selectedStore = RetailStoreDetails.mockedDataWithCheckoutComApplePay
        let cardDetails = CardDetails.mockedCard
        let today = Date().startOfDay
        let slotStartTime = today.addingTimeInterval(60*30)
        let slotEndTime = today.addingTimeInterval(60*60)
        let draftOrderTimeRequest = DraftOrderFulfilmentDetailsTimeRequest(date: today.dateOnlyString(storeTimeZone: nil), requestedTime: "\(slotStartTime.hourMinutesString(timeZone: nil)) - \(slotEndTime.hourMinutesString(timeZone: nil))")
        let draftOrderDetailRequest = DraftOrderFulfilmentDetailsRequest(time: draftOrderTimeRequest, place: nil)
        let basket = Basket(basketToken: "", isNewBasket: true, items: [], fulfilmentMethod: BasketFulfilmentMethod(type: .delivery, cost: 1.5, minSpend: 0), selectedSlot: BasketSelectedSlot(todaySelected: true, start: slotStartTime, end: slotEndTime, expires: nil), savings: nil, coupon: nil, fees: nil, tips: nil, addresses: nil, orderSubtotal: 10, orderTotal: 11, storeId: nil, basketItemRemoved: nil)
        let userData = AppState.UserData(selectedStore: .loaded(selectedStore), selectedFulfilmentMethod: .delivery, searchResult: .notRequested, basket: basket, currentFulfilmentLocation: nil, tempTodayTimeSlot: nil, basketDeliveryAddress: nil, memberProfile: nil)
        let appState = AppState(system: AppState.System(), routing: AppState.ViewRouting(), businessData: AppState.BusinessData(), userData: userData)
        let checkoutService = MockedCheckoutService(expected: [.processCardPaymentOrder(fulfilmentDetails: draftOrderDetailRequest, paymentGatewayType: PaymentGatewayType.checkoutcom, paymentGatewayMode: .sandbox, instructions: nil, publicKey: selectedStore.paymentGateways?.first?.fields?["publicKey"] as? String ?? "", cardDetails: cardDetails)])
        let services = DIContainer.Services(
            businessProfileService: MockedBusinessProfileService(expected: []),
            retailStoreService: MockedRetailStoreService(expected: []),
            retailStoreMenuService: MockedRetailStoreMenuService(expected: []),
            basketService: MockedBasketService(expected: []),
            userService: MockedUserService(expected: []),
            checkoutService: checkoutService,
            addressService: MockedAddressService(expected: []),
            utilityService: MockedUtilityService(expected: []),
            imageService: MockedImageService(expected: []),
            notificationService: MockedNotificationService(expected: [])
        )
        let container = DIContainer(appState: appState, eventLogger: MockedEventLogger(), services: services)
        var setBillingTriggered: Bool = false
        let sut = makeSUT(container: container)
        sut.creditCardName = cardDetails.cardName
        sut.creditCardNumber = cardDetails.number
        sut.creditCardExpiryMonth = cardDetails.expiryMonth
        sut.creditCardExpiryYear = cardDetails.expiryYear
        sut.creditCardCVV = cardDetails.cvv
        
        await sut.continueButtonTapped(setBilling: { setBillingTriggered = true }, errorHandler: {_ in })
        
        XCTAssertTrue(setBillingTriggered)
        XCTAssertEqual(sut.draftOrderFulfilmentDetails, draftOrderDetailRequest)
        XCTAssertEqual(sut.paymentOutcome, .unsuccessful)
        XCTAssertNil(sut.threeDSWebViewURLs)
        container.services.verify(as: .checkout)
    }
    
    func test_whenThreeDSSuccessTriggered_thenUrlsAreNilAndPaymentOutcomeIsSuccessful() async {
        let container = DIContainer(appState: AppState(), eventLogger: MockedEventLogger(), services: .mocked(checkoutService: [.verifyPayment]))
        let sut = makeSUT(container: container)
        sut.threeDSWebViewURLs = CheckoutCom3DSURLs.mockedData
        
        await sut.threeDSSuccess()
        
        XCTAssertNil(sut.threeDSWebViewURLs)
        XCTAssertEqual(sut.paymentOutcome, .successful)
        container.services.verify(as: .checkout)
    }
    
    func test_whenThreeDSFailTriggered_thenUrlsAreNilAndPaymentOutcomeIsUnsuccessful() {
        let sut = makeSUT()
        sut.threeDSWebViewURLs = CheckoutCom3DSURLs.mockedData
        
        sut.threeDSFail()
        
        XCTAssertNil(sut.threeDSWebViewURLs)
        XCTAssertEqual(sut.paymentOutcome, .unsuccessful)
    }

    func makeSUT(container: DIContainer = DIContainer(appState: AppState(), eventLogger: MockedEventLogger(), services: .mocked())) -> CheckoutPaymentHandlingViewModel {
        let sut = CheckoutPaymentHandlingViewModel(container: container, instructions: nil, paymentSuccess: {}, paymentFailure: {})
        
        trackForMemoryLeaks(sut)
        
        return sut
    }
}


