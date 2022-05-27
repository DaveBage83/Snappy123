//
//  TimeSlotSelectionViewTests.swift
//  SnappyV2SnapshotTests
//
//  Created by David Bage on 13/05/2022.
//

import XCTest
import SwiftUI
@testable import SnappyV2

class TimeSlotViewTests: XCTestCase {
    func _testinit() {
        let sut = makeSUT()
        let iPhone12Snapshot = sut.snapshot(for: .iPhone12(style: .light))
        let iPad8thGenSnapshot = sut.snapshot(for: .iPad8thGen(style: .light))
        
        assert(snapshot: iPhone12Snapshot, sut: sut)
        assert(snapshot: iPad8thGenSnapshot, sut: sut)
    }

    func makeSUT() -> TimeSlotView {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "US_en")
        formatter.dateFormat = "E, dd MMM yyyy HH:mm:ss Z"
        let fromDate = formatter.date(from: "Fri, 13 May 2022 10:50:00 +0000")
        let toDate = formatter.date(from: "Fri, 13 May 2022 11:00:00 +0000")
        
        return TimeSlotView(viewModel: TimeSlotViewModel(container: .preview ,timeSlot: RetailStoreSlotDayTimeSlot(slotId: "1", startTime: fromDate!, endTime: toDate!, daytime: "morning", info: RetailStoreSlotDayTimeSlotInfo(status: "", isAsap: false, price: 3.5, fulfilmentIn: ""))), selectedTimeSlot: .constant(nil))
    }
}
