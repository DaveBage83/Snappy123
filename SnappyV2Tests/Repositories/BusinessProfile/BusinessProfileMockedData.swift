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
        fetchLocaleCode: nil,
        fetchTimestamp: nil,
        colors: nil
    )
    
    var recordsCount: Int {
        return 1 + tipLimitLevels.count
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
