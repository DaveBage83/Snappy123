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
        XCTAssertEqual(sut.selectedRetailStoreDetails, .notRequested)
        XCTAssertTrue(sut.retailStores.isEmpty)
        XCTAssertEqual(sut.shownRetailStores, [])
        XCTAssertEqual(sut.retailStoreTypes, [])
        XCTAssertNil(sut.filteredRetailStoreType)
        XCTAssertFalse(sut.isLoading)
    }
    
    func test_givenStoreWithDelivery_whenDeliveryIsSelected_thenStoreIsShown() throws {
        let sut = makeSUT()
        
        let orderMethodDelivery = RetailStoreOrderMethod(name: .delivery, earliestTime: nil, status: .open, cost: nil, fulfilmentIn: nil)
        let orderMethodCollection = RetailStoreOrderMethod(name: .delivery, earliestTime: nil, status: .open, cost: nil, fulfilmentIn: nil)
        let fulfilmentLocation = FulfilmentLocation(countryCode: "UK", lat: 56.473358599999997, lng: -3.0111853000000002, postcode: "DD1 3JA")
        let storeDelivery = RetailStore(id: 1, storeName: "DeliveryStore", distance: 0, storeLogo: nil, storeProductTypes: nil, orderMethods: ["delivery": orderMethodDelivery])
        let storeCollection = RetailStore(id: 1, storeName: "CollectionStore", distance: 0, storeLogo: nil, storeProductTypes: nil, orderMethods: ["collection": orderMethodCollection])
        let search = RetailStoresSearch(storeProductTypes: nil, stores: [storeDelivery, storeCollection], fulfilmentLocation: fulfilmentLocation)
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
        let fulfilmentLocation = FulfilmentLocation(countryCode: "UK", lat: 56.473358599999997, lng: -3.0111853000000002, postcode: "DD1 3JA")
        let storeDelivery = RetailStore(id: 1, storeName: "DeliveryStore", distance: 0, storeLogo: nil, storeProductTypes: nil, orderMethods: ["delivery": orderMethodDelivery])
        let storeCollection = RetailStore(id: 1, storeName: "CollectionStore", distance: 0, storeLogo: nil, storeProductTypes: nil, orderMethods: ["collection": orderMethodCollection])
        let search = RetailStoresSearch(storeProductTypes: nil, stores: [storeDelivery, storeCollection], fulfilmentLocation: fulfilmentLocation)
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
        let fulfilmentLocation = FulfilmentLocation(countryCode: "UK", lat: 56.473358599999997, lng: -3.0111853000000002, postcode: "DD1 3JA")
        let search = RetailStoresSearch(storeProductTypes: nil, stores: [storeDelivery, storeCollection], fulfilmentLocation: fulfilmentLocation)
        sut.container.appState.value.userData.searchResult = .loaded(search)
        
        sut.selectedOrderMethod = .collection
        
        let expectation = expectation(description: "selectedOrderMethodMethod")
        var cancellables = Set<AnyCancellable>()
        
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
        let fulfilmentLocation = FulfilmentLocation(countryCode: "UK", lat: 56.473358599999997, lng: -3.0111853000000002, postcode: "DD1 3JA")
        
        let search = RetailStoresSearch(storeProductTypes: [storeTypeButchers, storeTypeGroceries], stores: [storeButchers, storeGroceries], fulfilmentLocation: fulfilmentLocation)
        sut.container.appState.value.userData.searchResult = .loaded(search)
        
        sut.filteredRetailStoreType = 1
        
        let expectation = expectation(description: "selectedRetailStoreType")
        var cancellables = Set<AnyCancellable>()
        
        sut.$filteredRetailStoreType
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 5)
        
        XCTAssertEqual(sut.shownRetailStores.count, 1)
        XCTAssertEqual(sut.shownRetailStores.first, storeButchers)
    }
    
    func test_givenStoreWithOneResult_whenResultChanges_thenShownRetailStoresChangedCorrectly() {
        let sut = makeSUT()
        
        let orderMethod = RetailStoreOrderMethod(name: .delivery, earliestTime: nil, status: .open, cost: nil, fulfilmentIn: nil)
        let orderMethods = ["delivery": orderMethod]
        let storeButchers = RetailStore(id: 1, storeName: "", distance: 0, storeLogo: nil, storeProductTypes: [1], orderMethods: orderMethods)
        let fulfilmentLocation = FulfilmentLocation(countryCode: "UK", lat: 56.473358599999997, lng: -3.0111853000000002, postcode: "DD1 3JA")
        
        let search1 = RetailStoresSearch(storeProductTypes: nil, stores: [storeButchers], fulfilmentLocation: fulfilmentLocation)
        
        sut.container.appState.value.userData.searchResult = .loaded(search1)
        
        XCTAssertEqual(sut.storeSearchResult, .loaded(search1))
        
        let storeGroceries = RetailStore(id: 1, storeName: "", distance: 0, storeLogo: nil, storeProductTypes: [2], orderMethods: orderMethods)
        let search2 = RetailStoresSearch(storeProductTypes: nil, stores: [storeGroceries], fulfilmentLocation: fulfilmentLocation)
        
        sut.container.appState.value.userData.searchResult = .loaded(search2)
        
        let expectation = expectation(description: "retailStores")
        var cancellables = Set<AnyCancellable>()
        
        sut.$retailStores
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 5)
        
        XCTAssertEqual(sut.shownRetailStores.count, 1)
        XCTAssertEqual(sut.shownRetailStores.first, storeGroceries)
    }
    
    func test_whenStoreIsOpen_thenShowsInCorrectSection() {
        let sut = makeSUT()
        
        let fulfilmentLocation = FulfilmentLocation(countryCode: "UK", lat: 0, lng: 0, postcode: "TN223HY")
        let orderMethodOpen = RetailStoreOrderMethod(name: .delivery, earliestTime: nil, status: .open, cost: nil, fulfilmentIn: nil)
        let orderMethodClosed = RetailStoreOrderMethod(name: .delivery, earliestTime: nil, status: .closed, cost: nil, fulfilmentIn: nil)
        let orderMethodPreorder = RetailStoreOrderMethod(name: .delivery, earliestTime: nil, status: .preorder, cost: nil, fulfilmentIn: nil)
        let storeOpen = RetailStore(id: 1, storeName: "OpenStore", distance: 0, storeLogo: nil, storeProductTypes: nil, orderMethods: ["delivery": orderMethodOpen])
        let storeClosed = RetailStore(id: 1, storeName: "ClosedStore", distance: 0, storeLogo: nil, storeProductTypes: nil, orderMethods: ["delivery": orderMethodClosed])
        let storePreorder = RetailStore(id: 1, storeName: "PreorderStore", distance: 0, storeLogo: nil, storeProductTypes: nil, orderMethods: ["delivery": orderMethodPreorder])
        let search = RetailStoresSearch(storeProductTypes: nil, stores: [storeOpen, storeClosed, storePreorder], fulfilmentLocation: fulfilmentLocation)
        sut.container.appState.value.userData.searchResult = .loaded(search)
        
        let expectation = expectation(description: "setupOrderMethodStatus")
        var cancellables = Set<AnyCancellable>()
        
        sut.$shownRetailStores
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 5)
        
        XCTAssertEqual(sut.shownOpenStores.count, 1)
        XCTAssertEqual(sut.shownOpenStores.first, storeOpen)
    }
    
    func test_whenStoreIsClosed_thenShowsInCorrectSection() {
        let sut = makeSUT()
        
        let fulfilmentLocation = FulfilmentLocation(countryCode: "UK", lat: 0, lng: 0, postcode: "TN223HY")
        let orderMethodOpen = RetailStoreOrderMethod(name: .delivery, earliestTime: nil, status: .open, cost: nil, fulfilmentIn: nil)
        let orderMethodClosed = RetailStoreOrderMethod(name: .delivery, earliestTime: nil, status: .closed, cost: nil, fulfilmentIn: nil)
        let storeOpen = RetailStore(id: 1, storeName: "OpenStore", distance: 0, storeLogo: nil, storeProductTypes: nil, orderMethods: ["delivery": orderMethodOpen])
        let storeClosed = RetailStore(id: 1, storeName: "ClosedStore", distance: 0, storeLogo: nil, storeProductTypes: nil, orderMethods: ["delivery": orderMethodClosed])
        let search = RetailStoresSearch(storeProductTypes: nil, stores: [storeOpen, storeClosed], fulfilmentLocation: fulfilmentLocation)
        sut.container.appState.value.userData.searchResult = .loaded(search)
        
        let expectation = expectation(description: "setupOrderMethodStatus")
        var cancellables = Set<AnyCancellable>()
        
        sut.$shownRetailStores
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 5)
        
        XCTAssertEqual(sut.showClosedStores.count, 1)
        XCTAssertEqual(sut.showClosedStores.first, storeClosed)
    }
    
    func test_whenStoreIsPreorder_thenShowsInCorrectSection() {
        let sut = makeSUT()
        
        let fulfilmentLocation = FulfilmentLocation(countryCode: "UK", lat: 0, lng: 0, postcode: "TN223HY")
        let orderMethodOpen = RetailStoreOrderMethod(name: .delivery, earliestTime: nil, status: .open, cost: nil, fulfilmentIn: nil)
        let orderMethodClosed = RetailStoreOrderMethod(name: .delivery, earliestTime: nil, status: .closed, cost: nil, fulfilmentIn: nil)
        let orderMethodPreorder = RetailStoreOrderMethod(name: .delivery, earliestTime: nil, status: .preorder, cost: nil, fulfilmentIn: nil)
        let storeOpen = RetailStore(id: 1, storeName: "OpenStore", distance: 0, storeLogo: nil, storeProductTypes: nil, orderMethods: ["delivery": orderMethodOpen])
        let storeClosed = RetailStore(id: 1, storeName: "ClosedStore", distance: 0, storeLogo: nil, storeProductTypes: nil, orderMethods: ["delivery": orderMethodClosed])
        let storePreorder = RetailStore(id: 1, storeName: "PreorderStore", distance: 0, storeLogo: nil, storeProductTypes: nil, orderMethods: ["delivery": orderMethodPreorder])
        let search = RetailStoresSearch(storeProductTypes: nil, stores: [storeOpen, storeClosed, storePreorder], fulfilmentLocation: fulfilmentLocation)
        sut.container.appState.value.userData.searchResult = .loaded(search)
        
        let expectation = expectation(description: "setupOrderMethodStatus")
        var cancellables = Set<AnyCancellable>()
        
        sut.$shownRetailStores
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 5)
        
        XCTAssertEqual(sut.showPreorderStores.count, 1)
        XCTAssertEqual(sut.showPreorderStores.first, storePreorder)
    }


    func test_whenSearchPostcodeTapped_thenIsFocusedSetToFalse() {
        let container = DIContainer(appState: AppState(), services: .mocked(retailStoreService: [.searchRetailStores(postcode: "TN223HY")]))
        let sut = makeSUT(container: container)
        
        sut.postcodeSearchString = "TN223HY"
        sut.isFocused = true

        sut.searchPostcode()

        XCTAssertFalse(sut.isFocused)
        container.services.verify()
    }

	func test_whenSelectStoreTapped() {
        let container = DIContainer(appState: AppState(), services: .mocked(retailStoreService: [.getStoreDetails(storeId: 123, postcode: "TN223HY")]))
        let sut = makeSUT(container: container)
        
        let fulfilmentLocation = FulfilmentLocation(countryCode: "UK", lat: 0, lng: 0, postcode: "TN223HY")
        let search = RetailStoresSearch(storeProductTypes: nil, stores: nil, fulfilmentLocation: fulfilmentLocation)
        sut.container.appState.value.userData.searchResult = .loaded(search)
        
        sut.selectStore(id: 123)
        
        container.services.verify()
	}
    
    func test_addFilteredStoreType() {
        let sut = makeSUT()
        
        sut.selectFilteredRetailStoreType(id: 11)
        
        XCTAssertEqual(sut.filteredRetailStoreType, 11)
    }
    
    func test_removeFilteredStoreType() {
        let sut = makeSUT()
        
        sut.filteredRetailStoreType = 12
        
        XCTAssertEqual(sut.filteredRetailStoreType, 12)
        
        sut.clearFilteredRetailStoreType()
        
        XCTAssertNil(sut.filteredRetailStoreType)
    }
    
    func test_givenStoreSearchResult_whenIsLoadingStatus_thenReturnsTrue() {
        let sut = makeSUT()
        sut.storeSearchResult = .isLoading(last: nil, cancelBag: CancelBag())
        
        XCTAssertTrue(sut.isLoading)
    }
    
    func test_givenStoreSearchResult_whenLoadedStatus_thenReturnsFalse() {
        let sut = makeSUT()
        sut.storeSearchResult = .loaded(RetailStoresSearch(storeProductTypes: nil, stores: nil, fulfilmentLocation: FulfilmentLocation(countryCode: "", lat: 0, lng: 0, postcode: "")))
        
        XCTAssertFalse(sut.isLoading)
    }
    
    func test_whenSelectedOrderMethodIsDelivery_thenIsDeliverySelectedReturnsTrue() {
        let sut = makeSUT()
        sut.selectedOrderMethod = .collection
        
        XCTAssertFalse(sut.isDeliverySelected)
    }

    func makeSUT(storeSearchResult: Loadable<RetailStoresSearch> = .notRequested, container: DIContainer = DIContainer(appState: AppState(), services: .mocked())) -> StoresViewModel {
        let sut = StoresViewModel(container: container, storeSearchResult: storeSearchResult)
        
        trackForMemoryLeaks(sut)
        
        return sut
    }

}
