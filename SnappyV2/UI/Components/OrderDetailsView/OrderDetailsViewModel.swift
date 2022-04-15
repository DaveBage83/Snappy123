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
    typealias ErrorStrings = Strings.PlacedOrders.Errors
    
    
    enum OrderDetailsError: Swift.Error {
        case noDeliveryAddressOnOrder
        case noMatchingStoreFound
        case noStoreFound
        case failedToSetDeliveryAddress

        var errorDescription: String? {
            switch self {
            case .noDeliveryAddressOnOrder:
                return ErrorStrings.noDeliveryAddressOnOrder.localized
            case .noMatchingStoreFound:
                return ErrorStrings.noMatchingStoreFound.localized
            case .noStoreFound:
                return ErrorStrings.noStoreFound.localized
            case .failedToSetDeliveryAddress:
                return ErrorStrings.failedToSetDeliveryAddress.localized
            }
        }
    }
    
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
        guard let deliveryCost = order.fulfilmentMethod.deliveryCost else { return false }
        return deliveryCost > 0
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
        
        try await container.services.retailStoresService.searchRetailStores(postcode: postcode).singleOutput()
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
            
            throw OrderDetailsError.failedToSetDeliveryAddress
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
        try await container.services.basketService.populateRepeatOrder(businessOrderId: order.businessOrderId).singleOutput()
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
        
        // First we check if there is a delivery address on the order. If not, we cannot proceed, so throw error
        guard let deliveryAddress = order.fulfilmentMethod.address else {
            Logger.member.error("No delivery address on order")
            throw OrderDetailsError.noDeliveryAddressOnOrder
        }
        
        do {
            // Perform store search
            try await searchStore()
            
            // Check if we get results back from the store search and that the search is not empty
            guard let searchResult = container.appState.value.userData.searchResult.value,
            let stores = searchResult.stores, stores.count > 0 else {
                Logger.member.error("No store found")
                throw OrderDetailsError.noStoreFound
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
                
                // If store details successfully retrieved, set the delivery address
                do {
                    try await setDeliveryAddress()
                } catch {
                    #warning("Consider adding toast here")
                    Logger.member.error("Failed to set delivery address")
                }
                
                guaranteeMainThread { [weak self] in
                    guard let self = self else { return }
                    self.showDetailsView = false
                }
                
            } else {
                Logger.member.error("No matching store found")
                throw OrderDetailsError.noMatchingStoreFound
            }
        } catch {
            Logger.member.error("Error trying to repeat order: \(error.localizedDescription)")
            self.getRepeatOrderInProgress(false)
            throw error
        }
    }
    
    private func getRepeatOrderInProgress(_ inProgress: Bool) {
        guaranteeMainThread { [weak self] in
            guard let self = self else { return }
            self.repeatOrderRequested = inProgress
        }
    }
}
