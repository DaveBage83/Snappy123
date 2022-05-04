//
//  RootViewModel.swift
//  SnappyV2
//
//  Created by Henrik Gustavii on 21/09/2021.
//

import Combine
import Foundation

class RootViewModel: ObservableObject {
    let container: DIContainer
    
    @Published var selectedTab: Tab
    @Published var basketTotal: String?
    @Published var showAddItemToBasketToast: Bool
    
    private var cancellables = Set<AnyCancellable>()

    init(container: DIContainer) {
        self.container = container
        let appState = container.appState
        _selectedTab = .init(initialValue: appState.value.routing.selectedTab)
        _showAddItemToBasketToast = .init(initialValue: appState.value.notifications.showAddItemToBasketToast)
        
        setupBindToSelectedTab(with: appState)
        setupBasketTotal(with: appState)
        setupShowToast(with: appState)
    }
    
    func setupShowToast(with appState: Store<AppState>) {
        appState
            .map(\.notifications.showAddItemToBasketToast)
            .removeDuplicates()
            .assignWeak(to: \.showAddItemToBasketToast, on: self)
            .store(in: &cancellables)
        
        $showAddItemToBasketToast
            .sink { appState.value.notifications.showAddItemToBasketToast = $0 }
            .store(in: &cancellables)
    }
    
    func setupBindToSelectedTab(with appState: Store<AppState>) {
        $selectedTab
            .sink { appState.value.routing.selectedTab = $0 }
            .store(in: &cancellables)
        
        appState
            .map(\.routing.selectedTab)
            .removeDuplicates()
            .assignWeak(to: \.selectedTab, on: self)
            .store(in: &cancellables)
    }
    
    func setupBasketTotal(with appState: Store<AppState>) {
        appState
            .map(\.userData.basket)
            .receive(on: RunLoop.main)
            .sink { [weak self] basket in
                guard let self = self else { return }
                self.basketTotal = basket?.orderTotal == 0 ? nil : basket?.orderTotal.toCurrencyString()
            }
            .store(in: &cancellables)
    }
}
