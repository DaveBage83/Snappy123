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
    
    private func searchStore() async throws {
        guard let postcode = order.fulfilmentMethod.address?.postcode else { return }
        
        return try await container.services.retailStoresService.searchRetailStores(postcode: postcode).singleOutput()
    }
    
    private func getStoreDetails(id: Int, postCode: String) async throws {
        return try await container.services.retailStoresService.getStoreDetails(storeId: id, postcode: postCode).singleOutput()
    }
    
    private func setDeliveryAddress() async throws {
        guard let address = order.fulfilmentMethod.address,
              let firstName = address.firstName,
              let lastName = address.lastName,
              let countryCode = address.countryCode,
              let email = address.email,
              let telephone = address.telephone else {
            Logger.member.error("Unable to set delivery address: missing contact details")
            return
        }
        
        let basketAddressRequest = BasketAddressRequest(
            firstName: firstName,
            lastName: lastName,
            addressLine1: address.addressLine1,
            addressLine2: address.addressLine2 ?? "",
            town: address.town,
            postcode: address.postcode,
            countryCode: countryCode,
            type: AddressType.delivery.rawValue,
            email: email,
            telephone: telephone,
            state: nil,
            county: address.county,
            location: nil)
        
        return try await container.services.basketService.setDeliveryAddress(to: basketAddressRequest).singleOutput()
    }

    private func populateRepeatOrder() async throws {
        return try await container.services.basketService.populateRepeatOrder(businessOrderId: order.businessOrderId).singleOutput()
    }
    
    // MARK: - Tap methods
    
    // When repeat order is tapped we need to perform several operations:
    // 1- perform a store search and check that the order store is present in the results
    // 2- get the store details
    // 3 - populate the basket
    // Without all 3 of the above steps the order cannot be populated in the basket correctly as we require
    // store details and current fulfilment location to all be present
    
    func repeatOrderTapped() async throws {
        getRepeatOrderInProgress(true)
        
        guard let deliveryAddress = order.fulfilmentMethod.address else { return }
        
        do {
            try await searchStore()
            
            if let searchResult = container.appState.value.userData.searchResult.value {
                
                // Perform store search
                guard let stores = searchResult.stores, stores.count > 0 else {
                    Logger.member.error("No stores returned in search")
                    return
                }
                
                // Check if search results include the store from the order
                if stores.filter({ $0.id == order.store.id }).count > 0 {
                    
                    // If store is present in results, get the store details
                    try await getStoreDetails(id: order.store.id, postCode: deliveryAddress.postcode)
                    
                    // If delivery address set successfully, then populate the order
                    try await populateRepeatOrder()
                    
                    
                    self.getRepeatOrderInProgress(false)
                    self.container.appState.value.routing.showInitialView = false
                    self.container.appState.value.routing.selectedTab = 3
                    
                    guaranteeMainThread { // Not dismissing
                        self.showDetailsView = false
                    }
                    
                    // If store details successfully retrieved, set the delivery address
                    do {
                        try await setDeliveryAddress()
                    } catch {
                        Logger.member.error("Failed to set delivery address")
                    }
                    
                } else {
                    Logger.member.error("Store not valid")
                }
            }
        } catch {
            Logger.member.error("The store will not deliver to your location")
            self.getRepeatOrderInProgress(false)
        }
    }
    
    private func getRepeatOrderInProgress(_ inProgress: Bool) {
        guaranteeMainThread { [weak self] in
            guard let self = self else { return }
            self.repeatOrderRequested = inProgress
        }
    }
}
