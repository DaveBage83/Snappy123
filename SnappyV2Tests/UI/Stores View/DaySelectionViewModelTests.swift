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
        let date = Date()
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
    }
    
    func test_initSetDate() {
        let date = Date(timeIntervalSince1970: 1632146400) // Monday, 20 September 2021 15:00:00
        let sut = makeSUT(date: date, stringDate: "")
        
        XCTAssertTrue(sut.stringDate.isEmpty)
        XCTAssertEqual(sut.weekday, "Monday")
        XCTAssertEqual(sut.dayOfMonth, "20")
        XCTAssertEqual(sut.month, "September")
        XCTAssertFalse(sut.isToday)
    }

    func makeSUT(date: Date, stringDate: String) -> DaySelectionViewModel {
        let sut = DaySelectionViewModel(date: date, stringDate: stringDate)
        
        trackForMemoryLeaks(sut)
        
        return sut
    }
}
