//
//  MockedServices.swift
//  SnappyV2Tests
//
//  Created by Henrik Gustavii on 04/10/2021.
//

import XCTest
import CoreLocation
import Combine
@testable import SnappyV2

extension DIContainer.Services {
    static func mocked(
        retailStoreService: [MockedRetailStoreService.Action] = [],
        retailStoreMenuService: [MockedRetailStoreMenuService.Action] = [],
        basketService: [MockedBasketService.Action] = []) -> DIContainer.Services {
        .init(
            retailStoreService: MockedRetailStoreService(expected: retailStoreService),
            retailStoreMenuService: MockedRetailStoreMenuService(expected: retailStoreMenuService),
            basketService: MockedBasketService(expected: basketService)
        )
    }
    
    func verify(file: StaticString = #file, line: UInt = #line) {
        (retailStoresService as? MockedRetailStoreService)?
            .verify(file: file, line: line)
        (retailStoreMenuService as? MockedRetailStoreMenuService)?
            .verify(file: file, line: line)
        (basketService as? MockedBasketService)?
            .verify(file: file, line: line)
    }
}

struct MockedRetailStoreService: Mock, RetailStoresServiceProtocol {
    
    enum Action: Equatable {
        case repeatLastSearch(search: RetailStoresSearch)
        case searchRetailStores(postcode: String)
        case searchRetailStores(location: CLLocationCoordinate2D)
        case getStoreDetails(storeId: Int, postcode: String)
        case getStoreDeliveryTimeSlots(storeId: Int, startDate: Date, endDate: Date, location: CLLocationCoordinate2D)
        case getStoreCollectionTimeSlots(storeId: Int, startDate: Date, endDate: Date)
    }
    
    let actions: MockActions<Action>
    
    init(expected: [Action]) {
        self.actions = .init(expected: expected)
    }
    
    func searchRetailStores(search: LoadableSubject<RetailStoresSearch>, location: CLLocationCoordinate2D) {
        //
    }
    
    func getStoreDetails(details: LoadableSubject<RetailStoreDetails>, storeId: Int, postcode: String) {
        register(.getStoreDetails(storeId: storeId, postcode: postcode))
    }
    
    func repeatLastSearch(search: LoadableSubject<RetailStoresSearch>) {
        //
    }
    
    func searchRetailStores(search: LoadableSubject<RetailStoresSearch>, postcode: String) {
        register(.searchRetailStores(postcode: postcode))
    }
    
    
    func getStoreDeliveryTimeSlots(slots: LoadableSubject<RetailStoreTimeSlots>, storeId: Int, startDate: Date, endDate: Date, location: CLLocationCoordinate2D) {
        register(.getStoreDeliveryTimeSlots(storeId: storeId, startDate: startDate, endDate: endDate, location: location))
    }
    
    func getStoreCollectionTimeSlots(slots: LoadableSubject<RetailStoreTimeSlots>, storeId: Int, startDate: Date, endDate: Date) {
        
    }
}

struct MockedRetailStoreMenuService: Mock, RetailStoreMenuServiceProtocol {

    enum Action: Equatable {
        case getRootCategories(storeId: Int, fulfilmentMethod: RetailStoreOrderMethodType)
        case searchRetailStores(storeId: Int, categoryId: Int, fulfilmentMethod: RetailStoreOrderMethodType)
    }
    
    let actions: MockActions<Action>
    
    init(expected: [Action]) {
        self.actions = .init(expected: expected)
    }
    
    func getRootCategories(menuFetch: LoadableSubject<RetailStoreMenuFetch>, storeId: Int) {
        func getStoreDeliveryTimeSlots(slots: LoadableSubject<RetailStoreTimeSlots>, storeId: Int, startDate: Date, endDate: Date, location: CLLocationCoordinate2D) {
            
        }
        
        func getStoreCollectionTimeSlots(slots: LoadableSubject<RetailStoreTimeSlots>, storeId: Int, startDate: Date, endDate: Date) {
            
        }
        //
    }
    
    func getChildCategoriesAndItems(menuFetch: LoadableSubject<RetailStoreMenuFetch>, storeId: Int, categoryId: Int) {
        //
    }
}

struct MockedBasketService: Mock, BasketServiceProtocol {

    enum Action: Equatable {}
    
    let actions: MockActions<Action>
    
    init(expected: [Action]) {
        self.actions = .init(expected: expected)
    }
    
    func restoreBasket() -> Future<Bool, Error> {
        return Future { $0(.success(true)) }
    }
    
    func updateFulfilmentMethodAndStore() -> Future<Bool, Error> {
        return Future { $0(.success(true)) }
    }
    
    func addItem(item: BasketItemRequest) -> Future<Bool, Error> {
        return Future { $0(.success(true)) }
    }
    
    func updateItem(item: BasketItemRequest, basketLineId: Int) -> Future<Bool, Error> {
        return Future { $0(.success(true)) }
    }
    
    func removeItem(basketLineId: Int) -> Future<Bool, Error> {
        return Future { $0(.success(true)) }
    }
    
    func applyCoupon(code: String) -> Future<Bool, Error> {
        return Future { $0(.success(true)) }
    }
    
    func removeCoupon() -> Future<Bool, Error> {
        return Future { $0(.success(true)) }
    }
    
    func clearItems() -> Future<Bool, Error> {
        return Future { $0(.success(true)) }
    }
    
    func getNewBasket() -> Future<Bool, Error> {
        return Future { $0(.success(true)) }
    }
    
    func test(delay: TimeInterval) -> Future<Bool, Error> {
        return Future { $0(.success(true)) }
    }
    
}
