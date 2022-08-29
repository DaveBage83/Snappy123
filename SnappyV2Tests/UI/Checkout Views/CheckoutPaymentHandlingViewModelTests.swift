//
//  CheckoutPaymentHandlingViewModelTests.swift
//  SnappyV2Tests
//
//  Created by Henrik Gustavii on 14/03/2022.
//

import XCTest
import Combine
@testable import SnappyV2

// 3rd Party Imports
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
        XCTAssertNil(sut.cardType)
        XCTAssertNil(sut.basketTotal)
        XCTAssertFalse(sut.isUnvalidCardName)
        XCTAssertFalse(sut.isUnvalidCardNumber)
        XCTAssertFalse(sut.isUnvalidExpiry)
        XCTAssertFalse(sut.isUnvalidCVV)
        XCTAssertNil(sut.memberProfile)
        XCTAssertFalse(sut.showCardCamera)
        XCTAssertFalse(sut.handlingPayment)
        XCTAssertNil(sut.error)
        XCTAssertTrue(sut.continueButtonDisabled)
        XCTAssertNil(sut.selectedSavedCard)
        XCTAssertTrue(sut.selectedSavedCardCVV.isEmpty)
        XCTAssertTrue(sut.isUnvalidSelectedCardCVV)
        XCTAssertTrue(sut.showNewCardEntry)
        XCTAssertTrue(sut.savedCardsDetails.isEmpty)
    }
    
    func test_givenCardTypeIsVisa_whenVisaNumberIsPopulated_thenShowVisaCardIsTrue() {
        let sut = makeSUT()
        sut.creditCardNumber = "4242424242424242" // Visa test number
        
        let expectation = expectation(description: "setupCreditCardNumber")
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
        
        let expectation = expectation(description: "setupCreditCardNumber")
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
        
        let expectation = expectation(description: "setupCreditCardNumber")
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
        
        let expectation = expectation(description: "setupCreditCardNumber")
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
    
    func test_givenCorrectCardNumber_thenIsUnvalidCardNumberIsFalse() {
        let sut = makeSUT()
        
        let expectation = expectation(description: "setupCreditCardNumber")
        var cancellables = Set<AnyCancellable>()
        
        sut.$creditCardNumber
            .first()
            .receive(on: RunLoop.main)
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        sut.creditCardNumber = "4242424242424242"
        
        wait(for: [expectation], timeout: 2)
        
        XCTAssertFalse(sut.isUnvalidCardNumber)
    }
    
    func test_givenIncorrectCardNumber_thenIsUnvalidCardNumberIsTrue() {
        let sut = makeSUT()
        
        let expectation = expectation(description: "setupCreditCardNumber")
        var cancellables = Set<AnyCancellable>()
        
        sut.$creditCardNumber
            .first()
            .receive(on: RunLoop.main)
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        sut.creditCardNumber = "4242 4242 4242 4242"
        
        wait(for: [expectation], timeout: 2)
        
        XCTAssertTrue(sut.isUnvalidCardNumber)
    }
    
    func test_givenCorrectCardExpiryMonth_thenIsUnvalidCardExpiryIsFalse() {
        let sut = makeSUT()
        
        let expectation = expectation(description: "setupCreditCardExpiry")
        var cancellables = Set<AnyCancellable>()
        sut.creditCardExpiryYear = "24"
        
        sut.$creditCardExpiryMonth
            .first()
            .receive(on: RunLoop.main)
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        sut.creditCardExpiryMonth = "09"
        
        wait(for: [expectation], timeout: 2)
        
        XCTAssertFalse(sut.isUnvalidExpiry)
    }
    
    func test_givenIncorrectCardExpiryMonth_thenIsUnvalidCardExpiryIsTrue() {
        let sut = makeSUT()
        
        let expectation = expectation(description: "setupCreditCardExpiry")
        var cancellables = Set<AnyCancellable>()
        sut.creditCardExpiryYear = "24"
        
        sut.$creditCardExpiryMonth
            .first()
            .receive(on: RunLoop.main)
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        sut.creditCardExpiryMonth = "13"
        
        wait(for: [expectation], timeout: 2)
        
        XCTAssertTrue(sut.isUnvalidExpiry)
    }
    
    func test_givenCorrectCardExpiryYear_thenIsUnvalidCardExpiryIsFalse() {
        let sut = makeSUT()
        
        let expectation = expectation(description: "setupCreditCardExpiry")
        var cancellables = Set<AnyCancellable>()
        sut.creditCardExpiryMonth = "09"
        
        sut.$creditCardExpiryYear
            .first()
            .receive(on: RunLoop.main)
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        sut.creditCardExpiryYear = "24"
        
        wait(for: [expectation], timeout: 2)
        
        XCTAssertFalse(sut.isUnvalidExpiry)
    }
    
    func test_givenIncorrectCardExpiryYear_thenIsUnvalidCardExpiryIsTrue() {
        let sut = makeSUT()
        
        let expectation = expectation(description: "setupCreditCardExpiry")
        var cancellables = Set<AnyCancellable>()
        sut.creditCardExpiryMonth = "09"
        
        sut.$creditCardExpiryYear
            .first()
            .receive(on: RunLoop.main)
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        sut.creditCardExpiryYear = "14"
        
        wait(for: [expectation], timeout: 2)
        
        XCTAssertTrue(sut.isUnvalidExpiry)
    }
    
    func test_givenCorrectCardCVV_thenIsUnvalidCardCVVIsFalse() {
        let sut = makeSUT()
        
        let expectation = expectation(description: "setupCreditCardCVV")
        var cancellables = Set<AnyCancellable>()
        
        sut.$creditCardCVV
            .first()
            .receive(on: RunLoop.main)
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        sut.creditCardCVV = "100"
        
        wait(for: [expectation], timeout: 2)
        
        XCTAssertFalse(sut.isUnvalidCVV)
    }
    
    func test_givenIncorrectCardCVV_thenIsUnvalidCardCVVIsTrue() {
        let sut = makeSUT()
        sut.creditCardNumber = "4242424242424242"
        
        let expectation = expectation(description: "setupCreditCardCVV")
        var cancellables = Set<AnyCancellable>()
        
        sut.$creditCardCVV
            .first()
            .receive(on: RunLoop.main)
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        sut.creditCardCVV = "1000"
        
        wait(for: [expectation], timeout: 2)
        
        XCTAssertTrue(sut.isUnvalidCVV)
    }
    
    func test_givenIncorrectSelectedCardCVV_thenIsUnvalidCardCVVIsTrue() {
        let sut = makeSUT()
        sut.selectedSavedCard = MemberCardDetails.mockedData
        
        let expectation = expectation(description: "setupSelectedSavedCardCVV")
        var cancellables = Set<AnyCancellable>()
        
        sut.$selectedSavedCardCVV
            .first()
            .receive(on: RunLoop.main)
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        sut.selectedSavedCardCVV = "1000"
        
        wait(for: [expectation], timeout: 2)
        
        XCTAssertTrue(sut.isUnvalidSelectedCardCVV)
    }
    
    func test_givenCorrectDetails_whenAreCardDetailsValidTriggered_thenReturnsTrue() {
        let sut = makeSUT()
        sut.creditCardName = "Some Name"
        sut.creditCardNumber = "4242424242424242"
        sut.creditCardExpiryMonth = "03"
        sut.creditCardExpiryYear = "24"
        sut.creditCardCVV = "100"
        
        XCTAssertTrue(sut.areCardDetailsValid())
    }
    
    func test_givenIncorrectNumberDetails_whenAreCardDetailsValidTriggered_thenReturnsFalse() {
        let sut = makeSUT()
        sut.creditCardName = "Some Name"
        sut.creditCardNumber = "4242 4242 4242 4242"
        sut.creditCardExpiryMonth = "03"
        sut.creditCardExpiryYear = "24"
        sut.creditCardCVV = "100"
        
        XCTAssertFalse(sut.areCardDetailsValid())
    }
    
    func test_givenIncorrectExpiryMonthDetails_whenAreCardDetailsValidTriggered_thenReturnsFalse() {
        let sut = makeSUT()
        sut.creditCardName = "Some Name"
        sut.creditCardNumber = "4242424242424242"
        sut.creditCardExpiryMonth = "13"
        sut.creditCardExpiryYear = "24"
        sut.creditCardCVV = "100"
        
        XCTAssertFalse(sut.areCardDetailsValid())
    }
    
    func test_givenIncorrectExpiryYearDetails_whenAreCardDetailsValidTriggered_thenReturnsFalse() {
        let sut = makeSUT()
        sut.creditCardName = "Some Name"
        sut.creditCardNumber = "4242424242424242"
        sut.creditCardExpiryMonth = "06"
        sut.creditCardExpiryYear = "13"
        sut.creditCardCVV = "100"
        
        XCTAssertFalse(sut.areCardDetailsValid())
    }
    
    func test_givenIncorrectCVVDetails_whenAreCardDetailsValidTriggered_thenReturnsFalse() {
        let sut = makeSUT()
        sut.creditCardName = "Some Name"
        sut.creditCardNumber = "4242424242424242"
        sut.creditCardExpiryMonth = "09"
        sut.creditCardExpiryYear = "24"
        sut.creditCardCVV = "1000"
        
        let expectation = expectation(description: "setupCreditCardNumber")
        var cancellables = Set<AnyCancellable>()
        
        sut.$creditCardNumber
            .first()
            .receive(on: RunLoop.main)
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 2)
        
        XCTAssertFalse(sut.areCardDetailsValid())
    }
    
    func test_givenMissingCardNameDetails_whenAreCardDetailsValidTriggered_thenReturnsFalse() {
        let sut = makeSUT()
        sut.creditCardName = ""
        sut.creditCardNumber = "4242424242424242"
        sut.creditCardExpiryMonth = "09"
        sut.creditCardExpiryYear = "24"
        sut.creditCardCVV = "100"
        
        XCTAssertFalse(sut.areCardDetailsValid())
    }
    
    func test_givenMissingSelectedCardCVV_whenAreCardDetailsValidTriggered_thenReturnsFalse() {
        let sut = makeSUT()
        sut.selectedSavedCard = MemberCardDetails.mockedData
        
        let expectation = expectation(description: "setupSelectedSavedCardCVV")
        var cancellables = Set<AnyCancellable>()
        
        sut.$selectedSavedCardCVV
            .first()
            .receive(on: RunLoop.main)
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 2)
        
        XCTAssertFalse(sut.areCardDetailsValid())
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
        sut.creditCardName = "Some Name"
        sut.creditCardNumber = "4242424242424242"
        sut.creditCardExpiryMonth = "03"
        sut.creditCardExpiryYear = "24"
        sut.creditCardCVV = "100"
        
        await sut.continueButtonTapped(setBilling: { setBillingTriggered = true }, errorHandler: {_ in })
        
        XCTAssertTrue(setBillingTriggered)
        XCTAssertEqual(sut.draftOrderFulfilmentDetails, draftOrderDetailRequest)
    }
    
    func test_givenBasketTimeSlotAndStoreWithCheckoutcom_whenContinueButtonTappedAndBusinessOrderIdReturned_thenCorrectCallsAreMadeAndStateSuccessful() async {
        let selectedStore = RetailStoreDetails.mockedDataWithCheckoutComApplePay
        let cardDetails = CheckoutCardDetails.mockedCard
        let today = Date().startOfDay
        let slotStartTime = today.addingTimeInterval(60*30)
        let slotEndTime = today.addingTimeInterval(60*60)
        let draftOrderTimeRequest = DraftOrderFulfilmentDetailsTimeRequest(date: today.dateOnlyString(storeTimeZone: nil), requestedTime: "\(slotStartTime.hourMinutesString(timeZone: nil)) - \(slotEndTime.hourMinutesString(timeZone: nil))")
        let draftOrderDetailRequest = DraftOrderFulfilmentDetailsRequest(time: draftOrderTimeRequest, place: nil)
        let basket = Basket(basketToken: "", isNewBasket: true, items: [], fulfilmentMethod: BasketFulfilmentMethod(type: .delivery, cost: 1.5, minSpend: 0), selectedSlot: BasketSelectedSlot(todaySelected: true, start: slotStartTime, end: slotEndTime, expires: nil), savings: nil, coupon: nil, fees: nil, tips: nil, addresses: nil, orderSubtotal: 10, orderTotal: 11, storeId: nil, basketItemRemoved: nil)
        let userData = AppState.UserData(selectedStore: .loaded(selectedStore), selectedFulfilmentMethod: .delivery, searchResult: .notRequested, basket: basket, currentFulfilmentLocation: nil, tempTodayTimeSlot: nil, basketDeliveryAddress: nil, memberProfile: nil)
        let appState = AppState(system: AppState.System(), routing: AppState.ViewRouting(), businessData: AppState.BusinessData(), userData: userData)
        let checkoutService = MockedCheckoutService(expected: [.processNewCardPaymentOrder(fulfilmentDetails: draftOrderDetailRequest, paymentGatewayType: PaymentGatewayType.checkoutcom, paymentGatewayMode: .sandbox, instructions: nil, publicKey: selectedStore.paymentGateways?.first?.fields?["publicKey"] as? String ?? "", cardDetails: cardDetails)])
        checkoutService.processNewCardPaymentOrderResult = (1234, nil)
        let services = DIContainer.Services(
            businessProfileService: MockedBusinessProfileService(expected: []),
            retailStoreService: MockedRetailStoreService(expected: []),
            retailStoreMenuService: MockedRetailStoreMenuService(expected: []),
            basketService: MockedBasketService(expected: []),
            memberService: MockedUserService(expected: []),
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
        let cardDetails = CheckoutCardDetails.mockedCard
        let today = Date().startOfDay
        let slotStartTime = today.addingTimeInterval(60*30)
        let slotEndTime = today.addingTimeInterval(60*60)
        let draftOrderTimeRequest = DraftOrderFulfilmentDetailsTimeRequest(date: today.dateOnlyString(storeTimeZone: nil), requestedTime: "\(slotStartTime.hourMinutesString(timeZone: nil)) - \(slotEndTime.hourMinutesString(timeZone: nil))")
        let draftOrderDetailRequest = DraftOrderFulfilmentDetailsRequest(time: draftOrderTimeRequest, place: nil)
        let basket = Basket(basketToken: "", isNewBasket: true, items: [], fulfilmentMethod: BasketFulfilmentMethod(type: .delivery, cost: 1.5, minSpend: 0), selectedSlot: BasketSelectedSlot(todaySelected: true, start: slotStartTime, end: slotEndTime, expires: nil), savings: nil, coupon: nil, fees: nil, tips: nil, addresses: nil, orderSubtotal: 10, orderTotal: 11, storeId: nil, basketItemRemoved: nil)
        let userData = AppState.UserData(selectedStore: .loaded(selectedStore), selectedFulfilmentMethod: .delivery, searchResult: .notRequested, basket: basket, currentFulfilmentLocation: nil, tempTodayTimeSlot: nil, basketDeliveryAddress: nil, memberProfile: nil)
        let appState = AppState(system: AppState.System(), routing: AppState.ViewRouting(), businessData: AppState.BusinessData(), userData: userData)
        let checkoutService = MockedCheckoutService(expected: [.processNewCardPaymentOrder(fulfilmentDetails: draftOrderDetailRequest, paymentGatewayType: PaymentGatewayType.checkoutcom, paymentGatewayMode: .sandbox, instructions: nil, publicKey: selectedStore.paymentGateways?.first?.fields?["publicKey"] as? String ?? "", cardDetails: cardDetails)])
        let urls = CheckoutCom3DSURLs(redirectUrl: URL(string: "redirectURL")!, successUrl: URL(string: "successURL")!, failUrl: URL(string: "failURL")!)
        checkoutService.processNewCardPaymentOrderResult = (nil, urls)
        let services = DIContainer.Services(
            businessProfileService: MockedBusinessProfileService(expected: []),
            retailStoreService: MockedRetailStoreService(expected: []),
            retailStoreMenuService: MockedRetailStoreMenuService(expected: []),
            basketService: MockedBasketService(expected: []),
            memberService: MockedUserService(expected: []),
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
        let cardDetails = CheckoutCardDetails.mockedCard
        let today = Date().startOfDay
        let slotStartTime = today.addingTimeInterval(60*30)
        let slotEndTime = today.addingTimeInterval(60*60)
        let draftOrderTimeRequest = DraftOrderFulfilmentDetailsTimeRequest(date: today.dateOnlyString(storeTimeZone: nil), requestedTime: "\(slotStartTime.hourMinutesString(timeZone: nil)) - \(slotEndTime.hourMinutesString(timeZone: nil))")
        let draftOrderDetailRequest = DraftOrderFulfilmentDetailsRequest(time: draftOrderTimeRequest, place: nil)
        let basket = Basket(basketToken: "", isNewBasket: true, items: [], fulfilmentMethod: BasketFulfilmentMethod(type: .delivery, cost: 1.5, minSpend: 0), selectedSlot: BasketSelectedSlot(todaySelected: true, start: slotStartTime, end: slotEndTime, expires: nil), savings: nil, coupon: nil, fees: nil, tips: nil, addresses: nil, orderSubtotal: 10, orderTotal: 11, storeId: nil, basketItemRemoved: nil)
        let userData = AppState.UserData(selectedStore: .loaded(selectedStore), selectedFulfilmentMethod: .delivery, searchResult: .notRequested, basket: basket, currentFulfilmentLocation: nil, tempTodayTimeSlot: nil, basketDeliveryAddress: nil, memberProfile: nil)
        let appState = AppState(system: AppState.System(), routing: AppState.ViewRouting(), businessData: AppState.BusinessData(), userData: userData)
        let checkoutService = MockedCheckoutService(expected: [.processNewCardPaymentOrder(fulfilmentDetails: draftOrderDetailRequest, paymentGatewayType: PaymentGatewayType.checkoutcom, paymentGatewayMode: .sandbox, instructions: nil, publicKey: selectedStore.paymentGateways?.first?.fields?["publicKey"] as? String ?? "", cardDetails: cardDetails)])
        let services = DIContainer.Services(
            businessProfileService: MockedBusinessProfileService(expected: []),
            retailStoreService: MockedRetailStoreService(expected: []),
            retailStoreMenuService: MockedRetailStoreMenuService(expected: []),
            basketService: MockedBasketService(expected: []),
            memberService: MockedUserService(expected: []),
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
    
    func test_givenBasketTimeSlotAndStoreWithCheckoutcomAndSavedPaymentCard_whenContinueButtonTappedAndBusinessOrderIdReturned_thenCorrectCallsAreMadeAndStateSuccessful() async {
        let selectedStore = RetailStoreDetails.mockedDataWithCheckoutComApplePay
        let memberCard = MemberCardDetails.mockedData
        let cvv = "100"
        let today = Date().startOfDay
        let slotStartTime = today.addingTimeInterval(60*30)
        let slotEndTime = today.addingTimeInterval(60*60)
        let draftOrderTimeRequest = DraftOrderFulfilmentDetailsTimeRequest(date: today.dateOnlyString(storeTimeZone: nil), requestedTime: "\(slotStartTime.hourMinutesString(timeZone: nil)) - \(slotEndTime.hourMinutesString(timeZone: nil))")
        let draftOrderDetailRequest = DraftOrderFulfilmentDetailsRequest(time: draftOrderTimeRequest, place: nil)
        let basket = Basket(basketToken: "", isNewBasket: true, items: [], fulfilmentMethod: BasketFulfilmentMethod(type: .delivery, cost: 1.5, minSpend: 0), selectedSlot: BasketSelectedSlot(todaySelected: true, start: slotStartTime, end: slotEndTime, expires: nil), savings: nil, coupon: nil, fees: nil, tips: nil, addresses: nil, orderSubtotal: 10, orderTotal: 11, storeId: nil, basketItemRemoved: nil)
        let userData = AppState.UserData(selectedStore: .loaded(selectedStore), selectedFulfilmentMethod: .delivery, searchResult: .notRequested, basket: basket, currentFulfilmentLocation: nil, tempTodayTimeSlot: nil, basketDeliveryAddress: nil, memberProfile: nil)
        let appState = AppState(system: AppState.System(), routing: AppState.ViewRouting(), businessData: AppState.BusinessData(), userData: userData)
        let checkoutService = MockedCheckoutService(expected: [.processSavedCardPaymentOrder(fulfilmentDetails: draftOrderDetailRequest, paymentGatewayType: PaymentGatewayType.checkoutcom, paymentGatewayMode: .sandbox, instructions: nil, publicKey: selectedStore.paymentGateways?.first?.fields?["publicKey"] as? String ?? "", cardId: memberCard.id, cvv: cvv)])
        
        // setup service result
        checkoutService.processSavedCardPaymentOrderResult = (1234, nil)
        let services = DIContainer.Services(
            businessProfileService: MockedBusinessProfileService(expected: []),
            retailStoreService: MockedRetailStoreService(expected: []),
            retailStoreMenuService: MockedRetailStoreMenuService(expected: []),
            basketService: MockedBasketService(expected: []),
            memberService: MockedUserService(expected: []),
            checkoutService: checkoutService,
            addressService: MockedAddressService(expected: []),
            utilityService: MockedUtilityService(expected: []),
            imageService: MockedImageService(expected: []),
            notificationService: MockedNotificationService(expected: [])
        )
        let container = DIContainer(appState: appState, eventLogger: MockedEventLogger(), services: services)
        var setBillingTriggered: Bool = false
        let sut = makeSUT(container: container)
        sut.selectedSavedCard = memberCard
        
        let expectation = expectation(description: "selectedSavedCardCVV")
        var cancellables = Set<AnyCancellable>()
        
        sut.$selectedSavedCardCVV
            .first()
            .receive(on: RunLoop.main)
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        sut.selectedSavedCardCVV = cvv
        
        wait(for: [expectation], timeout: 2)
        
        await sut.continueButtonTapped(setBilling: { setBillingTriggered = true }, errorHandler: {_ in })
        
        XCTAssertTrue(setBillingTriggered)
        XCTAssertEqual(sut.draftOrderFulfilmentDetails, draftOrderDetailRequest)
        XCTAssertEqual(sut.paymentOutcome, .successful)
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
    
    func test_givenCardNameAndNumberAndCVVIsNotEmpty_thenIsUnvalidCardNameIsTrue() {
        let sut = makeSUT()
        sut.creditCardName = ""
        sut.creditCardNumber = "4242424242424242"
        sut.creditCardCVV = "100"
        
        XCTAssertTrue(sut.isUnvalidCardName)
    }
    
    func test_whenShowCardCameraTapped_thenShowCardCameraIsTrue() {
        let sut = makeSUT()
        
        sut.showCardCameraTapped()
        
        XCTAssertTrue(sut.showCardCamera)
    }
    
    func test_givenCardDetailsWithSpaces_whenHandleCardCameraReturnTriggered_thenCorrectDetailsAreFilled() {
        let sut = makeSUT()
        let name = "Some Name"
        let number = "4242 4242 4242 4242"
        let expiry = "04/24"
        let expectedMonth = "04"
        let expectedYear = "24"
        let expectedNumber = "4242424242424242"
        
        sut.handleCardCameraReturn(name: name, number: number, expiry: expiry)
        
        XCTAssertEqual(sut.creditCardName, name)
        XCTAssertEqual(sut.creditCardNumber, expectedNumber)
        XCTAssertEqual(sut.creditCardExpiryMonth, expectedMonth)
        XCTAssertEqual(sut.creditCardExpiryYear, expectedYear)
	}
	
    func test_whenOnAppearTrigger_thenCorrectServiceCall() async {
        let container = DIContainer(appState: AppState(), eventLogger: MockedEventLogger(), services: .mocked(memberService: [.getSavedCards]))
        let sut = makeSUT(container: container)
        
        await sut.onAppearTrigger()
        
        container.services.verify(as: .member)
    }
    
    func test_whenSelectSavedCardTriggered_thenSelectedSavedCardPopulated() {
        let card = MemberCardDetails.mockedData
        let sut = makeSUT()
        
        sut.selectSavedCard(card: card)
        
        XCTAssertEqual(sut.selectedSavedCard, card)
    }
    
    func test_givenEmptyCardDetails_thenContinueButtonDisabledIsTrue() {
        let sut = makeSUT()
        
        let expectation = expectation(description: "setupCardType")
        var cancellables = Set<AnyCancellable>()
        
        sut.$cardType
            .first()
            .receive(on: RunLoop.main)
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 2)
        
        XCTAssertTrue(sut.continueButtonDisabled)
    }
    
    func test_givenCardDetails_thenContinueButtonDisabledIsFalse() {
        let cardDetails = CheckoutCardDetails.mockedCard
        let sut = makeSUT()
        sut.creditCardName = cardDetails.cardName
        sut.creditCardNumber = cardDetails.number
        sut.creditCardExpiryMonth = cardDetails.expiryMonth
        sut.creditCardExpiryYear = cardDetails.expiryYear
        sut.creditCardCVV = cardDetails.cvv
        
        let expectation = expectation(description: "setupCardType")
        var cancellables = Set<AnyCancellable>()
        
        sut.$cardType
            .first()
            .receive(on: RunLoop.main)
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 2)
        
        XCTAssertFalse(sut.continueButtonDisabled)
    }
    
    func test_givenSavedCardDetails_thenContinueButtonDisabledIsFalse() {
        let memberCard = MemberCardDetails.mockedData
        let sut = makeSUT()
        sut.selectedSavedCard = memberCard
        sut.selectedSavedCardCVV = "100"
        
        let expectation = expectation(description: "setupCardType")
        var cancellables = Set<AnyCancellable>()
        
        sut.$selectedSavedCardCVV
            .first()
            .receive(on: RunLoop.main)
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 2)
        
        XCTAssertFalse(sut.continueButtonDisabled)
    }
    
    func test_givenNumberWithLetters_whenTriggerFilterCardNumber_thenOnlyNumbers() {
        let sut = makeSUT()
        
        sut.filterCardNumber(newValue: "1234AB56")
        
        XCTAssertEqual(sut.creditCardNumber, "123456")
    }
    
    func test_givenNumberWithLetters_whenTriggerFilterCardCVV_thenOnlyNumbers() {
        let sut = makeSUT()
        
        sut.filterCardCVV(newValue: "1234AB56")
        
        XCTAssertEqual(sut.creditCardCVV, "123456")
    }
    
    func test_givenMemberProfile_whenInit_thenShowNewCardEntryIsTrue() {
        let container = DIContainer(appState: AppState(), eventLogger: MockedEventLogger(), services: .mocked())
        container.appState.value.userData.memberProfile = MemberProfile.mockedData
        let sut = makeSUT(container: container)
        
        XCTAssertTrue(sut.showNewCardEntry)
    }
    
    func test_givenMemberProfileAndSavedCards_whenInit_thenShowNewCardEntryIsFalse() {
        let container = DIContainer(appState: AppState(), eventLogger: MockedEventLogger(), services: .mocked())
        container.appState.value.userData.memberProfile = MemberProfile.mockedData
        let sut = makeSUT(container: container)
        sut.selectedSavedCard = MemberCardDetails.mockedData
        
        XCTAssertFalse(sut.showNewCardEntry)
    }

    func makeSUT(container: DIContainer = DIContainer(appState: AppState(), eventLogger: MockedEventLogger(), services: .mocked())) -> CheckoutPaymentHandlingViewModel {
        let sut = CheckoutPaymentHandlingViewModel(container: container, instructions: nil, paymentSuccess: {}, paymentFailure: {})
        
        trackForMemoryLeaks(sut)
        
        return sut
    }
}


