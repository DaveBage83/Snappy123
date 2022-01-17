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
        XCTAssertNil(sut.productDetail)
        XCTAssertEqual(sut.viewState, .rootCategories)
        XCTAssertEqual(sut.selectedRetailStoreDetails, .notRequested)
        XCTAssertEqual(sut.selectedFulfilmentMethod, .delivery)
        XCTAssertEqual(sut.rootCategoriesMenuFetch, .notRequested)
        XCTAssertEqual(sut.subcategoriesOrItemsMenuFetch, .notRequested)
        XCTAssertTrue(sut.rootCategories.isEmpty)
        XCTAssertTrue(sut.subCategories.isEmpty)
        XCTAssertTrue(sut.items.isEmpty)
        XCTAssertTrue(sut.specialOfferItems.isEmpty)
        XCTAssertFalse(sut.rootCategoriesIsLoading)
        XCTAssertFalse(sut.subCategoriesOrItemsIsLoading)
        XCTAssertTrue(sut.searchText.isEmpty)
        XCTAssertFalse(sut.isEditing)
        XCTAssertEqual(sut.searchResult, .notRequested)
        XCTAssertTrue(sut.searchResultCategories.isEmpty)
        XCTAssertTrue(sut.searchResultItems.isEmpty)
    }
    
    func test_whenSpecialsArePopulated_thenViewStateIsOffers() {
        let sut = makeSUT()
        sut.specialOfferItems = [RetailStoreMenuItem(
            id: 123, name: "Test", eposCode: "Test", outOfStock: false, ageRestriction: 0, description: "",
            quickAdd: true, price: RetailStoreMenuItemPrice(
                price: 5.0, fromPrice: 4.0, unitMetric: "", unitsInPack: 1, unitVolume: 1.0, wasPrice: nil),
            images: nil, menuItemSizes: nil, menuItemOptions: nil, availableDeals: nil)]
        
        XCTAssertEqual(sut.viewState, .offers)
    }
    
    func test_whenSubCategoriesIsPopulatedAndItemsIsNil_thenViewStateIsSubCategories() {
        let sut = makeSUT()
        sut.subCategories = [RetailStoreMenuCategory(id: 123, parentId: 321, name: "", image: nil)]
        
        XCTAssertEqual(sut.viewState, .subCategories)
    }
    
    func test_whenSubCategoriesIsPopulatedAndItemsIsPopulated_thenViewStateIsItems() {
        let sut = makeSUT()
        sut.subCategories = [RetailStoreMenuCategory(id: 123, parentId: 321, name: "", image: nil)]
        sut.items = [RetailStoreMenuItem(id: 123, name: "", eposCode: nil, outOfStock: false, ageRestriction: 0, description: nil, quickAdd: true, price: RetailStoreMenuItemPrice(price: 10, fromPrice: 10, unitMetric: "", unitsInPack: 0, unitVolume: 0, wasPrice: nil), images: nil, menuItemSizes: nil, menuItemOptions: nil, availableDeals: nil)]
        
        XCTAssertEqual(sut.viewState, .items)
    }
    
    func test_whenSubCategoriesIsNilAndItemsIsPopulated_thenViewStateIsItems() {
        let sut = makeSUT()
        sut.items = [RetailStoreMenuItem(id: 123, name: "", eposCode: nil, outOfStock: false, ageRestriction: 0, description: nil, quickAdd: true, price: RetailStoreMenuItemPrice(price: 10, fromPrice: 10, unitMetric: "", unitsInPack: 0, unitVolume: 0, wasPrice: nil), images: nil, menuItemSizes: nil, menuItemOptions: nil, availableDeals: nil)]
        
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
        sut.subCategories = [RetailStoreMenuCategory(id: 123, parentId: 321, name: "", image: nil)]
        sut.items = [RetailStoreMenuItem(id: 123, name: "", eposCode: nil, outOfStock: false, ageRestriction: 0, description: nil, quickAdd: true, price: RetailStoreMenuItemPrice(price: 10, fromPrice: 10, unitMetric: "", unitsInPack: 0, unitVolume: 0, wasPrice: nil), images: nil, menuItemSizes: nil, menuItemOptions: nil, availableDeals: nil)]
        
        sut.backButtonTapped()
        
        XCTAssertEqual(sut.viewState, .subCategories)
    }
    
    func test_whenSpecialsAreLoading_thenSpecialOffersIsLoadingReturnsTrue() {
        let sut = makeSUT()
        sut.specialOffersMenuFetch = .isLoading(last: nil, cancelBag: CancelBag())
        
        XCTAssertTrue(sut.specialOffersIsLoading)
    }
    
    func test_whenRootCategoriesAreLoading_thenRootCategoriesIsLoadingReturnsTrue() {
        let sut = makeSUT()
        sut.rootCategoriesMenuFetch = .isLoading(last: nil, cancelBag: CancelBag())
        
        XCTAssertTrue(sut.rootCategoriesIsLoading)
    }
    
    func test_whenRootCategoriesHasLoaded_thenRootCategoriesIsLoadingReturnsFalse() {
        let sut = makeSUT()
        sut.rootCategoriesMenuFetch = .loaded(RetailStoreMenuFetch(categories: nil, menuItems: nil, fetchStoreId: nil, fetchCategoryId: nil, fetchFulfilmentMethod: nil, fetchFulfilmentDate: nil, fetchTimestamp: nil))
        
        XCTAssertFalse(sut.subCategoriesOrItemsIsLoading)
    }
    
    func test_whenSubCategoriesOrItemsAreLoading_thenSubCategoriesOrItemsIsLoadingReturnsTrue() {
        let sut = makeSUT()
        sut.subcategoriesOrItemsMenuFetch = .isLoading(last: nil, cancelBag: CancelBag())
        
        XCTAssertTrue(sut.subCategoriesOrItemsIsLoading)
    }
    
    func test_whenSubCategoriesOrItemsHasLoaded_thenSubCategoriesOrItemsIsLoadingReturnsFalse() {
        let sut = makeSUT()
        sut.subcategoriesOrItemsMenuFetch = .loaded(RetailStoreMenuFetch(categories: nil, menuItems: nil, fetchStoreId: nil, fetchCategoryId: nil, fetchFulfilmentMethod: nil, fetchFulfilmentDate: nil, fetchTimestamp: nil))
        
        XCTAssertFalse(sut.rootCategoriesIsLoading)
    }
    
    func test_whenSearchIsLoading_thenIsSearchingReturnsTrueAndSearchIsLoadedReturnsFalse() {
        let sut = makeSUT()
        sut.searchResult = .isLoading(last: nil, cancelBag: CancelBag())
        
        XCTAssertTrue(sut.isSearching)
        XCTAssertFalse(sut.searchIsLoaded)
    }
    
    func test_whenSearchHasLoaded_thenIsSearchingReturnsFalseAndSearchIsLoadedReturnsTrue() {
        let sut = makeSUT()
        sut.searchResult = .loaded(RetailStoreMenuGlobalSearch(categories: nil, menuItems: nil, deals: nil, noItemFoundHint: nil, fetchStoreId: nil, fetchFulfilmentMethod: nil, fetchSearchTerm: nil, fetchSearchScope: nil, fetchTimestamp: nil, fetchItemsLimit: nil, fetchItemsPage: nil, fetchCategoriesLimit: nil, fetchCategoryPage: nil))
        
        XCTAssertFalse(sut.isSearching)
        XCTAssertTrue(sut.searchIsLoaded)
    }
    
    func test_whenSearchReturnsNoResultAndHasLoaded_thenNoSearchResultReturnsTrue() {
        let sut = makeSUT()
        sut.searchResult = .loaded(RetailStoreMenuGlobalSearch(categories: nil, menuItems: nil, deals: nil, noItemFoundHint: nil, fetchStoreId: nil, fetchFulfilmentMethod: nil, fetchSearchTerm: nil, fetchSearchScope: nil, fetchTimestamp: nil, fetchItemsLimit: nil, fetchItemsPage: nil, fetchCategoriesLimit: nil, fetchCategoryPage: nil))
        
        XCTAssertTrue(sut.noSearchResult)
    }
    
    func test_whenSearchReturnsItemResultAndHasLoaded_thenNoSearchResultReturnsFalse() {
        let sut = makeSUT()
        let price = RetailStoreMenuItemPrice(price: 10, fromPrice: 10, unitMetric: "", unitsInPack: 0, unitVolume: 0, wasPrice: nil)
        let menuItems = [RetailStoreMenuItem(id: 123, name: "ResultItem", eposCode: nil, outOfStock: false, ageRestriction: 0, description: nil, quickAdd: true, price: price, images: nil, menuItemSizes: nil, menuItemOptions: nil, availableDeals: nil)]
        
        let itemsResult = GlobalSearchItemsResult(pagination: nil, records: menuItems)
        
        sut.searchResult = .loaded(RetailStoreMenuGlobalSearch(categories: nil, menuItems: itemsResult, deals: nil, noItemFoundHint: nil, fetchStoreId: nil, fetchFulfilmentMethod: nil, fetchSearchTerm: nil, fetchSearchScope: nil, fetchTimestamp: nil, fetchItemsLimit: nil, fetchItemsPage: nil, fetchCategoriesLimit: nil, fetchCategoryPage: nil))
        
        XCTAssertTrue(sut.noSearchResult)
    }
    
    func test_whenGetCategoriesTapped() {
        let storeDetails = RetailStoreDetails(id: 123, menuGroupId: 12, storeName: "", telephone: "", lat: 0, lng: 0, ordersPaused: false, canDeliver: true, distance: nil, pausedMessage: nil, address1: "", address2: nil, town: "", postcode: "", storeLogo: nil, storeProductTypes: nil, orderMethods: nil, deliveryDays: nil, collectionDays: nil, timeZone: nil, searchPostcode: nil)

        let container = DIContainer(appState: AppState(), services: .mocked(retailStoreMenuService: [.getRootCategories]))
        let sut = makeSUT(container: container)
        
        sut.container.appState.value.userData.selectedStore = .loaded(storeDetails)
        
        sut.getCategories()
        
        container.services.verify()
    }
    
    func test_whenSubCategoriesAndItemsTapped() {
        let container = DIContainer(appState: AppState(), services: .mocked(retailStoreMenuService: [.getChildCategoriesAndItems(categoryId: 321)]))
        let sut = makeSUT(container: container)

        sut.container.appState.value.userData.selectedStore = .loaded(RetailStoreDetails(id: 123, menuGroupId: 12, storeName: "", telephone: "", lat: 0, lng: 0, ordersPaused: false, canDeliver: true, distance: nil, pausedMessage: nil, address1: "", address2: nil, town: "", postcode: "", storeLogo: nil, storeProductTypes: nil, orderMethods: nil, deliveryDays: nil, collectionDays: nil, timeZone: nil, searchPostcode: nil))

        sut.categoryTapped(categoryID: 321)
        
        container.services.verify()
    }
    
    func test_missedOffer() {
        let container = DIContainer(appState: AppState(), services: .mocked(retailStoreMenuService: [.getChildCategoriesAndItems(categoryId: 321)]))
        let sut = makeSUT(container: container, missedOffer: BasketItemMissedPromotion(referenceId: 123, name: "Test missed promo", type: .multiSectionDiscount, missedSections: nil))
        XCTAssertEqual(sut.missedOffer?.referenceId, 123)
        XCTAssertEqual(sut.offerText, "Test missed promo")
    }
    
    func test_whenSpecialOfferPillTappedTapped() {
        let container = DIContainer(appState: AppState(), services: .mocked(retailStoreMenuService: [.getItems(menuItemIds: nil, discountId: 321, discountSectionId: nil)]))
        let sut = makeSUT(container: container)

        sut.container.appState.value.userData.selectedStore = .loaded(RetailStoreDetails(id: 123, menuGroupId: 12, storeName: "", telephone: "", lat: 0, lng: 0, ordersPaused: false, canDeliver: true, distance: nil, pausedMessage: nil, address1: "", address2: nil, town: "", postcode: "", storeLogo: nil, storeProductTypes: nil, orderMethods: nil, deliveryDays: nil, collectionDays: nil, timeZone: nil, searchPostcode: nil))

        sut.specialOfferPillTapped(offer: RetailStoreMenuItemAvailableDeal(id: 321, name: "Test offer", type: ""))
        
        XCTAssertEqual(sut.offerText, "Test offer")

        container.services.verify()
    }

    func makeSUT(container: DIContainer = DIContainer(appState: AppState(), services: .mocked()), missedOffer: BasketItemMissedPromotion? = nil) -> ProductsViewModel {
        let sut = ProductsViewModel(container: container, missedOffer: missedOffer)
        
        trackForMemoryLeaks(sut)
        
        return sut
    }
}
