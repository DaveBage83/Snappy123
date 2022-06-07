//
//  RetailStoreMenuServiceTests.swift
//  SnappyV2Tests
//
//  Created by Henrik Gustavii on 03/06/2022.
//

import XCTest
import Combine
@testable import SnappyV2

class RetailStoreMenuServiceTests: XCTestCase {
    
    var appState = CurrentValueSubject<AppState, Never>(AppState())
    var mockedEventLogger: MockedEventLogger!
    var mockedWebRepo: MockedRetailStoreMenuWebRepository!
    var mockedDBRepo: MockedRetailStoreMenuDBRepository!
    var subscriptions = Set<AnyCancellable>()
    var sut: RetailStoreMenuService!

    override func setUp() {
        mockedEventLogger = MockedEventLogger()
        mockedWebRepo = MockedRetailStoreMenuWebRepository()
        mockedDBRepo = MockedRetailStoreMenuDBRepository()
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
        let categoriesResult = RetailStoreMenuFetch.mockedDataCategories
        let store = RetailStoreDetails.mockedData
        appState.value.userData.selectedStore = .loaded(store)
        
        mockedWebRepo.actions = .init(expected: [.loadRetailStoreMenuSubCategoriesAndItems(storeId: store.id, categoryId: 0, fulfilmentMethod: .delivery, fulfilmentDate: nil)])
        
        mockedDBRepo.actions = .init(expected: [.retailStoreMenuFetch(forStoreId: store.id, categoryId: 0, fulfilmentMethod: .delivery, fulfilmentDate: Date().dateOnlyString(storeTimeZone: nil))])
        
        let params: [String: Any] = [
            "category_id":0,
            "af_content_type":categoriesResult.name,
            "af_quantity":categoriesResult.categories!.count,
            "category_type":"child"
        ]
        mockedEventLogger.actions = .init(expected: [.sendEvent(for: .viewContentList, with: .appsFlyer, params: params)])
        
        mockedWebRepo.loadRootRetailStoreMenuCategoriesResponse = .success(categoriesResult)
        mockedDBRepo.retailStoreMenuFetchResponse = .success(categoriesResult)
        
        let exp = expectation(description: #function)
        
        let result = BindingWithPublisher(value: Loadable<RetailStoreMenuFetch>.notRequested)
        sut.getChildCategoriesAndItems(menuFetch: result.binding, categoryId: 0)
        result.updatesRecorder.sink { updates in
            XCTAssertEqual(updates, [
                .notRequested,
                .isLoading(last: nil, cancelBag: CancelBag()),
                .loaded(categoriesResult)
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
    func test_whenSuccessfulSearch_thenReturnCorrectResult() {
        let searchResult = RetailStoreMenuGlobalSearch.mockedDataFromAPI
        let selectedStore = RetailStoreDetails.mockedData
        sut.appState.value.userData.selectedStore = .loaded(selectedStore)
        
        mockedWebRepo.actions = .init(expected: [.globalSearch(storeId: selectedStore.id, fulfilmentMethod: .delivery, searchTerm: "Bags")])
        mockedDBRepo.actions = .init(expected: [.clearGlobalSearch(forStoreId: selectedStore.id, fulfilmentMethod: .delivery, searchTerm: "Bags"), .store(fetchResult: searchResult, forStoreId: selectedStore.id, fulfilmentMethod: .delivery, searchTerm: "Bags")])
        
        let params: [String: Any] = [
            "af_search_string":"Bags",
            "category_names":["Bags", "Bags & Wrap", "Bags & Wrap"],
            "item_names":["Basket limit conflict", "Option Grid Max(2) Min (0) Mutually Exclusive (true)"],
            "deal_names":[]
        ]
        mockedEventLogger.actions = .init(expected: [.sendEvent(for: .search, with: .appsFlyer, params: params)])
        
        mockedWebRepo.globalSearchResponse = .success(searchResult)
        mockedDBRepo.clearGlobalSearchResponse = .success(true)
        mockedDBRepo.storeSearchResponse = .success(searchResult)
        
        let exp = expectation(description: #function)
        
        let result = BindingWithPublisher(value: Loadable<RetailStoreMenuGlobalSearch>.notRequested)
        sut.globalSearch(
            searchFetch: result.binding,
            searchTerm: "Bags",
            scope: nil,
            itemsPagination: nil,
            categoriesPagination: nil
        )
        result.updatesRecorder.sink { updates  in
            XCTAssertEqual(updates, [
                .notRequested,
                .isLoading(last: nil, cancelBag: CancelBag()),
                .loaded(searchResult)
            ])
            self.mockedWebRepo.verify()
            self.mockedDBRepo.verify()
            self.mockedEventLogger.verify()
            exp.fulfill()
        }.store(in: &subscriptions)
        
        wait(for: [exp], timeout: 2)
    }
}
