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
    
    // used to fetch or create new baskets and change the fulfilmentMethod
    func getBasket(
        basketToken: String?,
        storeId: Int,
        fulfilmentMethod: RetailStoreOrderMethodType,
        fulfilmentLocation: FulfilmentLocation?,
        isFirstOrder: Bool
    ) -> AnyPublisher<Basket, Error>
    
    // TODO: need to see if the extra basket generation parameters really are ever required
    // adding items has more parameters because there is the potential to create a new basket which reuires the extra fields
    // func addItem(basketToken: String?, item: BasketItemRequest, storeId: Int, fulfilmentMethod: FulfilmentMethod, isFirstOrder: Bool) -> AnyPublisher<Basket, Error>
    
    func reserveTimeSlot(basketToken: String, storeId: Int, timeSlotDate: String, timeSlotTime: String?, postcode: String,  fulfilmentMethod: RetailStoreOrderMethodType) -> AnyPublisher<Basket, Error>
    func addItem(basketToken: String, item: BasketItemRequest, fulfilmentMethod: RetailStoreOrderMethodType) -> AnyPublisher<Basket, Error>
    func removeItem(basketToken: String, basketLineId: Int) -> AnyPublisher<Basket, Error>
    func updateItem(basketToken: String, basketLineId: Int, item: BasketItemRequest) -> AnyPublisher<Basket, Error>
    func applyCoupon(basketToken: String, code: String) -> AnyPublisher<Basket, Error>
    func removeCoupon(basketToken: String) -> AnyPublisher<Basket, Error>
    func clearItems(basketToken: String) -> AnyPublisher<Basket, Error>
    func setContactDetails(basketToken: String, details: BasketContactDetailsRequest) -> AnyPublisher<Basket, Error>
    func setBillingAddress(basketToken: String, address: BasketAddressRequest) -> AnyPublisher<Basket, Error>
    func setDeliveryAddress(basketToken: String, address: BasketAddressRequest) -> AnyPublisher<Basket, Error>
    func updateTip(basketToken: String, tip: Double) -> AnyPublisher<Basket, Error>
    func populateRepeatOrder(basketToken: String, businessOrderId: Int, fulfilmentMethod: RetailStoreOrderMethodType) -> AnyPublisher<Basket, Error>
}

struct BasketWebRepository: BasketWebRepositoryProtocol {

    let networkHandler: NetworkHandler
    let baseURL: String
    
    init(networkHandler: NetworkHandler, baseURL: String) {
        self.networkHandler = networkHandler
        self.baseURL = baseURL
    }
    
    func getBasket(basketToken: String?, storeId: Int, fulfilmentMethod: RetailStoreOrderMethodType, fulfilmentLocation: FulfilmentLocation?, isFirstOrder: Bool) -> AnyPublisher<Basket, Error> {
        var parameters: [String: Any] = [
            "storeId": storeId,
            "fulfilmentMethod": fulfilmentMethod.rawValue,
            "businessId": AppV2Constants.Business.id,
            "isFirstOrder": isFirstOrder
        ]
        
        if let basketToken = basketToken {
            parameters["basketToken"] = basketToken
        }
        
        if let fulfilmentLocation = fulfilmentLocation {
            parameters["fulfilmentLocation"] = fulfilmentLocation
        }

        return call(endpoint: API.getBasket(parameters))
    }
    
    func reserveTimeSlot(basketToken: String, storeId: Int, timeSlotDate: String, timeSlotTime: String?, postcode: String, fulfilmentMethod: RetailStoreOrderMethodType) -> AnyPublisher<Basket, Error> {
        
        var parameters: [String: Any] = [
            "basketToken": basketToken,
            "storeId": storeId,
            "timeSlotDate": timeSlotDate,
            "postcode": postcode,
            "fulfilmentMethod": fulfilmentMethod.rawValue
        ]
        
        if let timeSlotTime = timeSlotTime {
            parameters["timeSlotTime"] = timeSlotTime
        }

        return call(endpoint: API.reserveTimeSlot(parameters))
    }
    
    func addItem(basketToken: String, item: BasketItemRequest, fulfilmentMethod: RetailStoreOrderMethodType) -> AnyPublisher<Basket, Error> {
        let parameters: [String: Any] = [
            "businessId": AppV2Constants.Business.id,
            "basketToken": basketToken,
            "menuItem": item,
            "fulfilmentMethod": fulfilmentMethod.rawValue
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
    
    func updateItem(basketToken: String, basketLineId: Int, item: BasketItemRequest) -> AnyPublisher<Basket, Error> {
        let parameters: [String: Any] = [
            "businessId": AppV2Constants.Business.id,
            "basketToken": basketToken,
            "basketLineId": basketLineId,
            "menuItem": item
        ]

        return call(endpoint: API.updateItem(parameters))
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
    
    func clearItems(basketToken: String) -> AnyPublisher<Basket, Error> {
        let parameters: [String: Any] = [
            "businessId": AppV2Constants.Business.id,
            "basketToken": basketToken
        ]

        return call(endpoint: API.clearItems(parameters))
    }
    
    func setContactDetails(basketToken: String, details: BasketContactDetailsRequest) -> AnyPublisher<Basket, Error> {
        let parameters: [String: Any] = [
            "basketToken": basketToken,
            "firstName": details.firstName,
            "lastName": details.lastName,
            "email": details.email,
            "phoneNumber": details.telephone
        ]

        return call(endpoint: API.setContactDetails(parameters))
    }
    
    func setBillingAddress(basketToken: String, address: BasketAddressRequest) -> AnyPublisher<Basket, Error> {
        let parameters: [String: Any] = [
            "businessId": AppV2Constants.Business.id,
            "basketToken": basketToken,
            "address": address
        ]

        return call(endpoint: API.setBillingAddress(parameters))
    }
    
    func setDeliveryAddress(basketToken: String, address: BasketAddressRequest) -> AnyPublisher<Basket, Error> {
        let parameters: [String: Any] = [
            "businessId": AppV2Constants.Business.id,
            "basketToken": basketToken,
            "address": address
        ]

        return call(endpoint: API.setDeliveryAddress(parameters))
    }
    
    func updateTip(basketToken: String, tip: Double) -> AnyPublisher<Basket, Error> {
        let parameters: [String: Any] = [
            "basketToken": basketToken,
            "tip": tip
        ]

        return call(endpoint: API.updateTip(parameters))
    }
    
    func populateRepeatOrder(basketToken: String, businessOrderId: Int, fulfilmentMethod: RetailStoreOrderMethodType) -> AnyPublisher<Basket, Error> {
        let parameters: [String: Any] = [
            "businessId": AppV2Constants.Business.id,
            "basketToken": basketToken,
            "businessOrderId": businessOrderId,
            "fulfilmentMethod": fulfilmentMethod.rawValue
        ]

        return call(endpoint: API.populateRepeatOrder(parameters))
    }
}

// MARK: - Endpoints

extension BasketWebRepository {
    enum API {
        case getBasket([String: Any]?)
        case reserveTimeSlot([String: Any]?)
        case addItem([String: Any]?)
        case removeItem([String: Any]?)
        case updateItem([String: Any]?)
        case applyCoupon([String: Any]?)
        case removeCoupon([String: Any]?)
        case clearItems([String: Any]?)
        case setContactDetails([String: Any]?)
        case setDeliveryAddress([String: Any]?)
        case setBillingAddress([String: Any]?)
        case updateTip([String: Any]?)
        case populateRepeatOrder([String: Any]?)
    }
}

extension BasketWebRepository.API: APICall {
    var path: String {
        switch self {
        case .getBasket:
            return AppV2Constants.Client.languageCode + "/basket/get.json"
        case .reserveTimeSlot:
            return AppV2Constants.Client.languageCode + "/basket/reserveTimeSlot.json"
        case .addItem:
            return AppV2Constants.Client.languageCode + "/basket/item/add.json"
        case .removeItem:
            return AppV2Constants.Client.languageCode + "/basket/item/remove.json"
        case .updateItem:
            return AppV2Constants.Client.languageCode + "/basket/item/update.json"
        case .applyCoupon:
            return AppV2Constants.Client.languageCode + "/basket/applyCoupon.json"
        case .removeCoupon:
            return AppV2Constants.Client.languageCode + "/basket/removeCoupon.json"
        case .clearItems:
            return AppV2Constants.Client.languageCode + "/basket/clear.json"
        case .setContactDetails:
            return AppV2Constants.Client.languageCode + "/checkout/setContactDetails.json"
        case .setDeliveryAddress:
            return AppV2Constants.Client.languageCode + "/checkout/setDeliveryAddress.json"
        case .setBillingAddress:
            return AppV2Constants.Client.languageCode + "/checkout/setBillingAddress.json"
        case .updateTip:
            return AppV2Constants.Client.languageCode + "/basket/tip/update.json"
        case .populateRepeatOrder:
            return AppV2Constants.Client.languageCode + "/member/reorder.json"
        }
    }
    var method: String {
        switch self {
        case .getBasket, .reserveTimeSlot, .addItem, .removeItem, .updateItem, .applyCoupon, .removeCoupon, .clearItems, .setContactDetails, .setBillingAddress, .setDeliveryAddress, .updateTip, .populateRepeatOrder:
            return "POST"
        }
    }
    var jsonParameters: [String : Any]? {
        switch self {
        case let .getBasket(parameters):
            return parameters
        case let .reserveTimeSlot(parameters):
            return parameters
        case let .addItem(parameters):
            return parameters
        case let .removeItem(parameters):
            return parameters
        case let .updateItem(parameters):
            return parameters
        case let .applyCoupon(parameters):
            return parameters
        case let .removeCoupon(parameters):
            return parameters
        case let .clearItems(parameters):
            return parameters
        case let .setContactDetails(parameters):
            return parameters
        case let .setBillingAddress(parameters):
            return parameters
        case let .setDeliveryAddress(parameters):
            return parameters
        case let .updateTip(parameters):
            return parameters
        case let .populateRepeatOrder(parameters):
            return parameters
        }
    }
}
