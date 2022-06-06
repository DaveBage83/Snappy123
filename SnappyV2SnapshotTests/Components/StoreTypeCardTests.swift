//
//  StoreTypeCardTests.swift
//  SnappyV2SnapshotTests
//
//  Created by David Bage on 15/05/2022.
//

import XCTest
import SwiftUI
@testable import SnappyV2

@MainActor
class StoreTypeCardTests: XCTestCase {
    func _testinit() {
        let sut = makeSUT()
        let iPhone12Snapshot = sut.snapshot(for: .iPhone12(style: .light))
        let iPad8thGenSnapshot = sut.snapshot(for: .iPad8thGen(style: .light))
        
        assert(snapshot: iPhone12Snapshot, sut: sut)
        assert(snapshot: iPad8thGenSnapshot, sut: sut)
    }
    
    func makeSUT() -> StoreTypeCard {
        StoreTypeCard(
            container: .preview,
            storeType:  RetailStoreProductType(
                id: 21,
                name: "Convenience Stores",
                image: [
                    "mdpi_1x": URL(string: "https://www.snappyshopper.co.uk/uploads/images/store_types_full_width/mdpi_1x/1613754190stores.png")!,
                    "xhdpi_2x": URL(string: "https://www.snappyshopper.co.uk/uploads/images/store_types_full_width/xhdpi_2x/1613754190stores.png")!,
                    "xxhdpi_3x": URL(string: "https://www.snappyshopper.co.uk/uploads/images/store_types_full_width/xxhdpi_3x/1613754190stores.png")!
                ]
            ), selected: .constant(true), viewModel: .init(container: .preview))
    }
}
