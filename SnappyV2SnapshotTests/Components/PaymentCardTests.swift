//
//  PaymentCardTests.swift
//  SnappyV2SnapshotTests
//
//  Created by David Bage on 13/05/2022.
//

import XCTest
import SwiftUI
@testable import SnappyV2

class PaymentCardTests: XCTestCase {
    func _testinit_givenMethodIsCardAndDisabledIsFalse() {
        let sut = makeSUT(method: .card)
        let iPhone12Snapshot = sut.snapshot(for: .iPhone12(style: .light))
        let iPad8thGenSnapshot = sut.snapshot(for: .iPad8thGen(style: .light))
        
        assert(snapshot: iPhone12Snapshot, sut: sut)
        assert(snapshot: iPad8thGenSnapshot, sut: sut)
    }
    
    func _testinit_givenMethodIsCardAndDisabledIsTrue() {
        let sut = makeSUT(method: .card, disabled: true)
        let iPhone12Snapshot = sut.snapshot(for: .iPhone12(style: .light))
        let iPad8thGenSnapshot = sut.snapshot(for: .iPad8thGen(style: .light))
        
        assert(snapshot: iPhone12Snapshot, sut: sut)
        assert(snapshot: iPad8thGenSnapshot, sut: sut)
    }
    
    func _testinit_givenMethodIsCashAndDisabledIsFalse() {
        let sut = makeSUT(method: .cash)
        let iPhone12Snapshot = sut.snapshot(for: .iPhone12(style: .light))
        let iPad8thGenSnapshot = sut.snapshot(for: .iPad8thGen(style: .light))
        
        assert(snapshot: iPhone12Snapshot, sut: sut)
        assert(snapshot: iPad8thGenSnapshot, sut: sut)
    }
    
    func _testinit_givenMethodIsCashAndDisabledIsTrue() {
        let sut = makeSUT(method: .cash, disabled: true)
        let iPhone12Snapshot = sut.snapshot(for: .iPhone12(style: .light))
        let iPad8thGenSnapshot = sut.snapshot(for: .iPad8thGen(style: .light))
        
        assert(snapshot: iPhone12Snapshot, sut: sut)
        assert(snapshot: iPad8thGenSnapshot, sut: sut)
    }
    
    func _testinit_givenMethodIsAppleAndDisabledIsFalse() {
        let sut = makeSUT(method: .apple)
        let iPhone12Snapshot = sut.snapshot(for: .iPhone12(style: .light))
        let iPad8thGenSnapshot = sut.snapshot(for: .iPad8thGen(style: .light))
        
        assert(snapshot: iPhone12Snapshot, sut: sut)
        assert(snapshot: iPad8thGenSnapshot, sut: sut)
    }
    
    func _testinit_givenMethodIsAppleAndDisabledIsTrue() {
        let sut = makeSUT(method: .apple, disabled: true)
        let iPhone12Snapshot = sut.snapshot(for: .iPhone12(style: .light))
        let iPad8thGenSnapshot = sut.snapshot(for: .iPad8thGen(style: .light))
        
        assert(snapshot: iPhone12Snapshot, sut: sut)
        assert(snapshot: iPad8thGenSnapshot, sut: sut)
    }
    
    
    func makeSUT(method: PaymentCard.PaymentMethod, disabled: Bool = false) -> PaymentCard {
        PaymentCard(container: .preview, paymentMethod: method, disabled: disabled)
    }
}

