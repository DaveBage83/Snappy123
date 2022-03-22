//
//  User.swift
//  SnappyV2
//
//  Created by Kevin Palser on 29/12/2021.
//

import Foundation

struct MemberProfile: Codable, Equatable {
    let firstname: String
    let lastname: String
    let emailAddress: String
    let type: MemberType
    let referFriendCode: String?
    let referFriendBalance: Double
    let numberOfReferrals: Int
    let mobileContactNumber: String?
    let mobileValidated: Bool
    let acceptedMarketing: Bool // legacy
    // StopLight currently has defaultBillingDetails as
    // required but it might become optional
    let defaultBillingDetails: Address?
    let savedAddresses: [Address]?
    
    // Populated by the results from the fetch
    let fetchTimestamp: Date?
}

struct MemberProfileRegisterRequest: Codable, Equatable {
    let firstname: String
    let lastname: String
    let emailAddress: String
    
    // probably will be depricated - potentially what the
    // friend might have given to the customer
    let referFriendCode: String?
    
    let mobileContactNumber: String?
    let defaultBillingDetails: Address?
    let savedAddresses: [Address]?
}

enum MemberType: String, Codable, Equatable {
    case customer
    case driver
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

enum MarketingOptions: String {
    case email
    case notification
    case sms
    case telephone
    case directMail
    
    func title() -> String {
        switch self {
        case .email:
            return Strings.CheckoutDetails.MarketingPreferences.email.localized
        case .notification:
            return Strings.CheckoutDetails.MarketingPreferences.notifications.localized
        case .sms:
            return Strings.CheckoutDetails.MarketingPreferences.sms.localized
        case .telephone:
            return Strings.CheckoutDetails.MarketingPreferences.telephone.localized
        case .directMail:
            return Strings.CheckoutDetails.MarketingPreferences.directMail.localized
        }
    }
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

struct PastOrder: Codable, Equatable {
    let id: Int // draft order ID
    let businessOrderId: Int
    let status: String // enumerations in Stoplight not respected, e.g. "Store Accepted / Picking"
    let store: PastOrderStore
    let fulfilmentMethod: PastOrderFulfilmentMethod
    let createdAt: String
    let updatedAt: String
    let totalPrice: Double
    let totalDiscounts: Double?
    let totalSurcharge: Double?
    let totalToPay: Double?
    //let paymentMethod: PastOrderPaymentMethod // in Stoplight but not returned
    let orderLines: [PastOrderLine]
    let customer: PastOrderCustomer
    let discount: [PastOrderDiscount]?
    let surcharges: [PastOrderSurcharge]?
    let loyaltyPoints: PastOrderLoyaltyPoints?
}

struct PastOrderStore: Codable, Equatable {
    let id: Int
    let name: String
    let originalStoreId: Int
    let storeLogo: [String: URL]?
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
    let processingStatus: String // enumerations in Stoplight not respected, e.g. "Store Accepted / Picking"
    let datetime: PastOrderFulfilmentMethodDateTime
    let place: OrderFulfilmentPlace?
    let address: Address?
    let driverTip: Double
    let refund: Double
    let cost: Double
    let driverTipRefunds: [PastOrderDriverTip]?
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

//struct PastOrderPaymentMethod: Codable, Equatable {
//    let name: Double
//    let dateTime: String
//    let paymentGateway: String
//    let lastFourDigits: String?
//}

struct PastOrderLine: Codable, Equatable {
    let id: Int
    let item: PastOrderLineItem
    let quantity: Int
    let rewardPoints: Int
    let pricePaid: Double
    let discount: Double
    let substitutionAllowed: Bool
}

struct PastOrderLineItem: Codable, Equatable {
    let id: Int
    let name: String
    let image: [[String: URL]]?
    let price: Double
}

struct PastOrderCustomer: Codable, Equatable {
    let firstname: String
    let lastname: String
}

struct PastOrderDiscount: Codable, Equatable {
    let name: String
    let amount: Double
    let type: String
    let lines: [Int]
}

struct PastOrderSurcharge: Codable, Equatable {
    let name: String
    let amount: Double
}

struct PastOrderLoyaltyPoints: Codable, Equatable {
    let type: String
    let name: String
    let deductCost: Double
}

struct UserSuccessResult: Codable, Equatable {
    let success: Bool
}
