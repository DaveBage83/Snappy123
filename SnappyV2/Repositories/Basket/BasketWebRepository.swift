//
//  BasketWebRepository.swift
//  SnappyV2
//
//  Created by Kevin Palser on 31/10/2021.
//

import Foundation
import Combine
import CoreLocation

protocol BasketWebRepositoryProtocol: WebRepository {
    
    // used to fetch and also create new baskets
    func getBasket(basketToken: String?, storeId: Int, fulfilmentMethod: FulfilmentMethod, isFirstOrder: Bool) -> AnyPublisher<Basket, Error>
    
    // TODO: need to see if the extra basket generation parameters really are ever required
    // adding items has more parameters because there is the potential to create a new basket which reuires the extra fields
    // func addItem(basketToken: String?, item: BasketItemRequest, storeId: Int, fulfilmentMethod: FulfilmentMethod, isFirstOrder: Bool) -> AnyPublisher<Basket, Error>
    
    func addItem(basketToken: String, item: BasketItemRequest, fulfilmentMethod: FulfilmentMethod) -> AnyPublisher<Basket, Error>
    func removeItem(basketToken: String, basketLineId: Int) -> AnyPublisher<Basket, Error>
    
    func applyCoupon(basketToken: String, code: String) -> AnyPublisher<Basket, Error>
    func removeCoupon(basketToken: String) -> AnyPublisher<Basket, Error>
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
    
    func addItem(basketToken: String, item: BasketItemRequest, fulfilmentMethod: FulfilmentMethod) -> AnyPublisher<Basket, Error> {
        
        let parameters: [String: Any] = [
            "businessId": AppV2Constants.Business.id,
            "basketToken": basketToken,
            "menuItem": item,
            "fulfilmentMethod": fulfilmentMethod.rawValue,
        ]

        return call(endpoint: API.addItem(parameters))
    }
    
    func removeItem(basketToken: String, basketLineId: Int) -> AnyPublisher<Basket, Error> {
        
        let parameters: [String: Any] = [
            "businessId": AppV2Constants.Business.id,
            "basketToken": basketToken,
            "basketLineId": basketLineId
        ]

        return call(endpoint: API.removeItem(parameters))
    }
    
    func applyCoupon(basketToken: String, code: String) -> AnyPublisher<Basket, Error> {
        
        let parameters: [String: Any] = [
            "businessId": AppV2Constants.Business.id,
            "basketToken": basketToken,
            "coupon": code
        ]

        return call(endpoint: API.applyCoupon(parameters))
    }
    
    func removeCoupon(basketToken: String) -> AnyPublisher<Basket, Error> {
        
        let parameters: [String: Any] = [
            "businessId": AppV2Constants.Business.id,
            "basketToken": basketToken
        ]

        return call(endpoint: API.removeCoupon(parameters))
    }
    
}

// MARK: - Endpoints

extension BasketWebRepository {
    enum API {
        case getBasket([String: Any]?)
        case addItem([String: Any]?)
        case removeItem([String: Any]?)
        case applyCoupon([String: Any]?)
        case removeCoupon([String: Any]?)
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
        case .applyCoupon:
            return "en_GB/basket/applyCoupon.json"
        case .removeCoupon:
            return "en_GB/basket/removeCoupon.json"
        }
    }
    var method: String {
        switch self {
        case .getBasket, .addItem, .removeItem, .applyCoupon, .removeCoupon:
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
        case let .applyCoupon(parameters):
            return parameters
        case let .removeCoupon(parameters):
            return parameters
        }
    }
}
