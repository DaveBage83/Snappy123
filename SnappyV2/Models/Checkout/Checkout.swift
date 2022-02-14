//
//  Checkout.swift
//  SnappyV2
//
//  Created by Kevin Palser on 04/02/2022.
//

import Foundation

enum PaymentGateway: String {
    case stripe
    case realex // globalpayments
    case cash
}

enum DraftOrderFulfilmentDetailsPlaceRequestType: String, Codable, Equatable {
    case table
    case name
    case subName
}

struct DraftOrderResult: Codable, Equatable {
    let draftOrderId: Int
    let businessOrderId: Int? // Only for cash and loyalty paid orders
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
    let time:DraftOrderFulfilmentDetailsTimeRequest?
    let place: DraftOrderFulfilmentDetailsPlaceRequest?
}

struct DraftOrderFulfilmentDetailsTimeRequest: Codable, Equatable {
    let date: String
    let requestedTime: String
}

struct DraftOrderFulfilmentDetailsPlaceRequest: Codable, Equatable {
    let type: DraftOrderFulfilmentDetailsPlaceRequestType
    let name: String
    let subName: String?
}