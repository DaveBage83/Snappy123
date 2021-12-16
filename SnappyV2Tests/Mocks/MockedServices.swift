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
    
    func searchRetailStores(location: CLLocationCoordinate2D) {
        //
    }
    
    func getStoreDetails(storeId: Int, postcode: String) {
        register(.getStoreDetails(storeId: storeId, postcode: postcode))
    }
    
    func repeatLastSearch() {
        //
    }
    
    func searchRetailStores(postcode: String) {
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
        case getRootCategories
        case getChildCategoriesAndItems(categoryId: Int)
        case globalSearch(
            searchTerm: String,
            scope: RetailStoreMenuGlobalSearchScope?,
            itemsPagination: (limit: Int, page: Int)?,
            categoriesPagination: (limit: Int, page: Int)?
        )
        case getItems(menuItemIds: [Int]?, discountId: Int?, discountSectionId: Int?)
        
        static func == (lhs: MockedRetailStoreMenuService.Action, rhs: MockedRetailStoreMenuService.Action) -> Bool {
            switch (lhs, rhs) {
            
            case (.getRootCategories, .getRootCategories):
                return true
            
            case let (.getChildCategoriesAndItems(lhsCategoryId), .getChildCategoriesAndItems(rhsCategoryId)):
                return lhsCategoryId == rhsCategoryId
            
            case let (.globalSearch(lhsSearchTerm, lhsScope, lhsItemsPagination, lhsCategoriesPagination), .globalSearch(rhsSearchTerm, rhsScope, rhsItemsPagination, rhsCategoriesPagination)):
                
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
                
                return lhsSearchTerm == rhsSearchTerm && lhsScope == rhsScope && itemsPaginationComparison && categoriesPaginationComparison
                
            case let (.getItems(lhsMenuItemIds, lhsDiscountId, lhsDiscountSectionId), .getItems(rhsMenuItemIds, rhsDiscountId, rhsDiscountSectionId)):
                
                let menuItemIdsComparison: Bool
                if
                    let lhsMenuItemIds = lhsMenuItemIds,
                    let rhsMenuItemIds = rhsMenuItemIds
                {
                    // check the counts before using the more expensive comparison
                    menuItemIdsComparison = lhsMenuItemIds.count == rhsMenuItemIds.count && lhsMenuItemIds == rhsMenuItemIds
                } else {
                    menuItemIdsComparison = lhsMenuItemIds == nil && rhsMenuItemIds == nil
                }
                
                let discountIdComparison: Bool
                if
                    let lhsDiscountId = lhsDiscountId,
                    let rhsDiscountId = rhsDiscountId
                {
                    // check the counts before using the more expensive comparison
                    discountIdComparison = lhsDiscountId == rhsDiscountId
                } else {
                    discountIdComparison = lhsDiscountId == nil && rhsDiscountId == nil
                }
                
                let discountSectionIdComparison: Bool
                if
                    let lhsDiscountSectionId = lhsDiscountSectionId,
                    let rhsDiscountSectionId = rhsDiscountSectionId
                {
                    // check the counts before using the more expensive comparison
                    discountSectionIdComparison = lhsDiscountSectionId == rhsDiscountSectionId
                } else {
                    discountSectionIdComparison = lhsDiscountSectionId == nil && rhsDiscountSectionId == nil
                }
                
                return menuItemIdsComparison && discountIdComparison && discountSectionIdComparison
                
            default:
                return false
            }
        }
    }
    
    let actions: MockActions<Action>
    
    init(expected: [Action]) {
        self.actions = .init(expected: expected)
    }
    
    func getRootCategories(menuFetch: LoadableSubject<RetailStoreMenuFetch>) {
        register(.getRootCategories)
    }
    
    func getChildCategoriesAndItems(menuFetch: LoadableSubject<RetailStoreMenuFetch>, categoryId: Int) {
        register(.getChildCategoriesAndItems(categoryId: categoryId))
    }
    
    func globalSearch(
        searchFetch: LoadableSubject<RetailStoreMenuGlobalSearch>,
        searchTerm: String,
        scope: RetailStoreMenuGlobalSearchScope?,
        itemsPagination: (limit: Int, page: Int)?,
        categoriesPagination: (limit: Int, page: Int)?
    ) {
        register(
            .globalSearch(
                searchTerm: searchTerm,
                scope: scope,
                itemsPagination: itemsPagination,
                categoriesPagination: categoriesPagination
            )
        )
    }
    
    func getItems(menuFetch: LoadableSubject<RetailStoreMenuFetch>, menuItemIds: [Int]?, discountId: Int?, discountSectionId: Int?) {
        register(
            .getItems(menuItemIds: menuItemIds, discountId: discountId, discountSectionId: discountSectionId)
        )
    }
}

struct MockedBasketService: Mock, BasketServiceProtocol {
    
    enum Action: Equatable {
        case addItem(item: BasketItemRequest)
        case updateItem(item: BasketItemRequest, basketLineId: Int)
        case removeItem(basketLineId: Int)
        case reserveTimeSlot(date: String, time: String?)
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
    
    func reserveTimeSlot(timeSlotDate: String, timeSlotTime: String?) -> Future<Bool, Error> {
        register(.reserveTimeSlot(date: timeSlotDate, time: timeSlotTime))
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
