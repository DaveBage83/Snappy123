//
//  BasketListItemViewModel.swift
//  SnappyV2
//
//  Created by David Bage on 17/01/2022.
//

import Foundation
import Combine

class BasketListItemViewModel: ObservableObject {
    let container: DIContainer
    var item: BasketItem
    @Published var quantity: String = ""
    @Published var showMissedPromoItems = false
    var changeQuantity: (_ basketItem: BasketItem, _ quantity: Int) -> Void
    private var cancellables = Set<AnyCancellable>()
    var hasMissedPromotions = false
    var latestMissedPromotion: BasketItemMissedPromotion?
    
    var priceString: String {
        item.menuItem.price.price.toCurrencyString(using: container.appState.value.userData.selectedStore.value?.currency ?? AppV2Constants.Business.defaultStoreCurrency)
    }
    
    var totalPriceString: String {
        item.totalPrice.toCurrencyString(using: container.appState.value.userData.selectedStore.value?.currency ?? AppV2Constants.Business.defaultStoreCurrency)
    }

    init(container: DIContainer, item: BasketItem, changeQuantity: @escaping (BasketItem, Int) -> Void) {
        self.item = item
        self.changeQuantity = changeQuantity
        self.container = container
        
        if let missedPromos = item.missedPromotions {
            setupMissedPromotions(promos: missedPromos)
        }
    }
    
    func onSubmit() {
        changeQuantity(item ,Int(quantity) ?? 0)
        quantity = ""
    }
    
    private func setupMissedPromotions(promos: [BasketItemMissedPromotion]) {
        self.hasMissedPromotions = true
        self.latestMissedPromotion = promos.max { $0.referenceId < $1.referenceId }
    }
    
    func filterQuantityToStringNumber(stringValue: String) {
        let filtered = stringValue.filter { $0.isNumber }
        
        if quantity != filtered {
            quantity = filtered
        }
    }
    
    func showMissedPromoItemsTapped() {
        showMissedPromoItems = true
    }
}
