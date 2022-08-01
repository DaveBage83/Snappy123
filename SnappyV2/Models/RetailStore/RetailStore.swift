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
    let currency: RetailStoreCurrency
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

struct RetailStoreCurrency: Codable, Equatable, Hashable {
    let currencyCode: String // e.g. "GBP"
    let symbol: String // e.g. HTML "&pound;"
    let ratio: Double
    let symbolChar: String // e.g. £, $, €
    let name: String // e.g. "Great British Pound"
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
    let memberEmailCheck: Bool?
    let guestCheckoutAllowed: Bool
    let basketOnlyTimeSelection: Bool
    let ratings: RetailStoreRatings?
    let tips: [RetailStoreTip]?
    let storeLogo: [String: URL]?
    let storeProductTypes: [Int]?
    let orderMethods: [String: RetailStoreOrderMethod]?
    let deliveryDays: [RetailStoreFulfilmentDay]
    let collectionDays: [RetailStoreFulfilmentDay]
    let paymentMethods: [PaymentMethod]?
    let paymentGateways: [PaymentGateway]?
    let allowedMarketingChannels: [AllowedMarketingChannel]
    let timeZone: String?
    let currency: RetailStoreCurrency

    // populated by request and cached data
    let searchPostcode: String?
    
    var nameWithAddress1: String {
        "\(storeName), \(address1)"
    }
}

struct AllowedMarketingChannel: Codable, Equatable {
    let id: Int
    let name: String
}

struct RetailStoreFulfilmentDay: Codable, Equatable, Hashable {
    
    // Populated from the API response:
    
    let date: String
    let holidayMessage: String?
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
    
    enum Reason: String {
        case holiday
        case closed
    }
}

enum RetailStoreSlotDayStatus: String {
    case available
    case unavailable
}

enum RetailStoreSlotDayReason: String {
    case closed
    case holiday
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

struct RetailStoreTip: Codable, Equatable, Hashable {
    let enabled: Bool
    let defaultValue: Double // not that useful as should be set automatically in the new basket
    let type: String
    
    // These fields are more for the server than the ordering
    // client - maybe they will have a future use
    let refundDriverTipsForLateOrders: Bool?
    let refundDriverTipsAfterLateByMinutes: Int?
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

    func isCompatible(with type: PaymentGatewayType) -> Bool {
        switch type {
            
        case .loyalty:
            return true
            
        case .cash:
            // no payment gateway values expected so check the methods
            if let paymentMethods = paymentMethods {
                for paymentMethod in paymentMethods where paymentMethod.name.lowercased() == "cash" {
                    return true
                }
            }
            return false
            
        default:
            // check if the payment gateway is present
            if let paymentGateways = paymentGateways {
                for paymentGateway in paymentGateways where paymentGateway.name == type.rawValue {
                    return true
                }
            }
            return false
            
        }
    }
    
}

struct PaymentMethod: Codable, Equatable {
    let name: String
    let title: String
    let description: String?
    let settings: PaymentMethodSettings
}

extension PaymentMethod {
    
    func isCompatible(with method: RetailStoreOrderMethodType, for gateway: PaymentGatewayType? = nil) -> Bool {
        let enabledForMethod = settings.enabledForMethod.contains(method)
        if
            let gateway = gateway,
            gateway.needsPaymentGatewaySettings,
            enabledForMethod
        {
            return settings.paymentGateways?.contains(gateway.rawValue) ?? false
        } else {
            // based only on the method
            return enabledForMethod
        }
    }
    
}

struct PaymentMethodSettings: Codable, Equatable {
    let title: String
    let instructions: String?
    let enabledForMethod: [RetailStoreOrderMethodType]
    let paymentGateways: [String]?
    let saveCards: Bool?
    let cutOffTime: String? // H:i:s
}


struct PaymentGateway: Codable, Equatable {
    let name: String
    let mode: String
    let fields: [String: Any]?
    
    enum CodingKeys: String, CodingKey {
        case name
        case mode
        case fields
    }
    
    // the following is required because of the Any in fields
    
    static func == (lhs: PaymentGateway, rhs: PaymentGateway) -> Bool {
        
        var fieldsMatch = true
        if lhs.fields != nil || rhs.fields != nil {
            if
                let lhsFields = lhs.fields,
                let rhsFields = rhs.fields
            {
                fieldsMatch = lhsFields.isEqual(to: rhsFields)
            } else {
                fieldsMatch = false
            }
        }
        
        return fieldsMatch && lhs.name == rhs.name && lhs.mode == rhs.mode
    }
    
    init (from decoder: Decoder) throws {
        let container =  try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decode(String.self, forKey: .name)
        mode = try container.decode(String.self, forKey: .mode)
        fields = try container.decodeIfPresent([String: Any].self, forKey: .fields)
    }
    
    func encode (to encoder: Encoder) throws {
        var container = encoder.container (keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(mode, forKey: .mode)
        try container.encodeIfPresent(fields, forKey: .fields)
    }
    
    init(name: String, mode: String, fields: [String: Any]?) {
        self.name = name
        self.mode = mode
        self.fields = fields
    }

}

// TODO: Implementation will change: https://snappyshopper.atlassian.net/browse/OAPIV2-560
struct FutureContactRequestResponse: Codable, Equatable {
    let result: FutureContactRequestResponseResult
}

struct FutureContactRequestResponseResult: Codable, Equatable {
    let status: Bool
    let message: String
    let errors: [String: [String]]?
}
