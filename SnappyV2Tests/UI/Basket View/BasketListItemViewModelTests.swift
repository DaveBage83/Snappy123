//
//  BasketListItemViewModelTests.swift
//  SnappyV2Tests
//
//  Created by Henrik Gustavii on 05/01/2022.
//

import XCTest
@testable import SnappyV2

class BasketListItemViewModelTests: XCTestCase {
    
    func test_init_givenItemHasNoMissedPromotions() {
        let storeMenuItemPrice = RetailStoreMenuItemPrice(price: 10, fromPrice: 9, unitMetric: "", unitsInPack: 0, unitVolume: 0, wasPrice: nil)
        let storeMenuItem = RetailStoreMenuItem(id: 123, name: "ItemName", eposCode: nil, outOfStock: false, ageRestriction: 0, description: nil, quickAdd: true, acceptCustomerInstructions: false, basketQuantityLimit: 500, price: storeMenuItemPrice, images: nil, menuItemSizes: nil, menuItemOptions: nil, availableDeals: nil, itemCaptions: nil, mainCategory: MenuItemCategory(id: 345, name: ""), itemDetails: nil)
        let basketItem = BasketItem(basketLineId: 321, menuItem: storeMenuItem, totalPrice: 10, totalPriceBeforeDiscounts: 9, price: 9, pricePaid: 9, quantity: 0, instructions: nil, size: nil, selectedOptions: nil, missedPromotions: nil, isAlcohol: false)
        let sut = makeSUT(item: basketItem, changeQuantity: {_, _ in})
        
        XCTAssertEqual(sut.item, basketItem)
        XCTAssertTrue(sut.quantity.isEmpty)
        XCTAssertNil(sut.latestMissedPromotion)
        XCTAssertFalse(sut.hasMissedPromotions)
    }
    
    func test_init_givenItemHasMissedPromotions() {
        let storeMenuItemPrice = RetailStoreMenuItemPrice(price: 10, fromPrice: 9, unitMetric: "", unitsInPack: 0, unitVolume: 0, wasPrice: nil)
        let storeMenuItem = RetailStoreMenuItem(id: 123, name: "ItemName", eposCode: nil, outOfStock: false, ageRestriction: 0, description: nil, quickAdd: true, acceptCustomerInstructions: false, basketQuantityLimit: 500, price: storeMenuItemPrice, images: nil, menuItemSizes: nil, menuItemOptions: nil, availableDeals: nil, itemCaptions: nil, mainCategory: MenuItemCategory(id: 345, name: ""), itemDetails: nil)
        let basketItem = BasketItem(basketLineId: 321, menuItem: storeMenuItem, totalPrice: 10, totalPriceBeforeDiscounts: 9, price: 9, pricePaid: 9, quantity: 0, instructions: nil, size: nil, selectedOptions: nil, missedPromotions: [
            BasketItemMissedPromotion(referenceId: 123, name: "Test promo", type: .multiSectionDiscount, missedSections: nil),
            BasketItemMissedPromotion(referenceId: 456, name: "Test promo", type: .multiSectionDiscount, missedSections: nil)
        ], isAlcohol: false)
        let sut = makeSUT(item: basketItem, changeQuantity: {_, _ in})
        
        XCTAssertEqual(sut.item, basketItem)
        XCTAssertTrue(sut.quantity.isEmpty)
        XCTAssertEqual(sut.latestMissedPromotion?.referenceId, 456)
        XCTAssertTrue(sut.hasMissedPromotions)
    }
    
    func test_givenBasketItem_whenOnSubmit_thenQuantityIsResetAndClosureReturns() {
        let storeMenuItemPrice = RetailStoreMenuItemPrice(price: 10, fromPrice: 9, unitMetric: "", unitsInPack: 0, unitVolume: 0, wasPrice: nil)
        let storeMenuItem = RetailStoreMenuItem(id: 123, name: "ItemName", eposCode: nil, outOfStock: false, ageRestriction: 0, description: nil, quickAdd: true, acceptCustomerInstructions: false, basketQuantityLimit: 500, price: storeMenuItemPrice, images: nil, menuItemSizes: nil, menuItemOptions: nil, availableDeals: nil, itemCaptions: nil, mainCategory: MenuItemCategory(id: 345, name: ""), itemDetails: nil)
        let basketItem = BasketItem(basketLineId: 321, menuItem: storeMenuItem, totalPrice: 10, totalPriceBeforeDiscounts: 9, price: 9, pricePaid: 9, quantity: 0, instructions: nil, size: nil, selectedOptions: nil, missedPromotions: nil, isAlcohol: false)
        let sut = makeSUT(item: basketItem) { basketItem, quantity in
            XCTAssertEqual(basketItem.menuItem.id, 123)
            XCTAssertEqual(quantity, 2)
            XCTAssertEqual(basketItem.basketLineId, 321)
        }
        sut.quantity = "2"
        
        sut.onSubmit()
        
        XCTAssertTrue(sut.quantity.isEmpty)
    }
    
    func test_whenFilterQuantityToStringNumberIsTriggered_thenOnlyNumberIsStored() {
        let storeMenuItemPrice = RetailStoreMenuItemPrice(price: 10, fromPrice: 9, unitMetric: "", unitsInPack: 0, unitVolume: 0, wasPrice: nil)
        let storeMenuItem = RetailStoreMenuItem(id: 123, name: "ItemName", eposCode: nil, outOfStock: false, ageRestriction: 0, description: nil, quickAdd: true, acceptCustomerInstructions: false, basketQuantityLimit: 500, price: storeMenuItemPrice, images: nil, menuItemSizes: nil, menuItemOptions: nil, availableDeals: nil, itemCaptions: nil, mainCategory: MenuItemCategory(id: 345, name: ""), itemDetails: nil)
        let basketItem = BasketItem(basketLineId: 321, menuItem: storeMenuItem, totalPrice: 10, totalPriceBeforeDiscounts: 9, price: 9, pricePaid: 9, quantity: 0, instructions: nil, size: nil, selectedOptions: nil, missedPromotions: nil, isAlcohol: false)
        let sut = makeSUT(item: basketItem, changeQuantity: {_, _ in})
        
        sut.filterQuantityToStringNumber(stringValue: "OneTwo12")
        
        XCTAssertEqual(sut.quantity, "12")
    }
    
    func test_hasMissedPromotions() {
        let storeMenuItemPrice = RetailStoreMenuItemPrice(price: 10, fromPrice: 9, unitMetric: "", unitsInPack: 0, unitVolume: 0, wasPrice: nil)
        let storeMenuItem = RetailStoreMenuItem(id: 123, name: "ItemName", eposCode: nil, outOfStock: false, ageRestriction: 0, description: nil, quickAdd: true, acceptCustomerInstructions: false, basketQuantityLimit: 500, price: storeMenuItemPrice, images: nil, menuItemSizes: nil, menuItemOptions: nil, availableDeals: nil, itemCaptions: nil, mainCategory: MenuItemCategory(id: 345, name: ""), itemDetails: nil)
        let basketItem_with_missed_promo = BasketItem(basketLineId: 321, menuItem: storeMenuItem, totalPrice: 10, totalPriceBeforeDiscounts: 9, price: 9, pricePaid: 9, quantity: 0, instructions: nil, size: nil, selectedOptions: nil, missedPromotions: [BasketItemMissedPromotion(referenceId: 123, name: "Test promotion", type: .multiSectionDiscount, missedSections: nil), BasketItemMissedPromotion(referenceId: 456, name: "Test promotion", type: .multiSectionDiscount, missedSections: nil)], isAlcohol: false)
        let basketItem_without_missed_promo = BasketItem(basketLineId: 321, menuItem: storeMenuItem, totalPrice: 10, totalPriceBeforeDiscounts: 9, price: 9, pricePaid: 9, quantity: 0, instructions: nil, size: nil, selectedOptions: nil, missedPromotions: nil, isAlcohol: false)
        
        let sutMissedPromo = makeSUT(item: basketItem_with_missed_promo, changeQuantity: {_, _ in})
        let sutNoMissedPromo = makeSUT(item: basketItem_without_missed_promo, changeQuantity: {_, _ in})
        
        XCTAssertTrue(sutMissedPromo.hasMissedPromotions)
        XCTAssertFalse(sutNoMissedPromo.hasMissedPromotions)
        XCTAssertEqual(sutMissedPromo.latestMissedPromotion?.referenceId, 456)
    }
    
    func makeSUT(item: BasketItem, changeQuantity: @escaping (BasketItem, Int) -> Void) -> BasketListItemViewModel {
        let sut = BasketListItemViewModel(container: .preview, item: item, changeQuantity: changeQuantity)
        trackForMemoryLeaks(sut)
        return sut
    }

}
