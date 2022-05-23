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
    
    var basketTotal: String? {
        // If the basket total is zero, we want to return nil so as not to display the badge
        if let total = container.appState.value.userData.basket?.orderTotal, total > 0 {
            return total.toCurrencyString()
        }
        return nil
    }

    init(container: DIContainer) {
        self.container = container
        let appState = container.appState
        _selectedTab = .init(initialValue: container.appState.value.routing.selectedTab)
        
        bindSelectedTabToAppState(with: appState)
    }
    
    private func bindSelectedTabToAppState(with appState: Store<AppState>) {
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
    
    func selectTab(_ tab: Tab) {
        selectedTab = tab
    }
}
