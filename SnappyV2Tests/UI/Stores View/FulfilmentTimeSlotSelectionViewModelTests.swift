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
        XCTAssertFalse(sut.isFutureFulfilmentSelected)
        XCTAssertEqual(sut.selectedRetailStoreDetails, .notRequested)
        XCTAssertEqual(sut.selectedRetailStoreFulfilmentTimeSlots, .notRequested)
        XCTAssertEqual(sut.storeSearchResult, .notRequested)
        XCTAssertTrue(sut.availableFulfilmentDays.isEmpty)
        XCTAssertNil(sut.selectedDaySlot)
        XCTAssertTrue(sut.morningTimeSlots.isEmpty)
        XCTAssertTrue(sut.afternoonTimeSlots.isEmpty)
        XCTAssertTrue(sut.eveningTimeSlots.isEmpty)
        XCTAssertTrue(sut.isTodayFulfilmentDisabled)
        XCTAssertTrue(sut.isFutureFulfilmentDisabled)
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
        XCTAssertFalse(sut.isFutureFulfilmentSelected)
        XCTAssertEqual(sut.selectedRetailStoreDetails, .notRequested)
        XCTAssertEqual(sut.selectedRetailStoreFulfilmentTimeSlots, .notRequested)
        XCTAssertEqual(sut.storeSearchResult, .notRequested)
        XCTAssertTrue(sut.availableFulfilmentDays.isEmpty)
        XCTAssertNil(sut.selectedDaySlot)
        XCTAssertTrue(sut.morningTimeSlots.isEmpty)
        XCTAssertTrue(sut.afternoonTimeSlots.isEmpty)
        XCTAssertTrue(sut.eveningTimeSlots.isEmpty)
        XCTAssertTrue(sut.isTodayFulfilmentDisabled)
        XCTAssertTrue(sut.isFutureFulfilmentDisabled)
        XCTAssertFalse(sut.isTimeSlotsLoading)
        XCTAssertFalse(sut.isFulfilmentSlotSelected)
        XCTAssertFalse(sut.isReservingTimeSlot)
        XCTAssertFalse(sut.viewDismissed)
        XCTAssertEqual(sut.slotDescription, GeneralStrings.collection.localized)
    }
    
    func test_givenInit_whenIsFutureDeliveryTapped_thenIsFutureDeliverySelectedIsTrue() {
        let sut = makeSUT()
        
        sut.futureFulfilmentTapped()
        
        XCTAssertTrue(sut.isFutureFulfilmentSelected)
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
        
        let storeDetails = RetailStoreDetails(id: 123, menuGroupId: 1, storeName: "SomeStore", telephone: "", lat: 0, lng: 0, ordersPaused: false, canDeliver: true, distance: nil, pausedMessage: nil, address1: "", address2: nil, town: "", postcode: "", customerOrderNotePlaceholder: nil, ratings: nil, storeLogo: nil, storeProductTypes: nil, orderMethods: nil, deliveryDays: nil, collectionDays: nil, timeZone: nil, searchPostcode: nil)
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
        
        let storeDetails = RetailStoreDetails(id: 123, menuGroupId: 1, storeName: "SomeStore", telephone: "", lat: 0, lng: 0, ordersPaused: false, canDeliver: true, distance: nil, pausedMessage: nil, address1: "", address2: nil, town: "", postcode: "", customerOrderNotePlaceholder: nil, ratings: nil, storeLogo: nil, storeProductTypes: nil, orderMethods: nil, deliveryDays: nil, collectionDays: nil, timeZone: nil, searchPostcode: nil)
        sut.selectedRetailStoreDetails = .loaded(storeDetails)
        sut.storeSearchResult = .loaded(RetailStoresSearch(storeProductTypes: nil, stores: nil, fulfilmentLocation: fulfilmentLocation))
        
        sut.selectFulfilmentDate(startDate: currentDate, endDate: currentDate.addingTimeInterval(60*60*23), storeID: 123)
        
        container.services.verify()
    }
    
    func test_givenNilDayTimeSlots_thenAllTimeSlotsEmpty() {
        let sut = makeSUT()
        sut.futureFulfilmentSetup()

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
        sut.futureFulfilmentSetup()
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
        
        let morningSlot1 = RetailStoreSlotDayTimeSlot(slotId: "", startTime: Date(), endTime: Date(), daytime: "morning", info: .init(status: "", isAsap: false, price: 0, fulfilmentIn: ""))
        let morningSlot2 = RetailStoreSlotDayTimeSlot(slotId: "", startTime: Date(), endTime: Date(), daytime: "morning", info: .init(status: "", isAsap: false, price: 0, fulfilmentIn: ""))
        let afternoonSlot = RetailStoreSlotDayTimeSlot(slotId: "", startTime: Date(), endTime: Date(), daytime: "afternoon", info: .init(status: "", isAsap: false, price: 0, fulfilmentIn: ""))
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
    
    func test_whenDeliveryTodayTapped_thenContinueToItemMenuCalledAndSelectedTabCorrect() {
        var appState = AppState()
        let today = Date()
        let deliveryDays = [RetailStoreFulfilmentDay(date: "Today", holidayMessage: nil, start: "", end: "", storeDateStart: today, storeDateEnd: today)]
        let store = RetailStoreDetails(id: 123, menuGroupId: 23, storeName: "", telephone: "", lat: 0, lng: 0, ordersPaused: false, canDeliver: true, distance: nil, pausedMessage: nil, address1: "", address2: nil, town: "", postcode: "", customerOrderNotePlaceholder: nil, ratings: nil, storeLogo: nil, storeProductTypes: nil, orderMethods: nil, deliveryDays: deliveryDays, collectionDays: nil, timeZone: nil, searchPostcode: nil)
        appState.userData.selectedStore = .loaded(store)
        let container = DIContainer(appState: appState, services: .mocked(basketService: [.reserveTimeSlot(timeSlotDate: "Today", timeSlotTime: nil)]))
        
        let sut = makeSUT(container: container)
        
        let expectation1 = expectation(description: "availableFulfilmentDays")
        let expectation2 = expectation(description: "availableFulfilmentDays")
        var cancellables = Set<AnyCancellable>()
        
        sut.$availableFulfilmentDays
            .collect(2)
            .receive(on: RunLoop.main)
            .sink { _ in
                expectation1.fulfill()
            }
            .store(in: &cancellables)
        
        wait(for: [expectation1], timeout: 5)
        
        sut.todayFulfilmentTapped()
        
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
    
    func test_whenCollectionTodayTapped_thenContinueToItemMenuCalledAndSelectedTabCorrect() {
        var appState = AppState()
        let today = Date()
        let collectionDays = [RetailStoreFulfilmentDay(date: "Today", holidayMessage: nil, start: "", end: "", storeDateStart: today, storeDateEnd: today)]
        let store = RetailStoreDetails(id: 123, menuGroupId: 23, storeName: "", telephone: "", lat: 0, lng: 0, ordersPaused: false, canDeliver: true, distance: nil, pausedMessage: nil, address1: "", address2: nil, town: "", postcode: "", customerOrderNotePlaceholder: nil, ratings: nil, storeLogo: nil, storeProductTypes: nil, orderMethods: nil, deliveryDays: nil, collectionDays: collectionDays, timeZone: nil, searchPostcode: nil)
        appState.userData.selectedStore = .loaded(store)
        appState.userData.selectedFulfilmentMethod = .collection
        let container = DIContainer(appState: appState, services: .mocked(basketService: [.reserveTimeSlot(timeSlotDate: "Today", timeSlotTime: nil)]))
        
        let sut = makeSUT(container: container)
        
        let expectation1 = expectation(description: "availableFulfilmentDays")
        let expectation2 = expectation(description: "availableFulfilmentDays")
        var cancellables = Set<AnyCancellable>()
        
        sut.$availableFulfilmentDays
            .collect(2)
            .receive(on: RunLoop.main)
            .sink { _ in
                expectation1.fulfill()
            }
            .store(in: &cancellables)
        
        wait(for: [expectation1], timeout: 5)
        
        sut.todayFulfilmentTapped()
        
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
        let endTIme = dateFormatter.string(from: Date().addingTimeInterval(60*60))
        
        let container = DIContainer(appState: AppState(), services: .mocked(basketService: [.reserveTimeSlot(timeSlotDate: "Tomorrow", timeSlotTime: "\(startTime) - \(endTIme)")]))
        
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
    
    func test_givenSingleAvailableDeliveryDayIsTomorrow_thenIsASAPDeliveryDisabledReturnsTrue() {
        let tomorrow = Date(timeIntervalSinceNow: 60*60*24)
        let sut = makeSUT()
        sut.availableFulfilmentDays = [RetailStoreFulfilmentDay(date: "", holidayMessage: nil, start: "", end: "", storeDateStart: tomorrow, storeDateEnd: tomorrow)]
        
        XCTAssertTrue(sut.isTodayFulfilmentDisabled)
    }
    
    func test_givenSingleAvailableFulfilmentDayIsToday_thenIsTodayFulfilmentDisabledReturnsFalse() {
        let today = Date()
        let sut = makeSUT()
        sut.availableFulfilmentDays = [RetailStoreFulfilmentDay(date: "", holidayMessage: nil, start: "", end: "", storeDateStart: today, storeDateEnd: today)]
        
        XCTAssertFalse(sut.isTodayFulfilmentDisabled)
    }
    
    func test_givenSingleAvailableDeliveryDayIsTomorrow_thenIsFutureDeliveryDisabledReturnsFalse() {
        let tomorrow = Date(timeIntervalSinceNow: 60*60*24)
        let sut = makeSUT()
        sut.availableFulfilmentDays = [RetailStoreFulfilmentDay(date: "", holidayMessage: nil, start: "", end: "", storeDateStart: tomorrow, storeDateEnd: tomorrow)]
        
        XCTAssertFalse(sut.isFutureFulfilmentDisabled)
    }
    
    func test_givenSingleAvailableFulfilmentDayIsToday_thenIsFutureFulfilmentDisabledReturnsTrue() {
        let today = Date()
        let sut = makeSUT()
        sut.availableFulfilmentDays = [RetailStoreFulfilmentDay(date: "", holidayMessage: nil, start: "", end: "", storeDateStart: today, storeDateEnd: today)]
        
        XCTAssertTrue(sut.isFutureFulfilmentDisabled)
    }
    
    func test_givenTwoAvailableFulfilmentDayTomorrowAndToday_thenIsFutureFulfilmentDisabledReturnsFalse() {
        let tomorrow = Date(timeIntervalSinceNow: 60*60*24)
        let today = Date()
        let tomorrowDelivery = RetailStoreFulfilmentDay(date: "", holidayMessage: nil, start: "", end: "", storeDateStart: tomorrow, storeDateEnd: tomorrow)
        let todayDelivery = RetailStoreFulfilmentDay(date: "", holidayMessage: nil, start: "", end: "", storeDateStart: today, storeDateEnd: today)
        let sut = makeSUT()
        sut.availableFulfilmentDays = [todayDelivery, tomorrowDelivery]
        
        XCTAssertFalse(sut.isFutureFulfilmentDisabled)
    }
    
    func test_givenTwoAvailableFulfilmentDayTomorrowAndDayAfter_thenIsFutureFulfilmentDisabledReturnsFalse() {
        let tomorrow = Date(timeIntervalSinceNow: 60*60*24)
        let dayAfter = Date(timeIntervalSinceNow: 60*60*24*2)
        let tomorrowDelivery = RetailStoreFulfilmentDay(date: "", holidayMessage: nil, start: "", end: "", storeDateStart: tomorrow, storeDateEnd: tomorrow)
        let dayAfterDelivery = RetailStoreFulfilmentDay(date: "", holidayMessage: nil, start: "", end: "", storeDateStart: dayAfter, storeDateEnd: dayAfter)
        let sut = makeSUT()
        sut.availableFulfilmentDays = [dayAfterDelivery, tomorrowDelivery]
        
        XCTAssertFalse(sut.isFutureFulfilmentDisabled)
    }
    
    func test_whenDismissViewTriggered_thenViewDismissedIsTrue() {
        let sut = makeSUT()
        
        sut.dismissView()
        
        XCTAssertTrue(sut.viewDismissed)
    }
    
    func makeSUT(container: DIContainer = DIContainer(appState: AppState(), services: .mocked())) -> FulfilmentTimeSlotSelectionViewModel {
        let sut = FulfilmentTimeSlotSelectionViewModel(container: container)

        trackForMemoryLeaks(sut)

        return sut
    }
}
