//
//  StoresViewModelTests.swift
//  SnappyV2Tests
//
//  Created by Henrik Gustavii on 04/10/2021.
//

import XCTest
import Combine
import AppsFlyerLib
import CoreLocation
@testable import SnappyV2

@MainActor
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
        XCTAssertNil(sut.selectedStoreTypeName)
    }
    
    func test_whenSelectedOrderMethodIsDelivery_thenReturnDeliveryString() {
        let sut = makeSUT()
        sut.selectedOrderMethod = .delivery
        XCTAssertEqual(sut.fulfilmentString, GeneralStrings.delivery.localized.lowercased())
    }
    
    func test_whenSelectedOrderMethodIsCollection_thenReturnCollectionString() {
        let sut = makeSUT()
        sut.selectedOrderMethod = .collection
        XCTAssertEqual(sut.fulfilmentString, GeneralStrings.collection.localized.lowercased())
    }

    func test_givenStoreWithDelivery_whenDeliveryIsSelected_thenStoreIsShown() throws {
        let orderMethodDelivery = RetailStoreOrderMethod(name: .delivery, earliestTime: nil, status: .open, cost: nil, fulfilmentIn: nil,
                                                         freeFulfilmentMessage: nil, deliveryTiers: nil, freeFrom: nil, minSpend: nil)
        let orderMethodCollection = RetailStoreOrderMethod(name: .collection, earliestTime: nil, status: .open, cost: nil, fulfilmentIn: nil,
                                                           freeFulfilmentMessage: nil, deliveryTiers: nil, freeFrom: nil, minSpend: nil)
        let fulfilmentLocation = FulfilmentLocation(country: "UK", latitude: 56.473358599999997, longitude: -3.0111853000000002, postcode: "DD1 3JA")
        let storeDelivery = RetailStore(id: 1, storeName: "DeliveryStore", distance: 0, storeLogo: nil, storeProductTypes: nil, orderMethods: ["delivery": orderMethodDelivery], ratings: nil, currency: RetailStoreCurrency.mockedGBPData)
        let storeCollection = RetailStore(id: 1, storeName: "CollectionStore", distance: 0, storeLogo: nil, storeProductTypes: nil, orderMethods: ["collection": orderMethodCollection], ratings: nil, currency: RetailStoreCurrency.mockedGBPData)
        let search = RetailStoresSearch(storeProductTypes: nil, stores: [storeDelivery, storeCollection], fulfilmentLocation: fulfilmentLocation)
        
        var appState = AppState()
        appState.userData.searchResult = .loaded(search)
        
        let container = DIContainer(appState: appState, eventLogger: MockedEventLogger(), services: .mocked())
        
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
        let orderMethodDelivery = RetailStoreOrderMethod(name: .delivery, earliestTime: nil, status: .open, cost: nil, fulfilmentIn: nil,
                                                         freeFulfilmentMessage: nil, deliveryTiers: nil, freeFrom: nil, minSpend: nil)
        let orderMethodCollection = RetailStoreOrderMethod(name: .collection, earliestTime: nil, status: .open, cost: nil, fulfilmentIn: nil,
                                                           freeFulfilmentMessage: nil, deliveryTiers: nil, freeFrom: nil, minSpend: nil)
        let fulfilmentLocation = FulfilmentLocation(country: "UK", latitude: 56.473358599999997, longitude: -3.0111853000000002, postcode: "DD1 3JA")
        let storeDelivery = RetailStore(id: 1, storeName: "DeliveryStore", distance: 0, storeLogo: nil, storeProductTypes: nil, orderMethods: ["delivery": orderMethodDelivery], ratings: nil, currency: RetailStoreCurrency.mockedGBPData)
        let storeCollection = RetailStore(id: 1, storeName: "CollectionStore", distance: 0, storeLogo: nil, storeProductTypes: nil, orderMethods: ["collection": orderMethodCollection], ratings: nil, currency: RetailStoreCurrency.mockedGBPData)
        let search = RetailStoresSearch(storeProductTypes: nil, stores: [storeDelivery, storeCollection], fulfilmentLocation: fulfilmentLocation)
        
        var appState = AppState()
        appState.userData.searchResult = .loaded(search)
        
        let container = DIContainer(appState: appState, eventLogger: MockedEventLogger(), services: .mocked())
        
        let sut = makeSUT(container: container)
        
        let expectation = expectation(description: "selectedOrderMethodMethod")
        var cancellables = Set<AnyCancellable>()
        
        sut.$selectedOrderMethod
            .first()
            .receive(on: RunLoop.main)
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        sut.selectedOrderMethod = .collection
        
        wait(for: [expectation], timeout: 2)
        
        let shownRetailStore = try XCTUnwrap(sut.shownRetailStores)
        
        XCTAssertEqual(shownRetailStore, [storeCollection])
    }
    
    func test_givenStoresWithNoOrderMethods_whenCollectionIsSelected_thenNoStoreIsShown() throws {
        let sut = makeSUT()
        
        let storeDelivery = RetailStore(id: 1, storeName: "DeliveryStore", distance: 0, storeLogo: nil, storeProductTypes: nil, orderMethods: nil, ratings: nil, currency: RetailStoreCurrency.mockedGBPData)
        let storeCollection = RetailStore(id: 1, storeName: "CollectionStore", distance: 0, storeLogo: nil, storeProductTypes: nil, orderMethods: nil, ratings: nil, currency: RetailStoreCurrency.mockedGBPData)
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
        let orderMethod = RetailStoreOrderMethod(name: .delivery, earliestTime: nil, status: .open, cost: nil, fulfilmentIn: nil,
                                                 freeFulfilmentMessage: nil, deliveryTiers: nil, freeFrom: nil, minSpend: nil)
        let orderMethods = ["delivery": orderMethod]
        let storeTypeButchers = RetailStoreProductType(id: 1, name: "Butchers", image: nil)
        let storeButchers = RetailStore(id: 1, storeName: "", distance: 0, storeLogo: nil, storeProductTypes: [1], orderMethods: orderMethods, ratings: nil, currency: RetailStoreCurrency.mockedGBPData)
        let storeTypeGroceries = RetailStoreProductType(id: 2, name: "Groceries", image: nil)
        let storeGroceries = RetailStore(id: 1, storeName: "", distance: 0, storeLogo: nil, storeProductTypes: [2], orderMethods: orderMethods, ratings: nil, currency: RetailStoreCurrency.mockedGBPData)
        let fulfilmentLocation = FulfilmentLocation(country: "UK", latitude: 56.473358599999997, longitude: -3.0111853000000002, postcode: "DD1 3JA")
        
        let search = RetailStoresSearch(storeProductTypes: [storeTypeButchers, storeTypeGroceries], stores: [storeButchers, storeGroceries], fulfilmentLocation: fulfilmentLocation)
        var appState = AppState()
        appState.userData.searchResult = .loaded(search)
        
        let container = DIContainer(appState: appState, eventLogger: MockedEventLogger(), services: .mocked())
        
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
        
        let orderMethod = RetailStoreOrderMethod(name: .delivery, earliestTime: nil, status: .open, cost: nil, fulfilmentIn: nil,
                                                 freeFulfilmentMessage: nil, deliveryTiers: nil, freeFrom: nil, minSpend: nil)
        let orderMethods = ["delivery": orderMethod]
        let storeButchers = RetailStore(id: 1, storeName: "", distance: 0, storeLogo: nil, storeProductTypes: [1], orderMethods: orderMethods, ratings: nil, currency: RetailStoreCurrency.mockedGBPData)
        let fulfilmentLocation = FulfilmentLocation(country: "UK", latitude: 56.473358599999997, longitude: -3.0111853000000002, postcode: "DD1 3JA")
        
        let search1 = RetailStoresSearch(storeProductTypes: nil, stores: [storeButchers], fulfilmentLocation: fulfilmentLocation)
        
        let expectation1 = expectation(description: #function)
        var cancellables = Set<AnyCancellable>()
        
        sut.$retailStores
            .first()
            .receive(on: RunLoop.main)
            .sink { _ in
                expectation1.fulfill()
            }
            .store(in: &cancellables)
        
        sut.container.appState.value.userData.searchResult = .loaded(search1)
        
        wait(for: [expectation1], timeout: 2)
        
        XCTAssertEqual(sut.storeSearchResult, .loaded(search1))
        
        let storeGroceries = RetailStore(id: 1, storeName: "", distance: 0, storeLogo: nil, storeProductTypes: [2], orderMethods: orderMethods, ratings: nil, currency: RetailStoreCurrency.mockedGBPData)
        let search2 = RetailStoresSearch(storeProductTypes: nil, stores: [storeGroceries], fulfilmentLocation: fulfilmentLocation)
        
        sut.container.appState.value.userData.searchResult = .loaded(search2)
        
        let expectation = expectation(description: "retailStores")
        
        sut.$retailStores
            .first()
            .receive(on: RunLoop.main)
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 2)
        
        XCTAssertEqual(sut.shownRetailStores.count, 1)
        XCTAssertEqual(sut.shownRetailStores.first, storeGroceries)
    }
    
    func test_whenStoreIsOpen_thenShowsInCorrectSection() {
        let sut = makeSUT()
        
        let fulfilmentLocation = FulfilmentLocation(country: "UK", latitude: 0, longitude: 0, postcode: "TN223HY")
        let orderMethodOpen = RetailStoreOrderMethod(name: .delivery, earliestTime: nil, status: .open, cost: nil, fulfilmentIn: nil,
                                                     freeFulfilmentMessage: nil, deliveryTiers: nil, freeFrom: nil, minSpend: nil)
        let orderMethodClosed = RetailStoreOrderMethod(name: .delivery, earliestTime: nil, status: .closed, cost: nil, fulfilmentIn: nil,
                                                       freeFulfilmentMessage: nil, deliveryTiers: nil, freeFrom: nil, minSpend: nil)
        let orderMethodPreorder = RetailStoreOrderMethod(name: .delivery, earliestTime: nil, status: .preorder, cost: nil, fulfilmentIn: nil,
                                                         freeFulfilmentMessage: nil, deliveryTiers: nil, freeFrom: nil, minSpend: nil)
        let storeOpen = RetailStore(id: 1, storeName: "OpenStore", distance: 0, storeLogo: nil, storeProductTypes: nil, orderMethods: ["delivery": orderMethodOpen], ratings: nil, currency: RetailStoreCurrency.mockedGBPData)
        let storeClosed = RetailStore(id: 1, storeName: "ClosedStore", distance: 0, storeLogo: nil, storeProductTypes: nil, orderMethods: ["delivery": orderMethodClosed], ratings: nil, currency: RetailStoreCurrency.mockedGBPData)
        let storePreorder = RetailStore(id: 1, storeName: "PreorderStore", distance: 0, storeLogo: nil, storeProductTypes: nil, orderMethods: ["delivery": orderMethodPreorder], ratings: nil, currency: RetailStoreCurrency.mockedGBPData)
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
        
        XCTAssertEqual(sut.showOpenStores.count, 1)
        XCTAssertEqual(sut.showOpenStores.first, storeOpen)
    }
    
    func test_whenStoreIsClosed_thenShowsInCorrectSection() {
        let sut = makeSUT()
        
        let fulfilmentLocation = FulfilmentLocation(country: "UK", latitude: 0, longitude: 0, postcode: "TN223HY")
        let orderMethodOpen = RetailStoreOrderMethod(name: .delivery, earliestTime: nil, status: .open, cost: nil, fulfilmentIn: nil,
                                                     freeFulfilmentMessage: nil, deliveryTiers: nil, freeFrom: nil, minSpend: nil)
        let orderMethodClosed = RetailStoreOrderMethod(name: .delivery, earliestTime: nil, status: .closed, cost: nil, fulfilmentIn: nil,
                                                       freeFulfilmentMessage: nil, deliveryTiers: nil, freeFrom: nil, minSpend: nil)
        let storeOpen = RetailStore(id: 1, storeName: "OpenStore", distance: 0, storeLogo: nil, storeProductTypes: nil, orderMethods: ["delivery": orderMethodOpen], ratings: nil, currency: RetailStoreCurrency.mockedGBPData)
        let storeClosed = RetailStore(id: 1, storeName: "ClosedStore", distance: 0, storeLogo: nil, storeProductTypes: nil, orderMethods: ["delivery": orderMethodClosed], ratings: nil, currency: RetailStoreCurrency.mockedGBPData)
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
        let orderMethodOpen = RetailStoreOrderMethod(name: .delivery, earliestTime: nil, status: .open, cost: nil, fulfilmentIn: nil,
                                                     freeFulfilmentMessage: nil, deliveryTiers: nil, freeFrom: nil, minSpend: nil)
        let orderMethodClosed = RetailStoreOrderMethod(name: .delivery, earliestTime: nil, status: .closed, cost: nil, fulfilmentIn: nil,
                                                       freeFulfilmentMessage: nil, deliveryTiers: nil, freeFrom: nil, minSpend: nil)
        let orderMethodPreorder = RetailStoreOrderMethod(name: .delivery, earliestTime: nil, status: .preorder, cost: nil, fulfilmentIn: nil,
                                                         freeFulfilmentMessage: nil, deliveryTiers: nil, freeFrom: nil, minSpend: nil)
        let storeOpen = RetailStore(id: 1, storeName: "OpenStore", distance: 0, storeLogo: nil, storeProductTypes: nil, orderMethods: ["delivery": orderMethodOpen], ratings: nil, currency: RetailStoreCurrency.mockedGBPData)
        let storeClosed = RetailStore(id: 1, storeName: "ClosedStore", distance: 0, storeLogo: nil, storeProductTypes: nil, orderMethods: ["delivery": orderMethodClosed], ratings: nil, currency: RetailStoreCurrency.mockedGBPData)
        let storePreorder = RetailStore(id: 1, storeName: "PreorderStore", distance: 0, storeLogo: nil, storeProductTypes: nil, orderMethods: ["delivery": orderMethodPreorder], ratings: nil, currency: RetailStoreCurrency.mockedGBPData)
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
    
    func test_addFilteredStoreType() {
        let sut = makeSUT()
        
        sut.selectFilteredRetailStoreType(id: 11)
        
        XCTAssertEqual(sut.filteredRetailStoreType, 11)
    }
    
    func test_whenStoreTypeFiltered_thenSelectedStoreTypeNamePopulated() {
        let sut = makeSUT()
        sut.retailStoreTypes = RetailStoreProductType.mockedData
        
        sut.selectFilteredRetailStoreType(id: 21)
        
        XCTAssertEqual(sut.filteredRetailStoreType, 21)
        XCTAssertEqual(sut.selectedStoreTypeName, "convenience stores")
    }
    
    func test_whenNoStoresFound_thenShowNoStoresAvailableMessageIsTrue() {
        let sut = makeSUT()
        sut.showOpenStores = []
        sut.showPreorderStores = []
        sut.showClosedStores = []
        
        XCTAssertTrue(sut.showNoStoresAvailableMessage)
    }
    
    func test_whenAtLeastSomeStoresFound_thenShowNoStoresAvailableMessageIsFalse() {
        let sut = makeSUT()
        sut.showOpenStores = RetailStore.mockedData
        sut.showPreorderStores = []
        sut.showClosedStores = []
        
        XCTAssertFalse(sut.showNoStoresAvailableMessage)
    }
    
    func test_whenMoreThan1StoreType_thenShowStoreTypesIsTrue() {
        let sut = makeSUT()
        sut.retailStoreTypes = RetailStoreProductType.mockedData
        
        XCTAssertTrue(sut.showStoreTypes)
    }
    
    func test_whenOnly1StoreType_thenShowStoreTypesIsFalse() {
        let sut = makeSUT()
        sut.retailStoreTypes = RetailStoreProductType.mockedDataOne1StoreType
        
        XCTAssertFalse(sut.showStoreTypes)
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
        
        let expectation1 = expectation(description: #function)
        var cancellables = Set<AnyCancellable>()
        
        sut.container.appState
            .map(\.userData.selectedFulfilmentMethod)
            .first()
            .receive(on: RunLoop.main)
            .sink { _ in
                expectation1.fulfill()
            }
            .store(in: &cancellables)
        
        sut.fulfilmentMethodButtonTapped(.collection)
        
        wait(for: [expectation1], timeout: 2)
            
        XCTAssertEqual(sut.container.appState.value.userData.selectedFulfilmentMethod, .collection)
        
        let expectation2 = expectation(description: #function)
        
        sut.container.appState
            .map(\.userData.selectedFulfilmentMethod)
            .first()
            .receive(on: RunLoop.main)
            .sink { _ in
                expectation2.fulfill()
            }
            .store(in: &cancellables)
        
        sut.fulfilmentMethodButtonTapped(.delivery)
        
        wait(for: [expectation2], timeout: 2)
        
        XCTAssertEqual(sut.container.appState.value.userData.selectedFulfilmentMethod, .delivery)
    }
    
    func test_whenSelectedRetailStoreDetailsSet_givenFulfilmentIsDeliveryAndNoFutureFulfilmentAvailable_thenShowStoreMenuSetToTrueAndShowFulfilmentSlotSelectionSetToFalse() async {
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
        
        let retailStoreDetails = RetailStoreDetails.mockedData

        await sut.selectStore(id: 123)
        
        sut.selectedRetailStoreDetails = .loaded(retailStoreDetails)
        
        wait(for: [expectation], timeout: 2)
        
        XCTAssertFalse(sut.showFulfilmentSlotSelection)
        XCTAssertEqual(sut.storeLoadingId, 123)
    }
    
    func test_whenSelectedRetailStoreDetailsSet_givenFulfilmentIsDeliveryAndFutureFulfilmentAvailableIs_thenShowStoreMenuSetToFalseAndShowFulfilmentSlotSelectionSetToTrue() async {
        let sut = makeSUT()
        sut.storeSearchResult = .loaded(RetailStoresSearch.mockedData)

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
            memberEmailCheck: false,
            guestCheckoutAllowed: true,
            basketOnlyTimeSelection: false,
            ratings: nil,
            tips: nil,
            storeLogo: nil,
            storeProductTypes: nil,
            orderMethods: nil,
            deliveryDays: [
                RetailStoreFulfilmentDay(date: Date().trueDate.dateOnlyString(storeTimeZone: nil), holidayMessage: nil, start: nil, end: nil, storeDateStart: nil, storeDateEnd: nil),
                RetailStoreFulfilmentDay(date: Date().advanced(by: 86400).trueDate.dateOnlyString(storeTimeZone: nil), holidayMessage: nil, start: nil, end: nil, storeDateStart: nil, storeDateEnd: nil)
            ],
            collectionDays: [],
            paymentMethods: nil,
            paymentGateways: nil,
            allowedMarketingChannels: [],
            timeZone: nil,
            currency: RetailStoreCurrency.mockedGBPData,
            retailCustomer: nil,
            searchPostcode: nil
        )
        
        sut.selectedRetailStoreDetails = .loaded(retailStoreDetails)
        
        let expectation = expectation(description: #function)
        var cancellables = Set<AnyCancellable>()
        
        sut.$showFulfilmentSlotSelection
            .first()
            .receive(on: RunLoop.main)
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        await sut.selectStore(id: 123)
        
        wait(for: [expectation], timeout: 5)
        
        XCTAssertTrue(sut.showFulfilmentSlotSelection)
    }
    
    func test_whenSelectedRetailStoreDetailsSet_givenFulfilmentIsCollectionAndNoFutureFulfilmentAvailable_thenShowStoreMenuSetToTrueAndShowFulfilmentSlotSelectionSetToFalse() async {
        let storeSearch = RetailStoresSearch.mockedData
        let appState = AppState(system: AppState.System(), routing: AppState.ViewRouting(), businessData: AppState.BusinessData(), userData: AppState.UserData(selectedStore: .notRequested, selectedFulfilmentMethod: .collection, searchResult: .loaded(storeSearch), basket: nil, currentFulfilmentLocation: nil, tempTodayTimeSlot: nil, basketDeliveryAddress: nil, memberProfile: nil), notifications: AppState.Notifications())
        let container  = DIContainer(appState: appState, eventLogger: MockedEventLogger(), services: .mocked())
        let sut = makeSUT(container: container)
        
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
            memberEmailCheck: false,
            guestCheckoutAllowed: true,
            basketOnlyTimeSelection: false,
            ratings: nil,
            tips: nil,
            storeLogo: nil,
            storeProductTypes: nil,
            orderMethods: nil,
            deliveryDays: [],
            collectionDays: [],
            paymentMethods: nil,
            paymentGateways: nil,
            allowedMarketingChannels: [],
            timeZone: nil,
            currency: RetailStoreCurrency.mockedGBPData,
            retailCustomer: nil,
            searchPostcode: nil
        )
        
        sut.selectedRetailStoreDetails = .loaded(retailStoreDetails)
        await sut.selectStore(id: 123)

        XCTAssertEqual(sut.container.appState.value.routing.selectedTab, .menu)
    }
    
    func test_whenSelectedRetailStoreDetailsSet_giveFulfilmentIsCollectionAndFutureFulfilmentAvailableIsTrue_thenShowStoreMenuSetToFalseAndShowFulfilmentSlotSelectionSetToTrue() async {
        let sut = makeSUT()

        sut.selectedOrderMethod = .collection

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
            memberEmailCheck: false,
            guestCheckoutAllowed: true,
            basketOnlyTimeSelection: false,
            ratings: nil,
            tips: nil,
            storeLogo: nil,
            storeProductTypes: nil,
            orderMethods: nil,
            deliveryDays: [],
            collectionDays: [
                RetailStoreFulfilmentDay(date: Date().trueDate.dateOnlyString(storeTimeZone: nil), holidayMessage: nil, start: nil, end: nil, storeDateStart: nil, storeDateEnd: nil),
                RetailStoreFulfilmentDay(date: Date().advanced(by: 86400).trueDate.dateOnlyString(storeTimeZone: nil), holidayMessage: nil, start: nil, end: nil, storeDateStart: nil, storeDateEnd: nil)
            ],
            paymentMethods: nil,
            paymentGateways: nil,
            allowedMarketingChannels: [],
            timeZone: nil,
            currency: RetailStoreCurrency.mockedGBPData,
            retailCustomer: nil,
            searchPostcode: nil
        )
        
        sut.storeSearchResult = .loaded(.mockedData)
        sut.selectedRetailStoreDetails = .loaded(retailStoreDetails)
        
        await sut.selectStore(id: 123)
        
        XCTAssertTrue(sut.showFulfilmentSlotSelection)
    }
    
    func test_whenOrderMethodIsDelivery_givenNoDeliverySlotsAvailableAndselectStoreIsFired_thenShowNoSlotsAvailableerrorIsTrue() async {
        let sut = makeSUT()
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
            memberEmailCheck: false,
            guestCheckoutAllowed: true,
            basketOnlyTimeSelection: false,
            ratings: nil,
            tips: nil,
            storeLogo: nil,
            storeProductTypes: nil,
            orderMethods: nil,
            deliveryDays: [],
            collectionDays: [
                RetailStoreFulfilmentDay(date: Date().trueDate.dateOnlyString(storeTimeZone: nil), holidayMessage: nil, start: nil, end: nil, storeDateStart: nil, storeDateEnd: nil),
                RetailStoreFulfilmentDay(date: Date().advanced(by: 86400).trueDate.dateOnlyString(storeTimeZone: nil), holidayMessage: nil, start: nil, end: nil, storeDateStart: nil, storeDateEnd: nil)
            ],
            paymentMethods: nil,
            paymentGateways: nil,
            allowedMarketingChannels: [],
            timeZone: nil,
            currency: RetailStoreCurrency.mockedGBPData,
            retailCustomer: nil,
            searchPostcode: nil)
        
        let orderMethod = RetailStoreOrderMethod(name: .delivery, earliestTime: nil, status: .open, cost: nil, fulfilmentIn: nil,
                                                 freeFulfilmentMessage: nil, deliveryTiers: nil, freeFrom: nil, minSpend: nil)
        let orderMethods = ["delivery": orderMethod]
        let storeButchers = RetailStore(id: 1, storeName: "", distance: 0, storeLogo: nil, storeProductTypes: [1], orderMethods: orderMethods, ratings: nil, currency: RetailStoreCurrency.mockedGBPData)
        let fulfilmentLocation = FulfilmentLocation(country: "UK", latitude: 56.473358599999997, longitude: -3.0111853000000002, postcode: "DD1 3JA")
        
        let search1 = RetailStoresSearch(storeProductTypes: nil, stores: [storeButchers], fulfilmentLocation: fulfilmentLocation)

        sut.selectedRetailStoreDetails = .loaded(retailStoreDetails)
        sut.storeSearchResult = .loaded(search1)
        
        await sut.selectStore(id: 123)

        XCTAssertEqual(sut.container.appState.value.routing.selectedTab, .menu)
    }
    
    func test_whenOrderMethodIsCollection_givenNoCollectionSlotsAvailableAndselectStoreIsFired_thenShowNoSlotsAvailableerrorIsTrue() async {
        let sut = makeSUT()
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
            memberEmailCheck: false,
            guestCheckoutAllowed: true,
            basketOnlyTimeSelection: false,
            ratings: nil,
            tips: nil,
            storeLogo: nil,
            storeProductTypes: nil,
            orderMethods: nil,
            deliveryDays: [
                RetailStoreFulfilmentDay(date: Date().trueDate.dateOnlyString(storeTimeZone: nil), holidayMessage: nil, start: nil, end: nil, storeDateStart: nil, storeDateEnd: nil),
                RetailStoreFulfilmentDay(date: Date().advanced(by: 86400).trueDate.dateOnlyString(storeTimeZone: nil), holidayMessage: nil, start: nil, end: nil, storeDateStart: nil, storeDateEnd: nil)
            ],
            collectionDays: [],
            paymentMethods: nil,
            paymentGateways: nil,
            allowedMarketingChannels: [],
            timeZone: nil,
            currency: RetailStoreCurrency.mockedGBPData,
            retailCustomer: nil,
            searchPostcode: nil)
        
        let orderMethod = RetailStoreOrderMethod(name: .collection, earliestTime: nil, status: .open, cost: nil, fulfilmentIn: nil,
                                                 freeFulfilmentMessage: nil, deliveryTiers: nil, freeFrom: nil, minSpend: nil)
        let orderMethods = ["collection": orderMethod]
        let storeButchers = RetailStore(id: 1, storeName: "", distance: 0, storeLogo: nil, storeProductTypes: [1], orderMethods: orderMethods, ratings: nil, currency: RetailStoreCurrency.mockedGBPData)
        let fulfilmentLocation = FulfilmentLocation(country: "UK", latitude: 56.473358599999997, longitude: -3.0111853000000002, postcode: "DD1 3JA")
        
        let search1 = RetailStoresSearch(storeProductTypes: nil, stores: [storeButchers], fulfilmentLocation: fulfilmentLocation)

        sut.selectedOrderMethod = .collection

        sut.selectedRetailStoreDetails = .loaded(retailStoreDetails)
        sut.storeSearchResult = .loaded(search1)
        await sut.selectStore(id: 123)

        XCTAssertEqual(sut.container.appState.value.routing.selectedTab, .menu)
    }

	func test_givenEmail_whenSendNotificationTapped_thenFutureContactRequestCalled() async {
        var appState = AppState()
        let searchResult = RetailStoresSearch.mockedData
        let email: String = "someone@me.com"
        appState.userData.searchResult = .loaded(searchResult)
        let params: [String: Any] = [
            "contact_postcode":searchResult.fulfilmentLocation.postcode,
            AFEventParamLat:searchResult.fulfilmentLocation.latitude,
            AFEventParamLong:searchResult.fulfilmentLocation.longitude
        ]
        let eventLogger = MockedEventLogger(expected: [.sendEvent(for: .futureContact, with: .appsFlyer, params: params)])
        let container = DIContainer(appState: appState, eventLogger: eventLogger, services: .mocked(retailStoreService: [.futureContactRequest(email: email)]))
        let sut = makeSUT(container: container)
        sut.emailToNotify = email
        
        await sut.sendNotificationEmail()
        
        XCTAssertTrue(sut.successfullyRegisteredForNotifications)
        container.services.verify(as: .retailStore)
    }
    
    func test_whenOnAppearSendEvenTriggered_thenAppsFlyerEventCalled() {
        let eventLogger = MockedEventLogger(expected: [.sendEvent(for: .viewScreen(.outside, .storeListSelection), with: .appsFlyer, params: [:])])
        let container = DIContainer(appState: AppState(), eventLogger: eventLogger, services: .mocked())
        let sut = makeSUT(container: container)
        
        sut.onAppearSendEvent()
        
        eventLogger.verify()
    }
    
    // When store selected, if status is closed, go straight to store menu
    func test_whenSelectStoreCalled_givenStoreIsClosed_thenNavigateToStoreMenu() async {
        let container = DIContainer(appState: AppState(), eventLogger: MockedEventLogger(), services: .mocked())
        
        let store = RetailStoreDetails.mockedDataWithClosedDeliveryStatus

        container.appState.value.userData.selectedStore = .loaded(store)
        
        let sut = makeSUT(container: container)

        sut.selectedRetailStoreDetails = .loaded(store)
        sut.storeSearchResult = .loaded(.mockedData)
        await sut.selectStore(id: store.id)

        XCTAssertEqual(container.appState.value.routing.selectedTab, .menu)
    }
    
    // When store selected -> status NOT closed -> fulfilmentDays count is 1 -> only fulfilment date is today ->-> reserve today's timeslot, navigate to store menu
    
    func test_whenSelectStoreCalled_givenOnlyOneFulfilmentDateAndThatDateIsToday_thenReserveTodaysTimeslotAndNavigateToStoreMenu() async {
        let store = RetailStoreDetails.mockedDataOnlyTodayDelivery
        
        let container = DIContainer(appState: AppState(), eventLogger: MockedEventLogger(), services: .mocked(basketService: [.reserveTimeSlot(timeSlotDate: Date().dateOnlyString(storeTimeZone: TimeZone.current), timeSlotTime: nil)]))

        container.appState.value.userData.selectedStore = .loaded(store)
        
        let sut = makeSUT(container: container)

        sut.selectedRetailStoreDetails = .loaded(store)
        sut.storeSearchResult = .loaded(.mockedData)
        await sut.selectStore(id: store.id)

        XCTAssertEqual(container.appState.value.routing.selectedTab, .menu)
        container.services.verify(as: .basket)
    }
    
    func test_givenBasketAndOnlyOneFulfilmentDateAndThatDateIsToday_whenSelectStoreCalled_thenReserveTodaysTimeslotAndNavigateToStoreMenuAndCorrectServiceCalls() async {
        let store = RetailStoreDetails.mockedDataOnlyTodayDelivery
        let basket = Basket.mockedData
        
        let container = DIContainer(appState: AppState(), eventLogger: MockedEventLogger(), services: .mocked(retailStoreService: [.getStoreDetails(storeId: store.id, postcode: store.searchPostcode ?? "")], basketService: [.restoreBasket, .reserveTimeSlot(timeSlotDate: Date().dateOnlyString(storeTimeZone: TimeZone.current), timeSlotTime: nil)]))
        
        container.appState.value.userData.selectedStore = .loaded(store)
        container.appState.value.userData.basket = basket
        
        let sut = makeSUT(container: container)

        sut.selectedRetailStoreDetails = .loaded(store)
        sut.storeSearchResult = .loaded(.mockedData)
        await sut.selectStore(id: store.id)

        XCTAssertEqual(container.appState.value.routing.selectedTab, .menu)
        container.services.verify(as: .retailStore)
        container.services.verify(as: .basket)
    }
    
    func test_whenPostcodeErrorPresent_whenPostcodeTextChanged_thenErrorResetToFalse() {
        let sut = makeSUT()
        var cancellables = Set<AnyCancellable>()
        sut.invalidPostcodeError = true
        sut.postcodeSearchString = "TES"
        
        sut.$postcodeSearchString
            .dropFirst()
            .first()
            .sink { _ in
                XCTAssertFalse(sut.invalidPostcodeError)
            }
            .store(in: &cancellables)
    }

    func test_whenUserTapsLocationSearch_thenLocationManagerRetrievesUpdatedLocation() async {
        let testLocation = CLLocation(latitude: CLLocationDegrees(60.15340293), longitude: CLLocationDegrees(-1.14356283)) //Lerwick, Shetland
        let sut = makeSUT(locationAuthorisationStatus: .authorizedWhenInUse, testLocation: testLocation)
        
        await sut.searchViaLocationTapped()
        
        XCTAssertEqual(sut.locationManager.lastLocation, testLocation)
    }
    
    func test_givenNoAccessToLocationData_whenUserSearchesLocation_thenLocationDeniedAlertShown() async {
        let sut = makeSUT(locationAuthorisationStatus: .denied)
        
        await sut.searchViaLocationTapped()
        XCTAssertTrue(sut.locationManager.showDeniedLocationAlert)
    }
    
    func test_givenDetectedLocationIsUnknownAndUserIsAuthorised_whenUserSearchesLocation_thenLocationUnknownAlertShown() async {
        let sut = makeSUT(locationAuthorisationStatus: .authorizedAlways, testLocation: nil)
        await sut.searchViaLocationTapped()
        
        XCTAssertTrue(sut.locationManager.showLocationUnknownAlert)
    }
    
    /*Location manager is difficult to mock via protocols, so it is being partially mocked by subclassing the real locationManager
     and manually passing in the location/authorisation data required for testing. */
    func makeSUT(container: DIContainer = DIContainer(appState: AppState(), eventLogger: MockedEventLogger(), services: .mocked()),
                 locationAuthorisationStatus: CLAuthorizationStatus = .notDetermined,
                 testLocation: CLLocation? = nil) -> StoresViewModel {
        
        let mockedLocationManager = MockedLocationManager(locationAuthStatus: locationAuthorisationStatus, setLocation: testLocation)
        let sut = StoresViewModel(container: container, locationManager: mockedLocationManager)
        
        trackForMemoryLeaks(sut)
        
        return sut
    }
}
