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
//func updateFulfilmentMethodAndStore() -> Future<Void, Error>
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
//func reserveTimeSlot(timeSlotDate: String, timeSlotTime: String?) -> Future<Void, Error>
final class ReserveTimeSlotTests: BasketServiceTests {
}

// MARK: - func addItem(item:)
//func addItem(item: BasketItemRequest) -> Future<Void, Error>
final class AddItemTests: BasketServiceTests {
}

// MARK: - func updateItem(item:basketLineId:)
//func updateItem(item: BasketItemRequest, basketLineId: Int) -> Future<Void, Error>
final class UpdateItemTests: BasketServiceTests {
}

// MARK: - func removeItem(basketLineId:)
//func removeItem(basketLineId: Int) -> Future<Void, Error>
final class RemoveItemTests: BasketServiceTests {
}

// MARK: - func applyCoupon(code:)
//func applyCoupon(code: String) -> Future<Void, Error>
final class ApplyCouponTests: BasketServiceTests {
}

// MARK: - func removeCoupon()
//func removeCoupon() -> Future<Void, Error>
final class RemoveCouponTests: BasketServiceTests {
}

// MARK: - func clearItems()
//func clearItems() -> Future<Void, Error>
final class ClearItemsTests: BasketServiceTests {
}

// MARK: - func setDeliveryAddress(to:)
//func setDeliveryAddress(to: BasketAddressRequest) -> Future<Void, Error>
final class SetDeliveryAddressTests: BasketServiceTests {
}

// MARK: - func setBillingAddress(to:)
//func setBillingAddress(to: BasketAddressRequest) -> Future<Void, Error>
final class SetBillingAddressTests: BasketServiceTests {
}

// MARK: - func updateTip(to:)
//func updateTip(to: Double) -> Future<Void, Error>
final class UpdateTipTests: BasketServiceTests {
}
