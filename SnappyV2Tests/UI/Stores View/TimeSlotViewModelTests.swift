//
//  TimeSlotViewModelTests.swift
//  SnappyV2Tests
//
//  Created by Henrik Gustavii on 21/10/2021.
//

import XCTest
@testable import SnappyV2

class TimeSlotViewModelTests: XCTestCase {
    
    func test_init() {
        let date = Date(timeIntervalSince1970: 1632146400) // Monday, 20 September 2021 15:00:00
        let retailStoreDayTimeSlot = RetailStoreSlotDayTimeSlot(slotId: "3", startTime: date, endTime: date.addingTimeInterval(60*30), daytime: "morning", info: .init(status: "", isAsap: false, price: 3.5, fulfilmentIn: ""))
        let sut = makeSUT(timeSlot: retailStoreDayTimeSlot)
        
        XCTAssertEqual(sut.timeSlot, retailStoreDayTimeSlot)
        XCTAssertEqual(sut.startTime, date.hourMinutesString(timeZone: nil))
        XCTAssertEqual(sut.endTime, date.addingTimeInterval(60*30).hourMinutesString(timeZone: nil))
        XCTAssertEqual(sut.cost, "£3.50")
    }
    
    func test_initWithNoCost() {
        let retailStoreDayTimeSlot = RetailStoreSlotDayTimeSlot(slotId: "3", startTime: Date(), endTime: Date(timeIntervalSinceNow: 60*30), daytime: "morning", info: .init(status: "", isAsap: false, price: 0.0, fulfilmentIn: ""))
        let sut = makeSUT(timeSlot: retailStoreDayTimeSlot)
        
        XCTAssertEqual(sut.cost, "Free")
    }

    func makeSUT(timeSlot: RetailStoreSlotDayTimeSlot) -> TimeSlotViewModel {
        let sut = TimeSlotViewModel(container: .preview ,timeSlot: timeSlot)
        
        trackForMemoryLeaks(sut)
        
        return sut
    }

}
