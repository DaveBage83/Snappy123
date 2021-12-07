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
    func globalSeach(
        storeId: Int,
        fulfilmentMethod: RetailStoreOrderMethodType,
        searchTerm: String,
        scope: RetailStoreMenuGlobalSearchScope?,
        itemsLimit: Int?,
        itemsPage: Int?,
        categoriesLimit: Int?,
        categoryPage: Int?
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
    
    func globalSeach(
        storeId: Int,
        fulfilmentMethod: RetailStoreOrderMethodType,
        searchTerm: String,
        scope: RetailStoreMenuGlobalSearchScope?,
        itemsLimit: Int?,
        itemsPage: Int?,
        categoriesLimit: Int?,
        categoryPage: Int?)
    -> AnyPublisher<RetailStoreMenuFetch, Error> {
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
        if let itemsLimit = itemsLimit {
            parameters["itemsLimit"] = itemsLimit
            if let itemsPage = itemsPage {
                parameters["itemsPage"] = itemsPage
            }
        }
        if let categoriesLimit = categoriesLimit {
            parameters["categoriesLimit"] = categoriesLimit
            if let categoryPage = categoryPage {
                parameters["itemsPage"] = categoryPage
            }
        }
        return call(endpoint: API.globalSearch(parameters))
    }
    
}

// MARK: - Endpoints

extension RetailStoreMenuWebRepository {
    enum API {
        case rootMenu([String: Any]?)
        case subCategoriesAndItems([String: Any]?)
        case globalSearch([String: Any]?)
    }
}

extension RetailStoreMenuWebRepository.API: APICall {
    var path: String {
        switch self {
        case .rootMenu:
            return "en_GB/categories/list.json"
        case .subCategoriesAndItems:
            return "en_GB/categories/item.json"
        case .globalSearch:
            return "en_GB/search/global.json"
        }
    }
    var method: String {
        switch self {
        case .rootMenu, .subCategoriesAndItems, .globalSearch:
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
        }
    }
}


