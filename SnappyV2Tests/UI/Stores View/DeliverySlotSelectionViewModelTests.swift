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
        
        sut.selectDeliveryDate(startDate: currentDate, endDate: currentDate.addingTimeInterval(60*60*23))
        
        container.services.verify()
    }
    
    func test_givenVariousDaytimeSlots_thenCorrectTimeSlotsFilled() {
        let sut = makeSUT()
        let morningSlot1 = RetailStoreSlotDayTimeSlot(slotId: "", startTime: Date(), endTime: Date(), daytime: .morning, info: .init(status: "", isAsap: false, price: 0, fulfilmentIn: ""))
        let morningSlot2 = RetailStoreSlotDayTimeSlot(slotId: "", startTime: Date(), endTime: Date(), daytime: .morning, info: .init(status: "", isAsap: false, price: 0, fulfilmentIn: ""))
        let afternoonSlot = RetailStoreSlotDayTimeSlot(slotId: "", startTime: Date(), endTime: Date(), daytime: .afternoon, info: .init(status: "", isAsap: false, price: 0, fulfilmentIn: ""))
        let daySlot = RetailStoreSlotDay(status: "", reason: "", slotDate: "", slots: [morningSlot1, morningSlot2, afternoonSlot])
        sut.selectedDaySlot = daySlot
        
        let expectation = expectation(description: "setupDeliveryDaytimeSectionSlots")
        var cancellables = Set<AnyCancellable>()
        
        sut.$selectedDaySlot
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 5)
        
        XCTAssertEqual(sut.morningTimeSlots.count, 2)
        XCTAssertEqual(sut.morningTimeSlots.first, morningSlot1)
        XCTAssertEqual(sut.afternoonTimeSlots.count, 1)
        XCTAssertEqual(sut.afternoonTimeSlots.first, afternoonSlot)
        XCTAssertEqual(sut.eveningTimeSlots.count, 0)
        XCTAssertTrue(sut.eveningTimeSlots.isEmpty)
    }

    func makeSUT(container: DIContainer = DIContainer(appState: AppState(), services: .mocked())) -> DeliverySlotSelectionViewModel {
        let sut = DeliverySlotSelectionViewModel(container: container)
        
        trackForMemoryLeaks(sut)
        
        return sut
    }

}
