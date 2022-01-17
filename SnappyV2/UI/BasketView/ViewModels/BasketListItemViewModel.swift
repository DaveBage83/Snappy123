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
    var changeQuantity: (_ itemId: Int, _ quantity: Int, _ basketLineId: Int) -> Void
    private var cancellables = Set<AnyCancellable>()
    var hasMissedPromotions = false
    var latestMissedPromotion: BasketItemMissedPromotion?
    
    init(container: DIContainer, item: BasketItem, changeQuantity: @escaping (Int, Int, Int) -> Void) {
        self.item = item
        self.changeQuantity = changeQuantity
        self.container = container
        
        if let missedPromos = item.missedPromotions {
            setupMissedPromotions(promos: missedPromos)
        }
    }
    
    func onSubmit() {
        changeQuantity(item.menuItem.id ,Int(quantity) ?? 0, item.basketLineId)
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
}
