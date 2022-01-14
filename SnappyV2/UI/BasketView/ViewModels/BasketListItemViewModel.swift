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
    @Published var item: BasketItem
    @Published var quantity: String = ""
    var changeQuantity: (_ itemId: Int, _ quantity: Int, _ basketLineId: Int) -> Void
    private var cancellables = Set<AnyCancellable>()
    var hasMissedPromotions = false
    var latestMissedPromotion: BasketItemMissedPromotion?
    
    init(container: DIContainer, item: BasketItem, changeQuantity: @escaping (Int, Int, Int) -> Void) {
        self.item = item
        self.changeQuantity = changeQuantity
        self.container = container
        
        updateMissedPromotions()
    }
    
    func onSubmit() {
        changeQuantity(item.menuItem.id ,Int(quantity) ?? 0, item.basketLineId)
        quantity = ""
    }
    
    func filterQuantityToStringNumber(stringValue: String) {
        let filtered = stringValue.filter { $0.isNumber }
        
        if quantity != filtered {
            quantity = filtered
        }
    }
    
    func updateMissedPromotions() {
        $item
            .sink { item in
                if let missedPromos = item.missedPromotions {
                    self.hasMissedPromotions = true
                    self.latestMissedPromotion = missedPromos.max { $0.referenceId < $1.referenceId } // Get latest missed promo
                } else {
                    self.hasMissedPromotions = false
                    self.latestMissedPromotion = nil // Reset missed promos to nil
                }
            }
            .store(in: &cancellables)
    }
}
