//
//  ProductCardViewModelTests.swift
//  SnappyV2Tests
//
//  Created by Henrik Gustavii on 11/11/2021.
//

import XCTest
@testable import SnappyV2

class ProductCardViewModelTests: XCTestCase {
    
    func test_init() {
        let price = RetailStoreMenuItemPrice(price: 10, fromPrice: 0, unitMetric: "", unitsInPack: 0, unitVolume: 0, wasPrice: nil)
        let menuItem = RetailStoreMenuItem(id: 123, name: "", eposCode: nil, outOfStock: false, ageRestriction: 0, description: "", quickAdd: true, price: price, images: nil, sizes: nil, options: nil)
        let sut = makeSUT(menuItem: menuItem)
        
        XCTAssertEqual(sut.itemDetail, menuItem)
        XCTAssertNil(sut.basket)
        XCTAssertTrue(sut.quickAddIsEnabled)
        XCTAssertFalse(sut.hasAgeRestriction)
    }
    
    func test_whenAgeIsMoreThanZero_thenHasAgeRestrictionIsTrue() {
        let price = RetailStoreMenuItemPrice(price: 10, fromPrice: 0, unitMetric: "", unitsInPack: 0, unitVolume: 0, wasPrice: nil)
        let menuItem = RetailStoreMenuItem(id: 123, name: "", eposCode: nil, outOfStock: false, ageRestriction: 18, description: "", quickAdd: true, price: price, images: nil, sizes: nil, options: nil)
        let sut = makeSUT(menuItem: menuItem)
        
        XCTAssertTrue(sut.hasAgeRestriction)
    }

    func makeSUT(container: DIContainer = DIContainer(appState: AppState(), services: .mocked()), menuItem: RetailStoreMenuItem) -> ProductCardViewModel {
        let sut = ProductCardViewModel(container: container, menuItem: menuItem)
        
        trackForMemoryLeaks(sut)
        
        return sut
    }

}
