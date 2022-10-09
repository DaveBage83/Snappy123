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
class ProductIncrementButtonViewModel: ObservableObject {
    let container: DIContainer
    let item: RetailStoreMenuItem
    let interactionLoggerHandler: ((RetailStoreMenuItem)->())?
    @Published var basket: Basket?
    @Published var basketQuantity: Int = 0
    @Published var changeQuantity: Int = 0
    var basketItem: BasketItem?
    @Published var optionsShown: RetailStoreMenuItem?
    @Published var showMultipleComplexItemsAlert: Bool = false
    private let isInBasket: Bool
    @Published var itemForOptions: RetailStoreMenuItem?
    @Published var isGettingProductDetails = false
    @Published var isUpdatingQuantity = false
    @Published var isDisplayingAgeAlert = false
    var updateBasketTask: Task<Void, Never>?
    
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
    
    var quantityLimitReached: Bool { item.basketQuantityLimit > 0 && basketQuantity >= item.basketQuantityLimit }
    
    init(container: DIContainer, menuItem: RetailStoreMenuItem, isInBasket: Bool = false, interactionLoggerHandler: ((RetailStoreMenuItem)->())? = nil) {
        self.container = container
        let appState = container.appState
        self.item = menuItem
        self.interactionLoggerHandler = interactionLoggerHandler
        self._basket = .init(initialValue: appState.value.userData.basket)
        self.isInBasket = isInBasket
        
        setupBasket(appState: appState)
        setupBasketItemCheck()
        setupItemQuantityChange()
    }
    
    deinit {
        updateBasketTask?.cancel()
    }
    
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
            .sink { [weak self] newValue in
                guard let self = self else { return }
                if newValue == 0 { return } // Ignore when changeQuantity is set to 0 by updateBasket function
                var updatedValue = newValue
                // check item limit and update to max if newValue is above
                if let itemLimit = self.basketItem?.menuItem.basketQuantityLimit, updatedValue > itemLimit {
                   updatedValue = itemLimit
                }
                self.updateBasketTask = Task { [weak self] in
                    guard let self = self else { return }
                    await self.updateBasket(newValue: updatedValue)
                }
            }
            .store(in: &cancellables)
    }
    
    private func updateBasket(newValue: Int) async {
        self.isUpdatingQuantity = true
        
        // Add item
        if self.basketQuantity == 0 {
            let basketItem = BasketItemRequest(menuItemId: self.item.id, quantity: newValue, sizeId: nil, bannerAdvertId: nil, options: nil, instructions: nil)
            
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
            do {
                try await self.container.services.basketService.changeItemQuantity(basketItem: basketItem, changeQuantity: newValue)
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
    
    func addItem() async {
        interactionLoggerHandler?(item)

        if hasAgeRestriction {
            if item.ageRestriction > container.appState.value.userData.confirmedAge {
                self.isDisplayingAgeAlert = true
                return
            }
        }

        if quickAddIsEnabled {
            changeQuantity += 1
        } else {
            await addItemWithOptions()
        }
        
    }
    
    func removeItem() {
        interactionLoggerHandler?(item)
        if quickAddIsEnabled {
            changeQuantity -= 1
        } else if basketQuantity == 1 {
            changeQuantity -= 1
        } else {
            showMultipleComplexItemsAlert = true
        }
    }
    
    private func addItemWithOptions() async {
        guard let selectedStore = container.appState.value.userData.selectedStore.value else {
            return
        }
        
        isGettingProductDetails = true
        
        var fulfilmentDate = ""
        
        if container.appState.value.userData.basket?.selectedSlot?.todaySelected == true {
            fulfilmentDate = Date().trueDate.dateOnlyString(storeTimeZone: selectedStore.storeTimeZone)
        } else if let start = container.appState.value.userData.basket?.selectedSlot?.start {
            fulfilmentDate = start.dateOnlyString(storeTimeZone: selectedStore.storeTimeZone)
        }
        
        let request = RetailStoreMenuItemRequest(
            itemId: item.id,
            storeId: selectedStore.id,
            categoryId: nil,
            fulfilmentMethod: container.appState.value.userData.selectedFulfilmentMethod,
            fulfilmentDate: fulfilmentDate)
        
        do {
            let item = try await container.services.retailStoreMenuService.getItem(request: request)
            isGettingProductDetails = false
            self.optionsShown = item
        } catch {
            isGettingProductDetails = false
            self.error = error
        }
    }
    
    func goToBasketView() {
        self.container.appState.value.routing.selectedTab = .basket
    }
    
    func userConfirmedAge() async {
        self.container.appState.value.userData.confirmedAge = item.ageRestriction
        await addItem()
    }
    
}
