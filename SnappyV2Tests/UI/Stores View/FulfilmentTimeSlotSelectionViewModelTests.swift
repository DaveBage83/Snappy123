//
//  FulfilmentTimeSlotSelectionViewModelTests.swift
//  SnappyV2Tests
//
//  Created by Henrik Gustavii on 24/09/2021.
//

import XCTest
import MapKit
import Combine
@testable import SnappyV2

class FulfilmentTimeSlotSelectionViewModelTests: XCTestCase {
    
    func test_init_when_selectedFulfilmentMethodIsDelivery() {
        let sut = makeSUT()
        
        XCTAssertEqual(sut.fulfilmentType, .delivery)
        XCTAssertEqual(sut.selectedRetailStoreDetails, .notRequested)
        XCTAssertEqual(sut.selectedRetailStoreFulfilmentTimeSlots, .notRequested)
        XCTAssertEqual(sut.storeSearchResult, .notRequested)
        XCTAssertTrue(sut.availableFulfilmentDays.isEmpty)
        XCTAssertNil(sut.selectedDaySlot)
        XCTAssertTrue(sut.morningTimeSlots.isEmpty)
        XCTAssertTrue(sut.afternoonTimeSlots.isEmpty)
        XCTAssertTrue(sut.eveningTimeSlots.isEmpty)
        XCTAssertFalse(sut.isTimeSlotsLoading)
        XCTAssertFalse(sut.isFulfilmentSlotSelected)
        XCTAssertFalse(sut.isReservingTimeSlot)
        XCTAssertFalse(sut.viewDismissed)
        XCTAssertEqual(sut.slotDescription, GeneralStrings.delivery.localized)
        XCTAssertNil(sut.basket)
        XCTAssertFalse(sut.isInCheckout)
        XCTAssertEqual(sut.slotDescription, "Delivery")
        XCTAssertFalse(sut.isSlotSelectedToday)
        XCTAssertFalse(sut.todayFulfilmentExists)
        XCTAssertNil(sut.earliestFulfilmentTimeString)
        XCTAssertFalse(sut.isTodaySelectedWithSlotSelectionRestrictions)
    }
    
    func test_init_when_selectedFulfilmentMethodIsCollection() {
        let sut = makeSUT()
        sut.container.appState.value.userData.selectedFulfilmentMethod = .collection
        
        XCTAssertEqual(sut.fulfilmentType, .collection)
        XCTAssertEqual(sut.selectedRetailStoreDetails, .notRequested)
        XCTAssertEqual(sut.selectedRetailStoreFulfilmentTimeSlots, .notRequested)
        XCTAssertEqual(sut.storeSearchResult, .notRequested)
        XCTAssertTrue(sut.availableFulfilmentDays.isEmpty)
        XCTAssertNil(sut.selectedDaySlot)
        XCTAssertTrue(sut.morningTimeSlots.isEmpty)
        XCTAssertTrue(sut.afternoonTimeSlots.isEmpty)
        XCTAssertTrue(sut.eveningTimeSlots.isEmpty)
        XCTAssertFalse(sut.isTimeSlotsLoading)
        XCTAssertFalse(sut.isFulfilmentSlotSelected)
        XCTAssertFalse(sut.isReservingTimeSlot)
        XCTAssertFalse(sut.viewDismissed)
        XCTAssertEqual(sut.slotDescription, GeneralStrings.collection.localized)
        XCTAssertNil(sut.basket)
        XCTAssertFalse(sut.isInCheckout)
        XCTAssertEqual(sut.slotDescription, "Collection")
        XCTAssertFalse(sut.isSlotSelectedToday)
        XCTAssertFalse(sut.todayFulfilmentExists)
        XCTAssertNil(sut.earliestFulfilmentTimeString)
        XCTAssertFalse(sut.isTodaySelectedWithSlotSelectionRestrictions)
    }
    
    func test_givenInit_whenSelectedDaySlotAndSelectedTimeSlotIsPopulated_thenIsDataSelectedIsTrue() {
        let sut = makeSUT()
        
        sut.selectedDaySlot = RetailStoreSlotDay(status: "", reason: "", slotDate: "", slots: [])
        sut.selectedTimeSlot = RetailStoreSlotDayTimeSlot(slotId: "1", startTime: Date(), endTime: Date().addingTimeInterval(60*60), daytime: "", info: RetailStoreSlotDayTimeSlotInfo(status: "", isAsap: false, price: 2, fulfilmentIn: "30-60 mins"))
        
        XCTAssertTrue(sut.isFulfilmentSlotSelected)
    }
    
    func test_givenSearchResultAndStoreDetails_whenSelectFulfilmentDateTappedAndFulfilmentMethodIsDelivery_thenVerified() {
        let currentDate = Date().startOfDay
        let container = DIContainer(appState: AppState(), services: .mocked(retailStoreService: [.getStoreDeliveryTimeSlots(storeId: 123, startDate: currentDate, endDate: currentDate.addingTimeInterval(60*60*23), location: FulfilmentTimeSlotSelectionViewModelTests.fulfilmentLocation.location)]))
        let sut = makeSUT(container: container)
        
        let storeDetails = RetailStoreDetails(id: 123, menuGroupId: 1, storeName: "SomeStore", telephone: "", lat: 0, lng: 0, ordersPaused: false, canDeliver: true, distance: nil, pausedMessage: nil, address1: "", address2: nil, town: "", postcode: "", customerOrderNotePlaceholder: nil, memberEmailCheck: false, guestCheckoutAllowed: true, basketOnlyTimeSelection: false, ratings: nil, tips: nil, storeLogo: nil, storeProductTypes: nil, orderMethods: nil, deliveryDays: nil, collectionDays: nil, paymentMethods: nil, paymentGateways: nil, timeZone: nil, searchPostcode: nil)
        sut.selectedRetailStoreDetails = .loaded(storeDetails)
        sut.storeSearchResult = .loaded(RetailStoresSearch(storeProductTypes: nil, stores: nil, fulfilmentLocation: FulfilmentTimeSlotSelectionViewModelTests.fulfilmentLocation))
        
        sut.selectFulfilmentDate(startDate: currentDate, endDate: currentDate.addingTimeInterval(60*60*23), storeID: 123)
        
        container.services.verify()
    }
    
    func test_givenSearchResultAndStoreDetails_whenSelectFulfilmentDateTapped_andFulfilmentMethodIsCollection_thenVerified() {
        let currentDate = Date().startOfDay
        let container = DIContainer(appState: AppState(), services: .mocked(retailStoreService: [.getStoreCollectionTimeSlots(storeId: 123, startDate: currentDate, endDate: currentDate.addingTimeInterval(60*60*23))]))
        container.appState.value.userData.selectedFulfilmentMethod = .collection
        let sut = makeSUT(container: container)
        
        let storeDetails = RetailStoreDetails(id: 123, menuGroupId: 1, storeName: "SomeStore", telephone: "", lat: 0, lng: 0, ordersPaused: false, canDeliver: true, distance: nil, pausedMessage: nil, address1: "", address2: nil, town: "", postcode: "", customerOrderNotePlaceholder: nil, memberEmailCheck: false, guestCheckoutAllowed: true, basketOnlyTimeSelection: false, ratings: nil, tips: nil, storeLogo: nil, storeProductTypes: nil, orderMethods: nil, deliveryDays: nil, collectionDays: nil, paymentMethods: nil, paymentGateways: nil, timeZone: nil, searchPostcode: nil)
        sut.selectedRetailStoreDetails = .loaded(storeDetails)
        sut.storeSearchResult = .loaded(RetailStoresSearch(storeProductTypes: nil, stores: nil, fulfilmentLocation: FulfilmentTimeSlotSelectionViewModelTests.fulfilmentLocation))
        
        sut.selectFulfilmentDate(startDate: currentDate, endDate: currentDate.addingTimeInterval(60*60*23), storeID: 123)
        
        container.services.verify()
    }
    
    func test_givenNilDayTimeSlots_thenAllTimeSlotsEmpty() {
        let sut = makeSUT()

        let expectationMorning = expectation(description: "morningTimeSlots")
        let expectationAfternoon = expectation(description: "afternoonTimeSlots")
        let expectationEvening = expectation(description: "eveningTimeSlots")
        var cancellables = Set<AnyCancellable>()

        sut.$morningTimeSlots
            .first()
            .receive(on: RunLoop.main)
            .sink { _ in
                expectationMorning.fulfill()
            }
            .store(in: &cancellables)

        sut.$afternoonTimeSlots
            .first()
            .receive(on: RunLoop.main)
            .sink { _ in
                expectationAfternoon.fulfill()
            }
            .store(in: &cancellables)

        sut.$eveningTimeSlots
            .first()
            .receive(on: RunLoop.main)
            .sink { _ in
                expectationEvening.fulfill()
            }
            .store(in: &cancellables)

        let daySlot = RetailStoreSlotDay(status: "", reason: "", slotDate: "", slots: nil)
        sut.selectedDaySlot = daySlot

        wait(for: [expectationMorning, expectationAfternoon, expectationEvening], timeout: 5)

        XCTAssertTrue(sut.morningTimeSlots.isEmpty)
        XCTAssertTrue(sut.afternoonTimeSlots.isEmpty)
        XCTAssertTrue(sut.eveningTimeSlots.isEmpty)
    }
    
    func test_givenVariousDaytimeSlots_thenCorrectTimeSlotsFilled() {
        let sut = makeSUT()
        sut.selectedTimeSlot = RetailStoreSlotDayTimeSlot(slotId: "1", startTime: Date(), endTime: Date().addingTimeInterval(60*60), daytime: "", info: RetailStoreSlotDayTimeSlotInfo(status: "", isAsap: false, price: 2, fulfilmentIn: "30-60 mins"))
        
        let expectationMorning = expectation(description: "morningTimeSlots")
        let expectationAfternoon = expectation(description: "afternoonTimeSlots")
        let expectationEvening = expectation(description: "eveningTimeSlots")
        var cancellables = Set<AnyCancellable>()
        
        sut.$morningTimeSlots
            .first()
            .receive(on: RunLoop.main)
            .sink { _ in
                expectationMorning.fulfill()
            }
            .store(in: &cancellables)
        
        sut.$afternoonTimeSlots
            .first()
            .receive(on: RunLoop.main)
            .sink { _ in
                expectationAfternoon.fulfill()
            }
            .store(in: &cancellables)
        
        sut.$eveningTimeSlots
            .first()
            .receive(on: RunLoop.main)
            .sink { _ in
                expectationEvening.fulfill()
            }
            .store(in: &cancellables)
        
        let tomorrow = Date(timeIntervalSinceNow: 60*60*24)
        let morningSlot1 = RetailStoreSlotDayTimeSlot(slotId: "", startTime: tomorrow, endTime: tomorrow, daytime: "morning", info: .init(status: "", isAsap: false, price: 0, fulfilmentIn: ""))
        let morningSlot2 = RetailStoreSlotDayTimeSlot(slotId: "", startTime: tomorrow, endTime: tomorrow, daytime: "morning", info: .init(status: "", isAsap: false, price: 0, fulfilmentIn: ""))
        let afternoonSlot = RetailStoreSlotDayTimeSlot(slotId: "", startTime: tomorrow, endTime: tomorrow, daytime: "afternoon", info: .init(status: "", isAsap: false, price: 0, fulfilmentIn: ""))
        let daySlot = RetailStoreSlotDay(status: "", reason: "", slotDate: "", slots: [morningSlot1, morningSlot2, afternoonSlot])
        sut.selectedDaySlot = daySlot
        
        wait(for: [expectationMorning, expectationAfternoon, expectationEvening], timeout: 5)
        
        XCTAssertEqual(sut.morningTimeSlots.count, 2)
        XCTAssertEqual(sut.morningTimeSlots.first, morningSlot1)
        XCTAssertEqual(sut.afternoonTimeSlots.count, 1)
        XCTAssertEqual(sut.afternoonTimeSlots.first, afternoonSlot)
        XCTAssertEqual(sut.eveningTimeSlots.count, 0)
        XCTAssertTrue(sut.eveningTimeSlots.isEmpty)
        XCTAssertNil(sut.selectedTimeSlot)
    }
    
    func test_givenDelivery_whenShopNowTapped_thenReserveTimeSlotCalledAndViewDismissed() {
        var appState = AppState()
        let todayDate = Date().startOfDay
        let todayString = todayDate.dateOnlyString(storeTimeZone: nil)
        let deliveryDays = [RetailStoreFulfilmentDay(date: todayString, holidayMessage: nil, start: "", end: "", storeDateStart: todayDate.startOfDay, storeDateEnd: todayDate.endOfDay)]
        let store = RetailStoreDetails(id: 123, menuGroupId: 23, storeName: "", telephone: "", lat: 0, lng: 0, ordersPaused: false, canDeliver: true, distance: nil, pausedMessage: nil, address1: "", address2: nil, town: "", postcode: "", customerOrderNotePlaceholder: nil, memberEmailCheck: false, guestCheckoutAllowed: true, basketOnlyTimeSelection: false, ratings: nil, tips: nil, storeLogo: nil, storeProductTypes: nil, orderMethods: nil, deliveryDays: deliveryDays, collectionDays: nil, paymentMethods: nil, paymentGateways: nil, timeZone: nil, searchPostcode: nil)
        appState.userData.selectedStore = .loaded(store)
        let container = DIContainer(appState: appState, services: .mocked(basketService: [.reserveTimeSlot(timeSlotDate: todayString, timeSlotTime: nil)]))
        
        let sut = makeSUT(container: container)
        
        let slot1 = RetailStoreSlotDayTimeSlot(slotId: "1", startTime: todayDate, endTime: todayDate.addingTimeInterval(60*30), daytime: "", info: RetailStoreSlotDayTimeSlotInfo(status: "", isAsap: true, price: 0, fulfilmentIn: ""))
        let slot2 = RetailStoreSlotDayTimeSlot(slotId: "2", startTime: todayDate.addingTimeInterval(60*60), endTime: todayDate.addingTimeInterval(60*90), daytime: "", info: RetailStoreSlotDayTimeSlotInfo(status: "", isAsap: false, price: 0, fulfilmentIn: ""))
        let slots = RetailStoreSlotDay(status: "", reason: "", slotDate: todayString, slots: [slot1, slot2])
        sut.selectedRetailStoreFulfilmentTimeSlots = .loaded(RetailStoreTimeSlots(startDate: todayDate.startOfDay, endDate: todayDate.endOfDay, fulfilmentMethod: "delivery", slotDays: [slots], searchStoreId: nil, searchLatitude: nil, searchLongitude: nil))
                
        let expectation1 = expectation(description: "availableFulfilmentDays")
        let expectation2 = expectation(description: "availableFulfilmentDays")
        var cancellables = Set<AnyCancellable>()
        
        sut.$selectedRetailStoreFulfilmentTimeSlots
            .first()
            .receive(on: RunLoop.main)
            .sink { _ in
                expectation1.fulfill()
            }
            .store(in: &cancellables)
        
        wait(for: [expectation1], timeout: 5)
        
        sut.shopNowButtonTapped()
        
        sut.$availableFulfilmentDays
            .first()
            .receive(on: RunLoop.main)
            .sink { _ in
                expectation2.fulfill()
            }
            .store(in: &cancellables)
        
        wait(for: [expectation2], timeout: 5)
        
        XCTAssertTrue(sut.viewDismissed)
        container.services.verify()
    }
    
    func test_givenCollection_whenShopNowTapped_thenReserveTimeSlotCalledAndViewDismissed() {
        var appState = AppState()
        let todayDate = Date().startOfDay
        let todayString = todayDate.dateOnlyString(storeTimeZone: nil)
        let deliveryDays = [RetailStoreFulfilmentDay(date: todayString, holidayMessage: nil, start: "", end: "", storeDateStart: todayDate.startOfDay, storeDateEnd: todayDate.endOfDay)]
        let store = RetailStoreDetails(id: 123, menuGroupId: 23, storeName: "", telephone: "", lat: 0, lng: 0, ordersPaused: false, canDeliver: true, distance: nil, pausedMessage: nil, address1: "", address2: nil, town: "", postcode: "", customerOrderNotePlaceholder: nil, memberEmailCheck: false, guestCheckoutAllowed: true, basketOnlyTimeSelection: true, ratings: nil, tips: nil, storeLogo: nil, storeProductTypes: nil, orderMethods: nil, deliveryDays: deliveryDays, collectionDays: nil, paymentMethods: nil, paymentGateways: nil, timeZone: nil, searchPostcode: nil)
        appState.userData.selectedStore = .loaded(store)
        let container = DIContainer(appState: appState, services: .mocked(basketService: [.reserveTimeSlot(timeSlotDate: todayString, timeSlotTime: nil)]))
        
        let sut = makeSUT(container: container)
        sut.container.appState.value.userData.selectedFulfilmentMethod = .collection
        let slot1 = RetailStoreSlotDayTimeSlot(slotId: "1", startTime: todayDate, endTime: todayDate.addingTimeInterval(60*30), daytime: "", info: RetailStoreSlotDayTimeSlotInfo(status: "", isAsap: true, price: 0, fulfilmentIn: ""))
        let slot2 = RetailStoreSlotDayTimeSlot(slotId: "2", startTime: todayDate.addingTimeInterval(60*60), endTime: todayDate.addingTimeInterval(60*90), daytime: "", info: RetailStoreSlotDayTimeSlotInfo(status: "", isAsap: false, price: 0, fulfilmentIn: ""))
        let slots = RetailStoreSlotDay(status: "", reason: "", slotDate: todayString, slots: [slot1, slot2])
        sut.selectedRetailStoreFulfilmentTimeSlots = .loaded(RetailStoreTimeSlots(startDate: todayDate.startOfDay, endDate: todayDate.endOfDay, fulfilmentMethod: "collection", slotDays: [slots], searchStoreId: nil, searchLatitude: nil, searchLongitude: nil))
                
        let expectation1 = expectation(description: "availableFulfilmentDays")
        let expectation2 = expectation(description: "availableFulfilmentDays")
        var cancellables = Set<AnyCancellable>()
        
        sut.$selectedRetailStoreFulfilmentTimeSlots
            .first()
            .receive(on: RunLoop.main)
            .sink { _ in
                expectation1.fulfill()
            }
            .store(in: &cancellables)
        
        wait(for: [expectation1], timeout: 5)
        
        sut.shopNowButtonTapped()
        
        sut.$availableFulfilmentDays
            .first()
            .receive(on: RunLoop.main)
            .sink { _ in
                expectation2.fulfill()
            }
            .store(in: &cancellables)
        
        wait(for: [expectation2], timeout: 5)
        
        XCTAssertTrue(sut.viewDismissed)
        container.services.verify()
    }
    
    func test_givenSelectedDaySlotAndSelectedTimeSlot_whenShopNowButtonTapped_thenDismissViewCalledAndReserveTimeSlotTriggeredAndIsCorrect() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        
        let startTime = dateFormatter.string(from: Date())
        let endTime = dateFormatter.string(from: Date().addingTimeInterval(60*60))
        
        let container = DIContainer(appState: AppState(), services: .mocked(basketService: [.reserveTimeSlot(timeSlotDate: "Tomorrow", timeSlotTime: "\(startTime) - \(endTime)")]))
        
        let sut = makeSUT(container: container)
        sut.selectedDaySlot = RetailStoreSlotDay(status: "", reason: "", slotDate: "Tomorrow", slots: nil)
        sut.selectedTimeSlot = RetailStoreSlotDayTimeSlot(slotId: "1", startTime: Date(), endTime: Date().addingTimeInterval(60*60), daytime: "", info: RetailStoreSlotDayTimeSlotInfo(status: "", isAsap: false, price: 2, fulfilmentIn: "30-60 mins"))
        
        let expectation = expectation(description: "reserveTimeSlot")
        var cancellables = Set<AnyCancellable>()
        
        sut.$isReservingTimeSlot
            .first()
            .receive(on: RunLoop.main)
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        sut.shopNowButtonTapped()
        
        wait(for: [expectation], timeout: 5)
        
        XCTAssertTrue(sut.viewDismissed)
        
        container.services.verify()
    }
    
    func test_givenInCheckoutAndSlotSelectedIsToday_whenShowNowTapped_thenTempTodayTimeSlotpopulatedAndViewDissmissed() {
        let sut = makeSUT(isInCheckout: true)
        let today = Date().startOfDay
        sut.selectedDaySlot = RetailStoreSlotDay(status: "", reason: "", slotDate: today.dateOnlyString(storeTimeZone: nil), slots: nil)
        let selectedTimeSlot = RetailStoreSlotDayTimeSlot(slotId: "1", startTime: today, endTime: today.addingTimeInterval(60*60), daytime: "", info: RetailStoreSlotDayTimeSlotInfo(status: "", isAsap: false, price: 2, fulfilmentIn: "30-60 mins"))
        sut.selectedTimeSlot = selectedTimeSlot
        
        sut.shopNowButtonTapped()
        
        XCTAssertTrue(sut.viewDismissed)
        XCTAssertEqual(sut.container.appState.value.userData.tempTodayTimeSlot, selectedTimeSlot)
    }
    
    func test_givenSelectedRetailStoreFulfilmentTimeSlots_whenIsLoadingStatus_thenReturnsTrue() {
        let sut = makeSUT()
        sut.selectedRetailStoreFulfilmentTimeSlots = .isLoading(last: nil, cancelBag: CancelBag())
        
        XCTAssertTrue(sut.isTimeSlotsLoading)
    }
    
    func test_givenSelectedRetailStoreDeliveryTimeSlots_whenLoadedStatus_thenReturnsFalse() {
        let sut = makeSUT()
        sut.selectedRetailStoreFulfilmentTimeSlots = .loaded(RetailStoreTimeSlots(startDate: Date(), endDate: Date(), fulfilmentMethod: "delivery", slotDays: nil, searchStoreId: nil, searchLatitude: nil, searchLongitude: nil))
        
        XCTAssertFalse(sut.isTimeSlotsLoading)
    }

    func test_whenSelectedTimeSlotIsToday_thenIsSlotSelectedTodayIsTrue() {
        let sut = makeSUT(isInCheckout: true)
        sut.selectedTimeSlot = RetailStoreSlotDayTimeSlot(slotId: "12", startTime: Date(), endTime: Date(), daytime: "", info: RetailStoreSlotDayTimeSlotInfo(status: "", isAsap: true, price: 0, fulfilmentIn: ""))
        
        XCTAssertTrue(sut.isSlotSelectedToday)
    }
    
    func test_whenFulfilmentExistsToday_thenTodayFulfilmentExistsIsTrue() {
        let sut = makeSUT()
        let todayAsString = Date().startOfDay.dateOnlyString(storeTimeZone: nil)
        let tomorrowAsString = Date(timeIntervalSinceNow: 60*60*24).startOfDay.dateOnlyString(storeTimeZone: nil)
        let fulfilmentDayToday = RetailStoreFulfilmentDay(date: todayAsString, holidayMessage: nil, start: nil, end: nil, storeDateStart: nil, storeDateEnd: nil)
        let fulfilmentDayTomorrow = RetailStoreFulfilmentDay(date: tomorrowAsString, holidayMessage: nil, start: nil, end: nil, storeDateStart: nil, storeDateEnd: nil)
        sut.availableFulfilmentDays = [fulfilmentDayToday, fulfilmentDayTomorrow]
        
        XCTAssertTrue(sut.todayFulfilmentExists)
    }
    
    func test_givenBasketContainsSelectedSlot_thenCorrectFulfilmentDayIsSelected() {
        let currentDate = Date().startOfDay
        let container = DIContainer(appState: AppState(), services: .mocked(retailStoreService: [.getStoreDeliveryTimeSlots(storeId: 123, startDate: currentDate.startOfDay, endDate: currentDate.endOfDay, location: FulfilmentTimeSlotSelectionViewModelTests.fulfilmentLocation.location)]))
        let sut = makeSUT(container: container)
        let selectedStoreDetails = RetailStoreDetails(id: 123, menuGroupId: 1, storeName: "", telephone: "", lat: 0, lng: 0, ordersPaused: false, canDeliver: true, distance: nil, pausedMessage: nil, address1: "", address2: nil, town: "", postcode: "TN223HY", customerOrderNotePlaceholder: nil, memberEmailCheck: nil, guestCheckoutAllowed: true, basketOnlyTimeSelection: false, ratings: nil, tips: nil, storeLogo: nil, storeProductTypes: nil, orderMethods: nil, deliveryDays: nil, collectionDays: nil, paymentMethods: nil, paymentGateways: nil, timeZone: nil, searchPostcode: nil)
        sut.selectedRetailStoreDetails = .loaded(selectedStoreDetails)
        let storeSearch = RetailStoresSearch(storeProductTypes: nil, stores: nil, fulfilmentLocation: FulfilmentTimeSlotSelectionViewModelTests.fulfilmentLocation)
        sut.storeSearchResult = .loaded(storeSearch)
        
        let menuItem = RetailStoreMenuItem(id: 12, name: "SomeItem", eposCode: nil, outOfStock: false, ageRestriction: 0, description: nil, quickAdd: true, acceptCustomerInstructions: true, basketQuantityLimit: 10, price: RetailStoreMenuItemPrice(price: 10, fromPrice: 10, unitMetric: "10", unitsInPack: 10, unitVolume: 10, wasPrice: nil), images: nil, menuItemSizes: nil, menuItemOptions: nil, availableDeals: nil)
        let basketItem = BasketItem(basketLineId: 1, menuItem: menuItem, totalPrice: 15, totalPriceBeforeDiscounts: 15, price: 15, pricePaid: 15, quantity: 1, instructions: nil, size: nil, selectedOptions: nil, missedPromotions: nil)
        let selectedSlot = BasketSelectedSlot(todaySelected: false, start: currentDate, end: currentDate, expires: nil)
        let basket = Basket(basketToken: "nejnsfkj", isNewBasket: true, items: [basketItem], fulfilmentMethod: BasketFulfilmentMethod(type: .delivery, cost: 1.5, minSpend: 0), selectedSlot: selectedSlot, savings: nil, coupon: nil, fees: nil, tips: nil, addresses: nil, orderSubtotal: 15, orderTotal: 15)
        sut.basket = basket
        
        let expectationBasket = expectation(description: "basket")
        let expectationStoreDetails = expectation(description: "selectedRetailStoreDetails")
        var cancellables = Set<AnyCancellable>()
        
        sut.$selectedRetailStoreDetails
            .collect(2)
            .receive(on: RunLoop.main)
            .sink { _ in
                expectationStoreDetails.fulfill()
            }
            .store(in: &cancellables)
        
        wait(for: [expectationStoreDetails], timeout: 2)
        
        sut.$basket
            .first()
            .receive(on: RunLoop.main)
            .sink { _ in
                expectationBasket.fulfill()
            }
            .store(in: &cancellables)
        
        wait(for: [expectationBasket], timeout: 2)
        
        container.services.verify()
    }
    
    func test_givenIsInCheckoutIsTrueAndTempTodayTimeSlotIsFilled_thenCorrectFulfilmentDayIsSelected() {
        let currentDate = Date().startOfDay
        let selectedStoreDetails = RetailStoreDetails(id: 123, menuGroupId: 1, storeName: "", telephone: "", lat: 0, lng: 0, ordersPaused: false, canDeliver: true, distance: nil, pausedMessage: nil, address1: "", address2: nil, town: "", postcode: "TN223HY", customerOrderNotePlaceholder: nil, memberEmailCheck: nil, guestCheckoutAllowed: true, basketOnlyTimeSelection: false, ratings: nil, tips: nil, storeLogo: nil, storeProductTypes: nil, orderMethods: nil, deliveryDays: nil, collectionDays: nil, paymentMethods: nil, paymentGateways: nil, timeZone: nil, searchPostcode: nil)
        let storeSearch = RetailStoresSearch(storeProductTypes: nil, stores: nil, fulfilmentLocation: FulfilmentTimeSlotSelectionViewModelTests.fulfilmentLocation)
        let tempSlot = RetailStoreSlotDayTimeSlot(slotId: "123", startTime: currentDate, endTime: currentDate, daytime: "", info: RetailStoreSlotDayTimeSlotInfo(status: "", isAsap: true, price: 10, fulfilmentIn: ""))
        let userData = AppState.UserData(selectedStore: .loaded(selectedStoreDetails), selectedFulfilmentMethod: .delivery, searchResult: .loaded(storeSearch), basket: nil, currentFulfilmentLocation: FulfilmentTimeSlotSelectionViewModelTests.fulfilmentLocation, memberSignedIn: false, basketContactDetails: nil, tempTodayTimeSlot: tempSlot, basketDeliveryAddress: nil)
        let appState = AppState(system: AppState.System(), routing: AppState.ViewRouting(), businessData: AppState.BusinessData(), userData: userData)
        let container = DIContainer(appState: appState, services: .mocked(retailStoreService: [.getStoreDeliveryTimeSlots(storeId: 123, startDate: currentDate.startOfDay, endDate: currentDate.endOfDay, location: FulfilmentTimeSlotSelectionViewModelTests.fulfilmentLocation.location)]))
        let _ = makeSUT(container: container, isInCheckout: true)
        
        container.services.verify()
    }
    
    func test_givenAvailableDays_thenFirstFulfilmentDayIsDelected() {
        let today = Date().startOfDay
        let tomorrow = today.addingTimeInterval(60*60*24)
        let deliveryDay1 = RetailStoreFulfilmentDay(date: today.dateOnlyString(storeTimeZone: nil), holidayMessage: nil, start: today.startOfDay.timeString(storeTimeZone: nil), end: today.endOfDay.timeString(storeTimeZone: nil), storeDateStart: today.startOfDay, storeDateEnd: today.endOfDay)
        let deliveryDay2 = RetailStoreFulfilmentDay(date: tomorrow.dateOnlyString(storeTimeZone: nil), holidayMessage: nil, start: tomorrow.startOfDay.timeString(storeTimeZone: nil), end: tomorrow.endOfDay.timeString(storeTimeZone: nil), storeDateStart: tomorrow.startOfDay, storeDateEnd: tomorrow.endOfDay)
        let selectedStoreDetails = RetailStoreDetails(id: 123, menuGroupId: 1, storeName: "", telephone: "", lat: 0, lng: 0, ordersPaused: false, canDeliver: true, distance: nil, pausedMessage: nil, address1: "", address2: nil, town: "", postcode: "TN223HY", customerOrderNotePlaceholder: nil, memberEmailCheck: nil, guestCheckoutAllowed: true, basketOnlyTimeSelection: false, ratings: nil, tips: nil, storeLogo: nil, storeProductTypes: nil, orderMethods: nil, deliveryDays: [deliveryDay1, deliveryDay2], collectionDays: nil, paymentMethods: nil, paymentGateways: nil, timeZone: nil, searchPostcode: nil)
        let storeSearch = RetailStoresSearch(storeProductTypes: nil, stores: nil, fulfilmentLocation: FulfilmentTimeSlotSelectionViewModelTests.fulfilmentLocation)
        let userData = AppState.UserData(selectedStore: .loaded(selectedStoreDetails), selectedFulfilmentMethod: .delivery, searchResult: .loaded(storeSearch), basket: nil, currentFulfilmentLocation: FulfilmentTimeSlotSelectionViewModelTests.fulfilmentLocation, memberSignedIn: false, basketContactDetails: nil, tempTodayTimeSlot: nil, basketDeliveryAddress: nil)
        let appState = AppState(system: AppState.System(), routing: AppState.ViewRouting(), businessData: AppState.BusinessData(), userData: userData)
        let container = DIContainer(appState: appState, services: .mocked(retailStoreService: [.getStoreDeliveryTimeSlots(storeId: 123, startDate: today.startOfDay, endDate: today.endOfDay, location: FulfilmentTimeSlotSelectionViewModelTests.fulfilmentLocation.location)]))
        let _ = makeSUT(container: container, isInCheckout: true)
        
        container.services.verify()
    }
    
    func test_givenTimeSlotInBasket_thenCorrectTimeSlotIsSelected() {
        let today = Date().startOfDay
        let tomorrow = today.addingTimeInterval(60*60*24)
        let selectedStoreDetails = RetailStoreDetails(id: 123, menuGroupId: 1, storeName: "", telephone: "", lat: 0, lng: 0, ordersPaused: false, canDeliver: true, distance: nil, pausedMessage: nil, address1: "", address2: nil, town: "", postcode: "TN223HY", customerOrderNotePlaceholder: nil, memberEmailCheck: nil, guestCheckoutAllowed: true, basketOnlyTimeSelection: false, ratings: nil, tips: nil, storeLogo: nil, storeProductTypes: nil, orderMethods: nil, deliveryDays: nil, collectionDays: nil, paymentMethods: nil, paymentGateways: nil, timeZone: nil, searchPostcode: nil)
        let menuItem = RetailStoreMenuItem(id: 12, name: "SomeItem", eposCode: nil, outOfStock: false, ageRestriction: 0, description: nil, quickAdd: true, acceptCustomerInstructions: true, basketQuantityLimit: 10, price: RetailStoreMenuItemPrice(price: 10, fromPrice: 10, unitMetric: "10", unitsInPack: 10, unitVolume: 10, wasPrice: nil), images: nil, menuItemSizes: nil, menuItemOptions: nil, availableDeals: nil)
        let basketItem = BasketItem(basketLineId: 1, menuItem: menuItem, totalPrice: 15, totalPriceBeforeDiscounts: 15, price: 15, pricePaid: 15, quantity: 1, instructions: nil, size: nil, selectedOptions: nil, missedPromotions: nil)
        let selectedSlot = BasketSelectedSlot(todaySelected: false, start: tomorrow, end: tomorrow.addingTimeInterval(60*30), expires: nil)
        let basket = Basket(basketToken: "nejnsfkj", isNewBasket: true, items: [basketItem], fulfilmentMethod: BasketFulfilmentMethod(type: .delivery, cost: 1.5, minSpend: 0), selectedSlot: selectedSlot, savings: nil, coupon: nil, fees: nil, tips: nil, addresses: nil, orderSubtotal: 15, orderTotal: 15)
        let userData = AppState.UserData(selectedStore: .loaded(selectedStoreDetails), selectedFulfilmentMethod: .delivery, searchResult: .loaded(FulfilmentTimeSlotSelectionViewModelTests.storeSearch), basket: basket, currentFulfilmentLocation: FulfilmentTimeSlotSelectionViewModelTests.fulfilmentLocation, memberSignedIn: false, basketContactDetails: nil, tempTodayTimeSlot: nil, basketDeliveryAddress: nil)
        let appState = AppState(system: AppState.System(), routing: AppState.ViewRouting(), businessData: AppState.BusinessData(), userData: userData)
        let container = DIContainer(appState: appState, services: .mocked(retailStoreService: [.getStoreDeliveryTimeSlots(storeId: 123, startDate: today.startOfDay, endDate: today.endOfDay, location: FulfilmentTimeSlotSelectionViewModelTests.fulfilmentLocation.location)]))
        let sut = makeSUT(container: container, isInCheckout: true)
        let timeSlot1 = RetailStoreSlotDayTimeSlot(slotId: "213", startTime: tomorrow, endTime: tomorrow.addingTimeInterval(60*30), daytime: "", info: RetailStoreSlotDayTimeSlotInfo(status: "", isAsap: true, price: 10, fulfilmentIn: ""))
        let timeSlot2 = RetailStoreSlotDayTimeSlot(slotId: "321", startTime: tomorrow.addingTimeInterval(60*60), endTime: tomorrow.addingTimeInterval(60*90), daytime: "", info: RetailStoreSlotDayTimeSlotInfo(status: "", isAsap: true, price: 10, fulfilmentIn: ""))
        let timeSlotDayTomorrow = RetailStoreSlotDay(status: "", reason: "", slotDate: tomorrow.dateOnlyString(storeTimeZone: nil), slots: [timeSlot1, timeSlot2])
        let timeSlots = RetailStoreTimeSlots(startDate: tomorrow.startOfDay, endDate: tomorrow.endOfDay, fulfilmentMethod: "delivery", slotDays: [timeSlotDayTomorrow], searchStoreId: nil, searchLatitude: nil, searchLongitude: nil)
        sut.selectedRetailStoreFulfilmentTimeSlots = .loaded(timeSlots)
        
        let expectation = expectation(description: "selectedTimeSlot")
        var cancellables = Set<AnyCancellable>()
        
        sut.$selectedTimeSlot
            .first()
            .receive(on: RunLoop.main)
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 2)
        
        XCTAssertEqual(sut.selectedTimeSlot, timeSlot1)
    }
    
    func test_givenTempTodayTimeSlotIsFilled_thenCorrectTimeSlotIsSelected() {
        let today = Date().startOfDay
        let tomorrow = today.addingTimeInterval(60*60*24)
        let selectedStoreDetails = RetailStoreDetails(id: 123, menuGroupId: 1, storeName: "", telephone: "", lat: 0, lng: 0, ordersPaused: false, canDeliver: true, distance: nil, pausedMessage: nil, address1: "", address2: nil, town: "", postcode: "TN223HY", customerOrderNotePlaceholder: nil, memberEmailCheck: nil, guestCheckoutAllowed: true, basketOnlyTimeSelection: false, ratings: nil, tips: nil, storeLogo: nil, storeProductTypes: nil, orderMethods: nil, deliveryDays: nil, collectionDays: nil, paymentMethods: nil, paymentGateways: nil, timeZone: nil, searchPostcode: nil)
        let storeSearch = RetailStoresSearch(storeProductTypes: nil, stores: nil, fulfilmentLocation: FulfilmentTimeSlotSelectionViewModelTests.fulfilmentLocation)
        let timeSlot1 = RetailStoreSlotDayTimeSlot(slotId: "123", startTime: tomorrow, endTime: tomorrow, daytime: "", info: RetailStoreSlotDayTimeSlotInfo(status: "", isAsap: true, price: 10, fulfilmentIn: ""))
        let userData = AppState.UserData(selectedStore: .loaded(selectedStoreDetails), selectedFulfilmentMethod: .delivery, searchResult: .loaded(storeSearch), basket: nil, currentFulfilmentLocation: FulfilmentTimeSlotSelectionViewModelTests.fulfilmentLocation, memberSignedIn: false, basketContactDetails: nil, tempTodayTimeSlot: timeSlot1, basketDeliveryAddress: nil)
        let appState = AppState(system: AppState.System(), routing: AppState.ViewRouting(), businessData: AppState.BusinessData(), userData: userData)
        let container = DIContainer(appState: appState, services: .mocked(retailStoreService: [.getStoreDeliveryTimeSlots(storeId: 123, startDate: tomorrow.startOfDay, endDate: tomorrow.endOfDay, location: FulfilmentTimeSlotSelectionViewModelTests.fulfilmentLocation.location)]))
        let sut = makeSUT(container: container)
        let timeSlot2 = RetailStoreSlotDayTimeSlot(slotId: "321", startTime: tomorrow.addingTimeInterval(60*60), endTime: tomorrow.addingTimeInterval(60*90), daytime: "", info: RetailStoreSlotDayTimeSlotInfo(status: "", isAsap: true, price: 10, fulfilmentIn: ""))
        let timeSlotDayTomorrow = RetailStoreSlotDay(status: "", reason: "", slotDate: tomorrow.dateOnlyString(storeTimeZone: nil), slots: [timeSlot1, timeSlot2])
        let timeSlots = RetailStoreTimeSlots(startDate: tomorrow.startOfDay, endDate: tomorrow.endOfDay, fulfilmentMethod: "delivery", slotDays: [timeSlotDayTomorrow], searchStoreId: nil, searchLatitude: nil, searchLongitude: nil)
        sut.selectedRetailStoreFulfilmentTimeSlots = .loaded(timeSlots)
        
        let expectation = expectation(description: "selectedTimeSlot")
        var cancellables = Set<AnyCancellable>()

        sut.$selectedTimeSlot
            .first()
            .receive(on: RunLoop.main)
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 2)
        
        XCTAssertEqual(sut.selectedTimeSlot, timeSlot1)
    }

    func makeSUT(container: DIContainer = DIContainer(appState: AppState(), services: .mocked()), isInCheckout: Bool = false) -> FulfilmentTimeSlotSelectionViewModel {
        let sut = FulfilmentTimeSlotSelectionViewModel(container: container, isInCheckout: isInCheckout)

        trackForMemoryLeaks(sut)

        return sut
    }
    
    static let fulfilmentLocation = FulfilmentLocation(country: "UK", latitude: 0, longitude: 0, postcode: "TN223HY")
    
    static let storeSearch = RetailStoresSearch(storeProductTypes: nil, stores: nil, fulfilmentLocation: fulfilmentLocation)
}
