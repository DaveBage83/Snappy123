//
//  MockedRetailStoreMenuService.swift
//  SnappyV2Tests
//
//  Created by Kevin Palser on 19/12/2021.
//

import XCTest
@testable import SnappyV2

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
        case getItem(request: RetailStoreMenuItemRequest)
        
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
                
            case let (.getItem(lhsRequest), .getItem(rhsRequest)):
                return lhsRequest == rhsRequest
                
            default:
                return false
            }
        }
    }
    
    let actions: MockActions<Action>
    
    let cancelBag = CancelBag()
    var getChildCategoriesAndItemsResponse: Result<RetailStoreMenuFetch, Error> = .failure(MockError.valueNotSet)
    var globalSearchResponse: Result<RetailStoreMenuGlobalSearch, Error> = .failure(MockError.valueNotSet)
    
    init(expected: [Action]) {
        self.actions = .init(expected: expected)
    }
    
    func getRootCategories(menuFetch: LoadableSubject<RetailStoreMenuFetch>) {
        register(.getRootCategories)
    }
    
    func getChildCategoriesAndItems(menuFetch: LoadableSubject<RetailStoreMenuFetch>, categoryId: Int) {
        register(.getChildCategoriesAndItems(categoryId: categoryId))
        getChildCategoriesAndItemsResponse
            .publish()
            .sinkToLoadable {
                menuFetch.wrappedValue = $0
            }
            .store(in: cancelBag)
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
        globalSearchResponse
            .publish()
            .sinkToLoadable {
                searchFetch.wrappedValue = $0
            }
            .store(in: cancelBag)
    }
    
    func getItems(menuFetch: LoadableSubject<RetailStoreMenuFetch>, menuItemIds: [Int]?, discountId: Int?, discountSectionId: Int?) {
        register(
            .getItems(menuItemIds: menuItemIds, discountId: discountId, discountSectionId: discountSectionId)
        )
    }
    
    func getItem(request: RetailStoreMenuItemRequest) async throws -> RetailStoreMenuItem {
        register(
            .getItem(request: request)
        )
        return RetailStoreMenuItem.mockedData
    }
}
