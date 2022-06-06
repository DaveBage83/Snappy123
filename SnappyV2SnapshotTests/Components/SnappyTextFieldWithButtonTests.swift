//
//  SnappyTextFieldWithButtonTests.swift
//  SnappyV2SnapshotTests
//
//  Created by David Bage on 06/06/2022.
//

import XCTest
import SwiftUI
@testable import SnappyV2

#warning("Tests currently disabled - will enable all snapshot tests once designs are stable")

class SnappyTextFieldWithButtonTests: XCTestCase {
    func _testinit_noErrorNotLoading() {
        let sut = makeSUT(hasError: false, isLoading: false)
        let iPhone12Snapshot = sut.snapshot(for: .iPhone12(style: .light))
        let iPad8thGenSnapshot = sut.snapshot(for: .iPad8thGen(style: .light))
        
        assert(snapshot: iPhone12Snapshot, sut: sut)
        assert(snapshot: iPad8thGenSnapshot, sut: sut)
    }
    
    func _testinit_errorNotLoading() {
        let sut = makeSUT(hasError: true, isLoading: false)
        let iPhone12Snapshot = sut.snapshot(for: .iPhone12(style: .light))
        let iPad8thGenSnapshot = sut.snapshot(for: .iPad8thGen(style: .light))
        
        assert(snapshot: iPhone12Snapshot, sut: sut)
        assert(snapshot: iPad8thGenSnapshot, sut: sut)
    }
    
    func _testinit_noErrorIsLoading() {
        let sut = makeSUT(hasError: false, isLoading: true)
        let iPhone12Snapshot = sut.snapshot(for: .iPhone12(style: .light))
        let iPad8thGenSnapshot = sut.snapshot(for: .iPad8thGen(style: .light))
        
        assert(snapshot: iPhone12Snapshot, sut: sut)
        assert(snapshot: iPad8thGenSnapshot, sut: sut)
    }
    
    func makeSUT(hasError: Bool, isLoading: Bool) -> SnappyTextFieldWithButton {
        SnappyTextFieldWithButton(
            container: .preview,
            text: .constant("Test button"),
            hasError: .constant(hasError),
            isLoading: .constant(isLoading),
            labelText: "Test normal label",
            largeLabelText: "Test large label",
            mainButton: ("Button title", {}))
    }
}
