//
//  StoresViewModelTests.swift
//  SnappyV2Tests
//
//  Created by Henrik Gustavii on 04/10/2021.
//

import XCTest
import Combine
@testable import SnappyV2

class StoresViewModelTests: XCTestCase {
    
    func test_init() {
        let sut = makeSUT()
        
        XCTAssertTrue(sut.isDeliverySelected)
        XCTAssertEqual(sut.selectedOrderMethod, .delivery)
        XCTAssertEqual(sut.emailToNotify, "")
        XCTAssertEqual(sut.container.appState.value, AppState())
        XCTAssertEqual(sut.postcodeSearchString, "")
        XCTAssertEqual(sut.storeSearchResult, .notRequested)
        XCTAssertTrue(sut.retailStores.isEmpty)
        XCTAssertEqual(sut.shownRetailStores, [])
        XCTAssertNil(sut.retailStoreTypes)
    }
    
    func test_givenStoreWithDelivery_whenDeliveryIsSelected_thenStoreIsShown() throws {
        let sut = makeSUT()
        
        let orderMethodDelivery = RetailStoreOrderMethod(name: .delivery, earliestTime: nil, status: .open, cost: nil, fulfilmentIn: nil)
        let orderMethodCollection = RetailStoreOrderMethod(name: .delivery, earliestTime: nil, status: .open, cost: nil, fulfilmentIn: nil)
        let storeDelivery = RetailStore(id: 1, storeName: "DeliveryStore", distance: 0, storeLogo: nil, storeProductTypes: nil, orderMethods: ["delivery": orderMethodDelivery])
        let storeCollection = RetailStore(id: 1, storeName: "CollectionStore", distance: 0, storeLogo: nil, storeProductTypes: nil, orderMethods: ["collection": orderMethodCollection])
        let search = RetailStoresSearch(storeProductTypes: nil, stores: [storeDelivery, storeCollection], postcode: nil, latitude: nil, longitude: nil)
        sut.container.appState.value.userData.searchResult = .loaded(search)
        
        sut.selectedOrderMethod = .delivery
        
        let expectation = expectation(description: "selectedOrderMethodMethod")
        var cancellables = Set<AnyCancellable>()
        
        sut.$selectedOrderMethod
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 5)
        
        let shownRetailStore = try XCTUnwrap(sut.shownRetailStores)
        
        XCTAssertEqual(shownRetailStore, [storeDelivery])
    }
    
    func test_givenStoreWithCollection_whenCollectionIsSelected_thenStoreIsShown() throws {
        let sut = makeSUT()
        
        let orderMethodDelivery = RetailStoreOrderMethod(name: .delivery, earliestTime: nil, status: .open, cost: nil, fulfilmentIn: nil)
        let orderMethodCollection = RetailStoreOrderMethod(name: .delivery, earliestTime: nil, status: .open, cost: nil, fulfilmentIn: nil)
        let storeDelivery = RetailStore(id: 1, storeName: "DeliveryStore", distance: 0, storeLogo: nil, storeProductTypes: nil, orderMethods: ["delivery": orderMethodDelivery])
        let storeCollection = RetailStore(id: 1, storeName: "CollectionStore", distance: 0, storeLogo: nil, storeProductTypes: nil, orderMethods: ["collection": orderMethodCollection])
        let search = RetailStoresSearch(storeProductTypes: nil, stores: [storeDelivery, storeCollection], postcode: nil, latitude: nil, longitude: nil)
        sut.container.appState.value.userData.searchResult = .loaded(search)
        
        let expectation = expectation(description: "selectedOrderMethodMethod")
        var cancellables = Set<AnyCancellable>()
        
        sut.selectedOrderMethod = .collection
        
        sut.$selectedOrderMethod
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 5)
        
        let shownRetailStore = try XCTUnwrap(sut.shownRetailStores)
        
        XCTAssertEqual(shownRetailStore, [storeCollection])
    }
    
    func test_givenStoresWithNoOrderMethods_whenCollectionIsSelected_thenNoStoreIsShown() throws {
        let sut = makeSUT()
        
        let storeDelivery = RetailStore(id: 1, storeName: "DeliveryStore", distance: 0, storeLogo: nil, storeProductTypes: nil, orderMethods: nil)
        let storeCollection = RetailStore(id: 1, storeName: "CollectionStore", distance: 0, storeLogo: nil, storeProductTypes: nil, orderMethods: nil)
        let search = RetailStoresSearch(storeProductTypes: nil, stores: [storeDelivery, storeCollection], postcode: nil, latitude: nil, longitude: nil)
        sut.container.appState.value.userData.searchResult = .loaded(search)
        
        let expectation = expectation(description: "selectedOrderMethodMethod")
        var cancellables = Set<AnyCancellable>()
        
        sut.selectedOrderMethod = .collection
        
        sut.$selectedOrderMethod
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 5)
        
        let shownRetailStore = try XCTUnwrap(sut.shownRetailStores)
        
        XCTAssertTrue(shownRetailStore.isEmpty)
    }
    
    func test_givenStoreWith2Types_whenButchersIsSelected_ThenOnlyButchersShown() {
        let sut = makeSUT()
        
        let orderMethod = RetailStoreOrderMethod(name: .delivery, earliestTime: nil, status: .open, cost: nil, fulfilmentIn: nil)
        let orderMethods = ["delivery": orderMethod]
        let storeTypeButchers = RetailStoreProductType(id: 1, name: "Butchers", image: nil)
        let storeButchers = RetailStore(id: 1, storeName: "", distance: 0, storeLogo: nil, storeProductTypes: [1], orderMethods: orderMethods)
        let storeTypeGroceries = RetailStoreProductType(id: 2, name: "Groceries", image: nil)
        let storeGroceries = RetailStore(id: 1, storeName: "", distance: 0, storeLogo: nil, storeProductTypes: [2], orderMethods: orderMethods)
        
        let search = RetailStoresSearch(storeProductTypes: [storeTypeButchers, storeTypeGroceries], stores: [storeButchers, storeGroceries], postcode: nil, latitude: nil, longitude: nil)
        sut.container.appState.value.userData.searchResult = .loaded(search)
        
        sut.selectedRetailStoreTypes = [1]
        
        let expectation = expectation(description: "selectedRetailStoreType")
        var cancellables = Set<AnyCancellable>()
        
        sut.$selectedRetailStoreTypes
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 5)
        
        XCTAssertEqual(sut.shownRetailStores?.count, 1)
        XCTAssertEqual(sut.shownRetailStores?.first, storeButchers)
    }
    
    func test_givenStoreWithOneResult_whenResultChanges_thenShownRetailStoresChangedCorrectly() {
        let sut = makeSUT()
        
        let orderMethod = RetailStoreOrderMethod(name: .delivery, earliestTime: nil, status: .open, cost: nil, fulfilmentIn: nil)
        let orderMethods = ["delivery": orderMethod]
        let storeButchers = RetailStore(id: 1, storeName: "", distance: 0, storeLogo: nil, storeProductTypes: [1], orderMethods: orderMethods)
        let search1 = RetailStoresSearch(storeProductTypes: nil, stores: [storeButchers], postcode: nil, latitude: nil, longitude: nil)
        
        sut.container.appState.value.userData.searchResult = .loaded(search1)
        
        XCTAssertEqual(sut.storeSearchResult, .loaded(search1))
        
        let storeGroceries = RetailStore(id: 1, storeName: "", distance: 0, storeLogo: nil, storeProductTypes: [2], orderMethods: orderMethods)
        let search2 = RetailStoresSearch(storeProductTypes: nil, stores: [storeGroceries], postcode: nil, latitude: nil, longitude: nil)
        
        sut.container.appState.value.userData.searchResult = .loaded(search2)
        
        let expectation = expectation(description: "retailStores")
        var cancellables = Set<AnyCancellable>()
        
        sut.$retailStores
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 5)
        
        XCTAssertEqual(sut.shownRetailStores?.count, 1)
        XCTAssertEqual(sut.shownRetailStores?.first, storeGroceries)
    }

//    func test_whenSearchPostcodeTapped_thenIsFocusedSetToFalse() {
//        let sut = makeSUT()
//
//        sut.isFocused = true
//
//        sut.searchPostcode()
//
//        XCTAssertFalse(sut.isFocused)
//    }

    func makeSUT(storeSearchResult: Loadable<RetailStoresSearch> = .notRequested) -> StoresViewModel {
        let container = DIContainer(appState: AppState(), services: .mocked())
        let sut = StoresViewModel(container: container, storeSearchResult: storeSearchResult)
        
        trackForMemoryLeaks(sut)
        
        return sut
    }

}
