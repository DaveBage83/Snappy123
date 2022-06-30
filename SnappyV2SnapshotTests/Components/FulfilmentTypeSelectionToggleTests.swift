//
//  FulfilmentTypeSelectionToggleTests.swift
//  SnappyV2SnapshotTests
//
//  Created by David Bage on 06/06/2022.
//

import XCTest
import SwiftUI
@testable import SnappyV2

#warning("Tests currently disabled - will enable all snapshot tests once designs are stable")
@MainActor
class FulfilmentTypeSelectionToggleTests: XCTestCase {
    func _testinit_whenCollectionTapped() {
        let viewModel = StoresViewModel(container: .preview)
        viewModel.fulfilmentMethodButtonTapped(.collection)
        let sut = makeSUT(viewModel: viewModel)
        let iPhone12Snapshot = sut.snapshot(for: .iPhone12(style: .light))
        let iPad8thGenSnapshot = sut.snapshot(for: .iPad8thGen(style: .light))
        
        assert(snapshot: iPhone12Snapshot, sut: sut)
        assert(snapshot: iPad8thGenSnapshot, sut: sut)
    }
    
    func _testinitWhenDeliveryTapped() {
        let viewModel = StoresViewModel(container: .preview)
        viewModel.fulfilmentMethodButtonTapped(.delivery)
        let sut = makeSUT(viewModel: viewModel)
        let iPhone12Snapshot = sut.snapshot(for: .iPhone12(style: .light))
        let iPad8thGenSnapshot = sut.snapshot(for: .iPad8thGen(style: .light))
        
        assert(snapshot: iPhone12Snapshot, sut: sut)
        assert(snapshot: iPad8thGenSnapshot, sut: sut)
    }
    
    func makeSUT(viewModel: StoresViewModel) -> FulfilmentTypeSelectionToggle {
        FulfilmentTypeSelectionToggle(viewModel: .init(container: .preview))
    }
}
