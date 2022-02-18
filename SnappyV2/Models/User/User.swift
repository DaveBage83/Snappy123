//
//  User.swift
//  SnappyV2
//
//  Created by Kevin Palser on 29/12/2021.
//

import Foundation

struct MemberProfile: Codable, Equatable {
    let firstName: String
    let lastName: String
    let emailAddress: String
    let type: MemberType
    
    // Populated by the results from the fetch
    let fetchTimestamp: Date?
}

enum MemberType: String, Codable, Equatable {
    case customer
    case driver
}

struct Address: Codable, Equatable {
    let id: Int?
    let isDefault: Bool
    let addressName: String?
    let firstName: String
    let lastName: String
    let addressline1: String
    let addressline2: String?
    let town: String
    let postcode: String
    let county: String?
    let countryCode: String
    let type: AddressType
    let location: Location?
}

enum AddressType: String, Codable, Equatable {
    case billing
    case delivery
}

struct UserMarketingOptionsFetch: Codable, Equatable {
    let marketingPreferencesIntro: String?
    let marketingPreferencesGuestIntro: String?
    let marketingOptions: [UserMarketingOptionResponse]?
    
    // Populated by the results from the fetch
    let fetchIsCheckout: Bool?
    let fetchNotificationsEnabled: Bool?
    let fetchBasketToken: String?
    let fetchTimestamp: Date?
}

struct UserMarketingOptionResponse: Codable, Equatable {
    let type: String
    let text: String
    let opted: UserMarketingOptionState
}

struct UserMarketingOptionRequest: Codable, Equatable {
    let type: String
    let opted: UserMarketingOptionState
}

enum UserMarketingOptionState: String, Codable, Equatable {
    case `in`
    case `out`
}

struct UserMarketingOptionsUpdateResponse: Codable, Equatable {
    let email: UserMarketingOptionState?
    let directMail: UserMarketingOptionState?
    let notification: UserMarketingOptionState?
    let telephone: UserMarketingOptionState?
    let sms: UserMarketingOptionState?
}

enum PastOrderStatus: String, Codable, Equatable {
    case pending = "Order Pending"
    case accepted = "Order Accepted"
    case paymentAccepted = "Payment Accepted" // should never see this
    case paymentRejected = "Payment Rejected" // should never see this
    case outForDelivery = "Out for Delivery"
    case delivered = "Delivered"
    case cashOrderDeclined = "Cash Order Declined"
    case cardOrderDeclined = "Card Order Declined"
    case refunded = "Refunded"
}

struct PastOrder: Codable, Equatable {
    let id: Int // draft order ID
    let businessOrderId: Int
    let status: PastOrderStatus
    let store: PastOrderStore
    let createdAt: String
    let updatedAt: String
    let totalPrice: Double
    let totalDiscounts: Double?
    let totalSurcharge: Double?
    let totalToPay: Double?
    let paymentMethod: PastOrderPaymentMethod
    let orderLines: [PastOrderLine]
}

struct PastOrderStore: Codable, Equatable {
    let id: Int
    let name: String
    let originalStoreId: Int
    let storeLogo: String
    let address1: String
    let address2: String?
    let town: String
    let postcode: String
    let telephone: String?
    let lat: Double
    let lng: Double
}

struct PastOrderFulfilmentMethod: Codable, Equatable {
    let name: RetailStoreOrderMethodType
    let processingStatus: PastOrderFulfilmentMethodStatus
    let datetime: PastOrderFulfilmentMethodDateTime
    let place: OrderFulfilmentPlace?
    let address: Address?
    let driverTip: Double
    let refund: Double
    let cost: Double
    let driverTipRefunds: [PastOrderDriverTip]?
}

enum PastOrderFulfilmentMethodStatus: String, Codable, Equatable {
    case delivered
    case pending
}

struct PastOrderFulfilmentMethodDateTime: Codable, Equatable {
    let requestedDate: String?
    let requestedTime: String?
    let estimated: String?
    let fulfilled: String?
}

struct PastOrderDriverTip: Codable, Equatable {
    let value: Double
    let message: String
}

struct PastOrderPaymentMethod: Codable, Equatable {
    let name: Double
    let dateTime: String
    let paymentGateway: String
    let lastFourDigits: String?
}

struct PastOrderLine: Codable, Equatable {
    let id: Int
    let dateTime: String
    let paymentGateway: String
    let lastFourDigits: String?
}
