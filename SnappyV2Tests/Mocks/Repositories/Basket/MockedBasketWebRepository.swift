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

    func getBasket(basketToken: String?, storeId: Int, fulfilmentMethod: RetailStoreOrderMethodType, fulfilmentLocation: FulfilmentLocation?, isFirstOrder: Bool) -> AnyPublisher<Basket, Error> {
        register(.getBasket(basketToken: basketToken, storeId: storeId, fulfilmentMethod: fulfilmentMethod, fulfilmentLocation: fulfilmentLocation, isFirstOrder: isFirstOrder))
        return getBasketResponse.publish()
    }
    
    func reserveTimeSlot(basketToken: String, storeId: Int, timeSlotDate: String, timeSlotTime: String?, postcode: String, fulfilmentMethod: RetailStoreOrderMethodType) -> AnyPublisher<Basket, Error> {
        register(.reserveTimeSlot(basketToken: basketToken, storeId: storeId, timeSlotDate: timeSlotDate, timeSlotTime:timeSlotTime, postcode: postcode, fulfilmentMethod: fulfilmentMethod))
        return reserveTimeSlotResponse.publish()
    }
    
    func addItem(basketToken: String, item: BasketItemRequest, fulfilmentMethod: RetailStoreOrderMethodType) -> AnyPublisher<Basket, Error> {
        register(.addItem(basketToken: basketToken, item: item, fulfilmentMethod: fulfilmentMethod))
        return addItemResponse.publish()
    }
    
    func removeItem(basketToken: String, basketLineId: Int) -> AnyPublisher<Basket, Error> {
        register(.removeItem(basketToken: basketToken, basketLineId: basketLineId))
        return removeItemResponse.publish()
    }
    
    func updateItem(basketToken: String, basketLineId: Int, item: BasketItemRequest) -> AnyPublisher<Basket, Error> {
        register(.updateItem(basketToken: basketToken, basketLineId: basketLineId, item: item))
        return updateItemResponse.publish()
    }
    
    func applyCoupon(basketToken: String, code: String) -> AnyPublisher<Basket, Error> {
        register(.applyCoupon(basketToken: basketToken, code: code))
        return applyCouponResponse.publish()
    }
    
    func removeCoupon(basketToken: String) -> AnyPublisher<Basket, Error> {
        register(.removeCoupon(basketToken: basketToken))
        return removeCouponResponse.publish()
    }
    
    func clearItems(basketToken: String) -> AnyPublisher<Basket, Error> {
        register(.clearItems(basketToken: basketToken))
        return clearItemsResponse.publish()
    }
    
    func setContactDetails(basketToken: String, details: BasketContactDetailsRequest) -> AnyPublisher<Basket, Error> {
        register(.setContactDetails(basketToken: basketToken, details: details))
        return setContactDetailsResponse.publish()
    }
    
    func setBillingAddress(basketToken: String, address: BasketAddressRequest) -> AnyPublisher<Basket, Error> {
        register(.setBillingAddress(basketToken: basketToken, address: address))
        return setBillingAddressResponse.publish()
    }
    
    func setDeliveryAddress(basketToken: String, address: BasketAddressRequest) -> AnyPublisher<Basket, Error> {
        register(.setDeliveryAddress(basketToken: basketToken, address: address))
        return setDeliveryAddressResponse.publish()
    }
    
    func updateTip(basketToken: String, tip: Double) -> AnyPublisher<Basket, Error> {
        register(.updateTip(basketToken: basketToken, tip: tip))
        return updateTipResponse.publish()
    }
    
    func populateRepeatOrder(basketToken: String, businessOrderId: Int, fulfilmentMethod: RetailStoreOrderMethodType) -> AnyPublisher<Basket, Error> {
        register(.populateRepeatOrder(basketToken: basketToken, businessOrderId: businessOrderId, fulfilmentMethod: fulfilmentMethod))
        return populateRepeatOrderResponse.publish()
    }

}
