//
//  RetailStore.swift
//  SnappyV2
//
//  Created by Henrik Gustavii on 15/09/2021.
//

import Foundation
import CoreLocation

struct RetailStoresSearch: Codable, Equatable {
    let storeProductTypes: [RetailStoreProductType]?
    let stores: [RetailStore]?
    let fulfilmentLocation: FulfilmentLocation
}

struct RetailStore: Codable, Equatable, Hashable {
    let id: Int
    let storeName: String
    let distance: Double
    let storeLogo: [String: URL]?
    let storeProductTypes: [Int]?
    let orderMethods: [String: RetailStoreOrderMethod]?
    let ratings: RetailStoreRatings?
}

struct RetailStoreProductType: Codable, Equatable, Hashable {
    let id: Int
    let name: String
    let image: [String: URL]?
}

enum RetailStoreOrderMethodType: String, Codable {
    case delivery
    case collection
    case table
    case room
}

enum RetailStoreOrderMethodStatus: String, Codable {
    case open
    case closed
    case preorder
}

struct RetailStoreOrderMethod: Codable, Equatable, Hashable {
    let name: RetailStoreOrderMethodType
    let earliestTime: String?
    let status: RetailStoreOrderMethodStatus
    let cost: Double?
    let fulfilmentIn: String?
    // workingHours - todo, differs from spolight
}

struct FulfilmentLocation: Codable, Equatable {
    let country: String
    let latitude: Double
    let longitude: Double
    let postcode: String
    
    var location: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}

struct RetailStoreDetails: Codable, Equatable {
    let id: Int
    let menuGroupId: Int
    let storeName: String
    let telephone: String
    let lat: Double
    let lng: Double
    let ordersPaused: Bool
    let canDeliver: Bool
    let distance: Double?
    let pausedMessage: String?
    let address1: String
    let address2: String?
    let town: String
    let postcode: String
    let customerOrderNotePlaceholder: String?
    let ratings: RetailStoreRatings?
    let storeLogo: [String: URL]?
    let storeProductTypes: [Int]?
    let orderMethods: [String: RetailStoreOrderMethod]?
    let deliveryDays: [RetailStoreFulfilmentDay]?
    let collectionDays: [RetailStoreFulfilmentDay]?
    
    let timeZone: String?

    // populated by request and cached data
    let searchPostcode: String?
}

struct RetailStoreFulfilmentDay: Codable, Equatable, Hashable {
    
    // Populated from the API response:
    
    let date: String
    let start: String? // Not used by app UI
    let end: String? // Not used by app UI
    
    // Populated by RetailStoresService, not part of the API response:
    
    let storeDateStart: Date?
    let storeDateEnd: Date?
}

struct RetailStoreTimeSlots: Codable, Equatable {
    let startDate: Date
    let endDate: Date
    //let slotWindow: Int
    let fulfilmentMethod: String
    let slotDays: [RetailStoreSlotDay]? // normally/should be only one entry
    
    // populated by request and cached data
    let searchStoreId: Int?
    let searchLatitude: Double?
    let searchLongitude: Double?
}

struct RetailStoreSlotDay: Codable, Equatable {
    let status: String
    let reason: String
    let slotDate: String
    let slots: [RetailStoreSlotDayTimeSlot]?
}

struct RetailStoreSlotDayTimeSlot: Codable, Equatable {
    let slotId: String
    let startTime: Date
    let endTime: Date
    let daytime: String
    let info: RetailStoreSlotDayTimeSlotInfo
}

struct RetailStoreSlotDayTimeSlotInfo: Codable, Equatable {
    let status: String
    let isAsap: Bool
    let price: Double
    let fulfilmentIn: String
}

struct RetailStoreRatings: Codable, Equatable, Hashable {
    let averageRating: Double
    let numRatings: Int
}

extension RetailStoreDetails {
    
    var storeTimeZone: TimeZone? {
        if
            let storeTimeZone = self.timeZone,
            let timeZone = TimeZone(identifier: storeTimeZone)
        {
            return timeZone
        } else {
            return AppV2Constants.Business.defaultTimeZone
        }
    }
    
    func date(from sourceDate: Date?) -> String? {
        if
            let storeTimeZone = storeTimeZone,
            let sourceDate = sourceDate
        {
            return sourceDate.dateOnlyString(storeTimeZone: storeTimeZone)
        }
        return nil
    }
    
    func storeDateToday() -> String? {
        if let storeTimeZone = storeTimeZone {
            return Date().trueDate.dateOnlyString(storeTimeZone: storeTimeZone)
        }
        return nil
    }
}
