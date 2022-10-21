//
//  MemberDashboardOrdersViewModel.swift
//  SnappyV2
//
//  Created by David Bage on 05/04/2022.
//

import Foundation
import Combine
import OSLog

@MainActor
class MemberDashboardOrdersViewModel: ObservableObject {
    struct Constants {
        static let orderDisplayIncrement = 3
        static let fetchLimitIncrement = 10
    }
    
    // MARK: - Properties
    
    let container: DIContainer // Not private as we access this to init OrderSummaryCardViewModel from MemberDashboardOrdersView
    let categoriseOrders: Bool
    var showTrackOrderButton = false
    private var placedOrders: [PlacedOrderSummary]?
    @Published var selectedOrder: PlacedOrder?
    @Published var orderIsLoading = false
    @Published var tappedOrderId: Int?
    
    private var cancellables = Set<AnyCancellable>()
    
    var orderFetchLimit = Constants.fetchLimitIncrement // Total max number of orders fetched from the API
    
    var allOrdersFetched = false // Set to true once all orders have been retrieved from the API
    @Published var driverLocation: DriverLocation?

    // MARK: - Publishers
    
    @Published var maxDisplayedOrders = Constants.orderDisplayIncrement // Max number of orders we display per order category
    @Published var placedOrdersFetch: Loadable<[PlacedOrderSummary]?> = .notRequested

    @Published var initialOrdersLoading = false
    @Published var moreOrdersLoading = false
    private var moreOrdersRequested = false // Flag stops loading animation after first fetch
    
    // Used to display a set of plaeholder order detail cards while loading
    var placeholderOrder: PlacedOrderSummary {
        .init(id: 1, businessOrderId: 1, store: .init(id: 1, name: "Test Store", originalStoreId: nil, storeLogo: nil, address1: "This is a test address", address2: "This is also a test", town: "NiceTown", postcode: "NE101PW", telephone: "12223445556", latitude: 1, longitude: 1), status: "Sent to store", statusText: "Sent to store", fulfilmentMethod: .init(name: .delivery, processingStatus: "In progress", datetime: .init(requestedDate: "date", requestedTime: "time", estimated: nil, fulfilled: nil), place: nil, address: nil, driverTip: nil, refund: nil, deliveryCost: nil, driverTipRefunds: nil), totalPrice: 1)
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
    
    var allOrders: [PlacedOrderSummary] {

        guard let placedOrders = placedOrders else { return [] }

        let ordersToReturn = placedOrders.count >= maxDisplayedOrders ? maxDisplayedOrders : placedOrders.count
        
        return Array(placedOrders[0..<ordersToReturn])
    }
    
    var currentOrders: [PlacedOrderSummary] {

        // If order progress is less than 1, then it is still in progress
        guard let currentOrders = (placedOrders?.filter { $0.orderProgress < 1 }), currentOrders.count > 0 else { return [] }
        
        // If the maxDisplayedOrders is greater than the total number of orders retrieved, we display the total number retrieved
        let ordersToReturn = currentOrders.count >= maxDisplayedOrders ? maxDisplayedOrders : currentOrders.count
        
        return Array(currentOrders[0..<ordersToReturn])
    }
    
    var pastOrders: [PlacedOrderSummary] {

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
    
    func getPlacedOrder(businessOrderId: Int) async {
        orderIsLoading = true
        tappedOrderId = businessOrderId
        do {
            // Set order locally (we need to wait until driver location set
            // before setting the viewModel's selectedOrder property and triggering
            // the sheet
            let order = try await container.services.memberService.getPlacedOrder(businessOrderId: businessOrderId)
            
            // Get the driver location
            await self.getDriverLocationIfOrderIncomplete(orderProgress: order.orderProgress, businessOrderId: businessOrderId)
                        
            self.selectedOrder = order
            orderIsLoading = false
            tappedOrderId = nil
        } catch {
            container.appState.value.errors.append(error)
            orderIsLoading = false
            tappedOrderId = nil
        }
    }
    
    func getDriverLocationIfOrderIncomplete(orderProgress: Double, businessOrderId: Int) async {
        // We only want to get the driver location if orderProgress is not 1 i.e. not complete
        if orderProgress != 1 {
            do {
                try await setDriverLocation(businessOrderId: businessOrderId)
                // If delivery status is 5 we want to show the track order button
                self.showTrackOrderButton = driverLocation?.delivery?.status == 5
            } catch {
                // We do not present anything on the UI here as user should
                // still proceed to view the order details. They just will
                // not see the driver tracking
                Logger.member.error("Failed to get driver location")
            }
        }
    }
    
    func setDriverLocation(businessOrderId: Int) async throws {
            do {
                try await driverLocation = container.services.checkoutService.getDriverLocation(businessOrderId: businessOrderId)
            } catch {
                container.appState.value.errors.append(error)
            }
    }
    
    private func isCurrentOrder(businessOrderId: Int) -> Bool {
        tappedOrderId == businessOrderId
    }
    
    func currentOrderIsLoading(businessOrderId: Int) -> Bool {
        orderIsLoading && isCurrentOrder(businessOrderId: businessOrderId)
    }
    
    func disableCard(businessOrderId: Int) -> Bool {
        orderIsLoading && !currentOrderIsLoading(businessOrderId: businessOrderId)
    }
    
    func onAppearSendEvent() {
        container.eventLogger.sendEvent(for: .viewScreen, with: .appsFlyer, params: ["screen_reference": "past_orders_list"])
    }
}
