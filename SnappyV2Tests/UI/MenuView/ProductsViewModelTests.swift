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
        XCTAssertEqual(sut.viewState, .rootCategories)
        XCTAssertEqual(sut.selectedRetailStoreDetails, .notRequested)
        XCTAssertEqual(sut.selectedFulfilmentMethod, .delivery)
        XCTAssertEqual(sut.rootCategoriesMenuFetch, .notRequested)
        XCTAssertEqual(sut.subcategoriesOrItemsMenuFetch, .notRequested)
        XCTAssertNil(sut.rootCategories)
        XCTAssertNil(sut.subCategories)
        XCTAssertNil(sut.items)
        XCTAssertFalse(sut.rootCategoriesIsLoading)
        XCTAssertFalse(sut.subCategoriesOrItemsIsLoading)
    }
    
    func test_whenSubCategoriesIsPopulatedAndItemsIsNil_thenViewStateIsSubCategories() {
        let sut = makeSUT()
        sut.subCategories = []
        
        XCTAssertEqual(sut.viewState, .subCategories)
    }
    
    func test_whenSubCategoriesIsPopulatedAndItemsIsPopulated_thenViewStateIsItems() {
        let sut = makeSUT()
        sut.subCategories = []
        sut.items = []
        
        XCTAssertEqual(sut.viewState, .items)
    }
    
    func test_whenSubCategoriesIsNilAndItemsIsPopulated_thenViewStateIsItems() {
        let sut = makeSUT()
        sut.items = []
        
        XCTAssertEqual(sut.viewState, .items)
    }
    
    func test_givenViewStateSubCategories_whenBackButtonTapped_thenViewStateRootCategories() {
        let sut = makeSUT()
        sut.subCategories = []
        
        sut.backButtonTapped()
        
        XCTAssertEqual(sut.viewState, .rootCategories)
    }
    
    func test_givenViewStateItems_whenBackButtonTapped_thenViewStateSubCategories() {
        let sut = makeSUT()
        sut.subCategories = []
        sut.items = []
        
        sut.backButtonTapped()
        
        XCTAssertEqual(sut.viewState, .subCategories)
    }
    
    func test_whenRootCategoriesAreLoading_thenRootCategoriesIsLoadingReturnsTrue() {
        let sut = makeSUT()
        sut.rootCategoriesMenuFetch = .isLoading(last: nil, cancelBag: CancelBag())
        
        XCTAssertTrue(sut.rootCategoriesIsLoading)
    }
    
    func test_whenRootCategoriesHasLoaded_thenRootCategoriesIsLoadingReturnsFalse() {
        let sut = makeSUT()
        sut.rootCategoriesMenuFetch = .loaded(RetailStoreMenuFetch(categories: nil, menuItems: nil, fetchStoreId: nil, fetchCategoryId: nil, fetchFulfilmentMethod: nil, fetchTimestamp: nil))
        
        XCTAssertFalse(sut.subCategoriesOrItemsIsLoading)
    }
    
    func test_whenSubCategoriesOrItemsAreLoading_thenSubCategoriesOrItemsIsLoadingReturnsTrue() {
        let sut = makeSUT()
        sut.subcategoriesOrItemsMenuFetch = .isLoading(last: nil, cancelBag: CancelBag())
        
        XCTAssertTrue(sut.subCategoriesOrItemsIsLoading)
    }
    
    func test_whenSubCategoriesOrItemsHasLoaded_thenSubCategoriesOrItemsIsLoadingReturnsFalse() {
        let sut = makeSUT()
        sut.subcategoriesOrItemsMenuFetch = .loaded(RetailStoreMenuFetch(categories: nil, menuItems: nil, fetchStoreId: nil, fetchCategoryId: nil, fetchFulfilmentMethod: nil, fetchTimestamp: nil))
        
        XCTAssertFalse(sut.rootCategoriesIsLoading)
    }
    
    func test_whenGetCategoriesTapped() {
        let container = DIContainer(appState: AppState(), services: .mocked(retailStoreMenuService: [.getRootCategories(storeId: 123)]))
        let sut = makeSUT(container: container)
        
        sut.container.appState.value.userData.selectedStore = .loaded(RetailStoreDetails(id: 123, menuGroupId: 12, storeName: "", telephone: "", lat: 0, lng: 0, ordersPaused: false, canDeliver: true, distance: nil, pausedMessage: nil, address1: "", address2: nil, town: "", postcode: "", storeLogo: nil, storeProductTypes: nil, orderMethods: nil, deliveryDays: nil, collectionDays: nil, timeZone: nil, searchPostcode: nil))
        
        sut.getCategories()
        
        container.services.verify()
    }
    
    func test_whenSubCategoriesAndItemsTapped() {
        let container = DIContainer(appState: AppState(), services: .mocked(retailStoreMenuService: [.getChildCategoriesAndItems(storeId: 123, categoryId: 321)]))
        let sut = makeSUT(container: container)
        
        sut.container.appState.value.userData.selectedStore = .loaded(RetailStoreDetails(id: 123, menuGroupId: 12, storeName: "", telephone: "", lat: 0, lng: 0, ordersPaused: false, canDeliver: true, distance: nil, pausedMessage: nil, address1: "", address2: nil, town: "", postcode: "", storeLogo: nil, storeProductTypes: nil, orderMethods: nil, deliveryDays: nil, collectionDays: nil, timeZone: nil, searchPostcode: nil))
        
        sut.categoryTapped(categoryID: 321)
        
        container.services.verify()
    }

    func makeSUT(container: DIContainer = DIContainer(appState: AppState(), services: .mocked())) -> ProductsViewModel {
        let sut = ProductsViewModel(container: container)
        
        trackForMemoryLeaks(sut)
        
        return sut
    }

}
