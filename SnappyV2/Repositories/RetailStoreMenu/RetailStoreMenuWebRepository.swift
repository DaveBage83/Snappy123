//
//  RetailStoreMenuWebRepository.swift
//  SnappyV2
//
//  Created by Kevin Palser on 17/10/2021.
//

import Foundation
import Combine
import CoreLocation

// General Note:
// (a) Parameter requirement checking (PRC) could be at higher point in the call chain, e.g. in RetailStoresService
// public or helper methods. We could also try an map it to server responses. In the end we (Henrik|Kevin) decided
// to have it at this web repository level because:
// - parent calling methods might easily omit the checks if their implementation is updated
// - the web repository is nearer to the business logic and PRC is based on this logic
// - the server responses vary and don't always adhere to APIErrorResult structure or http codes

protocol RetailStoreMenuWebRepositoryProtocol: WebRepository {
    func loadRootRetailStoreMenuCategories(storeId: Int, fulfilmentMethod: RetailStoreOrderMethodType) -> AnyPublisher<RetailStoreMenuFetch, Error>
    func loadRetailStoreMenuSubCategoriesAndItems(storeId: Int, categoryId: Int, fulfilmentMethod: RetailStoreOrderMethodType) -> AnyPublisher<RetailStoreMenuFetch, Error>
    func globalSearch(
        storeId: Int,
        fulfilmentMethod: RetailStoreOrderMethodType,
        searchTerm: String,
        scope: RetailStoreMenuGlobalSearchScope?,
        itemsPagination: (limit: Int, page: Int)?,
        categoriesPagination: (limit: Int, page: Int)?
    ) -> AnyPublisher<RetailStoreMenuGlobalSearch, Error>
    func getItems(
        storeId: Int,
        fulfilmentMethod: RetailStoreOrderMethodType,
        menuItemIds: [Int]?,
        discountId: Int?,
        discountSectionId: Int?
    ) -> AnyPublisher<RetailStoreMenuFetch, Error>
}

struct RetailStoreMenuWebRepository: RetailStoreMenuWebRepositoryProtocol {

    let networkHandler: NetworkHandler
    let baseURL: String
    
    init(networkHandler: NetworkHandler, baseURL: String) {
        self.networkHandler = networkHandler
        self.baseURL = baseURL
    }
    
    func loadRootRetailStoreMenuCategories(storeId: Int, fulfilmentMethod: RetailStoreOrderMethodType) -> AnyPublisher<RetailStoreMenuFetch, Error> {
        let parameters: [String: Any] = [
            "businessId": AppV2Constants.Business.id,
            "storeId": storeId,
            "fulfilmentMethod": fulfilmentMethod.rawValue
        ]

        return call(endpoint: API.rootMenu(parameters))
    }
    
    func loadRetailStoreMenuSubCategoriesAndItems(storeId: Int, categoryId: Int, fulfilmentMethod: RetailStoreOrderMethodType) -> AnyPublisher<RetailStoreMenuFetch, Error> {
        let parameters: [String: Any] = [
            "businessId": AppV2Constants.Business.id,
            "storeId": storeId,
            "categoryId": categoryId,
            "fulfilmentMethod": fulfilmentMethod.rawValue
        ]

        return call(endpoint: API.subCategoriesAndItems(parameters))
    }
    
    func globalSearch(
        storeId: Int,
        fulfilmentMethod: RetailStoreOrderMethodType,
        searchTerm: String,
        scope: RetailStoreMenuGlobalSearchScope?,
        itemsPagination: (limit: Int, page: Int)?,
        categoriesPagination: (limit: Int, page: Int)?
    ) -> AnyPublisher<RetailStoreMenuGlobalSearch, Error> {
        // required parameters
        var parameters: [String: Any] = [
            "businessId": AppV2Constants.Business.id,
            "storeId": storeId,
            "fulfilmentMethod": fulfilmentMethod.rawValue,
            "searchTerm": searchTerm
        ]
        // optional paramters
        if let scope = scope {
            parameters["scope"] = scope
        }
        if let itemsPagination = itemsPagination {
            parameters["itemsLimit"] = itemsPagination.limit
            parameters["itemsPage"] = itemsPagination.page
        }
        if let categoriesPagination = categoriesPagination {
            parameters["categoriesLimit"] = categoriesPagination.limit
            parameters["categoryPage"] = categoriesPagination.page
        }
        return call(endpoint: API.globalSearch(parameters))
    }
    
    func getItems(
        storeId: Int,
        fulfilmentMethod: RetailStoreOrderMethodType,
        menuItemIds: [Int]?,
        discountId: Int?,
        discountSectionId: Int?
    ) -> AnyPublisher<RetailStoreMenuFetch, Error> {
        // required parameters
        var parameters: [String: Any] = [
            "businessId": AppV2Constants.Business.id,
            "storeId": storeId,
            "fulfilmentMethod": fulfilmentMethod.rawValue
        ]
        // one of the following paramters is expected
        if let menuItemIds = menuItemIds {
            parameters["menuItemIds"] = menuItemIds
        } else if let discountId = discountId {
            parameters["discountId"] = discountId
        } else if let discountSectionId = discountSectionId {
            parameters["discountSectionId"] = discountSectionId
        }
        return call(endpoint: API.getItems(parameters))
    }
    
}

// MARK: - Endpoints

extension RetailStoreMenuWebRepository {
    enum API {
        case rootMenu([String: Any]?)
        case subCategoriesAndItems([String: Any]?)
        case globalSearch([String: Any]?)
        case getItems([String: Any]?)
    }
}

extension RetailStoreMenuWebRepository.API: APICall {
    var path: String {
        switch self {
        case .rootMenu:
            return AppV2Constants.Client.languageCode + "/categories/list.json"
        case .subCategoriesAndItems:
            return AppV2Constants.Client.languageCode + "/categories/item.json"
        case .globalSearch:
            return AppV2Constants.Client.languageCode + "/search/global.json"
        case .getItems:
            return AppV2Constants.Client.languageCode + "/items/list.json"
        }
    }
    var method: String {
        switch self {
        case .rootMenu, .subCategoriesAndItems, .globalSearch, .getItems:
            return "POST"
        }
    }
    var jsonParameters: [String : Any]? {
        switch self {
        case let .rootMenu(parameters):
            return parameters
        case let .subCategoriesAndItems(parameters):
            return parameters
        case let .globalSearch(parameters):
            return parameters
        case let .getItems(parameters):
            return parameters
        }
    }
}


