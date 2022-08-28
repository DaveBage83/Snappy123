//
//  Checkout.swift
//  SnappyV2
//
//  Created by Kevin Palser on 04/02/2022.
//

import Foundation

enum PaymentGatewayType: String {
    case worldpay // worldpay online (to be deprecated)
    case stripe
    case realex // globalpayments
    case cash
    case loyalty = "loyalty_points"
    case checkoutcom
}

extension PaymentGatewayType {
    var needsPaymentGatewaySettings: Bool {
        switch self {
        case .cash, .loyalty:
            return false
        default:
            return true
        }
    }
}

enum DraftOrderFulfilmentDetailsPlaceRequestType: String, Codable, Equatable {
    case table
    case name
    case subName
}

struct DraftOrderResult: Codable, Equatable {
    let draftOrderId: Int
    let businessOrderId: Int? // Only for cash and loyalty paid orders
    let firstOrder: Bool
    let paymentMethods: DraftOrderPaymentMethods?
}

struct DraftOrderPaymentMethods: Codable, Equatable {
    let stripePaymentMethods: [StripePaymentMethod]?
}

// Structure that comes from Stripe. Hence it is not tightly defined using
// camel case for fields.
struct StripePaymentMethod: Codable, Equatable {
    let id: String
    let type: String
    let billingDetails: [String: Any]?
    let card: [String: Any]?
    
    enum CodingKeys: String, CodingKey {
        case id
        case type
        case billing_details
        case card
    }
    
    init (from decoder: Decoder) throws {
        let container =  try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        type = try container.decode(String.self, forKey: .type)
        billingDetails = try container.decodeIfPresent([String: Any].self, forKey: .billing_details)
        card = try container.decodeIfPresent([String: Any].self, forKey: .card)
    }
    
    func encode (to encoder: Encoder) throws {
        var container = encoder.container (keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(type, forKey: .type)
        try container.encodeIfPresent(billingDetails, forKey: .billing_details)
        try container.encodeIfPresent(card, forKey: .card)
    }
    
    static func == (lhs: StripePaymentMethod, rhs: StripePaymentMethod) -> Bool {
        return lhs.id == rhs.id && lhs.type == rhs.type
    }
}

struct DraftOrderFulfilmentDetailsRequest: Codable, Equatable {
    let time: DraftOrderFulfilmentDetailsTimeRequest?
    let place: OrderFulfilmentPlace?
}

struct DraftOrderFulfilmentDetailsTimeRequest: Codable, Equatable {
    let date: String
    let requestedTime: String
}

struct OrderFulfilmentPlace: Codable, Equatable {
    let type: DraftOrderFulfilmentDetailsPlaceRequestType
    let name: String
    let subName: String?
}

struct ShimmedPaymentResponse: Codable, Equatable {
    let status: Bool
    let message: String?
    let orderId: Int? // draft order ID
    let businessOrderId: Int?
    let pointsEarned: Int?
    let iterableUserEmail: String?
}

struct ConfirmPaymentResponse: Codable, Equatable {
    let result: ShimmedPaymentResponse
}

struct VerifyPaymentResponse: Codable, Equatable {
    let draftOrderId: Int
    let businessOrderId: Int
    let pointsEarned: Int
    let basketToken: String
    let message: String
}

enum PaymentType: String, Codable, Equatable {
    case card
    case id
    case applepay
    case googlepay
    case token
    case hpp
}

struct MakePaymentRequest: Codable, Equatable {
    let businessId: Int
    let draftOrderId: Int
    let paymentMethod: String // e.g. card
    let type: PaymentType
    let token: String?
    let cardId: String? // required if paymentMethod == saved_card
    let cvv: Int? // required if paymentMethod == saved_card
}

struct MakePaymentResponse: Codable, Equatable {
    let gatewayData: GatewayData
    let order: Order?
}

struct GatewayData: Codable, Equatable {
    let id: String?
    let status: MakePaymentStatus?
    let gateway: String?
    let saveCard: Bool?
    let paymentMethod: String?
    let approved: Bool?
    let _links: ThreeDSLinks?
}

struct ThreeDSLinks: Codable, Equatable {
    let redirect: HREF?
    let success: HREF?
    let failure: HREF?
}

struct HREF: Codable, Equatable {
    let href: String?
}

struct CheckoutCom3DSURLs: Identifiable, Equatable {
    var id: UUID = UUID()
    let redirectUrl: URL
    let successUrl: URL
    let failUrl: URL
}

struct Order: Codable, Equatable {
    let draftOrderId: Int
    let businessOrderId: Int?
    let pointsEarned: Double?
    let message: String?
}

// enum taken from checkout com api docs
enum MakePaymentStatus: String, Codable {
    case authorised = "Authorized"
    case pending = "Pending"
    case cardVerified = "Card Verified"
    case declined = "Declined"
}

struct ShimmedVerifyPaymentRequest: Codable, Equatable {
    let orderId: Int // draft order ID
    
}

struct PlacedOrderStatus: Codable, Equatable {
    let status: String
}

struct DriverLocation: Codable, Equatable {
    let orderId: Int
    let pusher: PusherConfiguration?
    let store: StoreLocation?
    let delivery: OrderDeliveryLocationAndStatus?
    let driver: DeliveryDriverLocationAndName?
}

struct PusherConfiguration: Codable, Equatable {
    let clusterServer: String
    let appKey: String
}

struct StoreLocation: Codable, Equatable {
    let latitude: Double
    let longitude: Double
}

struct OrderDeliveryLocationAndStatus: Codable, Equatable {
    let latitude: Double
    let longitude: Double
    let status: Int
}

struct DeliveryDriverLocationAndName: Codable, Equatable {
    let name: String
    let latitude: Double
    let longitude: Double
}

// Purely for persistent storage - will never be returned by the API
struct LastDeliveryOrderOnDevice: Equatable {
    let businessOrderId: Int
    let storeName: String?
    let storeContactNumber: String?
    let deliveryPostcode: String?
}

struct DriverLocationMapParameters: Equatable {
    let businessOrderId: Int
    let driverLocation: DriverLocation
    // set when returning from app transition event auto checking logic
    let lastDeliveryOrder: LastDeliveryOrderOnDevice?
    // set when viewing from an order
    let placedOrder: PlacedOrder?
}

struct CardDetails: Equatable {
    let number: String
    let expiryMonth: String
    let expiryYear: String
    let cvv: String
    let cardName: String
}
