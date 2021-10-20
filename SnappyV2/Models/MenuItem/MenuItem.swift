//
//  MenuItem.swift
//  SnappyV2
//
//  Created by Henrik Gustavii on 15/09/2021.
//

import Foundation

struct MenuItem {
    let id = UUID() // later Int
    let name: String
    let price: Price
    let description: String?
    let sizes: [MenuItemSize]?
    let options: [MenuItemOption]?
}

struct Price {
    let price: Double
    let fromPrice: Double?
    let wasPrice: Double?
    let unitMetric: String?
    let unitsInPack: String?
    let unitVolume: String?
}

struct MenuItemSize: Identifiable {
    let id: Int
    let name: String
    let price: Double?
}

struct MenuItemOption: Equatable, Identifiable, Hashable {
    let id: Int
    let name: String
    var placeholder: String?
    let maximumSelected: Int?
    var displayAsGrid: Bool?
    let mutuallyExclusive: Bool?
    let minimumSelected: Int?
    var dependentOn: [Int]?
    let values: [MenuItemOptionValue]
    let type: String
}

struct MenuItemOptionValue: Equatable, Identifiable, Hashable {
    let id: Int
    let name: String?
    let extraCost: Double?
    let `default`: Bool?
    let sizeExtraCost: [MenuItemOptionValueSize]?
}

struct MenuItemOptionValueSize: Identifiable, Equatable, Hashable {
    let id: Int
    let sizeId: Int?
    let extraCost: Double?
}
