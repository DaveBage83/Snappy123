//
//  StoreCardInfoViewModel.swift
//  SnappyV2
//
//  Created by Henrik Gustavii on 12/08/2021.
//

import Foundation

class StoreCardInfoViewModel: ObservableObject {
    let container: DIContainer
    var storeDetails: RetailStore
    let isClosed: Bool
    
    var orderDeliveryMethod: RetailStoreOrderMethod? {
        storeDetails.orderMethods?[RetailStoreOrderMethodType.delivery.rawValue]
    }
    
    var currency: RetailStoreCurrency? {
        storeDetails.currency
    }
    
    var defaultDeliveryCost: Double? {
        guard let deliveryOrderMethod = orderDeliveryMethod else { return nil }

        return deliveryOrderMethod.cost
    }
    
//    var fromDeliveryCost: String? {
//        guard let deliveryMethod = orderDeliveryMethod else { return nil }
//        
//        if let lowestTierDeliveryCost = deliveryMethod.lowestTierDeliveryCost {
//            if let cost = defaultDeliveryCost, lowestTierDeliveryCost > cost, (deliveryMethod.minSpend == nil || deliveryMethod.minSpend == 0)  {
//                return cost == 0 ? "Free delivery" : "From \(cost.toCurrencyString(using: storeDetails.currency)) delivery"
//            }
//            return "From \(lowestTierDeliveryCost.toCurrencyString(using: storeDetails.currency)) delivery"
//            
//        } else if let cost = defaultDeliveryCost {
//            return cost == 0 ? "Free delivery" : cost.toCurrencyString(using: storeDetails.currency)
//        }
//        return nil
//    }
    
    init(container: DIContainer, storeDetails: RetailStore, isClosed: Bool = false) {
        self.container = container
        self.storeDetails = storeDetails
        self.isClosed = isClosed
    }
    
    var distance: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 2
        
        let total = storeDetails.distance
        return formatter.string(from: NSNumber(value: total)) ?? ""
    }
}
