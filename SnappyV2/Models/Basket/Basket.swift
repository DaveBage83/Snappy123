//
//  Basket.swift
//  SnappyV2
//
//  Created by Kevin Palser on 25/10/2021.
//

import Foundation

struct Basket: Codable, Equatable {
    let basketToken: String
    let isNewBasket: Bool
    let items: [BasketItem]
    let fulfilmentMethod: BasketFulfilmentMethod
    let selectedSlot: BasketSelectedSlot?
    let savings: [BasketSaving]?
    let coupon: BasketCoupon?
    let fees: [BasketFee]?
    let addresses: [BasketAddressResponse]?
    let orderSubtotal: Double
    let orderTotal: Double
}

struct BasketItem: Codable, Equatable, Hashable {
    let basketLineId: Int
    let menuItem: RetailStoreMenuItem
    let totalPrice: Double
    let totalPriceBeforeDiscounts: Double
    let price: Double
    let pricePaid: Double
    let quantity: Int
    let size: BasketItemSelectedSize?
    let selectedOptions: [BasketItemSelectedOption]?
    let missedPromotions: [BasketItemMissedPromotion]?
}

struct BasketItemSelectedSize: Codable, Equatable, Hashable {
    let id: Int
    let name: String?
}

struct BasketItemSelectedOption: Codable, Equatable, Hashable {
    let id: Int
    let selectedValues: [Int]
}

struct BasketItemMissedPromotion: Codable, Equatable, Hashable {
    let referenceId: Int
    let name: String
    let type: BasketItemMissedPromotionType
    let missedSections: [BasketItemMissedPromotionSection]?
}

enum BasketItemMissedPromotionType: String, Codable, Equatable {
    case item
    case discount
    case multiSectionDiscount
}

struct BasketItemMissedPromotionSection: Codable, Equatable, Hashable {
    let id: Int
    let name: String
}

struct BasketFulfilmentMethod: Codable, Equatable {
    let type: RetailStoreOrderMethodType
    //let datetime: Date // disabled for now until bakend team straighten out
}

struct BasketSelectedSlot: Codable, Equatable {
    let todaySelected: Bool? // not returned from the API when false
    let start: Date?
    let end: Date?
    let expires: Date?
}

struct BasketSaving: Codable, Equatable, Hashable {
    let name: String
    let amount: Double
    let type: String?
    let lines: [Int]?
}

struct BasketCoupon: Codable, Equatable {
    let code: String
    let name: String
    let deductCost: Double
}

struct BasketFee: Codable, Equatable, Hashable {
    let typeId: Int
    let title: String
    let description: String? // information icon button to display if present
    let isOptional: Bool // occasionally fees can be removed
    let amount: Double
}

struct BasketItemRequest: Codable, Equatable {
    let menuItemId: Int
    let quantity: Int
    let sizeId: Int
    let bannerAdvertId: Int
    let options: [BasketItemRequestOption]
}

struct BasketItemRequestOption: Codable, Equatable {
    let id: Int
    let values: [Int]
    let type: BasketItemRequestOptionType
}

enum BasketItemRequestOptionType: String, Codable, Equatable {
    case item
    case category
    case global
}

struct BasketAddressRequest: Codable, Equatable {
    let firstName: String
    let lastName: String
    let addressline1: String
    let addressline2: String
    let town: String
    let postcode: String
    let countryCode: String
    let type: String
    let email: String
    let telephone: String
    let state: String?
    let county: String?
    let location: BasketAddressLocation?
}

struct BasketAddressResponse: Codable, Equatable {
    let firstName: String?
    let lastName: String?
    let addressLine1: String
    let addressLine2: String
    let town: String
    let postcode: String
    let countryCode: String?
    let type: String
    let email: String?
    let telephone: String?
    let state: String?
    let county: String?
    let location: BasketAddressLocation?
}

// For requests and results
struct BasketAddressLocation: Codable, Equatable {
    let latitude: Double
    let longitude: Double
}
