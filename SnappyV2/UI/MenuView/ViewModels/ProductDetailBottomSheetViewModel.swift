//
//  ProductDetailBottomSheetViewModel.swift
//  SnappyV2
//
//  Created by Henrik Gustavii on 21/03/2022.
//

import Foundation
import Combine
import AppsFlyerLib

class ProductDetailBottomSheetViewModel: ObservableObject {
    let container: DIContainer
    @Published var basket: Basket?
    let item: RetailStoreMenuItem
    @Published var basketQuantity = 0
    
    private var cancellables = Set<AnyCancellable>()
    
    var calories: String? {
        item.itemCaptions?.portionSize
    }
    
    var itemDetailElements: [ItemDetails]? {
        item.itemDetails
    }
    
    var latestOffer: RetailStoreMenuItemAvailableDeal? {
        /// Return offer with the highest id - this should be the latest offer
        item.availableDeals?.max { $0.id < $1.id }
    }
    
    var hasElements: Bool {
        itemDetailElements != nil && itemDetailElements?.isEmpty == false
    }

    var quantityLimitReached: Bool { basketQuantity > 0 && basketQuantity >= item.basketQuantityLimit }
    
    var wasPriceString: String? {
        guard let wasPrice = item.price.wasPrice, wasPrice > 0 else { return nil }
        return wasPrice.toCurrencyString(
            using: container.appState.value.userData.selectedStore.value?.currency ?? AppV2Constants.Business.defaultStoreCurrency
        )
    }
    
    var priceString: String {
        item.price.price.toCurrencyString(
            using: container.appState.value.userData.selectedStore.value?.currency ?? AppV2Constants.Business.defaultStoreCurrency
        )
    }
    
    init(container: DIContainer, menuItem: RetailStoreMenuItem) {
        self.container = container
        let appState = container.appState
        _basket = .init(initialValue: appState.value.userData.basket)
        self.item = menuItem
        
        setupBasket(with: appState)
        setupBasketQuantity()
        sendAppsFlyerContentViewEvent()
    }
    
    private func sendAppsFlyerContentViewEvent() {
        let params: [String: Any] = [
            AFEventParamContentId:item.id,
            "product_name":item.name,
            AFEventParamContentType:item.mainCategory.name
        ]
        container.eventLogger.sendEvent(for: .contentView, with: .appsFlyer, params: params)
    }
    
    private func setupBasket(with appState: Store<AppState>) {
        appState
            .map(\.userData.basket)
            .receive(on: RunLoop.main)
            .assignWeak(to: \.basket, on: self)
            .store(in: &cancellables)
    }
    
    private func setupBasketQuantity() {
        $basket
            .receive(on: RunLoop.main)
            .sink { [weak self] basket in
                guard let self = self else { return }
                if let basket = basket {
                    if basket.items.isEmpty {
                        self.basketQuantity = 0
                    } else {
                        for basketItem in basket.items {
                            if basketItem.menuItem.id == self.item.id {
                                self.basketQuantity = basketItem.quantity
                                break
                            } else {
                                self.basketQuantity = 0
                            }
                        }
                    }
                }
            }
            .store(in: &cancellables)
    }
}
