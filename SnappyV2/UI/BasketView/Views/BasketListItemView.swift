//
//  BasketListItemView.swift
//  SnappyV2
//
//  Created by Henrik Gustavii on 03/01/2022.
//

import SwiftUI
import Combine

struct BasketListItemView: View {
    @Environment(\.colorScheme) var colorScheme
    
    struct Constants {
        static let cornerRadius: CGFloat = 4
        
        struct ProductInfo {
            static let height: CGFloat = 40
            static let padding: CGFloat = 4
        }
        
        struct Container {
            static let missingOfferColor = Color.snappyOfferBasket.opacity(0.3)
        }
        
        struct ItemImage {
            static let size: CGFloat = 56
            static let cornerRadius: CGFloat = 8
            static let lineWidth: CGFloat = 1
        }
    }
    @StateObject var viewModel: BasketListItemViewModel
    
    private var colorPalette: ColorPalette {
        ColorPalette(container: viewModel.container, colorScheme: colorScheme)
    }
    
    var body: some View {
            VStack {
                HStack(spacing: 12) {
                    
                    itemImage
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text(viewModel.item.menuItem.name)
                            .font(.Body2.regular())
                            .foregroundColor(colorPalette.typefacePrimary)
                        
                        Text("\(viewModel.item.menuItem.price.price.toCurrencyString()) each")
                            .fixedSize(horizontal: true, vertical: false)
                            .multilineTextAlignment(.leading)
                            .font(.Body2.semiBold())
                            .foregroundColor(colorPalette.typefacePrimary)
                    }
                    
                    
                    Spacer()
                    
                    VStack(alignment: .trailing) {
                        productIncrementButton
                        
                        Text(viewModel.item.totalPrice.toCurrencyString())
                            .font(.heading4())
                            .foregroundColor(colorPalette.primaryBlue)
                    }
                    
                }
                .padding([.top, .leading, .trailing], viewModel.hasMissedPromotions ? 8 : 0)
                .cornerRadius(8, corners: [.topLeft, .topRight])
                
                if let latestMissedPromo = viewModel.latestMissedPromotion {
                    NavigationLink {
                        ProductsView(viewModel: .init(container: viewModel.container, missedOffer: latestMissedPromo))
                    } label: {
                        ZStack {
                            MissedPromotionsBanner(container: viewModel.container, text: Strings.BasketView.Promotions.missed.localizedFormat(latestMissedPromo.name))
                                .multilineTextAlignment(.leading)
                        }
                    }
                }
            }
            .background(viewModel.hasMissedPromotions ? colorPalette.offer.withOpacity(.ten) : .clear)
        .cornerRadius(Constants.cornerRadius)
    }
    
    private var productIncrementButton: some View {
        ProductIncrementButton(viewModel: .init(container: viewModel.container, menuItem: viewModel.item.menuItem), size: .standard)
    }
    
    private var itemImage: some View {
        AsyncImage(urlString: viewModel.item.menuItem.images?.first?[AppV2Constants.API.imageScaleFactor]?.absoluteString, placeholder: {
            Image.Placeholders.productPlaceholder
                .resizable()
                .frame(width: Constants.ItemImage.size, height: Constants.ItemImage.size)
                .scaledToFit()
                .cornerRadius(Constants.ItemImage.cornerRadius)
        })
        .frame(width: Constants.ItemImage.size, height: Constants.ItemImage.size)
        .scaledToFit()
        .cornerRadius(Constants.ItemImage.cornerRadius)
        .overlay(
            RoundedRectangle(cornerRadius: Constants.ItemImage.cornerRadius)
                .fill(colorPalette.textGrey1.withOpacity(.ten))
        )
    }
}

#if DEBUG
struct BasketListItemView_Previews: PreviewProvider {
    static var previews: some View {
        BasketListItemView(viewModel: .init(
            container: .preview, item: BasketItem(basketLineId: 123, menuItem: RetailStoreMenuItem(id: 12, name: "Some Product Name", eposCode: nil, outOfStock: false, ageRestriction: 0, description: nil, quickAdd: true, acceptCustomerInstructions: false, basketQuantityLimit: 500, price: RetailStoreMenuItemPrice(price: 10, fromPrice: 9, unitMetric: "", unitsInPack: 0, unitVolume: 0, wasPrice: nil), images: nil, menuItemSizes: nil, menuItemOptions: nil, availableDeals: nil, itemCaptions: ItemCaptions(portionSize: "495 Kcal per 100g"), mainCategory: MenuItemCategory(id: 0, name: "")), totalPrice: 10, totalPriceBeforeDiscounts: 9, price: 9, pricePaid: 4, quantity: 1, instructions: nil, size: nil, selectedOptions: nil, missedPromotions: [BasketItemMissedPromotion(referenceId: 123, name: "3 for 2", type: .discount, missedSections: nil)])) {_, _ in })
            .previewLayout(.sizeThatFits)
            .padding()
            .previewCases()
    }
}
#endif
