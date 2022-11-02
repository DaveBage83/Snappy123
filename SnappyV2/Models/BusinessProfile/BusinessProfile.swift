//
//  BusinessProfile.swift
//  SnappyV2
//
//  Created by Kevin Palser on 02/03/2022.
//

import Foundation
import CoreData

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

struct PostcodeRule: Codable, Equatable {
    let countryCode: String
    let regex: String
}

struct MarketingTexts: Codable, Equatable {
    let iosRemoteNotificationIntro: String?
    let remoteNotificationOrdersOnlyButton: String?
    let remoteNotificationIncludingMarketingButton: String?
    let remoteNotificationNoneButton: String?
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
    let paymentGateways: [PaymentGateway]
    let postcodeRules: [PostcodeRule]?
    let marketingText: MarketingTexts?
    
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
    let twoStar: BusinessProfileColor?
    let twoPointFiveStar: BusinessProfileColor?
    let threeStar: BusinessProfileColor?
    let threePointFiveStar: BusinessProfileColor?
    let fourStar: BusinessProfileColor?
    let fourPointFiveStar: BusinessProfileColor?
    let fiveStar: BusinessProfileColor?
    let offer: BusinessProfileColor?
    
    static func mapFromCoreData(_ businessProfileColors: BusinessProfileColorsMO?) -> BusinessProfileColors? {
        
        guard let businessProfileColors = businessProfileColors else { return nil }

        return BusinessProfileColors(
            success: BusinessProfileColor(light: businessProfileColors.success?.light, dark: businessProfileColors.success?.dark),
            warning: BusinessProfileColor(light: businessProfileColors.warning?.light, dark: businessProfileColors.warning?.dark),
            highlight: BusinessProfileColor(light: businessProfileColors.highlight?.light, dark: businessProfileColors.highlight?.dark),
            offerBasket: BusinessProfileColor(light: businessProfileColors.offerBasket?.light, dark: businessProfileColors.offerBasket?.dark),
            backgroundMain: BusinessProfileColor(light: businessProfileColors.backgroundMain?.light, dark: businessProfileColors.backgroundMain?.dark),
            modalBG: BusinessProfileColor(light: businessProfileColors.modalBG?.light, dark: businessProfileColors.modalBG?.dark),
            primaryBlue: BusinessProfileColor(light: businessProfileColors.primaryBlue?.light, dark: businessProfileColors.primaryBlue?.dark),
            primaryRed: BusinessProfileColor(light: businessProfileColors.primaryRed?.light, dark: businessProfileColors.primaryRed?.dark),
            secondaryWhite: BusinessProfileColor(light: businessProfileColors.secondaryWhite?.light, dark: businessProfileColors.secondaryWhite?.dark),
            secondaryBakery: BusinessProfileColor(light: businessProfileColors.secondaryBakery?.light, dark: businessProfileColors.secondaryBakery?.dark),
            secondaryButcher: BusinessProfileColor(light: businessProfileColors.secondaryButcher?.light, dark: businessProfileColors.secondaryButcher?.dark),
            secondaryConvenience: BusinessProfileColor(light: businessProfileColors.secondaryConvenience?.light, dark: businessProfileColors.secondaryConvenience?.dark),
            secondaryDark: BusinessProfileColor(light: businessProfileColors.secondaryDark?.light, dark: businessProfileColors.secondaryDark?.dark),
            textBlack: BusinessProfileColor(light: businessProfileColors.textBlack?.light, dark: businessProfileColors.textBlack?.dark),
            textGrey1: BusinessProfileColor(light: businessProfileColors.textGrey1?.light, dark: businessProfileColors.textGrey1?.dark),
            textGrey2: BusinessProfileColor(light: businessProfileColors.textGrey2?.light, dark: businessProfileColors.textGrey2?.dark),
            textGrey3: BusinessProfileColor(light: businessProfileColors.textGrey3?.light, dark: businessProfileColors.textGrey3?.dark),
            textGrey4: BusinessProfileColor(light: businessProfileColors.textGrey4?.light, dark: businessProfileColors.textGrey4?.dark),
            textGrey5: BusinessProfileColor(light: businessProfileColors.textGrey5?.light, dark: businessProfileColors.textGrey5?.dark),
            textGrey6: BusinessProfileColor(light: businessProfileColors.textGrey6?.light, dark: businessProfileColors.textGrey6?.dark),
            textWhite: BusinessProfileColor(light: businessProfileColors.textWhite?.light, dark: businessProfileColors.textWhite?.dark),
            twoStar: BusinessProfileColor(light: businessProfileColors.twoStar?.light, dark: businessProfileColors.textWhite?.dark),
            twoPointFiveStar: BusinessProfileColor(light: businessProfileColors.twoPointFiveStar?.light, dark: businessProfileColors.textWhite?.dark),
            threeStar: BusinessProfileColor(light: businessProfileColors.threeStar?.light, dark: businessProfileColors.textWhite?.dark),
            threePointFiveStar: BusinessProfileColor(light: businessProfileColors.threePointFiveStar?.light, dark: businessProfileColors.textWhite?.dark),
            fourStar: BusinessProfileColor(light: businessProfileColors.fourStar?.light, dark: businessProfileColors.textWhite?.dark),
            fourPointFiveStar: BusinessProfileColor(light: businessProfileColors.fourPointFiveStar?.light, dark: businessProfileColors.textWhite?.dark),
            fiveStar: BusinessProfileColor(light: businessProfileColors.fiveStar?.light, dark: businessProfileColors.textWhite?.dark),
            offer: BusinessProfileColor(light: businessProfileColors.offer?.light, dark: businessProfileColors.offer?.dark)
        )
    }
    
    func mapToCoreData(in context: NSManagedObjectContext) -> BusinessProfileColorsMO? {
        let profileColors = BusinessProfileColorsMO(context: context)
        
        profileColors.success = success?.mapToCoreData(in: context)
        profileColors.warning = warning?.mapToCoreData(in: context)
        profileColors.highlight = highlight?.mapToCoreData(in: context)
        profileColors.offerBasket = offerBasket?.mapToCoreData(in: context)
        profileColors.backgroundMain = backgroundMain?.mapToCoreData(in: context)
        profileColors.modalBG = modalBG?.mapToCoreData(in: context)
        profileColors.primaryBlue = primaryBlue?.mapToCoreData(in: context)
        profileColors.primaryRed = primaryRed?.mapToCoreData(in: context)
        profileColors.secondaryWhite = secondaryWhite?.mapToCoreData(in: context)
        profileColors.secondaryBakery = secondaryBakery?.mapToCoreData(in: context)
        profileColors.secondaryButcher = secondaryButcher?.mapToCoreData(in: context)
        profileColors.secondaryConvenience = secondaryConvenience?.mapToCoreData(in: context)
        profileColors.secondaryDark = secondaryDark?.mapToCoreData(in: context)
        profileColors.textBlack = textBlack?.mapToCoreData(in: context)
        profileColors.textGrey1 = textGrey1?.mapToCoreData(in: context)
        profileColors.textGrey2 = textGrey2?.mapToCoreData(in: context)
        profileColors.textGrey3 = textGrey3?.mapToCoreData(in: context)
        profileColors.textGrey4 = textGrey4?.mapToCoreData(in: context)
        profileColors.textGrey5 = textGrey5?.mapToCoreData(in: context)
        profileColors.textGrey6 = textGrey6?.mapToCoreData(in: context)
        profileColors.textWhite = textWhite?.mapToCoreData(in: context)
        profileColors.twoStar = twoStar?.mapToCoreData(in: context)
        profileColors.twoPointFiveStar = twoPointFiveStar?.mapToCoreData(in: context)
        profileColors.threeStar = threeStar?.mapToCoreData(in: context)
        profileColors.threePointFiveStar = threePointFiveStar?.mapToCoreData(in: context)
        profileColors.fourStar = fourStar?.mapToCoreData(in: context)
        profileColors.fourPointFiveStar = fourPointFiveStar?.mapToCoreData(in: context)
        profileColors.fiveStar = fiveStar?.mapToCoreData(in: context)
        profileColors.offer = offer?.mapToCoreData(in: context)
        
        return profileColors
    }
}

struct BusinessProfileColor: Codable, Equatable {
    let light: String?
    let dark: String?
    
    func mapToCoreData(in context: NSManagedObjectContext) -> BusinessProfileColorMO {
        let profileColor = BusinessProfileColorMO(context: context)
        
        profileColor.light = light
        profileColor.dark = dark
        
        return profileColor
    }
}
