//
//  MockedBasketService.swift
//  SnappyV2Tests
//
//  Created by Kevin Palser on 19/12/2021.
//

import XCTest
import Combine
@testable import SnappyV2

struct MockedBasketService: Mock, BasketServiceProtocol {
    
    enum Action: Equatable {
        case restoreBasket
        case updateFulfilmentMethodAndStore
        case reserveTimeSlot(timeSlotDate: String, timeSlotTime: String?)
        case addItem(item: BasketItemRequest)
        case updateItem(item: BasketItemRequest, basketLineId: Int)
        case removeItem(basketLineId: Int)
        case applyCoupon(code: String)
        case removeCoupon
        case clearItems
        case setDeliveryAddress(address: BasketAddressRequest)
        case setBillingAddress(address: BasketAddressRequest)
        case updateTip(tip: Double)
        case getNewBasket
        case test(delay: TimeInterval)
    }
    
    let actions: MockActions<Action>
    
    init(expected: [Action]) {
        self.actions = .init(expected: expected)
    }
    
    func restoreBasket() -> Future<Void, Error> {
        register(.restoreBasket)
        return Future { $0(.success(())) }
    }
    
    func updateFulfilmentMethodAndStore() -> Future<Void, Error> {
        register(.updateFulfilmentMethodAndStore)
        return Future { $0(.success(())) }
    }
    
    func reserveTimeSlot(timeSlotDate: String, timeSlotTime: String?) -> Future<Void, Error> {
        register(.reserveTimeSlot(timeSlotDate: timeSlotDate, timeSlotTime: timeSlotTime))
        return Future { $0(.success(())) }
    }
    
    func addItem(item: BasketItemRequest) -> Future<Void, Error> {
        register(.addItem(item: item))
        return Future { $0(.success(())) }
    }
    
    func updateItem(item: BasketItemRequest, basketLineId: Int) -> Future<Void, Error> {
        register(.updateItem(item: item, basketLineId: basketLineId))
        return Future { $0(.success(())) }
    }
    
    func removeItem(basketLineId: Int) -> Future<Void, Error> {
        register(.removeItem(basketLineId: basketLineId))
        return Future { $0(.success(())) }
    }
    
    func applyCoupon(code: String) -> Future<Void, Error> {
        if code == "FAIL" {
            let error = BasketServiceError.unableToProceedWithoutBasket
            return Future { $0(.failure(error)) }
        } else {
            register(.applyCoupon(code: code))
            return Future { $0(.success(())) }
        }
    }
    
    func removeCoupon() -> Future<Void, Error> {
        register(.removeCoupon)
        return Future { $0(.success(())) }
    }
    
    func clearItems() -> Future<Void, Error> {
        register(.clearItems)
        return Future { $0(.success(())) }
    }
    
    func setDeliveryAddress(to address: BasketAddressRequest) -> Future<Void, Error> {
        register(.setDeliveryAddress(address: address))
        return Future { $0(.success(())) }
    }
    
    func setBillingAddress(to address: BasketAddressRequest) -> Future<Void, Error> {
        register(.setBillingAddress(address: address))
        return Future { $0(.success(())) }
    }
    
    func updateTip(to tip: Double) -> Future<Void, Error> {
        register(.updateTip(tip: tip))
        return Future { $0(.success(())) }
    }
    
    func getNewBasket() -> Future<Void, Error> {
        register(.getNewBasket)
        return Future { $0(.success(())) }
    }
    
    func test(delay: TimeInterval) -> Future<Void, Error> {
        register(.test(delay: delay))
        return Future { $0(.success(())) }
    }
    
}
