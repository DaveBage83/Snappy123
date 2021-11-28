//
//  Basket.swift
//  SnappyV2
//
//  Created by Kevin Palser on 25/10/2021.
//

import Foundation
import KeychainAccess
import UIKit

struct Basket: Codable, Equatable {
    let basketToken: String
    let isNewBasket: Bool
    let items: [BasketItem]
    let fulfilmentMethod: BasketFulfilmentMethod
}

struct BasketItem: Codable, Equatable {
    let basketLineId: Int
    let menuItem: RetailStoreMenuItem
    let totalPrice: Double
    let totalPriceBeforeDiscounts: Double
    let price: Double
    let pricePaid: Double
    let quantity: Int
    let size: BasketItemSelectedSize?
    let selectedOptions: [BasketItemSelectedOption]?
}

struct BasketItemSelectedSize: Codable, Equatable {
    let id: Int
    let name: String?
}

struct BasketItemSelectedOption: Codable, Equatable {
    let id: String // TODO: waiting for API fix to change to Int
    let selectedValues: [Int]
}

struct BasketFulfilmentMethod: Codable, Equatable {
    let type: RetailStoreOrderMethodType
    //let datetime: Date // disabled for now until bakend team straighten out
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
