//
//  RetailStoreDeliveryTiersViewModel.swift
//  SnappyV2
//
//  Created by David Bage on 18/10/2022.
//

import Foundation
import Combine

struct DeliveryTiers {
    let minSpend: Double?
    let deliveryTiers: [DeliveryTier]
}

class RetailStoreDeliveryTiersViewModel: ObservableObject {
    typealias CustomTiersString = Strings.StoresView.DeliveryTiersCustom
    
    @Published var deliveryOrderMethod: RetailStoreOrderMethod?
    
    let container: DIContainer
    let currency: RetailStoreCurrency?
    
    var minSpend: String? {
        guard let minSpend = deliveryTiers?.minSpend, minSpend > 0 else { return nil }
        
        if let currency = currency {
            return CustomTiersString.minSpend.localizedFormat(minSpend.toCurrencyString(using: currency))
        }
        return CustomTiersString.minSpend.localizedFormat(minSpend.toCurrencyString())
    }
    
    // Because of the way the delivery fee is split between several unlinked values in the API response,
    // we need front end logic to build the tiers coherantly ourselves
    var deliveryTiers: DeliveryTiers? {
        guard let deliveryTiers = deliveryOrderMethod?.deliveryTiers,
              let lowestDeliveryThreshold = deliveryTiers.min(by: { $0.minBasketSpend < $1.minBasketSpend })?.minBasketSpend
        else { return nil }
        
        var tiers = deliveryTiers
        
        // If there is a minSpend value and a default delivery cost, and the lowest delivery threshold
        // within the deliveryTiers response does not equal the minSpend value, we create an additional
        // tier starting from the minSpend value
        if let minSpend = minSpendValue, let defaultDeliveryCost = defaultDeliveryCost, lowestDeliveryThreshold != minSpend {
            tiers.insert(.init(minBasketSpend: minSpend, deliveryFee: defaultDeliveryCost), at: 0)
            
            // Otherwise, if there is a default delivery cost and the lowest threshold in the delivery tiers object
            // is greater than 0 AND there is no minSpend, then we create an additional delivery tier from 0
        } else if let defaultDeliveryCost = defaultDeliveryCost, lowestDeliveryThreshold > 0, minSpendValue == nil {
            tiers.insert(.init(minBasketSpend: 0, deliveryFee: defaultDeliveryCost), at: 0)
        }
        
        return .init(
            minSpend: minSpendValue,
            deliveryTiers: tiers)
    }
    
    var minSpendValue: Double? {
        deliveryOrderMethod?.minSpend
    }
    
    var defaultDeliveryCost: Double? {
        guard let deliveryOrderMethod = deliveryOrderMethod else { return nil }
        
        return deliveryOrderMethod.cost
    }
    
    init(container: DIContainer, deliveryOrderMethod: RetailStoreOrderMethod?, currency: RetailStoreCurrency?) {
        self.container = container
        self.deliveryOrderMethod = deliveryOrderMethod
        self.currency = currency
    }
}
