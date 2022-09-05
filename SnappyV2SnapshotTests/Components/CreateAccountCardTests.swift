//
//  CreateAccountCardTests.swift
//  SnappyV2SnapshotTests
//
//  Created by David Bage on 15/05/2022.
//

import XCTest
import SwiftUI
@testable import SnappyV2

@MainActor
class CreateAccountCardTests: XCTestCase {
    func _test_init() {
        let sut = makeSUT()
        let iPhone12Snapshot = sut.snapshot(for: .iPhone12(style: .light))
        let iPad8thGenSnapshot = sut.snapshot(for: .iPad8thGen(style: .light))
        
        assert(snapshot: iPhone12Snapshot, sut: sut)
        assert(snapshot: iPad8thGenSnapshot, sut: sut)
    }
    
    func makeSUT() -> CreateAccountCard {
        CreateAccountCard(viewModel: .init(container: .preview))
    }
}

