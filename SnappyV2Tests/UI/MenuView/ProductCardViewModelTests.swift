//
//  ProductCardViewModelTests.swift
//  SnappyV2Tests
//
//  Created by Henrik Gustavii on 11/11/2021.
//

import XCTest
import Combine
@testable import SnappyV2

class ProductCardViewModelTests: XCTestCase {
    
    func test_init() {
        let price = RetailStoreMenuItemPrice(price: 10, fromPrice: 0, unitMetric: "", unitsInPack: 0, unitVolume: 0, wasPrice: nil)
        let menuItem = RetailStoreMenuItem(id: 123, name: "", eposCode: nil, outOfStock: false, ageRestriction: 0, description: "", quickAdd: true, acceptCustomerInstructions: false, basketQuantityLimit: 500, price: price, images: nil, menuItemSizes: nil, menuItemOptions: nil, availableDeals: nil, itemCaptions: nil, mainCategory: MenuItemCategory(id: 345, name: ""))
        let sut = makeSUT(menuItem: menuItem)
        
        XCTAssertEqual(sut.itemDetail, menuItem)
        XCTAssertFalse(sut.showSearchProductCard)
        XCTAssertFalse(sut.isReduced)
        XCTAssertNil(sut.calorieInfo)
        XCTAssertFalse(sut.hasFromPrice)
    }
    
    func test_whenWasPricePresent_thenIsReducedIsTrueAndWasPriceStringIsPopulated() {
        let price = RetailStoreMenuItemPrice(price: 10, fromPrice: 0, unitMetric: "", unitsInPack: 0, unitVolume: 0, wasPrice: 22)
        let menuItem = RetailStoreMenuItem(id: 123, name: "", eposCode: nil, outOfStock: false, ageRestriction: 0, description: "", quickAdd: true, acceptCustomerInstructions: false, basketQuantityLimit: 500, price: price, images: nil, menuItemSizes: nil, menuItemOptions: nil, availableDeals: nil, itemCaptions: nil, mainCategory: MenuItemCategory(id: 345, name: ""))
        let sut = makeSUT(menuItem: menuItem)
        
        XCTAssertTrue(sut.isReduced)
        XCTAssertEqual(sut.wasPrice, "£22.00")
    }
    
    func test_whenCalorieInfoPresent_thenCalorieStringPopulated() {
        let price = RetailStoreMenuItemPrice(price: 10, fromPrice: 0, unitMetric: "", unitsInPack: 0, unitVolume: 0, wasPrice: 22)
        let menuItem = RetailStoreMenuItem(id: 123, name: "", eposCode: nil, outOfStock: false, ageRestriction: 0, description: "", quickAdd: true, acceptCustomerInstructions: false, basketQuantityLimit: 500, price: price, images: nil, menuItemSizes: nil, menuItemOptions: nil, availableDeals: nil, itemCaptions: ItemCaptions(portionSize: "450 kcal per 100g"), mainCategory: MenuItemCategory(id: 345, name: ""))
        let sut = makeSUT(menuItem: menuItem)
        
        XCTAssertEqual(sut.calorieInfo, "450 kcal per 100g")
    }
    
    func test_whenFromPriceIs0_thenHasFromPriceIsFalse() {
        let price = RetailStoreMenuItemPrice(price: 10, fromPrice: 0, unitMetric: "", unitsInPack: 0, unitVolume: 0, wasPrice: 22)
        let menuItem = RetailStoreMenuItem(id: 123, name: "", eposCode: nil, outOfStock: false, ageRestriction: 0, description: "", quickAdd: true, acceptCustomerInstructions: false, basketQuantityLimit: 500, price: price, images: nil, menuItemSizes: nil, menuItemOptions: nil, availableDeals: nil, itemCaptions: ItemCaptions(portionSize: "450 kcal per 100g"), mainCategory: MenuItemCategory(id: 345, name: ""))
        let sut = makeSUT(menuItem: menuItem)
        
        XCTAssertFalse(sut.hasFromPrice)
    }
    
    func test_whenFromPriceIsGreaterThan0_thenHasFromPriceIsTrue() {
        let price = RetailStoreMenuItemPrice(price: 10, fromPrice: 22, unitMetric: "", unitsInPack: 0, unitVolume: 0, wasPrice: 22)
        let menuItem = RetailStoreMenuItem(id: 123, name: "", eposCode: nil, outOfStock: false, ageRestriction: 0, description: "", quickAdd: true, acceptCustomerInstructions: false, basketQuantityLimit: 500, price: price, images: nil, menuItemSizes: nil, menuItemOptions: nil, availableDeals: nil, itemCaptions: ItemCaptions(portionSize: "450 kcal per 100g"), mainCategory: MenuItemCategory(id: 345, name: ""))
        let sut = makeSUT(menuItem: menuItem)
        
        XCTAssertTrue(sut.hasFromPrice)
    }
    
    func test_latestOffer() {
        let deals = [RetailStoreMenuItemAvailableDeal(id: 888, name: "Test deal", type: "Test type"),
                     RetailStoreMenuItemAvailableDeal(id: 999, name: "Test deal", type: "Test type")]
        let price = RetailStoreMenuItemPrice(price: 10, fromPrice: 0, unitMetric: "", unitsInPack: 0, unitVolume: 0, wasPrice: nil)
        let menuItem = RetailStoreMenuItem(id: 123, name: "", eposCode: nil, outOfStock: false, ageRestriction: 0, description: "", quickAdd: true, acceptCustomerInstructions: false, basketQuantityLimit: 500, price: price, images: nil, menuItemSizes: nil, menuItemOptions: nil, availableDeals: deals, itemCaptions: nil, mainCategory: MenuItemCategory(id: 345, name: ""))
        let sut = makeSUT(menuItem: menuItem)
        
        XCTAssertEqual(sut.latestOffer?.id, 999)
    }
    
    func makeSUT(container: DIContainer = DIContainer(appState: AppState(), eventLogger: MockedEventLogger(), services: .mocked()), menuItem: RetailStoreMenuItem) -> ProductCardViewModel {
        let sut = ProductCardViewModel(container: container, menuItem: menuItem)
        
        trackForMemoryLeaks(sut)
        
        return sut
    }
}
