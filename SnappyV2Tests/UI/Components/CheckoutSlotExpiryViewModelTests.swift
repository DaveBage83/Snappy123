//
//  CheckoutSlotExpiryViewModelTests.swift
//  SnappyV2Tests
//
//  Created by David Bage on 12/12/2022.
//

import XCTest
@testable import SnappyV2
import SwiftUI
import Combine

class CheckoutSlotExpiryViewModelTests: XCTestCase {
    @Environment(\.colorScheme) var colorScheme
    
    private var colorPalette: ColorPalette {
        .init(container: .preview, colorScheme: colorScheme)
    }
    
    func test_whenTimeRemainingGreaterThanAppstateLimitThenExpiryStateOK() {
        let sut = makeSUT()
        
        sut.timeRemaining = 400
        
        XCTAssertEqual(sut.expiryState, .ok)
    }
    
    func test_whenTimeRemainingLessThanAppstateLimit_givenValueGreaterThan0_thenExpiryStateWarning() {
        let sut = makeSUT()
        
        sut.timeRemaining = 100
        
        XCTAssertEqual(sut.expiryState, .warning)
    }
    
    func test_whenTimeRemainingLessThanAppstateLimit_givenValueNotGreaterThan0_thenExpiryStateEnded() {
        let sut = makeSUT()
        
        sut.timeRemaining = 0
        
        XCTAssertEqual(sut.expiryState, .ended)
    }
    
    func test_whenTimeRemainingHoursGreaterThan0_thenReturnCorrectString() {
        let sut = makeSUT()
        
        sut.timeRemaining = 14560
        let hrs = "4"
        let mins = "2"
        
        let expectedString = Strings.CheckoutView.SlotExpiryCustom.expiresInHrsAndMins.localizedFormat(hrs, GeneralStrings.hours.localized, mins)
        
        XCTAssertEqual(sut.timeRemainingString, expectedString)
    }
    
    func test_whenTimeRemainingHoursGreaterThan0ButHrsIsNotGreaterThan1_thenReturnCorrectString() {
        let sut = makeSUT()
        
        sut.timeRemaining = 3700
        
        let hrs = "1"
        let mins = "1"
        let expectedString = Strings.CheckoutView.SlotExpiryCustom.expiresInHrsAndMins.localizedFormat(hrs, GeneralStrings.hour.localized, mins)
        
        XCTAssertEqual(sut.timeRemainingString, expectedString)
    }
    
    func test_whenTimeRemainingHoursNotGreaterThan0_givenMinsGreaterThan0_thenReturnCorrectString() {
        let sut = makeSUT()
        
        sut.timeRemaining = 120
        let mins = "2"
        
        let expectedString = Strings.CheckoutView.SlotExpiryCustom.expiresInMins.localizedFormat(mins)
        
        XCTAssertEqual(sut.timeRemainingString, expectedString)
    }

    func test_whenTimeRemainingHoursNotGreaterThan0_givenMinsNotGreaterThan0ButTimeRemainingGreaterThan0_thenReturnCorrectString() {
        let sut = makeSUT()
        
        sut.timeRemaining = 45
        
        let secs = "45"
        let expectedString = Strings.CheckoutView.SlotExpiryCustom.expiresInSecs.localizedFormat(secs)
        
        XCTAssertEqual(sut.timeRemainingString, expectedString)
    }
    
    func test_whenTimeRemainingIs0_thenReturnCorrectString() {
        let sut = makeSUT()
        
        sut.timeRemaining = 0
        
        XCTAssertEqual(sut.timeRemainingString, Strings.CheckoutView.SlotExpiry.tapForNewSlot.localized)
    }
    
    func test_whenConfirgureTimeRemainingFired_givenTimeRemainingGreaterThan1_thenSlotExpiredInAppStateIsFalseAndTimeRemainingReducedBy1() {
        let sut = makeSUT()
        sut.container.appState.value.userData.slotExpired = true
        
        sut.timeRemaining = 10
        sut.configureTimeRemaining()
        
        XCTAssertEqual(sut.timeRemaining, 9)
        
        if let slotExpired = sut.container.appState.value.userData.slotExpired {
            XCTAssertFalse(slotExpired)
        } else {
            XCTFail("Slot expired should not be nil")
        }
    }
    
    func test_whenConfirgureTimeRemainingFired_givenTimeRemainingLessThan1_thenSlotExpiredInAppStateIsTrueAndTimeRemainingUnchangedAndErrorSetInAppState() {
        let sut = makeSUT()
        sut.container.appState.value.userData.slotExpired = false
        
        sut.timeRemaining = 0.2
        sut.configureTimeRemaining()
        
        XCTAssertEqual(sut.timeRemaining, 0.2)
        
        if let slotExpired = sut.container.appState.value.userData.slotExpired {
            XCTAssertTrue(slotExpired)
        } else {
            XCTFail("Slot expired should not be nil")
        }
        
        XCTAssertEqual(sut.container.appState.value.latestError?.localizedDescription, SlotExpiryError.slotExpired.localizedDescription)
    }
    
    func test_whenExpiryStateIsOK_thenColorAndEditIconColorAndTextColorAndPillOpacitySet() {
        let sut = makeSUT()
        sut.timeRemaining = 950
        
        XCTAssertEqual(sut.expiryState.pillOpacity, .ten)
        XCTAssertEqual(sut.expiryState.textColor(colorPalette: colorPalette), colorPalette.alertSuccess)
        XCTAssertEqual(sut.expiryState.editIconColor(colorPalette: colorPalette), colorPalette.primaryBlue)
        XCTAssertEqual(sut.expiryState.color(colorPalette: colorPalette), colorPalette.alertSuccess)
    }
    
    func test_whenExpiryStateIsWarning_thenColorAndEditIconColorAndTextColorAndPillOpacitySet() {
        let sut = makeSUT()
        sut.timeRemaining = 20
        
        XCTAssertEqual(sut.expiryState.pillOpacity, .ten)
        XCTAssertEqual(sut.expiryState.textColor(colorPalette: colorPalette), colorPalette.alertWarning)
        XCTAssertEqual(sut.expiryState.editIconColor(colorPalette: colorPalette), colorPalette.primaryBlue)
        XCTAssertEqual(sut.expiryState.color(colorPalette: colorPalette), colorPalette.alertWarning)
    }
    
    func test_whenExpiryStateIsEnded_thenColorAndEditIconColorAndTextColorAndPillOpacitySet() {
        let sut = makeSUT()
        sut.timeRemaining = 0
        
        XCTAssertEqual(sut.expiryState.pillOpacity, .full)
        XCTAssertEqual(sut.expiryState.textColor(colorPalette: colorPalette), .white)
        XCTAssertEqual(sut.expiryState.editIconColor(colorPalette: colorPalette), .white)
        XCTAssertEqual(sut.expiryState.color(colorPalette: colorPalette), colorPalette.alertWarning)
    }
    
    func test_whenTodaySlotExpirySetInAppState_thenTimeRemainingPopulated() {
        var cancellables = Set<AnyCancellable>()
        let timeTraveler = TimeTraveler()

        let dateNow = Date().startOfDay.addingTimeInterval(60*60*13) // 13:00
        timeTraveler.date = dateNow
        
        let todaySlotExpiry = timeTraveler.date.addingTimeInterval(60).timeIntervalSince1970

        let sut = makeSUT(dateGenerator: timeTraveler.generateDate)

        sut.container.appState.value.userData.todaySlotExpiry = todaySlotExpiry
        
        let expectation = expectation(description: "setTimeRemaining")
        
        sut.$timeRemaining
            .first()
            .receive(on: RunLoop.main)
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 2)
        
        XCTAssertEqual(sut.timeRemaining, 60)
    }
    
    func test_whenBasketSlotExpirySetInAppState_thenTimeRemainingPopulated() {
        var cancellables = Set<AnyCancellable>()
        let timeTraveler = TimeTraveler()

        let dateNow = Date().startOfDay.addingTimeInterval(60*60*13) // 13:00

        timeTraveler.date = dateNow
        
        let sut = makeSUT(dateGenerator: timeTraveler.generateDate)

        sut.container.appState.value.userData.basket = .mockedDataWithExpiry
        
        let expectation = expectation(description: "setTimeRemaining")
        
        sut.$timeRemaining
            .first()
            .receive(on: RunLoop.main)
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 2)
        
        XCTAssertEqual(sut.timeRemaining, 7200)
        XCTAssertNotNil(sut.timer.upstream.connect())
    }
    
    func test_whenBasketSlotExpirySetInAppState_givenTimeRemainingIs0_thenTimeRemaining0() {
        var cancellables = Set<AnyCancellable>()
        let timeTraveler = TimeTraveler()

        let dateNow = Date().startOfDay.addingTimeInterval(60*60*13) // 13:00

        timeTraveler.date = dateNow
        
        let sut = makeSUT(dateGenerator: timeTraveler.generateDate)

        sut.container.appState.value.userData.basket = .mockedDataWithFixedExpiry(expiry: dateNow)
        
        let expectation = expectation(description: "setTimeRemaining")
        
        sut.$timeRemaining
            .first()
            .receive(on: RunLoop.main)
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 2)
        
        XCTAssertEqual(sut.timeRemaining, 0)
    }
    
    func makeSUT(container: DIContainer = DIContainer(appState: AppState(), eventLogger: MockedEventLogger(), services: .mocked()), dateGenerator: @escaping () -> Date = Date.init) -> CheckoutSlotExpiryViewModel {
        let sut = CheckoutSlotExpiryViewModel(container: container, dateGenerator: dateGenerator)
        
        trackForMemoryLeaks(sut)
        
        return sut
    }
}
