//
//  RootViewModel.swift
//  SnappyV2
//
//  Created by Henrik Gustavii on 21/09/2021.
//

import Combine
import Foundation

@MainActor
class RootViewModel: ObservableObject {
    let container: DIContainer
    
    @Published var selectedTab: Tab
    @Published var basketTotal: String?
    @Published var showAddItemToBasketToast: Bool
    @Published var driverMapParameters: DriverLocationMapParameters = DriverLocationMapParameters(businessOrderId: 0, driverLocation: DriverLocation(orderId: 0, pusher: nil, store: nil, delivery: nil, driver: nil), lastDeliveryOrder: nil, placedOrder: nil)
    @Published var displayDriverMap: Bool = false
    
    private var showing = false
    private var cancellables = Set<AnyCancellable>()

    init(container: DIContainer) {
        self.container = container
        let appState = container.appState
        _selectedTab = .init(initialValue: appState.value.routing.selectedTab)
        _showAddItemToBasketToast = .init(initialValue: appState.value.notifications.showAddItemToBasketToast)
        
        setupBindToSelectedTab(with: appState)
        setupBasketTotal(with: appState)
        setupShowToast(with: appState)
        setupLastOrderDriverEnRouteCheck(with: appState)
    }
    
    private func setupShowToast(with appState: Store<AppState>) {
        appState
            .map(\.notifications.showAddItemToBasketToast)
            .removeDuplicates()
            .assignWeak(to: \.showAddItemToBasketToast, on: self)
            .store(in: &cancellables)
        
        $showAddItemToBasketToast
            .sink { appState.value.notifications.showAddItemToBasketToast = $0 }
            .store(in: &cancellables)
    }
    
    private func setupBindToSelectedTab(with appState: Store<AppState>) {
        $selectedTab
            .sink { appState.value.routing.selectedTab = $0 }
            .store(in: &cancellables)
        
        appState
            .removeDuplicates()
            .map(\.routing.selectedTab)
            .removeDuplicates()
            .assignWeak(to: \.selectedTab, on: self)
            .store(in: &cancellables)
    }
    
    private func setupBasketTotal(with appState: Store<AppState>) {
        appState
            .map(\.userData.basket)
            .receive(on: RunLoop.main)
            .sink { [weak self] basket in
                guard let self = self else { return }
                self.basketTotal = basket?.orderTotal == 0 ? nil : basket?.orderTotal.toCurrencyString()
            }
            .store(in: &cancellables)
    }
    
    private func setupLastOrderDriverEnRouteCheck(with appState: Store<AppState>) {
        appState
            .map(\.system.isInForeground)
            .removeDuplicates()
            .receive(on: RunLoop.main)
            .asyncMap { [weak self] isInForeground in
                guard let self = self else { return }
                // check if the last delivery order is in progress when returning from the background
                if isInForeground && self.showing {
                    if let driverMapParameters = try await self.container.services.checkoutService.getLastDeliveryOrderDriverLocation() {
                        self.driverMapParameters = driverMapParameters
                        self.displayDriverMap = true
                    }
                }
            }
            .sink { _ in }
            .store(in: &cancellables)
    }
    
    func dismissDriverMap() {
        displayDriverMap = false
    }
    
    func viewShown() {
        showing = true
        // check if the last delivery order is in progress when first returning to this view
        Task {
            try await container.services.checkoutService.addTextLastDeliveryOrderDriverLocation()
            
            if let driverMapParameters = try await container.services.checkoutService.getLastDeliveryOrderDriverLocation() {
                self.driverMapParameters = driverMapParameters
                displayDriverMap = true
            }
        }
    }

    func viewRemoved() {
        showing = false
    }

}
