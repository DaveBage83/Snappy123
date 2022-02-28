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
        XCTAssertFalse(sut.storesSearchIsLoading)
    }
    
    func test_givenStoreWithDelivery_whenDeliveryIsSelected_thenStoreIsShown() throws {
        let orderMethodDelivery = RetailStoreOrderMethod(name: .delivery, earliestTime: nil, status: .open, cost: nil, fulfilmentIn: nil)
        let orderMethodCollection = RetailStoreOrderMethod(name: .collection, earliestTime: nil, status: .open, cost: nil, fulfilmentIn: nil)
        let fulfilmentLocation = FulfilmentLocation(country: "UK", latitude: 56.473358599999997, longitude: -3.0111853000000002, postcode: "DD1 3JA")
        let storeDelivery = RetailStore(id: 1, storeName: "DeliveryStore", distance: 0, storeLogo: nil, storeProductTypes: nil, orderMethods: ["delivery": orderMethodDelivery], ratings: nil)
        let storeCollection = RetailStore(id: 1, storeName: "CollectionStore", distance: 0, storeLogo: nil, storeProductTypes: nil, orderMethods: ["collection": orderMethodCollection], ratings: nil)
        let search = RetailStoresSearch(storeProductTypes: nil, stores: [storeDelivery, storeCollection], fulfilmentLocation: fulfilmentLocation)
        
        var appState = AppState()
        appState.userData.searchResult = .loaded(search)
        
        let container = DIContainer(appState: appState, services: .mocked())
        
        let sut = makeSUT(container: container)
        
        sut.selectedOrderMethod = .delivery
        
        let expectation = expectation(description: "selectedOrderMethodMethod")
        var cancellables = Set<AnyCancellable>()
        
        sut.$selectedOrderMethod
            .first()
            .receive(on: RunLoop.main)
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 5)
        
        let shownRetailStore = try XCTUnwrap(sut.shownRetailStores)
        
        XCTAssertEqual(shownRetailStore, [storeDelivery])
    }
    
    func test_givenStoreWithCollection_whenCollectionIsSelected_thenStoreIsShown() throws {
        let orderMethodDelivery = RetailStoreOrderMethod(name: .delivery, earliestTime: nil, status: .open, cost: nil, fulfilmentIn: nil)
        let orderMethodCollection = RetailStoreOrderMethod(name: .collection, earliestTime: nil, status: .open, cost: nil, fulfilmentIn: nil)
        let fulfilmentLocation = FulfilmentLocation(country: "UK", latitude: 56.473358599999997, longitude: -3.0111853000000002, postcode: "DD1 3JA")
        let storeDelivery = RetailStore(id: 1, storeName: "DeliveryStore", distance: 0, storeLogo: nil, storeProductTypes: nil, orderMethods: ["delivery": orderMethodDelivery], ratings: nil)
        let storeCollection = RetailStore(id: 1, storeName: "CollectionStore", distance: 0, storeLogo: nil, storeProductTypes: nil, orderMethods: ["collection": orderMethodCollection], ratings: nil)
        let search = RetailStoresSearch(storeProductTypes: nil, stores: [storeDelivery, storeCollection], fulfilmentLocation: fulfilmentLocation)
        
        var appState = AppState()
        appState.userData.searchResult = .loaded(search)
        
        let container = DIContainer(appState: appState, services: .mocked())
        
        let sut = makeSUT(container: container)
        
        let expectation = expectation(description: "selectedOrderMethodMethod")
        var cancellables = Set<AnyCancellable>()
        
        sut.selectedOrderMethod = .collection
        
        sut.$selectedOrderMethod
            .first()
            .receive(on: RunLoop.main)
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
        
        let storeDelivery = RetailStore(id: 1, storeName: "DeliveryStore", distance: 0, storeLogo: nil, storeProductTypes: nil, orderMethods: nil, ratings: nil)
        let storeCollection = RetailStore(id: 1, storeName: "CollectionStore", distance: 0, storeLogo: nil, storeProductTypes: nil, orderMethods: nil, ratings: nil)
        let fulfilmentLocation = FulfilmentLocation(country: "UK", latitude: 56.473358599999997, longitude: -3.0111853000000002, postcode: "DD1 3JA")
        let search = RetailStoresSearch(storeProductTypes: nil, stores: [storeDelivery, storeCollection], fulfilmentLocation: fulfilmentLocation)
        sut.container.appState.value.userData.searchResult = .loaded(search)
        
        sut.selectedOrderMethod = .collection
        
        let expectation = expectation(description: "selectedOrderMethodMethod")
        var cancellables = Set<AnyCancellable>()
        
        sut.$selectedOrderMethod
            .first()
            .receive(on: RunLoop.main)
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 5)
        
        let shownRetailStore = try XCTUnwrap(sut.shownRetailStores)
        
        XCTAssertTrue(shownRetailStore.isEmpty)
    }
    
    func test_givenStoreWith2Types_whenButchersIsSelected_ThenOnlyButchersShown() {
        let orderMethod = RetailStoreOrderMethod(name: .delivery, earliestTime: nil, status: .open, cost: nil, fulfilmentIn: nil)
        let orderMethods = ["delivery": orderMethod]
        let storeTypeButchers = RetailStoreProductType(id: 1, name: "Butchers", image: nil)
        let storeButchers = RetailStore(id: 1, storeName: "", distance: 0, storeLogo: nil, storeProductTypes: [1], orderMethods: orderMethods, ratings: nil)
        let storeTypeGroceries = RetailStoreProductType(id: 2, name: "Groceries", image: nil)
        let storeGroceries = RetailStore(id: 1, storeName: "", distance: 0, storeLogo: nil, storeProductTypes: [2], orderMethods: orderMethods, ratings: nil)
        let fulfilmentLocation = FulfilmentLocation(country: "UK", latitude: 56.473358599999997, longitude: -3.0111853000000002, postcode: "DD1 3JA")
        
        let search = RetailStoresSearch(storeProductTypes: [storeTypeButchers, storeTypeGroceries], stores: [storeButchers, storeGroceries], fulfilmentLocation: fulfilmentLocation)
        var appState = AppState()
        appState.userData.searchResult = .loaded(search)
        
        let container = DIContainer(appState: appState, services: .mocked())
        
        let sut = makeSUT(container: container)
        
        sut.filteredRetailStoreType = 1
        
        let expectation = expectation(description: "selectedRetailStoreType")
        var cancellables = Set<AnyCancellable>()
        
        sut.$filteredRetailStoreType
            .first()
            .receive(on: RunLoop.main)
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
        let storeButchers = RetailStore(id: 1, storeName: "", distance: 0, storeLogo: nil, storeProductTypes: [1], orderMethods: orderMethods, ratings: nil)
        let fulfilmentLocation = FulfilmentLocation(country: "UK", latitude: 56.473358599999997, longitude: -3.0111853000000002, postcode: "DD1 3JA")
        
        let search1 = RetailStoresSearch(storeProductTypes: nil, stores: [storeButchers], fulfilmentLocation: fulfilmentLocation)
        
        sut.container.appState.value.userData.searchResult = .loaded(search1)
        
        XCTAssertEqual(sut.storeSearchResult, .loaded(search1))
        
        let storeGroceries = RetailStore(id: 1, storeName: "", distance: 0, storeLogo: nil, storeProductTypes: [2], orderMethods: orderMethods, ratings: nil)
        let search2 = RetailStoresSearch(storeProductTypes: nil, stores: [storeGroceries], fulfilmentLocation: fulfilmentLocation)
        
        sut.container.appState.value.userData.searchResult = .loaded(search2)
        
        let expectation = expectation(description: "retailStores")
        var cancellables = Set<AnyCancellable>()
        
        sut.$retailStores
            .first()
            .receive(on: RunLoop.main)
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
        
        let fulfilmentLocation = FulfilmentLocation(country: "UK", latitude: 0, longitude: 0, postcode: "TN223HY")
        let orderMethodOpen = RetailStoreOrderMethod(name: .delivery, earliestTime: nil, status: .open, cost: nil, fulfilmentIn: nil)
        let orderMethodClosed = RetailStoreOrderMethod(name: .delivery, earliestTime: nil, status: .closed, cost: nil, fulfilmentIn: nil)
        let orderMethodPreorder = RetailStoreOrderMethod(name: .delivery, earliestTime: nil, status: .preorder, cost: nil, fulfilmentIn: nil)
        let storeOpen = RetailStore(id: 1, storeName: "OpenStore", distance: 0, storeLogo: nil, storeProductTypes: nil, orderMethods: ["delivery": orderMethodOpen], ratings: nil)
        let storeClosed = RetailStore(id: 1, storeName: "ClosedStore", distance: 0, storeLogo: nil, storeProductTypes: nil, orderMethods: ["delivery": orderMethodClosed], ratings: nil)
        let storePreorder = RetailStore(id: 1, storeName: "PreorderStore", distance: 0, storeLogo: nil, storeProductTypes: nil, orderMethods: ["delivery": orderMethodPreorder], ratings: nil)
        let search = RetailStoresSearch(storeProductTypes: nil, stores: [storeOpen, storeClosed, storePreorder], fulfilmentLocation: fulfilmentLocation)
        sut.container.appState.value.userData.searchResult = .loaded(search)
        
        let expectation = expectation(description: "setupOrderMethodStatus")
        var cancellables = Set<AnyCancellable>()
        
        sut.$shownRetailStores
            .collect(3)
            .receive(on: RunLoop.main)
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
        
        let fulfilmentLocation = FulfilmentLocation(country: "UK", latitude: 0, longitude: 0, postcode: "TN223HY")
        let orderMethodOpen = RetailStoreOrderMethod(name: .delivery, earliestTime: nil, status: .open, cost: nil, fulfilmentIn: nil)
        let orderMethodClosed = RetailStoreOrderMethod(name: .delivery, earliestTime: nil, status: .closed, cost: nil, fulfilmentIn: nil)
        let storeOpen = RetailStore(id: 1, storeName: "OpenStore", distance: 0, storeLogo: nil, storeProductTypes: nil, orderMethods: ["delivery": orderMethodOpen], ratings: nil)
        let storeClosed = RetailStore(id: 1, storeName: "ClosedStore", distance: 0, storeLogo: nil, storeProductTypes: nil, orderMethods: ["delivery": orderMethodClosed], ratings: nil)
        let search = RetailStoresSearch(storeProductTypes: nil, stores: [storeOpen, storeClosed], fulfilmentLocation: fulfilmentLocation)
        sut.container.appState.value.userData.searchResult = .loaded(search)
        
        let expectation = expectation(description: "setupOrderMethodStatus")
        var cancellables = Set<AnyCancellable>()
        
        sut.$shownRetailStores
            .collect(3)
            .receive(on: RunLoop.main)
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
        
        let fulfilmentLocation = FulfilmentLocation(country: "UK", latitude: 0, longitude: 0, postcode: "TN223HY")
        let orderMethodOpen = RetailStoreOrderMethod(name: .delivery, earliestTime: nil, status: .open, cost: nil, fulfilmentIn: nil)
        let orderMethodClosed = RetailStoreOrderMethod(name: .delivery, earliestTime: nil, status: .closed, cost: nil, fulfilmentIn: nil)
        let orderMethodPreorder = RetailStoreOrderMethod(name: .delivery, earliestTime: nil, status: .preorder, cost: nil, fulfilmentIn: nil)
        let storeOpen = RetailStore(id: 1, storeName: "OpenStore", distance: 0, storeLogo: nil, storeProductTypes: nil, orderMethods: ["delivery": orderMethodOpen], ratings: nil)
        let storeClosed = RetailStore(id: 1, storeName: "ClosedStore", distance: 0, storeLogo: nil, storeProductTypes: nil, orderMethods: ["delivery": orderMethodClosed], ratings: nil)
        let storePreorder = RetailStore(id: 1, storeName: "PreorderStore", distance: 0, storeLogo: nil, storeProductTypes: nil, orderMethods: ["delivery": orderMethodPreorder], ratings: nil)
        let search = RetailStoresSearch(storeProductTypes: nil, stores: [storeOpen, storeClosed, storePreorder], fulfilmentLocation: fulfilmentLocation)
        sut.container.appState.value.userData.searchResult = .loaded(search)
        
        let expectation = expectation(description: "setupOrderMethodStatus")
        var cancellables = Set<AnyCancellable>()
        
        sut.$shownRetailStores
            .collect(3)
            .receive(on: RunLoop.main)
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
        
        let fulfilmentLocation = FulfilmentLocation(country: "UK", latitude: 0, longitude: 0, postcode: "TN223HY")
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
        
        XCTAssertTrue(sut.storesSearchIsLoading)
    }
    
    func test_givenStoreSearchResult_whenLoadedStatus_thenReturnsFalse() {
        let sut = makeSUT()
        sut.storeSearchResult = .loaded(RetailStoresSearch(storeProductTypes: nil, stores: nil, fulfilmentLocation: FulfilmentLocation(country: "", latitude: 0, longitude: 0, postcode: "")))
        
        XCTAssertFalse(sut.storesSearchIsLoading)
    }
    
    func test_whenSelectedOrderMethodIsDelivery_thenIsDeliverySelectedReturnsTrue() {
        let sut = makeSUT()
        sut.selectedOrderMethod = .collection
        
        XCTAssertFalse(sut.isDeliverySelected)
    }
    
    func test_whenFulfilmentMethodButtonTapped_thenUserFulfilmentMethodSet() {
        let sut = makeSUT()
        sut.fulfilmentMethodButtonTapped(.collection)
        XCTAssertEqual(sut.container.appState.value.userData.selectedFulfilmentMethod, .collection)
        sut.fulfilmentMethodButtonTapped(.delivery)
        XCTAssertEqual(sut.container.appState.value.userData.selectedFulfilmentMethod, .delivery)
    }
    
    func test_whenSelectedRetailStoreDetailsSet_giveFulfilmentIsDeliveryAndNoFutureFulfilmentAvailable_thenShowStoreMenuSetToTrueAndShowFulfilmentSlotSelectionSetToFalse() {
        let sut = makeSUT()

        let expectation = expectation(description: "selectedRetailStoreDetailsSet")
        var cancellables = Set<AnyCancellable>()
        
        sut.$selectedRetailStoreDetails
            .first()
            .receive(on: RunLoop.main)
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        let retailStoreDetails = RetailStoreDetails(
            id: 123,
            menuGroupId: 123,
            storeName: "Test Store",
            telephone: "123344",
            lat: 1,
            lng: 1,
            ordersPaused: false,
            canDeliver: true,
            distance: 30,
            pausedMessage: nil,
            address1: "Test address",
            address2: nil,
            town: "Test Town",
            postcode: "TEST",
            customerOrderNotePlaceholder: nil,
            ratings: nil,
            storeLogo: nil,
            storeProductTypes: nil,
            orderMethods: nil,
            deliveryDays: [
                RetailStoreFulfilmentDay(date: Date().trueDate.dateOnlyString(storeTimeZone: nil), holidayMessage: nil, start: nil, end: nil, storeDateStart: nil, storeDateEnd: nil)
            ],
            collectionDays: [],
            timeZone: nil, searchPostcode: nil)
        
        sut.selectStore(id: 123)
        
        sut.selectedRetailStoreDetails = .loaded(retailStoreDetails)
        
        wait(for: [expectation], timeout: 5)
        
        XCTAssertFalse(sut.showFulfilmentSlotSelection)
        XCTAssertTrue(sut.showStoreMenu)
    }
    
    func test_whenSelectedRetailStoreDetailsSet_giveFulfilmentIsDeliveryAndFutureFulfilmentAvailableIs_thenShowStoreMenuSetToFalseAndShowFulfilmentSlotSelectionSetToTrue() {
        let sut = makeSUT()

        let expectation = expectation(description: "selectedRetailStoreDetailsSet")
        var cancellables = Set<AnyCancellable>()
        
        sut.$selectedRetailStoreDetails
            .first()
            .receive(on: RunLoop.main)
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        let retailStoreDetails = RetailStoreDetails(
            id: 123,
            menuGroupId: 123,
            storeName: "Test Store",
            telephone: "123344",
            lat: 1,
            lng: 1,
            ordersPaused: false,
            canDeliver: true,
            distance: 30,
            pausedMessage: nil,
            address1: "Test address",
            address2: nil,
            town: "Test Town",
            postcode: "TEST",
            customerOrderNotePlaceholder: nil,
            ratings: nil,
            storeLogo: nil,
            storeProductTypes: nil,
            orderMethods: nil,
            deliveryDays: [
                RetailStoreFulfilmentDay(date: Date().trueDate.dateOnlyString(storeTimeZone: nil), holidayMessage: nil, start: nil, end: nil, storeDateStart: nil, storeDateEnd: nil),
                RetailStoreFulfilmentDay(date: Date().advanced(by: 86400).trueDate.dateOnlyString(storeTimeZone: nil), holidayMessage: nil, start: nil, end: nil, storeDateStart: nil, storeDateEnd: nil)
            ],
            collectionDays: [],
            timeZone: nil, searchPostcode: nil)
        
        sut.selectStore(id: 123)
        
        sut.selectedRetailStoreDetails = .loaded(retailStoreDetails)
        
        wait(for: [expectation], timeout: 5)
        
        XCTAssertTrue(sut.showFulfilmentSlotSelection)
        XCTAssertFalse(sut.showStoreMenu)
    }
    
    func test_whenSelectedRetailStoreDetailsSet_giveFulfilmentIsCollectionAndNoFutureFulfilmentAvailable_thenShowStoreMenuSetToTrueAndShowFulfilmentSlotSelectionSetToFalse() {
        let sut = makeSUT()

        let expectation = expectation(description: "selectedRetailStoreDetailsSet")
        var cancellables = Set<AnyCancellable>()
        
        sut.selectedOrderMethod = .collection
        
        sut.$selectedRetailStoreDetails
            .first()
            .receive(on: RunLoop.main)
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        let retailStoreDetails = RetailStoreDetails(
            id: 123,
            menuGroupId: 123,
            storeName: "Test Store",
            telephone: "123344",
            lat: 1,
            lng: 1,
            ordersPaused: false,
            canDeliver: true,
            distance: 30,
            pausedMessage: nil,
            address1: "Test address",
            address2: nil,
            town: "Test Town",
            postcode: "TEST",
            customerOrderNotePlaceholder: nil,
            ratings: nil,
            storeLogo: nil,
            storeProductTypes: nil,
            orderMethods: nil,
            deliveryDays: [],
            collectionDays: [
                RetailStoreFulfilmentDay(date: Date().trueDate.dateOnlyString(storeTimeZone: nil), holidayMessage: nil, start: nil, end: nil, storeDateStart: nil, storeDateEnd: nil)
            ],
            timeZone: nil, searchPostcode: nil)
        
        sut.selectStore(id: 123)
        
        sut.selectedRetailStoreDetails = .loaded(retailStoreDetails)
        
        wait(for: [expectation], timeout: 5)
        
        XCTAssertFalse(sut.showFulfilmentSlotSelection)
        XCTAssertTrue(sut.showStoreMenu)
    }
    
    func test_whenSelectedRetailStoreDetailsSet_giveFulfilmentIsCollectionAndFutureFulfilmentAvailableIs_thenShowStoreMenuSetToFalseAndShowFulfilmentSlotSelectionSetToTrue() {
        let sut = makeSUT()

        let expectation = expectation(description: "selectedRetailStoreDetailsSet")
        var cancellables = Set<AnyCancellable>()
        
        sut.selectedOrderMethod = .collection
        
        sut.$selectedRetailStoreDetails
            .first()
            .receive(on: RunLoop.main)
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        let retailStoreDetails = RetailStoreDetails(
            id: 123,
            menuGroupId: 123,
            storeName: "Test Store",
            telephone: "123344",
            lat: 1,
            lng: 1,
            ordersPaused: false,
            canDeliver: true,
            distance: 30,
            pausedMessage: nil,
            address1: "Test address",
            address2: nil,
            town: "Test Town",
            postcode: "TEST",
            customerOrderNotePlaceholder: nil,
            ratings: nil,
            storeLogo: nil,
            storeProductTypes: nil,
            orderMethods: nil,
            deliveryDays: [],
            collectionDays: [
                RetailStoreFulfilmentDay(date: Date().trueDate.dateOnlyString(storeTimeZone: nil), holidayMessage: nil, start: nil, end: nil, storeDateStart: nil, storeDateEnd: nil),
                RetailStoreFulfilmentDay(date: Date().advanced(by: 86400).trueDate.dateOnlyString(storeTimeZone: nil), holidayMessage: nil, start: nil, end: nil, storeDateStart: nil, storeDateEnd: nil)
            ],
            timeZone: nil, searchPostcode: nil)
        
        sut.selectStore(id: 123)
        
        sut.selectedRetailStoreDetails = .loaded(retailStoreDetails)
        
        wait(for: [expectation], timeout: 5)
        
        XCTAssertTrue(sut.showFulfilmentSlotSelection)
        XCTAssertFalse(sut.showStoreMenu)
    }

    func makeSUT(container: DIContainer = DIContainer(appState: AppState(), services: .mocked())) -> StoresViewModel {
        let sut = StoresViewModel(container: container)
        
        trackForMemoryLeaks(sut)
        
        return sut
    }
}
