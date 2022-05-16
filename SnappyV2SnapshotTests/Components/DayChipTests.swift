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
    func test_initWhenTypeIsChipAndSchemeIsPrimaryAndSizeIsLargeAndDisabledIsFalse() {
        let sut = makeSUT(type: .chip, scheme: .primary, size: .large, disabled: false)
        let iPhone12Snapshot = sut.snapshot(for: .iPhone12(style: .light))
        let iPad8thGenSnapshot = sut.snapshot(for: .iPad8thGen(style: .light))
        
        assert(snapshot: iPhone12Snapshot, sut: sut)
        assert(snapshot: iPad8thGenSnapshot, sut: sut)
    }
    
    func test_initWhenTypeIsChipAndSchemeIsSecondaryAndSizeIsLargeAndDisabledIsFalse() {
        let sut = makeSUT(type: .chip, scheme: .secondary, size: .large, disabled: false)
        let iPhone12Snapshot = sut.snapshot(for: .iPhone12(style: .light))
        let iPad8thGenSnapshot = sut.snapshot(for: .iPad8thGen(style: .light))
        
        assert(snapshot: iPhone12Snapshot, sut: sut)
        assert(snapshot: iPad8thGenSnapshot, sut: sut)
    }
    
    func test_initWhenTypeIsChipAndSchemeIsPrimaryAndSizeIsSmallAndDisabledIsFalse() {
        let sut = makeSUT(type: .chip, scheme: .primary, size: .small, disabled: false)
        let iPhone12Snapshot = sut.snapshot(for: .iPhone12(style: .light))
        let iPad8thGenSnapshot = sut.snapshot(for: .iPad8thGen(style: .light))
        
        assert(snapshot: iPhone12Snapshot, sut: sut)
        assert(snapshot: iPad8thGenSnapshot, sut: sut)
    }
    
    func test_initWhenTypeIsChipAndSchemeIsPrimaryAndSizeIsLargeAndDisabledIsTrue() {
        let sut = makeSUT(type: .chip, scheme: .primary, size: .small, disabled: false)
        let iPhone12Snapshot = sut.snapshot(for: .iPhone12(style: .light))
        let iPad8thGenSnapshot = sut.snapshot(for: .iPad8thGen(style: .light))
        
        assert(snapshot: iPhone12Snapshot, sut: sut)
        assert(snapshot: iPad8thGenSnapshot, sut: sut)
    }
    
    func test_initWhenTypeIsTextAndSchemeIsPrimaryAndSizeIsLargeAndDisabledIsFalse() {
        let sut = makeSUT(type: .text, scheme: .primary, size: .large, disabled: false)
        let iPhone12Snapshot = sut.snapshot(for: .iPhone12(style: .light))
        let iPad8thGenSnapshot = sut.snapshot(for: .iPad8thGen(style: .light))
        
        assert(snapshot: iPhone12Snapshot, sut: sut)
        assert(snapshot: iPad8thGenSnapshot, sut: sut)
    }
    
    func test_initWhenTypeIsTextAndSchemeIsSecondaryAndSizeIsLargeAndDisabledIsFalse() {
        let sut = makeSUT(type: .text, scheme: .secondary, size: .large, disabled: false)
        let iPhone12Snapshot = sut.snapshot(for: .iPhone12(style: .light))
        let iPad8thGenSnapshot = sut.snapshot(for: .iPad8thGen(style: .light))
        
        assert(snapshot: iPhone12Snapshot, sut: sut)
        assert(snapshot: iPad8thGenSnapshot, sut: sut)
    }
    
    func test_initWhenTypeIsTextAndSchemeIsPrimaryAndSizeIsSmallAndDisabledIsFalse() {
        let sut = makeSUT(type: .text, scheme: .primary, size: .small, disabled: false)
        let iPhone12Snapshot = sut.snapshot(for: .iPhone12(style: .light))
        let iPad8thGenSnapshot = sut.snapshot(for: .iPad8thGen(style: .light))
        
        assert(snapshot: iPhone12Snapshot, sut: sut)
        assert(snapshot: iPad8thGenSnapshot, sut: sut)
    }
    
    func test_initWhenTypeIsTextAndSchemeIsPrimaryAndSizeIsLargeAndDisabledIsTrue() {
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

