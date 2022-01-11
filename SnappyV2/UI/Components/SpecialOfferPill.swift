//
//  SpecialOfferPill.swift
//  SnappyV2
//
//  Created by David Bage on 10/01/2022.
//

import SwiftUI

struct SpecialOfferPill: View {
    @ObservedObject var cardViewModel: ProductCardViewModel
    @ObservedObject var productsViewModel: ProductsViewModel
    
    struct Constants {
        static let cornerRadius: CGFloat = 20
        static let hPadding: CGFloat = 10
        static let vPadding: CGFloat = 5
    }
    
    var body: some View {
        Button(action: {
            if let offer = cardViewModel.latestOffer {
                productsViewModel.specialOfferPillTapped(offer: offer)
            }
        }) {
            Text(cardViewModel.latestOffer?.name ?? "")
                .padding(.horizontal, Constants.hPadding)
                .padding(.vertical, Constants.vPadding)
                .background(Color.snappyRed)
                .clipShape(RoundedRectangle(cornerRadius: Constants.cornerRadius))
                .foregroundColor(.white)
                .font(.snappyBadge)
        }
    }
}

struct SpecialOfferPill_Previews: PreviewProvider {
    static var previews: some View {
        SpecialOfferPill(cardViewModel: ProductCardViewModel(
            container: .preview,
            menuItem: RetailStoreMenuItem(id: 1, name: "Test product", eposCode: "",
                                          outOfStock: false, ageRestriction: 0, description: "", quickAdd: true,
                                          price: RetailStoreMenuItemPrice(price: 5.50,fromPrice: 4.45, unitMetric: "£", unitsInPack: 1, unitVolume: 1, wasPrice: 5.60),
                                          images: nil, menuItemSizes: nil, menuItemOptions: nil,
                                          availableDeals: [RetailStoreMenuItemAvailableDeal(id: 2, name: "25% off", type: "")])),
                         productsViewModel: ProductsViewModel(container: .preview))
    }
}
