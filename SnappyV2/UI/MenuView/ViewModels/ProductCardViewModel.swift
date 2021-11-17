//
//  ProductCardViewModel.swift
//  SnappyV2
//
//  Created by Henrik Gustavii on 11/11/2021.
//

import Combine
import Foundation

class ProductCardViewModel: ObservableObject {
    let container: DIContainer
    let itemDetail: RetailStoreMenuItem
    
    @Published var basket: Basket?
    @Published var quantity: Int = 0
    @Published var isUpdatingQuantity = false
    
    @Published var showItemOptions = false
    var quickAddIsEnabled: Bool { itemDetail.quickAdd }
    var itemHasOptionsOrSizes: Bool {
        itemDetail.menuItemSizes != nil || itemDetail.menuItemOptions != nil
    }
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
        
        setupBasketItemCheck()
        
        #warning("Disabled until basket service layer is sorted")
//        setupItemQuantityChange()
    }
    
    private func setupBasket(appState: Store<AppState>) {
        appState
            .map(\.userData.basket)
            .removeDuplicates()
            .assignWeak(to: \.basket, on: self)
            .store(in: &cancellables)
    }
    
    private func setupBasketItemCheck() {
        $basket
            .map { [weak self] basket in
                guard let self = self else { return 0 }
                if let basket = basket {
                    for basketItem in basket.items {
                        if basketItem.menuItem.id == self.itemDetail.id {
                            return basketItem.quantity
                        }
                    }
                }
                return 0
            }
            .assignWeak(to: \.quantity, on: self)
            .store(in: &cancellables)
    }
    
    func setupItemQuantityChange() {
        $quantity
            .debounce(for: 0.4, scheduler: RunLoop.main)
            .removeDuplicates()
            .receive(on: RunLoop.main)
            .sink { [weak self] currentValue in
                guard let self = self else { return }
                self.isUpdatingQuantity = true

                let basketItem = BasketItemRequest(menuItemId: self.itemDetail.id, quantity: currentValue, sizeId: 0, bannerAdvertId: 0, options: [])
                self.container.services.basketService.addItem(item: basketItem)
                    .receive(on: RunLoop.main)
                    .sink { error in
                        #warning("Code to handle error")
                    } receiveValue: { _ in
                        self.isUpdatingQuantity = false
                    }
                    .store(in: &self.cancellables)
            }
            .store(in: &cancellables)
    }
    
    func addItem() {
        quantity += 1
    }
    
    func removeItem() {
        quantity -= 1
    }
}
