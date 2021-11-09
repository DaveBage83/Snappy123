//
//  ProductsViewModelTests.swift
//  SnappyV2Tests
//
//  Created by Henrik Gustavii on 08/11/2021.
//

import XCTest
@testable import SnappyV2

class ProductsViewModelTests: XCTestCase {
    
    func test_init() {
        let sut = makeSUT()
        
        XCTAssertEqual(sut.container.appState.value, AppState())
        XCTAssertTrue(sut.searchText.isEmpty)
        XCTAssertNil(sut.productDetail)
        XCTAssertEqual(sut.viewState, .category)
        XCTAssertEqual(sut.selectedRetailStoreDetails, .notRequested)
        XCTAssertEqual(sut.selectedFulfilmentMethod, .delivery)
        XCTAssertEqual(sut.menuFetch, .notRequested)
    }
    
    func test_whenGetCategoriesTapped() {
        let container = DIContainer(appState: AppState(), services: .mocked(retailStoreMenuService: [.getRootCategories(storeId: 123, fulfilmentMethod: .delivery)]))
        let sut = makeSUT(container: container)
        
        sut.container.appState.value.userData.selectedStore = .loaded(RetailStoreDetails(id: 123, menuGroupId: 12, storeName: "", telephone: "", lat: 0, lng: 0, ordersPaused: false, canDeliver: true, distance: nil, pausedMessage: nil, address1: "", address2: nil, town: "", postcode: "", storeLogo: nil, storeProductTypes: nil, orderMethods: nil, deliveryDays: nil, collectionDays: nil, timeZone: nil, searchPostcode: nil))
        
        sut.getCategories()
        
        container.services.verify()
    }
    
    func test_whenSubCategoriesAndItemsTapped() {
        let container = DIContainer(appState: AppState(), services: .mocked(retailStoreMenuService: [.getChildCategoriesAndItems(storeId: 123, categoryId: 321, fulfilmentMethod: .delivery)]))
        let sut = makeSUT(container: container)
        
        sut.container.appState.value.userData.selectedStore = .loaded(RetailStoreDetails(id: 123, menuGroupId: 12, storeName: "", telephone: "", lat: 0, lng: 0, ordersPaused: false, canDeliver: true, distance: nil, pausedMessage: nil, address1: "", address2: nil, town: "", postcode: "", storeLogo: nil, storeProductTypes: nil, orderMethods: nil, deliveryDays: nil, collectionDays: nil, timeZone: nil, searchPostcode: nil))
        
        sut.getSubCategoriesAndItems(categoryID: 321)
        
        container.services.verify()
    }

    func makeSUT(container: DIContainer = DIContainer(appState: AppState(), services: .mocked())) -> ProductsViewModel {
        let sut = ProductsViewModel(container: container)
        
        trackForMemoryLeaks(sut)
        
        return sut
    }

}
