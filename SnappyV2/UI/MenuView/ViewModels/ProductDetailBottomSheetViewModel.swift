//
//  ProductDetailBottomSheetViewModel.swift
//  SnappyV2
//
//  Created by Henrik Gustavii on 21/03/2022.
//

import Foundation
import Combine

// 3rd party
import AppsFlyerLib
import Firebase

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
        sendContentViewEvent(with: appState)
    }
    
    private func sendContentViewEvent(with appState: Store<AppState>) {
        let appsFlyerParams: [String: Any] = [
            AFEventParamContentId: item.id,
            "product_name": item.name,
            AFEventParamContentType: item.mainCategory.name
        ]
        container.eventLogger.sendEvent(for: .viewItemDetail, with: .appsFlyer, params: appsFlyerParams)
        
        let iterableParams: [String: Any] = [
            "itemId": item.id,
            "name": item.name,
            "storeId": container.appState.value.userData.selectedStore.value?.id ?? 0
        ]
        container.eventLogger.sendEvent(for: .viewItemDetail, with: .iterable, params: iterableParams)

        let value = NSDecimalNumber(value: item.price.fromPrice).rounding(accordingToBehavior: EventLogger.decimalBehavior).doubleValue

        let itemValues: [String: Any] = [
            AnalyticsParameterItemID: AppV2Constants.EventsLogging.analyticsItemIdPrefix + "\(item.id)",
            AnalyticsParameterItemName: item.name,
            AnalyticsParameterPrice: value,
        ]
        
        let firebaseParams: [String: Any] = [
            AnalyticsParameterCurrency: appState.value.userData.selectedStore.value?.currency.currencyCode ?? AppV2Constants.Business.currencyCode,
            AnalyticsParameterValue: NSDecimalNumber(value: value).rounding(accordingToBehavior: EventLogger.decimalBehavior).doubleValue,
            AnalyticsParameterItems: [itemValues]
        ]
        container.eventLogger.sendEvent(for: .viewItemDetail, with: .firebaseAnalytics, params: firebaseParams)
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
