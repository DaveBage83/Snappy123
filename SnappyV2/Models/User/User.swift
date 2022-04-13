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

struct PlacedOrder: Codable, Equatable {
    let id: Int // draft order ID
    let businessOrderId: Int
    let status: String // Displayable localised text
    let statusText: String // Enumations for actions
    let totalPrice: Double
    let totalDiscounts: Double?
    let totalSurcharge: Double?
    let totalToPay: Double?
    
    // in theory "website", "android", "ios"
    // (in the future maybe more types like "telephone")
    let platform: String
    let firstOrder: Bool // always true???
    
    // YYYY-MM-DD hh:ii:ss
    // (not ISO 8601 so cannot be read directly decoded to Date obects)
    let createdAt: String
    let updatedAt: String
    
    let store: PlacedOrderStore
    let fulfilmentMethod: PlacedOrderFulfilmentMethod
    let paymentMethod: PlacedOrderPaymentMethod
    let orderLines: [PlacedOrderLine]
    let customer: PlacedOrderCustomer
    let discount: [PlacedOrderDiscount]?
    let surcharges: [PlacedOrderSurcharge]?
    let loyaltyPoints: PlacedOrderLoyaltyPoints?
    let coupon: PlacedOrderCoupon?
    
    // missing currency info https://snappyshopper.atlassian.net/browse/BGB-210
}

struct PlacedOrderStore: Codable, Equatable {
    let id: Int
    let name: String
    let originalStoreId: Int?
    let storeLogo: [String: URL]?
    let address1: String
    let address2: String?
    let town: String
    let postcode: String
    let telephone: String?
    let latitude: Double
    let longitude: Double
}

#warning("To re-instate address. At the moment, addressLine1 and addressLine2 are not returning in the API causing a decoding failure")
struct PlacedOrderFulfilmentMethod: Codable, Equatable {
    let name: RetailStoreOrderMethodType
    let processingStatus: String // enumerations in Stoplight not respected, e.g. "Store Accepted / Picking"
    let datetime: PlacedOrderFulfilmentMethodDateTime
    let place: OrderFulfilmentPlace?
//    let address: Address?
    let driverTip: Double?
    let refund: Double?
    //let cost: Double? *** in stoplight but not returned ***
    let deliveryCost: Double?
    let driverTipRefunds: [PlacedOrderDriverTip]?
}

struct PlacedOrderFulfilmentMethodDateTime: Codable, Equatable {
    let requestedDate: String? // "2022-02-18"
    let requestedTime: String? // "17:40 - 17:55"
    let estimated: Date? // "2022-02-18T17:55:00+00:00"
    let fulfilled: Date?
}

struct PlacedOrderDriverTip: Codable, Equatable {
    let value: Double
    let message: String
}

struct PlacedOrderPaymentMethod: Codable, Equatable {
    let name: String
    let dateTime: String
}

struct PlacedOrderLine: Codable, Equatable {
    let id: Int
    let substitutesOrderLineId: Int?
    let quantity: Int
    let rewardPoints: Int?
    let pricePaid: Double
    let discount: Double
    let substitutionAllowed: Bool?
    let customerInstructions: String?
    let rejectionReason: String?
    let item: PastOrderLineItem
    //let refund: *** in stoplight but not coming through: https://snappyshopper.atlassian.net/browse/BGB-210 ***
    
    #warning("Change to API requested to return this value per line. This is a temp solution below")
    var totalCost: Double {
        pricePaid * Double(quantity)
    }
}

struct PastOrderLineItem: Codable, Equatable {
    let id: Int
    let name: String
    let images: [[String: URL]]?
    let price: Double
}

struct PlacedOrderCustomer: Codable, Equatable {
    let firstname: String
    let lastname: String
}

struct PlacedOrderDiscount: Codable, Equatable {
    let name: String
    let amount: Double
    let type: String
    let lines: [Int]
}

struct PlacedOrderSurcharge: Codable, Equatable, Hashable {
    let name: String
    let amount: Double
}

struct PlacedOrderLoyaltyPoints: Codable, Equatable {
    let type: String
    let name: String
    let deductCost: Double
}

struct PlacedOrderCoupon: Codable, Equatable {
    // for display purposes
    let title: String
    let couponDeduct: Double
    // for event logging only - more important at the basket than placed orders
    let type: String
    let freeDelivery: Bool
    let value: Double
    let iterableCampaignId: Int
    // misc
    let percentage: Double
    let registeredMemberRequirement: Bool
}

struct UserSuccessResult: Codable, Equatable {
    let success: Bool
}

struct CheckRegistrationResult: Codable, Equatable {
    let loginRequired: Bool
    let contacts: [CheckRegistrationContactResult]?
}

enum OneTimePasswordSendType: String, Codable, Equatable {
    case sms
    case email
}

struct CheckRegistrationContactResult: Codable, Equatable {
    let type: OneTimePasswordSendType
    let display: String
}

struct OneTimePasswordSendResult: Codable, Equatable {
    let success: Bool
    let message: String
    // no client usecase for the following:
    // let backetToken: String
}

#warning("Change to API requested to return percent complete value. This is a temp solution below")
enum OrderStatus: String {
    enum StatusType {
        case success
        case error
        case standard
    }
    
    case unknow
    case sentToStore = "sent_to_store"
    case storeAcceptedPicking = "store_accepted_picking"
    case picked
    case enRoute = "en_route"
    case delivered
    case rejected = "store_rejected_order"
    case refunded
    
    var progress: Double {
        switch self {
        case .unknow:
            return 0
        case .sentToStore:
            return 0.2
        case .storeAcceptedPicking:
            return 0.4
        case .picked:
            return 0.6
        case .enRoute:
            return 0.8
        case .delivered, .refunded, .rejected:
            return 1
        }
    }
    
    var statusType: StatusType {
        switch self {
        case .unknow, .sentToStore, .storeAcceptedPicking, .picked, .enRoute:
            return .standard
        case .delivered, .refunded:
            return .success
        case .rejected:
            return .error
        }
    }
}

extension PlacedOrder {
    var orderStatus: OrderStatus {
        OrderStatus(rawValue: self.statusText) ?? .unknow
    }
    
    var orderProgress: Double {
        orderStatus.progress
    }
}
