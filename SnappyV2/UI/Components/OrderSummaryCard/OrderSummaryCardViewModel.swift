//
//  OrderSummaryCardViewModel.swift
//  SnappyV2
//
//  Created by David Bage on 01/03/2022.
//

import Foundation

class OrderSummaryCardViewModel: ObservableObject {
    #warning("This viewModel is not complete. Endpoint to retrieve past orders is not yet ready. We will not be using appState in the final version")
    let container: DIContainer
    
    let order: PastOrder

    var storeLogoURL: URL? {
        if let logo = order.store.storeLogo?[AppV2Constants.API.imageScaleFactor]?.absoluteString {
            return URL(string: logo)
        }
        return nil
    }
    
    var fulfilmentType: RetailStoreOrderMethodType {
        order.fulfilmentMethod.name
    }
    
    var orderTotal: String {
        order.totalPrice.toCurrencyString()
    }
    
    var selectedSlot: String {
        if let date = order.fulfilmentMethod.datetime.requestedDate, let time = order.fulfilmentMethod.datetime.requestedTime {
            return "\(date) | \(time)"
        }
        return "No slot"
    }
    
    var status: String {
        order.status
    }
    
    init(container: DIContainer, order: PastOrder) {
        self.container = container
        self.order = order
    }
}
