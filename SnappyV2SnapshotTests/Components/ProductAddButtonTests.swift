//
//  ProductAddButtonTests.swift
//  SnappyV2SnapshotTests
//
//  Created by Henrik Gustavii on 18/01/2022.
//

import XCTest
import SwiftUI
@testable import SnappyV2

class ProductAddButtonTests: XCTestCase {

    func test_init() {
        let sut = makeSUT()
        let iPhone12Snapshot = sut.snapshot(for: .iPhone12(style: .light))
        let iPad8thGenSnapshot = sut.snapshot(for: .iPad8thGen(style: .light))
        
        assert(snapshot: iPhone12Snapshot, sut: sut)
        assert(snapshot: iPad8thGenSnapshot, sut: sut)
    }
    
    func makeSUT() -> ProductAddButton {
        ProductAddButton(viewModel: .init(container: .preview, menuItem: RetailStoreMenuItem(id: 123, name: "MenuItem", eposCode: nil, outOfStock: false, ageRestriction: 0, description: nil, quickAdd: true, price: RetailStoreMenuItemPrice(price: 10, fromPrice: 10, unitMetric: "", unitsInPack: 0, unitVolume: 0, wasPrice: nil), images: nil, menuItemSizes: nil, menuItemOptions: nil, availableDeals: nil)))
    }

}
