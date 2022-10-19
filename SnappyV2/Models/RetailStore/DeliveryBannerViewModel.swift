//
//  DeliveryBannerViewModel.swift
//  SnappyV2
//
//  Created by David Bage on 18/10/2022.
//

import Foundation

class DeliveryOfferBannerViewModel: ObservableObject {
    let container: DIContainer
    let deliveryTierInfo: DeliveryTierInfo

    @Published var deliveryOrderMethod: RetailStoreOrderMethod?
    
    let fromBasket: Bool
    
    var bannerType: BannerType {
        if fromBasket {
            return hasTiers ? .deliveryOfferWithTiers : .deliveryOffer
        }
        
        return hasTiers ? .deliveryOfferWithTiersMain : .deliveryOfferMain
    }
    
    var freeFulfilmentMessage: String? {
        guard let text = deliveryTierInfo.orderMethod?.freeFulfilmentMessage, !text.isEmpty else { return nil }
        return text
    }
    
    var lowestTierDeliveryCost: Double? {
        guard let deliveryTiers =  deliveryTierInfo.orderMethod?.deliveryTiers else { return nil }
        
        // Get the lowest delivery cost in the tier array
        if let lowestCost = deliveryTiers.min(by: { $0.deliveryFee < $1.deliveryFee })?.deliveryFee {
            return lowestCost
        }
        
        return nil
    }
    
    var freeFrom: Double? {
        guard let freeFrom = deliveryTierInfo.orderMethod?.freeFrom, freeFrom > 0 else { return nil }
        return freeFrom
    }
    
    var deliveryBannerText: String? {
        guard let currency = deliveryTierInfo.currency else { return nil }

        if let freeFulfilmentMessage, freeFulfilmentMessage.isEmpty == false {
            return freeFulfilmentMessage
        } else if let freeFrom = freeFrom, deliveryTierInfo.orderMethod?.deliveryTiers == nil {
            return "Free delivery from \(freeFrom.toCurrencyString(using: currency))"
        } else if let freeFrom = freeFrom, let tiers = deliveryTierInfo.orderMethod?.deliveryTiers, tiers.isEmpty {
            return "Free delivery from \(freeFrom.toCurrencyString(using: currency))"
        } else if deliveryTierInfo.orderMethod?.deliveryTiers != nil {
            return deliveryTierInfo.orderMethod?.fromDeliveryCost(currency: currency)
        }
        
        return nil
    }

    var hasTiers: Bool {
        guard let tiers =  deliveryTierInfo.orderMethod?.deliveryTiers, tiers.count > 0 else { return false }
        return true
    }

    var isDisabled: Bool {
        if let orderMethod =  deliveryTierInfo.orderMethod, let tiers = orderMethod.deliveryTiers, tiers.isEmpty == false {
            return false
        }
        return true
    }
    
    var showDeliveryBanner: Bool {
        deliveryBannerText != nil
    }
        
    init(container: DIContainer, deliveryTierInfo: DeliveryTierInfo, fromBasket: Bool) {
        self.container = container
        self.deliveryTierInfo = deliveryTierInfo
        self.fromBasket = fromBasket
    }
    
    func setOrderMethod(_ orderMethod: RetailStoreOrderMethod) {
        self.deliveryOrderMethod = orderMethod
    }
}
