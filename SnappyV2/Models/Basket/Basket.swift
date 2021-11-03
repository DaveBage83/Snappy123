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
    let price: Double
    let quantity: Int
}

struct BasketFulfilmentMethod: Codable, Equatable {
    let type: FulfilmentMethod
    let datetime: Date
}

struct BasketItemRequest: Codable {
    let menuItemId: Int
    let quantity: Int
    let sizeId: Int
    let bannerAdvertId: Int
    let options: [BasketItemRequestOption]
}

struct BasketItemRequestOption: Codable {
    let id: Int
    let values: [Int]
    let type: BasketItemRequestOptionType
}

enum BasketItemRequestOptionType: String, Codable {
    case item
    case category
    case global
}
