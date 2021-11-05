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
    let fetchFulfilmentMethod: RetailStoreOrderMethodType?
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
        fetchFulfilmentMethod: RetailStoreOrderMethodType?,
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
    let sizes: [RetailStoreMenuItemSize]?
    let options: [RetailStoreMenuItemOption]?
}

struct RetailStoreMenuItemPrice: Codable, Equatable {
    let price: Double
    let fromPrice: Double
    let unitMetric: String
    let unitsInPack: Int
    let unitVolume: Double
    let wasPrice: Double?
}

struct RetailStoreMenuItemSize: Codable, Equatable, Identifiable {
    let id: Int
    let name: String
    let price: MenuItemSizePrice
}

struct MenuItemSizePrice: Codable, Equatable {
    let price: Double
}

/// RetailStoreMenuItemOptionSource is for the future to optimise the backend by passing it to the API when selected
/// so that it knows the source of the option instead of going though all 3 database tables.
enum RetailStoreMenuItemOptionSource: String, Codable {
    case item
    case global
    case category
}

struct RetailStoreMenuItemOption: Codable, Equatable, Identifiable, Hashable {
    let id: Int
    let name: String
    let type: RetailStoreMenuItemOptionSource
    let placeholder: String
    let instances: Int
    let displayAsGrid: Bool
    let mutuallyExclusive: Bool
    let minimumSelected: Int
    let extraCostThreshold: Double
    let dependencies: [Int]?
    // in production values should be populated but there might be cases
    // when the admin team are creating item entries and the value are
    // not present initially
    let values: [RetailStoreMenuItemOptionValue]?
}

struct RetailStoreMenuItemOptionValue: Codable, Equatable, Identifiable, Hashable {
    let id: Int
    let name: String
    // extraCost value is ignored if a size value match is found in sizeExtraCost array.
    let extraCost: Double
    // `default` is useful when minimum selections are present if the UI has to preselect
    // the options for some of the instances
    let `default`: Bool
    let sizeExtraCost: [RetailStoreMenuItemOptionValueSizeCost]?
}

struct RetailStoreMenuItemOptionValueSizeCost: Codable, Identifiable, Equatable, Hashable {
    let id: Int
    let sizeId: Int
    let extraCost: Double
}
