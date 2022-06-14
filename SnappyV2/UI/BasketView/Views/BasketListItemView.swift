//
//  BasketListItemView.swift
//  SnappyV2
//
//  Created by Henrik Gustavii on 03/01/2022.
//

import SwiftUI
import Combine

struct BasketListItemView: View {
    struct Constants {
        static let cornerRadius: CGFloat = 4
        
        struct ProductInfo {
            static let height: CGFloat = 40
            static let padding: CGFloat = 4
        }
        
        struct Container {
            static let missingOfferColor = Color.snappyOfferBasket.opacity(0.3)
        }
    }
    @StateObject var viewModel: BasketListItemViewModel
    
    var body: some View {
        VStack {
            HStack {
                if let image = viewModel.item.menuItem.images?.first?[AppV2Constants.API.imageScaleFactor]?.absoluteString,
                   let imageURL = URL(string: image)  {
                    RemoteImageView(viewModel: .init(container: viewModel.container, imageURL: imageURL))                        
                        .scaledToFit()
                } else {
                    Image("whiskey")
                        .resizable()
                        .scaledToFit()
                }
                
                Text(viewModel.item.menuItem.price.price.toCurrencyString() + " - \(viewModel.item.menuItem.name)")
                    .font(.snappyCaption)
                
                Spacer()
                
                #warning("Sort out iOS 14 versions of onSubmit")
                if #available(iOS 15.0, *) {
                    TextField("\(viewModel.item.quantity)", text: $viewModel.quantity)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .font(.snappyBody)
                        .scaledToFit()
                        .keyboardType(.numbersAndPunctuation)
                        .submitLabel(.done)
                        // adapted from: https://stackoverflow.com/questions/58733003/swiftui-how-to-create-textfield-that-only-accepts-numbers
                        .onReceive(Just(viewModel.quantity)) { newValue in
                            viewModel.filterQuantityToStringNumber(stringValue: newValue)
                        }
                        .onSubmit {
                            viewModel.onSubmit()
                        }
                } else {
                    TextField("\(viewModel.item.quantity)", text: $viewModel.quantity)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .font(.snappyBody)
                        .scaledToFit()
                        .keyboardType(.decimalPad)
                    // adapted from: https://stackoverflow.com/questions/58733003/swiftui-how-to-create-textfield-that-only-accepts-numbers
                        .onReceive(Just(viewModel.quantity)) { newValue in
                            viewModel.filterQuantityToStringNumber(stringValue: newValue)
                        }
                }
                
                Text(viewModel.item.totalPrice.toCurrencyString())
                    .font(.snappyBody)
            }
            .frame(height: Constants.ProductInfo.height)
            .padding([.horizontal, .top], Constants.ProductInfo.padding)
            
            if let latestMissedPromo = viewModel.latestMissedPromotion {
                NavigationLink {
                    ProductsView(viewModel: .init(container: viewModel.container, missedOffer: latestMissedPromo))
                } label: {
                    MissedPromotionsBanner(text: Strings.BasketView.Promotions.missed.localizedFormat(latestMissedPromo.name))
                        .multilineTextAlignment(.leading)
                }
            }
        }
        .background(viewModel.hasMissedPromotions ? Constants.Container.missingOfferColor : .clear)
        .cornerRadius(Constants.cornerRadius)
    }
}

#if DEBUG
struct BasketListItemView_Previews: PreviewProvider {
    static var previews: some View {
        BasketListItemView(viewModel: .init(
            container: .preview, item: BasketItem(basketLineId: 123, menuItem: RetailStoreMenuItem(id: 12, name: "Some Product Name", eposCode: nil, outOfStock: false, ageRestriction: 0, description: nil, quickAdd: true, acceptCustomerInstructions: false, basketQuantityLimit: 500, price: RetailStoreMenuItemPrice(price: 10, fromPrice: 9, unitMetric: "", unitsInPack: 0, unitVolume: 0, wasPrice: nil), images: nil, menuItemSizes: nil, menuItemOptions: nil, availableDeals: nil, itemCaptions: ["portionSize": "495 Kcal per 100g"]), totalPrice: 10, totalPriceBeforeDiscounts: 9, price: 9, pricePaid: 4, quantity: 1, instructions: nil, size: nil, selectedOptions: nil, missedPromotions: [BasketItemMissedPromotion(referenceId: 123, name: "3 for 2", type: .discount, missedSections: nil)])) {_, _, _ in })
            .previewLayout(.sizeThatFits)
            .padding()
            .previewCases()
    }
}
#endif
