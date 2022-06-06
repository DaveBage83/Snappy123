//
//  StoreReviewPillTests.swift
//  SnappyV2SnapshotTests
//
//  Created by David Bage on 06/06/2022.
//

import XCTest
import SwiftUI
@testable import SnappyV2

#warning("Tests currently disabled - will enable all snapshot tests once designs are stable")
class StoreReviewPillTests: XCTestCase {
    func _testinit_twoStar() {
        let sut = makeSUT(averageRating: 2.0, numRatings: 30)
        let iPhone12Snapshot = sut.snapshot(for: .iPhone12(style: .light))
        let iPad8thGenSnapshot = sut.snapshot(for: .iPad8thGen(style: .light))
        
        assert(snapshot: iPhone12Snapshot, sut: sut)
        assert(snapshot: iPad8thGenSnapshot, sut: sut)
    }
    
    func _testinit_twopointFiveStar() {
        let sut = makeSUT(averageRating: 2.5, numRatings: 30)
        let iPhone12Snapshot = sut.snapshot(for: .iPhone12(style: .light))
        let iPad8thGenSnapshot = sut.snapshot(for: .iPad8thGen(style: .light))
        
        assert(snapshot: iPhone12Snapshot, sut: sut)
        assert(snapshot: iPad8thGenSnapshot, sut: sut)
    }
    
    func _testinit_threeStar() {
        let sut = makeSUT(averageRating: 3.0, numRatings: 30)
        let iPhone12Snapshot = sut.snapshot(for: .iPhone12(style: .light))
        let iPad8thGenSnapshot = sut.snapshot(for: .iPad8thGen(style: .light))
        
        assert(snapshot: iPhone12Snapshot, sut: sut)
        assert(snapshot: iPad8thGenSnapshot, sut: sut)
    }
    
    func _testinit_threePointFive() {
        let sut = makeSUT(averageRating: 3.5, numRatings: 30)
        let iPhone12Snapshot = sut.snapshot(for: .iPhone12(style: .light))
        let iPad8thGenSnapshot = sut.snapshot(for: .iPad8thGen(style: .light))
        
        assert(snapshot: iPhone12Snapshot, sut: sut)
        assert(snapshot: iPad8thGenSnapshot, sut: sut)
    }
    
    func _testinit_fourStar() {
        let sut = makeSUT(averageRating: 4.0, numRatings: 30)
        let iPhone12Snapshot = sut.snapshot(for: .iPhone12(style: .light))
        let iPad8thGenSnapshot = sut.snapshot(for: .iPad8thGen(style: .light))
        
        assert(snapshot: iPhone12Snapshot, sut: sut)
        assert(snapshot: iPad8thGenSnapshot, sut: sut)
    }
    
    func _testinit_fourPointFive() {
        let sut = makeSUT(averageRating: 4.5, numRatings: 30)
        let iPhone12Snapshot = sut.snapshot(for: .iPhone12(style: .light))
        let iPad8thGenSnapshot = sut.snapshot(for: .iPad8thGen(style: .light))
        
        assert(snapshot: iPhone12Snapshot, sut: sut)
        assert(snapshot: iPad8thGenSnapshot, sut: sut)
    }
    
    func _testinit_fiveStar() {
        let sut = makeSUT(averageRating: 5.0, numRatings: 30)
        let iPhone12Snapshot = sut.snapshot(for: .iPhone12(style: .light))
        let iPad8thGenSnapshot = sut.snapshot(for: .iPad8thGen(style: .light))
        
        assert(snapshot: iPhone12Snapshot, sut: sut)
        assert(snapshot: iPad8thGenSnapshot, sut: sut)
    }
    
    func _testinit_moreThan50Ratings() {
        let sut = makeSUT(averageRating: 2.0, numRatings: 52)
        let iPhone12Snapshot = sut.snapshot(for: .iPhone12(style: .light))
        let iPad8thGenSnapshot = sut.snapshot(for: .iPad8thGen(style: .light))
        
        assert(snapshot: iPhone12Snapshot, sut: sut)
        assert(snapshot: iPad8thGenSnapshot, sut: sut)
    }

    func makeSUT(averageRating: Double, numRatings: Int) -> StoreReviewPill {
        StoreReviewPill(
            container: .preview,
            rating: RetailStoreRatings(
                averageRating: averageRating,
                numRatings: numRatings))
    }
}
