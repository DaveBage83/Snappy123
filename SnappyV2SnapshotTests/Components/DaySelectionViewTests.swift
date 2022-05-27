//
//  DaySelectionViewTests.swift
//  SnappyV2SnapshotTests
//
//  Created by David Bage on 13/05/2022.
//

import XCTest
import SwiftUI
@testable import SnappyV2

class DaySelectionViewTests: XCTestCase {
    func _testinitWhenNotDisabled() {
        let sut = makeSUT()
        let iPhone12Snapshot = sut.snapshot(for: .iPhone12(style: .light))
        let iPad8thGenSnapshot = sut.snapshot(for: .iPad8thGen(style: .light))
        
        assert(snapshot: iPhone12Snapshot, sut: sut)
        assert(snapshot: iPad8thGenSnapshot, sut: sut)
    }
    
    func _testinitWhenDisabled() {
        let sut = makeSUT(disableReason: "Closed")
        let iPhone12Snapshot = sut.snapshot(for: .iPhone12(style: .light))
        let iPad8thGenSnapshot = sut.snapshot(for: .iPad8thGen(style: .light))
        
        assert(snapshot: iPhone12Snapshot, sut: sut)
        assert(snapshot: iPad8thGenSnapshot, sut: sut)
    }

    func makeSUT(disableReason: String? = nil) -> DaySelectionView {
        let dateFormatterUK = DateFormatter()
        dateFormatterUK.dateFormat = "dd-MM-yyyy"

        let stringDate = "16-05-2022"
        let date = dateFormatterUK.date(from: stringDate)!
        
        return DaySelectionView(viewModel: .init(container: .preview, date: date, stringDate: "", disabledReason: disableReason), selectedDayTimeSlot: .constant(RetailStoreSlotDay(status: "", reason: "", slotDate: "", slots: nil)))
    }
}

