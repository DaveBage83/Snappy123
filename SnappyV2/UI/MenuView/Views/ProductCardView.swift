//
//  ProductCardView.swift
//  SnappyV2Study
//
//  Created by Henrik Gustavii on 06/07/2021.
//

import SwiftUI

struct ProductCardView: View {
    
    struct Constants {
        static let width: CGFloat = 160
        static let height: CGFloat = 250
        static let padding: CGFloat = 8
        static let cornerRadius: CGFloat = 8
        
        struct ProductButton {
            static let padding: CGFloat = 4
        }
        
        struct ProductLabel {
            static let padding: CGFloat = 4
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
                            .padding(.bottom, 4)
                    }
                    
                    Label(Strings.ProductsView.ProductCard.vegetarian.localized, systemImage: "checkmark.circle.fill")
                        .font(.snappyCaption)
                        .foregroundColor(.snappyTextGrey2)
                        .padding(.bottom, 4)
                    
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
                        
                        if viewModel.isUpdatingQuantity {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .gray))
                        } else {
                            addButton
                        }
                    }
                }
            }
            .frame(width: Constants.width, height: Constants.height)
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
                
                HStack {
                    VStack(alignment: .leading) {
                        Text(Strings.ProductsView.ProductDetail.from.localized)
                            .font(.snappyCaption).bold()
                        
                        Text(viewModel.itemDetail.price.fromPrice.toCurrencyString())
                            .font(.snappyHeadline)
                            .foregroundColor(.snappyBlue)
                    }
                    
                    Spacer()
                    
                    if viewModel.isUpdatingQuantity {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .gray))
                    } else {
                        addButton
                    }
                }
            }
        }
        .frame(maxWidth: 343, maxHeight: 112)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(colorScheme == .dark ? Color.black : Color.white)
                .snappyShadow()
                .padding(4)
        )
    }
    
    @ViewBuilder var productImage: some View {
        if let imageURL = viewModel.itemDetail.images?.first?["xhdpi_2x"]?.absoluteString {
            #warning("Temporary: Change to future image handling system - ticket: SBG-685")
            RemoteImage(url: imageURL)
                .scaledToFit()
        } else {
            Image("whiskey1")
                .resizable()
                .scaledToFit()
        }
    }
    
    @ViewBuilder var addButton: some View {
        if viewModel.quickAddIsEnabled {
            quickAddButton
        } else {
            standardAddButton
        }
    }
    
    @ViewBuilder var quickAddButton: some View {
        if viewModel.basketQuantity == 0 {
            standardAddButton
        } else {
            HStack {
                Button(action: { viewModel.removeItem() }) {
                    Image.Actions.Remove.circleFilled
                        .foregroundColor(.snappyBlue)
                }
                
                Text("\(viewModel.basketQuantity)")
                    .font(.snappyBody)
                
                Button(action: { viewModel.addItem() }) {
                    Image.Actions.Add.circleFilled
                        .foregroundColor(.snappyBlue)
                }
            }
        }
    }
    
    @ViewBuilder var standardAddButton: some View {
        if viewModel.itemHasOptionsOrSizes {
            Button(action: { productsViewModel.itemOptions = viewModel.itemDetail }) {
                Text(GeneralStrings.add.localized)
            }
            .buttonStyle(SnappyPrimaryButtonStyle())
        } else {
            Button(action: { viewModel.addItem() }) {
                Text(GeneralStrings.add.localized)
            }
            .buttonStyle(SnappyPrimaryButtonStyle())
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
