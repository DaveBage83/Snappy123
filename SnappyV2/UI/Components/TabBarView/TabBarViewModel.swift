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
        if let total = container.appState.value.userData.basket?.orderTotal, total > 0 {
            return total.toCurrencyString()
        }
        return nil
    }

    init(container: DIContainer) {
        self.container = container
        let appState = container.appState
        _selectedTab = .init(initialValue: .stores)
        
        bindSelectedTabToAppState(with: appState)
    }
    
    func bindSelectedTabToAppState(with appState: Store<AppState>) {
        $selectedTab
            .sink { appState.value.routing.selectedTab = $0 }
            .store(in: &cancellables)
    }
    
    func selectTab(_ tab: Tab) {
        selectedTab = tab
    }
}
