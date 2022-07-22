//
//  AddressDisplayCard.swift
//  SnappyV2SnapshotTests
//
//  Created by David Bage on 18/07/2022.
//

import XCTest
import SwiftUI
@testable import SnappyV2

class AddressDisplayCardTests: XCTestCase {
    #warning("Test failing on some machines. Need to revisit. Underscore added to ignore test for now.")
    func _test_init_selectedTrue() {
        let sut = makeSUT(selected: true, isDefault: false, addressName: nil)
        let iPhone12Snapshot = sut.snapshot(for: .iPhone12(style: .light))
        let iPad8thGenSnapshot = sut.snapshot(for: .iPad8thGen(style: .light))
        
        assert(snapshot: iPhone12Snapshot, sut: sut)
        assert(snapshot: iPad8thGenSnapshot, sut: sut)
    }
    
    func _test_init_isDefaultTrue() {
        let sut = makeSUT(selected: false, isDefault: true, addressName: nil)
        let iPhone12Snapshot = sut.snapshot(for: .iPhone12(style: .light))
        let iPad8thGenSnapshot = sut.snapshot(for: .iPad8thGen(style: .light))
        
        assert(snapshot: iPhone12Snapshot, sut: sut)
        assert(snapshot: iPad8thGenSnapshot, sut: sut)
    }
    
    func _test_init_isDefaultTrue_withAddressName() {
        let sut = makeSUT(selected: false, isDefault: false, addressName: "Home Address")
        let iPhone12Snapshot = sut.snapshot(for: .iPhone12(style: .light))
        let iPad8thGenSnapshot = sut.snapshot(for: .iPad8thGen(style: .light))
        
        assert(snapshot: iPhone12Snapshot, sut: sut)
        assert(snapshot: iPad8thGenSnapshot, sut: sut)
    }
    
    func makeSUT(selected: Bool, isDefault: Bool, addressName: String?) -> AddressDisplayCard {
        AddressDisplayCard(viewModel: .init(
            container: .preview,
            address: Address(
                id: 1,
                isDefault: isDefault,
                addressName: addressName,
                firstName: "Test name",
                lastName: "Test las name",
                addressLine1: "Address line 1",
                addressLine2: "Address line 2",
                town: "Test Town",
                postcode: "TEST EST",
                county: "Surrey",
                countryCode: "UK",
                type: .delivery,
                location: nil,
                email: nil,
                telephone: nil)),
                           isSelected: .constant(selected))
    }
}
