//
//  DeliverySlotSelectionViewModelTests.swift
//  SnappyV2Tests
//
//  Created by Henrik Gustavii on 24/09/2021.
//

import XCTest
import MapKit
import Combine
@testable import SnappyV2

class DeliverySlotSelectionViewModelTests: XCTestCase {
    
    func test_init() {
        let sut = makeSUT()
        
        XCTAssertFalse(sut.isDeliverySelected)
        XCTAssertFalse(sut.isFutureDeliverySelected)
        XCTAssertEqual(sut.selectedRetailStoreDetails, .notRequested)
        XCTAssertEqual(sut.selectedRetailStoreDeliveryTimeSlots, .notRequested)
        XCTAssertEqual(sut.storeSearchResult, .notRequested)
        XCTAssertTrue(sut.availableDeliveryDays.isEmpty)
        XCTAssertNil(sut.selectedDaySlot)
        XCTAssertTrue(sut.morningTimeSlots.isEmpty)
        XCTAssertTrue(sut.afternoonTimeSlots.isEmpty)
        XCTAssertTrue(sut.eveningTimeSlots.isEmpty)
        XCTAssertTrue(sut.isASAPDeliveryDisabled)
        XCTAssertTrue(sut.isFutureDeliveryDisabled)
        XCTAssertFalse(sut.isTimeSlotsLoading)
        XCTAssertFalse(sut.isDeliverySlotSelected)
    }
    
    func test_givenInit_whenIsFutureDeliveryTapped_thenIsFutureDeliverySelectedIsTrue() {
        let sut = makeSUT()
        
        sut.futureDeliveryTapped()
        
        XCTAssertTrue(sut.isFutureDeliverySelected)
    }
    
    func test_givenInit_whenSelectedDaySlotAndSelectedTimeSlotIsPopulated_thenIsDataSelectedIsTrue() {
        let sut = makeSUT()
        
        sut.selectedDaySlot = RetailStoreSlotDay(status: "", reason: "", slotDate: "", slots: [])
        sut.selectedTimeSlot = "1"
        
        XCTAssertTrue(sut.isDeliverySlotSelected)
    }
    
    func test_givenIsDeliverySelected_whenShopNotTapped_thenAppStateRoutingTabSetTo2() {
        let sut = makeSUT()
        sut.selectedDaySlot = RetailStoreSlotDay(status: "", reason: "", slotDate: "", slots: [])
        sut.selectedTimeSlot = "1"
        
        sut.shopNowButtonTapped()
        
        XCTAssertEqual(sut.container.appState.value.routing.selectedTab, 2)
    }
    
    func test_givenSearchResultAndStoreDetails_whenSelectDeliveryDateTapped_thenVerified() {
        let currentDate = Date()
        let fulfilmentLocation = FulfilmentLocation(countryCode: "UK", lat: 0, lng: 0, postcode: "TN223HY")
        let container = DIContainer(appState: AppState(), services: .mocked(retailStoreService: [.getStoreDeliveryTimeSlots(storeId: 123, startDate: currentDate, endDate: currentDate.addingTimeInterval(60*60*23), location: fulfilmentLocation.location)]))
        let sut = makeSUT(container: container)
        
        let storeDetails = RetailStoreDetails(id: 123, menuGroupId: 1, storeName: "SomeStore", telephone: "", lat: 0, lng: 0, ordersPaused: false, canDeliver: true, distance: nil, pausedMessage: nil, address1: "", address2: nil, town: "", postcode: "", storeLogo: nil, storeProductTypes: nil, orderMethods: nil, deliveryDays: nil, collectionDays: nil, timeZone: nil, searchPostcode: nil)
        sut.selectedRetailStoreDetails = .loaded(storeDetails)
        sut.storeSearchResult = .loaded(RetailStoresSearch(storeProductTypes: nil, stores: nil, fulfilmentLocation: fulfilmentLocation))
        
        sut.selectDeliveryDate(startDate: currentDate, endDate: currentDate.addingTimeInterval(60*60*23), storeID: 123)
        
        container.services.verify()
    }
    
    func test_givenNilDayTimeSlots_thenAllTimeSlotsEmpty() {
        let sut = makeSUT()
        sut.futureDeliverySetup()

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
        sut.futureDeliverySetup()
        sut.selectedTimeSlot = "SelectedTimeSlot"
        
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
        
        let morningSlot1 = RetailStoreSlotDayTimeSlot(slotId: "", startTime: Date(), endTime: Date(), daytime: .morning, info: .init(status: "", isAsap: false, price: 0, fulfilmentIn: ""))
        let morningSlot2 = RetailStoreSlotDayTimeSlot(slotId: "", startTime: Date(), endTime: Date(), daytime: .morning, info: .init(status: "", isAsap: false, price: 0, fulfilmentIn: ""))
        let afternoonSlot = RetailStoreSlotDayTimeSlot(slotId: "", startTime: Date(), endTime: Date(), daytime: .afternoon, info: .init(status: "", isAsap: false, price: 0, fulfilmentIn: ""))
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
    
    func test_whenContinueToItemMenuCalled_thenSelectedTabCorrect() {
        let sut = makeSUT()
        
        sut.continueToItemMenu()
        
        XCTAssertEqual(sut.container.appState.value.routing.selectedTab, 2)
    }
    
    func test_whenAsapDeliveryTapped_thenContinueToItemMenuCalledAndSelectedTabCorrect() {
        let sut = makeSUT()
        
        sut.asapDeliveryTapped()
        
        XCTAssertEqual(sut.container.appState.value.routing.selectedTab, 2)
    }
    
    func test_whenShopNowButtonTapped_thenContinueToItemMenuCalledAndSelectedTabCorrect() {
        let sut = makeSUT()
        
        sut.shopNowButtonTapped()
        
        XCTAssertEqual(sut.container.appState.value.routing.selectedTab, 2)
    }
    
    func test_givenSelectedRetailStoreDeliveryTimeSlots_whenIsLoadingStatus_thenReturnsTrue() {
        let sut = makeSUT()
        sut.selectedRetailStoreDeliveryTimeSlots = .isLoading(last: nil, cancelBag: CancelBag())
        
        XCTAssertTrue(sut.isTimeSlotsLoading)
    }
    
    func test_givenSelectedRetailStoreDeliveryTimeSlots_whenLoadedStatus_thenReturnsFalse() {
        let sut = makeSUT()
        sut.selectedRetailStoreDeliveryTimeSlots = .loaded(RetailStoreTimeSlots(startDate: Date(), endDate: Date(), fulfilmentMethod: "delivery", slotDays: nil, searchStoreId: nil, searchLatitude: nil, searchLongitude: nil))
        
        XCTAssertFalse(sut.isTimeSlotsLoading)
    }
    
    func test_givenSingleAvailableDeliveryDayIsTomorrow_thenIsASAPDeliveryDisabledReturnsTrue() {
        let tomorrow = Date(timeIntervalSinceNow: 60*60*24)
        let sut = makeSUT()
        sut.availableDeliveryDays = [RetailStoreFulfilmentDay(date: "", start: "", end: "", storeDateStart: tomorrow, storeDateEnd: tomorrow)]
        
        XCTAssertTrue(sut.isASAPDeliveryDisabled)
    }
    
    func test_givenSingleAvailableDeliveryDayIsToday_thenIsASAPDeliveryDisabledReturnsFalse() {
        let today = Date()
        let sut = makeSUT()
        sut.availableDeliveryDays = [RetailStoreFulfilmentDay(date: "", start: "", end: "", storeDateStart: today, storeDateEnd: today)]
        
        XCTAssertFalse(sut.isASAPDeliveryDisabled)
    }
    
    func test_givenSingleAvailableDeliveryDayIsTomorrow_thenIsFutureDeliveryDisabledReturnsFalse() {
        let tomorrow = Date(timeIntervalSinceNow: 60*60*24)
        let sut = makeSUT()
        sut.availableDeliveryDays = [RetailStoreFulfilmentDay(date: "", start: "", end: "", storeDateStart: tomorrow, storeDateEnd: tomorrow)]
        
        XCTAssertFalse(sut.isFutureDeliveryDisabled)
    }
    
    func test_givenSingleAvailableDeliveryDayIsToday_thenIsFutureDeliveryDisabledReturnsTrue() {
        let today = Date()
        let sut = makeSUT()
        sut.availableDeliveryDays = [RetailStoreFulfilmentDay(date: "", start: "", end: "", storeDateStart: today, storeDateEnd: today)]
        
        XCTAssertTrue(sut.isFutureDeliveryDisabled)
    }
    
    func test_givenTwoAvailableDeliveryDayTomorrowAndToday_thenIsFutureDeliveryDisabledReturnsFalse() {
        let tomorrow = Date(timeIntervalSinceNow: 60*60*24)
        let today = Date()
        let tomorrowDelivery = RetailStoreFulfilmentDay(date: "", start: "", end: "", storeDateStart: tomorrow, storeDateEnd: tomorrow)
        let todayDelivery = RetailStoreFulfilmentDay(date: "", start: "", end: "", storeDateStart: today, storeDateEnd: today)
        let sut = makeSUT()
        sut.availableDeliveryDays = [todayDelivery, tomorrowDelivery]
        
        XCTAssertFalse(sut.isFutureDeliveryDisabled)
    }
    
    func test_givenTwoAvailableDeliveryDayTomorrowAndDayAfter_thenIsFutureDeliveryDisabledReturnsFalse() {
        let tomorrow = Date(timeIntervalSinceNow: 60*60*24)
        let dayAfter = Date(timeIntervalSinceNow: 60*60*24*2)
        let tomorrowDelivery = RetailStoreFulfilmentDay(date: "", start: "", end: "", storeDateStart: tomorrow, storeDateEnd: tomorrow)
        let dayAfterDelivery = RetailStoreFulfilmentDay(date: "", start: "", end: "", storeDateStart: dayAfter, storeDateEnd: dayAfter)
        let sut = makeSUT()
        sut.availableDeliveryDays = [dayAfterDelivery, tomorrowDelivery]
        
        XCTAssertFalse(sut.isFutureDeliveryDisabled)
    }

    func makeSUT(container: DIContainer = DIContainer(appState: AppState(), services: .mocked())) -> DeliverySlotSelectionViewModel {
        let sut = DeliverySlotSelectionViewModel(container: container)
        
        trackForMemoryLeaks(sut)
        
        return sut
    }
}
