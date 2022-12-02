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
    
    private var showing = false
    private var cancellables = Set<AnyCancellable>()

    init(container: DIContainer) {
        self.container = container
        let appState = container.appState
        _selectedTab = .init(initialValue: appState.value.routing.selectedTab)
        
        setupBindToSelectedTab(with: appState)
        setupBasketTotal(with: appState)
        setupResetPaswordDeepLinkNavigation(with: appState)
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
    
    func viewShown() {
        showing = true
    }

    func viewRemoved() {
        showing = false
    }

}
