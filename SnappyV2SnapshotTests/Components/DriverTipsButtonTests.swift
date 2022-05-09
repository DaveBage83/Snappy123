//
//  DriverTipsButtonTests.swift
//  SnappyV2SnapshotTests
//
//  Created by David Bage on 09/05/2022.
//

import XCTest
import SwiftUI
@testable import SnappyV2

@MainActor
class DriverTipsButtonTests: XCTestCase {
    func test_init_givenSizeIsLarge() {
        let sut = makeSUT(size: .large)
        let iPhone12Snapshot = sut.snapshot(for: .iPhone12(style: .light))
        let iPad8thGenSnapshot = sut.snapshot(for: .iPad8thGen(style: .light))
        
        assert(snapshot: iPhone12Snapshot, sut: sut)
        assert(snapshot: iPad8thGenSnapshot, sut: sut)
    }
    
    func test_init_givenSizeIsStandard() {
        let sut = makeSUT(size: .standard)
        let iPhone12Snapshot = sut.snapshot(for: .iPhone12(style: .light))
        let iPad8thGenSnapshot = sut.snapshot(for: .iPad8thGen(style: .light))
        
        assert(snapshot: iPhone12Snapshot, sut: sut)
        assert(snapshot: iPad8thGenSnapshot, sut: sut)
    }

    func makeSUT(size: DriverTipsButton.Size) -> DriverTipsButton {
        DriverTipsButton(viewModel: .init(container: .preview), size: size)
    }
}
