//
//  RetailStoreMenu.swift
//  SnappyV2
//
//  Created by Kevin Palser on 19/10/2021.
//

import Foundation
import CoreLocation

struct RetailStoreMenuFetch: Codable, Equatable {
    // Codable - populated by API response
    let id: Int?
    let name: String?
    let categories: [RetailStoreMenuCategory]?
    let menuItems: [RetailStoreMenuItem]?
    let dealSections: [MenuItemCategory]?
    
    // Populated by the results from the fetch
    let fetchStoreId: Int?
    let fetchCategoryId: Int?
    let fetchFulfilmentMethod: RetailStoreOrderMethodType?
    let fetchFulfilmentDate: String?
    let fetchTimestamp: Date?

    private enum CodingKeys: String, CodingKey {
        case id
        case name
        case categories
        case menuItems
        case dealSections
    }
    
    // We only want to encode 'categories' from the JSON
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeIfPresent(Int.self, forKey: .id)
        name = try container.decodeIfPresent(String.self, forKey: .name)
        categories = try container.decodeIfPresent([RetailStoreMenuCategory].self, forKey: .categories)
        menuItems = try container.decodeIfPresent([RetailStoreMenuItem].self, forKey: .menuItems)
        dealSections = try container.decodeIfPresent([MenuItemCategory].self, forKey: .dealSections)
        fetchStoreId = nil
        fetchCategoryId = nil
        fetchFulfilmentMethod = nil
        fetchFulfilmentDate = nil
        fetchTimestamp = nil
    }
    
    // The init(from decoder: Decoder) seems to stop the
    // normal init from being automatically synthesized
    init(
        id: Int,
        name: String,
        categories: [RetailStoreMenuCategory]?,
        menuItems: [RetailStoreMenuItem]?,
        dealSections: [MenuItemCategory]?,
        fetchStoreId: Int?,
        fetchCategoryId: Int?,
        fetchFulfilmentMethod: RetailStoreOrderMethodType?,
        fetchFulfilmentDate: String?,
        fetchTimestamp: Date?
    ) {
        self.id = id
        self.name = name
        self.categories = categories
        self.menuItems = menuItems
        self.dealSections = dealSections
        self.fetchStoreId = fetchStoreId
        self.fetchCategoryId = fetchCategoryId
        self.fetchFulfilmentMethod = fetchFulfilmentMethod
        self.fetchFulfilmentDate = fetchFulfilmentDate
        self.fetchTimestamp = fetchTimestamp
    }
}

struct RetailStoreMenuCategory: Codable, Equatable, Hashable {
    let id: Int
    let parentId: Int // zero if on the root category
    let name: String
    let image: [String: URL]?
    let description: String?
    let action: RetailStoreMenuCategoryAction?
    // Decided not to represent sub categories here simply because it
    // is in the API result. We are following a different methodology
    // than the one initially considered by the API v2 developers
}

struct RetailStoreMenuCategoryAction: Codable, Equatable, Hashable {
    let name: String? // Should be required, but we currently do not need it
    let params: RetailStoreMenuCategoryActionParams?
}

struct RetailStoreMenuCategoryActionParams: Codable, Equatable, Hashable {
//    let categoryId: Int?
//    let itemId: Int?
//    let couponId: Int?
    let discountId: Int?
}

struct RetailStoreMenuItem: Codable, Equatable, Identifiable, Hashable {
    let id: Int
    let name: String
    let eposCode: String?
    let outOfStock: Bool
    let ageRestriction: Int
    let description: String?
    let quickAdd: Bool
    let acceptCustomerInstructions: Bool
    let basketQuantityLimit: Int
    let price: RetailStoreMenuItemPrice
    let images: [[String: URL]]?
    let menuItemSizes: [RetailStoreMenuItemSize]?
    let menuItemOptions: [RetailStoreMenuItemOption]?
    let availableDeals: [RetailStoreMenuItemAvailableDeal]?
    let itemCaptions: ItemCaptions?
    let mainCategory: MenuItemCategory
    let itemDetails: [ItemDetails]?
    let deal: ItemDeal?
}

struct ItemDeal: Codable, Equatable, Hashable {
    let id: Int
    let name: String
    let type: String
    let section: MenuItemCategory?
}

struct ItemDetails: Codable, Equatable, Hashable {
    let header: String?
    let elements: [ItemDetailElement]?
}

struct ItemDetailElement: Codable, Equatable, Hashable {
    let type: String
    let text: String?
    let rows: [ItemDetailElementRow]?
}

struct ItemDetailElementRow: Codable, Equatable, Hashable {
    let columns: [String]?
}

struct ItemCaptions: Codable, Equatable, Hashable {
    let portionSize: String?
}

extension RetailStoreMenuItem {
    var calories: Int {
        if let string = itemCaptions?.portionSize {
            let stringArray = string.components(separatedBy: CharacterSet.decimalDigits.inverted)
            if let firstStringInt = stringArray.first, let int = Int(firstStringInt) {
                return int
            }
        }
        return 5000
    }
}

struct MenuItemCategory: Codable, Equatable, Hashable {
    let id: Int
    let name: String
}

struct RetailStoreMenuItemPrice: Codable, Equatable, Hashable {
    let price: Double
    let fromPrice: Double
    let unitMetric: String
    let unitsInPack: Int
    let unitVolume: Double
    let wasPrice: Double?
}

struct RetailStoreMenuItemSize: Codable, Equatable, Identifiable, Hashable {
    let id: Int
    let name: String
    let price: MenuItemSizePrice
}

struct MenuItemSizePrice: Codable, Equatable, Hashable {
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
    let minimumSelected: Int // Maximum selected
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
    let defaultSelection: Int
    let sizeExtraCost: [RetailStoreMenuItemOptionValueSizeCost]?
}

struct RetailStoreMenuItemOptionValueSizeCost: Codable, Identifiable, Equatable, Hashable {
    let id: Int
    let sizeId: Int
    let extraCost: Double
}

enum RetailStoreMenuGlobalSearchScope: String, Codable, Equatable {
    case items
    case categories
    case deals
}

struct RetailStoreMenuItemAvailableDeal: Codable, Equatable, Identifiable, Hashable {
    let id: Int
    let name: String
    let type: String
}

struct RetailStoreMenuGlobalSearch: Codable, Equatable {
    // Coable - populated by API response
    let categories: GlobalSearchResult?
    let menuItems: GlobalSearchItemsResult?
    let deals: GlobalSearchResult?
    let noItemFoundHint: GlobalSearchNoItemHint?
    // Populated for checking cached results
    let fetchStoreId: Int?
    let fetchFulfilmentMethod: RetailStoreOrderMethodType?
    let fetchSearchTerm: String?
    let fetchSearchScope: RetailStoreMenuGlobalSearchScope?
    let fetchTimestamp: Date?
    let fetchItemsLimit: Int?
    let fetchItemsPage: Int?
    let fetchCategoriesLimit: Int?
    let fetchCategoryPage: Int?
}

// Both GlobalSearchResult & GlobalSearchItemsResult use the same managed object
// i.e. GlobalSearchResultMO

struct GlobalSearchResult: Codable, Equatable {
    let pagination: GlobalSearchResultPagination?
    let records: [GlobalSearchResultRecord]?
}

struct GlobalSearchItemsResult: Codable, Equatable {
    let pagination: GlobalSearchResultPagination?
    let records: [RetailStoreMenuItem]?
}

struct GlobalSearchResultPagination: Codable, Equatable {
    let page: Int
    let perPage: Int
    let totalCount: Int
    let pageCount: Int
}

struct GlobalSearchResultRecord: Codable, Equatable, Hashable
{
    let id: Int
    let name: String
    let image: [String: URL]?
    let price: RetailStoreMenuItemPrice?
}

struct GlobalSearchNoItemHint: Codable, Equatable {
    let numberToCall: String?
    let label: String
}

// type shared by various methods fetching a single Item
struct RetailStoreMenuItemRequest: Equatable {
    let itemId: Int
    let storeId: Int
    let categoryId: Int?
    let fulfilmentMethod: RetailStoreOrderMethodType
    let fulfilmentDate: String?
}

struct RetailStoreMenuItemFetch: Equatable {
    // original fetch criteria
    let itemId: Int
    let storeId: Int
    let categoryId: Int?
    let fulfilmentMethod: RetailStoreOrderMethodType
    let fulfilmentDate: String?
    // result data
    let item: RetailStoreMenuItem
    let fetchTimestamp: Date?
}
