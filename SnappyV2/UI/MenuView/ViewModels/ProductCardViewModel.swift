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
    
    @Published var showSearchProductCard = false
    
    var isReduced: Bool {
        itemDetail.price.wasPrice != nil
    }
    
    var wasPrice: String? {
        guard let wasPrice = itemDetail.price.wasPrice, wasPrice > 0 else { return nil }
        return wasPrice.toCurrencyString()
    }
    
    var calorieInfo: String? {
        itemDetail.itemCaptions?.portionSize
    }
    
    var hasFromPrice: Bool {
        itemDetail.price.fromPrice > 0
    }

    var latestOffer: RetailStoreMenuItemAvailableDeal? {
        /// Return offer with the highest id - this should be the latest offer
        itemDetail.availableDeals?.max { $0.id < $1.id }
    }
    
    init(container: DIContainer, menuItem: RetailStoreMenuItem) {
        self.container = container
        self.itemDetail = menuItem
    }
}
