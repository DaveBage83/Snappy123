//
//  ProductAddButtonTests.swift
//  SnappyV2SnapshotTests
//
//  Created by Henrik Gustavii on 18/01/2022.
//

import XCTest
import SwiftUI
@testable import SnappyV2

@MainActor
class ProductAddButtonTests: XCTestCase {
    func _testinit() {
        let sut = makeSUT()
        let iPhone12Snapshot = sut.snapshot(for: .iPhone12(style: .light))
        let iPad8thGenSnapshot = sut.snapshot(for: .iPad8thGen(style: .light))
        
        assert(snapshot: iPhone12Snapshot, sut: sut)
        assert(snapshot: iPad8thGenSnapshot, sut: sut)
    }
    
    func makeSUT() -> ProductAddButton {
        ProductAddButton(viewModel: .init(container: .preview, menuItem: RetailStoreMenuItem(id: 123, name: "MenuItem", eposCode: nil, outOfStock: false, ageRestriction: 0, description: nil, quickAdd: true, acceptCustomerInstructions: false, basketQuantityLimit: 500, price: RetailStoreMenuItemPrice(price: 10, fromPrice: 10, unitMetric: "", unitsInPack: 0, unitVolume: 0, wasPrice: nil), images: nil, menuItemSizes: nil, menuItemOptions: nil, availableDeals: nil, itemCaptions: ["portionSize": "450 kcal per 100g"], mainCategory: MenuItemCategory.init(id: 345, name: ""))))
    }

}
