//
//  BusinessProfileMockedData.swift
//  SnappyV2Tests
//
//  Created by Kevin Palser on 02/03/2022.
//

import Foundation
@testable import SnappyV2

extension BusinessProfile {

    static let mockedDataFromAPI = BusinessProfile(
        id: 15,
        checkoutTimeoutSeconds: 900,
        minOrdersForAppReview: 2,
        privacyPolicyLink: URL(string: "http://www.privacy.hungrrr.co.uk/shop/privacy-policy/?id=214"),
        pusherClusterServer: "",
        pusherAppKey: "",
        mentionMeEnabled: false,
        iterableMobileApiKey: nil,
        useDeliveryFirms: false,
        driverTipIncrement: 0.25,
        tipLimitLevels: TipLimitLevel.mockedDataArray,
        facebook: FacebookSetting.mockedData,
        tikTok: TikTokSetting.mockedData,
        paymentGateways: [
            PaymentGateway.mockedCheckoutcomData,
            PaymentGateway.mockedWorldpayData
        ],
        fetchLocaleCode: nil,
        fetchTimestamp: nil,
        colors: nil,
        marketingText: nil
    )
    
    static let mockedDataFromAPIWithColors = BusinessProfile(
        id: 15,
        checkoutTimeoutSeconds: 900,
        minOrdersForAppReview: 2,
        privacyPolicyLink: URL(string: "http://www.privacy.hungrrr.co.uk/shop/privacy-policy/?id=214"),
        pusherClusterServer: "",
        pusherAppKey: "",
        mentionMeEnabled: false,
        iterableMobileApiKey: nil,
        useDeliveryFirms: false,
        driverTipIncrement: 0.25,
        tipLimitLevels: TipLimitLevel.mockedDataArray,
        facebook: FacebookSetting.mockedData,
        tikTok: TikTokSetting.mockedData,
        paymentGateways: [
            PaymentGateway.mockedCheckoutcomData,
            PaymentGateway.mockedWorldpayData
        ],
        fetchLocaleCode: nil,
        fetchTimestamp: nil,
        colors: mockedBusinessProfileColors,
        marketingText: nil
    )
    
    static let mockedDataFromAPIWithColorsWithoutDarkVariants = BusinessProfile(
        id: 15,
        checkoutTimeoutSeconds: 900,
        minOrdersForAppReview: 2,
        privacyPolicyLink: URL(string: "http://www.privacy.hungrrr.co.uk/shop/privacy-policy/?id=214"),
        pusherClusterServer: "",
        pusherAppKey: "",
        mentionMeEnabled: false,
        iterableMobileApiKey: nil,
        useDeliveryFirms: false,
        driverTipIncrement: 0.25,
        tipLimitLevels: TipLimitLevel.mockedDataArray,
        facebook: FacebookSetting.mockedData,
        tikTok: TikTokSetting.mockedData,
        paymentGateways: [
            PaymentGateway.mockedCheckoutcomData,
            PaymentGateway.mockedWorldpayData
        ],
        fetchLocaleCode: nil,
        fetchTimestamp: nil,
        colors: mockedBusinessProfileColorsWithoutDarkVariants,
        marketingText: nil
    )
    
    static let mockedDataFromAPIWithColorsInvalidHexValues = BusinessProfile(
        id: 15,
        checkoutTimeoutSeconds: 900,
        minOrdersForAppReview: 2,
        privacyPolicyLink: URL(string: "http://www.privacy.hungrrr.co.uk/shop/privacy-policy/?id=214"),
        pusherClusterServer: "",
        pusherAppKey: "",
        mentionMeEnabled: false,
        iterableMobileApiKey: nil,
        useDeliveryFirms: false,
        driverTipIncrement: 0.25,
        tipLimitLevels: TipLimitLevel.mockedDataArray,
        facebook: FacebookSetting.mockedData,
        tikTok: TikTokSetting.mockedData,
        paymentGateways: [
            PaymentGateway.mockedCheckoutcomData,
            PaymentGateway.mockedWorldpayData
        ],
        fetchLocaleCode: nil,
        fetchTimestamp: nil,
        colors: mockedBusinessProfileColorsInvalidHexValues,
        marketingText: nil
    )
    
    static let mockedBusinessProfileColors = BusinessProfileColors(
        success: BusinessProfileColor(light: "#eb4031", dark: "#eb3471"),
        warning: BusinessProfileColor(light: "#eb4032", dark: "#eb3472"),
        highlight: BusinessProfileColor(light: "#eb4033", dark: "#eb3473"),
        offerBasket: BusinessProfileColor(light: "#eb4034", dark: "#eb3474"),
        backgroundMain: BusinessProfileColor(light: "#eb4035", dark: "#eb3475"),
        modalBG: BusinessProfileColor(light: "#eb4036", dark: "#eb3476"),
        primaryBlue: BusinessProfileColor(light: "#eb4037", dark: "#eb3477"),
        primaryRed: BusinessProfileColor(light: "#eb4038", dark: "#eb3478"),
        secondaryWhite: BusinessProfileColor(light: "#eb4039", dark: "#eb3479"),
        secondaryBakery: BusinessProfileColor(light: "#eb4041", dark: "#eb3480"),
        secondaryButcher: BusinessProfileColor(light: "#eb4042", dark: "#eb3481"),
        secondaryConvenience: BusinessProfileColor(light: "#eb4043", dark: "#eb3482"),
        secondaryDark: BusinessProfileColor(light: "#eb4044", dark: "#eb3483"),
        textBlack: BusinessProfileColor(light: "#eb4045", dark: "#eb3484"),
        textGrey1: BusinessProfileColor(light: "#eb4046", dark: "#eb3485"),
        textGrey2: BusinessProfileColor(light: "#eb4047", dark: "#eb3486"),
        textGrey3: BusinessProfileColor(light: "#eb4048", dark: "#eb3487"),
        textGrey4: BusinessProfileColor(light: "#eb4049", dark: "#eb3488"),
        textGrey5: BusinessProfileColor(light: "#eb4051", dark: "#eb3489"),
        textGrey6: BusinessProfileColor(light: "#eb4052", dark: "#eb3490"),
        textWhite: BusinessProfileColor(light: "#eb4053", dark: "#eb3491"),
        twoStar: BusinessProfileColor(light: "#eb4053", dark: "#eb3491"),
        twoPointFiveStar: BusinessProfileColor(light: "#eb4053", dark: "#eb3491"),
        threeStar: BusinessProfileColor(light: "#eb4053", dark: "#eb3491"),
        threePointFiveStar: BusinessProfileColor(light: "#eb4053", dark: "#eb3491"),
        fourStar: BusinessProfileColor(light: "#eb4053", dark: "#eb3491"),
        fourPointFiveStar: BusinessProfileColor(light: "#eb4053", dark: "#eb3491"),
        fiveStar: BusinessProfileColor(light: "#eb4053", dark: "#eb3491"),
        offer: BusinessProfileColor(light: "#eb4053", dark: "#eb3491")
    )
    
    static let mockedBusinessProfileColorsWithoutDarkVariants = BusinessProfileColors(
        success: BusinessProfileColor(light: "#eb4031", dark: nil),
        warning: BusinessProfileColor(light: "#eb4032", dark: nil),
        highlight: BusinessProfileColor(light: "#eb4033", dark: nil),
        offerBasket: BusinessProfileColor(light: "#eb4034", dark: nil),
        backgroundMain: BusinessProfileColor(light: "#eb4035", dark: nil),
        modalBG: BusinessProfileColor(light: "#eb4036", dark: nil),
        primaryBlue: BusinessProfileColor(light: "#eb4037", dark: nil),
        primaryRed: BusinessProfileColor(light: "#eb4038", dark: nil),
        secondaryWhite: BusinessProfileColor(light: "#eb4039", dark: nil),
        secondaryBakery: BusinessProfileColor(light: "#eb4041", dark: nil),
        secondaryButcher: BusinessProfileColor(light: "#eb4042", dark: nil),
        secondaryConvenience: BusinessProfileColor(light: "#eb4043", dark: nil),
        secondaryDark: BusinessProfileColor(light: "#eb4044", dark: nil),
        textBlack: BusinessProfileColor(light: "#eb4045", dark: nil),
        textGrey1: BusinessProfileColor(light: "#eb4046", dark: nil),
        textGrey2: BusinessProfileColor(light: "#eb4047", dark: nil),
        textGrey3: BusinessProfileColor(light: "#eb4048", dark: nil),
        textGrey4: BusinessProfileColor(light: "#eb4049", dark: nil),
        textGrey5: BusinessProfileColor(light: "#eb4051", dark: nil),
        textGrey6: BusinessProfileColor(light: "#eb4052", dark: nil),
        textWhite: BusinessProfileColor(light: "#eb4053", dark: nil),
        twoStar: BusinessProfileColor(light: "#eb4053", dark: nil),
        twoPointFiveStar: BusinessProfileColor(light: "#eb4053", dark: nil),
        threeStar: BusinessProfileColor(light: "#eb4053", dark: nil),
        threePointFiveStar: BusinessProfileColor(light: "#eb4053", dark: nil),
        fourStar: BusinessProfileColor(light: "#eb4053", dark: nil),
        fourPointFiveStar: BusinessProfileColor(light: "#eb4053", dark: nil),
        fiveStar: BusinessProfileColor(light: "#eb4053", dark: nil),
        offer: BusinessProfileColor(light: "#eb4053", dark: nil)
    )
    
    static let mockedBusinessProfileColorsInvalidHexValues = BusinessProfileColors(
        success: BusinessProfileColor(light: "#eb40", dark: nil),
        warning: BusinessProfileColor(light: "#eb40", dark: nil),
        highlight: BusinessProfileColor(light: "#eb40", dark: nil),
        offerBasket: BusinessProfileColor(light: "#eb40", dark: nil),
        backgroundMain: BusinessProfileColor(light: "#eb40", dark: nil),
        modalBG: BusinessProfileColor(light: "#eb40", dark: nil),
        primaryBlue: BusinessProfileColor(light: "#eb40", dark: nil),
        primaryRed: BusinessProfileColor(light: "#eb40", dark: nil),
        secondaryWhite: BusinessProfileColor(light: "#eb40", dark: nil),
        secondaryBakery: BusinessProfileColor(light: "#eb40", dark: nil),
        secondaryButcher: BusinessProfileColor(light: "#eb40", dark: nil),
        secondaryConvenience: BusinessProfileColor(light: "#eb40", dark: nil),
        secondaryDark: BusinessProfileColor(light: "#eb40", dark: nil),
        textBlack: BusinessProfileColor(light: "#eb40", dark: nil),
        textGrey1: BusinessProfileColor(light: "#eb40", dark: nil),
        textGrey2: BusinessProfileColor(light: "#eb40", dark: nil),
        textGrey3: BusinessProfileColor(light: "#eb40", dark: nil),
        textGrey4: BusinessProfileColor(light: "#eb40", dark: nil),
        textGrey5: BusinessProfileColor(light: "#eb40", dark: nil),
        textGrey6: BusinessProfileColor(light: "#eb40", dark: nil),
        textWhite: BusinessProfileColor(light: "#eb40", dark: nil),
        twoStar: BusinessProfileColor(light: "#eb4053", dark: nil),
        twoPointFiveStar: BusinessProfileColor(light: "#eb4053", dark: nil),
        threeStar: BusinessProfileColor(light: "#eb4053", dark: nil),
        threePointFiveStar: BusinessProfileColor(light: "#eb4053", dark: nil),
        fourStar: BusinessProfileColor(light: "#eb4053", dark: nil),
        fourPointFiveStar: BusinessProfileColor(light: "#eb4053", dark: nil),
        fiveStar: BusinessProfileColor(light: "#eb4053", dark: nil),
        offer: BusinessProfileColor(light: "#eb4053", dark: nil)
    )
    
    var recordsCount: Int {
        
        var count = 1
        
        for paymentGateway in paymentGateways {
            count += paymentGateway.recordsCount
        }
        
        return count + tipLimitLevels.count + (colors != nil ? 30 : 0)
    }
}

extension TipLimitLevel {
    
    static let mockedDataArray: [TipLimitLevel] = [
        TipLimitLevel(level: 1, amount: 0.5, type: "driver", title: "neutral"),
        TipLimitLevel(level: 2, amount: 1.0, type: "driver", title: "happy"),
        TipLimitLevel(level: 2, amount: 1.5, type: "driver", title: "very happy"),
        TipLimitLevel(level: 2, amount: 2.0, type: "driver", title: "insanely happy")
    ]
    
}

extension FacebookSetting {
    
    static let mockedData = FacebookSetting(pixelId: "0", appId: "")
    
}

extension TikTokSetting {
    
    static let mockedData = TikTokSetting(pixelId: "")
    
}
