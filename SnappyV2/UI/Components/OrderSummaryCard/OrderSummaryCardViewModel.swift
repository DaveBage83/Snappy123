//
//  OrderSummaryCardViewModel.swift
//  SnappyV2
//
//  Created by David Bage on 01/03/2022.
//

import Foundation

class OrderSummaryCardViewModel: ObservableObject {
    
    // MARK: - Properties
    
    // These 2 properties are used to build view models in their parent view and so cannot be private
    let container: DIContainer
    let order: PlacedOrder
    
    // MARK: - Calculated variables
    
    var storeLogoURL: URL? {
        if let logo = order.store.storeLogo?[AppV2Constants.API.imageScaleFactor]?.absoluteString {
            return URL(string: logo)
        }
        return nil
    }
    
    var fulfilmentType: RetailStoreOrderMethodType {
        order.fulfilmentMethod.name
    }
    
    var statusType: OrderStatus.StatusType {
        order.orderStatus.statusType
    }
    
    var orderTotal: String {
        order.totalPrice.toCurrencyString()
    }
    
    var status: String {
        order.status
    }
    
    // Formatted date and time
    var selectedSlot: String {
        if let date = order.fulfilmentMethod.datetime.estimated?.dateShortString(storeTimeZone: nil), let time = order.fulfilmentMethod.datetime.requestedTime {
            return "\(date) | \(time)"
        }
        return Strings.PlacedOrders.OrderSummaryCard.noSlotSelected.localized
    }
    
    // MARK: - Init
    
    init(container: DIContainer, order: PlacedOrder) {
        self.container = container
        self.order = order
    }
}
