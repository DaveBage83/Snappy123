//
//  BusinessProfile.swift
//  SnappyV2
//
//  Created by Kevin Palser on 02/03/2022.
//

import Foundation

struct TipLimitLevel: Codable, Equatable {
    let level: Int
    let amount: Double
    let type: String
    let title: String
}

struct FacebookSetting: Codable, Equatable {
    let pixelId: String
    let appId: String
}

struct TikTokSetting: Codable, Equatable {
    let pixelId: String
}

struct BusinessProfile: Codable, Equatable {
    let id: Int
    let checkoutTimeoutSeconds: Int?
    let minOrdersForAppReview: Int
    let privacyPolicyLink: URL?
    let pusherClusterServer: String?
    let pusherAppKey: String?
    let mentionMeEnabled: Bool?
    let iterableMobileApiKey: String?
    let useDeliveryFirms: Bool
    let driverTipIncrement: Double
    let tipLimitLevels: [TipLimitLevel]
    let facebook: FacebookSetting
    let tikTok: TikTokSetting
    
    // Populated for checking cached results not from
    // decoding an API response
    let fetchLocaleCode: String?
    let fetchTimestamp: Date?
}
