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
    @Published var displayDriverMap: Bool = false
    
    lazy var driverMapViewModel: DriverMapViewModel = {
        DriverMapViewModel(container: container) { [weak self] in
            guard let self = self else { return }
            self.dismissDriverMap()
        }
    }()
    
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
        setupForegroundLastOrderDriverEnRouteCheck(with: appState)
        setupPushNotificationLastOrderDriverEnRouteCheck(with: appState)
        setupResetPaswordDeepLinkNavigation(with: appState)
        setupDisplayedDriverLocationCheck(with: appState)
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
                guard
                    let selectedStore = self.container.appState.value.userData.selectedStore.value,
                    let orderTotal = basket?.orderTotal,
                    orderTotal != 0
                else {
                    self.basketTotal = nil
                    return
                }
                self.basketTotal = orderTotal.toCurrencyString(using: selectedStore.currency)
            }
            .store(in: &cancellables)
    }
    
    private func setupForegroundLastOrderDriverEnRouteCheck(with appState: Store<AppState>) {
        appState
            .map(\.system.isInForeground)
            .removeDuplicates()
            .receive(on: RunLoop.main)
            .asyncMap { [weak self] isInForeground in
                guard
                    let self = self,
                    isInForeground && self.showing && appState.value.openViews.driverLocationMap == false
                else { return }
                // check if the last delivery order is in progress when returning from the background
                try await self.getLastDeliveryOrderDriverLocation()
            }
            .sink { _ in }
            .store(in: &cancellables)
        
        $displayDriverMap
            .sink { [weak self] in
                guard let self = self else { return }
                appState.value.openViews.driverLocationMap = $0
                if $0 == false {
                    self.container.appState.value.routing.displayedDriverLocation = nil
                }
            }
            .store(in: &cancellables)
    }
    
    private func setupPushNotificationLastOrderDriverEnRouteCheck(with appState: Store<AppState>) {
        appState
            .map(\.pushNotifications.driverMapOpenNotification)
            .filter { $0 != nil }
            .removeDuplicates()
            .print()
            .receive(on: RunLoop.main)
            .asyncMap { [weak self] _ in
                guard
                    let self = self,
                    self.showing && appState.value.openViews.driverLocationMap == false
                else { return }
                try await self.getLastDeliveryOrderDriverLocation()
            }
            .sink { _ in }
            .store(in: &cancellables)
    }
    
    private func setupDisplayedDriverLocationCheck(with appState: Store<AppState>) {
        appState
            .map(\.routing.displayedDriverLocation)
            .receive(on: RunLoop.main)
            .sink { [weak self] displayedDriverLocationParams in
                guard
                    let self = self,
                    displayedDriverLocationParams != nil && self.driverMapViewModel.showing == false
                else { return }
                self.displayDriverMap = true
            }
            .store(in: &cancellables)
    }
    
    private func setupResetPaswordDeepLinkNavigation(with appState: Store<AppState>) {
        appState
            .map(\.passwordResetCode)
            .removeDuplicates()
            .receive(on: RunLoop.main)
            .sink { [weak self] token in
                guard
                    let self = self,
                    self.selectedTab != .account,
                    token != nil
                else { return }
                self.selectedTab = .account
            }.store(in: &cancellables)
    }
    
    private func getLastDeliveryOrderDriverLocation() async throws {
        if let driverMapParameters = try await self.container.services.checkoutService.getLastDeliveryOrderDriverLocation() {
            container.appState.value.routing.displayedDriverLocation = driverMapParameters
        }
    }
    
    func dismissDriverMap() {
        container.appState.value.pushNotifications.driverMapOpenNotification = nil
        displayDriverMap = false
    }
    
    func viewShown() {
        showing = true
        // check if the last delivery order is in progress when first returning to this view
        Task {
            // Useful approach for testing without having to place an order.
            //try await container.services.checkoutService.addTestLastDeliveryOrderDriverLocation()
            
            try await getLastDeliveryOrderDriverLocation()
        }
    }

    func viewRemoved() {
        showing = false
    }

}
