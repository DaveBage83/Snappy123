//
//  MemberDashboardOptionButtonTests.swift
//  SnappyV2SnapshotTests
//
//  Created by David Bage on 15/05/2022.
//

import XCTest
import SwiftUI
@testable import SnappyV2

@MainActor
class MemberDashboardOptionButtonTests: XCTestCase {
    func _testinitWhenIsActive() {
        let sut = makeSUT(isActive: true)
        let iPhone12Snapshot = sut.snapshot(for: .iPhone12(style: .light))
        let iPad8thGenSnapshot = sut.snapshot(for: .iPad8thGen(style: .light))
        
        assert(snapshot: iPhone12Snapshot, sut: sut)
        assert(snapshot: iPad8thGenSnapshot, sut: sut)
    }
    
    func _testinitWhenNotActive() {
        let sut = makeSUT(isActive: false)
        let iPhone12Snapshot = sut.snapshot(for: .iPhone12(style: .light))
        let iPad8thGenSnapshot = sut.snapshot(for: .iPad8thGen(style: .light))
        
        assert(snapshot: iPhone12Snapshot, sut: sut)
        assert(snapshot: iPad8thGenSnapshot, sut: sut)
    }
    
    @MainActor func makeSUT(isActive: Bool) -> MemberDashboardOptionsButton {
        MemberDashboardOptionsButton(viewModel: .init(container: .preview), option: .myDetails)
    }
}
