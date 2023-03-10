//
//  BasketServiceTests.swift
//  SnappyV2Tests
//
//  Created by Kevin Palser on 30/01/2022.
//

import XCTest
import Combine

// import 3rd party
import AppsFlyerLib
import FBSDKCoreKit
import Firebase

@testable import SnappyV2

class BasketServiceTests: XCTestCase {
    
    var appState = CurrentValueSubject<AppState, Never>(AppState())
    var mockedEventLogger: MockedEventLogger!
    var mockedWebRepo: MockedBasketWebRepository!
    var mockedDBRepo: MockedBasketDBRepository!
    var notificationService: MockedNotificationService!
    var subscriptions = Set<AnyCancellable>()
    var sut: BasketService!
    
    override func setUp() {
        mockedEventLogger = MockedEventLogger()
        mockedWebRepo = MockedBasketWebRepository()
        mockedDBRepo = MockedBasketDBRepository()
        notificationService = MockedNotificationService()
        let sut = BasketService(
            webRepository: mockedWebRepo,
            dbRepository: mockedDBRepo,
            notificationService: notificationService,
            appState: appState,
            eventLogger: mockedEventLogger
        )
        
        // Commented out and left just to remind that there are
        // potential memory leaks due to the actor reference type,
        // however, this is currently deemed a non-issue as the
        // basket service is constantly available, and thus does
        // not deinit. This *should* be kept in mind and monitored
        // in future though.
//        trackForMemoryLeaks(sut)
        
        self.sut = sut
    }
    
    func delay(_ closure: @escaping () -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: closure)
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

// MARK: - conditionallyGetBasket(basketToken:storeId)
final class ConditionallyGetBasketTests: BasketServiceTests {
    
    func test_storeIdMismatch() async {
        let store = RetailStoreDetails.mockedData
        let searchResult = RetailStoresSearch.mockedData
        let basket = Basket.mockedData
        let isFirstOrder = true
        
        // Configuring app prexisting states
        appState.value.userData.isFirstOrder = isFirstOrder
        appState.value.userData.selectedStore = .loaded(store)
        appState.value.userData.searchResult = .loaded(searchResult)
        appState.value.userData.selectedFulfilmentMethod = .delivery
        appState.value.userData.basket = Basket.mockedDataStoreIdMismatch
        
        mockedWebRepo.actions = .init(expected: [
            .getBasket(
                basketToken: "8c6f3a9a1f2ffa9e93a9ec2920a4a911",
                storeId: store.id,
                fulfilmentMethod: appState.value.userData.selectedFulfilmentMethod,
                fulfilmentLocation: searchResult.fulfilmentLocation,
                isFirstOrder: isFirstOrder
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
        
        do {
            // removeCoupon used as an easy test for conditionallyGetBasket
            try await sut.removeCoupon()
            
            XCTAssertEqual(sut.appState.value.userData.basket, basket, file: #file, line: #line)
        } catch {
            XCTFail("Unexpected error: \(error)", file: #file, line: #line)
        }
        
        self.mockedWebRepo.verify()
        self.mockedDBRepo.verify()
    }
    
    func test_fulfilmentMethodMismatch() async {
        let store = RetailStoreDetails.mockedData
        let searchResult = RetailStoresSearch.mockedData
        let basket = Basket.mockedData
        let isFirstOrder = true
        
        // Configuring app prexisting states
        appState.value.userData.isFirstOrder = isFirstOrder
        appState.value.userData.selectedStore = .loaded(store)
        appState.value.userData.searchResult = .loaded(searchResult)
        appState.value.userData.selectedFulfilmentMethod = .delivery
        appState.value.userData.basket = Basket.mockedDataStoreFulfilmentMismatch
        
        mockedWebRepo.actions = .init(expected: [
            .getBasket(
                basketToken: "8c6f3a9a1f2ffa9e93a9ec2920a4a911",
                storeId: store.id,
                fulfilmentMethod: appState.value.userData.selectedFulfilmentMethod,
                fulfilmentLocation: searchResult.fulfilmentLocation,
                isFirstOrder: isFirstOrder
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
        
        do {
            // removeCoupon used as an easy test for conditionallyGetBasket
            try await sut.removeCoupon()
            
            XCTAssertEqual(sut.appState.value.userData.basket, basket, file: #file, line: #line)
        } catch {
            XCTFail("Unexpected error: \(error)", file: #file, line: #line)
        }
        
        self.mockedWebRepo.verify()
        self.mockedDBRepo.verify()
    }
}

// MARK: - func restoreBasket()
final class RestoreBasketTests: BasketServiceTests {
    
    func test_unsuccessRestoreBasket_whenNoSelectedStore_returnError() async {
        
        do {
            try await sut.restoreBasket()
            
            XCTFail("Unexpected success", file: #file, line: #line)
        } catch {
            if let basketError = error as? BasketServiceError {
                XCTAssertEqual(basketError, BasketServiceError.storeSelectionRequired, file: #file, line: #line)
            } else {
                XCTFail("Unexpected error type: \(error)", file: #file, line: #line)
            }
        }
        
        self.mockedWebRepo.verify()
        self.mockedDBRepo.verify()
    }
    
    func test_successRestoreBasket_whenNoBasketToRestore_returnNil() async {
        
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
        
        do {
            try await sut.restoreBasket()
            
            XCTAssertEqual(sut.appState.value.userData.basket, nil, file: #file, line: #line)
        } catch {
            XCTFail("Unexpected error: \(error)", file: #file, line: #line)
        }
        
        self.mockedWebRepo.verify()
        self.mockedDBRepo.verify()
    }
    
    func test_successRestoreBasket_whenBasketToRestore_setAppStateBasket() async {
        
        let basket = Basket.mockedData
        let store = RetailStoreDetails.mockedData
        let isFirstOrder = true
        
        // Configuring app prexisting states
        appState.value.userData.isFirstOrder = isFirstOrder
        appState.value.userData.selectedStore = .loaded(store)
        appState.value.userData.selectedFulfilmentMethod = .delivery
        
        // Configuring expected actions on repositories
        
        mockedWebRepo.actions = .init(expected: [
            .getBasket(
                basketToken: basket.basketToken,
                storeId: store.id,
                fulfilmentMethod: appState.value.userData.selectedFulfilmentMethod,
                fulfilmentLocation: nil,
                isFirstOrder: isFirstOrder
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
        
        do {
            try await sut.restoreBasket()
            
            XCTAssertEqual(sut.appState.value.userData.basket, basket, file: #file, line: #line)
        } catch {
            XCTFail("Unexpected error: \(error)", file: #file, line: #line)
        }
        
        self.mockedWebRepo.verify()
        self.mockedDBRepo.verify()
    }
    
    func test_unsuccessRestoreBasket_whenOldBasketInDBAndNetworkError_returnError() async {
        
        let networkError = NSError(domain: NSURLErrorDomain, code: -1009, userInfo: [:])
        let basket = Basket.mockedData
        let store = RetailStoreDetails.mockedData
        let isFirstOrder = true
        
        // Configuring app prexisting states
        appState.value.userData.isFirstOrder = isFirstOrder
        appState.value.userData.selectedStore = .loaded(store)
        appState.value.userData.selectedFulfilmentMethod = .delivery
        
        // Configuring expected actions on repositories
        
        mockedWebRepo.actions = .init(expected: [
            .getBasket(
                basketToken: basket.basketToken,
                storeId: store.id,
                fulfilmentMethod: appState.value.userData.selectedFulfilmentMethod,
                fulfilmentLocation: nil,
                isFirstOrder: isFirstOrder
            )
        ])
        mockedDBRepo.actions = .init(expected: [
            .fetchBasket
        ])
        
        // Configuring responses from repositories
        
        mockedWebRepo.getBasketResponse = .failure(networkError)
        mockedDBRepo.fetchBasketResult = .success(basket)
        
        do {
            try await sut.restoreBasket()
            
            XCTFail("Unexpected success", file: #file, line: #line)
        } catch {
            XCTAssertEqual(error as NSError, networkError, file: #file, line: #line)
        }
        
        self.mockedWebRepo.verify()
        self.mockedDBRepo.verify()
    }
}

// MARK: - func updateFulfilmentMethodAndStore()
final class UpdateFulfilmentMethodAndStoreTests: BasketServiceTests {
    
    func test_unsuccessUpdateFulfilmentMethodAndStore_whenNoStoreSelected_returnError() async {
        
        do {
            try await sut.updateFulfilmentMethodAndStore()
            
            XCTFail("Unexpected success", file: #file, line: #line)
        } catch {
            if let basketError = error as? BasketServiceError {
                XCTAssertEqual(basketError, BasketServiceError.storeSelectionRequired, file: #file, line: #line)
            } else {
                XCTFail("Unexpected error type: \(error)", file: #file, line: #line)
            }
        }
        
        self.mockedWebRepo.verify()
        self.mockedDBRepo.verify()
    }
    
    func test_unsuccessUpdateFulfilmentMethodAndStore_whenSelectedStoreAndNoFulfilmentLocation_returnError() async {
        
        let store = RetailStoreDetails.mockedData
        
        // Configuring app prexisting states
        appState.value.userData.selectedStore = .loaded(store)
        
        do {
            try await sut.updateFulfilmentMethodAndStore()
            
            XCTFail("Unexpected success", file: #file, line: #line)
        } catch {
            if let basketError = error as? BasketServiceError {
                XCTAssertEqual(basketError, BasketServiceError.fulfilmentLocationRequired, file: #file, line: #line)
            } else {
                XCTFail("Unexpected error type: \(error)", file: #file, line: #line)
            }
        }
        
        self.mockedWebRepo.verify()
        self.mockedDBRepo.verify()
    }
    
    func test_successUpdateFulfilmentMethodAndStore_whenSelectedStoreAndFulfilmentLocationWithoutBasket_setAppStateBasket() async {
        
        let store = RetailStoreDetails.mockedData
        let searchResult = RetailStoresSearch.mockedData
        let basket = Basket.mockedData
        let isFirstOrder = true
        
        // Configuring app prexisting states
        appState.value.userData.isFirstOrder = isFirstOrder
        appState.value.userData.selectedStore = .loaded(store)
        appState.value.userData.searchResult = .loaded(searchResult)
        
        mockedWebRepo.actions = .init(expected: [
            .getBasket(
                basketToken: nil,
                storeId: store.id,
                fulfilmentMethod: appState.value.userData.selectedFulfilmentMethod,
                fulfilmentLocation: searchResult.fulfilmentLocation,
                isFirstOrder: isFirstOrder
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
        
        do {
            try await sut.updateFulfilmentMethodAndStore()
            
            XCTAssertEqual(sut.appState.value.userData.basket, basket, file: #file, line: #line)
        } catch {
            XCTFail("Unexpected error: \(error)", file: #file, line: #line)
        }
        
        self.mockedWebRepo.verify()
        self.mockedDBRepo.verify()
    }
    
    func test_successUpdateFulfilmentMethodAndStore_whenSelectedStoreAndFulfilmentLocationWithBasket_setAppStateBasket() async {
        
        let store = RetailStoreDetails.mockedData
        let searchResult = RetailStoresSearch.mockedData
        let basket = Basket.mockedData
        let isFirstOrder = true
        
        // Configuring app prexisting states
        appState.value.userData.isFirstOrder = isFirstOrder
        appState.value.userData.selectedStore = .loaded(store)
        appState.value.userData.searchResult = .loaded(searchResult)
        appState.value.userData.basket = basket
        
        mockedWebRepo.actions = .init(expected: [
            .getBasket(
                basketToken: basket.basketToken,
                storeId: store.id,
                fulfilmentMethod: appState.value.userData.selectedFulfilmentMethod,
                fulfilmentLocation: searchResult.fulfilmentLocation,
                isFirstOrder: isFirstOrder
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
        
        do {
            try await sut.updateFulfilmentMethodAndStore()
            
            XCTAssertEqual(sut.appState.value.userData.basket, basket, file: #file, line: #line)
        } catch {
            XCTFail("Unexpected error: \(error)", file: #file, line: #line)
        }
        
        self.mockedWebRepo.verify()
        self.mockedDBRepo.verify()
    }
}

// MARK: - func reserveTimeSlot(timeSlotDate:timeSlotTime:)
final class ReserveTimeSlotTests: BasketServiceTests {
    
    func test_unsuccessReserveTimeSlot_whenNoStoreSelected_returnError() async {
        
        do {
            try await sut.reserveTimeSlot(timeSlotDate: "2022-03-11", timeSlotTime: nil)
            
            XCTFail("Unexpected success", file: #file, line: #line)
        } catch {
            if let basketError = error as? BasketServiceError {
                XCTAssertEqual(basketError, BasketServiceError.storeSelectionRequired, file: #file, line: #line)
            } else {
                XCTFail("Unexpected error type: \(error)", file: #file, line: #line)
            }
        }
        
        self.mockedWebRepo.verify()
        self.mockedDBRepo.verify()
    }
    
    func test_unsuccessReserveTimeSlot_whenStoreSelectedButNoFulfilmentLocation_returnError() async {
        
        let store = RetailStoreDetails.mockedData
        
        // Configuring app prexisting states
        appState.value.userData.selectedStore = .loaded(store)
        
        do {
            try await sut.reserveTimeSlot(timeSlotDate: "2022-03-11", timeSlotTime: nil)
            
            XCTFail("Unexpected success)", file: #file, line: #line)
        } catch {
            if let basketError = error as? BasketServiceError {
                XCTAssertEqual(basketError, BasketServiceError.fulfilmentLocationRequired, file: #file, line: #line)
            } else {
                XCTFail("Unexpected error type: \(error)", file: #file, line: #line)
            }
        }
        
        self.mockedWebRepo.verify()
        self.mockedDBRepo.verify()
    }
    
    func test_successReserveTimeSlot_whenSelectedStoreAndFulfilmentLocationWithoutBasket_setAppStateBasket() async {
        
        let store = RetailStoreDetails.mockedData
        let searchResult = RetailStoresSearch.mockedData
        let basket = Basket.mockedData
        let isFirstOrder = true
        
        // Configuring app prexisting states
        appState.value.userData.isFirstOrder = isFirstOrder
        appState.value.userData.selectedStore = .loaded(store)
        appState.value.userData.searchResult = .loaded(searchResult)
        
        mockedWebRepo.actions = .init(expected: [
            .getBasket(
                basketToken: nil,
                storeId: store.id,
                fulfilmentMethod: appState.value.userData.selectedFulfilmentMethod,
                fulfilmentLocation: searchResult.fulfilmentLocation,
                isFirstOrder: isFirstOrder
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
        
        do {
            try await sut.reserveTimeSlot(timeSlotDate: "2022-03-11", timeSlotTime: nil)
            
            XCTAssertEqual(sut.appState.value.userData.basket, basket, file: #file, line: #line)
        } catch {
            XCTFail("Unexpected error: \(error)", file: #file, line: #line)
        }
        
        self.mockedWebRepo.verify()
        self.mockedDBRepo.verify()
    }
    
    func test_successReserveTimeSlot_whenSelectedStoreAndFulfilmentLocationWithBasket_setAppStateBasket() async {
        
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
        
        do {
            try await sut.reserveTimeSlot(timeSlotDate: "2022-03-11", timeSlotTime: nil)
            
            XCTAssertEqual(sut.appState.value.userData.basket, basket, file: #file, line: #line)
        } catch {
            XCTFail("Unexpected error: \(error)", file: #file, line: #line)
        }
        
        self.mockedWebRepo.verify()
        self.mockedDBRepo.verify()
    }
}

// MARK: - func addItem(item:)
final class AddItemTests: BasketServiceTests {
    
    func test_unsuccessAddItem_whenNoStoreSelected_returnError() async {
        
        let itemRequest = BasketItemRequest.mockedData
        let item = RetailStoreMenuItem.mockedData
        
        do {
            try await sut.addItem(basketItemRequest: itemRequest, item: item)
            
            XCTFail("Unexpected success", file: #file, line: #line)
        } catch {
            if let basketError = error as? BasketServiceError {
                XCTAssertEqual(basketError, BasketServiceError.storeSelectionRequired, file: #file, line: #line)
            } else {
                XCTFail("Unexpected error type: \(error)", file: #file, line: #line)
            }
        }
        self.mockedWebRepo.verify()
        self.mockedDBRepo.verify()
        self.mockedEventLogger.verify()
    }
    
    func test_unsuccessAddItem_whenStoreSelectedButNoFulfilmentLocation_returnError() async {
        
        let itemRequest = BasketItemRequest.mockedData
        let store = RetailStoreDetails.mockedData
        let item = RetailStoreMenuItem.mockedData
        
        // Configuring app prexisting states
        appState.value.userData.selectedStore = .loaded(store)
        
        do {
            try await sut.addItem(basketItemRequest: itemRequest, item: item)
            
            XCTFail("Unexpected success", file: #file, line: #line)
        } catch {
            if let basketError = error as? BasketServiceError {
                XCTAssertEqual(basketError, BasketServiceError.fulfilmentLocationRequired, file: #file, line: #line)
            } else {
                XCTFail("Unexpected error type: \(error)", file: #file, line: #line)
            }
        }
        
        self.mockedWebRepo.verify()
        self.mockedDBRepo.verify()
        self.mockedEventLogger.verify()
    }
    
    func test_successAddItem_whenSelectedStoreAndFulfilmentLocationWithoutBasketAndIsFirstOrder_setAppStateBasket() async {
        
        let itemRequest = BasketItemRequest.mockedData
        let store = RetailStoreDetails.mockedData
        let searchResult = RetailStoresSearch.mockedData
        let basket = Basket.mockedData
        let item = basket.items.first!.menuItem
        
        let contentId = AppV2Constants.EventsLogging.analyticsItemIdPrefix + "\(item.id)"
        let currencyCode = appState.value.userData.selectedStore.value?.currency.currencyCode ?? AppV2Constants.Business.currencyCode
        let isFirstOrder = true
        
        // Configuring app prexisting states
        appState.value.userData.isFirstOrder = isFirstOrder
        appState.value.userData.selectedStore = .loaded(store)
        appState.value.userData.searchResult = .loaded(searchResult)
        
        mockedWebRepo.actions = .init(expected: [
            .getBasket(
                basketToken: nil,
                storeId: store.id,
                fulfilmentMethod: appState.value.userData.selectedFulfilmentMethod,
                fulfilmentLocation: searchResult.fulfilmentLocation,
                isFirstOrder: isFirstOrder
            ),
            .addItem(
                basketToken: basket.basketToken,
                item: itemRequest,
                fulfilmentMethod: basket.fulfilmentMethod.type,
                isFirstOrder: isFirstOrder
            )
        ])
        mockedDBRepo.actions = .init(expected: [
            .clearBasket,
            .store(basket: basket),
            .clearBasket,
            .store(basket: basket)
        ])
        
        let appsFlyerEventParameters: [String: Any] = [
            AFEventParamPrice:          item.price.price,
            AFEventParamContent:        item.eposCode ?? "",
            AFEventParamContentId:      item.id,
            AFEventParamContentType:    item.mainCategory.name,
            AFEventParamCurrency:       currencyCode,
            AFEventParamQuantity:       itemRequest.quantity ?? 1,
            "product_name":             item.name
        ]
        
        let facebookParams: [AppEvents.ParameterName: Any] = [
            .description: item.name,
            .contentID: contentId,
            .contentType: "product",
            .numItems: itemRequest.quantity ?? 1,
            .currency: appState.value.userData.selectedStore.value?.currency.currencyCode ?? AppV2Constants.Business.currencyCode
        ]
        let facebookEventParameters: [String: Any] = [
            "valueToSum": item.price.price,
            "facebookParams": facebookParams
        ]
        
        let addedItem: [String: Any] = [
            AnalyticsParameterItemID: contentId,
            AnalyticsParameterQuantity: itemRequest.quantity ?? 1,
            AnalyticsParameterPrice: NSDecimalNumber(value: item.price.price).rounding(accordingToBehavior: EventLogger.decimalBehavior).doubleValue
        ]
        let firebaseEventParams: [String: Any] = [
            AnalyticsParameterCurrency: currencyCode,
            AnalyticsParameterItems: [addedItem],
            AnalyticsParameterValue: NSDecimalNumber(value: item.price.price * Double(itemRequest.quantity ?? 1)).rounding(accordingToBehavior: EventLogger.decimalBehavior).doubleValue
        ]
        
        mockedEventLogger.actions = .init(expected: [
            .sendEvent(for: .addToBasket, with: .appsFlyer, params: appsFlyerEventParameters),
            .sendEvent(for: .addToBasket, with: .facebook, params: facebookEventParameters),
            .sendEvent(for: .addToBasket, with: .firebaseAnalytics, params: firebaseEventParams)
        ])
        
        // Configuring responses from repositories
        mockedWebRepo.getBasketResponse = .success(basket)
        mockedWebRepo.addItemResponse = .success(basket)
        mockedDBRepo.clearBasketResult = .success(true)
        mockedDBRepo.storeBasketResult = .success(basket)
        
        do {
            try await sut.addItem(basketItemRequest: itemRequest, item: item)
            
            XCTAssertEqual(sut.appState.value.userData.basket, basket, file: #file, line: #line)
        } catch {
            XCTFail("Unexpected error: \(error)", file: #file, line: #line)
        }
        
        self.mockedWebRepo.verify()
        self.mockedDBRepo.verify()
        self.mockedEventLogger.verify()
    }
    
    func test_successAddItem_whenSelectedStoreAndFulfilmentLocationWithoutBasketAndIsNotFirstOrder_setAppStateBasket() async {
        
        let itemRequest = BasketItemRequest.mockedData
        let store = RetailStoreDetails.mockedData
        let searchResult = RetailStoresSearch.mockedData
        let basket = Basket.mockedData
        let item = basket.items.first!.menuItem
        
        let contentId = AppV2Constants.EventsLogging.analyticsItemIdPrefix + "\(item.id)"
        let currencyCode = appState.value.userData.selectedStore.value?.currency.currencyCode ?? AppV2Constants.Business.currencyCode
        let isFirstOrder = false
        
        // Configuring app prexisting states
        appState.value.userData.isFirstOrder = isFirstOrder
        appState.value.userData.selectedStore = .loaded(store)
        appState.value.userData.searchResult = .loaded(searchResult)
        
        mockedWebRepo.actions = .init(expected: [
            .getBasket(
                basketToken: nil,
                storeId: store.id,
                fulfilmentMethod: appState.value.userData.selectedFulfilmentMethod,
                fulfilmentLocation: searchResult.fulfilmentLocation,
                isFirstOrder: isFirstOrder
            ),
            .addItem(
                basketToken: basket.basketToken,
                item: itemRequest,
                fulfilmentMethod: basket.fulfilmentMethod.type,
                isFirstOrder: isFirstOrder
            )
        ])
        mockedDBRepo.actions = .init(expected: [
            .clearBasket,
            .store(basket: basket),
            .clearBasket,
            .store(basket: basket)
        ])
        
        let appsFlyerEventParameters: [String: Any] = [
            AFEventParamPrice:          item.price.price,
            AFEventParamContent:        item.eposCode ?? "",
            AFEventParamContentId:      item.id,
            AFEventParamContentType:    item.mainCategory.name,
            AFEventParamCurrency:       currencyCode,
            AFEventParamQuantity:       itemRequest.quantity ?? 1,
            "product_name":             item.name
        ]
        
        let facebookParams: [AppEvents.ParameterName: Any] = [
            .description: item.name,
            .contentID: contentId,
            .contentType: "product",
            .numItems: itemRequest.quantity ?? 1,
            .currency: appState.value.userData.selectedStore.value?.currency.currencyCode ?? AppV2Constants.Business.currencyCode
        ]
        let facebookEventParameters: [String: Any] = [
            "valueToSum": item.price.price,
            "facebookParams": facebookParams
        ]
        
        let addedItem: [String: Any] = [
            AnalyticsParameterItemID: contentId,
            AnalyticsParameterQuantity: itemRequest.quantity ?? 1,
            AnalyticsParameterPrice: NSDecimalNumber(value: item.price.price).rounding(accordingToBehavior: EventLogger.decimalBehavior).doubleValue
        ]
        let firebaseEventParams: [String: Any] = [
            AnalyticsParameterCurrency: currencyCode,
            AnalyticsParameterItems: [addedItem],
            AnalyticsParameterValue: NSDecimalNumber(value: item.price.price * Double(itemRequest.quantity ?? 1)).rounding(accordingToBehavior: EventLogger.decimalBehavior).doubleValue
        ]
        
        mockedEventLogger.actions = .init(expected: [
            .sendEvent(for: .addToBasket, with: .appsFlyer, params: appsFlyerEventParameters),
            .sendEvent(for: .addToBasket, with: .facebook, params: facebookEventParameters),
            .sendEvent(for: .addToBasket, with: .firebaseAnalytics, params: firebaseEventParams)
        ])
        
        // Configuring responses from repositories
        mockedWebRepo.getBasketResponse = .success(basket)
        mockedWebRepo.addItemResponse = .success(basket)
        mockedDBRepo.clearBasketResult = .success(true)
        mockedDBRepo.storeBasketResult = .success(basket)
        
        do {
            try await sut.addItem(basketItemRequest: itemRequest, item: item)
            
            XCTAssertEqual(sut.appState.value.userData.basket, basket, file: #file, line: #line)
        } catch {
            XCTFail("Unexpected error: \(error)", file: #file, line: #line)
        }
        
        self.mockedWebRepo.verify()
        self.mockedDBRepo.verify()
        self.mockedEventLogger.verify()
    }
    
    func test_successAddItem_whenSelectedStoreAndFulfilmentLocationWithBasket_setAppStateBasket() async {
        
        let itemRequest = BasketItemRequest.mockedData
        let store = RetailStoreDetails.mockedData
        let searchResult = RetailStoresSearch.mockedData
        let basket = Basket.mockedData
        let item = basket.items.first!.menuItem
        
        let contentId = AppV2Constants.EventsLogging.analyticsItemIdPrefix + "\(item.id)"
        let currencyCode = appState.value.userData.selectedStore.value?.currency.currencyCode ?? AppV2Constants.Business.currencyCode
        let isFirstOrder = true
        
        // Configuring app prexisting states
        appState.value.userData.isFirstOrder = isFirstOrder
        appState.value.userData.selectedStore = .loaded(store)
        appState.value.userData.searchResult = .loaded(searchResult)
        appState.value.userData.basket = basket
        
        mockedWebRepo.actions = .init(expected: [
            .addItem(
                basketToken: basket.basketToken,
                item: itemRequest,
                fulfilmentMethod: basket.fulfilmentMethod.type,
                isFirstOrder: isFirstOrder
            )
        ])
        mockedDBRepo.actions = .init(expected: [
            .clearBasket,
            .store(basket: basket)
        ])
        
        let appsFlyerEventParameters: [String: Any] = [
            AFEventParamPrice:          item.price.price,
            AFEventParamContent:        item.eposCode ?? "",
            AFEventParamContentId:      item.id,
            AFEventParamContentType:    item.mainCategory.name,
            AFEventParamCurrency:       currencyCode,
            AFEventParamQuantity:       itemRequest.quantity ?? 1,
            "product_name":             item.name
        ]
        
        let facebookParams: [AppEvents.ParameterName: Any] = [
            .description: item.name,
            .contentID: contentId,
            .contentType: "product",
            .numItems: itemRequest.quantity ?? 1,
            .currency: currencyCode
        ]
        let facebookEventParameters: [String: Any] = [
            "valueToSum": item.price.price,
            "facebookParams": facebookParams
        ]
        
        let addedItem: [String: Any] = [
            AnalyticsParameterItemID: contentId,
            AnalyticsParameterQuantity: itemRequest.quantity ?? 1,
            AnalyticsParameterPrice: NSDecimalNumber(value: item.price.price).rounding(accordingToBehavior: EventLogger.decimalBehavior).doubleValue
        ]
        let firebaseEventParams: [String: Any] = [
            AnalyticsParameterCurrency: currencyCode,
            AnalyticsParameterItems: [addedItem],
            AnalyticsParameterValue: NSDecimalNumber(value: item.price.price * Double(itemRequest.quantity ?? 1)).rounding(accordingToBehavior: EventLogger.decimalBehavior).doubleValue
        ]
        
        mockedEventLogger.actions = .init(expected: [
            .sendEvent(for: .addToBasket, with: .appsFlyer, params: appsFlyerEventParameters),
            .sendEvent(for: .addToBasket, with: .facebook, params: facebookEventParameters),
            .sendEvent(for: .addToBasket, with: .firebaseAnalytics, params: firebaseEventParams)
        ])
        
        // Configuring responses from repositories
        mockedWebRepo.addItemResponse = .success(basket)
        mockedDBRepo.clearBasketResult = .success(true)
        mockedDBRepo.storeBasketResult = .success(basket)
        
        do {
            try await sut.addItem(basketItemRequest: itemRequest, item: basket.items.first!.menuItem)
            
            XCTAssertEqual(sut.appState.value.userData.basket, basket, file: #file, line: #line)
        } catch {
            XCTFail("Unexpected error: \(error)", file: #file, line: #line)
        }
        
        self.mockedWebRepo.verify()
        self.mockedDBRepo.verify()
        self.mockedEventLogger.verify()
    }
}

// MARK: - func updateItem(item:basketLineId:)
final class UpdateItemTests: BasketServiceTests {
    
    func test_unsuccessUpdateItem_whenNoStoreSelected_returnError() async {
        
        let itemRequest = BasketItemRequest.mockedData
        let basket = Basket.mockedData
        
        do {
            try await sut.updateItem(basketItemRequest: itemRequest, basketItem: basket.items.first!)
            
            XCTFail("Unexpected success", file: #file, line: #line)
        } catch {
            if let basketError = error as? BasketServiceError {
                XCTAssertEqual(basketError, BasketServiceError.storeSelectionRequired, file: #file, line: #line)
            } else {
                XCTFail("Unexpected error type: \(error)", file: #file, line: #line)
            }
        }
        
        self.mockedWebRepo.verify()
        self.mockedDBRepo.verify()
        self.mockedEventLogger.verify()
    }
    
    func test_unsuccessUpdateItem_whenStoreSelectedButNoFulfilmentLocation_returnError() async {
        
        let itemRequest = BasketItemRequest.mockedData
        let basket = Basket.mockedData
        let store = RetailStoreDetails.mockedData
        
        // Configuring app prexisting states
        appState.value.userData.selectedStore = .loaded(store)
        
        do {
            try await sut.updateItem(basketItemRequest: itemRequest, basketItem: basket.items.first!)
            
            XCTFail("Unexpected success", file: #file, line: #line)
        } catch {
            if let basketError = error as? BasketServiceError {
                XCTAssertEqual(basketError, BasketServiceError.fulfilmentLocationRequired, file: #file, line: #line)
            } else {
                XCTFail("Unexpected error type: \(error)", file: #file, line: #line)
            }
        }
        
        self.mockedWebRepo.verify()
        self.mockedDBRepo.verify()
        self.mockedEventLogger.verify()
    }
    
    func test_successUpdateItem_whenSelectedStoreAndFulfilmentLocationWithoutBasketAndIsFirstOrder_setAppStateBasket() async {
        
        let itemRequest = BasketItemRequest.mockedData
        let store = RetailStoreDetails.mockedData
        let searchResult = RetailStoresSearch.mockedData
        let basket = Basket.mockedData
        
        let contentId = AppV2Constants.EventsLogging.analyticsItemIdPrefix + "\(basket.items.first!.menuItem.id)"
        let currencyCode = store.currency.currencyCode
        let isFirstOrder = true
        
        // Configuring app prexisting states
        appState.value.userData.isFirstOrder = isFirstOrder
        appState.value.userData.selectedStore = .loaded(store)
        appState.value.userData.searchResult = .loaded(searchResult)
        
        mockedWebRepo.actions = .init(expected: [
            .getBasket(
                basketToken: nil,
                storeId: store.id,
                fulfilmentMethod: appState.value.userData.selectedFulfilmentMethod,
                fulfilmentLocation: searchResult.fulfilmentLocation,
                isFirstOrder: isFirstOrder
            ),
            .updateItem(
                basketToken: basket.basketToken,
                basketLineId: basket.items.first!.basketLineId,
                item: itemRequest,
                isFirstOrder: isFirstOrder
            )
        ])
        mockedDBRepo.actions = .init(expected: [
            .clearBasket,
            .store(basket: basket),
            .clearBasket,
            .store(basket: basket)
        ])
        
        var appsFlyerEventParameters: [String: Any] = [
            AFEventParamPrice:          basket.items.first!.menuItem.price.price,
            AFEventParamContentId:      basket.items.first!.menuItem.id,
            AFEventParamContentType:    basket.items.first!.menuItem.mainCategory.name,
            AFEventParamCurrency:       currencyCode,
            AFEventParamQuantity:       itemRequest.quantity ?? 2,
            "product_name":             basket.items.first!.menuItem.name
        ]
        if let eposCode = basket.items.first!.menuItem.eposCode {
            appsFlyerEventParameters[AFEventParamContent] = eposCode
        }
        
        let facebookParams: [AppEvents.ParameterName: Any] = [
            .description: basket.items.first!.menuItem.name,
            .contentID: contentId,
            .contentType: "product",
            .numItems: itemRequest.quantity ?? 2,
            .currency: appState.value.userData.selectedStore.value?.currency.currencyCode ?? AppV2Constants.Business.currencyCode
        ]
        let facebookEventParameters: [String: Any] = [
            "valueToSum": basket.items.first!.menuItem.price.price,
            "facebookParams": facebookParams
        ]
        
        let addedItem: [String: Any] = [
            AnalyticsParameterItemID: contentId,
            AnalyticsParameterQuantity: itemRequest.quantity ?? 2,
            AnalyticsParameterPrice: NSDecimalNumber(value: basket.items.first!.menuItem.price.price).rounding(accordingToBehavior: EventLogger.decimalBehavior).doubleValue
        ]
        let firebaseEventParams: [String: Any] = [
            AnalyticsParameterCurrency: currencyCode,
            AnalyticsParameterItems: [addedItem],
            AnalyticsParameterValue: NSDecimalNumber(value: basket.items.first!.menuItem.price.price * Double(itemRequest.quantity ?? 1)).rounding(accordingToBehavior: EventLogger.decimalBehavior).doubleValue
        ]
        
        mockedEventLogger.actions = .init(expected: [
            .sendEvent(for: .updateCart, with: .appsFlyer, params: appsFlyerEventParameters),
            .sendEvent(for: .updateCart, with: .facebook, params: facebookEventParameters),
            .sendEvent(for: .addToBasket, with: .firebaseAnalytics, params: firebaseEventParams)
        ])
        
        // Configuring responses from repositories
        mockedWebRepo.getBasketResponse = .success(basket)
        mockedWebRepo.updateItemResponse = .success(basket)
        mockedDBRepo.clearBasketResult = .success(true)
        mockedDBRepo.storeBasketResult = .success(basket)
        
        do {
            try await sut.updateItem(basketItemRequest: itemRequest, basketItem: basket.items.first!)
            
            XCTAssertEqual(sut.appState.value.userData.basket, basket, file: #file, line: #line)
        } catch {
            XCTFail("Unexpected error: \(error)", file: #file, line: #line)
        }
        
        self.mockedWebRepo.verify()
        self.mockedDBRepo.verify()
        self.mockedEventLogger.verify()
    }
    
    func test_successUpdateItem_whenSelectedStoreAndFulfilmentLocationWithoutBasketAndNotIsFirstOrder_setAppStateBasket() async {
        
        let itemRequest = BasketItemRequest.mockedData
        let store = RetailStoreDetails.mockedData
        let searchResult = RetailStoresSearch.mockedData
        let basket = Basket.mockedData
        
        let contentId = AppV2Constants.EventsLogging.analyticsItemIdPrefix + "\(basket.items.first!.menuItem.id)"
        let currencyCode = store.currency.currencyCode
        let isFirstOrder = false
        
        // Configuring app prexisting states
        appState.value.userData.isFirstOrder = isFirstOrder
        appState.value.userData.selectedStore = .loaded(store)
        appState.value.userData.searchResult = .loaded(searchResult)
        
        mockedWebRepo.actions = .init(expected: [
            .getBasket(
                basketToken: nil,
                storeId: store.id,
                fulfilmentMethod: appState.value.userData.selectedFulfilmentMethod,
                fulfilmentLocation: searchResult.fulfilmentLocation,
                isFirstOrder: isFirstOrder
            ),
            .updateItem(
                basketToken: basket.basketToken,
                basketLineId: basket.items.first!.basketLineId,
                item: itemRequest,
                isFirstOrder: isFirstOrder
            )
        ])
        mockedDBRepo.actions = .init(expected: [
            .clearBasket,
            .store(basket: basket),
            .clearBasket,
            .store(basket: basket)
        ])
        
        var appsFlyerEventParameters: [String: Any] = [
            AFEventParamPrice:          basket.items.first!.menuItem.price.price,
            AFEventParamContentId:      basket.items.first!.menuItem.id,
            AFEventParamContentType:    basket.items.first!.menuItem.mainCategory.name,
            AFEventParamCurrency:       currencyCode,
            AFEventParamQuantity:       itemRequest.quantity ?? 2,
            "product_name":             basket.items.first!.menuItem.name
        ]
        if let eposCode = basket.items.first!.menuItem.eposCode {
            appsFlyerEventParameters[AFEventParamContent] = eposCode
        }
        
        let facebookParams: [AppEvents.ParameterName: Any] = [
            .description: basket.items.first!.menuItem.name,
            .contentID: contentId,
            .contentType: "product",
            .numItems: itemRequest.quantity ?? 2,
            .currency: appState.value.userData.selectedStore.value?.currency.currencyCode ?? AppV2Constants.Business.currencyCode
        ]
        let facebookEventParameters: [String: Any] = [
            "valueToSum": basket.items.first!.menuItem.price.price,
            "facebookParams": facebookParams
        ]
        
        let addedItem: [String: Any] = [
            AnalyticsParameterItemID: contentId,
            AnalyticsParameterQuantity: itemRequest.quantity ?? 2,
            AnalyticsParameterPrice: NSDecimalNumber(value: basket.items.first!.menuItem.price.price).rounding(accordingToBehavior: EventLogger.decimalBehavior).doubleValue
        ]
        let firebaseEventParams: [String: Any] = [
            AnalyticsParameterCurrency: currencyCode,
            AnalyticsParameterItems: [addedItem],
            AnalyticsParameterValue: NSDecimalNumber(value: basket.items.first!.menuItem.price.price * Double(itemRequest.quantity ?? 1)).rounding(accordingToBehavior: EventLogger.decimalBehavior).doubleValue
        ]
        
        mockedEventLogger.actions = .init(expected: [
            .sendEvent(for: .updateCart, with: .appsFlyer, params: appsFlyerEventParameters),
            .sendEvent(for: .updateCart, with: .facebook, params: facebookEventParameters),
            .sendEvent(for: .addToBasket, with: .firebaseAnalytics, params: firebaseEventParams)
        ])
        
        // Configuring responses from repositories
        mockedWebRepo.getBasketResponse = .success(basket)
        mockedWebRepo.updateItemResponse = .success(basket)
        mockedDBRepo.clearBasketResult = .success(true)
        mockedDBRepo.storeBasketResult = .success(basket)
        
        do {
            try await sut.updateItem(basketItemRequest: itemRequest, basketItem: basket.items.first!)
            
            XCTAssertEqual(sut.appState.value.userData.basket, basket, file: #file, line: #line)
        } catch {
            XCTFail("Unexpected error: \(error)", file: #file, line: #line)
        }
        
        self.mockedWebRepo.verify()
        self.mockedDBRepo.verify()
        self.mockedEventLogger.verify()
    }
    
    func test_successUpdateItem_whenSelectedStoreAndFulfilmentLocationWithBasket_setAppStateBasket() async {
        
        let itemRequest = BasketItemRequest.mockedData
        let store = RetailStoreDetails.mockedData
        let searchResult = RetailStoresSearch.mockedData
        let basket = Basket.mockedData
        
        let contentId = AppV2Constants.EventsLogging.analyticsItemIdPrefix + "\(basket.items.first!.menuItem.id)"
        let currencyCode = store.currency.currencyCode
        let isFirstOrder = true
        
        // Configuring app prexisting states
        appState.value.userData.isFirstOrder = isFirstOrder
        appState.value.userData.selectedStore = .loaded(store)
        appState.value.userData.searchResult = .loaded(searchResult)
        appState.value.userData.basket = basket
        
        mockedWebRepo.actions = .init(expected: [
            .updateItem(
                basketToken: basket.basketToken,
                basketLineId: basket.items[0].basketLineId,
                item: itemRequest,
                isFirstOrder: isFirstOrder
            )
        ])
        mockedDBRepo.actions = .init(expected: [
            .clearBasket,
            .store(basket: basket)
        ])
        
        var appsFlyerEventParameters: [String: Any] = [
            AFEventParamPrice:          basket.items.first!.menuItem.price.price,
            AFEventParamContentId:      basket.items.first!.menuItem.id,
            AFEventParamContentType:    basket.items.first!.menuItem.mainCategory.name,
            AFEventParamCurrency:       currencyCode,
            AFEventParamQuantity:       itemRequest.quantity ?? 2,
            "product_name":             basket.items.first!.menuItem.name
        ]
        if let eposCode = basket.items.first!.menuItem.eposCode {
            appsFlyerEventParameters[AFEventParamContent] = eposCode
        }

        let facebookParams: [AppEvents.ParameterName: Any] = [
            .description: basket.items.first!.menuItem.name,
            .contentID: AppV2Constants.EventsLogging.analyticsItemIdPrefix + "\(basket.items.first!.menuItem.id)",
            .contentType: "product",
            .numItems: itemRequest.quantity ?? 2,
            .currency: appState.value.userData.selectedStore.value?.currency.currencyCode ?? AppV2Constants.Business.currencyCode
        ]
        let facebookEventParameters: [String: Any] = [
            "valueToSum": basket.items.first!.menuItem.price.price,
            "facebookParams": facebookParams
        ]
        
        let addedItem: [String: Any] = [
            AnalyticsParameterItemID: contentId,
            AnalyticsParameterQuantity: itemRequest.quantity ?? 2,
            AnalyticsParameterPrice: NSDecimalNumber(value: basket.items.first!.menuItem.price.price).rounding(accordingToBehavior: EventLogger.decimalBehavior).doubleValue
        ]
        let firebaseEventParams: [String: Any] = [
            AnalyticsParameterCurrency: currencyCode,
            AnalyticsParameterItems: [addedItem],
            AnalyticsParameterValue: NSDecimalNumber(value: basket.items.first!.menuItem.price.price * Double(itemRequest.quantity ?? 1)).rounding(accordingToBehavior: EventLogger.decimalBehavior).doubleValue
        ]
        
        mockedEventLogger.actions = .init(expected: [
            .sendEvent(for: .updateCart, with: .appsFlyer, params: appsFlyerEventParameters),
            .sendEvent(for: .updateCart, with: .facebook, params: facebookEventParameters),
            .sendEvent(for: .addToBasket, with: .firebaseAnalytics, params: firebaseEventParams)
        ])
        
        // Configuring responses from repositories
        mockedWebRepo.updateItemResponse = .success(basket)
        mockedDBRepo.clearBasketResult = .success(true)
        mockedDBRepo.storeBasketResult = .success(basket)
        
        do {
            try await sut.updateItem(basketItemRequest: itemRequest, basketItem: basket.items.first!)
            
            XCTAssertEqual(sut.appState.value.userData.basket, basket, file: #file, line: #line)
        } catch {
            XCTFail("Unexpected error: \(error)", file: #file, line: #line)
        }
        
        self.mockedWebRepo.verify()
        self.mockedDBRepo.verify()
        self.mockedEventLogger.verify()
    }
}

// MARK: - func changeItemQuantity(basketItem:changeQuantity:)
final class ChangeItemQuantityTests: BasketServiceTests {
    
    func test_unsuccessChangeItem_whenNoStoreSelected_returnError() async {
        let basketItem = BasketItem.mockedData
        
        do {
            try await sut.changeItemQuantity(basketItem: basketItem, changeQuantity: 2)
            
            XCTFail("Unexpected success", file: #file, line: #line)
        } catch {
            if let basketError = error as? BasketServiceError {
                XCTAssertEqual(basketError, BasketServiceError.storeSelectionRequired, file: #file, line: #line)
            } else {
                XCTFail("Unexpected error type: \(error)", file: #file, line: #line)
            }
        }
        
        self.mockedWebRepo.verify()
        self.mockedDBRepo.verify()
        self.mockedEventLogger.verify()
    }
    
    func test_unsuccessChangeItemQuantity_whenStoreSelectedButNoFulfilmentLocation_returnError() async {
        let basketItem = BasketItem.mockedData
        let store = RetailStoreDetails.mockedData
        
        // Configuring app prexisting states
        appState.value.userData.selectedStore = .loaded(store)
        
        do {
            try await sut.changeItemQuantity(basketItem: basketItem, changeQuantity: 2)
            
            XCTFail("Unexpected success", file: #file, line: #line)
        } catch {
            if let basketError = error as? BasketServiceError {
                XCTAssertEqual(basketError, BasketServiceError.fulfilmentLocationRequired, file: #file, line: #line)
            } else {
                XCTFail("Unexpected error type: \(error)", file: #file, line: #line)
            }
        }
        
        self.mockedWebRepo.verify()
        self.mockedDBRepo.verify()
        self.mockedEventLogger.verify()
    }
    
    func test_successChangeItemQuantity_whenSelectedStoreAndFulfilmentLocationWithoutBasket_setAppStateBasket() async {
        
        let store = RetailStoreDetails.mockedData
        let searchResult = RetailStoresSearch.mockedData
        let basket = Basket.mockedData
        let basketItem = BasketItem.mockedData
        
        let contentId = AppV2Constants.EventsLogging.analyticsItemIdPrefix + "\(basketItem.menuItem.id)"
        let currencyCode = store.currency.currencyCode
        let changeQuantity = 2
        let isFirstOrder = true
        
        // Configuring app prexisting states
        appState.value.userData.isFirstOrder = isFirstOrder
        appState.value.userData.selectedStore = .loaded(store)
        appState.value.userData.searchResult = .loaded(searchResult)
        
        mockedWebRepo.actions = .init(expected: [
            .getBasket(
                basketToken: nil,
                storeId: store.id,
                fulfilmentMethod: appState.value.userData.selectedFulfilmentMethod,
                fulfilmentLocation: searchResult.fulfilmentLocation,
                isFirstOrder: isFirstOrder
            ),
            .changeItemQuantity(
                basketToken: basket.basketToken,
                basketLineId: basketItem.basketLineId,
                changeQuantity: changeQuantity,
                isFirstOrder: isFirstOrder
            )
        ])
        mockedDBRepo.actions = .init(expected: [
            .clearBasket,
            .store(basket: basket),
            .clearBasket,
            .store(basket: basket)
        ])
        var appsFlyerEventParameters: [String: Any] = [
            AFEventParamPrice:          basketItem.menuItem.price.price,
            AFEventParamContentId:      basketItem.menuItem.id,
            AFEventParamContentType:    basketItem.menuItem.mainCategory.name,
            AFEventParamCurrency:       currencyCode,
            AFEventParamQuantity:       changeQuantity,
            "product_name":             basketItem.menuItem.name
        ]
        if let eposCode = basketItem.menuItem.eposCode {
            appsFlyerEventParameters[AFEventParamContent] = eposCode
        }
        
        let facebookParams: [AppEvents.ParameterName: Any] = [
            .description: basketItem.menuItem.name,
            .contentID: contentId,
            .contentType: "product",
            .numItems: changeQuantity,
            .currency: currencyCode
        ]
        
        let facebookEventParameters: [String: Any] = [
            "valueToSum": basketItem.menuItem.price.price,
            "facebookParams": facebookParams
        ]
        
        let addedItem: [String: Any] = [
            AnalyticsParameterItemID: contentId,
            AnalyticsParameterQuantity: changeQuantity,
            AnalyticsParameterPrice: NSDecimalNumber(value: basketItem.menuItem.price.price).rounding(accordingToBehavior: EventLogger.decimalBehavior).doubleValue
        ]
        let firebaseEventParams: [String: Any] = [
            AnalyticsParameterCurrency: currencyCode,
            AnalyticsParameterItems: [addedItem],
            AnalyticsParameterValue: NSDecimalNumber(value: basketItem.menuItem.price.price * Double(changeQuantity)).rounding(accordingToBehavior: EventLogger.decimalBehavior).doubleValue
        ]
        
        mockedEventLogger.actions = .init(expected: [
            .sendEvent(for: .updateCart, with: .appsFlyer, params: appsFlyerEventParameters),
            .sendEvent(for: .updateCart, with: .facebook, params: facebookEventParameters),
            .sendEvent(for: .addToBasket, with: .firebaseAnalytics, params: firebaseEventParams)
        ])
        
        // Configuring responses from repositories
        mockedWebRepo.getBasketResponse = .success(basket)
        mockedWebRepo.changeItemQuantityResponse = .success(basket)
        mockedDBRepo.clearBasketResult = .success(true)
        mockedDBRepo.storeBasketResult = .success(basket)
        
        do {
            try await sut.changeItemQuantity(basketItem: basketItem, changeQuantity: changeQuantity)
            
            XCTAssertEqual(sut.appState.value.userData.basket, basket, file: #file, line: #line)
        } catch {
            XCTFail("Unexpected error: \(error)", file: #file, line: #line)
        }
        
        self.mockedWebRepo.verify()
        self.mockedDBRepo.verify()
        self.mockedEventLogger.verify()
    }
    
    func test_successChangeItemQuantity_whenSelectedStoreAndFulfilmentLocationWitBasket_setAppStateBasket() async {
        
        let store = RetailStoreDetails.mockedData
        let searchResult = RetailStoresSearch.mockedData
        let basket = Basket.mockedData
        let basketItem = BasketItem.mockedData
        
        let contentId = AppV2Constants.EventsLogging.analyticsItemIdPrefix + "\(basketItem.menuItem.id)"
        let currencyCode = store.currency.currencyCode
        let changeQuantity = 2
        let isFirstOrder = true
        
        // Configuring app prexisting states
        appState.value.userData.isFirstOrder = isFirstOrder
        appState.value.userData.selectedStore = .loaded(store)
        appState.value.userData.searchResult = .loaded(searchResult)
        appState.value.userData.basket = basket
        
        mockedWebRepo.actions = .init(expected: [
            .changeItemQuantity(
                basketToken: basket.basketToken,
                basketLineId: basketItem.basketLineId,
                changeQuantity: changeQuantity,
                isFirstOrder: isFirstOrder
            )
        ])
        mockedDBRepo.actions = .init(expected: [
            .clearBasket,
            .store(basket: basket)
        ])
        
        var appsFlyerEventParameters: [String: Any] = [
            AFEventParamPrice:          basketItem.menuItem.price.price,
            AFEventParamContentId:      basketItem.menuItem.id,
            AFEventParamContentType:    basketItem.menuItem.mainCategory.name,
            AFEventParamCurrency:       currencyCode,
            AFEventParamQuantity:       changeQuantity,
            "product_name":             basketItem.menuItem.name
        ]
        if let eposCode = basketItem.menuItem.eposCode {
            appsFlyerEventParameters[AFEventParamContent] = eposCode
        }
        
        let facebookParams: [AppEvents.ParameterName: Any] = [
            .description: basketItem.menuItem.name,
            .contentID: contentId,
            .contentType: "product",
            .numItems: changeQuantity,
            .currency: currencyCode
        ]
        let facebookEventParameters: [String: Any] = [
            "valueToSum": basketItem.menuItem.price.price,
            "facebookParams": facebookParams
        ]
        
        let addedItem: [String: Any] = [
            AnalyticsParameterItemID: contentId,
            AnalyticsParameterQuantity: changeQuantity,
            AnalyticsParameterPrice: NSDecimalNumber(value: basketItem.menuItem.price.price).rounding(accordingToBehavior: EventLogger.decimalBehavior).doubleValue
        ]
        let firebaseEventParams: [String: Any] = [
            AnalyticsParameterCurrency: currencyCode,
            AnalyticsParameterItems: [addedItem],
            AnalyticsParameterValue: NSDecimalNumber(value: basketItem.menuItem.price.price * Double(changeQuantity)).rounding(accordingToBehavior: EventLogger.decimalBehavior).doubleValue
        ]
        
        mockedEventLogger.actions = .init(expected: [
            .sendEvent(for: .updateCart, with: .appsFlyer, params: appsFlyerEventParameters),
            .sendEvent(for: .updateCart, with: .facebook, params: facebookEventParameters),
            .sendEvent(for: .addToBasket, with: .firebaseAnalytics, params: firebaseEventParams)
        ])
        
        // Configuring responses from repositories
        mockedWebRepo.changeItemQuantityResponse = .success(basket)
        mockedDBRepo.clearBasketResult = .success(true)
        mockedDBRepo.storeBasketResult = .success(basket)
        
        do {
            try await sut.changeItemQuantity(basketItem: basketItem, changeQuantity: changeQuantity)
            
            XCTAssertEqual(sut.appState.value.userData.basket, basket, file: #file, line: #line)
        } catch {
            XCTFail("Unexpected error: \(error)", file: #file, line: #line)
        }
        
        self.mockedWebRepo.verify()
        self.mockedDBRepo.verify()
        self.mockedEventLogger.verify()
    }
}

// MARK: - func removeItem(basketLineId:)
final class RemoveItemTests: BasketServiceTests {
    
    func test_unsuccessRemoveItem_whenNoStoreSelected_returnError() async {
        
        let basket = Basket.mockedData
        let item = RetailStoreMenuItem.mockedData
        
        do {
            try await sut.removeItem(basketLineId: basket.items[0].basketLineId, item: item)
            
            XCTFail("Unexpected success", file: #file, line: #line)
        } catch {
            if let basketError = error as? BasketServiceError {
                XCTAssertEqual(basketError, BasketServiceError.storeSelectionRequired, file: #file, line: #line)
            } else {
                XCTFail("Unexpected error type: \(error)", file: #file, line: #line)
            }
        }
        
        self.mockedWebRepo.verify()
        self.mockedDBRepo.verify()
        self.mockedEventLogger.verify()
    }
    
    func test_unsuccessRemoveItem_whenStoreSelectedButNoFulfilmentLocation_returnError() async {
        
        let basket = Basket.mockedData
        let store = RetailStoreDetails.mockedData
        let item = RetailStoreMenuItem.mockedData
        
        // Configuring app prexisting states
        appState.value.userData.selectedStore = .loaded(store)
        
        do {
            try await sut.removeItem(basketLineId: basket.items[0].basketLineId, item: item)
            
            XCTFail("Unexpected success", file: #file, line: #line)
        } catch {
            if let basketError = error as? BasketServiceError {
                XCTAssertEqual(basketError, BasketServiceError.fulfilmentLocationRequired, file: #file, line: #line)
            } else {
                XCTFail("Unexpected error type: \(error)", file: #file, line: #line)
            }
        }
        
        self.mockedWebRepo.verify()
        self.mockedDBRepo.verify()
        self.mockedEventLogger.verify()
    }
    
    func test_successRemoveItem_whenSelectedStoreAndFulfilmentLocationWithoutBasket_setAppStateBasket() async {
        
        let store = RetailStoreDetails.mockedData
        let searchResult = RetailStoresSearch.mockedData
        let basket = Basket.mockedData
        let item = RetailStoreMenuItem.mockedData
        
        let contentId = AppV2Constants.EventsLogging.analyticsItemIdPrefix + "\(item.id)"
        let currencyCode = store.currency.currencyCode
        let isFirstOrder = true
        
        // Configuring app prexisting states
        appState.value.userData.isFirstOrder = isFirstOrder
        appState.value.userData.selectedStore = .loaded(store)
        appState.value.userData.searchResult = .loaded(searchResult)
        
        mockedWebRepo.actions = .init(expected: [
            .getBasket(
                basketToken: nil,
                storeId: store.id,
                fulfilmentMethod: appState.value.userData.selectedFulfilmentMethod,
                fulfilmentLocation: searchResult.fulfilmentLocation,
                isFirstOrder: isFirstOrder
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
        
        var appsFlyerEventParameters: [String: Any] = [
            AFEventParamPrice:          0.0,
            AFEventParamContentId:      item.id,
            AFEventParamContentType:    item.mainCategory.name,
            AFEventParamCurrency:       currencyCode,
            AFEventParamQuantity:       0,
            "product_name":             item.name
        ]
        if let eposCode = basket.items.first!.menuItem.eposCode {
            appsFlyerEventParameters[AFEventParamContent] = eposCode
        }
        
        let facebookParams: [AppEvents.ParameterName: Any] = [
            .description: item.name,
            .contentID: contentId,
            .contentType: "product",
            .numItems: -1,
            .currency: currencyCode
        ]
        let facebookEventParameters: [String: Any] = [
            "valueToSum":-10.0,
            "facebookParams": facebookParams
        ]
        
        let removedItem: [String: Any] = [
            AnalyticsParameterItemID: contentId,
            AnalyticsParameterQuantity: 1,
            AnalyticsParameterPrice: NSDecimalNumber(value: item.price.price).rounding(accordingToBehavior: EventLogger.decimalBehavior).doubleValue
        ]
        let firebaseEventParams: [String: Any] = [
            AnalyticsParameterCurrency: currencyCode,
            AnalyticsParameterItems: [removedItem],
            AnalyticsParameterValue: NSDecimalNumber(value: item.price.price * Double(1)).rounding(accordingToBehavior: EventLogger.decimalBehavior).doubleValue
        ]
        
        mockedEventLogger.actions = .init(expected: [
            .sendEvent(for: .removeFromBasket, with: .appsFlyer, params: appsFlyerEventParameters),
            .sendEvent(for: .removeFromBasket, with: .facebook, params: facebookEventParameters),
            .sendEvent(for: .removeFromBasket, with: .firebaseAnalytics, params: firebaseEventParams)
        ])
        
        // Configuring responses from repositories
        mockedWebRepo.getBasketResponse = .success(basket)
        mockedWebRepo.removeItemResponse = .success(basket)
        mockedDBRepo.clearBasketResult = .success(true)
        mockedDBRepo.storeBasketResult = .success(basket)
        
        do {
            try await sut.removeItem(basketLineId: basket.items[0].basketLineId, item: item)
            
            XCTAssertEqual(sut.appState.value.userData.basket, basket, file: #file, line: #line)
        } catch {
            XCTFail("Unexpected error: \(error)", file: #file, line: #line)
        }
        
        self.mockedWebRepo.verify()
        self.mockedDBRepo.verify()
        self.mockedEventLogger.verify()
    }
    
    func test_successRemoveItem_whenSelectedStoreAndFulfilmentLocationWithBasket_setAppStateBasket() async {
        
        let store = RetailStoreDetails.mockedData
        let searchResult = RetailStoresSearch.mockedData
        let basket = Basket.mockedData
        let item = RetailStoreMenuItem.mockedData
        
        let contentId = AppV2Constants.EventsLogging.analyticsItemIdPrefix + "\(item.id)"
        let currencyCode = store.currency.currencyCode
        
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
        
        var appsFlyerEventParameters: [String: Any] = [
            AFEventParamPrice:          0.0,
            AFEventParamContentId:      item.id,
            AFEventParamContentType:    item.mainCategory.name,
            AFEventParamCurrency:       currencyCode,
            AFEventParamQuantity:       0,
            "product_name":             item.name
        ]
        if let eposCode = basket.items.first!.menuItem.eposCode {
            appsFlyerEventParameters[AFEventParamContent] = eposCode
        }
        
        let facebookParams: [AppEvents.ParameterName: Any] = [
            .description: item.name,
            .contentID: contentId,
            .contentType: "product",
            .numItems: -1,
            .currency: appState.value.userData.selectedStore.value?.currency.currencyCode ?? AppV2Constants.Business.currencyCode
        ]
        let firebaseEventParameters: [String: Any] = [
            "valueToSum":-10.0,
            "facebookParams": facebookParams
        ]
        
        let removedItem: [String: Any] = [
            AnalyticsParameterItemID: contentId,
            AnalyticsParameterQuantity: 1,
            AnalyticsParameterPrice: NSDecimalNumber(value: item.price.price).rounding(accordingToBehavior: EventLogger.decimalBehavior).doubleValue
        ]
        let firebaseEventParams: [String: Any] = [
            AnalyticsParameterCurrency: currencyCode,
            AnalyticsParameterItems: [removedItem],
            AnalyticsParameterValue: NSDecimalNumber(value: item.price.price * Double(1)).rounding(accordingToBehavior: EventLogger.decimalBehavior).doubleValue
        ]
        
        mockedEventLogger.actions = .init(expected: [
            .sendEvent(for: .removeFromBasket, with: .appsFlyer, params: appsFlyerEventParameters),
            .sendEvent(for: .removeFromBasket, with: .facebook, params: firebaseEventParameters),
            .sendEvent(for: .removeFromBasket, with: .firebaseAnalytics, params: firebaseEventParams)
        ])
        
        // Configuring responses from repositories
        mockedWebRepo.removeItemResponse = .success(basket)
        mockedDBRepo.clearBasketResult = .success(true)
        mockedDBRepo.storeBasketResult = .success(basket)
        
        do {
            try await sut.removeItem(basketLineId: basket.items[0].basketLineId, item: item)
            
            XCTAssertEqual(sut.appState.value.userData.basket, basket, file: #file, line: #line)
        } catch {
            XCTFail("Unexpected error: \(error)", file: #file, line: #line)
        }
        
        self.mockedWebRepo.verify()
        self.mockedDBRepo.verify()
        self.mockedEventLogger.verify()
    }
}

// MARK: - func applyCoupon(code:)
final class ApplyCouponTests: BasketServiceTests {
    
    func test_unsuccessApplyCoupon_whenNoStoreSelected_returnError() async {
        
        do {
            try await sut.applyCoupon(code: "COUPONCODE")
            
            XCTFail("Unexpected success", file: #file, line: #line)
        } catch {
            if let basketError = error as? BasketServiceError {
                XCTAssertEqual(basketError, BasketServiceError.storeSelectionRequired, file: #file, line: #line)
            } else {
                XCTFail("Unexpected error type: \(error)", file: #file, line: #line)
            }
        }
        
        self.mockedWebRepo.verify()
        self.mockedDBRepo.verify()
    }
    
    func test_unsuccessApplyCoupon_whenStoreSelectedButNoFulfilmentLocation_returnError() async {
        
        let store = RetailStoreDetails.mockedData
        
        // Configuring app prexisting states
        appState.value.userData.selectedStore = .loaded(store)
        
        do {
            try await sut.applyCoupon(code: "COUPONCODE")
            
            XCTFail("Unexpected success", file: #file, line: #line)
        } catch {
            if let basketError = error as? BasketServiceError {
                XCTAssertEqual(basketError, BasketServiceError.fulfilmentLocationRequired, file: #file, line: #line)
            } else {
                XCTFail("Unexpected error type: \(error)", file: #file, line: #line)
            }
        }
        
        self.mockedWebRepo.verify()
        self.mockedDBRepo.verify()
    }
    
    func test_successApplyCoupon_whenSelectedStoreAndFulfilmentLocationWithoutBasketIsFirstOrder_setAppStateBasket() async {
        
        let store = RetailStoreDetails.mockedData
        let searchResult = RetailStoresSearch.mockedData
        let basket = Basket.mockedData
        let isFirstOrder = true
        
        // Configuring app prexisting states
        appState.value.userData.isFirstOrder = isFirstOrder
        appState.value.userData.selectedStore = .loaded(store)
        appState.value.userData.searchResult = .loaded(searchResult)
        
        mockedWebRepo.actions = .init(expected: [
            .getBasket(
                basketToken: nil,
                storeId: store.id,
                fulfilmentMethod: appState.value.userData.selectedFulfilmentMethod,
                fulfilmentLocation: searchResult.fulfilmentLocation,
                isFirstOrder: isFirstOrder
            ),
            .applyCoupon(
                basketToken: basket.basketToken,
                code: "COUPONCODE",
                isFirstOrder: isFirstOrder
            )
        ])
        mockedDBRepo.actions = .init(expected: [
            .clearBasket,
            .store(basket: basket),
            .clearBasket,
            .store(basket: basket)
        ])
        
        // Configuring expected events
        let params: [String: Any] = [
            "coupon_code": basket.coupon?.code ?? "",
            "coupon_name":basket.coupon?.name ?? "",
            "coupon_discount_applied": basket.coupon?.deductCost ?? 0,
            "coupon_type": basket.coupon?.type ?? "",
            "coupon_value": basket.coupon?.value ?? 0,
            "coupon_free_delivery": basket.coupon?.freeDelivery ?? false,
            "campaign_id": basket.coupon?.iterableCampaignId ?? 1
        ]
        mockedEventLogger.actions = .init(expected: [
            .sendEvent(
                for: .applyCoupon,
                with: .appsFlyer,
                params: params
            )
        ])
        
        // Configuring responses from repositories
        mockedWebRepo.getBasketResponse = .success(basket)
        mockedWebRepo.applyCouponResponse = .success(basket)
        mockedDBRepo.clearBasketResult = .success(true)
        mockedDBRepo.storeBasketResult = .success(basket)
        
        do {
            try await sut.applyCoupon(code: "COUPONCODE")
            
            XCTAssertEqual(sut.appState.value.userData.basket, basket, file: #file, line: #line)
        } catch {
            XCTFail("Unexpected error: \(error)", file: #file, line: #line)
        }
        
        self.mockedWebRepo.verify()
        self.mockedDBRepo.verify()
        self.mockedEventLogger.verify()
    }
    
    func test_successApplyCoupon_whenSelectedStoreAndFulfilmentLocationWithoutBasketAndIsNotFirstOrder_setAppStateBasket() async {
        
        let store = RetailStoreDetails.mockedData
        let searchResult = RetailStoresSearch.mockedData
        let basket = Basket.mockedData
        let isFirstOrder = false
        
        // Configuring app prexisting states
        appState.value.userData.isFirstOrder = isFirstOrder
        appState.value.userData.selectedStore = .loaded(store)
        appState.value.userData.searchResult = .loaded(searchResult)
        
        mockedWebRepo.actions = .init(expected: [
            .getBasket(
                basketToken: nil,
                storeId: store.id,
                fulfilmentMethod: appState.value.userData.selectedFulfilmentMethod,
                fulfilmentLocation: searchResult.fulfilmentLocation,
                isFirstOrder: isFirstOrder
            ),
            .applyCoupon(
                basketToken: basket.basketToken,
                code: "COUPONCODE",
                isFirstOrder: isFirstOrder
            )
        ])
        mockedDBRepo.actions = .init(expected: [
            .clearBasket,
            .store(basket: basket),
            .clearBasket,
            .store(basket: basket)
        ])
        
        // Configuring expected events
        let params: [String: Any] = [
            "coupon_code": basket.coupon?.code ?? "",
            "coupon_name":basket.coupon?.name ?? "",
            "coupon_discount_applied": basket.coupon?.deductCost ?? 0,
            "coupon_type": basket.coupon?.type ?? "",
            "coupon_value": basket.coupon?.value ?? 0,
            "coupon_free_delivery": basket.coupon?.freeDelivery ?? false,
            "campaign_id": basket.coupon?.iterableCampaignId ?? 1
        ]
        mockedEventLogger.actions = .init(expected: [
            .sendEvent(
                for: .applyCoupon,
                with: .appsFlyer,
                params: params
            )
        ])
        
        // Configuring responses from repositories
        mockedWebRepo.getBasketResponse = .success(basket)
        mockedWebRepo.applyCouponResponse = .success(basket)
        mockedDBRepo.clearBasketResult = .success(true)
        mockedDBRepo.storeBasketResult = .success(basket)
        
        do {
            try await sut.applyCoupon(code: "COUPONCODE")
            
            XCTAssertEqual(sut.appState.value.userData.basket, basket, file: #file, line: #line)
        } catch {
            XCTFail("Unexpected error: \(error)", file: #file, line: #line)
        }
        
        self.mockedWebRepo.verify()
        self.mockedDBRepo.verify()
        self.mockedEventLogger.verify()
    }
    
    func test_successApplyCoupon_whenSelectedStoreAndFulfilmentLocationWithBasket_setAppStateBasket() async {
        
        let store = RetailStoreDetails.mockedData
        let searchResult = RetailStoresSearch.mockedData
        let basket = Basket.mockedData
        let isFirstOrder = true
        
        // Configuring app prexisting states
        appState.value.userData.isFirstOrder = isFirstOrder
        appState.value.userData.selectedStore = .loaded(store)
        appState.value.userData.searchResult = .loaded(searchResult)
        appState.value.userData.basket = basket
        
        mockedWebRepo.actions = .init(expected: [
            .applyCoupon(
                basketToken: basket.basketToken,
                code: "COUPONCODE",
                isFirstOrder: isFirstOrder
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
        
        do {
            try await sut.applyCoupon(code: "COUPONCODE")
            
            XCTAssertEqual(sut.appState.value.userData.basket, basket, file: #file, line: #line)
        } catch {
            XCTFail("Unexpected error: \(error)", file: #file, line: #line)
        }
        
        self.mockedWebRepo.verify()
        self.mockedDBRepo.verify()
    }
}

// MARK: - func removeCoupon()
final class RemoveCouponTests: BasketServiceTests {
    
    func test_unsuccessRemoveCoupon_whenNoStoreSelected_returnError() async {
        
        do {
            try await sut.removeCoupon()
            
            XCTFail("Unexpected success", file: #file, line: #line)
        } catch {
            if let basketError = error as? BasketServiceError {
                XCTAssertEqual(basketError, BasketServiceError.storeSelectionRequired, file: #file, line: #line)
            } else {
                XCTFail("Unexpected error type: \(error)", file: #file, line: #line)
            }
        }
        
        self.mockedWebRepo.verify()
        self.mockedDBRepo.verify()
    }
    
    func test_unsuccessRemoveCoupon_whenStoreSelectedButNoFulfilmentLocation_returnError() async {
        
        let store = RetailStoreDetails.mockedData
        
        // Configuring app prexisting states
        appState.value.userData.selectedStore = .loaded(store)
        
        do {
            try await sut.removeCoupon()
            
            XCTFail("Unexpected success", file: #file, line: #line)
        } catch {
            if let basketError = error as? BasketServiceError {
                XCTAssertEqual(basketError, BasketServiceError.fulfilmentLocationRequired, file: #file, line: #line)
            } else {
                XCTFail("Unexpected error type: \(error)", file: #file, line: #line)
            }
        }
        
        self.mockedWebRepo.verify()
        self.mockedDBRepo.verify()
    }
    
    func test_successRemoveCoupon_whenSelectedStoreAndFulfilmentLocationWithoutBasket_setAppStateBasket() async {
        
        let store = RetailStoreDetails.mockedData
        let searchResult = RetailStoresSearch.mockedData
        let basket = Basket.mockedData
        let isFirstOrder = true
        
        // Configuring app prexisting states
        appState.value.userData.isFirstOrder = isFirstOrder
        appState.value.userData.selectedStore = .loaded(store)
        appState.value.userData.searchResult = .loaded(searchResult)
        
        mockedWebRepo.actions = .init(expected: [
            .getBasket(
                basketToken: nil,
                storeId: store.id,
                fulfilmentMethod: appState.value.userData.selectedFulfilmentMethod,
                fulfilmentLocation: searchResult.fulfilmentLocation,
                isFirstOrder: isFirstOrder
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
        
        do {
            try await sut.removeCoupon()
            
            XCTAssertEqual(sut.appState.value.userData.basket, basket, file: #file, line: #line)
        } catch {
            XCTFail("Unexpected error: \(error)", file: #file, line: #line)
        }
        
        self.mockedWebRepo.verify()
        self.mockedDBRepo.verify()
    }
    
    func test_successRemoveCoupon_whenSelectedStoreAndFulfilmentLocationWithBasket_setAppStateBasket() async {
        
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
        
        do {
            try await sut.removeCoupon()
            
            XCTAssertEqual(sut.appState.value.userData.basket, basket, file: #file, line: #line)
        } catch {
            XCTFail("Unexpected error: \(error)", file: #file, line: #line)
        }
        
        self.mockedWebRepo.verify()
        self.mockedDBRepo.verify()
    }
}

// MARK: - func clearItems()
final class ClearItemsTests: BasketServiceTests {
    
    func test_unsuccessClearItems_whenNoStoreSelected_returnError() async {
        
        do {
            try await sut.clearItems()
            
            XCTFail("Unexpected success", file: #file, line: #line)
        } catch {
            if let basketError = error as? BasketServiceError {
                XCTAssertEqual(basketError, BasketServiceError.storeSelectionRequired, file: #file, line: #line)
            } else {
                XCTFail("Unexpected error type: \(error)", file: #file, line: #line)
            }
        }
        
        self.mockedWebRepo.verify()
        self.mockedDBRepo.verify()
    }
    
    func test_unsuccessClearItems_whenStoreSelectedButNoFulfilmentLocation_returnError() async {
        
        let store = RetailStoreDetails.mockedData
        
        // Configuring app prexisting states
        appState.value.userData.selectedStore = .loaded(store)
        
        do {
            try await sut.clearItems()
            
            XCTFail("Unexpected success", file: #file, line: #line)
        } catch {
            if let basketError = error as? BasketServiceError {
                XCTAssertEqual(basketError, BasketServiceError.fulfilmentLocationRequired, file: #file, line: #line)
            } else {
                XCTFail("Unexpected error type: \(error)", file: #file, line: #line)
            }
        }
        
        self.mockedWebRepo.verify()
        self.mockedDBRepo.verify()
    }
    
    func test_successClearItems_whenSelectedStoreAndFulfilmentLocationWithoutBasket_setAppStateBasket() async {
        
        let store = RetailStoreDetails.mockedData
        let searchResult = RetailStoresSearch.mockedData
        let basket = Basket.mockedData
        let isFirstOrder = true
        
        // Configuring app prexisting states
        appState.value.userData.isFirstOrder = isFirstOrder
        appState.value.userData.selectedStore = .loaded(store)
        appState.value.userData.searchResult = .loaded(searchResult)
        
        mockedWebRepo.actions = .init(expected: [
            .getBasket(
                basketToken: nil,
                storeId: store.id,
                fulfilmentMethod: appState.value.userData.selectedFulfilmentMethod,
                fulfilmentLocation: searchResult.fulfilmentLocation,
                isFirstOrder: isFirstOrder
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
        
        do {
            try await sut.clearItems()
            
            XCTAssertEqual(sut.appState.value.userData.basket, basket, file: #file, line: #line)
        } catch {
            XCTFail("Unexpected error: \(error)", file: #file, line: #line)
        }
        
        self.mockedWebRepo.verify()
        self.mockedDBRepo.verify()
    }
    
    func test_successClearItems_whenSelectedStoreAndFulfilmentLocationWithBasket_setAppStateBasket() async {
        
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
        
        do {
            try await sut.clearItems()
            
            XCTAssertEqual(self.appState.value.userData.basket, basket, file: #file, line: #line)
        } catch {
            XCTFail("Unexpected error: \(error)", file: #file, line: #line)
        }
        
        self.mockedWebRepo.verify()
        self.mockedDBRepo.verify()
    }
}

// MARK: - func setContactDetails(to:)
final class SetContactDetailsTests: BasketServiceTests {
    
    func test_unsuccessfulSetContactDetails_whenNoStoreSelected_returnError() async {
        
        let contactDetails = BasketContactDetailsRequest.mockedData
        
        do {
            try await sut.setContactDetails(to: contactDetails)
            
            XCTFail("Unexpected success", file: #file, line: #line)
        } catch {
            if let basketError = error as? BasketServiceError {
                XCTAssertEqual(basketError, BasketServiceError.storeSelectionRequired, file: #file, line: #line)
            } else {
                XCTFail("Unexpected error type: \(error)", file: #file, line: #line)
            }
        }
        
        self.mockedWebRepo.verify()
        self.mockedDBRepo.verify()
    }
    
    func test_unsuccessfulSetContactDetails_whenStoreSelectedButNoFulfilmentLocation_returnError() async {
        
        let contactDetails = BasketContactDetailsRequest.mockedData
        let store = RetailStoreDetails.mockedData
        
        // Configuring app prexisting states
        appState.value.userData.selectedStore = .loaded(store)
        
        do {
            try await sut.setContactDetails(to: contactDetails)
            
            XCTFail("Unexpected success", file: #file, line: #line)
        } catch {
            if let basketError = error as? BasketServiceError {
                XCTAssertEqual(basketError, BasketServiceError.fulfilmentLocationRequired, file: #file, line: #line)
            } else {
                XCTFail("Unexpected error type: \(error)", file: #file, line: #line)
            }
        }
        
        self.mockedWebRepo.verify()
        self.mockedDBRepo.verify()
    }
    
    func test_successfulSetContactDetails_whenSelectedStoreAndFulfilmentLocationWithoutBasket_setAppStateBasket() async {
        
        let contactDetails = BasketContactDetailsRequest.mockedData
        let store = RetailStoreDetails.mockedData
        let searchResult = RetailStoresSearch.mockedData
        let basket = Basket.mockedData
        let isFirstOrder = true
        
        // Configuring app prexisting states
        appState.value.userData.isFirstOrder = isFirstOrder
        appState.value.userData.selectedStore = .loaded(store)
        appState.value.userData.searchResult = .loaded(searchResult)
        
        mockedWebRepo.actions = .init(expected: [
            .getBasket(
                basketToken: nil,
                storeId: store.id,
                fulfilmentMethod: appState.value.userData.selectedFulfilmentMethod,
                fulfilmentLocation: searchResult.fulfilmentLocation,
                isFirstOrder: isFirstOrder
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
        
        do {
            try await sut.setContactDetails(to: contactDetails)
            
            XCTAssertEqual(sut.appState.value.userData.basket, basket, file: #file, line: #line)
        } catch {
            XCTFail("Unexpected error: \(error)", file: #file, line: #line)
        }
        
        self.mockedWebRepo.verify()
        self.mockedDBRepo.verify()
    }
    
    func test_successfulSetContactDetails_whenSelectedStoreAndFulfilmentLocationWithBasket_setAppStateBasket() async {
        
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
        
        do {
            try await sut.setContactDetails(to: contactDetails)
            
            XCTAssertEqual(sut.appState.value.userData.basket, basket, file: #file, line: #line)
        } catch {
            XCTFail("Unexpected error: \(error)", file: #file, line: #line)
        }
        
        self.mockedWebRepo.verify()
        self.mockedDBRepo.verify()
    }
}

// MARK: - func setDeliveryAddress(to:)
final class SetDeliveryAddressTests: BasketServiceTests {
    
    func test_unsuccessDeliveryAddress_whenNoStoreSelected_returnError() async {
        
        let deliveryAddress = BasketAddressRequest.mockedDeliveryData
        
        do {
            try await sut.setDeliveryAddress(to: deliveryAddress)
            
            XCTFail("Unexpected success", file: #file, line: #line)
        } catch {
            if let basketError = error as? BasketServiceError {
                XCTAssertEqual(basketError, BasketServiceError.storeSelectionRequired, file: #file, line: #line)
            } else {
                XCTFail("Unexpected error type: \(error)", file: #file, line: #line)
            }
        }
        
        self.mockedWebRepo.verify()
        self.mockedDBRepo.verify()
    }
    
    func test_unsuccessDeliveryAddress_whenStoreSelectedButNoFulfilmentLocation_returnError() async {
        
        let deliveryAddress = BasketAddressRequest.mockedDeliveryData
        let store = RetailStoreDetails.mockedData
        
        // Configuring app prexisting states
        appState.value.userData.selectedStore = .loaded(store)
        
        do {
            try await sut.setDeliveryAddress(to: deliveryAddress)
            
            XCTFail("Unexpected success", file: #file, line: #line)
        } catch {
            if let basketError = error as? BasketServiceError {
                XCTAssertEqual(basketError, BasketServiceError.fulfilmentLocationRequired, file: #file, line: #line)
            } else {
                XCTFail("Unexpected error type: \(error)", file: #file, line: #line)
            }
        }
        
        self.mockedWebRepo.verify()
        self.mockedDBRepo.verify()
    }
    
    func test_successDeliveryAddress_whenSelectedStoreAndFulfilmentLocationWithoutBasket_setAppStateBasket() async {
        
        let deliveryAddress = BasketAddressRequest.mockedDeliveryData
        let store = RetailStoreDetails.mockedData
        let searchResult = RetailStoresSearch.mockedData
        let basket = Basket.mockedData
        let isFirstOrder = true
        
        // Configuring app prexisting states
        appState.value.userData.isFirstOrder = isFirstOrder
        appState.value.userData.selectedStore = .loaded(store)
        appState.value.userData.searchResult = .loaded(searchResult)
        
        mockedWebRepo.actions = .init(expected: [
            .getBasket(
                basketToken: nil,
                storeId: store.id,
                fulfilmentMethod: appState.value.userData.selectedFulfilmentMethod,
                fulfilmentLocation: searchResult.fulfilmentLocation,
                isFirstOrder: isFirstOrder
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
        
        do {
            try await sut.setDeliveryAddress(to: deliveryAddress)
            
            XCTAssertEqual(sut.appState.value.userData.basket, basket, file: #file, line: #line)
        } catch {
            XCTFail("Unexpected error: \(error)", file: #file, line: #line)
        }
        
        self.mockedWebRepo.verify()
        self.mockedDBRepo.verify()
    }
    
    func test_successDeliveryAddress_whenSelectedStoreAndFulfilmentLocationWithBasket_setAppStateBasket() async {
        
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
        
        do {
            try await sut.setDeliveryAddress(to: deliveryAddress)
            
            XCTAssertEqual(sut.appState.value.userData.basket, basket, file: #file, line: #line)
        } catch {
            XCTFail("Unexpected error: \(error)", file: #file, line: #line)
        }
        
        self.mockedWebRepo.verify()
        self.mockedDBRepo.verify()
    }
    
    func test_failureDeliveryAddress_whenSelectedStoreAndFulfilmentLocationWithBasket_triggerEventAndThrowError() async {
        
        let cannotDeliverToAddressAPIError = APIErrorResult(errorCode: 400, errorText: "Can not deliver to this address", errorDisplay: "Can not deliver to this address")
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
        mockedEventLogger.actions = .init(expected: [
            .sendEvent(for: .cannotDeliverToAddress, with: .firebaseAnalytics, params: [:])
        ])
        
        // Configuring responses from repositories
        mockedWebRepo.setDeliveryAddressResponse = .failure(cannotDeliverToAddressAPIError)
        
        do {
            try await sut.setDeliveryAddress(to: deliveryAddress)
            XCTFail("Unexpected success", file: #file, line: #line)
        } catch {
            if let error = error as? APIErrorResult {
                XCTAssertEqual(error, cannotDeliverToAddressAPIError, file: #file, line: #line)
            } else {
                XCTFail("Unexpected error type: \(error)", file: #file, line: #line)
            }
        }
        
        mockedWebRepo.verify()
        mockedDBRepo.verify()
        mockedEventLogger.verify()
    }
}

// MARK: - func setBillingAddress(to:)
final class SetBillingAddressTests: BasketServiceTests {
    
    func test_unsuccessBillingAddress_whenNoStoreSelected_returnError() async {
        
        let billingAddress = BasketAddressRequest.mockedBillingData
        
        do {
            try await sut.setBillingAddress(to: billingAddress)
            
            XCTFail("Unexpected success", file: #file, line: #line)
        } catch {
            if let basketError = error as? BasketServiceError {
                XCTAssertEqual(basketError, BasketServiceError.storeSelectionRequired, file: #file, line: #line)
            } else {
                XCTFail("Unexpected error type: \(error)", file: #file, line: #line)
            }
        }
        
        self.mockedWebRepo.verify()
        self.mockedDBRepo.verify()
        self.mockedEventLogger.verify()
    }
    
    func test_unsuccessBillingAddress_whenStoreSelectedButNoFulfilmentLocation_returnError() async {
        
        let billingAddress = BasketAddressRequest.mockedBillingData
        let store = RetailStoreDetails.mockedData
        
        // Configuring app prexisting states
        appState.value.userData.selectedStore = .loaded(store)
        
        do {
            try await sut.setBillingAddress(to: billingAddress)
            
            XCTFail("Unexpected success", file: #file, line: #line)
        } catch {
            if let basketError = error as? BasketServiceError {
                XCTAssertEqual(basketError, BasketServiceError.fulfilmentLocationRequired, file: #file, line: #line)
            } else {
                XCTFail("Unexpected error type: \(error)", file: #file, line: #line)
            }
        }
        
        self.mockedWebRepo.verify()
        self.mockedDBRepo.verify()
        self.mockedEventLogger.verify()
    }
    
    func test_successBillingAddress_whenSelectedStoreAndFulfilmentLocationWithoutBasket_setAppStateBasket() async {
        
        let billingAddress = BasketAddressRequest.mockedBillingData
        let store = RetailStoreDetails.mockedData
        let searchResult = RetailStoresSearch.mockedData
        let basket = Basket.mockedData
        let isFirstOrder = true
        
        // Configuring app prexisting states
        appState.value.userData.isFirstOrder = isFirstOrder
        appState.value.userData.selectedStore = .loaded(store)
        appState.value.userData.searchResult = .loaded(searchResult)
        
        mockedWebRepo.actions = .init(expected: [
            .getBasket(
                basketToken: nil,
                storeId: store.id,
                fulfilmentMethod: appState.value.userData.selectedFulfilmentMethod,
                fulfilmentLocation: searchResult.fulfilmentLocation,
                isFirstOrder: isFirstOrder
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
        mockedEventLogger.actions = .init(expected: [.sendEvent(for: .addBillingInfo, with: .appsFlyer, params: [:])])
        
        // Configuring responses from repositories
        mockedWebRepo.getBasketResponse = .success(basket)
        mockedWebRepo.setBillingAddressResponse = .success(basket)
        mockedDBRepo.clearBasketResult = .success(true)
        mockedDBRepo.storeBasketResult = .success(basket)
        
        do {
            try await sut.setBillingAddress(to: billingAddress)
            
            XCTAssertEqual(self.appState.value.userData.basket, basket, file: #file, line: #line)
        } catch {
            XCTFail("Unexpected error: \(error)", file: #file, line: #line)
        }
        
        self.mockedWebRepo.verify()
        self.mockedDBRepo.verify()
        self.mockedEventLogger.verify()
    }
    
    func test_successBillingAddress_whenSelectedStoreAndFulfilmentLocationWithBasket_setAppStateBasket() async {
        
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
        mockedEventLogger.actions = .init(expected: [.sendEvent(for: .addBillingInfo, with: .appsFlyer, params: [:])])
        
        // Configuring responses from repositories
        mockedWebRepo.setBillingAddressResponse = .success(basket)
        mockedDBRepo.clearBasketResult = .success(true)
        mockedDBRepo.storeBasketResult = .success(basket)
        
        do {
            try await sut.setBillingAddress(to: billingAddress)
            
            XCTAssertEqual(sut.appState.value.userData.basket, basket, file: #file, line: #line)
        } catch {
            XCTFail("Unexpected error: \(error)", file: #file, line: #line)
        }
        
        self.mockedWebRepo.verify()
        self.mockedDBRepo.verify()
        self.mockedEventLogger.verify()
    }
}

// MARK: - func updateTip(to:)
final class UpdateTipTests: BasketServiceTests {
    
    func test_unsuccessUpdateTip_whenNoStoreSelected_returnError() async {
        
        do {
            try await sut.updateTip(to: 1.5)
            
            XCTFail("Unexpected success", file: #file, line: #line)
        } catch {
            if let basketError = error as? BasketServiceError {
                XCTAssertEqual(basketError, BasketServiceError.storeSelectionRequired, file: #file, line: #line)
            } else {
                XCTFail("Unexpected error type: \(error)", file: #file, line: #line)
            }
        }
        
        self.mockedWebRepo.verify()
        self.mockedDBRepo.verify()
    }
    
    func test_unsuccessUpdateTip_whenStoreSelectedButNoFulfilmentLocation_returnError() async {
        
        let store = RetailStoreDetails.mockedData
        
        // Configuring app prexisting states
        appState.value.userData.selectedStore = .loaded(store)
        
        do {
            try await sut.updateTip(to: 1.5)
            
            XCTFail("Unexpected success", file: #file, line: #line)
        } catch {
            if let basketError = error as? BasketServiceError {
                XCTAssertEqual(basketError, BasketServiceError.fulfilmentLocationRequired, file: #file, line: #line)
            } else {
                XCTFail("Unexpected error type: \(error)", file: #file, line: #line)
            }
        }
        
        self.mockedWebRepo.verify()
        self.mockedDBRepo.verify()
    }
    
    func test_successUpdateTip_whenSelectedStoreAndFulfilmentLocationWithoutBasket_setAppStateBasket() async {
        
        let store = RetailStoreDetails.mockedData
        let searchResult = RetailStoresSearch.mockedData
        let basket = Basket.mockedData
        let isFirstOrder = true
        
        // Configuring app prexisting states
        appState.value.userData.isFirstOrder = isFirstOrder
        appState.value.userData.selectedStore = .loaded(store)
        appState.value.userData.searchResult = .loaded(searchResult)
        
        mockedWebRepo.actions = .init(expected: [
            .getBasket(
                basketToken: nil,
                storeId: store.id,
                fulfilmentMethod: appState.value.userData.selectedFulfilmentMethod,
                fulfilmentLocation: searchResult.fulfilmentLocation,
                isFirstOrder: isFirstOrder
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
        
        do {
            try await  sut.updateTip(to: 1.5)
            
            XCTAssertEqual(sut.appState.value.userData.basket, basket, file: #file, line: #line)
        } catch {
            XCTFail("Unexpected error: \(error)", file: #file, line: #line)
        }
        
        self.mockedWebRepo.verify()
        self.mockedDBRepo.verify()
    }
    
    func test_successUpdateTip_whenSelectedStoreAndFulfilmentLocationWithBasket_setAppStateBasket() async {
        
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
        
        do {
            try await sut.updateTip(to: 1.5)
            
            XCTAssertEqual(sut.appState.value.userData.basket, basket, file: #file, line: #line)
        } catch {
            XCTFail("Unexpected error: \(error)", file: #file, line: #line)
        }
        
        self.mockedWebRepo.verify()
        self.mockedDBRepo.verify()
    }
}

// MARK: - func populateRepeatOrder(businessOrderId:)
final class PopulateRepeatOrderTests: BasketServiceTests {
    
    func test_unsuccessPopulateRepeatOrder_whenNoStoreSelected_returnError() async {
        
        do {
            try await sut.populateRepeatOrder(businessOrderId: 1670)
            
            XCTFail("Unexpected success", file: #file, line: #line)
        } catch {
            if let basketError = error as? BasketServiceError {
                XCTAssertEqual(basketError, BasketServiceError.storeSelectionRequired, file: #file, line: #line)
            } else {
                XCTFail("Unexpected error type: \(error)", file: #file, line: #line)
            }
        }
        
        self.mockedWebRepo.verify()
        self.mockedDBRepo.verify()
    }
    
    func test_unsuccessPopulateRepeatOrder_whenStoreSelectedButNoFulfilmentLocation_returnError() async {
        
        let store = RetailStoreDetails.mockedData
        
        // Configuring app prexisting states
        appState.value.userData.selectedStore = .loaded(store)
        
        do {
            try await sut.populateRepeatOrder(businessOrderId: 1670)
            
            XCTFail("Unexpected success", file: #file, line: #line)
        } catch {
            if let basketError = error as? BasketServiceError {
                XCTAssertEqual(basketError, BasketServiceError.fulfilmentLocationRequired, file: #file, line: #line)
            } else {
                XCTFail("Unexpected error type: \(error)", file: #file, line: #line)
            }
        }
        
        self.mockedWebRepo.verify()
        self.mockedDBRepo.verify()
    }
    
    func test_unsuccessPopulateRepeatOrder_whenMemberNotSignIn_returnError() async {
        
        let store = RetailStoreDetails.mockedData
        let searchResult = RetailStoresSearch.mockedData
        let basket = Basket.mockedData
        let isFirstOrder = true
        
        // Configuring app prexisting states
        appState.value.userData.isFirstOrder = isFirstOrder
        appState.value.userData.selectedStore = .loaded(store)
        appState.value.userData.searchResult = .loaded(searchResult)
        
        mockedWebRepo.actions = .init(expected: [
            .getBasket(
                basketToken: nil,
                storeId: store.id,
                fulfilmentMethod: appState.value.userData.selectedFulfilmentMethod,
                fulfilmentLocation: searchResult.fulfilmentLocation,
                isFirstOrder: isFirstOrder
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
        
        do {
            try await sut.populateRepeatOrder(businessOrderId: 1670)
            
            XCTFail("Unexpected success", file: #file, line: #line)
        } catch {
            if let basketError = error as? BasketServiceError {
                XCTAssertEqual(basketError, BasketServiceError.memberRequiredToBeSignedIn, file: #file, line: #line)
            } else {
                XCTFail("Unexpected error type: \(error)", file: #file, line: #line)
            }
        }
        
        self.mockedWebRepo.verify()
        self.mockedDBRepo.verify()
    }
    
    func test_successPopulateRepeatOrder_withoutBasket_setAppStateBasket() async {
        
        let store = RetailStoreDetails.mockedData
        let searchResult = RetailStoresSearch.mockedData
        let basket = Basket.mockedData
        let member = MemberProfile.mockedData
        let isFirstOrder = true
        
        // Configuring app prexisting states
        appState.value.userData.isFirstOrder = isFirstOrder
        appState.value.userData.selectedStore = .loaded(store)
        appState.value.userData.searchResult = .loaded(searchResult)
        appState.value.userData.memberProfile = member
        
        mockedWebRepo.actions = .init(expected: [
            .getBasket(
                basketToken: nil,
                storeId: store.id,
                fulfilmentMethod: appState.value.userData.selectedFulfilmentMethod,
                fulfilmentLocation: searchResult.fulfilmentLocation,
                isFirstOrder: isFirstOrder
            ),
            .populateRepeatOrder(
                basketToken: basket.basketToken,
                businessOrderId: 910,
                fulfilmentMethod: appState.value.userData.selectedFulfilmentMethod
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
        mockedWebRepo.populateRepeatOrderResponse = .success(basket)
        mockedDBRepo.clearBasketResult = .success(true)
        mockedDBRepo.storeBasketResult = .success(basket)
        
        do {
            try await sut.populateRepeatOrder(businessOrderId: 910)
            
            XCTAssertEqual(sut.appState.value.userData.basket, basket, file: #file, line: #line)
        } catch {
            XCTFail("Unexpected error: \(error)", file: #file, line: #line)
        }
        
        self.mockedWebRepo.verify()
        self.mockedDBRepo.verify()
    }
    
    func test_successPopulateRepeatOrder_withBasket_setAppStateBasket() async {
        
        let store = RetailStoreDetails.mockedData
        let searchResult = RetailStoresSearch.mockedData
        let basket = Basket.mockedData
        let member = MemberProfile.mockedData
        
        // Configuring app prexisting states
        appState.value.userData.selectedStore = .loaded(store)
        appState.value.userData.searchResult = .loaded(searchResult)
        appState.value.userData.basket = basket
        appState.value.userData.memberProfile = member
        
        mockedWebRepo.actions = .init(expected: [
            .populateRepeatOrder(
                basketToken: basket.basketToken,
                businessOrderId: 910,
                fulfilmentMethod: appState.value.userData.selectedFulfilmentMethod
            )
        ])
        mockedDBRepo.actions = .init(expected: [
            .clearBasket,
            .store(basket: basket)
        ])
        
        // Configuring responses from repositories
        mockedWebRepo.getBasketResponse = .success(basket)
        mockedWebRepo.populateRepeatOrderResponse = .success(basket)
        mockedDBRepo.clearBasketResult = .success(true)
        mockedDBRepo.storeBasketResult = .success(basket)
        
        do {
            try await sut.populateRepeatOrder(businessOrderId: 910)
            
            XCTAssertEqual(sut.appState.value.userData.basket, basket, file: #file, line: #line)
        } catch {
            XCTFail("Unexpected error: \(error)", file: #file, line: #line)
        }
        
        self.mockedWebRepo.verify()
        self.mockedDBRepo.verify()
    }
}
