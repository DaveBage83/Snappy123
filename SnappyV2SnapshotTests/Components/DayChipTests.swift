//
//  DayChipTests.swift
//  SnappyV2SnapshotTests
//
//  Created by David Bage on 16/05/2022.
//

import XCTest
import SwiftUI
@testable import SnappyV2

class DayChipTests: XCTestCase {
    func _testinitWhenTypeIsChipAndSchemeIsPrimaryAndSizeIsLargeAndDisabledIsFalse() {
        let sut = makeSUT(type: .chip, scheme: .primary, size: .large, disabled: false)
        let iPhone12Snapshot = sut.snapshot(for: .iPhone12(style: .light))
        let iPad8thGenSnapshot = sut.snapshot(for: .iPad8thGen(style: .light))
        
        assert(snapshot: iPhone12Snapshot, sut: sut)
        assert(snapshot: iPad8thGenSnapshot, sut: sut)
    }
    
    func _testinitWhenTypeIsChipAndSchemeIsSecondaryAndSizeIsLargeAndDisabledIsFalse() {
        let sut = makeSUT(type: .chip, scheme: .secondary, size: .large, disabled: false)
        let iPhone12Snapshot = sut.snapshot(for: .iPhone12(style: .light))
        let iPad8thGenSnapshot = sut.snapshot(for: .iPad8thGen(style: .light))
        
        assert(snapshot: iPhone12Snapshot, sut: sut)
        assert(snapshot: iPad8thGenSnapshot, sut: sut)
    }
    
    func _testinitWhenTypeIsChipAndSchemeIsPrimaryAndSizeIsSmallAndDisabledIsFalse() {
        let sut = makeSUT(type: .chip, scheme: .primary, size: .small, disabled: false)
        let iPhone12Snapshot = sut.snapshot(for: .iPhone12(style: .light))
        let iPad8thGenSnapshot = sut.snapshot(for: .iPad8thGen(style: .light))
        
        assert(snapshot: iPhone12Snapshot, sut: sut)
        assert(snapshot: iPad8thGenSnapshot, sut: sut)
    }
    
    func _testinitWhenTypeIsChipAndSchemeIsPrimaryAndSizeIsLargeAndDisabledIsTrue() {
        let sut = makeSUT(type: .chip, scheme: .primary, size: .small, disabled: false)
        let iPhone12Snapshot = sut.snapshot(for: .iPhone12(style: .light))
        let iPad8thGenSnapshot = sut.snapshot(for: .iPad8thGen(style: .light))
        
        assert(snapshot: iPhone12Snapshot, sut: sut)
        assert(snapshot: iPad8thGenSnapshot, sut: sut)
    }
    
    func _testinitWhenTypeIsTextAndSchemeIsPrimaryAndSizeIsLargeAndDisabledIsFalse() {
        let sut = makeSUT(type: .text, scheme: .primary, size: .large, disabled: false)
        let iPhone12Snapshot = sut.snapshot(for: .iPhone12(style: .light))
        let iPad8thGenSnapshot = sut.snapshot(for: .iPad8thGen(style: .light))
        
        assert(snapshot: iPhone12Snapshot, sut: sut)
        assert(snapshot: iPad8thGenSnapshot, sut: sut)
    }
    
    func _testinitWhenTypeIsTextAndSchemeIsSecondaryAndSizeIsLargeAndDisabledIsFalse() {
        let sut = makeSUT(type: .text, scheme: .secondary, size: .large, disabled: false)
        let iPhone12Snapshot = sut.snapshot(for: .iPhone12(style: .light))
        let iPad8thGenSnapshot = sut.snapshot(for: .iPad8thGen(style: .light))
        
        assert(snapshot: iPhone12Snapshot, sut: sut)
        assert(snapshot: iPad8thGenSnapshot, sut: sut)
    }
    
    func _testinitWhenTypeIsTextAndSchemeIsPrimaryAndSizeIsSmallAndDisabledIsFalse() {
        let sut = makeSUT(type: .text, scheme: .primary, size: .small, disabled: false)
        let iPhone12Snapshot = sut.snapshot(for: .iPhone12(style: .light))
        let iPad8thGenSnapshot = sut.snapshot(for: .iPad8thGen(style: .light))
        
        assert(snapshot: iPhone12Snapshot, sut: sut)
        assert(snapshot: iPad8thGenSnapshot, sut: sut)
    }
    
    func _testinitWhenTypeIsTextAndSchemeIsPrimaryAndSizeIsLargeAndDisabledIsTrue() {
        let sut = makeSUT(type: .text, scheme: .primary, size: .small, disabled: false)
        let iPhone12Snapshot = sut.snapshot(for: .iPhone12(style: .light))
        let iPad8thGenSnapshot = sut.snapshot(for: .iPad8thGen(style: .light))
        
        assert(snapshot: iPhone12Snapshot, sut: sut)
        assert(snapshot: iPad8thGenSnapshot, sut: sut)
    }

    func makeSUT(type: DayChip.ChipType, scheme: DayChip.ChipScheme, size: DayChip.Size, disabled: Bool) -> DayChip {
        DayChip(container: .preview, title: "Test chip", type: type, scheme: scheme, size: size, disabled: disabled)
    }
}

