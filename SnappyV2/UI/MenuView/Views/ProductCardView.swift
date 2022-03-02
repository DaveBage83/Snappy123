//
//  ProductCardView.swift
//  SnappyV2Study
//
//  Created by Henrik Gustavii on 06/07/2021.
//

import SwiftUI

struct ProductCardView: View {
    
    struct Constants {
        static let padding: CGFloat = 8
        static let cornerRadius: CGFloat = 8
        
        struct ProductButton {
            static let padding: CGFloat = 4
        }
        
        struct ProductLabel {
            static let padding: CGFloat = 4
        }
        
        struct Card {
            static let standardCardWidth: CGFloat = 160
            static let standardCardHeight: CGFloat = 250
            static let searchCardHeight: CGFloat = 112
            static let searchCardWidth: CGFloat = 343
            static let padding: CGFloat = 4
            static let cornerRadius: CGFloat = 10
        }
    }
    
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var productsViewModel: ProductsViewModel
    @StateObject var viewModel: ProductCardViewModel
    
    var body: some View {
        if viewModel.showSearchProductCard {
            searchProductCard()
        } else {
            standardProductCard()
        }
    }
    
    func standardProductCard() -> some View {
        ZStack(alignment: .topLeading) {
            VStack {
                Button(action: { productsViewModel.productDetail = viewModel.itemDetail }) {
                    productImage
                }
                
                VStack(alignment: .leading) {
                    Button(action: { productsViewModel.productDetail = viewModel.itemDetail }) {
                        Text(viewModel.itemDetail.name)
                            .font(.snappyFootnote)
                            .padding(.bottom, Constants.Card.padding)
                    }
                    
                    Label(Strings.ProductsView.ProductCard.vegetarian.localized, systemImage: "checkmark.circle.fill")
                        .font(.snappyCaption)
                        .foregroundColor(.snappyTextGrey2)
                        .padding(.bottom, Constants.Card.padding)
                    
                    HStack {
                        VStack(alignment: .leading) {
                            Text(viewModel.itemDetail.price.price.toCurrencyString())
                                .font(.snappyFootnote)
                                .foregroundColor(.snappyRed)
                            
                            if let previousPrice = viewModel.itemDetail.price.wasPrice, previousPrice > 0 {
                                Text(previousPrice.toCurrencyString())
                                    .font(.snappyCaption)
                                    .foregroundColor(.snappyTextGrey2)
                            }
                        }
                        
                        Spacer()
                        
                        ProductAddButton(viewModel: .init(container: viewModel.container, menuItem: viewModel.itemDetail))
                    }
                }
            }
            .frame(width: Constants.Card.standardCardWidth, height: Constants.Card.standardCardHeight)
            .padding(Constants.padding)
            .background(
                RoundedRectangle(cornerRadius: Constants.cornerRadius)
                    .fill(colorScheme == .dark ? Color.black : Color.white)
                    .snappyShadow()
            )
            
            #warning("Consider moving logic into viewModel")
            if let latestOffer = viewModel.latestOffer, productsViewModel.viewState != .offers {
                Button {
                    productsViewModel.specialOfferPillTapped(offer: latestOffer)
                } label: {
                    SpecialOfferPill(offerText: latestOffer.name)
                }
                .padding()
            }
        }
    }
    
    func searchProductCard() -> some View {
        HStack {
            Button(action: { productsViewModel.productDetail = viewModel.itemDetail }) {
                productImage
            }
            
            VStack(alignment: .leading) {
                Button(action: { productsViewModel.productDetail = viewModel.itemDetail }) {
                    Text(viewModel.itemDetail.name)
                        .font(.snappyBody)
                }
                
                Spacer()
                
                Spacer()
                
                HStack {
                    VStack(alignment: .leading) {
                        Text(Strings.ProductsView.ProductDetail.from.localized)
                            .font(.snappyCaption).bold()
                        
                        Text(viewModel.itemDetail.price.fromPrice.toCurrencyString())
                            .font(.snappyHeadline)
                            .foregroundColor(.snappyBlue)
                    }
                    
                    Spacer()
                    
                    ProductAddButton(viewModel: .init(container: viewModel.container, menuItem: viewModel.itemDetail))
                }
            }
        }
        .frame(maxWidth: Constants.Card.searchCardWidth, maxHeight: Constants.Card.searchCardHeight)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: Constants.Card.cornerRadius)
                .fill(colorScheme == .dark ? Color.black : Color.white)
                .snappyShadow()
                .padding(Constants.Card.padding)
        )
    }
    
    @ViewBuilder var productImage: some View {
        if let image = viewModel.itemDetail.images?.first?["xhdpi_2x"]?.absoluteString,
           let imageURL = URL(string: image) {
            RemoteImageView(imageURL: imageURL, container: viewModel.container)
                .scaledToFit()
        } else {
            Image("whiskey1")
                .resizable()
                .scaledToFit()
        }
    }
}

struct ProductCardView_Previews: PreviewProvider {
    static var previews: some View {
        ProductCardView(viewModel: .init(container: .preview, menuItem: RetailStoreMenuItem(id: 123, name: "Some whiskey or other that possibly is not Scottish", eposCode: nil, outOfStock: false, ageRestriction: 18, description: nil, quickAdd: true, price: RetailStoreMenuItemPrice(price: 20.90, fromPrice: 0, unitMetric: "", unitsInPack: 0, unitVolume: 0, wasPrice: 24.45), images: nil, menuItemSizes: nil, menuItemOptions: nil, availableDeals: nil), showSearchProductCard: false))
            .environmentObject(ProductsViewModel(container: .preview))
            .previewLayout(.sizeThatFits)
            .padding()
            .previewCases()
    }
}
