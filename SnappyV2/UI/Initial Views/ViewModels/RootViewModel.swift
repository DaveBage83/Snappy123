//
//  RootViewModel.swift
//  SnappyV2
//
//  Created by Henrik Gustavii on 21/09/2021.
//

import Combine

class RootViewModel: ObservableObject {
    let container: DIContainer
    
    @Published var selectedTab: Int
    
    private var cancellables = Set<AnyCancellable>()
    
    init(container: DIContainer) {
        self.container = container
        let appState = container.appState
        _selectedTab = .init(initialValue: appState.value.routing.selectedTab)
        
        // Below code is to make local and appState selectedTab dynamically equal to each other
        $selectedTab
            .sink { appState.value.routing.selectedTab = $0 }
            .store(in: &cancellables)
        
        appState
            .map(\.routing.selectedTab)
            .removeDuplicates()
            .assignNoRetain(to: \.selectedTab, on: self)
            .store(in: &cancellables)
    }
}
