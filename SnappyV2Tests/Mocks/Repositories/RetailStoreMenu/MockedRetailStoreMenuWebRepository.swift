//
//  MockedRetailStoreMenuWebRepository.swift
//  SnappyV2Tests
//
//  Created by Henrik Gustavii on 03/06/2022.
//

import XCTest
import Combine
@testable import SnappyV2

final class MockedRetailStoreMenuWebRepository: TestWebRepository, Mock, RetailStoreMenuWebRepositoryProtocol {
    enum Action: Equatable {
        case loadRootRetailStoreMenuCategories(storeId: Int, fulfilmentMethod: RetailStoreOrderMethodType, fulfilmentDate: String?)
        case loadRetailStoreMenuSubCategoriesAndItems(storeId: Int, categoryId: Int, fulfilmentMethod: RetailStoreOrderMethodType, fulfilmentDate: String?)
        case globalSearch(storeId: Int, fulfilmentMethod: RetailStoreOrderMethodType, searchTerm: String)
        case getItems(storeId: Int, fulfilmentMethod: RetailStoreOrderMethodType, menuItemIds: [Int]?, discountId: Int?, discountSectionId: Int?)
        case getItem(request: RetailStoreMenuItemRequest)
    }
    
    var actions = MockActions<Action>(expected: [])
    
    var loadRootRetailStoreMenuCategoriesResponse: Result<RetailStoreMenuFetch, Error> = .failure(MockError.valueNotSet)
    var loadRetailStoreMenuSubCategoriesAndItemsResponse: Result<RetailStoreMenuFetch, Error> = .failure(MockError.valueNotSet)
    var globalSearchResponse: Result<RetailStoreMenuGlobalSearch, Error> = .failure(MockError.valueNotSet)
    var getItemsResponse: Result<RetailStoreMenuFetch, Error> = .failure(MockError.valueNotSet)
    var getItemResponse: Result<RetailStoreMenuItem, Error> = .failure(MockError.valueNotSet)
    
    func loadRootRetailStoreMenuCategories(storeId: Int, fulfilmentMethod: RetailStoreOrderMethodType, fulfilmentDate: String?) -> AnyPublisher<RetailStoreMenuFetch, Error> {
        register(.loadRootRetailStoreMenuCategories(storeId: storeId, fulfilmentMethod: fulfilmentMethod, fulfilmentDate: fulfilmentDate))
        return loadRootRetailStoreMenuCategoriesResponse.publish()
    }
    
    func loadRetailStoreMenuSubCategoriesAndItems(storeId: Int, categoryId: Int, fulfilmentMethod: RetailStoreOrderMethodType, fulfilmentDate: String?) -> AnyPublisher<RetailStoreMenuFetch, Error> {
        register(.loadRetailStoreMenuSubCategoriesAndItems(storeId: storeId, categoryId: categoryId, fulfilmentMethod: fulfilmentMethod, fulfilmentDate: fulfilmentDate))
        return loadRetailStoreMenuSubCategoriesAndItemsResponse.publish()
    }
    
    func globalSearch(storeId: Int, fulfilmentMethod: RetailStoreOrderMethodType, searchTerm: String, scope: RetailStoreMenuGlobalSearchScope?, itemsPagination: (limit: Int, page: Int)?, categoriesPagination: (limit: Int, page: Int)?) -> AnyPublisher<RetailStoreMenuGlobalSearch, Error> {
        register(.globalSearch(storeId: storeId, fulfilmentMethod: fulfilmentMethod, searchTerm: searchTerm))
        return globalSearchResponse.publish()
    }
    
    func getItems(storeId: Int, fulfilmentMethod: RetailStoreOrderMethodType, menuItemIds: [Int]?, discountId: Int?, discountSectionId: Int?) -> AnyPublisher<RetailStoreMenuFetch, Error> {
        register(.getItems(storeId: storeId, fulfilmentMethod: fulfilmentMethod, menuItemIds: menuItemIds, discountId: discountId, discountSectionId: discountSectionId))
        return getItemsResponse.publish()
    }
    
    func getItem(request: RetailStoreMenuItemRequest) async throws -> RetailStoreMenuItem {
        register(.getItem(request: request))
        switch getItemResponse {
        case let .success(item):
            return item
        case let .failure(error):
            throw error
        }
    }

}
