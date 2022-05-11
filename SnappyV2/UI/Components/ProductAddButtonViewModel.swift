//
//  ProductAddButtonViewModel.swift
//  SnappyV2
//
//  Created by Henrik Gustavii on 18/01/2022.
//

import Foundation
import Combine
import OSLog

@MainActor
class ProductAddButtonViewModel: ObservableObject {
    let container: DIContainer
    let item: RetailStoreMenuItem
    @Published var basket: Basket?
    @Published var basketQuantity: Int = 0
    @Published var changeQuantity: Int = 0
    var basketLineId: Int?
    @Published var showOptions: Bool = false
    
    var quantityLimitReached: Bool { item.basketQuantityLimit > 0 && basketQuantity >= item.basketQuantityLimit }
    
    init(container: DIContainer, menuItem: RetailStoreMenuItem) {
        self.container = container
        let appState = container.appState
        self.item = menuItem
        self._basket = .init(initialValue: appState.value.userData.basket)
        
        setupBasket(appState: appState)
        setupBasketItemCheck()
        setupItemQuantityChange()
    }
    
    @Published var isUpdatingQuantity = false
    
    @Published private(set) var error: Error?
    
    private var cancellables = Set<AnyCancellable>()
    
    var quickAddIsEnabled: Bool { item.quickAdd }

    var itemHasOptionsOrSizes: Bool {
        item.menuItemSizes != nil || item.menuItemOptions != nil
    }
    
    var showStandardButton: Bool { basketQuantity == 0 }
    
    var showDeleteButton: Bool { basketQuantity == 1 }
    
    #warning("Implement properly once we have access to user age")
    var hasAgeRestriction: Bool { item.ageRestriction > 0 }
    
    private func setupBasket(appState: Store<AppState>) {
        appState
            .map(\.userData.basket)
            .assignWeak(to: \.basket, on: self)
            .store(in: &cancellables)
    }
    
    private func setupBasketItemCheck() {
        $basket
            .receive(on: RunLoop.main)
            .sink { [weak self] basket in
                guard let self = self, let basket = basket else { return }
                if basket.items.isEmpty {
                    self.basketQuantity = 0
                    self.basketLineId = nil
                } else {
                    for basketItem in basket.items {
                        if basketItem.menuItem.id == self.item.id {
                            self.basketQuantity = basketItem.quantity
                            self.basketLineId = basketItem.basketLineId
                            break
                        } else {
                            self.basketQuantity = 0
                            self.basketLineId = nil
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
            .asyncMap { [weak self] newValue in
                guard let self = self else { return }
                if newValue == 0 { return } // Ignore when changeQuantity is set to 0 by updateBasket function
                
                await self.updateBasket(newValue: newValue)
            }
            .sink { }
            .store(in: &cancellables)
    }
    
    private func updateBasket(newValue: Int) async {
        self.isUpdatingQuantity = true
        
        // Add item
        if self.basketQuantity == 0 {
            let basketItem = BasketItemRequest(menuItemId: self.item.id, quantity: newValue, changeQuantity: nil, sizeId: 0, bannerAdvertId: 0, options: [], instructions: nil)
            
            do {
                try await self.container.services.basketService.addItem(item: basketItem)
                
                Logger.product.info("Added \(String(describing: self.item.name)) x \(newValue) to basket")
                self.isUpdatingQuantity = false
                self.changeQuantity = 0
            } catch {
                self.error = error
                Logger.product.error("Error adding \(String(describing: self.item.name)) to basket - \(error.localizedDescription)")
                self.isUpdatingQuantity = false
                self.changeQuantity = 0
            }
            
            // Update item
        } else if let basketLineID = self.basketLineId, (self.basketQuantity + newValue) > 0 {
            let totalQuantity = self.basketQuantity + newValue
            let basketItem = BasketItemRequest(menuItemId: self.item.id, quantity: totalQuantity, changeQuantity: nil, sizeId: 0, bannerAdvertId: 0, options: [], instructions: nil)
            
            do {
                try await self.container.services.basketService.updateItem(item: basketItem, basketLineId: basketLineID)
                Logger.product.info("Updated \(String(describing: self.item.name)) with \(newValue) in basket")
                self.isUpdatingQuantity = false
                self.changeQuantity = 0
            } catch {
                self.error = error
                Logger.product.error("Error updating \(String(describing: self.item.name)) in basket - \(error.localizedDescription)")
                self.isUpdatingQuantity = false
                self.changeQuantity = 0
            }
            
            // Remove item
        } else if let basketLineID = self.basketLineId, (self.basketQuantity + newValue) <= 0 {
            
            do {
                try await self.container.services.basketService.removeItem(basketLineId: basketLineID)
                Logger.product.info("Removed \(String(describing: self.item.name)) from basket")
                self.isUpdatingQuantity = false
                self.changeQuantity = 0
            } catch {
                self.error = error
                self.isUpdatingQuantity = false
                self.changeQuantity = 0
            }
        }
    }
    
    func addItem() {
        changeQuantity += 1
    }
    
    func removeItem() {
        changeQuantity -= 1
    }
    
    func addItemWithOptionsTapped() {
        showOptions = true
    }
}
