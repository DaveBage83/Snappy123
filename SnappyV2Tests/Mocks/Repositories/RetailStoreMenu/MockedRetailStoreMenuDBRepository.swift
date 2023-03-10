//
//  MockedRetailStoreMenuDBRepository.swift
//  SnappyV2Tests
//
//  Created by Henrik Gustavii on 03/06/2022.
//

import XCTest
import Combine
@testable import SnappyV2

final class MockedRetailStoreMenuDBRepository: Mock, RetailStoreMenuDBRepositoryProtocol {
    enum Action: Equatable {
        case store(fetchResult: RetailStoreMenuFetch, forStoreId: Int, categoryId: Int, fulfilmentMethod: RetailStoreOrderMethodType, fulfilmentDate: String?)
        case store(fetchResult: RetailStoreMenuGlobalSearch, forStoreId: Int, fulfilmentMethod: RetailStoreOrderMethodType, searchTerm: String)
        case store(fetchResult: RetailStoreMenuFetch, forStoreId: Int, menuItemIds: [Int]?, discountId: Int?, discountSectionId: Int?, fulfilmentMethod: RetailStoreOrderMethodType)
        case store(item: RetailStoreMenuItem, for: RetailStoreMenuItemRequest)
        case clearRetailStoreMenuFetch(forStoreId: Int, categoryId: Int, fulfilmentMethod: RetailStoreOrderMethodType, fulfilmentDate: String?)
        case clearGlobalSearch(forStoreId: Int, fulfilmentMethod: RetailStoreOrderMethodType, searchTerm: String)
        case clearRetailStoreMenuItemsFetch(forStoreId: Int, menuItemIds: [Int]?, discountId: Int?, discountSectionId: Int?, fulfilmentMethod: RetailStoreOrderMethodType)
        case clearItem(with: RetailStoreMenuItemRequest)
        case retailStoreMenuFetch(forStoreId: Int, categoryId: Int, fulfilmentMethod: RetailStoreOrderMethodType, fulfilmentDate: String?)
        case retailStoreMenuGlobalSearch(forStoreId: Int, fulfilmentMethod: RetailStoreOrderMethodType, searchTerm: String)
        case retailStoreMenuItemsFetch(forStoreId: Int, menuItemIds: [Int]?, discountId: Int?, discountSectionId: Int?, fulfilmentMethod: RetailStoreOrderMethodType)
        case retailStoreMenuItemFetch(request: RetailStoreMenuItemRequest)
    }
    
    var actions = MockActions<Action>(expected: [])
    
    var storeCategoryResponse: Result<RetailStoreMenuFetch?, Error> = .failure(MockError.valueNotSet)
    var storeSearchResponse: Result<RetailStoreMenuGlobalSearch?, Error> = .failure(MockError.valueNotSet)
    var storeMenuFetchResponse: Result<RetailStoreMenuFetch?, Error> = .failure(MockError.valueNotSet)
    var storeItemFetchResponse: Result<RetailStoreMenuItemFetch?, Error> = .failure(MockError.valueNotSet)
    var clearRetailStoreMenuFetchResponse: Result<Bool, Error> = .failure(MockError.valueNotSet)
    var clearGlobalSearchResponse: Result<Bool, Error> = .failure(MockError.valueNotSet)
    var clearRetailStoreMenuItemsFetchResponse: Result<Bool, Error> = .failure(MockError.valueNotSet)
    var clearRetailStoreMenuItemFetchResponse: Result<Void, Error> = .failure(MockError.valueNotSet)
    var retailStoreMenuFetchResponse: Result<RetailStoreMenuFetch?, Error> = .failure(MockError.valueNotSet)
    var retailStoreMenuGlobalSearchResponse: Result<RetailStoreMenuGlobalSearch?, Error> = .failure(MockError.valueNotSet)
    var retailStoreMenuItemsFetchResponse: Result<RetailStoreMenuFetch?, Error> = .failure(MockError.valueNotSet)
    var retailStoreMenuItemFetchResponse: Result<RetailStoreMenuItemFetch?, Error> = .failure(MockError.valueNotSet)
    
    func store(fetchResult: RetailStoreMenuFetch, forStoreId: Int, categoryId: Int, fulfilmentMethod: RetailStoreOrderMethodType, fulfilmentDate: String?) -> AnyPublisher<RetailStoreMenuFetch?, Error> {
        register(.store(fetchResult: fetchResult, forStoreId: forStoreId, categoryId: categoryId, fulfilmentMethod: fulfilmentMethod, fulfilmentDate: fulfilmentDate))
        return storeCategoryResponse.publish()
    }
    
    func store(fetchResult: RetailStoreMenuGlobalSearch, forStoreId: Int, fulfilmentMethod: RetailStoreOrderMethodType, searchTerm: String, scope: RetailStoreMenuGlobalSearchScope?, itemsPagination: (limit: Int, page: Int)?, categoriesPagination: (limit: Int, page: Int)?) -> AnyPublisher<RetailStoreMenuGlobalSearch?, Error> {
        register(.store(fetchResult: fetchResult, forStoreId: forStoreId, fulfilmentMethod: fulfilmentMethod, searchTerm: searchTerm))
        return storeSearchResponse.publish()
    }
    
    func store(fetchResult: RetailStoreMenuFetch, forStoreId: Int, menuItemIds: [Int]?, discountId: Int?, discountSectionId: Int?, fulfilmentMethod: RetailStoreOrderMethodType) -> AnyPublisher<RetailStoreMenuFetch?, Error> {
        register(.store(fetchResult: fetchResult, forStoreId: forStoreId, menuItemIds: menuItemIds, discountId: discountId, discountSectionId: discountSectionId, fulfilmentMethod: fulfilmentMethod))
        return storeMenuFetchResponse.publish()
    }
    
    func store(item: RetailStoreMenuItem, for request: RetailStoreMenuItemRequest) async throws {
        register(.store(item: item, for: request))
        switch storeItemFetchResponse {
        case let .failure(error):
            throw error
        default:
            break
        }
    }
    
    func clearRetailStoreMenuFetch(forStoreId: Int, categoryId: Int, fulfilmentMethod: RetailStoreOrderMethodType, fulfilmentDate: String?) -> AnyPublisher<Bool, Error> {
        register(.clearRetailStoreMenuFetch(forStoreId: forStoreId, categoryId: categoryId, fulfilmentMethod: fulfilmentMethod, fulfilmentDate: fulfilmentDate))
        return clearRetailStoreMenuFetchResponse.publish()
    }
    
    func clearGlobalSearch(forStoreId: Int, fulfilmentMethod: RetailStoreOrderMethodType, searchTerm: String, scope: RetailStoreMenuGlobalSearchScope?, itemsPagination: (limit: Int, page: Int)?, categoriesPagination: (limit: Int, page: Int)?) -> AnyPublisher<Bool, Error> {
        register(.clearGlobalSearch(forStoreId: forStoreId, fulfilmentMethod: fulfilmentMethod, searchTerm: searchTerm))
        return clearGlobalSearchResponse.publish()
    }
    
    func clearRetailStoreMenuItemsFetch(forStoreId: Int, menuItemIds: [Int]?, discountId: Int?, discountSectionId: Int?, fulfilmentMethod: RetailStoreOrderMethodType) -> AnyPublisher<Bool, Error> {
        register(.clearRetailStoreMenuItemsFetch(forStoreId: forStoreId, menuItemIds: menuItemIds, discountId: discountId, discountSectionId: discountSectionId, fulfilmentMethod: fulfilmentMethod))
        return clearRetailStoreMenuItemsFetchResponse.publish()
    }
    
    func clearItem(with request: RetailStoreMenuItemRequest) async throws {
        register(.clearItem(with: request))
        switch clearRetailStoreMenuItemFetchResponse {
        case let .failure(error):
            throw error
        default:
            break
        }
    }
    
    func retailStoreMenuFetch(forStoreId: Int, categoryId: Int, fulfilmentMethod: RetailStoreOrderMethodType, fulfilmentDate: String?) -> AnyPublisher<RetailStoreMenuFetch?, Error> {
        register(.retailStoreMenuFetch(forStoreId: forStoreId, categoryId: categoryId, fulfilmentMethod: fulfilmentMethod, fulfilmentDate: fulfilmentDate))
        return retailStoreMenuFetchResponse.publish()
    }
    
    func retailStoreMenuGlobalSearch(forStoreId: Int, fulfilmentMethod: RetailStoreOrderMethodType, searchTerm: String, scope: RetailStoreMenuGlobalSearchScope?, itemsPagination: (limit: Int, page: Int)?, categoriesPagination: (limit: Int, page: Int)?) -> AnyPublisher<RetailStoreMenuGlobalSearch?, Error> {
        register(.retailStoreMenuGlobalSearch(forStoreId: forStoreId, fulfilmentMethod: fulfilmentMethod, searchTerm: searchTerm))
        return retailStoreMenuGlobalSearchResponse.publish()
    }
    
    func retailStoreMenuItemsFetch(forStoreId: Int, menuItemIds: [Int]?, discountId: Int?, discountSectionId: Int?, fulfilmentMethod: RetailStoreOrderMethodType) -> AnyPublisher<RetailStoreMenuFetch?, Error> {
        register(.retailStoreMenuItemsFetch(forStoreId: forStoreId, menuItemIds: menuItemIds, discountId: discountId, discountSectionId: discountSectionId, fulfilmentMethod: fulfilmentMethod))
        return retailStoreMenuItemsFetchResponse.publish()
    }
    
    func retailStoreMenuItemFetch(request: RetailStoreMenuItemRequest) async throws -> RetailStoreMenuItemFetch? {
        register(.retailStoreMenuItemFetch(request: request))
        switch retailStoreMenuItemFetchResponse {
        case let .success(result):
            return result
        case let .failure(error):
            throw error
        }
    }
}
