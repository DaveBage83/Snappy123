//
//  ProductsViewModelTests.swift
//  SnappyV2Tests
//
//  Created by Henrik Gustavii on 08/11/2021.
//

import XCTest
import Combine
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
        XCTAssertFalse(sut.specialOffersIsLoading)
        XCTAssertFalse(sut.rootCategoriesIsLoading)
        XCTAssertFalse(sut.subCategoriesOrItemsIsLoading)
        XCTAssertTrue(sut.searchText.isEmpty)
        XCTAssertFalse(sut.isEditing)
        XCTAssertEqual(sut.searchResult, .notRequested)
        XCTAssertTrue(sut.searchResultCategories.isEmpty)
        XCTAssertTrue(sut.searchResultItems.isEmpty)
        XCTAssertFalse(sut.noSearchResult)
        XCTAssertFalse(sut.showBackButton)
        XCTAssertFalse(sut.showSearchResultCategories)
        XCTAssertFalse(sut.showSearchResultItems)
    }
    
    func test_whenSpecialsArePopulated_thenViewStateIsOffers() {
        let sut = makeSUT()
        sut.specialOfferItems = [RetailStoreMenuItem(
            id: 123, name: "Test", eposCode: "Test", outOfStock: false, ageRestriction: 0, description: "",
            quickAdd: true, acceptCustomerInstructions: false, basketQuantityLimit: 500, price: RetailStoreMenuItemPrice(
                price: 5.0, fromPrice: 4.0, unitMetric: "", unitsInPack: 1, unitVolume: 1.0, wasPrice: nil),
            images: nil, menuItemSizes: nil, menuItemOptions: nil, availableDeals: nil, itemCaptions: nil)]
        
        XCTAssertEqual(sut.viewState, .offers)
    }
    
    func test_whenSubCategoriesIsPopulatedAndItemsIsNil_thenViewStateIsSubCategories() {
        let sut = makeSUT()
        sut.subCategories = [RetailStoreMenuCategory(id: 123, parentId: 321, name: "", image: nil, description: "")]
        
        XCTAssertEqual(sut.viewState, .subCategories)
    }
    
    func test_whenSubCategoriesIsPopulatedAndItemsIsPopulated_thenViewStateIsItems() {
        let sut = makeSUT()

        sut.subCategories = [RetailStoreMenuCategory(id: 123, parentId: 321, name: "", image: nil, description: "")]
        sut.items = [RetailStoreMenuItem(id: 123, name: "", eposCode: nil, outOfStock: false, ageRestriction: 0, description: nil, quickAdd: true, acceptCustomerInstructions: false, basketQuantityLimit: 500, price: RetailStoreMenuItemPrice(price: 10, fromPrice: 10, unitMetric: "", unitsInPack: 0, unitVolume: 0, wasPrice: nil), images: nil, menuItemSizes: nil, menuItemOptions: nil, availableDeals: nil, itemCaptions: nil)]
        
        XCTAssertEqual(sut.viewState, .items)
    }
    
    func test_whenSubCategoriesIsNilAndItemsIsPopulated_thenViewStateIsItems() {
        let sut = makeSUT()
        sut.items = [RetailStoreMenuItem(id: 123, name: "", eposCode: nil, outOfStock: false, ageRestriction: 0, description: nil, quickAdd: true, acceptCustomerInstructions: false, basketQuantityLimit: 500, price: RetailStoreMenuItemPrice(price: 10, fromPrice: 10, unitMetric: "", unitsInPack: 0, unitVolume: 0, wasPrice: nil), images: nil, menuItemSizes: nil, menuItemOptions: nil, availableDeals: nil, itemCaptions: nil)]
        
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

        sut.subCategories = [RetailStoreMenuCategory(id: 123, parentId: 321, name: "", image: nil, description: "")]
        sut.items = [RetailStoreMenuItem(id: 123, name: "", eposCode: nil, outOfStock: false, ageRestriction: 0, description: nil, quickAdd: true, acceptCustomerInstructions: false, basketQuantityLimit: 500, price: RetailStoreMenuItemPrice(price: 10, fromPrice: 10, unitMetric: "", unitsInPack: 0, unitVolume: 0, wasPrice: nil), images: nil, menuItemSizes: nil, menuItemOptions: nil, availableDeals: nil, itemCaptions: nil)]
        
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
    
    func test_whenRootCategoriesMenuFetchHasLoadedWithResult_thenRootCategoriesIsPopulated() {
        let sut = makeSUT()
        
        let expectation = expectation(description: "setupRootCategories")
        var cancellables = Set<AnyCancellable>()
        
        sut.$rootCategories
            .first()
            .receive(on: RunLoop.main)
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        let category = [RetailStoreMenuCategory(id: 123, parentId: 0, name: "RootCategory", image: nil, description: "")]
        sut.rootCategoriesMenuFetch = .loaded(RetailStoreMenuFetch(categories: category, menuItems: nil, fetchStoreId: nil, fetchCategoryId: nil, fetchFulfilmentMethod: nil, fetchFulfilmentDate: nil, fetchTimestamp: nil))
        
        wait(for: [expectation], timeout: 5)
        
        XCTAssertEqual(sut.rootCategories, category)
    }
    
    func test_whenSubCategoriesAndItemsMenuFetchHasLoadedWithResult_thenSubCategoriesIsPopulated() {
        let sut = makeSUT()
        
        let expectation = expectation(description: "setupSubCategoriesOrItems")
        var cancellables = Set<AnyCancellable>()
        
        sut.$subCategories
            .first()
            .receive(on: RunLoop.main)
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        let category = [RetailStoreMenuCategory(id: 123, parentId: 0, name: "SubCategory", image: nil, description: "")]
        sut.subcategoriesOrItemsMenuFetch = .loaded(RetailStoreMenuFetch(categories: category, menuItems: nil, fetchStoreId: nil, fetchCategoryId: nil, fetchFulfilmentMethod: nil, fetchFulfilmentDate: nil, fetchTimestamp: nil))
        
        wait(for: [expectation], timeout: 5)
        
        XCTAssertEqual(sut.subCategories, category)
        XCTAssertTrue(sut.items.isEmpty)
    }
    
    func test_whenSubCategoriesAndItemsMenuFetchHasLoadedWithResult_thenItemsIsPopulated() {
        let sut = makeSUT()
        
        let expectation = expectation(description: "setupSubCategoriesOrItems")
        var cancellables = Set<AnyCancellable>()
        
        sut.$items
            .first()
            .receive(on: RunLoop.main)
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        let item = [RetailStoreMenuItem(id: 123, name: "ItemName", eposCode: nil, outOfStock: false, ageRestriction: 0, description: nil, quickAdd: true, acceptCustomerInstructions: false, basketQuantityLimit: 500, price: RetailStoreMenuItemPrice(price: 10, fromPrice: 10, unitMetric: "", unitsInPack: 0, unitVolume: 0, wasPrice: nil), images: nil, menuItemSizes: nil, menuItemOptions: nil, availableDeals: nil, itemCaptions: nil)]
        sut.subcategoriesOrItemsMenuFetch = .loaded(RetailStoreMenuFetch(categories: nil, menuItems: item, fetchStoreId: nil, fetchCategoryId: nil, fetchFulfilmentMethod: nil, fetchFulfilmentDate: nil, fetchTimestamp: nil))
        
        wait(for: [expectation], timeout: 5)
        
        XCTAssertEqual(sut.items, item)
        XCTAssertTrue(sut.subCategories.isEmpty)
    }
    
    func test_whenSearchResultHoldsCategoriesAndItems_thenSearchResultCategoriesAndSearchResultItemsArePopulated() {
        let sut = makeSUT()
        
        let expectationItems = expectation(description: "setupCategoriesOrItemSearchResult")
        let expectationCategories = expectation(description: "setupCategoriesOrItemSearchResult")
        var cancellables = Set<AnyCancellable>()
        
        let categories = [GlobalSearchResultRecord(id: 321, name: "CategoryName", image: nil, price: nil)]
        let items = [RetailStoreMenuItem(id: 123, name: "ItemName", eposCode: nil, outOfStock: false, ageRestriction: 0, description: nil, quickAdd: true, acceptCustomerInstructions: false, basketQuantityLimit: 500, price: RetailStoreMenuItemPrice(price: 10, fromPrice: 10, unitMetric: "", unitsInPack: 0, unitVolume: 0, wasPrice: nil), images: nil, menuItemSizes: nil, menuItemOptions: nil, availableDeals: nil, itemCaptions: nil)]
        
        let searchResultCategories = GlobalSearchResult(pagination: nil, records: categories)
        let searchResultItems = GlobalSearchItemsResult(pagination: nil, records: items)
        let searchResult = RetailStoreMenuGlobalSearch(categories: searchResultCategories, menuItems: searchResultItems, deals: nil, noItemFoundHint: nil, fetchStoreId: nil, fetchFulfilmentMethod: nil, fetchSearchTerm: nil, fetchSearchScope: nil, fetchTimestamp: nil, fetchItemsLimit: nil, fetchItemsPage: nil, fetchCategoriesLimit: nil, fetchCategoryPage: nil)
        sut.searchResult = .loaded(searchResult)
        
        sut.$searchResultItems
            .first()
            .receive(on: RunLoop.main)
            .sink { _ in
                expectationItems.fulfill()
            }
            .store(in: &cancellables)
        
        sut.$searchResultCategories
            .first()
            .receive(on: RunLoop.main)
            .sink { _ in
                expectationCategories.fulfill()
            }
            .store(in: &cancellables)
        
        wait(for: [expectationItems, expectationCategories], timeout: 5)
        
        XCTAssertEqual(sut.searchResultCategories, categories)
        XCTAssertEqual(sut.searchResultItems, items)
    }
    
    func test_whenSpecialOffersHasLoaded_thenSpecialOfferItemsIsPopulated() {
        let sut = makeSUT()
        let specialOfferItems = [RetailStoreMenuItem(id: 123, name: "SpecialOfferItemName", eposCode: nil, outOfStock: false, ageRestriction: 0, description: nil, quickAdd: true, acceptCustomerInstructions: false, basketQuantityLimit: 500, price: RetailStoreMenuItemPrice(price: 10, fromPrice: 10, unitMetric: "", unitsInPack: 0, unitVolume: 0, wasPrice: nil), images: nil, menuItemSizes: nil, menuItemOptions: nil, availableDeals: nil, itemCaptions: nil)]
        let specialOfferFetch = RetailStoreMenuFetch(categories: nil, menuItems: specialOfferItems, fetchStoreId: nil, fetchCategoryId: nil, fetchFulfilmentMethod: nil, fetchFulfilmentDate: nil, fetchTimestamp: nil)
        sut.specialOffersMenuFetch = .loaded(specialOfferFetch)
        
        let expectation = expectation(description: "setupSpecialOffers")
        var cancellables = Set<AnyCancellable>()
        
        sut.$specialOfferItems
            .first()
            .receive(on: RunLoop.main)
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 5)
        
        XCTAssertEqual(sut.specialOfferItems, specialOfferItems)
    }
    
    func test_whenMissedOffersHasLoaded_thenSpecialOfferItemsIsPopulated() {
        let sut = makeSUT(missedOffer: BasketItemMissedPromotion(referenceId: 234, name: "GreatOffer", type: .item, missedSections: nil))
        let specialOfferItems = [RetailStoreMenuItem(id: 123, name: "SpecialOfferItemName", eposCode: nil, outOfStock: false, ageRestriction: 0, description: nil, quickAdd: true, acceptCustomerInstructions: false, basketQuantityLimit: 500, price: RetailStoreMenuItemPrice(price: 10, fromPrice: 10, unitMetric: "", unitsInPack: 0, unitVolume: 0, wasPrice: nil), images: nil, menuItemSizes: nil, menuItemOptions: nil, availableDeals: nil, itemCaptions: nil)]
        let missedOfferFetch = RetailStoreMenuFetch(categories: nil, menuItems: specialOfferItems, fetchStoreId: nil, fetchCategoryId: nil, fetchFulfilmentMethod: nil, fetchFulfilmentDate: nil, fetchTimestamp: nil)
        sut.missedOffersMenuFetch = .loaded(missedOfferFetch)
        
        let expectation = expectation(description: "setupMissedPromotions")
        var cancellables = Set<AnyCancellable>()
        
        sut.$specialOfferItems
            .first()
            .receive(on: RunLoop.main)
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 5)
        
        XCTAssertEqual(sut.specialOfferItems, specialOfferItems)
    }
    
    func test_whenSearchTextIsEntered_thenSearchTriggers() {
        let container = DIContainer(appState: AppState(), eventLogger: MockedEventLogger(), services: .mocked(retailStoreMenuService: [.globalSearch(searchTerm: "Beer", scope: nil, itemsPagination: nil, categoriesPagination: nil)]))
        let sut = makeSUT(container: container)
        
        let expectation = expectation(description: "setupSearchText")
        var cancellables = Set<AnyCancellable>()
        
        sut.$searchText
            .first()
            .receive(on: RunLoop.main)
            .delay(for: 1, scheduler: RunLoop.main)
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        sut.searchText = "Beer"
        
        wait(for: [expectation], timeout: 5)
        
        container.services.verify(as: .retailStoreMenu)
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
        sut.searchText = "SomeSearch"
        
        XCTAssertTrue(sut.noSearchResult)
    }
    
    func test_whenSearchReturnsItemResultAndHasLoaded_thenNoSearchResultReturnsFalse() {
        let sut = makeSUT()
        let price = RetailStoreMenuItemPrice(price: 10, fromPrice: 10, unitMetric: "", unitsInPack: 0, unitVolume: 0, wasPrice: nil)
        let menuItems = [RetailStoreMenuItem(id: 123, name: "ResultItem", eposCode: nil, outOfStock: false, ageRestriction: 0, description: nil, quickAdd: true, acceptCustomerInstructions: false, basketQuantityLimit: 500, price: price, images: nil, menuItemSizes: nil, menuItemOptions: nil, availableDeals: nil, itemCaptions: nil)]
        
        let itemsResult = GlobalSearchItemsResult(pagination: nil, records: menuItems)
        
        sut.searchResult = .loaded(RetailStoreMenuGlobalSearch(categories: nil, menuItems: itemsResult, deals: nil, noItemFoundHint: nil, fetchStoreId: nil, fetchFulfilmentMethod: nil, fetchSearchTerm: nil, fetchSearchScope: nil, fetchTimestamp: nil, fetchItemsLimit: nil, fetchItemsPage: nil, fetchCategoriesLimit: nil, fetchCategoryPage: nil))
        
        let expectation = expectation(description: "noSearchResult")
        var cancellables = Set<AnyCancellable>()
        
        sut.$searchResultItems
            .first()
            .receive(on: RunLoop.main)
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 5)
        
        XCTAssertFalse(sut.noSearchResult)
    }
    
    func test_whenGetCategoriesTapped() {
        let storeDetails = RetailStoreDetails(id: 123, menuGroupId: 12, storeName: "", telephone: "", lat: 0, lng: 0, ordersPaused: false, canDeliver: true, distance: nil, pausedMessage: nil, address1: "", address2: nil, town: "", postcode: "", customerOrderNotePlaceholder: nil, memberEmailCheck: false, guestCheckoutAllowed: true, basketOnlyTimeSelection: false, ratings: nil, tips: nil, storeLogo: nil, storeProductTypes: nil, orderMethods: nil, deliveryDays: nil, collectionDays: nil, paymentMethods: nil, paymentGateways: nil, timeZone: nil, searchPostcode: nil)

        let container = DIContainer(appState: AppState(), eventLogger: MockedEventLogger(), services: .mocked(retailStoreMenuService: [.getRootCategories]))
        let sut = makeSUT(container: container)
        
        sut.container.appState.value.userData.selectedStore = .loaded(storeDetails)
        
        sut.getCategories()
        
        container.services.verify(as: .retailStoreMenu)
    }
    
    func test_whenSearchTapped() {
        let container = DIContainer(appState: AppState(), eventLogger: MockedEventLogger(), services: .mocked(retailStoreMenuService: [.globalSearch(searchTerm: "Milk", scope: nil, itemsPagination: nil, categoriesPagination: nil)]))
        let sut = makeSUT(container: container)
        
        sut.search(text: "Milk")
        
        container.services.verify(as: .retailStoreMenu)
    }
    
    func test_whenEditingIsTrueAndAResultCategoryIsTapped_thenIsEditingIsFalseAndItemsIsCleared() {
        let container = DIContainer(appState: AppState(), eventLogger: MockedEventLogger(), services: .mocked(retailStoreMenuService: [.getChildCategoriesAndItems(categoryId: 321)]))
        let sut = makeSUT(container: container)
        
        sut.container.appState.value.userData.selectedStore = .loaded(RetailStoreDetails(id: 123, menuGroupId: 12, storeName: "", telephone: "", lat: 0, lng: 0, ordersPaused: false, canDeliver: true, distance: nil, pausedMessage: nil, address1: "", address2: nil, town: "", postcode: "", customerOrderNotePlaceholder: nil, memberEmailCheck: false, guestCheckoutAllowed: true, basketOnlyTimeSelection: false, ratings: nil, tips: nil, storeLogo: nil, storeProductTypes: nil, orderMethods: nil, deliveryDays: nil, collectionDays: nil, paymentMethods: nil, paymentGateways: nil, timeZone: nil, searchPostcode: nil))
        
        
        sut.isEditing = true
        
        sut.items = [RetailStoreMenuItem(id: 123, name: "ItemName", eposCode: nil, outOfStock: false, ageRestriction: 0, description: nil, quickAdd: true, acceptCustomerInstructions: false, basketQuantityLimit: 500, price: RetailStoreMenuItemPrice(price: 10, fromPrice: 10, unitMetric: "", unitsInPack: 0, unitVolume: 0, wasPrice: nil), images: nil, menuItemSizes: nil, menuItemOptions: nil, availableDeals: nil, itemCaptions: nil)]
        
        sut.searchCategoryTapped(categoryID: 321)
        
        XCTAssertFalse(sut.isEditing)
        XCTAssertTrue(sut.items.isEmpty)
        
        container.services.verify(as: .retailStoreMenu)
    }
    
    func test_whenSubCategoriesAndItemsTapped() {
        let container = DIContainer(appState: AppState(), eventLogger: MockedEventLogger(), services: .mocked(retailStoreMenuService: [.getChildCategoriesAndItems(categoryId: 321)]))
        let sut = makeSUT(container: container)

        sut.container.appState.value.userData.selectedStore = .loaded(RetailStoreDetails(id: 123, menuGroupId: 12, storeName: "", telephone: "", lat: 0, lng: 0, ordersPaused: false, canDeliver: true, distance: nil, pausedMessage: nil, address1: "", address2: nil, town: "", postcode: "", customerOrderNotePlaceholder: nil, memberEmailCheck: false, guestCheckoutAllowed: true, basketOnlyTimeSelection: false, ratings: nil, tips: nil, storeLogo: nil, storeProductTypes: nil, orderMethods: nil, deliveryDays: nil, collectionDays: nil, paymentMethods: nil, paymentGateways: nil, timeZone: nil, searchPostcode: nil))

        sut.categoryTapped(with: 321)
        
        container.services.verify(as: .retailStoreMenu)
    }
    
    func test_missedOffer() {
        let container = DIContainer(appState: AppState(), eventLogger: MockedEventLogger(), services: .mocked(retailStoreMenuService: [.getChildCategoriesAndItems(categoryId: 321)]))
        let sut = makeSUT(container: container, missedOffer: BasketItemMissedPromotion(referenceId: 123, name: "Test missed promo", type: .multiSectionDiscount, missedSections: nil))
        XCTAssertEqual(sut.missedOffer?.referenceId, 123)
        XCTAssertEqual(sut.offerText, "Test missed promo")
    }
    
    func test_whenSpecialOfferPillTappedTapped() {
        let container = DIContainer(appState: AppState(), eventLogger: MockedEventLogger(), services: .mocked(retailStoreMenuService: [.getItems(menuItemIds: nil, discountId: 321, discountSectionId: nil)]))
        let sut = makeSUT(container: container)

        sut.container.appState.value.userData.selectedStore = .loaded(RetailStoreDetails(id: 123, menuGroupId: 12, storeName: "", telephone: "", lat: 0, lng: 0, ordersPaused: false, canDeliver: true, distance: nil, pausedMessage: nil, address1: "", address2: nil, town: "", postcode: "", customerOrderNotePlaceholder: nil, memberEmailCheck: false, guestCheckoutAllowed: true, basketOnlyTimeSelection: false, ratings: nil, tips: nil, storeLogo: nil, storeProductTypes: nil, orderMethods: nil, deliveryDays: nil, collectionDays: nil, paymentMethods: nil, paymentGateways: nil, timeZone: nil, searchPostcode: nil))

        sut.specialOfferPillTapped(offer: RetailStoreMenuItemAvailableDeal(id: 321, name: "Test offer", type: ""))
        
        XCTAssertEqual(sut.offerText, "Test offer")

        container.services.verify(as: .retailStoreMenu)
    }
    
    func test_whenClearStateTapped_thenAllIsLCleared() {
        let sut = makeSUT()
        
        sut.subcategoriesOrItemsMenuFetch = .loaded(RetailStoreMenuFetch(categories: nil, menuItems: nil, fetchStoreId: nil, fetchCategoryId: nil, fetchFulfilmentMethod: nil, fetchFulfilmentDate: nil, fetchTimestamp: nil))
        sut.rootCategoriesMenuFetch = .loaded(RetailStoreMenuFetch(categories: nil, menuItems: nil, fetchStoreId: nil, fetchCategoryId: nil, fetchFulfilmentMethod: nil, fetchFulfilmentDate: nil, fetchTimestamp: nil))
        sut.specialOffersMenuFetch = .loaded(RetailStoreMenuFetch(categories: nil, menuItems: nil, fetchStoreId: nil, fetchCategoryId: nil, fetchFulfilmentMethod: nil, fetchFulfilmentDate: nil, fetchTimestamp: nil))

        sut.rootCategories = [RetailStoreMenuCategory(id: 123, parentId: 321, name: "", image: nil, description: "")]
        sut.subCategories = [RetailStoreMenuCategory(id: 123, parentId: 321, name: "", image: nil, description: "")]
        sut.items = [RetailStoreMenuItem(id: 123, name: "ItemName", eposCode: nil, outOfStock: false, ageRestriction: 0, description: nil, quickAdd: true, acceptCustomerInstructions: false, basketQuantityLimit: 500, price: RetailStoreMenuItemPrice(price: 10, fromPrice: 10, unitMetric: "", unitsInPack: 0, unitVolume: 0, wasPrice: nil), images: nil, menuItemSizes: nil, menuItemOptions: nil, availableDeals: nil, itemCaptions: nil)]
        sut.specialOfferItems = [RetailStoreMenuItem(id: 123, name: "ItemName", eposCode: nil, outOfStock: false, ageRestriction: 0, description: nil, quickAdd: true, acceptCustomerInstructions: false, basketQuantityLimit: 500, price: RetailStoreMenuItemPrice(price: 10, fromPrice: 10, unitMetric: "", unitsInPack: 0, unitVolume: 0, wasPrice: nil), images: nil, menuItemSizes: nil, menuItemOptions: nil, availableDeals: nil, itemCaptions: nil)]
        
        sut.selectedOffer = RetailStoreMenuItemAvailableDeal(id: 123, name: "", type: "")
        
        sut.clearState()
        
        XCTAssertEqual(sut.subcategoriesOrItemsMenuFetch, .notRequested)
        XCTAssertEqual(sut.rootCategoriesMenuFetch, .notRequested)
        XCTAssertEqual(sut.specialOffersMenuFetch, .notRequested)
        XCTAssertTrue(sut.items.isEmpty)
        XCTAssertTrue(sut.subCategories.isEmpty)
        XCTAssertTrue(sut.rootCategories.isEmpty)
        XCTAssertTrue(sut.specialOfferItems.isEmpty)
        XCTAssertNil(sut.selectedOffer)
    }
    
    func test_whenIsEditingIsTrue_thenShowBackButtonReturnsFalse() {
        let sut = makeSUT()
        sut.subCategories = [RetailStoreMenuCategory(id: 123, parentId: 312, name: "SomeName", image: nil, description: "")]
        sut.isEditing = true
        
        XCTAssertFalse(sut.showBackButton)
    }
    
    func test_whenViewStateIsNotRootCategories_thenShowBackButtonReturnsTrue() {
        let sut = makeSUT()
        sut.subCategories = [RetailStoreMenuCategory(id: 123, parentId: 312, name: "SomeName", image: nil, description: "")]
        
        XCTAssertTrue(sut.showBackButton)
    }
    
    func test_whenCancelSearchButtonTapped_thenSearchResultCleared() {
        let sut = makeSUT()
        sut.searchResult = .loaded(RetailStoreMenuGlobalSearch(categories: nil, menuItems: nil, deals: nil, noItemFoundHint: nil, fetchStoreId: nil, fetchFulfilmentMethod: nil, fetchSearchTerm: nil, fetchSearchScope: nil, fetchTimestamp: nil, fetchItemsLimit: nil, fetchItemsPage: nil, fetchCategoriesLimit: nil, fetchCategoryPage: nil))
        
        sut.cancelSearchButtonTapped()
        
        XCTAssertEqual(sut.searchResult, .notRequested)
    }
    
    func test_whenSearchResultCategoriesAndSearchTextArePopulated_thenShowSearchResultCategoriesReturnsTrue() {
        let sut = makeSUT()
        
        sut.searchResultCategories = [GlobalSearchResultRecord(id: 123, name: "SomeCategory", image: nil, price: nil)]
        sut.searchText = "someSearch"
        
        XCTAssertTrue(sut.showSearchResultCategories)
    }
    
    func test_whenSearchResultItemsAndSearchTextArePopulated_thenShowSearchResultItemsReturnsTrue() {
        let sut = makeSUT()
        
        sut.searchResultItems = [RetailStoreMenuItem(id: 123, name: "SearchItem", eposCode: nil, outOfStock: false, ageRestriction: 0, description: nil, quickAdd: true, acceptCustomerInstructions: false, basketQuantityLimit: 500, price: RetailStoreMenuItemPrice(price: 10, fromPrice: 10, unitMetric: "", unitsInPack: 0, unitVolume: 0, wasPrice: nil), images: nil, menuItemSizes: nil, menuItemOptions: nil, availableDeals: nil, itemCaptions: nil)]
        sut.searchText = "someSearch"
        
        XCTAssertTrue(sut.showSearchResultItems)
    }
    
    func test_whenItemsSplit_thenNestedArrayReceived() {
        let sut = makeSUT()
        let items = [
            RetailStoreMenuItem.mockedData,
            RetailStoreMenuItem.mockedData,
            RetailStoreMenuItem.mockedData,
            RetailStoreMenuItem.mockedData,
            RetailStoreMenuItem.mockedData,
            RetailStoreMenuItem.mockedData,
            RetailStoreMenuItem.mockedData
        ]
        
        let splitItems = sut.splitItems(storeItems: items, into: 2)
        
        XCTAssertEqual(splitItems, [
            [RetailStoreMenuItem.mockedData, RetailStoreMenuItem.mockedData],
            [RetailStoreMenuItem.mockedData, RetailStoreMenuItem.mockedData],
            [RetailStoreMenuItem.mockedData, RetailStoreMenuItem.mockedData],
            [RetailStoreMenuItem.mockedData]
        ])
    }

    func makeSUT(container: DIContainer = DIContainer(appState: AppState(), eventLogger: MockedEventLogger(), services: .mocked()), missedOffer: BasketItemMissedPromotion? = nil) -> ProductsViewModel {
        let sut = ProductsViewModel(container: container, missedOffer: missedOffer)
        
        trackForMemoryLeaks(sut)
        
        return sut
    }
}
