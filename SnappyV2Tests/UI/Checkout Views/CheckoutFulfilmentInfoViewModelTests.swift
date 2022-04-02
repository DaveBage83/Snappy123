//
//  CheckoutFulfilmentInfoViewModelTests.swift
//  SnappyV2Tests
//
//  Created by Henrik Gustavii on 10/03/2022.
//

import XCTest
import Combine
import CoreLocation
@testable import SnappyV2
import StoreKit

class CheckoutFulfilmentInfoViewModelTests: XCTestCase {
    
    func test_init() {
        let sut = makeSUT()
        
        XCTAssertEqual(sut.selectedRetailStoreFulfilmentTimeSlots, .notRequested)
        XCTAssertNil(sut.deliveryLocation)
        XCTAssertNil(sut.basket)
        XCTAssertTrue(sut.postcode.isEmpty)
        XCTAssertTrue(sut.instructions.isEmpty)
        XCTAssertNil(sut.tempTodayTimeSlot)
        XCTAssertFalse(sut.wasPaymentUnsuccessful)
        XCTAssertNil(sut.navigateToPaymentHandling)
        XCTAssertFalse(sut.isDeliveryAddressSet)
        XCTAssertNil(sut.selectedDeliveryAddress)
        XCTAssertNil(sut.prefilledAddressName)
        XCTAssertFalse(sut.showPayByCard)
        XCTAssertFalse(sut.showPayByApple)
        XCTAssertFalse(sut.showPayByCash)
    }
    
    func test_givenBasketContactDetails_thenPrefilledAddressNameIsFilled() {
        let firstName = "Boris"
        let surname = "Johnson"
        let contactDetails = BasketContactDetailsRequest(firstName: firstName, lastName: surname, email: "alone@tendowningstreet.gov.uk", telephone: "666")
        let userData = AppState.UserData(selectedStore: .notRequested, selectedFulfilmentMethod: .delivery, searchResult: .notRequested, basket: nil, currentFulfilmentLocation: nil, basketContactDetails: contactDetails, tempTodayTimeSlot: nil, basketDeliveryAddress: nil, memberProfile: nil)
        let appState = AppState(system: AppState.System(), routing: AppState.ViewRouting(), businessData: AppState.BusinessData(), userData: userData)
        let container = DIContainer(appState: appState, services: .mocked())
        let sut = makeSUT(container: container)
        
        XCTAssertEqual(sut.prefilledAddressName, Name(firstName: firstName, secondName: surname))
    }
    
    func test_givenBasketAddressesAndMatchingFulfilmentType_thenDeliveryLocationFilled() {
        let locationDelivery = Location(latitude: 12, longitude: 34)
        let address1 = BasketAddressResponse(firstName: nil, lastName: nil, addressLine1: "addressLine1", addressLine2: "addressLine2", town: "town", postcode: "PA344AG", countryCode: nil, type: "collection", email: nil, telephone: nil, state: nil, county: nil, location: nil)
        let address2 = BasketAddressResponse(firstName: nil, lastName: nil, addressLine1: "addressLine1", addressLine2: "addressLine2", town: "town", postcode: "PA344AG", countryCode: nil, type: "delivery", email: nil, telephone: nil, state: nil, county: nil, location: locationDelivery)
        let basket = Basket(basketToken: "", isNewBasket: true, items: [], fulfilmentMethod: BasketFulfilmentMethod(type: RetailStoreOrderMethodType.delivery, cost: 1.5, minSpend: 0), selectedSlot: nil, savings: nil, coupon: nil, fees: nil, tips: nil, addresses: [address1, address2], orderSubtotal: 10, orderTotal: 10)
        let userData = AppState.UserData(selectedStore: .notRequested, selectedFulfilmentMethod: .delivery, searchResult: .notRequested, basket: basket, currentFulfilmentLocation: nil, basketContactDetails: nil, tempTodayTimeSlot: nil, basketDeliveryAddress: nil, memberProfile: nil)
        let appState = AppState(system: AppState.System(), routing: AppState.ViewRouting(), businessData: AppState.BusinessData(), userData: userData)
        let container = DIContainer(appState: appState, services: .mocked())
        let sut = makeSUT(container: container)
        
        XCTAssertEqual(sut.deliveryLocation, locationDelivery)
    }
    
    func test_givenBasketSelectedSlotTodaySelectedTrueAndNoTempTodayTimeSlotAssigned_thenFirstAvailableTimeSlotTodayAssigned() {
        let basket = Basket(basketToken: "", isNewBasket: true, items: [], fulfilmentMethod: BasketFulfilmentMethod(type: .delivery, cost: 1.5, minSpend: 0), selectedSlot: BasketSelectedSlot(todaySelected: true, start: nil, end: nil, expires: nil), savings: nil, coupon: nil, fees: nil, tips: nil, addresses: nil, orderSubtotal: 10, orderTotal: 10)
        let userData = AppState.UserData(selectedStore: .notRequested, selectedFulfilmentMethod: .delivery, searchResult: .notRequested, basket: basket, currentFulfilmentLocation: nil, basketContactDetails: nil, tempTodayTimeSlot: nil, basketDeliveryAddress: nil, memberProfile: nil)
        let appState = AppState(system: AppState.System(), routing: AppState.ViewRouting(), businessData: AppState.BusinessData(), userData: userData)
        let container = DIContainer(appState: appState, services: .mocked())
        let sut = makeSUT(container: container)
        let today = Date().startOfDay
        let timeSlot1 = RetailStoreSlotDayTimeSlot(slotId: "123", startTime: today, endTime: today.addingTimeInterval(60*30), daytime: "", info: RetailStoreSlotDayTimeSlotInfo(status: "", isAsap: true, price: 5, fulfilmentIn: ""))
        let timeSlot2 = RetailStoreSlotDayTimeSlot(slotId: "321", startTime: today.addingTimeInterval(60*30), endTime: today.addingTimeInterval(60*60), daytime: "", info: RetailStoreSlotDayTimeSlotInfo(status: "", isAsap: true, price: 5, fulfilmentIn: ""))
        let slotDay = RetailStoreSlotDay(status: "", reason: "", slotDate: today.dateOnlyString(storeTimeZone: nil), slots: [timeSlot1, timeSlot2])
        let timeSlots = RetailStoreTimeSlots(startDate: today.startOfDay, endDate: today.endOfDay, fulfilmentMethod: "delivery", slotDays: [slotDay], searchStoreId: nil, searchLatitude: nil, searchLongitude: nil)
        sut.selectedRetailStoreFulfilmentTimeSlots = .loaded(timeSlots)
        
        let expectation = expectation(description: "tempTodayTimeSlot")
        var cancellables = Set<AnyCancellable>()
        
        sut.$tempTodayTimeSlot
            .first()
            .receive(on: RunLoop.main)
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 2)
        
        XCTAssertEqual(sut.tempTodayTimeSlot, timeSlot1)
    }
    
    func test_whenSetDeliveryAddressTriggered_thenSetDeliveryAddressIsCalled() {
        let deliveryAddress = BasketAddressRequest(firstName: "first", lastName: "last", addressline1: "line1", addressline2: "line2", town: "town", postcode: "postcode", countryCode: "UK", type: "delivery", email: "email@email.com", telephone: "01929", state: nil, county: "county", location: nil)
        let basketContactDetails = BasketContactDetailsRequest(firstName: deliveryAddress.firstName, lastName: deliveryAddress.lastName, email: deliveryAddress.email, telephone: deliveryAddress.telephone)
        let userData = AppState.UserData(selectedStore: .notRequested, selectedFulfilmentMethod: .delivery, searchResult: .notRequested, basket: nil, currentFulfilmentLocation: nil, basketContactDetails: basketContactDetails, tempTodayTimeSlot: nil, basketDeliveryAddress: nil, memberProfile: nil)
        let appState = AppState(system: AppState.System(), routing: AppState.ViewRouting(), businessData: AppState.BusinessData(), userData: userData)
        let container = DIContainer(appState: appState, services: .mocked(basketService: [.setDeliveryAddress(address: deliveryAddress)]))
        let sut = makeSUT(container: container)
        
        let selectedAddress = Address(id: nil, isDefault: nil, addressName: nil, firstName: deliveryAddress.firstName, lastName: deliveryAddress.lastName, addressLine1: deliveryAddress.addressline1, addressLine2: deliveryAddress.addressline2, town: deliveryAddress.town, postcode: deliveryAddress.postcode, county: deliveryAddress.county, countryCode: deliveryAddress.countryCode, type: .delivery, location: nil)

        sut.setDelivery(address: selectedAddress)
        
        XCTAssertTrue(sut.settingDeliveryAddress)
        
        let expectation = expectation(description: "selectedDeliveryAddress")
        var cancellables = Set<AnyCancellable>()

        sut.$selectedDeliveryAddress
            .first()
            .receive(on: RunLoop.main)
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 2)
        
        XCTAssertEqual(sut.selectedDeliveryAddress, selectedAddress)
        XCTAssertFalse(sut.settingDeliveryAddress)
        container.services.verify()
    }
    
    func test_givenFulfilmentTypeIsDelivery_whenCheckAndAssignASAPIsTriggered_thenCorrectServiceIsCalled() {
        let today = Date().startOfDay
        let location = Location(latitude: 0, longitude: 0)
        let selectedStoreDetails = RetailStoreDetails(id: 123, menuGroupId: 1, storeName: "", telephone: "", lat: 0, lng: 0, ordersPaused: false, canDeliver: true, distance: nil, pausedMessage: nil, address1: "", address2: nil, town: "", postcode: "TN223HY", customerOrderNotePlaceholder: nil, memberEmailCheck: nil, guestCheckoutAllowed: true, basketOnlyTimeSelection: false, ratings: nil, tips: nil, storeLogo: nil, storeProductTypes: nil, orderMethods: nil, deliveryDays: nil, collectionDays: nil, paymentMethods: nil, paymentGateways: nil, timeZone: nil, searchPostcode: nil)
        let basket = Basket(basketToken: "", isNewBasket: true, items: [], fulfilmentMethod: BasketFulfilmentMethod(type: .delivery, cost: 1.5, minSpend: 0), selectedSlot: BasketSelectedSlot(todaySelected: true, start: nil, end: nil, expires: nil), savings: nil, coupon: nil, fees: nil, tips: nil, addresses: nil, orderSubtotal: 10, orderTotal: 11)
        let userData = AppState.UserData(selectedStore: .loaded(selectedStoreDetails), selectedFulfilmentMethod: .delivery, searchResult: .loaded(CheckoutFulfilmentInfoViewModelTests.storeSearch), basket: basket, currentFulfilmentLocation: nil, basketContactDetails: nil, tempTodayTimeSlot: nil, basketDeliveryAddress: nil, memberProfile: nil)
        let appState = AppState(system: AppState.System(), routing: AppState.ViewRouting(), businessData: AppState.BusinessData(), userData: userData)
        let container = DIContainer(appState: appState, services: .mocked(retailStoreService: [.getStoreDeliveryTimeSlots(storeId: 123, startDate: today.startOfDay, endDate: today.endOfDay, location: CLLocationCoordinate2D(latitude: CLLocationDegrees(Float(location.latitude)), longitude: CLLocationDegrees(Float(location.longitude))))]))
        let sut = makeSUT(container: container)

        sut.exposeCheckAndAssignASAP()
        
        container.services.verify()
    }
    
    func test_givenFulfilmentTypeIsCollection_whenCheckAndAssignASAPIsTriggered_thenCorrectServiceIsCalled() {
        let today = Date().startOfDay
        let selectedStoreDetails = RetailStoreDetails(id: 123, menuGroupId: 1, storeName: "", telephone: "", lat: 0, lng: 0, ordersPaused: false, canDeliver: true, distance: nil, pausedMessage: nil, address1: "", address2: nil, town: "", postcode: "TN223HY", customerOrderNotePlaceholder: nil, memberEmailCheck: nil, guestCheckoutAllowed: true, basketOnlyTimeSelection: false, ratings: nil, tips: nil, storeLogo: nil, storeProductTypes: nil, orderMethods: nil, deliveryDays: nil, collectionDays: nil, paymentMethods: nil, paymentGateways: nil, timeZone: nil, searchPostcode: nil)
        let basket = Basket(basketToken: "", isNewBasket: true, items: [], fulfilmentMethod: BasketFulfilmentMethod(type: .delivery, cost: 1.5, minSpend: 0), selectedSlot: BasketSelectedSlot(todaySelected: true, start: nil, end: nil, expires: nil), savings: nil, coupon: nil, fees: nil, tips: nil, addresses: nil, orderSubtotal: 10, orderTotal: 11)
        let userData = AppState.UserData(selectedStore: .loaded(selectedStoreDetails), selectedFulfilmentMethod: .collection, searchResult: .loaded(CheckoutFulfilmentInfoViewModelTests.storeSearch), basket: basket, currentFulfilmentLocation: nil, basketContactDetails: nil, tempTodayTimeSlot: nil, basketDeliveryAddress: nil, memberProfile: nil)
        let appState = AppState(system: AppState.System(), routing: AppState.ViewRouting(), businessData: AppState.BusinessData(), userData: userData)
        let container = DIContainer(appState: appState, services: .mocked(retailStoreService: [.getStoreCollectionTimeSlots(storeId: 123, startDate: today.startOfDay, endDate: today.endOfDay)]))
        let sut = makeSUT(container: container)

        sut.exposeCheckAndAssignASAP()
        
        container.services.verify()
    }
    
    func test_whenPayByCardTapped_thenNavigateToPaymentHandlingIsCorrect() {
        let sut = makeSUT()
        
        sut.payByCardTapped()
        
        XCTAssertEqual(sut.navigateToPaymentHandling, .payByCard)
    }
    
    func test_whenPayByAppleTapped_thenNavigateToPaymentHandlingIsCorrect() {
        let sut = makeSUT()
        
        sut.payByAppleTapped()
        
        XCTAssertEqual(sut.navigateToPaymentHandling, .payByApple)
    }
    
    func test_givenStoreSupportsRealex_thenShowPayByCardIsTrue() {
        let paymentMethod = PaymentMethod(name: "realex", title: "realex", description: nil, settings: PaymentMethodSettings(title: "realex", instructions: nil, enabledForMethod: [.delivery], paymentGateways: ["realex"], saveCards: nil, cutoffTime: nil))
        let paymentGateway = PaymentGateway(name: "realex", mode: "realex", fields: nil)
        let storeDetails = RetailStoreDetails(id: 123, menuGroupId: 12, storeName: "", telephone: "", lat: 10, lng: 10, ordersPaused: false, canDeliver: true, distance: nil, pausedMessage: nil, address1: "", address2: nil, town: "", postcode: "", customerOrderNotePlaceholder: nil, memberEmailCheck: nil, guestCheckoutAllowed: true, basketOnlyTimeSelection: false, ratings: nil, tips: nil, storeLogo: nil, storeProductTypes: nil, orderMethods: nil, deliveryDays: nil, collectionDays: nil, paymentMethods: [paymentMethod], paymentGateways: [paymentGateway], timeZone: nil, searchPostcode: nil)
        let userData = AppState.UserData(selectedStore: .loaded(storeDetails), selectedFulfilmentMethod: .delivery, searchResult: .notRequested, basket: nil, currentFulfilmentLocation: nil, basketContactDetails: nil, tempTodayTimeSlot: nil, basketDeliveryAddress: nil, memberProfile: nil)
        let appState = AppState(system: AppState.System(), routing: AppState.ViewRouting(), businessData: AppState.BusinessData(), userData: userData)
        let sut = makeSUT(container: DIContainer(appState: appState, services: .mocked()))
                          
        XCTAssertTrue(sut.showPayByCard)
    }
    
    func test_givenStoreSupportsApplePay_thenShowPayByAppleIsTrue() {
        let paymentMethod = PaymentMethod(name: "ApplePay", title: "worldpay", description: nil, settings: PaymentMethodSettings(title: "worldpay", instructions: nil, enabledForMethod: [.delivery], paymentGateways: ["worldpay"], saveCards: nil, cutoffTime: nil))
        let paymentGateway = PaymentGateway(name: "ApplePay", mode: "worldpay", fields: nil)
        let storeDetails = RetailStoreDetails(id: 123, menuGroupId: 12, storeName: "", telephone: "", lat: 10, lng: 10, ordersPaused: false, canDeliver: true, distance: nil, pausedMessage: nil, address1: "", address2: nil, town: "", postcode: "", customerOrderNotePlaceholder: nil, memberEmailCheck: nil, guestCheckoutAllowed: true, basketOnlyTimeSelection: false, ratings: nil, tips: nil, storeLogo: nil, storeProductTypes: nil, orderMethods: nil, deliveryDays: nil, collectionDays: nil, paymentMethods: [paymentMethod], paymentGateways: [paymentGateway], timeZone: nil, searchPostcode: nil)
        let userData = AppState.UserData(selectedStore: .loaded(storeDetails), selectedFulfilmentMethod: .delivery, searchResult: .notRequested, basket: nil, currentFulfilmentLocation: nil, basketContactDetails: nil, tempTodayTimeSlot: nil, basketDeliveryAddress: nil, memberProfile: nil)
        let appState = AppState(system: AppState.System(), routing: AppState.ViewRouting(), businessData: AppState.BusinessData(), userData: userData)
        let sut = makeSUT(container: DIContainer(appState: appState, services: .mocked()))
        sut.enableApplePay()
                          
        XCTAssertTrue(sut.showPayByApple)
    }
    
    func test_givenStoreSupportsCash_thenShowPayByCashIsTrue() {
        let paymentMethod = PaymentMethod(name: "cash", title: "cash", description: nil, settings: PaymentMethodSettings(title: "cash", instructions: nil, enabledForMethod: [.delivery], paymentGateways: ["cash"], saveCards: nil, cutoffTime: nil))
        let paymentGateway = PaymentGateway(name: "cash", mode: "cash", fields: nil)
        let storeDetails = RetailStoreDetails(id: 123, menuGroupId: 12, storeName: "", telephone: "", lat: 10, lng: 10, ordersPaused: false, canDeliver: true, distance: nil, pausedMessage: nil, address1: "", address2: nil, town: "", postcode: "", customerOrderNotePlaceholder: nil, memberEmailCheck: nil, guestCheckoutAllowed: true, basketOnlyTimeSelection: false, ratings: nil, tips: nil, storeLogo: nil, storeProductTypes: nil, orderMethods: nil, deliveryDays: nil, collectionDays: nil, paymentMethods: [paymentMethod], paymentGateways: [paymentGateway], timeZone: nil, searchPostcode: nil)
        let userData = AppState.UserData(selectedStore: .loaded(storeDetails), selectedFulfilmentMethod: .delivery, searchResult: .notRequested, basket: nil, currentFulfilmentLocation: nil, basketContactDetails: nil, tempTodayTimeSlot: nil, basketDeliveryAddress: nil, memberProfile: nil)
        let appState = AppState(system: AppState.System(), routing: AppState.ViewRouting(), businessData: AppState.BusinessData(), userData: userData)
        let sut = makeSUT(container: DIContainer(appState: appState, services: .mocked()))
                          
        XCTAssertTrue(sut.showPayByCash)
    }
    
    func test_givenTempTodayTimeSlot_whenPayByCashTapped_thenCreateDraftOrderTriggers() {
        let today = Date().startOfDay
        let slotStartTime = today.addingTimeInterval(60*30)
        let slotEndTime = today.addingTimeInterval(60*60)
        let draftOrderTimeRequest = DraftOrderFulfilmentDetailsTimeRequest(date: today.dateOnlyString(storeTimeZone: nil), requestedTime: "\(slotStartTime.hourMinutesString(timeZone: nil)) - \(slotEndTime.hourMinutesString(timeZone: nil))")
        let draftOrderDetailRequest = DraftOrderFulfilmentDetailsRequest(time: draftOrderTimeRequest, place: nil)
        let tempTodayTimeSlot = RetailStoreSlotDayTimeSlot(slotId: "123", startTime: slotStartTime, endTime: slotEndTime, daytime: "", info: RetailStoreSlotDayTimeSlotInfo(status: "", isAsap: true, price: 5, fulfilmentIn: ""))
        let userData = AppState.UserData(selectedStore: .notRequested, selectedFulfilmentMethod: .delivery, searchResult: .notRequested, basket: nil, currentFulfilmentLocation: nil, basketContactDetails: nil, tempTodayTimeSlot: tempTodayTimeSlot, basketDeliveryAddress: nil, memberProfile: nil)
        let appState = AppState(system: AppState.System(), routing: AppState.ViewRouting(), businessData: AppState.BusinessData(), userData: userData)
        let container = DIContainer(appState: appState, services: .mocked(checkoutService: [.createDraftOrder(fulfilmentDetails: draftOrderDetailRequest, paymentGateway: .cash, instructions: "")]))
        let sut = makeSUT(container: container)
        
        let expectation = expectation(description: "navigateToPaymentHandling")
        var cancellables = Set<AnyCancellable>()
        
        sut.$navigateToPaymentHandling
            .first()
            .receive(on: RunLoop.main)
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        sut.payByCashTapped()
        XCTAssertTrue(sut.processingPayByCash)
        
        wait(for: [expectation], timeout: 2)
        
        XCTAssertFalse(sut.processingPayByCash)
        XCTAssertEqual(sut.navigateToPaymentHandling, .payByCash)
        container.services.verify()
    }
    
    func test_givenBasketTimeSlot_whenPayByCashTapped_thenCreateDraftOrderTriggers() {
        let today = Date().startOfDay
        let slotStartTime = today.addingTimeInterval(60*30)
        let slotEndTime = today.addingTimeInterval(60*60)
        let draftOrderTimeRequest = DraftOrderFulfilmentDetailsTimeRequest(date: today.dateOnlyString(storeTimeZone: nil), requestedTime: "\(slotStartTime.hourMinutesString(timeZone: nil)) - \(slotEndTime.hourMinutesString(timeZone: nil))")
        let draftOrderDetailRequest = DraftOrderFulfilmentDetailsRequest(time: draftOrderTimeRequest, place: nil)
        let basket = Basket(basketToken: "", isNewBasket: true, items: [], fulfilmentMethod: BasketFulfilmentMethod(type: .delivery, cost: 1.5, minSpend: 0), selectedSlot: BasketSelectedSlot(todaySelected: true, start: slotStartTime, end: slotEndTime, expires: nil), savings: nil, coupon: nil, fees: nil, tips: nil, addresses: nil, orderSubtotal: 10, orderTotal: 11)
        let userData = AppState.UserData(selectedStore: .notRequested, selectedFulfilmentMethod: .delivery, searchResult: .notRequested, basket: basket, currentFulfilmentLocation: nil, basketContactDetails: nil, tempTodayTimeSlot: nil, basketDeliveryAddress: nil, memberProfile: nil)
        let appState = AppState(system: AppState.System(), routing: AppState.ViewRouting(), businessData: AppState.BusinessData(), userData: userData)
        let container = DIContainer(appState: appState, services: .mocked(checkoutService: [.createDraftOrder(fulfilmentDetails: draftOrderDetailRequest, paymentGateway: .cash, instructions: "")]))
        let sut = makeSUT(container: container)
        
        let expectation = expectation(description: "navigateToPaymentHandling")
        var cancellables = Set<AnyCancellable>()
        
        sut.$navigateToPaymentHandling
            .first()
            .receive(on: RunLoop.main)
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        sut.payByCashTapped()
        XCTAssertTrue(sut.processingPayByCash)
        
        wait(for: [expectation], timeout: 2)
        
        XCTAssertFalse(sut.processingPayByCash)
        XCTAssertEqual(sut.navigateToPaymentHandling, .payByCash)
        container.services.verify()
    }

    func makeSUT(container: DIContainer = DIContainer(appState: AppState(), services: .mocked())) -> CheckoutFulfilmentInfoViewModel {
        let sut = CheckoutFulfilmentInfoViewModel(container: container)
        
        trackForMemoryLeaks(sut)
        
        return sut
    }
    
    static let fulfilmentLocation = FulfilmentLocation(country: "UK", latitude: 0, longitude: 0, postcode: "TN223HY")
    
    static let storeSearch = RetailStoresSearch(storeProductTypes: nil, stores: nil, fulfilmentLocation: fulfilmentLocation)
}
