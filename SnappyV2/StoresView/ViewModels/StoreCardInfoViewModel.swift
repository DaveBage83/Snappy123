//
//  StoreCardInfoViewModel.swift
//  SnappyV2
//
//  Created by Henrik Gustavii on 12/08/2021.
//

import Foundation

class StoreCardInfoViewModel: ObservableObject {
    var storeDetails: StoreCardDetails
    
    init(storeDetails: StoreCardDetails) {
        self.storeDetails = storeDetails
    }
    
    var distance: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        
        let total = Double(storeDetails.distaceToDeliver)
        return formatter.string(from: NSNumber(value: total)) ?? ""
    }
    
    var deliveryChargeString: String {
        guard let deliveryCharge = storeDetails.deliveryCharge else { return "Free delivery" }
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = "£"
        
        let total = Double(deliveryCharge)
        return formatter.string(from: NSNumber(value: total)) ?? ""
    }
}
