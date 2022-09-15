//
//  ProductAddButtonViewModel.swift
//  SnappyV2
//
//  Created by Henrik Gustavii on 18/01/2022.
//

import Foundation
import Combine
import OSLog
import AppsFlyerLib

@MainActor
class ProductAddButtonViewModel: ObservableObject {
    let container: DIContainer
    let item: RetailStoreMenuItem
    @Published var basket: Basket?
    @Published var basketQuantity: Int = 0
    @Published var changeQuantity: Int = 0
    var basketItem: BasketItem?
    @Published var showOptions: Bool = false
    @Published var showMultipleComplexItemsAlert: Bool = false
    private let isInBasket: Bool
    @Published var itemForOptions: RetailStoreMenuItem?
    
    var quantityLimitReached: Bool { item.basketQuantityLimit > 0 && basketQuantity >= item.basketQuantityLimit }
    
    init(container: DIContainer, menuItem: RetailStoreMenuItem, isInBasket: Bool = false) {
        self.container = container
        let appState = container.appState
        self.item = menuItem
        self._basket = .init(initialValue: appState.value.userData.basket)
        self.isInBasket = isInBasket
        
        setupBasket(appState: appState)
        setupBasketItemCheck()
        setupItemQuantityChange()
    }
    
    @Published var isUpdatingQuantity = false
    
    @Published private(set) var error: Error?
    
    private var cancellables = Set<AnyCancellable>()
    
    var quickAddIsEnabled: Bool {
        if isInBasket { return true }
        return item.quickAdd
    }

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
                    self.basketItem = nil
                } else {
                    self.basketQuantity = 0
                    self.basketItem = nil
                    for basketItem in basket.items {
                        if basketItem.menuItem.id == self.item.id {
                            if self.isInBasket {
                                self.basketQuantity = basketItem.quantity
                            } else {
                                self.basketQuantity += basketItem.quantity
                            }
                            self.basketItem = basketItem
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
            let basketItem = BasketItemRequest(menuItemId: self.item.id, quantity: newValue, sizeId: 0, bannerAdvertId: 0, options: [], instructions: nil)
            
            do {
                try await self.container.services.basketService.addItem(basketItemRequest: basketItem, item: self.item)
                
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
        } else if let basketItem = self.basketItem, (self.basketQuantity + newValue) > 0 {
            let totalQuantity = self.basketQuantity + newValue
            let basketItemRequest = BasketItemRequest(menuItemId: self.item.id, quantity: totalQuantity, sizeId: 0, bannerAdvertId: 0, options: [], instructions: nil)
            
            do {
                try await self.container.services.basketService.updateItem(basketItemRequest: basketItemRequest, basketItem: basketItem)
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
        } else if let basketLineID = self.basketItem?.basketLineId, (self.basketQuantity + newValue) <= 0 {
            
            do {
                try await self.container.services.basketService.removeItem(basketLineId: basketLineID, item: item)
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
        if quickAddIsEnabled {
            changeQuantity += 1
        } else {
            addItemWithOptionsTapped()
        }
    }
    
    func removeItem() {
        if quickAddIsEnabled {
            changeQuantity -= 1
        } else if basketQuantity == 1 {
            changeQuantity -= 1
        } else {
            showMultipleComplexItemsAlert = true
        }
    }
    
    private func addItemWithOptionsTapped() {
        showOptions = true
    }
    
    func goToBasketView() {
        self.container.appState.value.routing.selectedTab = .basket
    }
}
