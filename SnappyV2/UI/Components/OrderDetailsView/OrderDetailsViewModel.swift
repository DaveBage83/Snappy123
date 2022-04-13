//
//  OrderDetailsViewModel.swift
//  SnappyV2
//
//  Created by David Bage on 05/04/2022.
//

import Foundation
import OSLog
import Combine

class OrderDetailsViewModel: ObservableObject {
    // MARK: - Properties
    
    // The following 2 properties are used for view model creation in parent view so cannot be private
    let container: DIContainer
    let order: PlacedOrder
    @Published var repeatOrderRequested = false
    @Published var showDetailsView = false
    
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Calculated variables
    
    var orderNumber: String {
        String(order.id)
    }
    
    var subTotal: String {
        order.totalPrice.toCurrencyString()
    }
    
    var totalToPay: String {
        order.totalToPay?.toCurrencyString() ?? ""
    }
    
    var surCharges: [PlacedOrderSurcharge] {
        return order.surcharges ?? []
    }
    
    var deliveryCostApplicable: Bool {
        order.fulfilmentMethod.deliveryCost != nil && order.fulfilmentMethod.deliveryCost != 0
    }
    
    var driverTipPresent: Bool {
        order.fulfilmentMethod.driverTip != nil
    }
    
    // In order to get total number of items in the order, we need to take the total from each
    // orderLine and add together
    var numberOfItems: String {
        var items = [Int]()
        
        order.orderLines.forEach { line in
            items.append(line.quantity)
        }
        
        let orderCount = items.reduce(0, +)
        
        // Show 'item' in singular or plural depending on number of items
        let itemString = orderCount == 1 ? GeneralStrings.item.localized: GeneralStrings.items.localized
        
        return String("\(orderCount) \(itemString)")
    }
    
    var fulfilmentMethod: String {
        switch order.fulfilmentMethod.name {
        case .delivery:
            return GeneralStrings.delivery.localized
        case .collection:
            return GeneralStrings.collection.localized
        case .table:
            return GeneralStrings.table.localized // Should not be needed in Snappy context
        case .room:
            return GeneralStrings.room.localized // Should not be needed in Snappy context
        }
    }
    
    // MARK: - Init
    
    init(container: DIContainer, order: PlacedOrder) {
        self.container = container
        self.order = order
    }
    
    // MARK: - Repeat order methods
    
    // 1- Get store details: when successful this sets the selected store in the appState
    
    private func getStoreDetails() {
        container.services.retailStoresService.getStoreDetails(storeId: order.store.id, postcode: order.store.postcode)
            .print()
            .sink { [weak self] completion in
                guard let self = self else { return }
                
                switch completion {
                case .finished:
                    Logger.member.log("Successfully retrieved store details and saved to appState")
                case .failure(let err):
                    Logger.member.error("Failed to retrieve store details and / or save to appState: \(err.localizedDescription)")
                    self.getRepeatOrderInProgress(false)
                }
            } receiveValue: { [weak self] _ in
                guard let self = self else { return }
                // Once store successfully selected in the appState we can move on to store search
                self.searchStore()
            }
            .store(in: &cancellables)
    }
    
    // 2- Search store: in order to populate the basket with the current order, we need to have the
    // fulfilment location selected
    
    private func searchStore() {
        container.services.retailStoresService.searchRetailStores(postcode: order.store.postcode)
            .sink { [weak self] completion in
                guard let self = self else { return }
                
                switch completion {
                case .finished:
                    Logger.member.log("Successfully completed store search")
                case .failure(let err):
                    Logger.member.error("Failed to complete store search: \(err.localizedDescription)")
                    self.getRepeatOrderInProgress(false)
                }
            } receiveValue: { [weak self] _ in
                guard let self = self else { return }
                // We direct the user to the basket tab
                self.container.appState.value.routing.selectedTab = 3
                // Once the store search is complete we are ready to populate the order
                self.populateRepeatOrder()
            }
            .store(in: &cancellables)
    }
    
    // 3- Populate repeat order: now we have the store details selected, we have all we need to populate
    // the basket with the repeat order

    private func populateRepeatOrder() {
        container.services.basketService.populateRepeatOrder(businessOrderId: order.businessOrderId)
            .receive(on: RunLoop.main)
            .sink { [weak self] completion in
                guard let self = self else { return }
                switch completion {
                case .failure(let err):
                    Logger.basket.error("Failed to populate repeat order: \(err.localizedDescription)")
                    self.getRepeatOrderInProgress(false)
                case .finished:
                    Logger.basket.log("Successfully populated repeat order")
                    self.getRepeatOrderInProgress(false)
                    self.container.appState.value.routing.showInitialView = false
                    self.showDetailsView = false
                }
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Tap methods
    
    // When repeat order is tapped we need to perform several operations:
    // 1- get the current store details
    // 2- search for a store
    // 3 - populate the basket
    // Without all 3 of the above steps the order cannot be populated in the basket correctly as we require
    // store details and current fulfilment location to all be present
    
    func repeatOrderTapped() {
        getRepeatOrderInProgress(true)
        getStoreDetails()
    }
    
    private func getRepeatOrderInProgress(_ inProgress: Bool) {
        repeatOrderRequested = inProgress
    }
}
