//
//  SnappyButtonTests.swift
//  SnappyV2SnapshotTests
//
//  Created by David Bage on 09/05/2022.
//

import XCTest
import SwiftUI
@testable import SnappyV2

class SnappyButtonTests: XCTestCase {
    func _testinit_givenSnappyButtonTypeIsPrimaryAndButtonSizeIsLarge() {
        let sut = makeSUT(type: .primary, size: .large)
        let iPhone12Snapshot = sut.snapshot(for: .iPhone12(style: .light))
        let iPad8thGenSnapshot = sut.snapshot(for: .iPad8thGen(style: .light))
        
        assert(snapshot: iPhone12Snapshot, sut: sut)
        assert(snapshot: iPad8thGenSnapshot, sut: sut)
    }
    
    func _testinit_givenSnappyButtonTypeIsPrimaryAndButtonSizeIsMedium() {
        let sut = makeSUT(type: .primary, size: .medium)
        let iPhone12Snapshot = sut.snapshot(for: .iPhone12(style: .light))
        let iPad8thGenSnapshot = sut.snapshot(for: .iPad8thGen(style: .light))
        
        assert(snapshot: iPhone12Snapshot, sut: sut)
        assert(snapshot: iPad8thGenSnapshot, sut: sut)
    }
    
    func _testinit_givenSnappyButtonTypeIsPrimaryAndButtonSizeIsSmall() {
        let sut = makeSUT(type: .primary, size: .medium)
        let iPhone12Snapshot = sut.snapshot(for: .iPhone12(style: .light))
        let iPad8thGenSnapshot = sut.snapshot(for: .iPad8thGen(style: .light))
        
        assert(snapshot: iPhone12Snapshot, sut: sut)
        assert(snapshot: iPad8thGenSnapshot, sut: sut)
    }
    
    func _testinit_givenSnappyButtonTypeIsSecondaryAndButtonSizeIsLarge() {
        let sut = makeSUT(type: .secondary, size: .large)
        let iPhone12Snapshot = sut.snapshot(for: .iPhone12(style: .light))
        let iPad8thGenSnapshot = sut.snapshot(for: .iPad8thGen(style: .light))
        
        assert(snapshot: iPhone12Snapshot, sut: sut)
        assert(snapshot: iPad8thGenSnapshot, sut: sut)
    }
    
    func _testinit_givenSnappyButtonTypeIsSecondaryAndButtonSizeIsMedium() {
        let sut = makeSUT(type: .secondary, size: .medium)
        let iPhone12Snapshot = sut.snapshot(for: .iPhone12(style: .light))
        let iPad8thGenSnapshot = sut.snapshot(for: .iPad8thGen(style: .light))
        
        assert(snapshot: iPhone12Snapshot, sut: sut)
        assert(snapshot: iPad8thGenSnapshot, sut: sut)
    }
    
    func _testinit_givenSnappyButtonTypeIsSecondaryAndButtonSizeIsSmall() {
        let sut = makeSUT(type: .secondary, size: .small)
        let iPhone12Snapshot = sut.snapshot(for: .iPhone12(style: .light))
        let iPad8thGenSnapshot = sut.snapshot(for: .iPad8thGen(style: .light))
        
        assert(snapshot: iPhone12Snapshot, sut: sut)
        assert(snapshot: iPad8thGenSnapshot, sut: sut)
    }
    
    func _testinit_givenSnappyButtonTypeIsOutlineAndButtonSizeIsLarge() {
        let sut = makeSUT(type: .outline, size: .large)
        let iPhone12Snapshot = sut.snapshot(for: .iPhone12(style: .light))
        let iPad8thGenSnapshot = sut.snapshot(for: .iPad8thGen(style: .light))
        
        assert(snapshot: iPhone12Snapshot, sut: sut)
        assert(snapshot: iPad8thGenSnapshot, sut: sut)
    }
    
    func _testinit_givenSnappyButtonTypeIsOutlineAndButtonSizeIsMedium() {
        let sut = makeSUT(type: .outline, size: .medium)
        let iPhone12Snapshot = sut.snapshot(for: .iPhone12(style: .light))
        let iPad8thGenSnapshot = sut.snapshot(for: .iPad8thGen(style: .light))
        
        assert(snapshot: iPhone12Snapshot, sut: sut)
        assert(snapshot: iPad8thGenSnapshot, sut: sut)
    }
    
    func _testinit_givenSnappyButtonTypeIsOutlineAndButtonSizeIsSmall() {
        let sut = makeSUT(type: .outline, size: .small)
        let iPhone12Snapshot = sut.snapshot(for: .iPhone12(style: .light))
        let iPad8thGenSnapshot = sut.snapshot(for: .iPad8thGen(style: .light))
        
        assert(snapshot: iPhone12Snapshot, sut: sut)
        assert(snapshot: iPad8thGenSnapshot, sut: sut)
    }
    
    func _testinit_givenSnappyButtonTypeIsSuccessAndButtonSizeIsLarge() {
        let sut = makeSUT(type: .success, size: .large)
        let iPhone12Snapshot = sut.snapshot(for: .iPhone12(style: .light))
        let iPad8thGenSnapshot = sut.snapshot(for: .iPad8thGen(style: .light))
        
        assert(snapshot: iPhone12Snapshot, sut: sut)
        assert(snapshot: iPad8thGenSnapshot, sut: sut)
    }
    
    func _testinit_givenSnappyButtonTypeIsSuccessAndButtonSizeIsMedium() {
        let sut = makeSUT(type: .success, size: .medium)
        let iPhone12Snapshot = sut.snapshot(for: .iPhone12(style: .light))
        let iPad8thGenSnapshot = sut.snapshot(for: .iPad8thGen(style: .light))
        
        assert(snapshot: iPhone12Snapshot, sut: sut)
        assert(snapshot: iPad8thGenSnapshot, sut: sut)
    }
    
    func _testinit_givenSnappyButtonTypeIsSuccessAndButtonSizeIsSmall() {
        let sut = makeSUT(type: .success, size: .small)
        let iPhone12Snapshot = sut.snapshot(for: .iPhone12(style: .light))
        let iPad8thGenSnapshot = sut.snapshot(for: .iPad8thGen(style: .light))
        
        assert(snapshot: iPhone12Snapshot, sut: sut)
        assert(snapshot: iPad8thGenSnapshot, sut: sut)
    }
    
    func _testinit_givenSnappyButtonTypeIsTextAndButtonSizeIsLarge() {
        let sut = makeSUT(type: .text, size: .large)
        let iPhone12Snapshot = sut.snapshot(for: .iPhone12(style: .light))
        let iPad8thGenSnapshot = sut.snapshot(for: .iPad8thGen(style: .light))
        
        assert(snapshot: iPhone12Snapshot, sut: sut)
        assert(snapshot: iPad8thGenSnapshot, sut: sut)
    }
    
    func _testinit_givenSnappyButtonTypeIsTextAndButtonSizeIsMedium() {
        let sut = makeSUT(type: .text, size: .medium)
        let iPhone12Snapshot = sut.snapshot(for: .iPhone12(style: .light))
        let iPad8thGenSnapshot = sut.snapshot(for: .iPad8thGen(style: .light))
        
        assert(snapshot: iPhone12Snapshot, sut: sut)
        assert(snapshot: iPad8thGenSnapshot, sut: sut)
    }
    
    func _testinit_givenSnappyButtonTypeIsTextAndButtonSizeIsSmall() {
        let sut = makeSUT(type: .text, size: .small)
        let iPhone12Snapshot = sut.snapshot(for: .iPhone12(style: .light))
        let iPad8thGenSnapshot = sut.snapshot(for: .iPad8thGen(style: .light))
        
        assert(snapshot: iPhone12Snapshot, sut: sut)
        assert(snapshot: iPad8thGenSnapshot, sut: sut)
    }
    
    func makeSUT(type: SnappyButton.SnappyButtonType, size: SnappyButton.SnappyButtonSize) -> SnappyButton {
        SnappyButton(container: .preview, type: .primary, size: .large, title: "Test Button", largeTextTitle: nil, icon: Image.Icons.Chevrons.Right.light, action: {})
    }
}
