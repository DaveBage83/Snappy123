//
//  ProductCardTests.swift
//  SnappyV2SnapshotTests
//
//  Created by David Bage on 12/05/2022.
//

import XCTest
import SwiftUI
@testable import SnappyV2

@MainActor
class ProductCardTests: XCTestCase {
    // MARK: - Standard cards
    func _testinit_standardCardNoFromPriceAndNoWasPriceAndQuickAddTrue() {
        let sut = makeSUT(searchCard: false, fromPrice: 0, quickAddPresent: true)
        let iPhone12Snapshot = sut.snapshot(for: .iPhone12(style: .light))
        let iPad8thGenSnapshot = sut.snapshot(for: .iPad8thGen(style: .light))
        
        assert(snapshot: iPhone12Snapshot, sut: sut)
        assert(snapshot: iPad8thGenSnapshot, sut: sut)
    }
    
    func _testinit_standardCardNoFromPriceAndNoWasPriceAndQuickAddFalse() {
        let sut = makeSUT(searchCard: false, fromPrice: 0, quickAddPresent: false)
        let iPhone12Snapshot = sut.snapshot(for: .iPhone12(style: .light))
        let iPad8thGenSnapshot = sut.snapshot(for: .iPad8thGen(style: .light))
        
        assert(snapshot: iPhone12Snapshot, sut: sut)
        assert(snapshot: iPad8thGenSnapshot, sut: sut)
    }
    
    func _testinit_standardCardFromPricePresentAndNoWasPriceAndQuickAddTrue() {
        let sut = makeSUT(searchCard: false, fromPrice: 22, quickAddPresent: true)
        let iPhone12Snapshot = sut.snapshot(for: .iPhone12(style: .light))
        let iPad8thGenSnapshot = sut.snapshot(for: .iPad8thGen(style: .light))
        
        assert(snapshot: iPhone12Snapshot, sut: sut)
        assert(snapshot: iPad8thGenSnapshot, sut: sut)
    }
    
    func _testinit_standardCardFromPricePresentAndNoWasPriceAndQuickAddFalse() {
        let sut = makeSUT(searchCard: false, fromPrice: 22, quickAddPresent: true)
        let iPhone12Snapshot = sut.snapshot(for: .iPhone12(style: .light))
        let iPad8thGenSnapshot = sut.snapshot(for: .iPad8thGen(style: .light))
        
        assert(snapshot: iPhone12Snapshot, sut: sut)
        assert(snapshot: iPad8thGenSnapshot, sut: sut)
    }
    
    func _testinit_standardCardNoFromPriceAndWasPricePresentAndQuickAddTrue() {
        let sut = makeSUT(searchCard: false, fromPrice: 0, wasPrice: 22, quickAddPresent: true)
        let iPhone12Snapshot = sut.snapshot(for: .iPhone12(style: .light))
        let iPad8thGenSnapshot = sut.snapshot(for: .iPad8thGen(style: .light))
        
        assert(snapshot: iPhone12Snapshot, sut: sut)
        assert(snapshot: iPad8thGenSnapshot, sut: sut)
    }
    
    func _testinit_standardCardNoFromPriceAndWasPricePresentAndQuickAddFalse() {
        let sut = makeSUT(searchCard: false, fromPrice: 0, wasPrice: 22, quickAddPresent: true)
        let iPhone12Snapshot = sut.snapshot(for: .iPhone12(style: .light))
        let iPad8thGenSnapshot = sut.snapshot(for: .iPad8thGen(style: .light))
        
        assert(snapshot: iPhone12Snapshot, sut: sut)
        assert(snapshot: iPad8thGenSnapshot, sut: sut)
    }
    
    func _testinit_standardCardFromPricePresentAndWasPricePresentAndQuickAddTrue() {
        let sut = makeSUT(searchCard: false, fromPrice: 21, wasPrice: 22, quickAddPresent: true)
        let iPhone12Snapshot = sut.snapshot(for: .iPhone12(style: .light))
        let iPad8thGenSnapshot = sut.snapshot(for: .iPad8thGen(style: .light))
        
        assert(snapshot: iPhone12Snapshot, sut: sut)
        assert(snapshot: iPad8thGenSnapshot, sut: sut)
    }
    
    func _testinit_standardCardFromPricePresentAndWasPricePresentAndQuickAddFalse() {
        let sut = makeSUT(searchCard: false, fromPrice: 21, wasPrice: 22, quickAddPresent: false)
        let iPhone12Snapshot = sut.snapshot(for: .iPhone12(style: .light))
        let iPad8thGenSnapshot = sut.snapshot(for: .iPad8thGen(style: .light))
        
        assert(snapshot: iPhone12Snapshot, sut: sut)
        assert(snapshot: iPad8thGenSnapshot, sut: sut)
    }
    
    // MARK: - Search cards
    func _testinit_searchCardNoFromPriceAndNoWasPriceAndQuickAddTrue() {
        let sut = makeSUT(searchCard: true, fromPrice: 0, quickAddPresent: true)
        let iPhone12Snapshot = sut.snapshot(for: .iPhone12(style: .light))
        let iPad8thGenSnapshot = sut.snapshot(for: .iPad8thGen(style: .light))
        
        assert(snapshot: iPhone12Snapshot, sut: sut)
        assert(snapshot: iPad8thGenSnapshot, sut: sut)
    }
    
    func _testinit_searchCardNoFromPriceAndNoWasPriceAndQuickAddFalse() {
        let sut = makeSUT(searchCard: true, fromPrice: 0, quickAddPresent: false)
        let iPhone12Snapshot = sut.snapshot(for: .iPhone12(style: .light))
        let iPad8thGenSnapshot = sut.snapshot(for: .iPad8thGen(style: .light))
        
        assert(snapshot: iPhone12Snapshot, sut: sut)
        assert(snapshot: iPad8thGenSnapshot, sut: sut)
    }
    
    func _testinit_searchCardFromPricePresentAndNoWasPriceAndQuickAddTrue() {
        let sut = makeSUT(searchCard: true, fromPrice: 22, quickAddPresent: true)
        let iPhone12Snapshot = sut.snapshot(for: .iPhone12(style: .light))
        let iPad8thGenSnapshot = sut.snapshot(for: .iPad8thGen(style: .light))
        
        assert(snapshot: iPhone12Snapshot, sut: sut)
        assert(snapshot: iPad8thGenSnapshot, sut: sut)
    }
    
    func _testinit_searchCardFromPricePresentAndNoWasPriceAndQuickAddFalse() {
        let sut = makeSUT(searchCard: true, fromPrice: 22, quickAddPresent: true)
        let iPhone12Snapshot = sut.snapshot(for: .iPhone12(style: .light))
        let iPad8thGenSnapshot = sut.snapshot(for: .iPad8thGen(style: .light))
        
        assert(snapshot: iPhone12Snapshot, sut: sut)
        assert(snapshot: iPad8thGenSnapshot, sut: sut)
    }
    
    func _testinit_searchCardNoFromPriceAndWasPricePresentAndQuickAddTrue() {
        let sut = makeSUT(searchCard: true, fromPrice: 0, wasPrice: 22, quickAddPresent: true)
        let iPhone12Snapshot = sut.snapshot(for: .iPhone12(style: .light))
        let iPad8thGenSnapshot = sut.snapshot(for: .iPad8thGen(style: .light))
        
        assert(snapshot: iPhone12Snapshot, sut: sut)
        assert(snapshot: iPad8thGenSnapshot, sut: sut)
    }
    
    func _testinit_searchCardNoFromPriceAndWasPricePresentAndQuickAddFalse() {
        let sut = makeSUT(searchCard: true, fromPrice: 0, wasPrice: 22, quickAddPresent: true)
        let iPhone12Snapshot = sut.snapshot(for: .iPhone12(style: .light))
        let iPad8thGenSnapshot = sut.snapshot(for: .iPad8thGen(style: .light))
        
        assert(snapshot: iPhone12Snapshot, sut: sut)
        assert(snapshot: iPad8thGenSnapshot, sut: sut)
    }
    
    func _testinit_searchCardFromPricePresentAndWasPricePresentAndQuickAddTrue() {
        let sut = makeSUT(searchCard: true, fromPrice: 21, wasPrice: 22, quickAddPresent: true)
        let iPhone12Snapshot = sut.snapshot(for: .iPhone12(style: .light))
        let iPad8thGenSnapshot = sut.snapshot(for: .iPad8thGen(style: .light))
        
        assert(snapshot: iPhone12Snapshot, sut: sut)
        assert(snapshot: iPad8thGenSnapshot, sut: sut)
    }
    
    func _testinit_searchCardFromPricePresentAndWasPricePresentAndQuickAddFalse() {
        let sut = makeSUT(searchCard: true, fromPrice: 21, wasPrice: 22, quickAddPresent: false)
        let iPhone12Snapshot = sut.snapshot(for: .iPhone12(style: .light))
        let iPad8thGenSnapshot = sut.snapshot(for: .iPad8thGen(style: .light))
        
        assert(snapshot: iPhone12Snapshot, sut: sut)
        assert(snapshot: iPad8thGenSnapshot, sut: sut)
    }
    
    func makeSUT(searchCard: Bool, fromPrice: Double, wasPrice: Double? = nil, quickAddPresent: Bool) -> ProductCardView {
        let price = RetailStoreMenuItemPrice(price: 20.90, fromPrice: fromPrice, unitMetric: "", unitsInPack: 0, unitVolume: 0, wasPrice: wasPrice)
        let category = MenuItemCategory.init(id: 345, name: "Whiskey")
        
        let item = RetailStoreMenuItem(id: 123, name: "Some whiskey or other that possibly is not Scottish", eposCode: nil, outOfStock: false, ageRestriction: 18, description: nil, quickAdd: quickAddPresent, acceptCustomerInstructions: false, basketQuantityLimit: 500, price: price, images: nil, menuItemSizes: nil, menuItemOptions: nil, availableDeals: nil, itemCaptions: ItemCaptions(portionSize: "495 Kcal per 100g"), mainCategory: category, itemDetails: nil, deal: nil)
        
        return ProductCardView(viewModel: .init(
            container: .preview,
            menuItem: item,
            productSelected: {_ in}), productsViewModel: .init(container: .preview))
    }
}
