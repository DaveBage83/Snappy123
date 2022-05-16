//
//  DaySelectionViewModelTests.swift
//  SnappyV2Tests
//
//  Created by Henrik Gustavii on 21/10/2021.
//

import XCTest
@testable import SnappyV2

class DaySelectionViewModelTests: XCTestCase {
    
    func test_initToday() {
        let date = Date().startOfDay
        let sut = makeSUT(date: date, stringDate: "")
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd"
        let dayOfMonth = dateFormatter.string(from: date)
        dateFormatter.dateFormat = "MMMM"
        let month = dateFormatter.string(from: date)
        dateFormatter.dateFormat = "EEEE"
        let weekday = dateFormatter.string(from: date)
        
        XCTAssertTrue(sut.stringDate.isEmpty)
        XCTAssertEqual(sut.weekday, weekday)
        XCTAssertEqual(sut.dayOfMonth, dayOfMonth)
        XCTAssertEqual(sut.month, month)
        XCTAssertTrue(sut.isToday)
        XCTAssertNil(sut.disabledReason)
        XCTAssertFalse(sut.disabled)
    }
    
    func test_initSetDate() {
        let date = Date(timeIntervalSince1970: 1632146400) // Monday, 20 September 2021 15:00:00
        let sut = makeSUT(date: date, stringDate: "")
        
        // Use Calendar symbols so that it works for all
        // test device localisation settings
        let calendar = Calendar.current
        
        XCTAssertTrue(sut.stringDate.isEmpty)
        XCTAssertEqual(sut.weekday, calendar.weekdaySymbols[1])
        XCTAssertEqual(sut.dayOfMonth, "20")
        XCTAssertEqual(sut.month, calendar.monthSymbols[8])
        XCTAssertFalse(sut.isToday)
    }
    
    func test_whenDisabledReasonIsNotNil_thenDisabledIsTrue() {
        let date = Date().startOfDay
        let sut = makeSUT(date: date, stringDate: "", disableReason: "Closed")
        
        XCTAssertTrue(sut.disabled)
    }

    func makeSUT(date: Date, stringDate: String, disableReason: String? = nil) -> DaySelectionViewModel {
        let sut = DaySelectionViewModel(container: .preview, date: date, stringDate: stringDate, disabledReason: disableReason)
        
        trackForMemoryLeaks(sut)
        
        return sut
    }
}
