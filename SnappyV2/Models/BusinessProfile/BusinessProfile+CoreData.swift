//
//  BusinessProfile+CoreData.swift
//  SnappyV2
//
//  Created by Kevin Palser on 02/03/2022.
//

import Foundation
import CoreData

extension BusinessProfileMO: ManagedEntity { }
extension TipLimitLevelMO: ManagedEntity { }

extension BusinessProfile {
    
    init(managedObject: BusinessProfileMO) {
        
        var tipLimitLevels: [TipLimitLevel]
        if
            let managedTipLevels = managedObject.tipLimitLevels,
            let managedTipLevelsArray = managedTipLevels.array as? [TipLimitLevelMO]
        {
            tipLimitLevels = managedTipLevelsArray
                .reduce([], { (tipsArray, record) -> [TipLimitLevel] in
                    var array = tipsArray
                    array.append(TipLimitLevel(managedObject: record))
                    return array
                })
        } else {
            tipLimitLevels = []
        }
        
        var mentionMeEnabled: Bool?
        if let mentionMeEnabledNumber = managedObject.mentionMeEnabled {
            mentionMeEnabled = mentionMeEnabledNumber.boolValue
        }
        
        var checkoutTimeoutSeconds: Int?
        if let checkoutTimeoutSecondsNumber = managedObject.checkoutTimeoutSeconds {
            checkoutTimeoutSeconds = checkoutTimeoutSecondsNumber.intValue
        }
        
        self.init(
            id: Int(managedObject.id),
            checkoutTimeoutSeconds: checkoutTimeoutSeconds,
            minOrdersForAppReview: Int(managedObject.minOrdersForAppReview),
            privacyPolicyLink: managedObject.privacyPolicyLink,
            pusherClusterServer: managedObject.pusherClusterServer,
            pusherAppKey: managedObject.pusherAppKey,
            mentionMeEnabled: mentionMeEnabled,
            iterableMobileApiKey: managedObject.iterableMobileApiKey,
            useDeliveryFirms: managedObject.useDeliveryFirms,
            driverTipIncrement: managedObject.driverTipIncrement,
            tipLimitLevels: tipLimitLevels,
            facebook: FacebookSetting(
                pixelId: managedObject.facebookPixelId ?? "",
                appId: managedObject.facebookAppId ?? ""
            ),
            tikTok: TikTokSetting(pixelId: managedObject.tikTokPixelId ?? ""),
            fetchLocaleCode: managedObject.fetchLocaleCode,
            fetchTimestamp: managedObject.timestamp
        )
        
    }
    
    @discardableResult
    func store(in context: NSManagedObjectContext) -> BusinessProfileMO? {
        
        guard let profile = BusinessProfileMO.insertNew(in: context)
            else { return nil }
        
        profile.tipLimitLevels = NSOrderedSet(array: tipLimitLevels.compactMap({ tipLevel -> TipLimitLevelMO? in
            return tipLevel.store(in: context)
        }))

        profile.id = Int64(id)
        if let checkoutTimeoutSeconds = checkoutTimeoutSeconds {
            profile.checkoutTimeoutSeconds = NSNumber(value: checkoutTimeoutSeconds)
        }
        profile.minOrdersForAppReview = Int16(minOrdersForAppReview)
        profile.privacyPolicyLink = privacyPolicyLink
        profile.pusherClusterServer = pusherClusterServer
        profile.pusherAppKey = pusherAppKey
        if let mentionMeEnabled = mentionMeEnabled {
            profile.mentionMeEnabled = NSNumber(value: mentionMeEnabled)
        }
        profile.iterableMobileApiKey = iterableMobileApiKey
        profile.useDeliveryFirms = useDeliveryFirms
        profile.driverTipIncrement = driverTipIncrement
        
        // Facebook object
        profile.facebookPixelId = facebook.pixelId
        profile.facebookAppId = facebook.appId
        
        // TikTock object
        profile.tikTokPixelId = tikTok.pixelId
        
        profile.fetchLocaleCode = fetchLocaleCode
        profile.timestamp = Date().trueDate
        
        return profile
    }
}

extension TipLimitLevel {
    
    init(managedObject: TipLimitLevelMO) {
        
        self.init(
            level: Int(managedObject.level),
            amount: managedObject.amount,
            type: managedObject.type ?? "",
            title: managedObject.title ?? ""
        )
        
    }
    
    @discardableResult
    func store(in context: NSManagedObjectContext) -> TipLimitLevelMO? {
        
        guard let tipLevel = TipLimitLevelMO.insertNew(in: context)
            else { return nil }

        tipLevel.level = Int64(level)
        tipLevel.amount = amount
        tipLevel.title = title
        tipLevel.type = type
        
        return tipLevel
    }
}
