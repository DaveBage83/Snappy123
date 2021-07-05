//
//  MockData.swift
//  SnappyV2Study
//
//  Created by Henrik Gustavii on 14/06/2021.
//

import Foundation

struct MockData {
    struct StoreTypeData {
        let id: Int
        let label: String
        let image: String
    }
    
    enum StoreType: CaseIterable {
        case convenienceStores
        case butchers
        case bakers
        case florists
        case fishmongers
        case greengrocers
        case pharmacies
        case takeaways
        
        func getStoreTypeData() -> StoreTypeData {
            switch self {
            case .convenienceStores:
                return StoreTypeData(id: 1, label: "Convenience Stores", image: "convenience")
            case .butchers:
                return StoreTypeData(id: 2, label: "Butchers", image: "butchers")
            case .bakers:
                return StoreTypeData(id: 3, label: "Bakers", image: "bakers")
            case .florists:
                return StoreTypeData(id: 4, label: "Florists", image: "florists")
            case .fishmongers:
                return StoreTypeData(id: 5, label: "Fishmongers", image: "fishmongers")
            case .greengrocers:
                return StoreTypeData(id: 6, label: "Greengrocers", image: "greengrocers")
            case .pharmacies:
                return StoreTypeData(id: 8, label: "Pharmacies", image: "pharmacies")
            case .takeaways:
                return StoreTypeData(id: 9, label: "Takeaways", image: "takeaways")
            }
        }
    }
}

struct StoreCardDetails {
    let id = UUID()
    let name: String
    let logo: String
    let address: String
    let deliveryTime: String
    let distaceToDeliver: Double
    let deliveryCharge: Double?
    let isNewStore: Bool
}
