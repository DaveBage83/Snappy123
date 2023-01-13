//
//  TabBarViewModel.swift
//  SnappyV2
//
//  Created by David Bage on 01/05/2022.
//

import Foundation
import Combine

class TabBarViewModel: ObservableObject {
    let container: DIContainer
    var cancellables = Set<AnyCancellable>()
    @Published var selectedTab: Tab
    @Published var basketTotal: String?

    init(container: DIContainer) {
        self.container = container
        let appState = container.appState
        _selectedTab = .init(initialValue: container.appState.value.routing.selectedTab)
        
        bindSelectedTabToAppState(with: appState)
        setupBindToBasketTotal(with: appState)
    }
    
    private func setupBindToBasketTotal(with appState: Store<AppState>) {
        appState
            .map(\.userData.basket?.orderTotal)
            .receive(on: RunLoop.main)
            .sink { [weak self] total in
                guard let self = self else { return }
                if let total, let currency = self.container.appState.value.userData.selectedStore.value?.currency, total > 0 {
                    self.basketTotal = total.toCurrencyString(using: currency)
                } else {
                    self.basketTotal = nil
                }
            }
            .store(in: &cancellables)
    }
    
    private func bindSelectedTabToAppState(with appState: Store<AppState>) {
        $selectedTab
            .sink { appState.value.routing.selectedTab = $0 }
            .store(in: &cancellables)
        
        appState
            .map(\.routing.selectedTab)
            .removeDuplicates()
            .assignWeak(to: \.selectedTab, on: self)
            .store(in: &cancellables)
    }
    
    func selectTab(_ tab: Tab) {
        selectedTab = tab
    }
}
