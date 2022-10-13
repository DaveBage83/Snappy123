//
//  ProductCardViewModel.swift
//  SnappyV2
//
//  Created by Henrik Gustavii on 11/11/2021.
//

import Combine
import Foundation

// 3rd party
import Firebase

@MainActor
class ProductCardViewModel: ObservableObject {
    let container: DIContainer
    var itemDetail: RetailStoreMenuItem
    
    @Published var showSearchProductCard = false
    @Published var isGettingProductDetails = false
    @Published var showItemDetails = false
    let isInBasket: Bool
    let isOffer: Bool
    let associatedSearchTerm: String?
    let productSelected: (RetailStoreMenuItem) -> Void
    
    var isReduced: Bool {
        itemDetail.price.wasPrice != nil
    }
    
    var wasPriceString: String? {
        guard let wasPrice = itemDetail.price.wasPrice, wasPrice > 0 else { return nil }
        return wasPrice.toCurrencyString(using: container.appState.value.userData.selectedStore.value?.currency ?? AppV2Constants.Business.defaultStoreCurrency)
    }
    
    var showSpecialOfferPillAsButton: Bool {
        isInBasket == false
    }
    
    var calorieInfo: String? {
        itemDetail.itemCaptions?.portionSize
    }
    
    var isComplexItem: Bool {
        itemDetail.menuItemOptions != nil || itemDetail.menuItemSizes != nil
    }
    
    var fromPriceString: String? {
        // This logic is wrong, is should be fromPrice != price, but API currently
        // always sets both prices as the same, so this is stop gap logic
        if isComplexItem, itemDetail.price.fromPrice > 0 {
            return itemDetail.price.fromPrice.toCurrencyString(
                using: container.appState.value.userData.selectedStore.value?.currency ?? AppV2Constants.Business.defaultStoreCurrency
            )
        }
        return nil
    }
    
    var priceString: String {
        itemDetail.price.price.toCurrencyString(
            using: container.appState.value.userData.selectedStore.value?.currency ?? AppV2Constants.Business.defaultStoreCurrency
        )
    }

    var latestOffer: RetailStoreMenuItemAvailableDeal? {
        /// Return offer with the highest id - this should be the latest offer
        itemDetail.availableDeals?.max { $0.id < $1.id }
    }

    init(container: DIContainer, menuItem: RetailStoreMenuItem, isInBasket: Bool = false, isOffer: Bool = false, associatedSearchTerm: String? = nil, productSelected: @escaping (RetailStoreMenuItem) -> Void) {
        self.container = container
        self.itemDetail = menuItem
        self.isInBasket = isInBasket
        self.isOffer = isOffer
        self.associatedSearchTerm = associatedSearchTerm
        self.productSelected = productSelected
    }
    
    private func sendSearchResultSelectionEvent() {
        guard let associatedSearchTerm = associatedSearchTerm else { return }
        var firebaseAnalyticsParams: [String : Any] = [
            AnalyticsParameterSearchTerm: associatedSearchTerm,
            "name": itemDetail.name,
            "category_id": itemDetail.mainCategory.id,
            "item_id": itemDetail.id
        ]
        container.eventLogger.sendEvent(for: .searchResultSelection, with: .firebaseAnalytics, params: firebaseAnalyticsParams)
    }
    
    func productCardTapped() async throws {
        guard let selectedStore = container.appState.value.userData.selectedStore.value else {
            return
        }
        
        sendSearchResultSelectionEvent()
        
        isGettingProductDetails = true
        
        var fulfilmentDate = ""
        
        if container.appState.value.userData.basket?.selectedSlot?.todaySelected == true {
            fulfilmentDate = Date().trueDate.dateOnlyString(storeTimeZone: selectedStore.storeTimeZone)
        } else if let start = container.appState.value.userData.basket?.selectedSlot?.start {
            fulfilmentDate = start.dateOnlyString(storeTimeZone: selectedStore.storeTimeZone)
        }
        
        let request = RetailStoreMenuItemRequest(
            itemId: itemDetail.id,
            storeId: selectedStore.id,
            categoryId: nil,
            fulfilmentMethod: container.appState.value.userData.selectedFulfilmentMethod,
            fulfilmentDate: fulfilmentDate)
        
        do {
            self.itemDetail = try await container.services.retailStoreMenuService.getItem(request: request)
            isGettingProductDetails = false
            productSelected(itemDetail)
            self.showItemDetails = true
        } catch {
            isGettingProductDetails = false
            throw error
        }
    }
}
