//
//  MemberDashboardOrdersViewModel.swift
//  SnappyV2
//
//  Created by David Bage on 05/04/2022.
//

import Foundation
import Combine

@MainActor
class MemberDashboardOrdersViewModel: ObservableObject {
    struct Constants {
        static let orderDisplayIncrement = 3
        static let fetchLimitIncrement = 10
    }
    
    // MARK: - Properties
    
    let container: DIContainer // Not private as we access this to init OrderSummaryCardViewModel from MemberDashboardOrdersView
    let categoriseOrders: Bool
    private var placedOrders: [PlacedOrder]?
    
    private var cancellables = Set<AnyCancellable>()
    
    var orderFetchLimit = Constants.fetchLimitIncrement // Total max number of orders fetched from the API
    
    var allOrdersFetched = false // Set to true once all orders have been retrieved from the API

    // MARK: - Publishers
    
    @Published var maxDisplayedOrders = Constants.orderDisplayIncrement // Max number of orders we display per order category
    @Published var placedOrdersFetch: Loadable<[PlacedOrder]?> = .notRequested
    @Published var initialOrdersLoading = false
    @Published var moreOrdersLoading = false
    private var moreOrdersRequested = false // Flag stops loading animation after first fetch
    
    // Used to display a set of plaeholder order detail cards while loading
    var placeholderOrder: PlacedOrder {
        .init(id: 1, businessOrderId: 1, status: "Sent to store", statusText: "", totalPrice: 1, totalDiscounts: 1, totalSurcharge: 1, totalToPay: 1, platform: "", firstOrder: false, createdAt: "", updatedAt: "", store: .init(id: 1, name: "", originalStoreId: 1, storeLogo: nil, address1: "", address2: "", town: "", postcode: "", telephone: "", latitude: 1, longitude: 1), fulfilmentMethod: .init(name: .collection, processingStatus: "", datetime: .init(requestedDate: "", requestedTime: "", estimated: nil, fulfilled: nil), place: .init(type: .name, name: "", subName: ""), address: nil, driverTip: 1, refund: 1, deliveryCost: 1, driverTipRefunds: nil), paymentMethod: .init(name: "", dateTime: ""), orderLines: [], customer: .init(firstname: "", lastname: ""), discount: nil, surcharges: nil, loyaltyPoints: nil, coupon: nil, currency: .init(currencyCode: "", symbol: "", ratio: 1, symbolChar: "", name: ""), totalOrderValue: 1, totalRefunded: 1)
    }
    
    // MARK: - Computed properties
    
    var currentOrdersPresent: Bool {
        !currentOrders.isEmpty
    }
    
    var pastOrdersPresent: Bool {
        !pastOrders.isEmpty
    }
    
    var showViewMoreOrdersView: Bool {
        initialOrdersLoading == false
    }
    
    // While the /member/orders endpoint accepts a limit parameter, as we are sorting the results into current and past orders
    // we want control over how many of each we display. Therefore, we fetch 10 results initially from the API and then display
    // max 3 (initially) of each type using the 2 following computed variables. Each time the user taps the moreOrders button we
    // add 3 to the maxDisplayedOrders variable. Once all fetched orders have been displayed, we increase the orderFetchLimit by
    // 10 and hit the endpoint again.
    
    var allOrders: [PlacedOrder] {
        guard let placedOrders = placedOrders else { return [] }

        let ordersToReturn = placedOrders.count >= maxDisplayedOrders ? maxDisplayedOrders : placedOrders.count
        
        return Array(placedOrders[0..<ordersToReturn])
    }
    
    var currentOrders: [PlacedOrder] {
        // If order progress is less than 1, then it is still in progress
        guard let currentOrders = (placedOrders?.filter { $0.orderProgress < 1 }), currentOrders.count > 0 else { return [] }
        
        // If the maxDisplayedOrders is greater than the total number of orders retrieved, we display the total number retrieved
        let ordersToReturn = currentOrders.count >= maxDisplayedOrders ? maxDisplayedOrders : currentOrders.count
        
        return Array(currentOrders[0..<ordersToReturn])
    }
    
    var pastOrders: [PlacedOrder] {
        // If order progress is 1, then it is a past order i.e. completed
        guard let pastOrders = (placedOrders?.filter { $0.orderProgress == 1 }), pastOrders.count > 0 else {
            return []
        }
        
        // If the maxDisplayedOrders is greater than the total number of orders retrieved, we display the total number retrieved
        let ordersToReturn = pastOrders.count >= (maxDisplayedOrders - 1) ? maxDisplayedOrders : pastOrders.count
        
        return Array(pastOrders[0..<ordersToReturn])
    }

    init(container: DIContainer, categoriseOrders: Bool = false) {
        self.container = container
        self.categoriseOrders = categoriseOrders
        
        getPlacedOrders()
        setupPlacedOrders()
    }
    
    private func setupPlacedOrders() {
        $placedOrdersFetch
            .receive(on: RunLoop.main)
            .sink { [weak self] orders in
                guard let self = self, let orders = orders.value else { return }
                    self.placedOrders = orders
                
                if let placedOrders = self.placedOrders {
                    // Once we have fetched the orders, if the total number is equal to or less than the maxDisplayed
                    // orders, then we have retrieved all orders and we set the allOrdersFetched variable to true
                    // to prevent the API being hit any more and the remove the view more orders button
                    self.allOrdersFetched = placedOrders.count <= self.maxDisplayedOrders
                }
            }
            .store(in: &cancellables)
    }
    
    func getMoreOrdersTapped() {
        moreOrdersRequested = true
        
        guaranteeMainThread { [weak self] in
            // If there are no orders or all orders have been fetched from the API, no need to continue with this operation
            guard let self = self, let placedOrders = self.placedOrders, !self.allOrdersFetched else { return }
            self.maxDisplayedOrders += Constants.orderDisplayIncrement
            
            // Once incremented by 3, if the maxDisplayedOrders variable is greater than or equal to the total fetched orders then
            // we need to hit the member/orders endpoint again, incrementing the fetch limit by 10
            if self.maxDisplayedOrders >= placedOrders.count {
                self.orderFetchLimit += Constants.fetchLimitIncrement
                self.getPlacedOrders()
            }
        }
    }
    
    private func getPlacedOrders() {
        if moreOrdersRequested == false {
            initialOrdersLoading = true
        } else {
            moreOrdersLoading = true
        }
        
        Task { [weak self] in
            guard let self = self else {
                return
            }
            
            await self.container.services.memberService.getPastOrders(pastOrders: self.loadableSubject(\.placedOrdersFetch), dateFrom: nil, dateTo: nil, status: nil, page: nil, limit: self.orderFetchLimit)
            
            self.initialOrdersLoading = false
            self.moreOrdersLoading = false
        }
    }
    
    func onAppearSendEvent() {
        container.eventLogger.sendEvent(for: .viewScreen(.outside, .pastOrdersList), with: .appsFlyer, params: [:])
    }
}
