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
    }
    
    func test_givenInit_whenSelectedDaySlotAndSelectedTimeSlotIsPopulated_thenIsDataSelectedIsTrue() {
        let sut = makeSUT()
        
        sut.selectedDaySlot = RetailStoreSlotDay(status: "", reason: "", slotDate: "", slots: [])
        sut.selectedTimeSlot = RetailStoreSlotDayTimeSlot(slotId: "1", startTime: Date(), endTime: Date().addingTimeInterval(60*60), daytime: "", info: RetailStoreSlotDayTimeSlotInfo(status: "", isAsap: false, price: 2, fulfilmentIn: "30-60 mins"))
        
        XCTAssertTrue(sut.isFulfilmentSlotSelected)
    }
    
    func test_givenSearchResultAndStoreDetails_whenSelectFulfilmentDateTappedAndFulfilmentMethodIsDelivery_thenVerified() {
        let currentDate = Date()
        let fulfilmentLocation = FulfilmentLocation(country: "UK", latitude: 0, longitude: 0, postcode: "TN223HY")
        let container = DIContainer(appState: AppState(), services: .mocked(retailStoreService: [.getStoreDeliveryTimeSlots(storeId: 123, startDate: currentDate, endDate: currentDate.addingTimeInterval(60*60*23), location: fulfilmentLocation.location)]))
        let sut = makeSUT(container: container)
        
        let storeDetails = RetailStoreDetails(id: 123, menuGroupId: 1, storeName: "SomeStore", telephone: "", lat: 0, lng: 0, ordersPaused: false, canDeliver: true, distance: nil, pausedMessage: nil, address1: "", address2: nil, town: "", postcode: "", customerOrderNotePlaceholder: nil, memberEmailCheck: false, guestCheckoutAllowed: true, ratings: nil, tips: nil, storeLogo: nil, storeProductTypes: nil, orderMethods: nil, deliveryDays: nil, collectionDays: nil, paymentMethods: nil, paymentGateways: nil, timeZone: nil, searchPostcode: nil)
        sut.selectedRetailStoreDetails = .loaded(storeDetails)
        sut.storeSearchResult = .loaded(RetailStoresSearch(storeProductTypes: nil, stores: nil, fulfilmentLocation: fulfilmentLocation))
        
        sut.selectFulfilmentDate(startDate: currentDate, endDate: currentDate.addingTimeInterval(60*60*23), storeID: 123)
        
        container.services.verify()
    }
    
    func test_givenSearchResultAndStoreDetails_whenSelectFulfilmentDateTapped_andFulfilmentMethodIsCollection_thenVerified() {
        let currentDate = Date()
        let fulfilmentLocation = FulfilmentLocation(country: "UK", latitude: 0, longitude: 0, postcode: "TN223HY")
        let container = DIContainer(appState: AppState(), services: .mocked(retailStoreService: [.getStoreCollectionTimeSlots(storeId: 123, startDate: currentDate, endDate: currentDate.addingTimeInterval(60*60*23))]))
        container.appState.value.userData.selectedFulfilmentMethod = .collection
        let sut = makeSUT(container: container)
        
        let storeDetails = RetailStoreDetails(id: 123, menuGroupId: 1, storeName: "SomeStore", telephone: "", lat: 0, lng: 0, ordersPaused: false, canDeliver: true, distance: nil, pausedMessage: nil, address1: "", address2: nil, town: "", postcode: "", customerOrderNotePlaceholder: nil, memberEmailCheck: false, guestCheckoutAllowed: true, ratings: nil, tips: nil, storeLogo: nil, storeProductTypes: nil, orderMethods: nil, deliveryDays: nil, collectionDays: nil, paymentMethods: nil, paymentGateways: nil, timeZone: nil, searchPostcode: nil)
        sut.selectedRetailStoreDetails = .loaded(storeDetails)
        sut.storeSearchResult = .loaded(RetailStoresSearch(storeProductTypes: nil, stores: nil, fulfilmentLocation: fulfilmentLocation))
        
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
        let todayDate = Date()
        let todayString = todayDate.dateOnlyString(storeTimeZone: nil)
        let deliveryDays = [RetailStoreFulfilmentDay(date: todayString, holidayMessage: nil, start: "", end: "", storeDateStart: todayDate.startOfDay, storeDateEnd: todayDate.endOfDay)]
        let store = RetailStoreDetails(id: 123, menuGroupId: 23, storeName: "", telephone: "", lat: 0, lng: 0, ordersPaused: false, canDeliver: true, distance: nil, pausedMessage: nil, address1: "", address2: nil, town: "", postcode: "", customerOrderNotePlaceholder: nil, memberEmailCheck: false, guestCheckoutAllowed: true, ratings: nil, tips: nil, storeLogo: nil, storeProductTypes: nil, orderMethods: nil, deliveryDays: deliveryDays, collectionDays: nil, paymentMethods: nil, paymentGateways: nil, timeZone: nil, searchPostcode: nil)
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
        let todayDate = Date()
        let todayString = todayDate.dateOnlyString(storeTimeZone: nil)
        let deliveryDays = [RetailStoreFulfilmentDay(date: todayString, holidayMessage: nil, start: "", end: "", storeDateStart: todayDate.startOfDay, storeDateEnd: todayDate.endOfDay)]
        let store = RetailStoreDetails(id: 123, menuGroupId: 23, storeName: "", telephone: "", lat: 0, lng: 0, ordersPaused: false, canDeliver: true, distance: nil, pausedMessage: nil, address1: "", address2: nil, town: "", postcode: "", customerOrderNotePlaceholder: nil, memberEmailCheck: false, guestCheckoutAllowed: true, ratings: nil, tips: nil, storeLogo: nil, storeProductTypes: nil, orderMethods: nil, deliveryDays: deliveryDays, collectionDays: nil, paymentMethods: nil, paymentGateways: nil, timeZone: nil, searchPostcode: nil)
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
    
    func test_givenSelectedDaySlotAndSelectedTimeSlot_whenShopNowButtonTapped_thenContinueToItemMenuCalledAndSelectedTabCorrectAndReserveTimeSlotTriggeredAndIsCorrect() {
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
    
    func test_whenDismissViewTriggered_thenViewDismissedIsTrue() {
        let sut = makeSUT()
        
        sut.dismissView()
        
        XCTAssertTrue(sut.viewDismissed)
    }

    func test_whenSelectedTimeSlotIsToday_thenIsSlotSelectedTodayIsTrue() {
        let sut = makeSUT(isInCheckout: true)
        sut.selectedTimeSlot = RetailStoreSlotDayTimeSlot(slotId: "12", startTime: Date(), endTime: Date(), daytime: "", info: RetailStoreSlotDayTimeSlotInfo(status: "", isAsap: true, price: 0, fulfilmentIn: ""))
        
        XCTAssertTrue(sut.isSlotSelectedToday)
    }
    
    func test_whenFulfilmentExistsToday_thenTodayFulfilmentExistsIsTrue() {
        let sut = makeSUT()
        let todayAsString = Date().dateOnlyString(storeTimeZone: nil)
        let tomorrowAsString = Date(timeIntervalSinceNow: 60*60*24).dateOnlyString(storeTimeZone: nil)
        let fulfilmentDayToday = RetailStoreFulfilmentDay(date: todayAsString, holidayMessage: nil, start: nil, end: nil, storeDateStart: nil, storeDateEnd: nil)
        let fulfilmentDayTomorrow = RetailStoreFulfilmentDay(date: tomorrowAsString, holidayMessage: nil, start: nil, end: nil, storeDateStart: nil, storeDateEnd: nil)
        sut.availableFulfilmentDays = [fulfilmentDayToday, fulfilmentDayTomorrow]
        
        XCTAssertTrue(sut.todayFulfilmentExists)
    }
    
    func test_whenOptimisticReserveTimeSlotIsTriggered_thenAppStateTempTodayTimeSlotIsPopulated() {
        let sut = makeSUT()
        let timeSlot = RetailStoreSlotDayTimeSlot(slotId: "12", startTime: Date(), endTime: Date(), daytime: "", info: RetailStoreSlotDayTimeSlotInfo(status: "", isAsap: true, price: 0, fulfilmentIn: ""))
        sut.optimisticReserveTimeSlot(timeSlot: timeSlot)
        
        XCTAssertEqual(sut.container.appState.value.userData.tempTodayTimeSlot, timeSlot)
    }
    
    func test_givenIsTodaySelectedWithSlotSelectionsRestrictedIsTrue_whenShopNowButtonTapped_thenTodayFulfilmentTappedIsTriggered() {
        let sut = makeSUT()
        sut.isTodaySelectedWithSlotSelectionRestrictions = true
        
        
    }

    func makeSUT(container: DIContainer = DIContainer(appState: AppState(), services: .mocked()), isInCheckout: Bool = false) -> FulfilmentTimeSlotSelectionViewModel {
        let sut = FulfilmentTimeSlotSelectionViewModel(container: container, isInCheckout: isInCheckout)

        trackForMemoryLeaks(sut)

        return sut
    }
}
