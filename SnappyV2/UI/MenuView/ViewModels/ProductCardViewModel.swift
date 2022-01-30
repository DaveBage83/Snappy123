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
    
    var latestOffer: RetailStoreMenuItemAvailableDeal? {
        /// Return offer with the highest id - this should be the latest offer
        itemDetail.availableDeals?.max { $0.id < $1.id }
    }
    
    init(container: DIContainer, menuItem: RetailStoreMenuItem, showSearchProductCard: Bool = false) {
        self.container = container
        self.itemDetail = menuItem
        
        self.showSearchProductCard = showSearchProductCard
    }
}
