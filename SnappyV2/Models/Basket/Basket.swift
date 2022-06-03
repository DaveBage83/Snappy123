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
    let tips: [BasketTip]?
    let addresses: [BasketAddressResponse]?
    let orderSubtotal: Double
    let orderTotal: Double
    let storeId: Int?
    let basketItemRemoved: Bool?
}

struct BasketItem: Codable, Equatable, Hashable {
    let basketLineId: Int
    let menuItem: RetailStoreMenuItem
    let totalPrice: Double
    let totalPriceBeforeDiscounts: Double
    let price: Double
    let pricePaid: Double
    let quantity: Int
    let instructions: String?
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
    let cost: Double
    let minSpend: Double
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
    let iterableCampaignId: Int?
    let type: String
    let value: Double
    let freeDelivery: Bool
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
    let quantity: Int? // when setting an absolute value
    let changeQuantity: Int? // when changing the existing value
    let sizeId: Int
    let bannerAdvertId: Int
    let options: [BasketItemRequestOption]
    let instructions: String? // Can be set when RetailStoreMenuItem.acceptInstructions is true
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
    let addressLine1: String
    let addressLine2: String
    let town: String
    let postcode: String
    let countryCode: String
    let type: String
    let email: String
    let telephone: String
    let state: String?
    let county: String?
    let location: Location?
}

struct BasketAddressResponse: Codable, Equatable {
    let firstName: String?
    let lastName: String?
    let addressLine1: String? // Can be empty, e.g. after /checkout/setContactDetails.json
    let addressLine2: String?
    let town: String
    let postcode: String
    let countryCode: String?
    let type: String
    let email: String?
    let telephone: String?
    let state: String?
    let county: String?
    let location: Location?
}

struct BasketTip: Codable, Equatable {
    let type: String
    let amount: Double
}

struct BasketContactDetailsRequest: Equatable {
    let firstName: String
    let lastName: String
    let email: String
    let telephone: String
}
