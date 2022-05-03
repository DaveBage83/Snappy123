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
        case setContactDetails(details: BasketContactDetailsRequest)
        case setDeliveryAddress(address: BasketAddressRequest)
        case setBillingAddress(address: BasketAddressRequest)
        case updateTip(tip: Double)
        case populateRepeatOrder(businessOrderId: Int)
        case getNewBasket
        case test(delay: TimeInterval)
    }
    
    let actions: MockActions<Action>
    
    init(expected: [Action]) {
        self.actions = .init(expected: expected)
    }
    
    func restoreBasket() async throws {
        register(.restoreBasket)
    }
    
    func updateFulfilmentMethodAndStore() async throws {
        register(.updateFulfilmentMethodAndStore)
    }
    
    func reserveTimeSlot(timeSlotDate: String, timeSlotTime: String?) async throws {
        register(.reserveTimeSlot(timeSlotDate: timeSlotDate, timeSlotTime: timeSlotTime))
    }
    
    func addItem(item: BasketItemRequest) async throws {
        register(.addItem(item: item))
    }
    
    func updateItem(item: BasketItemRequest, basketLineId: Int) async throws {
        register(.updateItem(item: item, basketLineId: basketLineId))
    }
    
    func removeItem(basketLineId: Int) async throws {
        register(.removeItem(basketLineId: basketLineId))
    }
    
    func applyCoupon(code: String) async throws {
        if code == "FAIL" {
            throw BasketServiceError.unableToProceedWithoutBasket
        }
        register(.applyCoupon(code: code))
    }
    
    func removeCoupon() async throws {
        register(.removeCoupon)
    }
    
    func clearItems() async throws {
        register(.clearItems)
    }
    
    func setContactDetails(to details: BasketContactDetailsRequest) async throws {
        register(.setContactDetails(details: details))
    }
    
    func setDeliveryAddress(to address: BasketAddressRequest) async throws {
        register(.setDeliveryAddress(address: address))
    }
    
    func setBillingAddress(to address: BasketAddressRequest) async throws {
        register(.setBillingAddress(address: address))
    }
    
    func updateTip(to tip: Double) async throws {
        register(.updateTip(tip: tip))
    }
    
    func populateRepeatOrder(businessOrderId: Int) async throws {
        register(.populateRepeatOrder(businessOrderId: businessOrderId))
    }
    
    func getNewBasket() async throws {
        register(.getNewBasket)
    }
    
    func test(delay: TimeInterval) {
        register(.test(delay: delay))
    }
    
}
