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

    @Published var selectedDeliveryTierInfo: DeliveryTierInfo?
    
    let currency: RetailStoreCurrency?
    
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

    var freeFrom: Double? {
        guard let freeFrom = deliveryTierInfo.orderMethod?.freeFrom, freeFrom > 0 else { return nil }
        return freeFrom
    }
    
    var deliveryBannerText: String? {
        guard let currency = deliveryTierInfo.currency else { return nil }

        if let freeFulfilmentMessage, freeFulfilmentMessage.isEmpty == false {
            return freeFulfilmentMessage
        } else if let freeFrom = freeFrom, freeFrom != 0, deliveryTierInfo.orderMethod?.deliveryTiers == nil {
            return Strings.StoresView.DeliveryTiersCustom.freeFrom.localizedFormat(freeFrom.toCurrencyString(using: currency))
        } else if let freeFrom = freeFrom, freeFrom != 0, let tiers = deliveryTierInfo.orderMethod?.deliveryTiers, tiers.isEmpty {
            return Strings.StoresView.DeliveryTiersCustom.freeFrom.localizedFormat(freeFrom.toCurrencyString(using: currency))
        } else if deliveryTierInfo.orderMethod?.deliveryTiers != nil, deliveryTierInfo.orderMethod?.deliveryTiers?.isEmpty == false {
            return deliveryTierInfo.orderMethod?.fromDeliveryCost(currency: currency)?.text
        }
        
        return nil
    }

    var hasTiers: Bool {
        guard let tiers = deliveryTierInfo.orderMethod?.deliveryTiers, tiers.count > 0 else { return false }
        return true
    }

    var isDisabled: Bool {
        !hasTiers
    }
    
    var showDeliveryBanner: Bool {
        deliveryBannerText != nil
    }
        
    init(container: DIContainer, deliveryTierInfo: DeliveryTierInfo, currency: RetailStoreCurrency?, fromBasket: Bool) {
        self.deliveryTierInfo = deliveryTierInfo
        self.fromBasket = fromBasket
        self.currency = currency
        self.container = container
    }
    
    func setOrderMethod(_ orderMethod: RetailStoreOrderMethod) {
        self.selectedDeliveryTierInfo = .init(orderMethod: orderMethod, currency: currency)
    }
}
