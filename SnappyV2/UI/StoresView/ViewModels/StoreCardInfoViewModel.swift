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
        
        let total = storeDetails.distance
        return formatter.string(from: NSNumber(value: total)) ?? ""
    }
    
    var deliveryChargeString: String {
//        guard let deliveryCharge = storeDetails.deliveryCharge else { return "Free delivery" }
        
//        let formatter = NumberFormatter()
//        formatter.numberStyle = .currency
//        formatter.currencySymbol = "£"
//
//        let total = Double(deliveryCharge)
//        return formatter.string(from: NSNumber(value: total)) ?? ""
        
        return "Free delivery"
    }
}
