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
extension PostcodeRuleMO: ManagedEntity { }

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
        
        var paymentGateways: [PaymentGateway]?
        if let paymentGatewaysArray = managedObject.paymentGateways?.array as? [PaymentGatewayMO] {
            paymentGateways = paymentGatewaysArray
                .reduce(nil, { (gatewayArray, record) -> [PaymentGateway]? in
                    guard let gateway = PaymentGateway(managedObject: record) else {
                        return gatewayArray
                    }
                    var array = gatewayArray ?? []
                    array.append(gateway)
                    return array
                })
        }
        
        var postcodeRules: [PostcodeRule]?
        if let postcodeRulesArray = managedObject.postcodeRules?.array as? [PostcodeRuleMO] {
            postcodeRules = postcodeRulesArray
                .reduce(nil, { (rulesArray, record) -> [PostcodeRule]? in
                    var array = rulesArray ?? []
                    array.append(PostcodeRule(managedObject: record))
                    return array
                })
        }
        
        // if any of the texts is set then initialise the MarketingTexts struct
        var marketingText: MarketingTexts?
        if
            managedObject.iosRemoteNotificationIntro != nil ||
            managedObject.remoteNotificationOrdersOnlyButton != nil ||
            managedObject.remoteNotificationIncludingMarketingButton != nil ||
            managedObject.remoteNotificationNoneButton != nil
        {
            marketingText = MarketingTexts(
                iosRemoteNotificationIntro: managedObject.iosRemoteNotificationIntro,
                remoteNotificationOrdersOnlyButton: managedObject.remoteNotificationOrdersOnlyButton,
                remoteNotificationIncludingMarketingButton: managedObject.remoteNotificationIncludingMarketingButton,
                remoteNotificationNoneButton: managedObject.remoteNotificationNoneButton
            )
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
            paymentGateways: paymentGateways ?? [],
            postcodeRules: postcodeRules,
            marketingText: marketingText,
            fetchLocaleCode: managedObject.fetchLocaleCode,
            fetchTimestamp: managedObject.timestamp,
            colors: BusinessProfileColors.mapFromCoreData(managedObject.colors)
        )
    }
    
    @discardableResult
    func store(in context: NSManagedObjectContext) -> BusinessProfileMO? {
        
        guard let profile = BusinessProfileMO.insertNew(in: context)
            else { return nil }
        
        // Business profile colours
        profile.colors = colors?.mapToCoreData(in: context)
        
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
        profile.paymentGateways = NSOrderedSet(array: paymentGateways.compactMap({ paymentGateways -> PaymentGatewayMO? in
            return paymentGateways.store(in: context)
        }))
        if let postcodeRules = postcodeRules {
            profile.postcodeRules = NSOrderedSet(array: postcodeRules.compactMap({ postcodeRules -> PostcodeRuleMO? in
                return postcodeRules.store(in: context)
            }))
        }
        
        // Facebook object
        profile.facebookPixelId = facebook.pixelId
        profile.facebookAppId = facebook.appId
        
        // TikTock object
        profile.tikTokPixelId = tikTok.pixelId
        
        // Marketing Text
        if let marketingText = marketingText {
            profile.iosRemoteNotificationIntro = marketingText.iosRemoteNotificationIntro
            profile.remoteNotificationOrdersOnlyButton = marketingText.remoteNotificationOrdersOnlyButton
            profile.remoteNotificationIncludingMarketingButton = marketingText.remoteNotificationIncludingMarketingButton
            profile.remoteNotificationNoneButton = marketingText.remoteNotificationNoneButton
        }
        
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

extension PostcodeRule {
    
    init(managedObject: PostcodeRuleMO) {
        
        self.init(
            countryCode: managedObject.countryCode ?? "",
            regex: managedObject.regex ?? ""
        )
        
    }
    
    @discardableResult
    func store(in context: NSManagedObjectContext) -> PostcodeRuleMO? {
        
        guard let postcodeRule = PostcodeRuleMO.insertNew(in: context)
            else { return nil }

        postcodeRule.countryCode = countryCode
        postcodeRule.regex = regex
        
        return postcodeRule
    }
}
