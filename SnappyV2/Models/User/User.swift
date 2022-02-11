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
