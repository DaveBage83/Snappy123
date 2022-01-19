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
    @Published var basketQuantity: Int = 0
    @Published var changeQuantity: Int = 0
    var basketLineId: Int?
    
    @Published var isUpdatingQuantity = false
    
    @Published var showSearchProductCard = false
    
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
    
    var latestOffer: RetailStoreMenuItemAvailableDeal? {
        /// Return offer with the highest id - this should be the latest offer
        itemDetail.availableDeals?.max { $0.id < $1.id }
    }
    
    init(container: DIContainer, menuItem: RetailStoreMenuItem, showSearchProductCard: Bool = false) {
        self.container = container
        let appState = container.appState
        
        self.itemDetail = menuItem
        self._basket = .init(initialValue: appState.value.userData.basket)
        
        self.showSearchProductCard = showSearchProductCard
        
        setupBasket(appState: appState)
        
        setupBasketItemCheck()
        
        #warning("Disabled until basket service layer is sorted")
        setupItemQuantityChange()
    }
        
    private func setupBasket(appState: Store<AppState>) {
        appState
            .map(\.userData.basket)
            .assignWeak(to: \.basket, on: self)
            .store(in: &cancellables)
    }
    
    private func setupBasketItemCheck() {
        $basket
            .sink { [weak self] basket in
                guard let self = self else { return }
                if let basket = basket {
                    for basketItem in basket.items {
                        if basketItem.menuItem.id == self.itemDetail.id {
                            self.basketQuantity = basketItem.quantity
                            self.basketLineId = basketItem.basketLineId
                        }
                    }
                }
            }
            .store(in: &cancellables)
    }
    
    private func setupItemQuantityChange() {
        $changeQuantity
            .debounce(for: 0.4, scheduler: RunLoop.main)
            .receive(on: RunLoop.main)
            .sink { [weak self] newValue in
                guard let self = self else { return }
                if newValue == 0 { return } // Ignore when changeQuantity is set to 0 by updateBasket function
                
                self.updateBasket(newValue: newValue)
            }
            .store(in: &cancellables)
    }
    
    #warning("Replace print with logging below")
    private func updateBasket(newValue: Int) {
        isUpdatingQuantity = true
        
        // Add item
        if self.basketQuantity == 0 {
            let basketItem = BasketItemRequest(menuItemId: self.itemDetail.id, quantity: newValue, sizeId: 0, bannerAdvertId: 0, options: [])
            self.container.services.basketService.addItem(item: basketItem)
                .receive(on: RunLoop.main)
                .sink { [weak self] completion in
                    switch completion {
                    case .finished:
                        print("Added \(String(describing: self?.itemDetail.name)) x \(newValue) to basket")
                    case .failure(let error):
                        print("Error adding \(String(describing: self?.itemDetail.name)) to basket - \(error)")
                        #warning("Code to handle error")
                        self?.isUpdatingQuantity = false
                        self?.changeQuantity = 0
                    }
                } receiveValue: { _ in
                    self.isUpdatingQuantity = false
                    self.changeQuantity = 0
                }
                .store(in: &cancellables)
        }
        
        // Update item
        if let basketLineID = self.basketLineId, (self.basketQuantity + newValue) > 0 {
            let totalQuantity = self.basketQuantity + newValue
            let basketItem = BasketItemRequest(menuItemId: self.itemDetail.id, quantity: totalQuantity, sizeId: 0, bannerAdvertId: 0, options: [])
            self.container.services.basketService.updateItem(item: basketItem, basketLineId: basketLineID)
                .receive(on: RunLoop.main)
                .sink { [weak self] completion in
                    switch completion {
                    case .finished:
                        print("Updated \(String(describing: self?.itemDetail.name)) with \(newValue) in basket")
                    case .failure(let error):
                        print("Error updating \(String(describing: self?.itemDetail.name)) in basket - \(error)")
                        #warning("Code to handle error")
                        self?.isUpdatingQuantity = false
                        self?.changeQuantity = 0
                    }
                } receiveValue: { _ in
                    self.isUpdatingQuantity = false
                    self.changeQuantity = 0
                }
                .store(in: &cancellables)
        }
        
        // Remove item
        if let basketLineID = self.basketLineId, (self.basketQuantity + newValue) <= 0 {
            self.container.services.basketService.removeItem(basketLineId: basketLineID)
                .receive(on: RunLoop.main)
                .sink { [weak self] completion in
                    switch completion {
                    case .finished:
                        print("Removed \(String(describing: self?.itemDetail.name)) from basket")
                    case .failure(let error):
                        print("Error removing \(String(describing: self?.itemDetail.name)) from basket - \(error)")
                        #warning("Code to handle error")
                        self?.isUpdatingQuantity = false
                        self?.changeQuantity = 0
                    }
                } receiveValue: { _ in
                    self.isUpdatingQuantity = false
                    self.changeQuantity = 0
                }
                .store(in: &self.cancellables)
        }
    }

    func addItem() {
        changeQuantity += 1
    }
    
    func removeItem() {
        changeQuantity -= 1
    }
}
