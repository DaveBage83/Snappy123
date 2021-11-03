//
//  BasketWebRepository.swift
//  SnappyV2
//
//  Created by Kevin Palser on 31/10/2021.
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

protocol BasketWebRepositoryProtocol: WebRepository {
    func getBasket(basketToken: String?, storeId: Int, fulfilmentMethod: FulfilmentMethod, isFirstOrder: Bool) -> AnyPublisher<Basket, Error>
}

struct BasketWebRepository: BasketWebRepositoryProtocol {

    let networkHandler: NetworkHandler
    let baseURL: String
    
    init(networkHandler: NetworkHandler, baseURL: String) {
        self.networkHandler = networkHandler
        self.baseURL = baseURL
    }
    
    func getBasket(basketToken: String?, storeId: Int, fulfilmentMethod: FulfilmentMethod, isFirstOrder: Bool) -> AnyPublisher<Basket, Error> {
        
        var parameters: [String: Any] = [
            "storeId": storeId,
            "fulfilmentMethod": fulfilmentMethod.rawValue,
            "businessId": AppV2Constants.Business.id,
            "isFirstOrder": isFirstOrder
        ]
        
        if let basketToken = basketToken {
            parameters["basketToken"] = basketToken
        }

        return call(endpoint: API.getBasket(parameters))
    }
    
}

// MARK: - Endpoints

extension BasketWebRepository {
    enum API {
        case getBasket([String: Any]?)
        case addItem([String: Any]?)
        case removeItem([String: Any]?)
    }
}

extension BasketWebRepository.API: APICall {
    var path: String {
        switch self {
        case .getBasket:
            return "en_GB/basket/get.json"
        case .addItem:
            return "en_GB/basket/item/add.json"
        case .removeItem:
            return "en_GB/basket/item/remove.json"
        }
    }
    var method: String {
        switch self {
        case .getBasket, .addItem, .removeItem:
            return "POST"
        }
    }
    var jsonParameters: [String : Any]? {
        switch self {
        case let .getBasket(parameters):
            return parameters
        case let .addItem(parameters):
            return parameters
        case let .removeItem(parameters):
            return parameters
        }
    }
}
