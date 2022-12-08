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
    
    var fulfilmentTime: String? {
        if container.appState.value.userData.selectedFulfilmentMethod == .delivery {
            return storeDetails.orderMethods?[RetailStoreOrderMethodType.delivery.rawValue]?.fulfilmentIn
        } else {
            return storeDetails.orderMethods?[RetailStoreOrderMethodType.collection.rawValue]?.fulfilmentIn
        }
    }
    
    var showDeliveryCost: Bool {
        container.appState.value.userData.selectedFulfilmentMethod == .delivery
    }
    
    var currency: RetailStoreCurrency? {
        storeDetails.currency
    }
    
    var minOrder: String {
        guard let orderDeliveryMethod, showDeliveryCost else { return Strings.StoresView.DeliveryTiers.noMinOrder.localized }
        
        // If there is a minSpend value in the API response, return this
        if let minSpend = orderDeliveryMethod.minSpend {
            return minSpend > 0 ? "\(GeneralStrings.min.localized) \(minSpend.toCurrencyString(using: storeDetails.currency, roundWholeNumbers: true))" : Strings.StoresView.DeliveryTiers.noMinOrder.localized
        }
        return Strings.StoresView.DeliveryTiers.noMinOrder.localized
    }
    
    var freeDeliveryText: String? {
        guard let deliveryOrderMethod = orderDeliveryMethod else { return nil }

        return deliveryOrderMethod.freeFulfilmentMessage?.isEmpty == true || showDeliveryCost == false ? nil : deliveryOrderMethod.freeFulfilmentMessage
    }
    
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
