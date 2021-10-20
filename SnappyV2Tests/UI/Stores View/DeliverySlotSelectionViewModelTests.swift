//
//  DeliverySlotSelectionViewModelTests.swift
//  SnappyV2Tests
//
//  Created by Henrik Gustavii on 24/09/2021.
//

import XCTest
@testable import SnappyV2

class DeliverySlotSelectionViewModelTests: XCTestCase {
    
    func test_init() {
        let sut = makeSUT()
        
        XCTAssertFalse(sut.isDeliverySelected)
        XCTAssertFalse(sut.isASAPDeliverySelected)
        XCTAssertFalse(sut.isFutureDeliverySelected)
    }
    
    func test_givenInit_whenIsASAPDeliveryTapped_thenIsASAPDeliverySelectedIsTrue() {
        let sut = makeSUT()
        
        sut.isASAPDeliveryTapped()
        
        XCTAssertTrue(sut.isASAPDeliverySelected)
    }
    
    func test_givenInit_whenIsFutureDeliveryTapped_thenIsFutureDeliverySelectedIsTrue() {
        let sut = makeSUT()
        
        sut.isFutureDeliveryTapped()
        
        XCTAssertTrue(sut.isFutureDeliverySelected)
    }
    
    func test_givenInit_whenSelectedDaySlotAndSelectedTimeSlotIsPopulated_thenIsDataSelectedIsTrue() {
        let sut = makeSUT()
        
        sut.selectedDaySlot = 1
        sut.selectedTimeSlot = UUID()
        
        XCTAssertTrue(sut.isDateSelected)
    }

    func makeSUT() -> DeliverySlotSelectionViewModel {
        let sut = DeliverySlotSelectionViewModel()
        
        trackForMemoryLeaks(sut)
        
        return sut
    }

}
