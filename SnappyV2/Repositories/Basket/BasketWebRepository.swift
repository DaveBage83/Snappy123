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
    ) async throws -> Basket
    
    // TODO: need to see if the extra basket generation parameters really are ever required
    // adding items has more parameters because there is the potential to create a new basket which reuires the extra fields
    // func addItem(basketToken: String?, item: BasketItemRequest, storeId: Int, fulfilmentMethod: FulfilmentMethod, isFirstOrder: Bool) -> AnyPublisher<Basket, Error>
    
    func reserveTimeSlot(basketToken: String, storeId: Int, timeSlotDate: String, timeSlotTime: String?, postcode: String,  fulfilmentMethod: RetailStoreOrderMethodType) async throws -> Basket
    func addItem(basketToken: String, item: BasketItemRequest, fulfilmentMethod: RetailStoreOrderMethodType) async throws -> Basket
    func removeItem(basketToken: String, basketLineId: Int) async throws -> Basket
    func updateItem(basketToken: String, basketLineId: Int, item: BasketItemRequest) async throws -> Basket
    func changeItemQuantity(basketToken: String, basketLineId: Int, changeQuantity: Int) async throws -> Basket
    func applyCoupon(basketToken: String, code: String) async throws -> Basket
    func removeCoupon(basketToken: String) async throws -> Basket
    func clearItems(basketToken: String) async throws -> Basket
    func setContactDetails(basketToken: String, details: BasketContactDetailsRequest) async throws -> Basket
    func setBillingAddress(basketToken: String, address: BasketAddressRequest) async throws -> Basket
    func setDeliveryAddress(basketToken: String, address: BasketAddressRequest) async throws -> Basket
    func updateTip(basketToken: String, tip: Double) async throws -> Basket
    func populateRepeatOrder(basketToken: String, businessOrderId: Int, fulfilmentMethod: RetailStoreOrderMethodType) async throws -> Basket
}

struct BasketWebRepository: BasketWebRepositoryProtocol {

    let networkHandler: NetworkHandler
    let baseURL: String
    
    init(networkHandler: NetworkHandler, baseURL: String) {
        self.networkHandler = networkHandler
        self.baseURL = baseURL
    }
    
    func getBasket(basketToken: String?, storeId: Int, fulfilmentMethod: RetailStoreOrderMethodType, fulfilmentLocation: FulfilmentLocation?, isFirstOrder: Bool) async throws -> Basket {
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

        return try await call(endpoint: API.getBasket(parameters)).singleOutput()
    }
    
    func reserveTimeSlot(basketToken: String, storeId: Int, timeSlotDate: String, timeSlotTime: String?, postcode: String, fulfilmentMethod: RetailStoreOrderMethodType) async throws -> Basket {
        
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

        return try await call(endpoint: API.reserveTimeSlot(parameters)).singleOutput()
    }
    
    func addItem(basketToken: String, item: BasketItemRequest, fulfilmentMethod: RetailStoreOrderMethodType) async throws -> Basket {
        let parameters: [String: Any] = [
            "businessId": AppV2Constants.Business.id,
            "basketToken": basketToken,
            "menuItem": item,
            "fulfilmentMethod": fulfilmentMethod.rawValue
        ]

        return try await call(endpoint: API.addItem(parameters)).singleOutput()
    }
    
    func removeItem(basketToken: String, basketLineId: Int) async throws -> Basket {
        let parameters: [String: Any] = [
            "businessId": AppV2Constants.Business.id,
            "basketToken": basketToken,
            "basketLineId": basketLineId
        ]

        return try await call(endpoint: API.removeItem(parameters)).singleOutput()
    }
    
    func updateItem(basketToken: String, basketLineId: Int, item: BasketItemRequest) async throws -> Basket {
        let parameters: [String: Any] = [
            "businessId": AppV2Constants.Business.id,
            "basketToken": basketToken,
            "basketLineId": basketLineId,
            "menuItem": item
        ]

        return try await call(endpoint: API.updateItem(parameters)).singleOutput()
    }
    
    func changeItemQuantity(basketToken: String, basketLineId: Int, changeQuantity: Int) async throws -> Basket {
        let parameters: [String: Any] = [
            "businessId": AppV2Constants.Business.id,
            "basketToken": basketToken,
            "basketLineId": basketLineId,
            "quantity": changeQuantity
        ]

        return try await call(endpoint: API.changeItemQuantity(parameters)).singleOutput()
    }
    
    func applyCoupon(basketToken: String, code: String) async throws -> Basket {
        let parameters: [String: Any] = [
            "businessId": AppV2Constants.Business.id,
            "basketToken": basketToken,
            "coupon": code
        ]

        return try await call(endpoint: API.applyCoupon(parameters)).singleOutput()
    }
    
    func removeCoupon(basketToken: String) async throws -> Basket {
        let parameters: [String: Any] = [
            "businessId": AppV2Constants.Business.id,
            "basketToken": basketToken
        ]

        return try await call(endpoint: API.removeCoupon(parameters)).singleOutput()
    }
    
    func clearItems(basketToken: String) async throws -> Basket {
        let parameters: [String: Any] = [
            "businessId": AppV2Constants.Business.id,
            "basketToken": basketToken
        ]

        return try await call(endpoint: API.clearItems(parameters)).singleOutput()
    }
    
    func setContactDetails(basketToken: String, details: BasketContactDetailsRequest) async throws -> Basket {
        let parameters: [String: Any] = [
            "basketToken": basketToken,
            "firstName": details.firstName,
            "lastName": details.lastName,
            "email": details.email,
            "phoneNumber": details.telephone
        ]

        return try await call(endpoint: API.setContactDetails(parameters)).singleOutput()
    }
    
    func setBillingAddress(basketToken: String, address: BasketAddressRequest) async throws -> Basket {
        let parameters: [String: Any] = [
            "businessId": AppV2Constants.Business.id,
            "basketToken": basketToken,
            "address": address
        ]

        return try await call(endpoint: API.setBillingAddress(parameters)).singleOutput()
    }
    
    func setDeliveryAddress(basketToken: String, address: BasketAddressRequest) async throws -> Basket {
        let parameters: [String: Any] = [
            "businessId": AppV2Constants.Business.id,
            "basketToken": basketToken,
            "address": address
        ]

        return try await call(endpoint: API.setDeliveryAddress(parameters)).singleOutput()
    }
    
    func updateTip(basketToken: String, tip: Double) async throws -> Basket {
        let parameters: [String: Any] = [
            "basketToken": basketToken,
            "tip": tip
        ]

        return try await call(endpoint: API.updateTip(parameters)).singleOutput()
    }
    
    func populateRepeatOrder(basketToken: String, businessOrderId: Int, fulfilmentMethod: RetailStoreOrderMethodType) async throws -> Basket {
        let parameters: [String: Any] = [
            "businessId": AppV2Constants.Business.id,
            "basketToken": basketToken,
            "businessOrderId": businessOrderId,
            "fulfilmentMethod": fulfilmentMethod.rawValue
        ]

        return try await call(endpoint: API.populateRepeatOrder(parameters)).singleOutput()
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
        case changeItemQuantity([String: Any]?)
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
        case .changeItemQuantity:
            return AppV2Constants.Client.languageCode + "/basket/item/change.json"
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
        case .getBasket, .reserveTimeSlot, .addItem, .removeItem, .updateItem, .applyCoupon, .removeCoupon, .clearItems, .setContactDetails, .setBillingAddress, .setDeliveryAddress, .updateTip, .populateRepeatOrder, .changeItemQuantity:
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
        case let .changeItemQuantity(parameters):
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
