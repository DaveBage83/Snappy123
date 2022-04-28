//
//  MockedBasketWebRepository.swift
//  SnappyV2Tests
//
//  Created by Kevin Palser on 07/02/2022.
//

import XCTest
import Combine
@testable import SnappyV2

final class MockedBasketWebRepository: TestWebRepository, Mock, BasketWebRepositoryProtocol {

    enum Action: Equatable {
        case getBasket(basketToken: String?, storeId: Int, fulfilmentMethod: RetailStoreOrderMethodType, fulfilmentLocation: FulfilmentLocation?, isFirstOrder: Bool)
        case reserveTimeSlot(basketToken: String, storeId: Int, timeSlotDate: String, timeSlotTime: String?, postcode: String, fulfilmentMethod: RetailStoreOrderMethodType)
        case addItem(basketToken: String, item: BasketItemRequest, fulfilmentMethod: RetailStoreOrderMethodType)
        case removeItem(basketToken: String, basketLineId: Int)
        case updateItem(basketToken: String, basketLineId: Int, item: BasketItemRequest)
        case applyCoupon(basketToken: String, code: String)
        case removeCoupon(basketToken: String)
        case clearItems(basketToken: String)
        case setContactDetails(basketToken: String, details: BasketContactDetailsRequest)
        case setBillingAddress(basketToken: String, address: BasketAddressRequest)
        case setDeliveryAddress(basketToken: String, address: BasketAddressRequest)
        case updateTip(basketToken: String, tip: Double)
        case populateRepeatOrder(basketToken: String, businessOrderId: Int, fulfilmentMethod: RetailStoreOrderMethodType)
    }
    var actions = MockActions<Action>(expected: [])
    
    var getBasketResponse: Result<Basket, Error> = .failure(MockError.valueNotSet)
    var reserveTimeSlotResponse: Result<Basket, Error> = .failure(MockError.valueNotSet)
    var addItemResponse: Result<Basket, Error> = .failure(MockError.valueNotSet)
    var removeItemResponse: Result<Basket, Error> = .failure(MockError.valueNotSet)
    var updateItemResponse: Result<Basket, Error> = .failure(MockError.valueNotSet)
    var applyCouponResponse: Result<Basket, Error> = .failure(MockError.valueNotSet)
    var removeCouponResponse: Result<Basket, Error> = .failure(MockError.valueNotSet)
    var clearItemsResponse: Result<Basket, Error> = .failure(MockError.valueNotSet)
    var setContactDetailsResponse: Result<Basket, Error> = .failure(MockError.valueNotSet)
    var setBillingAddressResponse: Result<Basket, Error> = .failure(MockError.valueNotSet)
    var setDeliveryAddressResponse: Result<Basket, Error> = .failure(MockError.valueNotSet)
    var updateTipResponse: Result<Basket, Error> = .failure(MockError.valueNotSet)
    var populateRepeatOrderResponse: Result<Basket, Error> = .failure(MockError.valueNotSet)

    func getBasket(basketToken: String?, storeId: Int, fulfilmentMethod: RetailStoreOrderMethodType, fulfilmentLocation: FulfilmentLocation?, isFirstOrder: Bool) async throws -> Basket {
        register(.getBasket(basketToken: basketToken, storeId: storeId, fulfilmentMethod: fulfilmentMethod, fulfilmentLocation: fulfilmentLocation, isFirstOrder: isFirstOrder))
        switch getBasketResponse {
        case .success(let result):
            return result
        case let .failure(error):
            throw error
        }
    }
    
    func reserveTimeSlot(basketToken: String, storeId: Int, timeSlotDate: String, timeSlotTime: String?, postcode: String, fulfilmentMethod: RetailStoreOrderMethodType) async throws -> Basket {
        register(.reserveTimeSlot(basketToken: basketToken, storeId: storeId, timeSlotDate: timeSlotDate, timeSlotTime:timeSlotTime, postcode: postcode, fulfilmentMethod: fulfilmentMethod))
        switch reserveTimeSlotResponse {
        case .success(let result):
            return result
        case let .failure(error):
            throw error
        }
    }
    
    func addItem(basketToken: String, item: BasketItemRequest, fulfilmentMethod: RetailStoreOrderMethodType) async throws -> Basket {
        register(.addItem(basketToken: basketToken, item: item, fulfilmentMethod: fulfilmentMethod))
        switch addItemResponse {
        case .success(let result):
            return result
        case let .failure(error):
            throw error
        }
    }
    
    func removeItem(basketToken: String, basketLineId: Int) async throws -> Basket {
        register(.removeItem(basketToken: basketToken, basketLineId: basketLineId))
        switch removeItemResponse {
        case .success(let result):
            return result
        case let .failure(error):
            throw error
        }
    }
    
    func updateItem(basketToken: String, basketLineId: Int, item: BasketItemRequest) async throws -> Basket {
        register(.updateItem(basketToken: basketToken, basketLineId: basketLineId, item: item))
        switch updateItemResponse {
        case .success(let result):
            return result
        case let .failure(error):
            throw error
        }
    }
    
    func applyCoupon(basketToken: String, code: String) async throws -> Basket {
        register(.applyCoupon(basketToken: basketToken, code: code))
        switch applyCouponResponse {
        case .success(let result):
            return result
        case let .failure(error):
            throw error
        }
    }
    
    func removeCoupon(basketToken: String) async throws -> Basket {
        register(.removeCoupon(basketToken: basketToken))
        switch removeCouponResponse {
        case .success(let result):
            return result
        case let .failure(error):
            throw error
        }
    }
    
    func clearItems(basketToken: String) async throws -> Basket {
        register(.clearItems(basketToken: basketToken))
        switch clearItemsResponse {
        case .success(let result):
            return result
        case let .failure(error):
            throw error
        }
    }
    
    func setContactDetails(basketToken: String, details: BasketContactDetailsRequest) async throws -> Basket {
        register(.setContactDetails(basketToken: basketToken, details: details))
        switch setContactDetailsResponse {
        case .success(let result):
            return result
        case let .failure(error):
            throw error
        }
    }
    
    func setBillingAddress(basketToken: String, address: BasketAddressRequest) async throws -> Basket {
        register(.setBillingAddress(basketToken: basketToken, address: address))
        switch setBillingAddressResponse {
        case .success(let result):
            return result
        case let .failure(error):
            throw error
        }
    }
    
    func setDeliveryAddress(basketToken: String, address: BasketAddressRequest) async throws -> Basket {
        register(.setDeliveryAddress(basketToken: basketToken, address: address))
        switch setDeliveryAddressResponse {
        case .success(let result):
            return result
        case let .failure(error):
            throw error
        }
    }
    
    func updateTip(basketToken: String, tip: Double) async throws -> Basket {
        register(.updateTip(basketToken: basketToken, tip: tip))
        switch updateTipResponse {
        case .success(let result):
            return result
        case let .failure(error):
            throw error
        }
    }
    
    func populateRepeatOrder(basketToken: String, businessOrderId: Int, fulfilmentMethod: RetailStoreOrderMethodType) async throws -> Basket {
        register(.populateRepeatOrder(basketToken: basketToken, businessOrderId: businessOrderId, fulfilmentMethod: fulfilmentMethod))
        switch populateRepeatOrderResponse {
        case .success(let result):
            return result
        case let .failure(error):
            throw error
        }
    }

}
