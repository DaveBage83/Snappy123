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
        case getRootCategories(storeId: Int)
        case getChildCategoriesAndItems(storeId: Int, categoryId: Int)
        case globalSearch(
            storeId: Int,
            searchTerm: String,
            scope: RetailStoreMenuGlobalSearchScope?,
            itemsPagination: (limit: Int, page: Int)?,
            categoriesPagination: (limit: Int, page: Int)?
        )
        
        static func == (lhs: MockedRetailStoreMenuService.Action, rhs: MockedRetailStoreMenuService.Action) -> Bool {
            switch (lhs, rhs) {
            
            case let (.getRootCategories(lhsStoreId), .getRootCategories(rhsStoreId)):
                return lhsStoreId == rhsStoreId
            
            case let (.getChildCategoriesAndItems(lhsStoreId, lhsCategoryId), .getChildCategoriesAndItems(rhsStoreId, rhsCategoryId)):
                return lhsStoreId == rhsStoreId && lhsCategoryId == rhsCategoryId
            
            case let (.globalSearch(lhsStoreId, lhsSearchTerm, lhsScope, lhsItemsPagination, lhsCategoriesPagination), .globalSearch(rhsStoreId, rhsSearchTerm, rhsScope, rhsItemsPagination, rhsCategoriesPagination)):
                
                let itemsPaginationComparison: Bool
                if
                    let lhsItemsPagination = lhsItemsPagination,
                    let rhsItemsPagination = rhsItemsPagination
                {
                    itemsPaginationComparison = lhsItemsPagination == rhsItemsPagination
                } else {
                    itemsPaginationComparison = lhsItemsPagination == nil && rhsItemsPagination == nil
                }
                
                let categoriesPaginationComparison: Bool
                if
                    let lhsCategoriesPagination = lhsCategoriesPagination,
                    let rhsCategoriesPagination = rhsCategoriesPagination
                {
                    categoriesPaginationComparison = lhsCategoriesPagination == rhsCategoriesPagination
                } else {
                    categoriesPaginationComparison = lhsCategoriesPagination == nil && rhsCategoriesPagination == nil
                }
                
                return lhsStoreId == rhsStoreId && lhsSearchTerm == rhsSearchTerm && lhsScope == rhsScope && itemsPaginationComparison && categoriesPaginationComparison
                
            default:
                return false
            }
        }
    }
    
    let actions: MockActions<Action>
    
    init(expected: [Action]) {
        self.actions = .init(expected: expected)
    }
    
    func getRootCategories(menuFetch: LoadableSubject<RetailStoreMenuFetch>, storeId: Int) {
        register(.getRootCategories(storeId: storeId))
    }
    
    func getChildCategoriesAndItems(menuFetch: LoadableSubject<RetailStoreMenuFetch>, storeId: Int, categoryId: Int) {
        register(.getChildCategoriesAndItems(storeId: storeId, categoryId: categoryId))
    }
    
    func globalSearch(
        searchFetch: LoadableSubject<RetailStoreMenuGlobalSearch>,
        storeId: Int,
        searchTerm: String,
        scope: RetailStoreMenuGlobalSearchScope?,
        itemsPagination: (limit: Int, page: Int)?,
        categoriesPagination: (limit: Int, page: Int)?
    ) {
        register(
            .globalSearch(
                storeId: storeId,
                searchTerm: searchTerm,
                scope: scope,
                itemsPagination: itemsPagination,
                categoriesPagination: categoriesPagination
            )
        )
    }
}

struct MockedBasketService: Mock, BasketServiceProtocol {
    enum Action: Equatable {
        case addItem(item: BasketItemRequest)
        case updateItem(item: BasketItemRequest, basketLineId: Int)
        case removeItem(basketLineId: Int)
    }
    
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
        register(.addItem(item: item))
        return Future { $0(.success(true)) }
    }
    
    func updateItem(item: BasketItemRequest, basketLineId: Int) -> Future<Bool, Error> {
        register(.updateItem(item: item, basketLineId: basketLineId))
        return Future { $0(.success(true)) }
    }
    
    func removeItem(basketLineId: Int) -> Future<Bool, Error> {
        register(.removeItem(basketLineId: basketLineId))
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
