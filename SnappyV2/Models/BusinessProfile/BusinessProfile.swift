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
    let colors: BusinessProfileColors? // For now this will be nil as no white labeling colour info currently returned in API.
}

#warning("This is not currently coming back from the API, but we have are implementing this for future white labeling")
struct BusinessProfileColors: Codable, Equatable {
    let success: BusinessProfileColor?
    let warning: BusinessProfileColor?
    let highlight: BusinessProfileColor?
    let offerBasket: BusinessProfileColor?
    let backgroundMain: BusinessProfileColor?
    let modalBG: BusinessProfileColor?
    let primaryBlue: BusinessProfileColor?
    let primaryRed: BusinessProfileColor?
    let secondaryWhite: BusinessProfileColor?
    let secondaryBakery: BusinessProfileColor?
    let secondaryButcher: BusinessProfileColor?
    let secondaryConvenience: BusinessProfileColor?
    let secondaryDark: BusinessProfileColor?
    let textBlack: BusinessProfileColor?
    let textGrey1: BusinessProfileColor?
    let textGrey2: BusinessProfileColor?
    let textGrey3: BusinessProfileColor?
    let textGrey4: BusinessProfileColor?
    let textGrey5: BusinessProfileColor?
    let textGrey6: BusinessProfileColor?
    let textWhite: BusinessProfileColor?
    
    static func mapFromCoreData(_ businessProfileColors: BusinessProfileColorsMO?) -> BusinessProfileColors? {
        
        guard let businessProfileColors = businessProfileColors else { return nil }

        return BusinessProfileColors(
            success: BusinessProfileColor(light: businessProfileColors.success?.light, dark: businessProfileColors.success?.dark),
            warning: BusinessProfileColor(light: businessProfileColors.success?.light, dark: businessProfileColors.success?.dark),
            highlight: BusinessProfileColor(light: businessProfileColors.success?.light, dark: businessProfileColors.success?.dark),
            offerBasket: BusinessProfileColor(light: businessProfileColors.success?.light, dark: businessProfileColors.success?.dark),
            backgroundMain: BusinessProfileColor(light: businessProfileColors.success?.light, dark: businessProfileColors.success?.dark),
            modalBG: BusinessProfileColor(light: businessProfileColors.success?.light, dark: businessProfileColors.success?.dark),
            primaryBlue: BusinessProfileColor(light: businessProfileColors.success?.light, dark: businessProfileColors.success?.dark),
            primaryRed: BusinessProfileColor(light: businessProfileColors.success?.light, dark: businessProfileColors.success?.dark),
            secondaryWhite: BusinessProfileColor(light: businessProfileColors.success?.light, dark: businessProfileColors.success?.dark),
            secondaryBakery: BusinessProfileColor(light: businessProfileColors.success?.light, dark: businessProfileColors.success?.dark),
            secondaryButcher: BusinessProfileColor(light: businessProfileColors.success?.light, dark: businessProfileColors.success?.dark),
            secondaryConvenience: BusinessProfileColor(light: businessProfileColors.success?.light, dark: businessProfileColors.success?.dark),
            secondaryDark: BusinessProfileColor(light: businessProfileColors.success?.light, dark: businessProfileColors.success?.dark),
            textBlack: BusinessProfileColor(light: businessProfileColors.success?.light, dark: businessProfileColors.success?.dark),
            textGrey1: BusinessProfileColor(light: businessProfileColors.success?.light, dark: businessProfileColors.success?.dark),
            textGrey2: BusinessProfileColor(light: businessProfileColors.success?.light, dark: businessProfileColors.success?.dark),
            textGrey3: BusinessProfileColor(light: businessProfileColors.success?.light, dark: businessProfileColors.success?.dark),
            textGrey4: BusinessProfileColor(light: businessProfileColors.success?.light, dark: businessProfileColors.success?.dark),
            textGrey5: BusinessProfileColor(light: businessProfileColors.success?.light, dark: businessProfileColors.success?.dark),
            textGrey6: BusinessProfileColor(light: businessProfileColors.success?.light, dark: businessProfileColors.success?.dark),
            textWhite: BusinessProfileColor(light: businessProfileColors.success?.light, dark: businessProfileColors.success?.dark))
    }
}

struct BusinessProfileColor: Codable, Equatable {
    let light: String?
    let dark: String?
}
