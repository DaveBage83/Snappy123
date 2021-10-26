//
//  RetailStoreMenu.swift
//  SnappyV2
//
//  Created by Kevin Palser on 19/10/2021.
//

import Foundation
import CoreLocation

struct RetailStoreMenuFetch: Codable, Equatable {
    // Coable - populated by API response
    let categories: [RetailStoreMenuCategory]?
    let menuItems: [RetailStoreMenuItem]?
    
    // Populated by the results from the fetch
    let fetchStoreId: Int?
    let fetchCategoryId: Int?
    let fetchFulfilmentMethod: FulfilmentMethod?
    let fetchTimestamp: Date?

    private enum CodingKeys: String, CodingKey {
        case categories
        case menuItems
    }
    
    // We only want to encode 'categories' from the JSON
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        categories = try container.decodeIfPresent([RetailStoreMenuCategory].self, forKey: .categories)
        menuItems = try container.decodeIfPresent([RetailStoreMenuItem].self, forKey: .menuItems)
        fetchStoreId = nil
        fetchCategoryId = nil
        fetchFulfilmentMethod = nil
        fetchTimestamp = nil
    }
    
    // The init(from decoder: Decoder) seems to stop the
    // normal init from being automatically synthesized
    init(
        categories: [RetailStoreMenuCategory]?,
        menuItems: [RetailStoreMenuItem]?,
        fetchStoreId: Int?,
        fetchCategoryId: Int?,
        fetchFulfilmentMethod: FulfilmentMethod?,
        fetchTimestamp: Date?
    ) {
        self.categories = categories
        self.menuItems = menuItems
        self.fetchStoreId = fetchStoreId
        self.fetchCategoryId = fetchCategoryId
        self.fetchFulfilmentMethod = fetchFulfilmentMethod
        self.fetchTimestamp = fetchTimestamp
    }
}

struct RetailStoreMenuCategory: Codable, Equatable {
    let id: Int
    let parentId: Int
    let name: String
    let image: [String: URL]?
    // Decided not to represent sub categories here simply because it
    // is in the API result. We are following a different methodology
    // than the one initially considered by the API v2 developers
}

struct RetailStoreMenuItem: Codable, Equatable {
    let id: Int
    let name: String
    let eposCode: String?
    let outOfStock: Bool
    let ageRestriction: Int
    let description: String?
    let quickAdd: Bool
    let price: RetailStoreMenuItemPrice
    let images: [[String: URL]]?
}

struct RetailStoreMenuItemPrice: Codable, Equatable {
    let price: Double
    let fromPrice: Double
    let unitMetric: String
    let unitsInPack: Int
    let unitVolume: Double
}
