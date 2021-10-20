//
//  StoreCardInfoViewModel.swift
//  SnappyV2
//
//  Created by Henrik Gustavii on 12/08/2021.
//

import Foundation

class StoreCardInfoViewModel: ObservableObject {
    var storeDetails: RetailStore
    
    init(storeDetails: RetailStore) {
        self.storeDetails = storeDetails
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
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = "£"

        guard let total = formatter.string(from: NSNumber(value: deliveryCharge)) else { return "" }
        return total + " delivery"
    }
}
