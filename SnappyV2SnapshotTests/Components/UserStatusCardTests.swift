//
//  LoginCardTests.swift
//  SnappyV2SnapshotTests
//
//  Created by David Bage on 13/05/2022.
//

import XCTest
import SwiftUI
@testable import SnappyV2

class UserStatusCardTests: XCTestCase {
    func _testinit_givenCheckoutTypeIsGuest() {
        let sut = makeSUT(checkoutType: .guest)
        let iPhone12Snapshot = sut.snapshot(for: .iPhone12(style: .light))
        let iPad8thGenSnapshot = sut.snapshot(for: .iPad8thGen(style: .light))
        
        assert(snapshot: iPhone12Snapshot, sut: sut)
        assert(snapshot: iPad8thGenSnapshot, sut: sut)
    }
    
    func _testinit_givenCheckoutTypeIsMember() {
        let sut = makeSUT(checkoutType: .member)
        let iPhone12Snapshot = sut.snapshot(for: .iPhone12(style: .light))
        let iPad8thGenSnapshot = sut.snapshot(for: .iPad8thGen(style: .light))
        
        assert(snapshot: iPhone12Snapshot, sut: sut)
        assert(snapshot: iPad8thGenSnapshot, sut: sut)
    }
    
    func makeSUT(checkoutType: UserStatusCard.CheckoutType) -> UserStatusCard {
        UserStatusCard(container: .preview, checkoutType: checkoutType)
    }
}
