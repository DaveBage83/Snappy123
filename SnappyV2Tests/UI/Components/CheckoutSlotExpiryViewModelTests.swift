//
//  CheckoutSlotExpiryViewModelTests.swift
//  SnappyV2Tests
//
//  Created by David Bage on 12/12/2022.
//

import XCTest
@testable import SnappyV2

class CheckoutSlotExpiryViewModelTests: XCTestCase {
    func test_whenTimeRemainingGreaterThanAppstateLimitThenExpiryStateOK() {
        let slot: BasketSelectedSlot = .mockedTodayData
        let sut = makeSUT(basketSlot: slot)
        
        sut.timeRemaining = 400
        
        XCTAssertEqual(sut.expiryState, .ok)
    }
    
    func test_whenTimeRemainingLessThanAppstateLimit_givenValueGreaterThan0_thenExpiryStateWarning() {
        let slot: BasketSelectedSlot = .mockedTodayData
        let sut = makeSUT(basketSlot: slot)
        
        sut.timeRemaining = 100
        
        XCTAssertEqual(sut.expiryState, .warning)
    }
    
    func test_whenTimeRemainingLessThanAppstateLimit_givenValueNotGreaterThan0_thenExpiryStateEnded() {
        let slot: BasketSelectedSlot = .mockedTodayData
        let sut = makeSUT(basketSlot: slot)
        
        sut.timeRemaining = 0
        
        XCTAssertEqual(sut.expiryState, .ended)
    }
    
    func test_whenTimeRemainingHoursGreaterThan0_thenReturnCorrectString() {
        let slot: BasketSelectedSlot = .mockedTodayData
        let sut = makeSUT(basketSlot: slot)
        
        sut.timeRemaining = 14560
        let hrs = "4"
        let mins = "2"
        
        let expectedString = Strings.CheckoutView.SlotExpiryCustom.expiresInHrsAndMins.localizedFormat(hrs, GeneralStrings.hours.localized, mins)
        
        XCTAssertEqual(sut.timeRemainingString, expectedString)
    }
    
    func test_whenTimeRemainingHoursGreaterThan0ButHrsIsNotGreaterThan1_thenReturnCorrectString() {
        let slot: BasketSelectedSlot = .mockedTodayData
        let sut = makeSUT(basketSlot: slot)
        
        sut.timeRemaining = 3700
        
        let hrs = "1"
        let mins = "1"
        let expectedString = Strings.CheckoutView.SlotExpiryCustom.expiresInHrsAndMins.localizedFormat(hrs, GeneralStrings.hour.localized, mins)
        
        XCTAssertEqual(sut.timeRemainingString, expectedString)
    }
    
    func test_whenTimeRemainingHoursNotGreaterThan0_givenMinsGreaterThan0_thenReturnCorrectString() {
        let slot: BasketSelectedSlot = .mockedTodayData
        let sut = makeSUT(basketSlot: slot)
        
        sut.timeRemaining = 120
        let mins = "2"
        
        let expectedString = Strings.CheckoutView.SlotExpiryCustom.expiresInMins.localizedFormat(mins)
        
        XCTAssertEqual(sut.timeRemainingString, expectedString)
    }

    func test_whenTimeRemainingHoursNotGreaterThan0_givenMinsNotGreaterThan0ButTimeRemainingGreaterThan0_thenReturnCorrectString() {
        let slot: BasketSelectedSlot = .mockedTodayData
        let sut = makeSUT(basketSlot: slot)
        
        sut.timeRemaining = 45
        
        let secs = "45"
        let expectedString = Strings.CheckoutView.SlotExpiryCustom.expiresInSecs.localizedFormat(secs)
        
        XCTAssertEqual(sut.timeRemainingString, expectedString)
    }
    
    func test_whenTimeRemainingIs0_thenReturnCorrectString() {
        let slot: BasketSelectedSlot = .mockedTodayData
        let sut = makeSUT(basketSlot: slot)
        
        sut.timeRemaining = 0
        
        XCTAssertEqual(sut.timeRemainingString, Strings.CheckoutView.SlotExpiry.tapForNewSlot.localized)
    }
    
    func makeSUT(container: DIContainer = DIContainer(appState: AppState(), eventLogger: MockedEventLogger(), services: .mocked()), basketSlot: BasketSelectedSlot) -> CheckoutSlotExpiryViewModel {
        let sut = CheckoutSlotExpiryViewModel(container: container, basketSlot: basketSlot)
        
        trackForMemoryLeaks(sut)
        
        return sut
    }
}
