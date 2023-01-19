//
//  RetailStoreMenuServiceTests.swift
//  SnappyV2Tests
//
//  Created by Henrik Gustavii on 03/06/2022.
//

import XCTest
import Combine

// 3rd party
import AppsFlyerLib
import Firebase

@testable import SnappyV2

class RetailStoreMenuServiceTests: XCTestCase {
    
    var appState = CurrentValueSubject<AppState, Never>(AppState())
    var mockedEventLogger: MockedEventLogger!
    var mockedWebRepo: MockedRetailStoreMenuWebRepository!
    var mockedDBRepo: MockedRetailStoreMenuDBRepository!
    var mockedSearchHistoryDB: MockedSearchHistoryDBRepository!
    var subscriptions = Set<AnyCancellable>()
    var sut: RetailStoreMenuService!
    
    override func setUp() {
        mockedEventLogger = MockedEventLogger()
        mockedWebRepo = MockedRetailStoreMenuWebRepository()
        mockedDBRepo = MockedRetailStoreMenuDBRepository()
        mockedSearchHistoryDB = MockedSearchHistoryDBRepository()
        sut = RetailStoreMenuService(
            webRepository: mockedWebRepo,
            dbRepository: mockedDBRepo,
            appState: appState,
            eventLogger: mockedEventLogger
        )
    }
    
    override func tearDown() {
        appState = CurrentValueSubject<AppState, Never>(AppState())
        subscriptions = Set<AnyCancellable>()
        mockedEventLogger = nil
        mockedWebRepo = nil
        mockedDBRepo = nil
        sut = nil
    }
}

// MARK: - func getChildCategoriesAndItems(menuFetch:, categoryId:)
final class GetChildCategoriesAndItems: RetailStoreMenuServiceTests {
    func test_whenSuccessfulCategoriesResult_thenReturnCategories() {
        
        let menuFetchResult = RetailStoreMenuFetch.mockedDataFromAPI
        let store = RetailStoreDetails.mockedData
        appState.value.userData.selectedStore = .loaded(store)
        let dateString = appState.value.userData.selectedStore.value?.storeDateToday()
        let fulfilmentMethod: RetailStoreOrderMethodType = .delivery
        appState.value.userData.selectedFulfilmentMethod = fulfilmentMethod
        
        let storedMenuFetchResult = RetailStoreMenuFetch(
            id: menuFetchResult.id ?? 0,
            name: menuFetchResult.name ?? "",
            discountText: nil,
            categories: menuFetchResult.categories,
            menuItems: menuFetchResult.menuItems,
            dealSections: menuFetchResult.dealSections,
            fetchStoreId: store.id,
            fetchCategoryId: 0,
            fetchFulfilmentMethod: fulfilmentMethod,
            fetchFulfilmentDate: dateString,
            fetchTimestamp: Date()
        )
        
        // Configuring expected actions on repositories and events
        
        mockedWebRepo.actions = .init(
            expected: [.loadRetailStoreMenuSubCategoriesAndItems(storeId: store.id, categoryId: 0, fulfilmentMethod: .delivery, fulfilmentDate: nil)]
        )
        
        mockedDBRepo.actions = .init(
            expected: [
                .clearRetailStoreMenuFetch(forStoreId: store.id, categoryId: 0, fulfilmentMethod: fulfilmentMethod, fulfilmentDate: dateString),
                .store(fetchResult: menuFetchResult, forStoreId: store.id, categoryId: 0, fulfilmentMethod: fulfilmentMethod, fulfilmentDate: dateString)
            ]
        )
        
        let appsFlyerParams: [String: Any] = [
            "category_id": 0,
            AFEventParamContentType: menuFetchResult.name!,
            AFEventParamQuantity: menuFetchResult.categories!.count,
            "category_type": "child"
        ]
        let iterableParams: [String: Any] = [
            "categoryId": 0,
            "name": menuFetchResult.name!,
            "storeId": store.id
        ]
        let firebaseParams: [String: Any] = [
            "category_id": 0,
            "category_name": menuFetchResult.name!
        ]
        mockedEventLogger.actions = .init(expected: [
            .sendEvent(for: .viewCategoryList, with: .appsFlyer, params: appsFlyerParams),
            .sendEvent(for: .viewCategoryList, with: .iterable, params: iterableParams),
            .sendEvent(for: .viewCategoryList, with: .firebaseAnalytics, params: firebaseParams)
        ])
        
        // Configuring responses from repositories
        
        mockedWebRepo.loadRetailStoreMenuSubCategoriesAndItemsResponse = .success(menuFetchResult)
        mockedDBRepo.clearRetailStoreMenuFetchResponse = .success(true)
        mockedDBRepo.storeCategoryResponse = .success(storedMenuFetchResult)
        
        let exp = expectation(description: #function)
        
        let result = BindingWithPublisher(value: Loadable<RetailStoreMenuFetch>.notRequested)
        sut.getChildCategoriesAndItems(menuFetch: result.binding, categoryId: 0)
        result.updatesRecorder.sink { updates in
            XCTAssertEqual(updates, [
                .notRequested,
                .isLoading(last: nil, cancelBag: CancelBag()),
                .loaded(storedMenuFetchResult)
            ])
            self.mockedWebRepo.verify()
            self.mockedDBRepo.verify()
            self.mockedEventLogger.verify()
            exp.fulfill()
        }
        .store(in: &subscriptions)
        
        wait(for: [exp], timeout: 2)
    }
    
    func test_whenSuccessfulCategoriesResult_givenJustItems_thenReturnCategories() {
        
        let menuFetchResult = RetailStoreMenuFetch.mockedDataItems
        let store = RetailStoreDetails.mockedData
        appState.value.userData.selectedStore = .loaded(store)
        let dateString = appState.value.userData.selectedStore.value?.storeDateToday()
        let fulfilmentMethod: RetailStoreOrderMethodType = .delivery
        appState.value.userData.selectedFulfilmentMethod = fulfilmentMethod
        
        let storedMenuFetchResult = RetailStoreMenuFetch(
            id: menuFetchResult.id ?? 0,
            name: menuFetchResult.name ?? "",
            discountText: nil,
            categories: menuFetchResult.categories,
            menuItems: menuFetchResult.menuItems,
            dealSections: menuFetchResult.dealSections,
            fetchStoreId: store.id,
            fetchCategoryId: 0,
            fetchFulfilmentMethod: fulfilmentMethod,
            fetchFulfilmentDate: dateString,
            fetchTimestamp: Date()
        )
        
        // Configuring expected actions on repositories and events
        
        mockedWebRepo.actions = .init(
            expected: [.loadRetailStoreMenuSubCategoriesAndItems(storeId: store.id, categoryId: 0, fulfilmentMethod: .delivery, fulfilmentDate: nil)]
        )
        
        mockedDBRepo.actions = .init(
            expected: [
                .clearRetailStoreMenuFetch(forStoreId: store.id, categoryId: 0, fulfilmentMethod: fulfilmentMethod, fulfilmentDate: dateString),
                .store(fetchResult: menuFetchResult, forStoreId: store.id, categoryId: 0, fulfilmentMethod: fulfilmentMethod, fulfilmentDate: dateString)
            ]
        )
        
        let appsFlyerParams: [String: Any] = [
            "category_id": 0,
            AFEventParamContentType: menuFetchResult.name!,
            AFEventParamQuantity: menuFetchResult.menuItems?.count ?? 0,
            "category_type": "items"
        ]
        let iterableParams: [String: Any] = [
            "categoryId": 0,
            "name": menuFetchResult.name!,
            "storeId": store.id
        ]
        let firebaseParams: [String: Any] = [
            "category_id": 0,
            "category_name": menuFetchResult.name!
        ]
        mockedEventLogger.actions = .init(expected: [
            .sendEvent(for: .viewCategoryList, with: .appsFlyer, params: appsFlyerParams),
            .sendEvent(for: .viewCategoryList, with: .iterable, params: iterableParams),
            .sendEvent(for: .viewProductList, with: .firebaseAnalytics, params: firebaseParams)
        ])
        
        // Configuring responses from repositories
        
        mockedWebRepo.loadRetailStoreMenuSubCategoriesAndItemsResponse = .success(menuFetchResult)
        mockedDBRepo.clearRetailStoreMenuFetchResponse = .success(true)
        mockedDBRepo.storeCategoryResponse = .success(storedMenuFetchResult)
        
        let exp = expectation(description: #function)
        
        let result = BindingWithPublisher(value: Loadable<RetailStoreMenuFetch>.notRequested)
        sut.getChildCategoriesAndItems(menuFetch: result.binding, categoryId: 0)
        result.updatesRecorder.sink { updates in
            XCTAssertEqual(updates, [
                .notRequested,
                .isLoading(last: nil, cancelBag: CancelBag()),
                .loaded(storedMenuFetchResult)
            ])
            self.mockedWebRepo.verify()
            self.mockedDBRepo.verify()
            self.mockedEventLogger.verify()
            exp.fulfill()
        }
        .store(in: &subscriptions)
        
        wait(for: [exp], timeout: 2)
    }
    
    func test_whenNoStoreIsSelected_thenReturnError() {
        
        let exp = expectation(description: #function)
        
        let result = BindingWithPublisher(value: Loadable<RetailStoreMenuFetch>.notRequested)
        sut.getChildCategoriesAndItems(menuFetch: result.binding, categoryId: 0)
        
        result.updatesRecorder.sink { updates  in
            XCTAssertEqual(updates, [
                .notRequested,
                .isLoading(last: nil, cancelBag: CancelBag()),
                .failed(RetailStoreMenuServiceError.noSelectedStore)
            ])
            self.mockedWebRepo.verify()
            self.mockedDBRepo.verify()
            self.mockedEventLogger.verify()
            exp.fulfill()
        }.store(in: &subscriptions)
        
        wait(for: [exp], timeout: 2)
    }
    
    func test_whenWebErrorAndInDB_thenReturnCorrectCacheResult() {
        
        let networkError = NSError(domain: NSURLErrorDomain, code: -1009, userInfo: [:])
        let menuFetchResult = RetailStoreMenuFetch.mockedDataFromAPI
        let store = RetailStoreDetails.mockedData
        appState.value.userData.selectedStore = .loaded(store)
        let dateString = appState.value.userData.selectedStore.value?.storeDateToday()
        let fulfilmentMethod: RetailStoreOrderMethodType = .delivery
        appState.value.userData.selectedFulfilmentMethod = fulfilmentMethod
        
        let storedMenuFetchResult = RetailStoreMenuFetch(
            id: menuFetchResult.id ?? 0,
            name: menuFetchResult.name ?? "",
            discountText: nil,
            categories: menuFetchResult.categories,
            menuItems: menuFetchResult.menuItems,
            dealSections: menuFetchResult.dealSections,
            fetchStoreId: store.id,
            fetchCategoryId: 0,
            fetchFulfilmentMethod: fulfilmentMethod,
            fetchFulfilmentDate: dateString,
            fetchTimestamp: Date()
        )
        
        // Configuring expected actions on repositories and events
        
        mockedWebRepo.actions = .init(expected: [.loadRetailStoreMenuSubCategoriesAndItems(storeId: store.id, categoryId: 0, fulfilmentMethod: .delivery, fulfilmentDate: nil)])
        
        mockedDBRepo.actions = .init(expected: [.retailStoreMenuFetch(forStoreId: store.id, categoryId: 0, fulfilmentMethod: .delivery, fulfilmentDate: Date().dateOnlyString(storeTimeZone: nil))])
        
        let appsFlyerParams: [String: Any] = [
            "category_id": 0,
            AFEventParamContentType: menuFetchResult.name!,
            AFEventParamQuantity: menuFetchResult.categories!.count,
            "category_type": "child"
        ]
        let iterableParams: [String: Any] = [
            "categoryId": 0,
            "name": menuFetchResult.name!,
            "storeId": store.id
        ]
        let firebaseParams: [String: Any] = [
            "category_id": 0,
            "category_name": menuFetchResult.name!
        ]
        mockedEventLogger.actions = .init(expected: [
            .sendEvent(for: .viewCategoryList, with: .appsFlyer, params: appsFlyerParams),
            .sendEvent(for: .viewCategoryList, with: .iterable, params: iterableParams),
            .sendEvent(for: .viewCategoryList, with: .firebaseAnalytics, params: firebaseParams)
        ])
        
        // Configuring responses from repositories
        
        mockedWebRepo.loadRetailStoreMenuSubCategoriesAndItemsResponse = .failure(networkError)
        mockedDBRepo.retailStoreMenuFetchResponse = .success(storedMenuFetchResult)
        
        let exp = expectation(description: #function)
        
        let result = BindingWithPublisher(value: Loadable<RetailStoreMenuFetch>.notRequested)
        sut.getChildCategoriesAndItems(menuFetch: result.binding, categoryId: 0)
        result.updatesRecorder.sink { updates in
            XCTAssertEqual(updates, [
                .notRequested,
                .isLoading(last: nil, cancelBag: CancelBag()),
                .loaded(storedMenuFetchResult)
            ])
            self.mockedWebRepo.verify()
            self.mockedDBRepo.verify()
            self.mockedEventLogger.verify()
            exp.fulfill()
        }
        .store(in: &subscriptions)
        
        wait(for: [exp], timeout: 2)
    }
    
    func test_whenWebErrorAndInDBButExpired_thenReturnError() {
        
        let expiredDate = Calendar.current.date(byAdding: .hour, value: -12, to: AppV2Constants.Business.retailStoreMenuCachedExpiry)
        let networkError = NSError(domain: NSURLErrorDomain, code: -1009, userInfo: [:])
        let menuFetchResult = RetailStoreMenuFetch.mockedDataFromAPI
        let store = RetailStoreDetails.mockedData
        appState.value.userData.selectedStore = .loaded(store)
        let dateString = appState.value.userData.selectedStore.value?.storeDateToday()
        let fulfilmentMethod: RetailStoreOrderMethodType = .delivery
        appState.value.userData.selectedFulfilmentMethod = fulfilmentMethod
        
        let storedMenuFetchResult = RetailStoreMenuFetch(
            id: menuFetchResult.id ?? 0,
            name: menuFetchResult.name ?? "",
            discountText: nil,
            categories: menuFetchResult.categories,
            menuItems: menuFetchResult.menuItems,
            dealSections: menuFetchResult.dealSections,
            fetchStoreId: store.id,
            fetchCategoryId: 0,
            fetchFulfilmentMethod: fulfilmentMethod,
            fetchFulfilmentDate: dateString,
            fetchTimestamp: expiredDate
        )
        
        // Configuring expected actions on repositories and events
        
        mockedWebRepo.actions = .init(expected: [.loadRetailStoreMenuSubCategoriesAndItems(storeId: store.id, categoryId: 0, fulfilmentMethod: .delivery, fulfilmentDate: nil)])
        
        mockedDBRepo.actions = .init(expected: [.retailStoreMenuFetch(forStoreId: store.id, categoryId: 0, fulfilmentMethod: .delivery, fulfilmentDate: dateString)])
        
        // Configuring responses from repositories
        
        mockedWebRepo.loadRetailStoreMenuSubCategoriesAndItemsResponse = .failure(networkError)
        mockedDBRepo.retailStoreMenuFetchResponse = .success(storedMenuFetchResult)
        
        let exp = expectation(description: #function)
        
        let result = BindingWithPublisher(value: Loadable<RetailStoreMenuFetch>.notRequested)
        sut.getChildCategoriesAndItems(menuFetch: result.binding, categoryId: 0)
        result.updatesRecorder.sink { updates in
            XCTAssertEqual(updates, [
                .notRequested,
                .isLoading(last: nil, cancelBag: CancelBag()),
                .failed(networkError)
            ])
            self.mockedWebRepo.verify()
            self.mockedDBRepo.verify()
            self.mockedEventLogger.verify()
            exp.fulfill()
        }
        .store(in: &subscriptions)
        
        wait(for: [exp], timeout: 2)
    }
    
    func test_whenWebErrorAndInNotInDB_thenReturnError() {
        
        let networkError = NSError(domain: NSURLErrorDomain, code: -1009, userInfo: [:])
        let store = RetailStoreDetails.mockedData
        appState.value.userData.selectedStore = .loaded(store)
        let dateString = appState.value.userData.selectedStore.value?.storeDateToday()
        let fulfilmentMethod: RetailStoreOrderMethodType = .delivery
        appState.value.userData.selectedFulfilmentMethod = fulfilmentMethod
        
        // Configuring expected actions on repositories and events
        
        mockedWebRepo.actions = .init(expected: [.loadRetailStoreMenuSubCategoriesAndItems(storeId: store.id, categoryId: 0, fulfilmentMethod: .delivery, fulfilmentDate: nil)])
        
        mockedDBRepo.actions = .init(expected: [.retailStoreMenuFetch(forStoreId: store.id, categoryId: 0, fulfilmentMethod: .delivery, fulfilmentDate: dateString)])
        
        // Configuring responses from repositories
        
        mockedWebRepo.loadRetailStoreMenuSubCategoriesAndItemsResponse = .failure(networkError)
        mockedDBRepo.retailStoreMenuFetchResponse = .success(nil)
        
        let exp = expectation(description: #function)
        
        let result = BindingWithPublisher(value: Loadable<RetailStoreMenuFetch>.notRequested)
        sut.getChildCategoriesAndItems(menuFetch: result.binding, categoryId: 0)
        result.updatesRecorder.sink { updates in
            XCTAssertEqual(updates, [
                .notRequested,
                .isLoading(last: nil, cancelBag: CancelBag()),
                .failed(networkError)
            ])
            self.mockedWebRepo.verify()
            self.mockedDBRepo.verify()
            self.mockedEventLogger.verify()
            exp.fulfill()
        }
        .store(in: &subscriptions)
        
        wait(for: [exp], timeout: 2)
    }
}

// MARK: - func globalSearch(searchFetch:searchTerm:scope:itemsPagination:categoriesPagination:)
final class GlobalSearchTests: RetailStoreMenuServiceTests {
    
    func test_whenSuccessfulSearch_thenReturnCorrectResult() async {
        
        let searchTerm = "Bags"
        
        let searchResult = RetailStoreMenuGlobalSearch.mockedDataFromAPI
        let selectedStore = RetailStoreDetails.mockedData
        sut.appState.value.userData.selectedStore = .loaded(selectedStore)
        
        // Configuring expected actions on repositories and events
        
        mockedWebRepo.actions = .init(expected: [.globalSearch(storeId: selectedStore.id, fulfilmentMethod: .delivery, searchTerm: searchTerm)])
        mockedDBRepo.actions = .init(expected: [.clearGlobalSearch(forStoreId: selectedStore.id, fulfilmentMethod: .delivery, searchTerm: searchTerm), .store(fetchResult: searchResult, forStoreId: selectedStore.id, fulfilmentMethod: .delivery, searchTerm: searchTerm)])
        
        let appsFlyerParams: [String: Any] = [
            AFEventParamSearchString: searchTerm,
            "category_names": ["Bags", "Bags & Wrap", "Bags & Wrap"],
            "item_names":["Basket limit conflict", "Option Grid Max(2) Min (0) Mutually Exclusive (true)"],
            "deal_names": []
        ]
        let firebaseParams: [String: Any] = [
            AnalyticsParameterSearchTerm: searchTerm
        ]
        mockedEventLogger.actions = .init(
            expected: [
                .sendEvent(for: .search, with: .appsFlyer, params: appsFlyerParams),
                .sendEvent(for: .search, with: .firebaseAnalytics, params: firebaseParams)
            ]
        )
        
        // Configuring responses from repositories
        
        mockedWebRepo.globalSearchResponse = .success(searchResult)
        mockedDBRepo.clearGlobalSearchResponse = .success(true)
        mockedDBRepo.storeSearchResponse = .success(searchResult)
        
        do {
            let result = try await sut.globalSearch(
                searchTerm: searchTerm,
                scope: nil,
                itemsPagination: nil,
                categoriesPagination: nil
            )
            
            XCTAssertEqual(result, searchResult)
        } catch {
            XCTFail()
        }
        
        self.mockedWebRepo.verify()
        self.mockedDBRepo.verify()
        self.mockedEventLogger.verify()
    }
    
    func test_whenNoStoreIsSelected_thenReturnError() async {
        do {
            let _ = try await sut.globalSearch(
                searchTerm: "Bags",
                scope: nil,
                itemsPagination: nil,
                categoriesPagination: nil
            )
            XCTFail("Expected failure, received success")
            
        } catch {
            XCTAssertEqual(error.localizedDescription, RetailStoreMenuServiceError.unableToSearch.localizedDescription)
        }
        self.mockedWebRepo.verify()
        self.mockedDBRepo.verify()
        self.mockedEventLogger.verify()
    }
    
    func test_whenWebErrorGetItemsForDeliveryAndInDB_thenReturnCorrectCacheResult() async {
        
        let networkError = NSError(domain: NSURLErrorDomain, code: -1009, userInfo: [:])
        let searchTerm = "Bags"
        let fulfilmentMethod: RetailStoreOrderMethodType = .delivery
        appState.value.userData.selectedFulfilmentMethod = fulfilmentMethod
        let selectedStore = RetailStoreDetails.mockedData
        sut.appState.value.userData.selectedStore = .loaded(selectedStore)
        
        let searchResult = RetailStoreMenuGlobalSearch.mockedDataFromAPI
        
        let storedSearchResult = RetailStoreMenuGlobalSearch(
            categories: searchResult.categories,
            menuItems: searchResult.menuItems,
            deals: searchResult.deals,
            noItemFoundHint: searchResult.noItemFoundHint,
            fetchStoreId: selectedStore.id,
            fetchFulfilmentMethod: fulfilmentMethod,
            fetchSearchTerm: searchTerm,
            fetchSearchScope: nil,
            fetchTimestamp: Date(),
            fetchItemsLimit: nil,
            fetchItemsPage: nil,
            fetchCategoriesLimit: nil,
            fetchCategoryPage: nil
        )
        
        // Configuring expected actions on repositories and events
        
        mockedWebRepo.actions = .init(expected: [.globalSearch(storeId: selectedStore.id, fulfilmentMethod: fulfilmentMethod, searchTerm: searchTerm)])
        mockedDBRepo.actions = .init(expected: [.retailStoreMenuGlobalSearch(forStoreId: selectedStore.id, fulfilmentMethod: fulfilmentMethod, searchTerm: searchTerm)])
        
        let appsFlyerParams: [String: Any] = [
            AFEventParamSearchString: searchTerm,
            "category_names": ["Bags", "Bags & Wrap", "Bags & Wrap"],
            "item_names":["Basket limit conflict", "Option Grid Max(2) Min (0) Mutually Exclusive (true)"],
            "deal_names": []
        ]
        let firebaseParams: [String: Any] = [
            AnalyticsParameterSearchTerm: searchTerm
        ]
        mockedEventLogger.actions = .init(
            expected: [
                .sendEvent(for: .search, with: .appsFlyer, params: appsFlyerParams),
                .sendEvent(for: .search, with: .firebaseAnalytics, params: firebaseParams)
            ]
        )
        
        // Configuring responses from repositories
        
        mockedWebRepo.globalSearchResponse = .failure(networkError)
        mockedDBRepo.retailStoreMenuGlobalSearchResponse = .success(storedSearchResult)
        
        do {
            let result = try await sut.globalSearch(
                searchTerm: searchTerm,
                scope: nil,
                itemsPagination: nil,
                categoriesPagination: nil
            )
            XCTAssertEqual(result, storedSearchResult)
        } catch {
            XCTFail()
        }
        
        self.mockedWebRepo.verify()
        self.mockedDBRepo.verify()
        self.mockedEventLogger.verify()
    }
    
    func test_whenWebErrorGetItemsForDeliveryAndInDBButExpired_thenReturnError() async {
        let networkError = NSError(domain: NSURLErrorDomain, code: -1009, userInfo: [:])
        let searchTerm = "Bags"
        let fulfilmentMethod: RetailStoreOrderMethodType = .delivery
        appState.value.userData.selectedFulfilmentMethod = fulfilmentMethod
        let selectedStore = RetailStoreDetails.mockedData
        sut.appState.value.userData.selectedStore = .loaded(selectedStore)
        
        let searchResult = RetailStoreMenuGlobalSearch.mockedDataFromAPI
        
        let storedSearchResult = RetailStoreMenuGlobalSearch(
            categories: searchResult.categories,
            menuItems: searchResult.menuItems,
            deals: searchResult.deals,
            noItemFoundHint: searchResult.noItemFoundHint,
            fetchStoreId: selectedStore.id,
            fetchFulfilmentMethod: fulfilmentMethod,
            fetchSearchTerm: searchTerm,
            fetchSearchScope: nil,
            fetchTimestamp: Date(),
            fetchItemsLimit: nil,
            fetchItemsPage: nil,
            fetchCategoriesLimit: nil,
            fetchCategoryPage: nil
        )
        
        // Configuring expected actions on repositories and events
        
        mockedWebRepo.actions = .init(expected: [.globalSearch(storeId: selectedStore.id, fulfilmentMethod: fulfilmentMethod, searchTerm: searchTerm)])
        mockedDBRepo.actions = .init(expected: [.retailStoreMenuGlobalSearch(forStoreId: selectedStore.id, fulfilmentMethod: fulfilmentMethod, searchTerm: searchTerm)])
        
        let appsFlyerParams: [String: Any] = [
            AFEventParamSearchString: searchTerm,
            "category_names": ["Bags", "Bags & Wrap", "Bags & Wrap"],
            "item_names":["Basket limit conflict", "Option Grid Max(2) Min (0) Mutually Exclusive (true)"],
            "deal_names": []
        ]
        let firebaseParams: [String: Any] = [
            AnalyticsParameterSearchTerm: searchTerm
        ]
        mockedEventLogger.actions = .init(
            expected: [
                .sendEvent(for: .search, with: .appsFlyer, params: appsFlyerParams),
                .sendEvent(for: .search, with: .firebaseAnalytics, params: firebaseParams)
            ]
        )
        
        // Configuring responses from repositories
        
        mockedWebRepo.globalSearchResponse = .failure(networkError)
        mockedDBRepo.retailStoreMenuGlobalSearchResponse = .success(storedSearchResult)
        
        do {
            let result = try await sut.globalSearch(
                searchTerm: searchTerm,
                scope: nil,
                itemsPagination: nil,
                categoriesPagination: nil
            )
            XCTAssertEqual(result, storedSearchResult)
        } catch {
            XCTFail()
        }
        
        self.mockedWebRepo.verify()
        self.mockedDBRepo.verify()
        self.mockedEventLogger.verify()
    }
    
    func test_whenWebErrorGetItemsForDeliveryAndInNotInDB_thenReturnError() async {
        let networkError = NSError(domain: NSURLErrorDomain, code: -1009, userInfo: [:])
        let searchTerm = "Bags"
        let fulfilmentMethod: RetailStoreOrderMethodType = .delivery
        appState.value.userData.selectedFulfilmentMethod = fulfilmentMethod
        let selectedStore = RetailStoreDetails.mockedData
        sut.appState.value.userData.selectedStore = .loaded(selectedStore)
        
        // Configuring expected actions on repositories and events
        
        mockedWebRepo.actions = .init(expected: [.globalSearch(storeId: selectedStore.id, fulfilmentMethod: fulfilmentMethod, searchTerm: searchTerm)])
        mockedDBRepo.actions = .init(expected: [.retailStoreMenuGlobalSearch(forStoreId: selectedStore.id, fulfilmentMethod: fulfilmentMethod, searchTerm: searchTerm)])
        
        // Configuring responses from repositories
        
        mockedWebRepo.globalSearchResponse = .failure(networkError)
        mockedDBRepo.retailStoreMenuGlobalSearchResponse = .success(nil)
        
        do {
            let result = try await  sut.globalSearch(
                searchTerm: searchTerm,
                scope: nil,
                itemsPagination: nil,
                categoriesPagination: nil
            )
            XCTFail("Expected error, received success")
        } catch {
            XCTAssertEqual(error.localizedDescription, networkError.localizedDescription)
        }
        self.mockedWebRepo.verify()
        self.mockedDBRepo.verify()
        self.mockedEventLogger.verify()
    }
}

// MARK: - func getRootCategories(menuFetch:)
final class GetRootCategoriesTests: RetailStoreMenuServiceTests {
    func test_whenSuccessfulGetRootCategoriesForDelivery_thenReturnCorrectResult() {
        
        let store = RetailStoreDetails.mockedData
        appState.value.userData.selectedStore = .loaded(store)
        let dateString = appState.value.userData.selectedStore.value?.storeDateToday()
        let fulfilmentMethod: RetailStoreOrderMethodType = .delivery
        appState.value.userData.selectedFulfilmentMethod = fulfilmentMethod
        let menuFetchResult = RetailStoreMenuFetch.mockedDataCategoriesFromAPI
        
        let storedMenuFetchResult = RetailStoreMenuFetch(
            id: menuFetchResult.id ?? 0,
            name: menuFetchResult.name ?? "",
            discountText: nil,
            categories: menuFetchResult.categories,
            menuItems: menuFetchResult.menuItems,
            dealSections: menuFetchResult.dealSections,
            fetchStoreId: store.id,
            fetchCategoryId: 0,
            fetchFulfilmentMethod: fulfilmentMethod,
            fetchFulfilmentDate: dateString,
            fetchTimestamp: Date()
        )
        
        // Configuring expected actions on repositories and events
        
        mockedWebRepo.actions = .init(expected: [
            .loadRootRetailStoreMenuCategories(
                storeId: store.id,
                fulfilmentMethod: fulfilmentMethod,
                fulfilmentDate: nil
            )
        ])
        
        mockedDBRepo.actions = .init(expected: [
            .clearRetailStoreMenuFetch(
                forStoreId: store.id,
                categoryId: 0,
                fulfilmentMethod: fulfilmentMethod,
                fulfilmentDate: dateString
            ),
            .store(
                fetchResult: menuFetchResult,
                forStoreId: store.id,
                categoryId: 0,
                fulfilmentMethod: fulfilmentMethod,
                fulfilmentDate: dateString
            )
        ])
        
        let appsFlyerParams: [String: Any] = [
            AFEventParamContentType: "root_menu",
            AFEventParamQuantity:menuFetchResult.categories!.count,
            "category_type": "child"
        ]
        let iterableParams: [String: Any] = [
            "categoryId": 0,
            "name": "root_menu",
            "storeId": store.id
        ]
        let firebaseParams: [String: Any] = [
            "category_name": "root_menu"
        ]
        mockedEventLogger.actions = .init(expected: [
            .sendEvent(for: .viewCategoryList, with: .appsFlyer, params: appsFlyerParams),
            .sendEvent(for: .viewCategoryList, with: .iterable, params: iterableParams),
            .sendEvent(for: .viewCategoryList, with: .firebaseAnalytics, params: firebaseParams)
        ])
        
        // Configuring responses from repositories
        
        mockedWebRepo.loadRootRetailStoreMenuCategoriesResponse = .success(menuFetchResult)
        mockedDBRepo.clearRetailStoreMenuFetchResponse = .success(true)
        mockedDBRepo.storeCategoryResponse = .success(storedMenuFetchResult)
        
        let exp = expectation(description: #function)
        
        let result = BindingWithPublisher(value: Loadable<RetailStoreMenuFetch>.notRequested)
        sut.getRootCategories(menuFetch: result.binding)
        
        result.updatesRecorder.sink { updates  in
            XCTAssertEqual(updates, [
                .notRequested,
                .isLoading(last: nil, cancelBag: CancelBag()),
                .loaded(storedMenuFetchResult)
            ])
            self.mockedWebRepo.verify()
            self.mockedDBRepo.verify()
            self.mockedEventLogger.verify()
            exp.fulfill()
        }.store(in: &subscriptions)
        
        wait(for: [exp], timeout: 2)
    }
    
    func test_whenSuccessfulGetRootCategoriesForCollection_thenReturnCorrectResult() {
        
        let store = RetailStoreDetails.mockedData
        appState.value.userData.selectedStore = .loaded(store)
        let dateString = appState.value.userData.selectedStore.value?.storeDateToday()
        let fulfilmentMethod: RetailStoreOrderMethodType = .collection
        appState.value.userData.selectedFulfilmentMethod = fulfilmentMethod
        let menuFetchResult = RetailStoreMenuFetch.mockedDataCategoriesFromAPI
        
        let storedMenuFetchResult = RetailStoreMenuFetch(
            id: menuFetchResult.id ?? 0,
            name: menuFetchResult.name ?? "",
            discountText: nil,
            categories: menuFetchResult.categories,
            menuItems: menuFetchResult.menuItems,
            dealSections: menuFetchResult.dealSections,
            fetchStoreId: store.id,
            fetchCategoryId: 0,
            fetchFulfilmentMethod: fulfilmentMethod,
            fetchFulfilmentDate: dateString,
            fetchTimestamp: Date()
        )
        
        // Configuring expected actions on repositories and events
        
        mockedWebRepo.actions = .init(expected: [
            .loadRootRetailStoreMenuCategories(
                storeId: store.id,
                fulfilmentMethod: fulfilmentMethod,
                fulfilmentDate: nil
            )
        ])
        
        mockedDBRepo.actions = .init(expected: [
            .clearRetailStoreMenuFetch(
                forStoreId: store.id,
                categoryId: 0,
                fulfilmentMethod: fulfilmentMethod,
                fulfilmentDate: dateString
            ),
            .store(
                fetchResult: menuFetchResult,
                forStoreId: store.id,
                categoryId: 0,
                fulfilmentMethod: fulfilmentMethod,
                fulfilmentDate: dateString
            )
        ])
        
        let appsFlyerParams: [String: Any] = [
            AFEventParamContentType: "root_menu",
            AFEventParamQuantity:menuFetchResult.categories!.count,
            "category_type":"child"
        ]
        let iterableParams: [String: Any] = [
            "categoryId": 0,
            "name": "root_menu",
            "storeId": store.id
        ]
        let firebaseParams: [String: Any] = [
            "category_name": "root_menu"
        ]
        mockedEventLogger.actions = .init(expected: [
            .sendEvent(for: .viewCategoryList, with: .appsFlyer, params: appsFlyerParams),
            .sendEvent(for: .viewCategoryList, with: .iterable, params: iterableParams),
            .sendEvent(for: .viewCategoryList, with: .firebaseAnalytics, params: firebaseParams)
        ])
        
        // Configuring responses from repositories
        
        mockedWebRepo.loadRootRetailStoreMenuCategoriesResponse = .success(menuFetchResult)
        mockedDBRepo.clearRetailStoreMenuFetchResponse = .success(true)
        mockedDBRepo.storeCategoryResponse = .success(storedMenuFetchResult)
        
        let exp = expectation(description: #function)
        
        let result = BindingWithPublisher(value: Loadable<RetailStoreMenuFetch>.notRequested)
        sut.getRootCategories(menuFetch: result.binding)
        
        result.updatesRecorder.sink { updates  in
            XCTAssertEqual(updates, [
                .notRequested,
                .isLoading(last: nil, cancelBag: CancelBag()),
                .loaded(storedMenuFetchResult)
            ])
            self.mockedWebRepo.verify()
            self.mockedDBRepo.verify()
            self.mockedEventLogger.verify()
            exp.fulfill()
        }.store(in: &subscriptions)
        
        wait(for: [exp], timeout: 2)
    }
    
    func test_whenNoStoreIsSelected_thenReturnError() {
        
        let exp = expectation(description: #function)
        
        let result = BindingWithPublisher(value: Loadable<RetailStoreMenuFetch>.notRequested)
        sut.getRootCategories(menuFetch: result.binding)
        
        result.updatesRecorder.sink { updates  in
            XCTAssertEqual(updates, [
                .notRequested,
                .isLoading(last: nil, cancelBag: CancelBag()),
                .failed(RetailStoreMenuServiceError.noSelectedStore)
            ])
            self.mockedWebRepo.verify()
            self.mockedDBRepo.verify()
            self.mockedEventLogger.verify()
            exp.fulfill()
        }.store(in: &subscriptions)
        
        wait(for: [exp], timeout: 2)
    }
    
    func test_whenWebErrorGetRootCategoriesForDeliveryAndInDB_thenReturnCorrectCacheResult() {
        
        let networkError = NSError(domain: NSURLErrorDomain, code: -1009, userInfo: [:])
        
        let store = RetailStoreDetails.mockedData
        appState.value.userData.selectedStore = .loaded(store)
        let dateString = appState.value.userData.selectedStore.value?.storeDateToday()
        let fulfilmentMethod: RetailStoreOrderMethodType = .delivery
        appState.value.userData.selectedFulfilmentMethod = fulfilmentMethod
        let menuFetchResult = RetailStoreMenuFetch.mockedDataCategoriesFromAPI
        
        let storedMenuFetchResult = RetailStoreMenuFetch(
            id: menuFetchResult.id ?? 0,
            name: menuFetchResult.name ?? "",
            discountText: nil,
            categories: menuFetchResult.categories,
            menuItems: menuFetchResult.menuItems,
            dealSections: menuFetchResult.dealSections,
            fetchStoreId: store.id,
            fetchCategoryId: 0,
            fetchFulfilmentMethod: fulfilmentMethod,
            fetchFulfilmentDate: dateString,
            fetchTimestamp: Date()
        )
        
        // Configuring expected actions on repositories and events
        
        mockedWebRepo.actions = .init(expected: [
            .loadRootRetailStoreMenuCategories(
                storeId: store.id,
                fulfilmentMethod: fulfilmentMethod,
                fulfilmentDate: nil
            )
        ])
        
        mockedDBRepo.actions = .init(expected: [
            .retailStoreMenuFetch(
                forStoreId: store.id,
                categoryId: 0,
                fulfilmentMethod: fulfilmentMethod,
                fulfilmentDate: dateString
            )
        ])
        
        let appsFlyerParams: [String: Any] = [
            AFEventParamContentType: "root_menu",
            AFEventParamQuantity: menuFetchResult.categories!.count,
            "category_type": "child"
        ]
        let iterableParams: [String: Any] = [
            "categoryId": 0,
            "name": "root_menu",
            "storeId": store.id
        ]
        let firebaseParams: [String: Any] = [
            "category_name": "root_menu"
        ]
        mockedEventLogger.actions = .init(expected: [
            .sendEvent(for: .viewCategoryList, with: .appsFlyer, params: appsFlyerParams),
            .sendEvent(for: .viewCategoryList, with: .iterable, params: iterableParams),
            .sendEvent(for: .viewCategoryList, with: .firebaseAnalytics, params: firebaseParams)
        ])
        
        // Configuring responses from repositories
        
        mockedWebRepo.loadRootRetailStoreMenuCategoriesResponse = .failure(networkError)
        mockedDBRepo.retailStoreMenuFetchResponse = .success(storedMenuFetchResult)
        
        let exp = expectation(description: #function)
        
        let result = BindingWithPublisher(value: Loadable<RetailStoreMenuFetch>.notRequested)
        sut.getRootCategories(menuFetch: result.binding)
        
        result.updatesRecorder.sink { updates  in
            XCTAssertEqual(updates, [
                .notRequested,
                .isLoading(last: nil, cancelBag: CancelBag()),
                .loaded(storedMenuFetchResult)
            ])
            self.mockedWebRepo.verify()
            self.mockedDBRepo.verify()
            self.mockedEventLogger.verify()
            exp.fulfill()
        }.store(in: &subscriptions)
        
        wait(for: [exp], timeout: 2)
    }
    
    func test_whenWebErrorGetRootCategoriesForDeliveryAndInDBButExpired_thenReturnError() {
        
        let expiredDate = Calendar.current.date(byAdding: .hour, value: -12, to: AppV2Constants.Business.retailStoreMenuCachedExpiry)
        let networkError = NSError(domain: NSURLErrorDomain, code: -1009, userInfo: [:])
        
        let store = RetailStoreDetails.mockedData
        appState.value.userData.selectedStore = .loaded(store)
        let dateString = appState.value.userData.selectedStore.value?.storeDateToday()
        let fulfilmentMethod: RetailStoreOrderMethodType = .delivery
        appState.value.userData.selectedFulfilmentMethod = fulfilmentMethod
        let menuFetchResult = RetailStoreMenuFetch.mockedDataCategoriesFromAPI
        
        let storedMenuFetchResult = RetailStoreMenuFetch(
            id: menuFetchResult.id ?? 0,
            name: menuFetchResult.name ?? "",
            discountText: nil,
            categories: menuFetchResult.categories,
            menuItems: menuFetchResult.menuItems,
            dealSections: menuFetchResult.dealSections,
            fetchStoreId: store.id,
            fetchCategoryId: 0,
            fetchFulfilmentMethod: fulfilmentMethod,
            fetchFulfilmentDate: dateString,
            fetchTimestamp: expiredDate
        )
        
        // Configuring expected actions on repositories and events
        
        mockedWebRepo.actions = .init(expected: [
            .loadRootRetailStoreMenuCategories(
                storeId: store.id,
                fulfilmentMethod: fulfilmentMethod,
                fulfilmentDate: nil
            )
        ])
        
        mockedDBRepo.actions = .init(expected: [
            .retailStoreMenuFetch(
                forStoreId: store.id,
                categoryId: 0,
                fulfilmentMethod: fulfilmentMethod,
                fulfilmentDate: dateString
            )
        ])
        
        // Configuring responses from repositories
        
        mockedWebRepo.loadRootRetailStoreMenuCategoriesResponse = .failure(networkError)
        mockedDBRepo.retailStoreMenuFetchResponse = .success(storedMenuFetchResult)
        
        let exp = expectation(description: #function)
        
        let result = BindingWithPublisher(value: Loadable<RetailStoreMenuFetch>.notRequested)
        sut.getRootCategories(menuFetch: result.binding)
        
        result.updatesRecorder.sink { updates  in
            XCTAssertEqual(updates, [
                .notRequested,
                .isLoading(last: nil, cancelBag: CancelBag()),
                .failed(networkError)
            ])
            self.mockedWebRepo.verify()
            self.mockedDBRepo.verify()
            self.mockedEventLogger.verify()
            exp.fulfill()
        }.store(in: &subscriptions)
        
        wait(for: [exp], timeout: 2)
    }
    
    func test_whenWebErrorGetRootCategoriesForDeliveryAndInNotInDB_thenReturnError() {
        let networkError = NSError(domain: NSURLErrorDomain, code: -1009, userInfo: [:])
        
        let store = RetailStoreDetails.mockedData
        appState.value.userData.selectedStore = .loaded(store)
        let dateString = appState.value.userData.selectedStore.value?.storeDateToday()
        let fulfilmentMethod: RetailStoreOrderMethodType = .delivery
        appState.value.userData.selectedFulfilmentMethod = fulfilmentMethod
        
        // Configuring expected actions on repositories and events
        
        mockedWebRepo.actions = .init(expected: [
            .loadRootRetailStoreMenuCategories(
                storeId: store.id,
                fulfilmentMethod: fulfilmentMethod,
                fulfilmentDate: nil
            )
        ])
        
        mockedDBRepo.actions = .init(expected: [
            .retailStoreMenuFetch(
                forStoreId: store.id,
                categoryId: 0,
                fulfilmentMethod: fulfilmentMethod,
                fulfilmentDate: dateString
            )
        ])
        
        // Configuring responses from repositories
        
        mockedWebRepo.loadRootRetailStoreMenuCategoriesResponse = .failure(networkError)
        mockedDBRepo.retailStoreMenuFetchResponse = .success(nil)
        
        let exp = expectation(description: #function)
        
        let result = BindingWithPublisher(value: Loadable<RetailStoreMenuFetch>.notRequested)
        sut.getRootCategories(menuFetch: result.binding)
        
        result.updatesRecorder.sink { updates  in
            XCTAssertEqual(updates, [
                .notRequested,
                .isLoading(last: nil, cancelBag: CancelBag()),
                .failed(networkError)
            ])
            self.mockedWebRepo.verify()
            self.mockedDBRepo.verify()
            self.mockedEventLogger.verify()
            exp.fulfill()
        }.store(in: &subscriptions)
        
        wait(for: [exp], timeout: 2)
    }
}

// MARK: - func getItems(menuFetch:menuItemIds:discountId:discountSectionId:)
final class GetItemsTests: RetailStoreMenuServiceTests {
    func test_whenSuccessfulGetItemsForDelivery_thenReturnCorrectResult() {
        
        let store = RetailStoreDetails.mockedData
        appState.value.userData.selectedStore = .loaded(store)
        let dateString = appState.value.userData.selectedStore.value?.storeDateToday()
        let fulfilmentMethod: RetailStoreOrderMethodType = .delivery
        appState.value.userData.selectedFulfilmentMethod = fulfilmentMethod
        let menuFetchResult = RetailStoreMenuFetch.mockedDataItemsFromAPI
        
        let storedMenuFetchResult = RetailStoreMenuFetch(
            id: menuFetchResult.id ?? 0,
            name: menuFetchResult.name ?? "",
            discountText: nil,
            categories: menuFetchResult.categories,
            menuItems: menuFetchResult.menuItems,
            dealSections: menuFetchResult.dealSections,
            fetchStoreId: store.id,
            fetchCategoryId: 0,
            fetchFulfilmentMethod: fulfilmentMethod,
            fetchFulfilmentDate: dateString,
            fetchTimestamp: Date()
        )
        
        let menuItemIds = menuFetchResult.menuItems?.reduce([], { (itemArray, item) -> [Int] in
            var array = itemArray
            array.append(item.id)
            return array
        })
        
        // Configuring expected actions on repositories
        
        mockedWebRepo.actions = .init(expected: [
            .getItems(
                storeId: store.id,
                fulfilmentMethod: fulfilmentMethod,
                menuItemIds: menuItemIds,
                discountId: nil,
                discountSectionId: nil
            )
        ])
        
        mockedDBRepo.actions = .init(expected: [
            .clearRetailStoreMenuItemsFetch(
                forStoreId: store.id,
                menuItemIds: menuItemIds,
                discountId: nil,
                discountSectionId: nil,
                fulfilmentMethod: fulfilmentMethod
            ),
            .store(
                fetchResult: menuFetchResult,
                forStoreId: store.id,
                menuItemIds: menuItemIds,
                discountId: nil,
                discountSectionId: nil,
                fulfilmentMethod: fulfilmentMethod
            )
        ])
        
        // Configuring responses from repositories
        
        mockedWebRepo.getItemsResponse = .success(menuFetchResult)
        mockedDBRepo.clearRetailStoreMenuItemsFetchResponse = .success(true)
        mockedDBRepo.storeMenuFetchResponse = .success(storedMenuFetchResult)
        
        let exp = expectation(description: #function)
        
        let result = BindingWithPublisher(value: Loadable<RetailStoreMenuFetch>.notRequested)
        
        sut.getItems(
            menuFetch: result.binding,
            menuItemIds: menuItemIds,
            discountId: nil,
            discountSectionId: nil
        )
        
        result.updatesRecorder.sink { updates  in
            XCTAssertEqual(updates, [
                .notRequested,
                .isLoading(last: nil, cancelBag: CancelBag()),
                .loaded(storedMenuFetchResult)
            ])
            self.mockedWebRepo.verify()
            self.mockedDBRepo.verify()
            self.mockedEventLogger.verify()
            exp.fulfill()
        }.store(in: &subscriptions)
        
        wait(for: [exp], timeout: 2)
    }
    
    func test_whenSuccessfulGetItemsForCollection_thenReturnCorrectResult() {
        
        let store = RetailStoreDetails.mockedData
        appState.value.userData.selectedStore = .loaded(store)
        let dateString = appState.value.userData.selectedStore.value?.storeDateToday()
        let fulfilmentMethod: RetailStoreOrderMethodType = .collection
        appState.value.userData.selectedFulfilmentMethod = fulfilmentMethod
        let menuFetchResult = RetailStoreMenuFetch.mockedDataItemsFromAPI
        
        let storedMenuFetchResult = RetailStoreMenuFetch(
            id: menuFetchResult.id ?? 0,
            name: menuFetchResult.name ?? "",
            discountText: nil,
            categories: menuFetchResult.categories,
            menuItems: menuFetchResult.menuItems,
            dealSections: menuFetchResult.dealSections,
            fetchStoreId: store.id,
            fetchCategoryId: 0,
            fetchFulfilmentMethod: fulfilmentMethod,
            fetchFulfilmentDate: dateString,
            fetchTimestamp: Date()
        )
        
        let menuItemIds = menuFetchResult.menuItems?.reduce([], { (itemArray, item) -> [Int] in
            var array = itemArray
            array.append(item.id)
            return array
        })
        
        // Configuring expected actions on repositories
        
        mockedWebRepo.actions = .init(expected: [
            .getItems(
                storeId: store.id,
                fulfilmentMethod: fulfilmentMethod,
                menuItemIds: menuItemIds,
                discountId: nil,
                discountSectionId: nil
            )
        ])
        
        mockedDBRepo.actions = .init(expected: [
            .clearRetailStoreMenuItemsFetch(
                forStoreId: store.id,
                menuItemIds: menuItemIds,
                discountId: nil,
                discountSectionId: nil,
                fulfilmentMethod: fulfilmentMethod
            ),
            .store(
                fetchResult: menuFetchResult,
                forStoreId: store.id,
                menuItemIds: menuItemIds,
                discountId: nil,
                discountSectionId: nil,
                fulfilmentMethod: fulfilmentMethod
            )
        ])
        
        // Configuring responses from repositories
        
        mockedWebRepo.getItemsResponse = .success(menuFetchResult)
        mockedDBRepo.clearRetailStoreMenuItemsFetchResponse = .success(true)
        mockedDBRepo.storeMenuFetchResponse = .success(storedMenuFetchResult)
        
        let exp = expectation(description: #function)
        
        let result = BindingWithPublisher(value: Loadable<RetailStoreMenuFetch>.notRequested)
        
        sut.getItems(
            menuFetch: result.binding,
            menuItemIds: menuItemIds,
            discountId: nil,
            discountSectionId: nil
        )
        
        result.updatesRecorder.sink { updates  in
            XCTAssertEqual(updates, [
                .notRequested,
                .isLoading(last: nil, cancelBag: CancelBag()),
                .loaded(storedMenuFetchResult)
            ])
            self.mockedWebRepo.verify()
            self.mockedDBRepo.verify()
            self.mockedEventLogger.verify()
            exp.fulfill()
        }.store(in: &subscriptions)
        
        wait(for: [exp], timeout: 2)
    }
    
    func test_whenNoStoreIsSelected_thenReturnError() {
        
        let exp = expectation(description: #function)
        
        let result = BindingWithPublisher(value: Loadable<RetailStoreMenuFetch>.notRequested)
        
        sut.getItems(
            menuFetch: result.binding,
            menuItemIds: [256, 258],
            discountId: nil,
            discountSectionId: nil
        )
        
        result.updatesRecorder.sink { updates  in
            XCTAssertEqual(updates, [
                .notRequested,
                .isLoading(last: nil, cancelBag: CancelBag()),
                .failed(RetailStoreMenuServiceError.noSelectedStore)
            ])
            self.mockedWebRepo.verify()
            self.mockedDBRepo.verify()
            self.mockedEventLogger.verify()
            exp.fulfill()
        }.store(in: &subscriptions)
        
        wait(for: [exp], timeout: 2)
    }
    
    func test_whenGetItemsForDeliveryAndMissingParams_thenReturnError() {
        
        let store = RetailStoreDetails.mockedData
        appState.value.userData.selectedStore = .loaded(store)
        
        let exp = expectation(description: #function)
        
        let result = BindingWithPublisher(value: Loadable<RetailStoreMenuFetch>.notRequested)
        
        sut.getItems(
            menuFetch: result.binding,
            menuItemIds: nil,
            discountId: nil,
            discountSectionId: nil
        )
        
        result.updatesRecorder.sink { updates  in
            XCTAssertEqual(updates, [
                .notRequested,
                .isLoading(last: nil, cancelBag: CancelBag()),
                .failed(RetailStoreMenuServiceError.invalidGetItemsCriteria)
            ])
            self.mockedWebRepo.verify()
            self.mockedDBRepo.verify()
            self.mockedEventLogger.verify()
            exp.fulfill()
        }.store(in: &subscriptions)
        
        wait(for: [exp], timeout: 2)
    }
    
    func test_whenGetItemsForDeliveryAndEmptyItemsArray_thenReturnError() {
        
        let store = RetailStoreDetails.mockedData
        appState.value.userData.selectedStore = .loaded(store)
        
        let exp = expectation(description: #function)
        
        let result = BindingWithPublisher(value: Loadable<RetailStoreMenuFetch>.notRequested)
        
        sut.getItems(
            menuFetch: result.binding,
            menuItemIds: [],
            discountId: nil,
            discountSectionId: nil
        )
        
        result.updatesRecorder.sink { updates  in
            XCTAssertEqual(updates, [
                .notRequested,
                .isLoading(last: nil, cancelBag: CancelBag()),
                .failed(RetailStoreMenuServiceError.invalidGetItemsCriteria)
            ])
            self.mockedWebRepo.verify()
            self.mockedDBRepo.verify()
            self.mockedEventLogger.verify()
            exp.fulfill()
        }.store(in: &subscriptions)
        
        wait(for: [exp], timeout: 2)
    }
    
    func test_whenGetItemsForDeliveryAndConflictingParams_thenReturnError() {
        
        let store = RetailStoreDetails.mockedData
        appState.value.userData.selectedStore = .loaded(store)
        
        let exp = expectation(description: #function)
        
        let result = BindingWithPublisher(value: Loadable<RetailStoreMenuFetch>.notRequested)
        
        // only one of these fields should be set: menuItemIds, discountId or discountSectionId
        sut.getItems(
            menuFetch: result.binding,
            menuItemIds: [1234],
            discountId: 23,
            discountSectionId: nil
        )
        
        result.updatesRecorder.sink { updates  in
            XCTAssertEqual(updates, [
                .notRequested,
                .isLoading(last: nil, cancelBag: CancelBag()),
                .failed(RetailStoreMenuServiceError.invalidGetItemsCriteria)
            ])
            self.mockedWebRepo.verify()
            self.mockedDBRepo.verify()
            self.mockedEventLogger.verify()
            exp.fulfill()
        }.store(in: &subscriptions)
        
        wait(for: [exp], timeout: 2)
    }
    
    func test_whenWebErrorGetItemsForDeliveryAndInDB_thenReturnCorrectCacheResult() {
        
        let networkError = NSError(domain: NSURLErrorDomain, code: -1009, userInfo: [:])
        
        let store = RetailStoreDetails.mockedData
        appState.value.userData.selectedStore = .loaded(store)
        let dateString = appState.value.userData.selectedStore.value?.storeDateToday()
        let fulfilmentMethod: RetailStoreOrderMethodType = .delivery
        appState.value.userData.selectedFulfilmentMethod = fulfilmentMethod
        let menuFetchResult = RetailStoreMenuFetch.mockedDataItemsFromAPI
        
        let storedMenuFetchResult = RetailStoreMenuFetch(
            id: menuFetchResult.id ?? 0,
            name: menuFetchResult.name ?? "",
            discountText: nil,
            categories: menuFetchResult.categories,
            menuItems: menuFetchResult.menuItems,
            dealSections: menuFetchResult.dealSections,
            fetchStoreId: store.id,
            fetchCategoryId: 0,
            fetchFulfilmentMethod: fulfilmentMethod,
            fetchFulfilmentDate: dateString,
            fetchTimestamp: Date()
        )
        
        let menuItemIds = menuFetchResult.menuItems?.reduce([], { (itemArray, item) -> [Int] in
            var array = itemArray
            array.append(item.id)
            return array
        })
        
        // Configuring expected actions on repositories
        
        mockedWebRepo.actions = .init(expected: [
            .getItems(
                storeId: store.id,
                fulfilmentMethod: fulfilmentMethod,
                menuItemIds: menuItemIds,
                discountId: nil,
                discountSectionId: nil
            )
        ])
        
        mockedDBRepo.actions = .init(expected: [
            .retailStoreMenuItemsFetch(
                forStoreId: store.id,
                menuItemIds: menuItemIds,
                discountId: nil,
                discountSectionId: nil,
                fulfilmentMethod: fulfilmentMethod
            )
        ])
        
        // Configuring responses from repositories
        
        mockedWebRepo.getItemsResponse = .failure(networkError)
        mockedDBRepo.retailStoreMenuItemsFetchResponse = .success(storedMenuFetchResult)
        
        let exp = expectation(description: #function)
        
        let result = BindingWithPublisher(value: Loadable<RetailStoreMenuFetch>.notRequested)
        
        sut.getItems(
            menuFetch: result.binding,
            menuItemIds: menuItemIds,
            discountId: nil,
            discountSectionId: nil
        )
        
        result.updatesRecorder.sink { updates  in
            XCTAssertEqual(updates, [
                .notRequested,
                .isLoading(last: nil, cancelBag: CancelBag()),
                .loaded(storedMenuFetchResult)
            ])
            self.mockedWebRepo.verify()
            self.mockedDBRepo.verify()
            self.mockedEventLogger.verify()
            exp.fulfill()
        }.store(in: &subscriptions)
        
        wait(for: [exp], timeout: 2)
    }
    
    func test_whenWebErrorGetItemsForDeliveryAndInDBButExpired_thenReturnError() {
        
        let expiredDate = Calendar.current.date(byAdding: .hour, value: -12, to: AppV2Constants.Business.retailStoreMenuCachedExpiry)
        let networkError = NSError(domain: NSURLErrorDomain, code: -1009, userInfo: [:])
        
        let store = RetailStoreDetails.mockedData
        appState.value.userData.selectedStore = .loaded(store)
        let dateString = appState.value.userData.selectedStore.value?.storeDateToday()
        let fulfilmentMethod: RetailStoreOrderMethodType = .delivery
        appState.value.userData.selectedFulfilmentMethod = fulfilmentMethod
        let menuFetchResult = RetailStoreMenuFetch.mockedDataItemsFromAPI
        
        let storedMenuFetchResult = RetailStoreMenuFetch(
            id: menuFetchResult.id ?? 0,
            name: menuFetchResult.name ?? "",
            discountText: nil,
            categories: menuFetchResult.categories,
            menuItems: menuFetchResult.menuItems,
            dealSections: menuFetchResult.dealSections,
            fetchStoreId: store.id,
            fetchCategoryId: 0,
            fetchFulfilmentMethod: fulfilmentMethod,
            fetchFulfilmentDate: dateString,
            fetchTimestamp: expiredDate
        )
        
        let menuItemIds = menuFetchResult.menuItems?.reduce([], { (itemArray, item) -> [Int] in
            var array = itemArray
            array.append(item.id)
            return array
        })
        
        // Configuring expected actions on repositories
        
        mockedWebRepo.actions = .init(expected: [
            .getItems(
                storeId: store.id,
                fulfilmentMethod: fulfilmentMethod,
                menuItemIds: menuItemIds,
                discountId: nil,
                discountSectionId: nil
            )
        ])
        
        mockedDBRepo.actions = .init(expected: [
            .retailStoreMenuItemsFetch(
                forStoreId: store.id,
                menuItemIds: menuItemIds,
                discountId: nil,
                discountSectionId: nil,
                fulfilmentMethod: fulfilmentMethod
            )
        ])
        
        // Configuring responses from repositories
        
        mockedWebRepo.getItemsResponse = .failure(networkError)
        mockedDBRepo.retailStoreMenuItemsFetchResponse = .success(storedMenuFetchResult)
        
        let exp = expectation(description: #function)
        
        let result = BindingWithPublisher(value: Loadable<RetailStoreMenuFetch>.notRequested)
        
        sut.getItems(
            menuFetch: result.binding,
            menuItemIds: menuItemIds,
            discountId: nil,
            discountSectionId: nil
        )
        
        result.updatesRecorder.sink { updates  in
            XCTAssertEqual(updates, [
                .notRequested,
                .isLoading(last: nil, cancelBag: CancelBag()),
                .failed(networkError)
            ])
            self.mockedWebRepo.verify()
            self.mockedDBRepo.verify()
            self.mockedEventLogger.verify()
            exp.fulfill()
        }.store(in: &subscriptions)
        
        wait(for: [exp], timeout: 2)
    }
    
    func test_whenWebErrorGetItemsForDeliveryAndInNotInDB_thenReturnError() {
        
        let networkError = NSError(domain: NSURLErrorDomain, code: -1009, userInfo: [:])
        
        let store = RetailStoreDetails.mockedData
        appState.value.userData.selectedStore = .loaded(store)
        let fulfilmentMethod: RetailStoreOrderMethodType = .delivery
        appState.value.userData.selectedFulfilmentMethod = fulfilmentMethod
        let menuFetchResult = RetailStoreMenuFetch.mockedDataItemsFromAPI
        
        let menuItemIds = menuFetchResult.menuItems?.reduce([], { (itemArray, item) -> [Int] in
            var array = itemArray
            array.append(item.id)
            return array
        })
        
        // Configuring expected actions on repositories
        
        mockedWebRepo.actions = .init(expected: [
            .getItems(
                storeId: store.id,
                fulfilmentMethod: fulfilmentMethod,
                menuItemIds: menuItemIds,
                discountId: nil,
                discountSectionId: nil
            )
        ])
        
        mockedDBRepo.actions = .init(expected: [
            .retailStoreMenuItemsFetch(
                forStoreId: store.id,
                menuItemIds: menuItemIds,
                discountId: nil,
                discountSectionId: nil,
                fulfilmentMethod: fulfilmentMethod
            )
        ])
        
        // Configuring responses from repositories
        
        mockedWebRepo.getItemsResponse = .failure(networkError)
        mockedDBRepo.retailStoreMenuItemsFetchResponse = .success(nil)
        
        let exp = expectation(description: #function)
        
        let result = BindingWithPublisher(value: Loadable<RetailStoreMenuFetch>.notRequested)
        
        sut.getItems(
            menuFetch: result.binding,
            menuItemIds: menuItemIds,
            discountId: nil,
            discountSectionId: nil
        )
        
        result.updatesRecorder.sink { updates  in
            XCTAssertEqual(updates, [
                .notRequested,
                .isLoading(last: nil, cancelBag: CancelBag()),
                .failed(networkError)
            ])
            self.mockedWebRepo.verify()
            self.mockedDBRepo.verify()
            self.mockedEventLogger.verify()
            exp.fulfill()
        }.store(in: &subscriptions)
        
        wait(for: [exp], timeout: 2)
    }
}

// MARK: - func getItem(request:)
final class GetItemTests: RetailStoreMenuServiceTests {
    
    func test_whenSuccessfulGetItem_thenReturnCorrectResult() async {
        
        let request = RetailStoreMenuItemRequest.mockedData
        let item = RetailStoreMenuItem.mockedData
        
        let itemFetch = RetailStoreMenuItemFetch(
            itemId: item.id,
            storeId: request.storeId,
            categoryId: request.categoryId,
            fulfilmentMethod: request.fulfilmentMethod,
            fulfilmentDate: request.fulfilmentDate,
            item: item,
            fetchTimestamp: Date()
        )
        
        // Configuring expected actions on repositories
        
        mockedWebRepo.actions = .init(expected: [
            .getItem(request: request)
        ])
        
        mockedDBRepo.actions = .init(expected: [
            .clearItem(with: request),
            .store(item: item, for: request)
        ])
        
        // Configuring responses from repositories
        
        mockedWebRepo.getItemResponse = .success(item)
        mockedDBRepo.clearRetailStoreMenuItemFetchResponse = .success(())
        mockedDBRepo.storeItemFetchResponse = .success(itemFetch)
        
        do {
            let result = try await sut.getItem(request: request)
            XCTAssertEqual(result, item)
            self.mockedWebRepo.verify()
            self.mockedDBRepo.verify()
            self.mockedEventLogger.verify()
        } catch {
            XCTFail("Unexpected error: \(error)", file: #file, line: #line)
        }
        
    }
    
    func test_whenWebErrorGetItemAndInDB_thenReturnCorrectCacheResult() async {
        
        let networkError = NSError(domain: NSURLErrorDomain, code: -1009, userInfo: [:])
        
        let request = RetailStoreMenuItemRequest.mockedData
        let item = RetailStoreMenuItem.mockedData
        
        let itemFetch = RetailStoreMenuItemFetch(
            itemId: item.id,
            storeId: request.storeId,
            categoryId: request.categoryId,
            fulfilmentMethod: request.fulfilmentMethod,
            fulfilmentDate: request.fulfilmentDate,
            item: item,
            fetchTimestamp: Date()
        )
        
        // Configuring expected actions on repositories
        
        mockedWebRepo.actions = .init(expected: [
            .getItem(request: request)
        ])
        
        mockedDBRepo.actions = .init(expected: [
            .retailStoreMenuItemFetch(request: request)
        ])
        
        // Configuring responses from repositories
        
        mockedWebRepo.getItemResponse = .failure(networkError)
        mockedDBRepo.retailStoreMenuItemFetchResponse = .success(itemFetch)
        
        do {
            let result = try await sut.getItem(request: request)
            XCTAssertEqual(result, item)
            self.mockedWebRepo.verify()
            self.mockedDBRepo.verify()
            self.mockedEventLogger.verify()
        } catch {
            XCTFail("Unexpected error: \(error)", file: #file, line: #line)
        }
        
    }
    
    func test_whenWebErrorGetItemAndInDBButExpired_thenReturnError() async {
        
        let expiredDate = Calendar.current.date(byAdding: .hour, value: -12, to: AppV2Constants.Business.retailStoreMenuCachedExpiry)
        let networkError = NSError(domain: NSURLErrorDomain, code: -1009, userInfo: [:])
        
        let request = RetailStoreMenuItemRequest.mockedData
        let item = RetailStoreMenuItem.mockedData
        
        let itemFetch = RetailStoreMenuItemFetch(
            itemId: item.id,
            storeId: request.storeId,
            categoryId: request.categoryId,
            fulfilmentMethod: request.fulfilmentMethod,
            fulfilmentDate: request.fulfilmentDate,
            item: item,
            fetchTimestamp: expiredDate
        )
        
        // Configuring expected actions on repositories
        
        mockedWebRepo.actions = .init(expected: [
            .getItem(request: request)
        ])
        
        mockedDBRepo.actions = .init(expected: [
            .retailStoreMenuItemFetch(request: request)
        ])
        
        // Configuring responses from repositories
        
        mockedWebRepo.getItemResponse = .failure(networkError)
        mockedDBRepo.retailStoreMenuItemFetchResponse = .success(itemFetch)
        
        do {
            let result = try await sut.getItem(request: request)
            XCTFail("Unexpected result: \(result)", file: #file, line: #line)
        } catch {
            XCTAssertEqual(error as NSError, networkError)
            self.mockedWebRepo.verify()
            self.mockedDBRepo.verify()
            self.mockedEventLogger.verify()
        }
        
    }
    
    func test_whenWebErrorGetItemAndNotInDB_thenReturnError() async {
        
        let networkError = NSError(domain: NSURLErrorDomain, code: -1009, userInfo: [:])
        
        let request = RetailStoreMenuItemRequest.mockedData
        
        // Configuring expected actions on repositories
        
        mockedWebRepo.actions = .init(expected: [
            .getItem(request: request)
        ])
        
        mockedDBRepo.actions = .init(expected: [
            .retailStoreMenuItemFetch(request: request)
        ])
        
        // Configuring responses from repositories
        
        mockedWebRepo.getItemResponse = .failure(networkError)
        mockedDBRepo.retailStoreMenuItemFetchResponse = .success(nil)
        
        do {
            let result = try await sut.getItem(request: request)
            XCTFail("Unexpected result: \(result)", file: #file, line: #line)
        } catch {
            XCTAssertEqual(error as NSError, networkError)
            self.mockedWebRepo.verify()
            self.mockedDBRepo.verify()
            self.mockedEventLogger.verify()
        }
        
    }
}
