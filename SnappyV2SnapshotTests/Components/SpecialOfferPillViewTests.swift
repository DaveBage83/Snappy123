//
//  SpecialOfferPillViewTests.swift
//  SnappyV2SnapshotTests
//
//  Created by David Bage on 13/01/2022.
//

import XCTest
import SwiftUI
@testable import SnappyV2

class SpecialOfferPillViewTests: XCTestCase {
    func test_init_whenTypeIsChipAndSizeIsSmall() {
        let sut = makeSUT(type: .chip, size: .small)
        let iPhone12Snapshot = sut.snapshot(for: .iPhone12(style: .light))
        let iPad8thGenSnapshot = sut.snapshot(for: .iPad8thGen(style: .light))
        
        assert(snapshot: iPhone12Snapshot, sut: sut)
        assert(snapshot: iPad8thGenSnapshot, sut: sut)
    }
    
    func test_init_whenTypeIsChipAndSizeIsLarge() {
        let sut = makeSUT(type: .chip, size: .large)
        let iPhone12Snapshot = sut.snapshot(for: .iPhone12(style: .light))
        let iPad8thGenSnapshot = sut.snapshot(for: .iPad8thGen(style: .light))
        
        assert(snapshot: iPhone12Snapshot, sut: sut)
        assert(snapshot: iPad8thGenSnapshot, sut: sut)
    }
    
    func test_init_whenTypeIsTextAndSizeIsSmall() {
        let sut = makeSUT(type: .text, size: .small)
        let iPhone12Snapshot = sut.snapshot(for: .iPhone12(style: .light))
        let iPad8thGenSnapshot = sut.snapshot(for: .iPad8thGen(style: .light))
        
        assert(snapshot: iPhone12Snapshot, sut: sut)
        assert(snapshot: iPad8thGenSnapshot, sut: sut)
    }
    
    func test_init_whenTypeIsTextAndSizeIsLarge() {
        let sut = makeSUT(type: .text, size: .large)
        let iPhone12Snapshot = sut.snapshot(for: .iPhone12(style: .light))
        let iPad8thGenSnapshot = sut.snapshot(for: .iPad8thGen(style: .light))
        
        assert(snapshot: iPhone12Snapshot, sut: sut)
        assert(snapshot: iPad8thGenSnapshot, sut: sut)
    }
    
    func makeSUT(type: SpecialOfferPill.PillType, size: SpecialOfferPill.Size) -> SpecialOfferPill {
        SpecialOfferPill(container: .preview, offerText: "20 % off", type: type, size: size)
    }
}
