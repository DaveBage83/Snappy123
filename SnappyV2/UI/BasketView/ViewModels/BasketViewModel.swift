//
//  BasketViewModel.swift
//  SnappyV2
//
//  Created by Henrik Gustavii on 20/12/2021.
//

import Combine
import Foundation

class BasketViewModel: ObservableObject {
    let container: DIContainer
    @Published var basket: Basket?
    
    private var cancellables = Set<AnyCancellable>()
    
    init(container: DIContainer) {
        self.container = container
        let appState = container.appState
        
        _basket = .init(initialValue: appState.value.userData.basket)
        
        setupBasket(with: appState)
    }
    
    private func setupBasket(with appState: Store<AppState>) {
        appState
            .map(\.userData.basket)
            .receive(on: RunLoop.main)
            .assignWeak(to: \.basket, on: self)
            .store(in: &cancellables)
    }
}
