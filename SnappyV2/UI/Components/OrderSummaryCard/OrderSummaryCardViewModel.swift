//
//  OrderSummaryCardViewModel.swift
//  SnappyV2
//
//  Created by David Bage on 01/03/2022.
//

import Foundation

class OrderSummaryCardViewModel: ObservableObject {
    
    // MARK: - Properties
    let container: DIContainer
    
    // MARK: - Calculated variables
    
    var storeLogoURL: URL?
    
    var fulfilmentType: RetailStoreOrderMethodType?
    
    var statusType: OrderStatus.StatusType?
    
    var orderTotal: String?
    
    var status: String?
    
    // Formatted date and time
    var selectedSlot: String?
    
    var orderProgress: Double?
    
    var storeName: String?
    
    var concatenatedAddress: String?
    
    var storeWithAddress1: String?
    
    var order: PlacedOrder?
    
    @Published var showDetailsView = false
    
    // MARK: - Init
    
    init(container: DIContainer, order: PlacedOrder?, basket: Basket?) {
        self.container = container
        self.order = order
        
        if let order = order {
            setOrderProperties(order: order)
        } else if let basket = basket {
            setBasketProperties(basket: basket)
        }
    }
    
    private func setOrderProperties(order: PlacedOrder) {
        self.fulfilmentType = order.fulfilmentMethod.name
        self.statusType = order.orderStatus.statusType
        self.orderTotal = order.totalPrice.toCurrencyString(
            using: container.appState.value.userData.selectedStore.value?.currency ?? AppV2Constants.Business.defaultStoreCurrency
        )
        self.status = order.status.capitalizingFirstLetter()
        self.orderProgress = order.orderProgress
        self.storeName = order.store.name
        self.concatenatedAddress = order.store.concatenatedAddress
        self.storeWithAddress1 = order.store.storeWithAddress1
        
        if let logo = order.store.storeLogo?[AppV2Constants.API.imageScaleFactor]?.absoluteString {
            self.storeLogoURL = URL(string: logo)
        }
        
        if let date = order.fulfilmentMethod.datetime.estimated?.dateShortString(storeTimeZone: nil), let time = order.fulfilmentMethod.datetime.estimated?.timeString(storeTimeZone: nil) {
            self.selectedSlot = "\(date) | \(time)"
        } else {
            self.selectedSlot = Strings.PlacedOrders.OrderSummaryCard.noSlotSelected.localized
        }
    }
    
    private func setBasketProperties(basket: Basket) {
        let store = container.appState.value.userData.selectedStore.value
        
        self.fulfilmentType = basket.fulfilmentMethod.type
        self.orderTotal = basket.orderTotal.toCurrencyString(
            using: container.appState.value.userData.selectedStore.value?.currency ?? AppV2Constants.Business.defaultStoreCurrency
        )
        
        if let logo = container.appState.value.userData.selectedStore.value?.storeLogo?[AppV2Constants.API.imageScaleFactor]?.absoluteString {
            self.storeLogoURL = URL(string: logo)
        }
        
        self.concatenatedAddress = store?.nameWithAddress1
        
        if let tempSlot = container.appState.value.userData.tempTodayTimeSlot {
            let time = "\(tempSlot.startTime.timeString(storeTimeZone: store?.storeTimeZone)) - \(tempSlot.endTime.timeString(storeTimeZone: store?.storeTimeZone))"
            let date = Strings.General.today.localized
            self.selectedSlot = "\(date) | \(time)"
        } else if let date = basket.selectedSlot?.start?.trueDate.dateShortString(storeTimeZone: nil), let startTime = basket.selectedSlot?.start?.timeString(storeTimeZone: store?.storeTimeZone),
                  let endTime =  basket.selectedSlot?.end?.timeString(storeTimeZone: store?.storeTimeZone) {
            let time = "\(startTime) - \(endTime)"
            self.selectedSlot = "\(date) | \(time)"
        } else {
            self.selectedSlot = Strings.PlacedOrders.OrderSummaryCard.noSlotSelected.localized
        }
        
        self.status = Strings.OrderSummaryCard.status.localized
    }
}
