//
//  ProductCardView.swift
//  SnappyV2Study
//
//  Created by Henrik Gustavii on 06/07/2021.
//

import SwiftUI

struct ProductCardView: View {
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var productsViewModel: ProductsViewModel
    @StateObject var viewModel: ProductCardViewModel
    
    var body: some View {
        if viewModel.showItemOptions {
            ProductOptionsView(viewModel: .init(container: viewModel.container, item: viewModel.itemDetail))
        } else {
            VStack {
                Button(action: { productsViewModel.productDetail = viewModel.itemDetail }) {
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
                            #warning("Change to localised currency")
                            Text(viewModel.itemDetail.price.price.toCurrencyString())
                                .font(.snappyFootnote)
                                .foregroundColor(.snappyRed)
                            
                            if let previousPrice = viewModel.itemDetail.price.wasPrice {
                                Text(previousPrice.toCurrencyString())
                                    .font(.snappyCaption)
                                    .foregroundColor(.snappyTextGrey2)
                            }
                        }
                        
                        Spacer()
                        
                        if viewModel.quickAddIsEnabled {
                            quickAddButton
                        } else {
                            addButton
                        }
                    }
                }
                
            }
            .frame(width: 160, height: 250)
            .padding(8)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(colorScheme == .dark ? Color.black : Color.white)
                    .snappyShadow()
            )
        }
    }
    
    @ViewBuilder var quickAddButton: some View {
        if viewModel.basketQuantity == 0 {
            addButton
        } else {
            HStack {
                Button(action: { viewModel.removeItem() }) {
                    Image(systemName: "minus.circle.fill")
                        .foregroundColor(.snappyBlue)
                }
                
                Text("\(viewModel.basketQuantity)")
                    .font(.snappyBody)
                
                Button(action: { viewModel.addItem() }) {
                    Image(systemName: "plus.circle.fill")
                        .foregroundColor(.snappyBlue)
                }
            }
        }
    }
    
    @ViewBuilder var addButton: some View {
        if viewModel.itemHasOptionsOrSizes {
            Button(action: { productsViewModel.itemOptions = viewModel.itemDetail }) {
                if viewModel.isUpdatingQuantity {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                } else {
                    Text(GeneralStrings.add.localized)
                }
            }
            .buttonStyle(SnappyPrimaryButtonStyle())
            .disabled(viewModel.isUpdatingQuantity)
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
        ProductCardView(viewModel: .init(container: .preview, menuItem: RetailStoreMenuItem(id: 123, name: "Some whiskey or other that possibly is not Scottish", eposCode: nil, outOfStock: false, ageRestriction: 18, description: nil, quickAdd: true, price: RetailStoreMenuItemPrice(price: 20.90, fromPrice: 0, unitMetric: "", unitsInPack: 0, unitVolume: 0, wasPrice: 24.45), images: nil, menuItemSizes: nil, menuItemOptions: nil, availableDeals: nil)))
            .environmentObject(ProductsViewModel(container: .preview))
            .previewLayout(.sizeThatFits)
            .padding()
            .previewCases()
    }
}
