//
//  Date+ExtensionsTests.swift
//  SnappyV2Tests
//
//  Created by David Bage on 02/03/2022.
//

import XCTest
@testable import SnappyV2

class Date_ExtensionsTests: XCTestCase {
    func test_whenDateIsToday_thenIsTodayIsTrue() {
        XCTAssertTrue(Date().isToday)
    }
    
    func test_whenDateIsNotToday_thenIsTodayIsFalse() {
        XCTAssertFalse(Calendar.current.date(byAdding: DateComponents(day: +1), to: Date())!.isToday)
    }
    
    func test_whenDateShortStringExtensionCalled_thenCorrectStringIsReturned() {
        let date = createDate()
        XCTAssertEqual(date.dateShortString(storeTimeZone: nil), "01-Jan")
    }
    
    func test_whenTimeStringExtensionCalled_thenCorrectStringIsReturned() {
        let date = createDate()
        XCTAssertEqual(date.timeString(storeTimeZone: nil), "11:05 am")
    }
    
    func createDate() -> Date {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm"
        let dateString = "2022-01-01T11:05"
        return formatter.date(from: dateString)!
    }
}
