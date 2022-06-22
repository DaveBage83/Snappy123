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
    
    var deliveryChargeString: String {
        guard let deliveryCharge = storeDetails.orderMethods?["delivery"]?.cost else { return "" }
        
        if deliveryCharge == 0.0 { return "Free delivery"}
        
        return deliveryCharge.toCurrencyString() + " delivery"
    }
}
