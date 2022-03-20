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
    
    @Published var selectedTab: Int
    @Published var basketTotal: String?
    
    private var cancellables = Set<AnyCancellable>()
    
    var showAccountTab: Bool {
        container.appState.value.userData.memberSignedIn
    }
    
    init(container: DIContainer) {
        self.container = container
        let appState = container.appState
        _selectedTab = .init(initialValue: appState.value.routing.selectedTab)
        
        setupBindToSelectedTab(with: appState)
        setupBasketTotal(with: appState)
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
