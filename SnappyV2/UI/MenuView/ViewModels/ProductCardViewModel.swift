//
//  ProductCardViewModel.swift
//  SnappyV2
//
//  Created by Henrik Gustavii on 11/11/2021.
//

import Combine

class ProductCardViewModel: ObservableObject {
    let container: DIContainer
    let itemDetail: RetailStoreMenuItem
    
    @Published var basket: Basket?
    @Published var quantity: Int = 0
    
    var quickAddIsEnabled: Bool { itemDetail.quickAdd }
    var hasAgeRestriction: Bool {
        #warning("Implement properly once we have access to user age")
        if itemDetail.ageRestriction > 0 {
            return true
        }
        return false
    }
    
    private var cancellables = Set<AnyCancellable>()
    
    init(container: DIContainer, menuItem: RetailStoreMenuItem) {
        self.container = container
        let appState = container.appState
        
        self.itemDetail = menuItem
        self._basket = .init(initialValue: appState.value.userData.basket)
        
        setupBasket(appState: appState)
    }
    
    func setupBasket(appState: Store<AppState>) {
        appState
            .map(\.userData.basket)
            .removeDuplicates()
            .assignWeak(to: \.basket, on: self)
            .store(in: &cancellables)
    }
    
    func setupBasketItemCheck() {
        $basket
            .map { basket in
                // check for item and add to quantity
            }
    }
    
    func addItem() {
        // BasketService - addItem(item: BasketItemRequest) -> Future<Bool, Error>
    }
    
    func removeItem() {
        // BasketService - removeItem(basketLineId: Int) -> Future<Bool, Error>
    }
}
