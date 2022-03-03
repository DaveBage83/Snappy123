//
//  StoreCardInfoViewModel.swift
//  SnappyV2
//
//  Created by Henrik Gustavii on 12/08/2021.
//

import Foundation

class StoreCardInfoViewModel: ObservableObject {
    var storeDetails: RetailStore
    let container: DIContainer
    
    init(container: DIContainer, storeDetails: RetailStore) {
        self.storeDetails = storeDetails
        self.container = container
    }
    
    var distance: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 2
        
        let total = storeDetails.distance
        return formatter.string(from: NSNumber(value: total)) ?? ""
    }
    
    var deliveryChargeString: String {
        guard let deliveryCharge = storeDetails.orderMethods?["delivery"]?.cost else { return "" }
        
        if deliveryCharge == 0.0 { return "Free delivery"}
        
        return deliveryCharge.toCurrencyString() + " delivery"
    }
}
