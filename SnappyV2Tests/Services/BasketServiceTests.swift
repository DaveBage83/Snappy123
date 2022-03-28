//
//  BasketServiceTests.swift
//  SnappyV2Tests
//
//  Created by Kevin Palser on 30/01/2022.
//

import XCTest
import Combine
@testable import SnappyV2

class BasketServiceTests: XCTestCase {
    
    var appState = CurrentValueSubject<AppState, Never>(AppState())
    var mockedWebRepo: MockedBasketWebRepository!
    var mockedDBRepo: MockedBasketDBRepository!
    var subscriptions = Set<AnyCancellable>()
    var sut: BasketService!

    override func setUp() {
        mockedWebRepo = MockedBasketWebRepository()
        mockedDBRepo = MockedBasketDBRepository()
        sut = BasketService(
            webRepository: mockedWebRepo,
            dbRepository: mockedDBRepo,
            appState: appState
        )
    }
    
    func delay(_ closure: @escaping () -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: closure)
    }

    override func tearDown() {
        appState = CurrentValueSubject<AppState, Never>(AppState())
        subscriptions = Set<AnyCancellable>()
        mockedWebRepo = nil
        mockedDBRepo = nil
        sut = nil
    }
}

// MARK: - func restoreBasket()
final class RestoreBasketTests: BasketServiceTests {
    
    func test_unsuccessRestoreBasket_whenNoSelectedStore_returnError() {
        
        let exp = XCTestExpectation(description: #function)
        sut
            .restoreBasket()
            .sinkToResult { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success:
                    XCTFail("Unexpected result: \(result)", file: #file, line: #line)
                case let .failure(error):
                    if let basketError = error as? BasketServiceError {
                        XCTAssertEqual(basketError, BasketServiceError.storeSelectionRequired, file: #file, line: #line)
                    } else {
                        XCTFail("Unexpected error type: \(error)", file: #file, line: #line)
                    }
                }
                self.mockedWebRepo.verify()
                self.mockedDBRepo.verify()
                exp.fulfill()
            }
            .store(in: &subscriptions)

        wait(for: [exp], timeout: 0.5)
    }
    
    func test_successRestoreBasket_whenNoBasketToRestore_returnNil() {
        
        let store = RetailStoreDetails.mockedData
        
        // Configuring app prexisting states
        appState.value.userData.selectedStore = .loaded(store)
        appState.value.userData.selectedFulfilmentMethod = .delivery
        
        // Configuring expected actions on repositories

        mockedDBRepo.actions = .init(expected: [
            .fetchBasket
        ])

        // Configuring responses from repositories

        mockedDBRepo.fetchBasketResult = .success(nil)
        
        let exp = XCTestExpectation(description: #function)
        sut
            .restoreBasket()
            .sinkToResult { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success:
                    XCTAssertEqual(self.appState.value.userData.basket, nil, file: #file, line: #line)
                case let .failure(error):
                    XCTFail("Unexpected error: \(error)", file: #file, line: #line)
                }
                self.mockedWebRepo.verify()
                self.mockedDBRepo.verify()
                exp.fulfill()
            }
            .store(in: &subscriptions)

        wait(for: [exp], timeout: 0.5)
    }
    
    func test_successRestoreBasket_whenBasketToRestore_setAppStateBasket() {
        
        let basket = Basket.mockedData
        let store = RetailStoreDetails.mockedData
        
        // Configuring app prexisting states
        appState.value.userData.selectedStore = .loaded(store)
        appState.value.userData.selectedFulfilmentMethod = .delivery
        
        // Configuring expected actions on repositories

        mockedWebRepo.actions = .init(expected: [
            .getBasket(
                basketToken: basket.basketToken,
                storeId: store.id,
                fulfilmentMethod: appState.value.userData.selectedFulfilmentMethod,
                fulfilmentLocation: nil,
                isFirstOrder: true
            )
        ])
        mockedDBRepo.actions = .init(expected: [
            .fetchBasket,
            .clearBasket,
            .store(basket: basket)
        ])

        // Configuring responses from repositories

        mockedWebRepo.getBasketResponse = .success(basket)
        mockedDBRepo.fetchBasketResult = .success(basket)
        mockedDBRepo.clearBasketResult = .success(true)
        mockedDBRepo.storeBasketResult = .success(basket)
        
        let exp = XCTestExpectation(description: #function)
        sut
            .restoreBasket()
            .sinkToResult { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success:
                    XCTAssertEqual(self.appState.value.userData.basket, basket, file: #file, line: #line)
                case let .failure(error):
                    XCTFail("Unexpected error: \(error)", file: #file, line: #line)
                }
                self.mockedWebRepo.verify()
                self.mockedDBRepo.verify()
                exp.fulfill()
            }
            .store(in: &subscriptions)

        wait(for: [exp], timeout: 0.5)
    }
    
    func test_unsuccessRestoreBasket_whenOldBasketInDBAndNetworkError_returnError() {
        
        let networkError = NSError(domain: NSURLErrorDomain, code: -1009, userInfo: [:])
        let basket = Basket.mockedData
        let store = RetailStoreDetails.mockedData
        
        // Configuring app prexisting states
        appState.value.userData.selectedStore = .loaded(store)
        appState.value.userData.selectedFulfilmentMethod = .delivery
        
        // Configuring expected actions on repositories

        mockedWebRepo.actions = .init(expected: [
            .getBasket(
                basketToken: basket.basketToken,
                storeId: store.id,
                fulfilmentMethod: appState.value.userData.selectedFulfilmentMethod,
                fulfilmentLocation: nil,
                isFirstOrder: true
            )
        ])
        mockedDBRepo.actions = .init(expected: [
            .fetchBasket
        ])

        // Configuring responses from repositories

        mockedWebRepo.getBasketResponse = .failure(networkError)
        mockedDBRepo.fetchBasketResult = .success(basket)
        
        let exp = XCTestExpectation(description: #function)
        sut
            .restoreBasket()
            .sinkToResult { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success:
                    XCTFail("Unexpected result: \(result)", file: #file, line: #line)
                case let .failure(error):
                    XCTAssertEqual(error as NSError, networkError, file: #file, line: #line)
                }
                self.mockedWebRepo.verify()
                self.mockedDBRepo.verify()
                exp.fulfill()
            }
            .store(in: &subscriptions)

        wait(for: [exp], timeout: 0.5)
    }
    
}

// MARK: - func updateFulfilmentMethodAndStore()
final class UpdateFulfilmentMethodAndStoreTests: BasketServiceTests {
    
    func test_unsuccessUpdateFulfilmentMethodAndStore_whenNoStoreSelected_returnError() {
        
        let exp = XCTestExpectation(description: #function)
        sut
            .updateFulfilmentMethodAndStore()
            .sinkToResult { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success:
                    XCTFail("Unexpected result: \(result)", file: #file, line: #line)
                case let .failure(error):
                    if let basketError = error as? BasketServiceError {
                        XCTAssertEqual(basketError, BasketServiceError.storeSelectionRequired, file: #file, line: #line)
                    } else {
                        XCTFail("Unexpected error type: \(error)", file: #file, line: #line)
                    }
                }
                self.mockedWebRepo.verify()
                self.mockedDBRepo.verify()
                exp.fulfill()
            }
            .store(in: &subscriptions)

        wait(for: [exp], timeout: 0.5)
    }
    
    func test_unsuccessUpdateFulfilmentMethodAndStore_whenSelectedStoreAndNoFulfilmentLocation_returnError() {
        
        let store = RetailStoreDetails.mockedData
        
        // Configuring app prexisting states
        appState.value.userData.selectedStore = .loaded(store)
        
        let exp = XCTestExpectation(description: #function)
        sut
            .updateFulfilmentMethodAndStore()
            .sinkToResult { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success:
                    XCTFail("Unexpected result: \(result)", file: #file, line: #line)
                case let .failure(error):
                    if let basketError = error as? BasketServiceError {
                        XCTAssertEqual(basketError, BasketServiceError.fulfilmentLocationRequired, file: #file, line: #line)
                    } else {
                        XCTFail("Unexpected error type: \(error)", file: #file, line: #line)
                    }
                }
                self.mockedWebRepo.verify()
                self.mockedDBRepo.verify()
                exp.fulfill()
            }
            .store(in: &subscriptions)

        wait(for: [exp], timeout: 0.5)
    }
    
    func test_successUpdateFulfilmentMethodAndStore_whenSelectedStoreAndFulfilmentLocationWithoutBasket_setAppStateBasket() {
        
        let store = RetailStoreDetails.mockedData
        let searchResult = RetailStoresSearch.mockedData
        let basket = Basket.mockedData
        
        // Configuring app prexisting states
        appState.value.userData.selectedStore = .loaded(store)
        appState.value.userData.searchResult = .loaded(searchResult)
        
        mockedWebRepo.actions = .init(expected: [
            .getBasket(
                basketToken: nil,
                storeId: store.id,
                fulfilmentMethod: appState.value.userData.selectedFulfilmentMethod,
                fulfilmentLocation: searchResult.fulfilmentLocation,
                isFirstOrder: true
            )
        ])
        mockedDBRepo.actions = .init(expected: [
            .clearBasket,
            .store(basket: basket)
        ])
        
        // Configuring responses from repositories
        mockedWebRepo.getBasketResponse = .success(basket)
        mockedDBRepo.clearBasketResult = .success(true)
        mockedDBRepo.storeBasketResult = .success(basket)
        
        let exp = XCTestExpectation(description: #function)
        sut
            .updateFulfilmentMethodAndStore()
            .sinkToResult { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success:
                    XCTAssertEqual(self.appState.value.userData.basket, basket, file: #file, line: #line)
                case let .failure(error):
                    XCTFail("Unexpected error: \(error)", file: #file, line: #line)
                }
                self.mockedWebRepo.verify()
                self.mockedDBRepo.verify()
                exp.fulfill()
            }
            .store(in: &subscriptions)

        wait(for: [exp], timeout: 0.5)
    }
    
    func test_successUpdateFulfilmentMethodAndStore_whenSelectedStoreAndFulfilmentLocationWithBasket_setAppStateBasket() {
        
        let store = RetailStoreDetails.mockedData
        let searchResult = RetailStoresSearch.mockedData
        let basket = Basket.mockedData
        
        // Configuring app prexisting states
        appState.value.userData.selectedStore = .loaded(store)
        appState.value.userData.searchResult = .loaded(searchResult)
        appState.value.userData.basket = basket
        
        mockedWebRepo.actions = .init(expected: [
            .getBasket(
                basketToken: basket.basketToken,
                storeId: store.id,
                fulfilmentMethod: appState.value.userData.selectedFulfilmentMethod,
                fulfilmentLocation: searchResult.fulfilmentLocation,
                isFirstOrder: true
            )
        ])
        mockedDBRepo.actions = .init(expected: [
            .clearBasket,
            .store(basket: basket)
        ])
        
        // Configuring responses from repositories
        mockedWebRepo.getBasketResponse = .success(basket)
        mockedDBRepo.clearBasketResult = .success(true)
        mockedDBRepo.storeBasketResult = .success(basket)
        
        let exp = XCTestExpectation(description: #function)
        sut
            .updateFulfilmentMethodAndStore()
            .sinkToResult { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success:
                    XCTAssertEqual(self.appState.value.userData.basket, basket, file: #file, line: #line)
                case let .failure(error):
                    XCTFail("Unexpected error: \(error)", file: #file, line: #line)
                }
                self.mockedWebRepo.verify()
                self.mockedDBRepo.verify()
                exp.fulfill()
            }
            .store(in: &subscriptions)

        wait(for: [exp], timeout: 0.5)
    }
    
}

// MARK: - func reserveTimeSlot(timeSlotDate:timeSlotTime:)
final class ReserveTimeSlotTests: BasketServiceTests {
    
    func test_unsuccessReserveTimeSlot_whenNoStoreSelected_returnError() {
        
        let exp = XCTestExpectation(description: #function)
        sut
            .reserveTimeSlot(timeSlotDate: "2022-03-11", timeSlotTime: nil)
            .sinkToResult { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success:
                    XCTFail("Unexpected result: \(result)", file: #file, line: #line)
                case let .failure(error):
                    if let basketError = error as? BasketServiceError {
                        XCTAssertEqual(basketError, BasketServiceError.storeSelectionRequired, file: #file, line: #line)
                    } else {
                        XCTFail("Unexpected error type: \(error)", file: #file, line: #line)
                    }
                }
                self.mockedWebRepo.verify()
                self.mockedDBRepo.verify()
                exp.fulfill()
            }
            .store(in: &subscriptions)

        wait(for: [exp], timeout: 0.5)
    }
    
    func test_unsuccessReserveTimeSlot_whenStoreSelectedButNoFulfilmentLocation_returnError() {
        
        let store = RetailStoreDetails.mockedData
        
        // Configuring app prexisting states
        appState.value.userData.selectedStore = .loaded(store)
        
        let exp = XCTestExpectation(description: #function)
        sut
            .reserveTimeSlot(timeSlotDate: "2022-03-11", timeSlotTime: nil)
            .sinkToResult { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success:
                    XCTFail("Unexpected result: \(result)", file: #file, line: #line)
                case let .failure(error):
                    if let basketError = error as? BasketServiceError {
                        XCTAssertEqual(basketError, BasketServiceError.fulfilmentLocationRequired, file: #file, line: #line)
                    } else {
                        XCTFail("Unexpected error type: \(error)", file: #file, line: #line)
                    }
                }
                self.mockedWebRepo.verify()
                self.mockedDBRepo.verify()
                exp.fulfill()
            }
            .store(in: &subscriptions)

        wait(for: [exp], timeout: 0.5)
    }
    
    func test_successReserveTimeSlot_whenSelectedStoreAndFulfilmentLocationWithoutBasket_setAppStateBasket() {
        
        let store = RetailStoreDetails.mockedData
        let searchResult = RetailStoresSearch.mockedData
        let basket = Basket.mockedData
        
        // Configuring app prexisting states
        appState.value.userData.selectedStore = .loaded(store)
        appState.value.userData.searchResult = .loaded(searchResult)
        
        mockedWebRepo.actions = .init(expected: [
            .getBasket(
                basketToken: nil,
                storeId: store.id,
                fulfilmentMethod: appState.value.userData.selectedFulfilmentMethod,
                fulfilmentLocation: searchResult.fulfilmentLocation,
                isFirstOrder: true
            ),
            .reserveTimeSlot(
                basketToken: basket.basketToken,
                storeId: store.id,
                timeSlotDate: "2022-03-11",
                timeSlotTime: nil,
                postcode: "DD1 3JA",
                fulfilmentMethod: basket.fulfilmentMethod.type
            )
        ])
        mockedDBRepo.actions = .init(expected: [
            .clearBasket,
            .store(basket: basket),
            .clearBasket,
            .store(basket: basket)
        ])
        
        // Configuring responses from repositories
        mockedWebRepo.getBasketResponse = .success(basket)
        mockedWebRepo.reserveTimeSlotResponse = .success(basket)
        mockedDBRepo.clearBasketResult = .success(true)
        mockedDBRepo.storeBasketResult = .success(basket)
        
        let exp = XCTestExpectation(description: #function)
        sut
            .reserveTimeSlot(timeSlotDate: "2022-03-11", timeSlotTime: nil)
            .sinkToResult { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success:
                    XCTAssertEqual(self.appState.value.userData.basket, basket, file: #file, line: #line)
                case let .failure(error):
                    XCTFail("Unexpected error: \(error)", file: #file, line: #line)
                }
                self.mockedWebRepo.verify()
                self.mockedDBRepo.verify()
                exp.fulfill()
            }
            .store(in: &subscriptions)

        wait(for: [exp], timeout: 0.5)
    }
    
    func test_successReserveTimeSlot_whenSelectedStoreAndFulfilmentLocationWithBasket_setAppStateBasket() {
        
        let store = RetailStoreDetails.mockedData
        let searchResult = RetailStoresSearch.mockedData
        let basket = Basket.mockedData
        
        // Configuring app prexisting states
        appState.value.userData.selectedStore = .loaded(store)
        appState.value.userData.searchResult = .loaded(searchResult)
        appState.value.userData.basket = basket
        
        mockedWebRepo.actions = .init(expected: [
            .reserveTimeSlot(
                basketToken: basket.basketToken,
                storeId: store.id,
                timeSlotDate: "2022-03-11",
                timeSlotTime: nil,
                postcode: "DD1 3JA",
                fulfilmentMethod: basket.fulfilmentMethod.type
            )
        ])
        mockedDBRepo.actions = .init(expected: [
            .clearBasket,
            .store(basket: basket)
        ])
        
        // Configuring responses from repositories
        mockedWebRepo.reserveTimeSlotResponse = .success(basket)
        mockedDBRepo.clearBasketResult = .success(true)
        mockedDBRepo.storeBasketResult = .success(basket)
        
        let exp = XCTestExpectation(description: #function)
        sut
            .reserveTimeSlot(timeSlotDate: "2022-03-11", timeSlotTime: nil)
            .sinkToResult { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success:
                    XCTAssertEqual(self.appState.value.userData.basket, basket, file: #file, line: #line)
                case let .failure(error):
                    XCTFail("Unexpected error: \(error)", file: #file, line: #line)
                }
                self.mockedWebRepo.verify()
                self.mockedDBRepo.verify()
                exp.fulfill()
            }
            .store(in: &subscriptions)

        wait(for: [exp], timeout: 0.5)
    }
}

// MARK: - func addItem(item:)
final class AddItemTests: BasketServiceTests {
    
    func test_unsuccessAddItem_whenNoStoreSelected_returnError() {
        
        let itemRequest = BasketItemRequest.mockedData
        
        let exp = XCTestExpectation(description: #function)
        sut
            .addItem(item: itemRequest)
            .sinkToResult { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success:
                    XCTFail("Unexpected result: \(result)", file: #file, line: #line)
                case let .failure(error):
                    if let basketError = error as? BasketServiceError {
                        XCTAssertEqual(basketError, BasketServiceError.storeSelectionRequired, file: #file, line: #line)
                    } else {
                        XCTFail("Unexpected error type: \(error)", file: #file, line: #line)
                    }
                }
                self.mockedWebRepo.verify()
                self.mockedDBRepo.verify()
                exp.fulfill()
            }
            .store(in: &subscriptions)

        wait(for: [exp], timeout: 0.5)
    }
    
    func test_unsuccessAddItem_whenStoreSelectedButNoFulfilmentLocation_returnError() {
        
        let itemRequest = BasketItemRequest.mockedData
        let store = RetailStoreDetails.mockedData
        
        // Configuring app prexisting states
        appState.value.userData.selectedStore = .loaded(store)
        
        let exp = XCTestExpectation(description: #function)
        sut
            .addItem(item: itemRequest)
            .sinkToResult { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success:
                    XCTFail("Unexpected result: \(result)", file: #file, line: #line)
                case let .failure(error):
                    if let basketError = error as? BasketServiceError {
                        XCTAssertEqual(basketError, BasketServiceError.fulfilmentLocationRequired, file: #file, line: #line)
                    } else {
                        XCTFail("Unexpected error type: \(error)", file: #file, line: #line)
                    }
                }
                self.mockedWebRepo.verify()
                self.mockedDBRepo.verify()
                exp.fulfill()
            }
            .store(in: &subscriptions)

        wait(for: [exp], timeout: 0.5)
    }
    
    func test_successAddItem_whenSelectedStoreAndFulfilmentLocationWithoutBasket_setAppStateBasket() {
        
        let itemRequest = BasketItemRequest.mockedData
        let store = RetailStoreDetails.mockedData
        let searchResult = RetailStoresSearch.mockedData
        let basket = Basket.mockedData
        
        // Configuring app prexisting states
        appState.value.userData.selectedStore = .loaded(store)
        appState.value.userData.searchResult = .loaded(searchResult)
        
        mockedWebRepo.actions = .init(expected: [
            .getBasket(
                basketToken: nil,
                storeId: store.id,
                fulfilmentMethod: appState.value.userData.selectedFulfilmentMethod,
                fulfilmentLocation: searchResult.fulfilmentLocation,
                isFirstOrder: true
            ),
            .addItem(
                basketToken: basket.basketToken,
                item: itemRequest,
                fulfilmentMethod: basket.fulfilmentMethod.type
            )
        ])
        mockedDBRepo.actions = .init(expected: [
            .clearBasket,
            .store(basket: basket),
            .clearBasket,
            .store(basket: basket)
        ])
        
        // Configuring responses from repositories
        mockedWebRepo.getBasketResponse = .success(basket)
        mockedWebRepo.addItemResponse = .success(basket)
        mockedDBRepo.clearBasketResult = .success(true)
        mockedDBRepo.storeBasketResult = .success(basket)
        
        let exp = XCTestExpectation(description: #function)
        sut
            .addItem(item: itemRequest)
            .sinkToResult { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success:
                    XCTAssertEqual(self.appState.value.userData.basket, basket, file: #file, line: #line)
                case let .failure(error):
                    XCTFail("Unexpected error: \(error)", file: #file, line: #line)
                }
                self.mockedWebRepo.verify()
                self.mockedDBRepo.verify()
                exp.fulfill()
            }
            .store(in: &subscriptions)

        wait(for: [exp], timeout: 0.5)
    }
    
    func test_successAddItem_whenSelectedStoreAndFulfilmentLocationWithBasket_setAppStateBasket() {
        
        let itemRequest = BasketItemRequest.mockedData
        let store = RetailStoreDetails.mockedData
        let searchResult = RetailStoresSearch.mockedData
        let basket = Basket.mockedData
        
        // Configuring app prexisting states
        appState.value.userData.selectedStore = .loaded(store)
        appState.value.userData.searchResult = .loaded(searchResult)
        appState.value.userData.basket = basket
        
        mockedWebRepo.actions = .init(expected: [
            .addItem(
                basketToken: basket.basketToken,
                item: itemRequest,
                fulfilmentMethod: basket.fulfilmentMethod.type
            )
        ])
        mockedDBRepo.actions = .init(expected: [
            .clearBasket,
            .store(basket: basket)
        ])
        
        // Configuring responses from repositories
        mockedWebRepo.addItemResponse = .success(basket)
        mockedDBRepo.clearBasketResult = .success(true)
        mockedDBRepo.storeBasketResult = .success(basket)
        
        let exp = XCTestExpectation(description: #function)
        sut
            .addItem(item: itemRequest)
            .sinkToResult { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success:
                    XCTAssertEqual(self.appState.value.userData.basket, basket, file: #file, line: #line)
                case let .failure(error):
                    XCTFail("Unexpected error: \(error)", file: #file, line: #line)
                }
                self.mockedWebRepo.verify()
                self.mockedDBRepo.verify()
                exp.fulfill()
            }
            .store(in: &subscriptions)

        wait(for: [exp], timeout: 0.5)
    }
}

// MARK: - func updateItem(item:basketLineId:)
final class UpdateItemTests: BasketServiceTests {
    
    func test_unsuccessUpdateItem_whenNoStoreSelected_returnError() {
        
        let itemRequest = BasketItemRequest.mockedData
        let basket = Basket.mockedData
        
        let exp = XCTestExpectation(description: #function)
        sut
            .updateItem(item: itemRequest, basketLineId: basket.items[0].basketLineId)
            .sinkToResult { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success:
                    XCTFail("Unexpected result: \(result)", file: #file, line: #line)
                case let .failure(error):
                    if let basketError = error as? BasketServiceError {
                        XCTAssertEqual(basketError, BasketServiceError.storeSelectionRequired, file: #file, line: #line)
                    } else {
                        XCTFail("Unexpected error type: \(error)", file: #file, line: #line)
                    }
                }
                self.mockedWebRepo.verify()
                self.mockedDBRepo.verify()
                exp.fulfill()
            }
            .store(in: &subscriptions)

        wait(for: [exp], timeout: 0.5)
    }
    
    func test_unsuccessUpdateItem_whenStoreSelectedButNoFulfilmentLocation_returnError() {
        
        let itemRequest = BasketItemRequest.mockedData
        let basket = Basket.mockedData
        let store = RetailStoreDetails.mockedData
        
        // Configuring app prexisting states
        appState.value.userData.selectedStore = .loaded(store)
        
        let exp = XCTestExpectation(description: #function)
        sut
            .updateItem(item: itemRequest, basketLineId: basket.items[0].basketLineId)
            .sinkToResult { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success:
                    XCTFail("Unexpected result: \(result)", file: #file, line: #line)
                case let .failure(error):
                    if let basketError = error as? BasketServiceError {
                        XCTAssertEqual(basketError, BasketServiceError.fulfilmentLocationRequired, file: #file, line: #line)
                    } else {
                        XCTFail("Unexpected error type: \(error)", file: #file, line: #line)
                    }
                }
                self.mockedWebRepo.verify()
                self.mockedDBRepo.verify()
                exp.fulfill()
            }
            .store(in: &subscriptions)

        wait(for: [exp], timeout: 0.5)
    }
    
    func test_successUpdateItem_whenSelectedStoreAndFulfilmentLocationWithoutBasket_setAppStateBasket() {
        
        let itemRequest = BasketItemRequest.mockedData
        let store = RetailStoreDetails.mockedData
        let searchResult = RetailStoresSearch.mockedData
        let basket = Basket.mockedData
        
        // Configuring app prexisting states
        appState.value.userData.selectedStore = .loaded(store)
        appState.value.userData.searchResult = .loaded(searchResult)
        
        mockedWebRepo.actions = .init(expected: [
            .getBasket(
                basketToken: nil,
                storeId: store.id,
                fulfilmentMethod: appState.value.userData.selectedFulfilmentMethod,
                fulfilmentLocation: searchResult.fulfilmentLocation,
                isFirstOrder: true
            ),
            .updateItem(
                basketToken: basket.basketToken,
                basketLineId: basket.items[0].basketLineId,
                item: itemRequest
            )
        ])
        mockedDBRepo.actions = .init(expected: [
            .clearBasket,
            .store(basket: basket),
            .clearBasket,
            .store(basket: basket)
        ])
        
        // Configuring responses from repositories
        mockedWebRepo.getBasketResponse = .success(basket)
        mockedWebRepo.updateItemResponse = .success(basket)
        mockedDBRepo.clearBasketResult = .success(true)
        mockedDBRepo.storeBasketResult = .success(basket)
        
        let exp = XCTestExpectation(description: #function)
        sut
            .updateItem(item: itemRequest, basketLineId: basket.items[0].basketLineId)
            .sinkToResult { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success:
                    XCTAssertEqual(self.appState.value.userData.basket, basket, file: #file, line: #line)
                case let .failure(error):
                    XCTFail("Unexpected error: \(error)", file: #file, line: #line)
                }
                self.mockedWebRepo.verify()
                self.mockedDBRepo.verify()
                exp.fulfill()
            }
            .store(in: &subscriptions)

        wait(for: [exp], timeout: 0.5)
    }
    
    func test_successUpdateItem_whenSelectedStoreAndFulfilmentLocationWithBasket_setAppStateBasket() {
        
        let itemRequest = BasketItemRequest.mockedData
        let store = RetailStoreDetails.mockedData
        let searchResult = RetailStoresSearch.mockedData
        let basket = Basket.mockedData
        
        // Configuring app prexisting states
        appState.value.userData.selectedStore = .loaded(store)
        appState.value.userData.searchResult = .loaded(searchResult)
        appState.value.userData.basket = basket
        
        mockedWebRepo.actions = .init(expected: [
            .updateItem(
                basketToken: basket.basketToken,
                basketLineId: basket.items[0].basketLineId,
                item: itemRequest
            )
        ])
        mockedDBRepo.actions = .init(expected: [
            .clearBasket,
            .store(basket: basket)
        ])
        
        // Configuring responses from repositories
        mockedWebRepo.updateItemResponse = .success(basket)
        mockedDBRepo.clearBasketResult = .success(true)
        mockedDBRepo.storeBasketResult = .success(basket)
        
        let exp = XCTestExpectation(description: #function)
        sut
            .updateItem(item: itemRequest, basketLineId: basket.items[0].basketLineId)
            .sinkToResult { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success:
                    XCTAssertEqual(self.appState.value.userData.basket, basket, file: #file, line: #line)
                case let .failure(error):
                    XCTFail("Unexpected error: \(error)", file: #file, line: #line)
                }
                self.mockedWebRepo.verify()
                self.mockedDBRepo.verify()
                exp.fulfill()
            }
            .store(in: &subscriptions)

        wait(for: [exp], timeout: 0.5)
    }
}

// MARK: - func removeItem(basketLineId:)
final class RemoveItemTests: BasketServiceTests {
    
    func test_unsuccessRemoveItem_whenNoStoreSelected_returnError() {
        
        let basket = Basket.mockedData
        
        let exp = XCTestExpectation(description: #function)
        sut
            .removeItem(basketLineId: basket.items[0].basketLineId)
            .sinkToResult { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success:
                    XCTFail("Unexpected result: \(result)", file: #file, line: #line)
                case let .failure(error):
                    if let basketError = error as? BasketServiceError {
                        XCTAssertEqual(basketError, BasketServiceError.storeSelectionRequired, file: #file, line: #line)
                    } else {
                        XCTFail("Unexpected error type: \(error)", file: #file, line: #line)
                    }
                }
                self.mockedWebRepo.verify()
                self.mockedDBRepo.verify()
                exp.fulfill()
            }
            .store(in: &subscriptions)

        wait(for: [exp], timeout: 0.5)
    }
    
    func test_unsuccessRemoveItem_whenStoreSelectedButNoFulfilmentLocation_returnError() {
        
        let basket = Basket.mockedData
        let store = RetailStoreDetails.mockedData
        
        // Configuring app prexisting states
        appState.value.userData.selectedStore = .loaded(store)
        
        let exp = XCTestExpectation(description: #function)
        sut
            .removeItem(basketLineId: basket.items[0].basketLineId)
            .sinkToResult { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success:
                    XCTFail("Unexpected result: \(result)", file: #file, line: #line)
                case let .failure(error):
                    if let basketError = error as? BasketServiceError {
                        XCTAssertEqual(basketError, BasketServiceError.fulfilmentLocationRequired, file: #file, line: #line)
                    } else {
                        XCTFail("Unexpected error type: \(error)", file: #file, line: #line)
                    }
                }
                self.mockedWebRepo.verify()
                self.mockedDBRepo.verify()
                exp.fulfill()
            }
            .store(in: &subscriptions)

        wait(for: [exp], timeout: 0.5)
    }
    
    func test_successRemoveItem_whenSelectedStoreAndFulfilmentLocationWithoutBasket_setAppStateBasket() {
        
        let store = RetailStoreDetails.mockedData
        let searchResult = RetailStoresSearch.mockedData
        let basket = Basket.mockedData
        
        // Configuring app prexisting states
        appState.value.userData.selectedStore = .loaded(store)
        appState.value.userData.searchResult = .loaded(searchResult)
        
        mockedWebRepo.actions = .init(expected: [
            .getBasket(
                basketToken: nil,
                storeId: store.id,
                fulfilmentMethod: appState.value.userData.selectedFulfilmentMethod,
                fulfilmentLocation: searchResult.fulfilmentLocation,
                isFirstOrder: true
            ),
            .removeItem(
                basketToken: basket.basketToken,
                basketLineId: basket.items[0].basketLineId
            )
        ])
        mockedDBRepo.actions = .init(expected: [
            .clearBasket,
            .store(basket: basket),
            .clearBasket,
            .store(basket: basket)
        ])
        
        // Configuring responses from repositories
        mockedWebRepo.getBasketResponse = .success(basket)
        mockedWebRepo.removeItemResponse = .success(basket)
        mockedDBRepo.clearBasketResult = .success(true)
        mockedDBRepo.storeBasketResult = .success(basket)
        
        let exp = XCTestExpectation(description: #function)
        sut
            .removeItem(basketLineId: basket.items[0].basketLineId)
            .sinkToResult { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success:
                    XCTAssertEqual(self.appState.value.userData.basket, basket, file: #file, line: #line)
                case let .failure(error):
                    XCTFail("Unexpected error: \(error)", file: #file, line: #line)
                }
                self.mockedWebRepo.verify()
                self.mockedDBRepo.verify()
                exp.fulfill()
            }
            .store(in: &subscriptions)

        wait(for: [exp], timeout: 0.5)
    }
    
    func test_successRemoveItem_whenSelectedStoreAndFulfilmentLocationWithBasket_setAppStateBasket() {
        
        let store = RetailStoreDetails.mockedData
        let searchResult = RetailStoresSearch.mockedData
        let basket = Basket.mockedData
        
        // Configuring app prexisting states
        appState.value.userData.selectedStore = .loaded(store)
        appState.value.userData.searchResult = .loaded(searchResult)
        appState.value.userData.basket = basket
        
        mockedWebRepo.actions = .init(expected: [
            .removeItem(
                basketToken: basket.basketToken,
                basketLineId: basket.items[0].basketLineId
            )
        ])
        mockedDBRepo.actions = .init(expected: [
            .clearBasket,
            .store(basket: basket)
        ])
        
        // Configuring responses from repositories
        mockedWebRepo.removeItemResponse = .success(basket)
        mockedDBRepo.clearBasketResult = .success(true)
        mockedDBRepo.storeBasketResult = .success(basket)
        
        let exp = XCTestExpectation(description: #function)
        sut
            .removeItem(basketLineId: basket.items[0].basketLineId)
            .sinkToResult { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success:
                    XCTAssertEqual(self.appState.value.userData.basket, basket, file: #file, line: #line)
                case let .failure(error):
                    XCTFail("Unexpected error: \(error)", file: #file, line: #line)
                }
                self.mockedWebRepo.verify()
                self.mockedDBRepo.verify()
                exp.fulfill()
            }
            .store(in: &subscriptions)

        wait(for: [exp], timeout: 0.5)
    }
}

// MARK: - func applyCoupon(code:)
final class ApplyCouponTests: BasketServiceTests {
    
    func test_unsuccessApplyCoupon_whenNoStoreSelected_returnError() {
        
        let exp = XCTestExpectation(description: #function)
        sut
            .applyCoupon(code: "COUPONCODE")
            .sinkToResult { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success:
                    XCTFail("Unexpected result: \(result)", file: #file, line: #line)
                case let .failure(error):
                    if let basketError = error as? BasketServiceError {
                        XCTAssertEqual(basketError, BasketServiceError.storeSelectionRequired, file: #file, line: #line)
                    } else {
                        XCTFail("Unexpected error type: \(error)", file: #file, line: #line)
                    }
                }
                self.mockedWebRepo.verify()
                self.mockedDBRepo.verify()
                exp.fulfill()
            }
            .store(in: &subscriptions)

        wait(for: [exp], timeout: 0.5)
    }
    
    func test_unsuccessApplyCoupon_whenStoreSelectedButNoFulfilmentLocation_returnError() {
        
        let store = RetailStoreDetails.mockedData
        
        // Configuring app prexisting states
        appState.value.userData.selectedStore = .loaded(store)
        
        let exp = XCTestExpectation(description: #function)
        sut
            .applyCoupon(code: "COUPONCODE")
            .sinkToResult { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success:
                    XCTFail("Unexpected result: \(result)", file: #file, line: #line)
                case let .failure(error):
                    if let basketError = error as? BasketServiceError {
                        XCTAssertEqual(basketError, BasketServiceError.fulfilmentLocationRequired, file: #file, line: #line)
                    } else {
                        XCTFail("Unexpected error type: \(error)", file: #file, line: #line)
                    }
                }
                self.mockedWebRepo.verify()
                self.mockedDBRepo.verify()
                exp.fulfill()
            }
            .store(in: &subscriptions)

        wait(for: [exp], timeout: 0.5)
    }
    
    func test_successApplyCoupon_whenSelectedStoreAndFulfilmentLocationWithoutBasket_setAppStateBasket() {
        
        let store = RetailStoreDetails.mockedData
        let searchResult = RetailStoresSearch.mockedData
        let basket = Basket.mockedData
        
        // Configuring app prexisting states
        appState.value.userData.selectedStore = .loaded(store)
        appState.value.userData.searchResult = .loaded(searchResult)
        
        mockedWebRepo.actions = .init(expected: [
            .getBasket(
                basketToken: nil,
                storeId: store.id,
                fulfilmentMethod: appState.value.userData.selectedFulfilmentMethod,
                fulfilmentLocation: searchResult.fulfilmentLocation,
                isFirstOrder: true
            ),
            .applyCoupon(
                basketToken: basket.basketToken,
                code: "COUPONCODE"
            )
        ])
        mockedDBRepo.actions = .init(expected: [
            .clearBasket,
            .store(basket: basket),
            .clearBasket,
            .store(basket: basket)
        ])
        
        // Configuring responses from repositories
        mockedWebRepo.getBasketResponse = .success(basket)
        mockedWebRepo.applyCouponResponse = .success(basket)
        mockedDBRepo.clearBasketResult = .success(true)
        mockedDBRepo.storeBasketResult = .success(basket)
        
        let exp = XCTestExpectation(description: #function)
        sut
            .applyCoupon(code: "COUPONCODE")
            .sinkToResult { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success:
                    XCTAssertEqual(self.appState.value.userData.basket, basket, file: #file, line: #line)
                case let .failure(error):
                    XCTFail("Unexpected error: \(error)", file: #file, line: #line)
                }
                self.mockedWebRepo.verify()
                self.mockedDBRepo.verify()
                exp.fulfill()
            }
            .store(in: &subscriptions)

        wait(for: [exp], timeout: 0.5)
    }
    
    func test_successApplyCoupon_whenSelectedStoreAndFulfilmentLocationWithBasket_setAppStateBasket() {
        
        let store = RetailStoreDetails.mockedData
        let searchResult = RetailStoresSearch.mockedData
        let basket = Basket.mockedData
        
        // Configuring app prexisting states
        appState.value.userData.selectedStore = .loaded(store)
        appState.value.userData.searchResult = .loaded(searchResult)
        appState.value.userData.basket = basket
        
        mockedWebRepo.actions = .init(expected: [
            .applyCoupon(
                basketToken: basket.basketToken,
                code: "COUPONCODE"
            )
        ])
        mockedDBRepo.actions = .init(expected: [
            .clearBasket,
            .store(basket: basket)
        ])
        
        // Configuring responses from repositories
        mockedWebRepo.applyCouponResponse = .success(basket)
        mockedDBRepo.clearBasketResult = .success(true)
        mockedDBRepo.storeBasketResult = .success(basket)
        
        let exp = XCTestExpectation(description: #function)
        sut
            .applyCoupon(code: "COUPONCODE")
            .sinkToResult { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success:
                    XCTAssertEqual(self.appState.value.userData.basket, basket, file: #file, line: #line)
                case let .failure(error):
                    XCTFail("Unexpected error: \(error)", file: #file, line: #line)
                }
                self.mockedWebRepo.verify()
                self.mockedDBRepo.verify()
                exp.fulfill()
            }
            .store(in: &subscriptions)

        wait(for: [exp], timeout: 0.5)
    }
}

// MARK: - func removeCoupon()
final class RemoveCouponTests: BasketServiceTests {
    
    func test_unsuccessApplyCoupon_whenNoStoreSelected_returnError() {
        
        let exp = XCTestExpectation(description: #function)
        sut
            .removeCoupon()
            .sinkToResult { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success:
                    XCTFail("Unexpected result: \(result)", file: #file, line: #line)
                case let .failure(error):
                    if let basketError = error as? BasketServiceError {
                        XCTAssertEqual(basketError, BasketServiceError.storeSelectionRequired, file: #file, line: #line)
                    } else {
                        XCTFail("Unexpected error type: \(error)", file: #file, line: #line)
                    }
                }
                self.mockedWebRepo.verify()
                self.mockedDBRepo.verify()
                exp.fulfill()
            }
            .store(in: &subscriptions)

        wait(for: [exp], timeout: 0.5)
    }
    
    func test_unsuccessApplyCoupon_whenStoreSelectedButNoFulfilmentLocation_returnError() {
        
        let store = RetailStoreDetails.mockedData
        
        // Configuring app prexisting states
        appState.value.userData.selectedStore = .loaded(store)
        
        let exp = XCTestExpectation(description: #function)
        sut
            .removeCoupon()
            .sinkToResult { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success:
                    XCTFail("Unexpected result: \(result)", file: #file, line: #line)
                case let .failure(error):
                    if let basketError = error as? BasketServiceError {
                        XCTAssertEqual(basketError, BasketServiceError.fulfilmentLocationRequired, file: #file, line: #line)
                    } else {
                        XCTFail("Unexpected error type: \(error)", file: #file, line: #line)
                    }
                }
                self.mockedWebRepo.verify()
                self.mockedDBRepo.verify()
                exp.fulfill()
            }
            .store(in: &subscriptions)

        wait(for: [exp], timeout: 0.5)
    }
    
    func test_successApplyCoupon_whenSelectedStoreAndFulfilmentLocationWithoutBasket_setAppStateBasket() {
        
        let store = RetailStoreDetails.mockedData
        let searchResult = RetailStoresSearch.mockedData
        let basket = Basket.mockedData
        
        // Configuring app prexisting states
        appState.value.userData.selectedStore = .loaded(store)
        appState.value.userData.searchResult = .loaded(searchResult)
        
        mockedWebRepo.actions = .init(expected: [
            .getBasket(
                basketToken: nil,
                storeId: store.id,
                fulfilmentMethod: appState.value.userData.selectedFulfilmentMethod,
                fulfilmentLocation: searchResult.fulfilmentLocation,
                isFirstOrder: true
            ),
            .removeCoupon(basketToken: basket.basketToken)
        ])
        mockedDBRepo.actions = .init(expected: [
            .clearBasket,
            .store(basket: basket),
            .clearBasket,
            .store(basket: basket)
        ])
        
        // Configuring responses from repositories
        mockedWebRepo.getBasketResponse = .success(basket)
        mockedWebRepo.removeCouponResponse = .success(basket)
        mockedDBRepo.clearBasketResult = .success(true)
        mockedDBRepo.storeBasketResult = .success(basket)
        
        let exp = XCTestExpectation(description: #function)
        sut
            .removeCoupon()
            .sinkToResult { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success:
                    XCTAssertEqual(self.appState.value.userData.basket, basket, file: #file, line: #line)
                case let .failure(error):
                    XCTFail("Unexpected error: \(error)", file: #file, line: #line)
                }
                self.mockedWebRepo.verify()
                self.mockedDBRepo.verify()
                exp.fulfill()
            }
            .store(in: &subscriptions)

        wait(for: [exp], timeout: 0.5)
    }
    
    func test_successApplyCoupon_whenSelectedStoreAndFulfilmentLocationWithBasket_setAppStateBasket() {
        
        let store = RetailStoreDetails.mockedData
        let searchResult = RetailStoresSearch.mockedData
        let basket = Basket.mockedData
        
        // Configuring app prexisting states
        appState.value.userData.selectedStore = .loaded(store)
        appState.value.userData.searchResult = .loaded(searchResult)
        appState.value.userData.basket = basket
        
        mockedWebRepo.actions = .init(expected: [
            .removeCoupon(basketToken: basket.basketToken)
        ])
        mockedDBRepo.actions = .init(expected: [
            .clearBasket,
            .store(basket: basket)
        ])
        
        // Configuring responses from repositories
        mockedWebRepo.removeCouponResponse = .success(basket)
        mockedDBRepo.clearBasketResult = .success(true)
        mockedDBRepo.storeBasketResult = .success(basket)
        
        let exp = XCTestExpectation(description: #function)
        sut
            .removeCoupon()
            .sinkToResult { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success:
                    XCTAssertEqual(self.appState.value.userData.basket, basket, file: #file, line: #line)
                case let .failure(error):
                    XCTFail("Unexpected error: \(error)", file: #file, line: #line)
                }
                self.mockedWebRepo.verify()
                self.mockedDBRepo.verify()
                exp.fulfill()
            }
            .store(in: &subscriptions)

        wait(for: [exp], timeout: 0.5)
    }
}

// MARK: - func clearItems()
final class ClearItemsTests: BasketServiceTests {
    
    func test_unsuccessClearItems_whenNoStoreSelected_returnError() {
        
        let exp = XCTestExpectation(description: #function)
        sut
            .removeCoupon()
            .sinkToResult { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success:
                    XCTFail("Unexpected result: \(result)", file: #file, line: #line)
                case let .failure(error):
                    if let basketError = error as? BasketServiceError {
                        XCTAssertEqual(basketError, BasketServiceError.storeSelectionRequired, file: #file, line: #line)
                    } else {
                        XCTFail("Unexpected error type: \(error)", file: #file, line: #line)
                    }
                }
                self.mockedWebRepo.verify()
                self.mockedDBRepo.verify()
                exp.fulfill()
            }
            .store(in: &subscriptions)

        wait(for: [exp], timeout: 0.5)
    }
    
    func test_unsuccessClearItems_whenStoreSelectedButNoFulfilmentLocation_returnError() {
        
        let store = RetailStoreDetails.mockedData
        
        // Configuring app prexisting states
        appState.value.userData.selectedStore = .loaded(store)
        
        let exp = XCTestExpectation(description: #function)
        sut
            .removeCoupon()
            .sinkToResult { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success:
                    XCTFail("Unexpected result: \(result)", file: #file, line: #line)
                case let .failure(error):
                    if let basketError = error as? BasketServiceError {
                        XCTAssertEqual(basketError, BasketServiceError.fulfilmentLocationRequired, file: #file, line: #line)
                    } else {
                        XCTFail("Unexpected error type: \(error)", file: #file, line: #line)
                    }
                }
                self.mockedWebRepo.verify()
                self.mockedDBRepo.verify()
                exp.fulfill()
            }
            .store(in: &subscriptions)

        wait(for: [exp], timeout: 0.5)
    }
    
    func test_successClearItems_whenSelectedStoreAndFulfilmentLocationWithoutBasket_setAppStateBasket() {
        
        let store = RetailStoreDetails.mockedData
        let searchResult = RetailStoresSearch.mockedData
        let basket = Basket.mockedData
        
        // Configuring app prexisting states
        appState.value.userData.selectedStore = .loaded(store)
        appState.value.userData.searchResult = .loaded(searchResult)
        
        mockedWebRepo.actions = .init(expected: [
            .getBasket(
                basketToken: nil,
                storeId: store.id,
                fulfilmentMethod: appState.value.userData.selectedFulfilmentMethod,
                fulfilmentLocation: searchResult.fulfilmentLocation,
                isFirstOrder: true
            ),
            .clearItems(basketToken: basket.basketToken)
        ])
        mockedDBRepo.actions = .init(expected: [
            .clearBasket,
            .store(basket: basket),
            .clearBasket,
            .store(basket: basket)
        ])
        
        // Configuring responses from repositories
        mockedWebRepo.getBasketResponse = .success(basket)
        mockedWebRepo.clearItemsResponse = .success(basket)
        mockedDBRepo.clearBasketResult = .success(true)
        mockedDBRepo.storeBasketResult = .success(basket)
        
        let exp = XCTestExpectation(description: #function)
        sut
            .clearItems()
            .sinkToResult { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success:
                    XCTAssertEqual(self.appState.value.userData.basket, basket, file: #file, line: #line)
                case let .failure(error):
                    XCTFail("Unexpected error: \(error)", file: #file, line: #line)
                }
                self.mockedWebRepo.verify()
                self.mockedDBRepo.verify()
                exp.fulfill()
            }
            .store(in: &subscriptions)

        wait(for: [exp], timeout: 0.5)
    }
    
    func test_successClearItems_whenSelectedStoreAndFulfilmentLocationWithBasket_setAppStateBasket() {
        
        let store = RetailStoreDetails.mockedData
        let searchResult = RetailStoresSearch.mockedData
        let basket = Basket.mockedData
        
        // Configuring app prexisting states
        appState.value.userData.selectedStore = .loaded(store)
        appState.value.userData.searchResult = .loaded(searchResult)
        appState.value.userData.basket = basket
        
        mockedWebRepo.actions = .init(expected: [
            .clearItems(basketToken: basket.basketToken)
        ])
        mockedDBRepo.actions = .init(expected: [
            .clearBasket,
            .store(basket: basket)
        ])
        
        // Configuring responses from repositories
        mockedWebRepo.clearItemsResponse = .success(basket)
        mockedDBRepo.clearBasketResult = .success(true)
        mockedDBRepo.storeBasketResult = .success(basket)
        
        let exp = XCTestExpectation(description: #function)
        sut
            .clearItems()
            .sinkToResult { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success:
                    XCTAssertEqual(self.appState.value.userData.basket, basket, file: #file, line: #line)
                case let .failure(error):
                    XCTFail("Unexpected error: \(error)", file: #file, line: #line)
                }
                self.mockedWebRepo.verify()
                self.mockedDBRepo.verify()
                exp.fulfill()
            }
            .store(in: &subscriptions)

        wait(for: [exp], timeout: 0.5)
    }
}

// MARK: - func setContactDetails(to:)
final class SetContactDetailsTests: BasketServiceTests {
    
    func test_unsuccessfulSetContactDetails_whenNoStoreSelected_returnError() {
        
        let contactDetails = BasketContactDetailsRequest.mockedData
        
        let exp = XCTestExpectation(description: #function)
        sut
            .setContactDetails(to: contactDetails)
            .sinkToResult { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success:
                    XCTFail("Unexpected result: \(result)", file: #file, line: #line)
                case let .failure(error):
                    if let basketError = error as? BasketServiceError {
                        XCTAssertEqual(basketError, BasketServiceError.storeSelectionRequired, file: #file, line: #line)
                    } else {
                        XCTFail("Unexpected error type: \(error)", file: #file, line: #line)
                    }
                }
                self.mockedWebRepo.verify()
                self.mockedDBRepo.verify()
                exp.fulfill()
            }
            .store(in: &subscriptions)

        wait(for: [exp], timeout: 0.5)
    }
    
    func test_unsuccessfulSetContactDetails_whenStoreSelectedButNoFulfilmentLocation_returnError() {
        
        let contactDetails = BasketContactDetailsRequest.mockedData
        let store = RetailStoreDetails.mockedData
        
        // Configuring app prexisting states
        appState.value.userData.selectedStore = .loaded(store)
        
        let exp = XCTestExpectation(description: #function)
        sut
            .setContactDetails(to: contactDetails)
            .sinkToResult { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success:
                    XCTFail("Unexpected result: \(result)", file: #file, line: #line)
                case let .failure(error):
                    if let basketError = error as? BasketServiceError {
                        XCTAssertEqual(basketError, BasketServiceError.fulfilmentLocationRequired, file: #file, line: #line)
                    } else {
                        XCTFail("Unexpected error type: \(error)", file: #file, line: #line)
                    }
                }
                self.mockedWebRepo.verify()
                self.mockedDBRepo.verify()
                exp.fulfill()
            }
            .store(in: &subscriptions)

        wait(for: [exp], timeout: 0.5)
    }
    
    func test_successfulSetContactDetails_whenSelectedStoreAndFulfilmentLocationWithoutBasket_setAppStateBasket() {
        
        let contactDetails = BasketContactDetailsRequest.mockedData
        let store = RetailStoreDetails.mockedData
        let searchResult = RetailStoresSearch.mockedData
        let basket = Basket.mockedData
        
        // Configuring app prexisting states
        appState.value.userData.selectedStore = .loaded(store)
        appState.value.userData.searchResult = .loaded(searchResult)
        
        mockedWebRepo.actions = .init(expected: [
            .getBasket(
                basketToken: nil,
                storeId: store.id,
                fulfilmentMethod: appState.value.userData.selectedFulfilmentMethod,
                fulfilmentLocation: searchResult.fulfilmentLocation,
                isFirstOrder: true
            ),
            .setContactDetails(
                basketToken: basket.basketToken,
                details: contactDetails
            )
        ])
        mockedDBRepo.actions = .init(expected: [
            .clearBasket,
            .store(basket: basket),
            .clearBasket,
            .store(basket: basket)
        ])
        
        // Configuring responses from repositories
        mockedWebRepo.getBasketResponse = .success(basket)
        mockedWebRepo.setContactDetailsResponse = .success(basket)
        mockedDBRepo.clearBasketResult = .success(true)
        mockedDBRepo.storeBasketResult = .success(basket)
        
        let exp = XCTestExpectation(description: #function)
        sut
            .setContactDetails(to: contactDetails)
            .sinkToResult { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success:
                    XCTAssertEqual(self.appState.value.userData.basket, basket, file: #file, line: #line)
                case let .failure(error):
                    XCTFail("Unexpected error: \(error)", file: #file, line: #line)
                }
                self.mockedWebRepo.verify()
                self.mockedDBRepo.verify()
                exp.fulfill()
            }
            .store(in: &subscriptions)

        wait(for: [exp], timeout: 0.5)
    }
    
    func test_successfulSetContactDetails_whenSelectedStoreAndFulfilmentLocationWithBasket_setAppStateBasket() {
        
        let contactDetails = BasketContactDetailsRequest.mockedData
        let store = RetailStoreDetails.mockedData
        let searchResult = RetailStoresSearch.mockedData
        let basket = Basket.mockedData
        
        // Configuring app prexisting states
        appState.value.userData.selectedStore = .loaded(store)
        appState.value.userData.searchResult = .loaded(searchResult)
        appState.value.userData.basket = basket
        
        mockedWebRepo.actions = .init(expected: [
            .setContactDetails(
                basketToken: basket.basketToken,
                details: contactDetails
            )
        ])
        mockedDBRepo.actions = .init(expected: [
            .clearBasket,
            .store(basket: basket)
        ])
        
        // Configuring responses from repositories
        mockedWebRepo.setContactDetailsResponse = .success(basket)
        mockedDBRepo.clearBasketResult = .success(true)
        mockedDBRepo.storeBasketResult = .success(basket)
        
        let exp = XCTestExpectation(description: #function)
        sut
            .setContactDetails(to: contactDetails)
            .sinkToResult { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success:
                    XCTAssertEqual(self.appState.value.userData.basket, basket, file: #file, line: #line)
                case let .failure(error):
                    XCTFail("Unexpected error: \(error)", file: #file, line: #line)
                }
                self.mockedWebRepo.verify()
                self.mockedDBRepo.verify()
                exp.fulfill()
            }
            .store(in: &subscriptions)

        wait(for: [exp], timeout: 0.5)
    }
}

// MARK: - func setDeliveryAddress(to:)
final class SetDeliveryAddressTests: BasketServiceTests {
    
    func test_unsuccessDeliveryAddress_whenNoStoreSelected_returnError() {
        
        let deliveryAddress = BasketAddressRequest.mockedDeliveryData
        
        let exp = XCTestExpectation(description: #function)
        sut
            .setDeliveryAddress(to: deliveryAddress)
            .sinkToResult { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success:
                    XCTFail("Unexpected result: \(result)", file: #file, line: #line)
                case let .failure(error):
                    if let basketError = error as? BasketServiceError {
                        XCTAssertEqual(basketError, BasketServiceError.storeSelectionRequired, file: #file, line: #line)
                    } else {
                        XCTFail("Unexpected error type: \(error)", file: #file, line: #line)
                    }
                }
                self.mockedWebRepo.verify()
                self.mockedDBRepo.verify()
                exp.fulfill()
            }
            .store(in: &subscriptions)

        wait(for: [exp], timeout: 0.5)
    }
    
    func test_unsuccessDeliveryAddress_whenStoreSelectedButNoFulfilmentLocation_returnError() {
        
        let deliveryAddress = BasketAddressRequest.mockedDeliveryData
        let store = RetailStoreDetails.mockedData
        
        // Configuring app prexisting states
        appState.value.userData.selectedStore = .loaded(store)
        
        let exp = XCTestExpectation(description: #function)
        sut
            .setDeliveryAddress(to: deliveryAddress)
            .sinkToResult { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success:
                    XCTFail("Unexpected result: \(result)", file: #file, line: #line)
                case let .failure(error):
                    if let basketError = error as? BasketServiceError {
                        XCTAssertEqual(basketError, BasketServiceError.fulfilmentLocationRequired, file: #file, line: #line)
                    } else {
                        XCTFail("Unexpected error type: \(error)", file: #file, line: #line)
                    }
                }
                self.mockedWebRepo.verify()
                self.mockedDBRepo.verify()
                exp.fulfill()
            }
            .store(in: &subscriptions)

        wait(for: [exp], timeout: 0.5)
    }
    
    func test_successDeliveryAddress_whenSelectedStoreAndFulfilmentLocationWithoutBasket_setAppStateBasket() {
        
        let deliveryAddress = BasketAddressRequest.mockedDeliveryData
        let store = RetailStoreDetails.mockedData
        let searchResult = RetailStoresSearch.mockedData
        let basket = Basket.mockedData
        
        // Configuring app prexisting states
        appState.value.userData.selectedStore = .loaded(store)
        appState.value.userData.searchResult = .loaded(searchResult)
        
        mockedWebRepo.actions = .init(expected: [
            .getBasket(
                basketToken: nil,
                storeId: store.id,
                fulfilmentMethod: appState.value.userData.selectedFulfilmentMethod,
                fulfilmentLocation: searchResult.fulfilmentLocation,
                isFirstOrder: true
            ),
            .setDeliveryAddress(
                basketToken: basket.basketToken,
                address: deliveryAddress
            )
        ])
        mockedDBRepo.actions = .init(expected: [
            .clearBasket,
            .store(basket: basket),
            .clearBasket,
            .store(basket: basket)
        ])
        
        // Configuring responses from repositories
        mockedWebRepo.getBasketResponse = .success(basket)
        mockedWebRepo.setDeliveryAddressResponse = .success(basket)
        mockedDBRepo.clearBasketResult = .success(true)
        mockedDBRepo.storeBasketResult = .success(basket)
        
        let exp = XCTestExpectation(description: #function)
        sut
            .setDeliveryAddress(to: deliveryAddress)
            .sinkToResult { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success:
                    XCTAssertEqual(self.appState.value.userData.basket, basket, file: #file, line: #line)
                case let .failure(error):
                    XCTFail("Unexpected error: \(error)", file: #file, line: #line)
                }
                self.mockedWebRepo.verify()
                self.mockedDBRepo.verify()
                exp.fulfill()
            }
            .store(in: &subscriptions)

        wait(for: [exp], timeout: 0.5)
    }
    
    func test_successDeliveryAddress_whenSelectedStoreAndFulfilmentLocationWithBasket_setAppStateBasket() {
        
        let deliveryAddress = BasketAddressRequest.mockedDeliveryData
        let store = RetailStoreDetails.mockedData
        let searchResult = RetailStoresSearch.mockedData
        let basket = Basket.mockedData
        
        // Configuring app prexisting states
        appState.value.userData.selectedStore = .loaded(store)
        appState.value.userData.searchResult = .loaded(searchResult)
        appState.value.userData.basket = basket
        
        mockedWebRepo.actions = .init(expected: [
            .setDeliveryAddress(
                basketToken: basket.basketToken,
                address: deliveryAddress
            )
        ])
        mockedDBRepo.actions = .init(expected: [
            .clearBasket,
            .store(basket: basket)
        ])
        
        // Configuring responses from repositories
        mockedWebRepo.setDeliveryAddressResponse = .success(basket)
        mockedDBRepo.clearBasketResult = .success(true)
        mockedDBRepo.storeBasketResult = .success(basket)
        
        let exp = XCTestExpectation(description: #function)
        sut
            .setDeliveryAddress(to: deliveryAddress)
            .sinkToResult { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success:
                    XCTAssertEqual(self.appState.value.userData.basket, basket, file: #file, line: #line)
                case let .failure(error):
                    XCTFail("Unexpected error: \(error)", file: #file, line: #line)
                }
                self.mockedWebRepo.verify()
                self.mockedDBRepo.verify()
                exp.fulfill()
            }
            .store(in: &subscriptions)

        wait(for: [exp], timeout: 0.5)
    }
}

// MARK: - func setBillingAddress(to:)
final class SetBillingAddressTests: BasketServiceTests {
    
    func test_unsuccessBillingAddress_whenNoStoreSelected_returnError() {
        
        let billingAddress = BasketAddressRequest.mockedBillingData
        
        let exp = XCTestExpectation(description: #function)
        sut
            .setBillingAddress(to: billingAddress)
            .sinkToResult { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success:
                    XCTFail("Unexpected result: \(result)", file: #file, line: #line)
                case let .failure(error):
                    if let basketError = error as? BasketServiceError {
                        XCTAssertEqual(basketError, BasketServiceError.storeSelectionRequired, file: #file, line: #line)
                    } else {
                        XCTFail("Unexpected error type: \(error)", file: #file, line: #line)
                    }
                }
                self.mockedWebRepo.verify()
                self.mockedDBRepo.verify()
                exp.fulfill()
            }
            .store(in: &subscriptions)

        wait(for: [exp], timeout: 0.5)
    }
    
    func test_unsuccessBillingAddress_whenStoreSelectedButNoFulfilmentLocation_returnError() {
        
        let billingAddress = BasketAddressRequest.mockedBillingData
        let store = RetailStoreDetails.mockedData
        
        // Configuring app prexisting states
        appState.value.userData.selectedStore = .loaded(store)
        
        let exp = XCTestExpectation(description: #function)
        sut
            .setBillingAddress(to: billingAddress)
            .sinkToResult { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success:
                    XCTFail("Unexpected result: \(result)", file: #file, line: #line)
                case let .failure(error):
                    if let basketError = error as? BasketServiceError {
                        XCTAssertEqual(basketError, BasketServiceError.fulfilmentLocationRequired, file: #file, line: #line)
                    } else {
                        XCTFail("Unexpected error type: \(error)", file: #file, line: #line)
                    }
                }
                self.mockedWebRepo.verify()
                self.mockedDBRepo.verify()
                exp.fulfill()
            }
            .store(in: &subscriptions)

        wait(for: [exp], timeout: 0.5)
    }
    
    func test_successBillingAddress_whenSelectedStoreAndFulfilmentLocationWithoutBasket_setAppStateBasket() {
        
        let billingAddress = BasketAddressRequest.mockedBillingData
        let store = RetailStoreDetails.mockedData
        let searchResult = RetailStoresSearch.mockedData
        let basket = Basket.mockedData
        
        // Configuring app prexisting states
        appState.value.userData.selectedStore = .loaded(store)
        appState.value.userData.searchResult = .loaded(searchResult)
        
        mockedWebRepo.actions = .init(expected: [
            .getBasket(
                basketToken: nil,
                storeId: store.id,
                fulfilmentMethod: appState.value.userData.selectedFulfilmentMethod,
                fulfilmentLocation: searchResult.fulfilmentLocation,
                isFirstOrder: true
            ),
            .setBillingAddress(
                basketToken: basket.basketToken,
                address: billingAddress
            )
        ])
        mockedDBRepo.actions = .init(expected: [
            .clearBasket,
            .store(basket: basket),
            .clearBasket,
            .store(basket: basket)
        ])
        
        // Configuring responses from repositories
        mockedWebRepo.getBasketResponse = .success(basket)
        mockedWebRepo.setBillingAddressResponse = .success(basket)
        mockedDBRepo.clearBasketResult = .success(true)
        mockedDBRepo.storeBasketResult = .success(basket)
        
        let exp = XCTestExpectation(description: #function)
        sut
            .setBillingAddress(to: billingAddress)
            .sinkToResult { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success:
                    XCTAssertEqual(self.appState.value.userData.basket, basket, file: #file, line: #line)
                case let .failure(error):
                    XCTFail("Unexpected error: \(error)", file: #file, line: #line)
                }
                self.mockedWebRepo.verify()
                self.mockedDBRepo.verify()
                exp.fulfill()
            }
            .store(in: &subscriptions)

        wait(for: [exp], timeout: 0.5)
    }
    
    func test_successBillingAddress_whenSelectedStoreAndFulfilmentLocationWithBasket_setAppStateBasket() {
        
        let billingAddress = BasketAddressRequest.mockedBillingData
        let store = RetailStoreDetails.mockedData
        let searchResult = RetailStoresSearch.mockedData
        let basket = Basket.mockedData
        
        // Configuring app prexisting states
        appState.value.userData.selectedStore = .loaded(store)
        appState.value.userData.searchResult = .loaded(searchResult)
        appState.value.userData.basket = basket
        
        mockedWebRepo.actions = .init(expected: [
            .setBillingAddress(
                basketToken: basket.basketToken,
                address: billingAddress
            )
        ])
        mockedDBRepo.actions = .init(expected: [
            .clearBasket,
            .store(basket: basket)
        ])
        
        // Configuring responses from repositories
        mockedWebRepo.setBillingAddressResponse = .success(basket)
        mockedDBRepo.clearBasketResult = .success(true)
        mockedDBRepo.storeBasketResult = .success(basket)
        
        let exp = XCTestExpectation(description: #function)
        sut
            .setBillingAddress(to: billingAddress)
            .sinkToResult { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success:
                    XCTAssertEqual(self.appState.value.userData.basket, basket, file: #file, line: #line)
                case let .failure(error):
                    XCTFail("Unexpected error: \(error)", file: #file, line: #line)
                }
                self.mockedWebRepo.verify()
                self.mockedDBRepo.verify()
                exp.fulfill()
            }
            .store(in: &subscriptions)

        wait(for: [exp], timeout: 0.5)
    }
}

// MARK: - func updateTip(to:)
//func updateTip(to: Double) -> Future<Void, Error>
final class UpdateTipTests: BasketServiceTests {
    
    func test_unsuccessUpdateTip_whenNoStoreSelected_returnError() {
        
        let exp = XCTestExpectation(description: #function)
        sut
            .updateTip(to: 1.5)
            .sinkToResult { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success:
                    XCTFail("Unexpected result: \(result)", file: #file, line: #line)
                case let .failure(error):
                    if let basketError = error as? BasketServiceError {
                        XCTAssertEqual(basketError, BasketServiceError.storeSelectionRequired, file: #file, line: #line)
                    } else {
                        XCTFail("Unexpected error type: \(error)", file: #file, line: #line)
                    }
                }
                self.mockedWebRepo.verify()
                self.mockedDBRepo.verify()
                exp.fulfill()
            }
            .store(in: &subscriptions)

        wait(for: [exp], timeout: 0.5)
    }
    
    func test_unsuccessUpdateTip_whenStoreSelectedButNoFulfilmentLocation_returnError() {
        
        let store = RetailStoreDetails.mockedData
        
        // Configuring app prexisting states
        appState.value.userData.selectedStore = .loaded(store)
        
        let exp = XCTestExpectation(description: #function)
        sut
            .updateTip(to: 1.5)
            .sinkToResult { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success:
                    XCTFail("Unexpected result: \(result)", file: #file, line: #line)
                case let .failure(error):
                    if let basketError = error as? BasketServiceError {
                        XCTAssertEqual(basketError, BasketServiceError.fulfilmentLocationRequired, file: #file, line: #line)
                    } else {
                        XCTFail("Unexpected error type: \(error)", file: #file, line: #line)
                    }
                }
                self.mockedWebRepo.verify()
                self.mockedDBRepo.verify()
                exp.fulfill()
            }
            .store(in: &subscriptions)

        wait(for: [exp], timeout: 0.5)
    }
    
    func test_successUpdateTip_whenSelectedStoreAndFulfilmentLocationWithoutBasket_setAppStateBasket() {
        
        let store = RetailStoreDetails.mockedData
        let searchResult = RetailStoresSearch.mockedData
        let basket = Basket.mockedData
        
        // Configuring app prexisting states
        appState.value.userData.selectedStore = .loaded(store)
        appState.value.userData.searchResult = .loaded(searchResult)
        
        mockedWebRepo.actions = .init(expected: [
            .getBasket(
                basketToken: nil,
                storeId: store.id,
                fulfilmentMethod: appState.value.userData.selectedFulfilmentMethod,
                fulfilmentLocation: searchResult.fulfilmentLocation,
                isFirstOrder: true
            ),
            .updateTip(
                basketToken: basket.basketToken,
                tip: 1.5
            )
        ])
        mockedDBRepo.actions = .init(expected: [
            .clearBasket,
            .store(basket: basket),
            .clearBasket,
            .store(basket: basket)
        ])
        
        // Configuring responses from repositories
        mockedWebRepo.getBasketResponse = .success(basket)
        mockedWebRepo.updateTipResponse = .success(basket)
        mockedDBRepo.clearBasketResult = .success(true)
        mockedDBRepo.storeBasketResult = .success(basket)
        
        let exp = XCTestExpectation(description: #function)
        sut
            .updateTip(to: 1.5)
            .sinkToResult { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success:
                    XCTAssertEqual(self.appState.value.userData.basket, basket, file: #file, line: #line)
                case let .failure(error):
                    XCTFail("Unexpected error: \(error)", file: #file, line: #line)
                }
                self.mockedWebRepo.verify()
                self.mockedDBRepo.verify()
                exp.fulfill()
            }
            .store(in: &subscriptions)

        wait(for: [exp], timeout: 0.5)
    }
    
    func test_successUpdateTip_whenSelectedStoreAndFulfilmentLocationWithBasket_setAppStateBasket() {
        
        let store = RetailStoreDetails.mockedData
        let searchResult = RetailStoresSearch.mockedData
        let basket = Basket.mockedData
        
        // Configuring app prexisting states
        appState.value.userData.selectedStore = .loaded(store)
        appState.value.userData.searchResult = .loaded(searchResult)
        appState.value.userData.basket = basket
        
        mockedWebRepo.actions = .init(expected: [
            .updateTip(
                basketToken: basket.basketToken,
                tip: 1.5
            )
        ])
        mockedDBRepo.actions = .init(expected: [
            .clearBasket,
            .store(basket: basket)
        ])
        
        // Configuring responses from repositories
        mockedWebRepo.updateTipResponse = .success(basket)
        mockedDBRepo.clearBasketResult = .success(true)
        mockedDBRepo.storeBasketResult = .success(basket)
        
        let exp = XCTestExpectation(description: #function)
        sut
            .updateTip(to: 1.5)
            .sinkToResult { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success:
                    XCTAssertEqual(self.appState.value.userData.basket, basket, file: #file, line: #line)
                case let .failure(error):
                    XCTFail("Unexpected error: \(error)", file: #file, line: #line)
                }
                self.mockedWebRepo.verify()
                self.mockedDBRepo.verify()
                exp.fulfill()
            }
            .store(in: &subscriptions)

        wait(for: [exp], timeout: 0.5)
    }
}
