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
    
    let productDetail: RetailStoreMenuItem
    
    @State var quantity: Int = 0
    
    var body: some View {
        VStack {
            Button(action: { productsViewModel.productDetail = productDetail }) {
                if let imageURL = productDetail.images?.first?["xhdpi_2x"]?.absoluteString {
                    RemoteImage(url: imageURL)
                        .scaledToFit()
                } else {
                    Image("whiskey1")
                        .resizable()
                        .scaledToFit()
                }
            }
            
            VStack(alignment: .leading) {
                Button(action: { productsViewModel.productDetail = productDetail }) {
                    Text(productDetail.name)
                        .font(.snappyFootnote)
                        .padding(.bottom, 4)
                }
                
                Label("Vegetarian", systemImage: "checkmark.circle.fill")
                    .font(.snappyCaption)
                    .foregroundColor(.snappyTextGrey2)
                    .padding(.bottom, 4)
                
                HStack {
                    VStack(alignment: .leading) {
                        #warning("Change to localised currency")
                        Text("£\(productDetail.price.price)")
                            .font(.snappyFootnote)
                            .foregroundColor(.snappyRed)
                        
                        if let previousPrice = productDetail.price.wasPrice {
                            Text("£\(previousPrice)")
                                .font(.snappyCaption)
                                .foregroundColor(.snappyTextGrey2)
                        }
                    }
                    
                    Spacer()
                    
                    addButton
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
//        .overlay(
//            VStack {
//                HStack {
//                    if let offer = productDetail.offer {
//                        Text(offer)
//                            .font(.snappyCaption2)
//                            .fontWeight(.bold)
//                            .padding(EdgeInsets(top: 4, leading: 8, bottom: 4, trailing: 8))
//                            .foregroundColor(.white)
//                            .background(Capsule().fill(Color.snappyRed))
//                            .offset(x: 4, y: 4)
//                    }
//                    Spacer()
//                }
//                Spacer()
//            }
//            .padding(2)
//        )
    }
    
    @ViewBuilder var addButton: some View {
        if quantity == 0 {
            Button(action: { quantity = 1 }) {
                Text("Add +")
            }
            .buttonStyle(SnappyPrimaryButtonStyle())
        } else {
            HStack {
                Button(action: { quantity -= 1 }) {
                    Image(systemName: "minus.circle.fill")
                        .foregroundColor(.snappyBlue)
                }
                
                Text("\(quantity)")
                    .font(.snappyBody)
                
                Button(action: { quantity += 1 }) {
                    Image(systemName: "plus.circle.fill")
                        .foregroundColor(.snappyBlue)
                }
            }
        }
    }
}

struct ProductCardView_Previews: PreviewProvider {
    static var previews: some View {
        ProductCardView(productDetail: RetailStoreMenuItem(id: 123, name: "Some whiskey or other that possibly is not Scottish", eposCode: nil, outOfStock: false, ageRestriction: 18, description: nil, quickAdd: true, price: RetailStoreMenuItemPrice(price: 20.90, fromPrice: 0, unitMetric: "", unitsInPack: 0, unitVolume: 0, wasPrice: 24.45), images: nil, sizes: nil, options: nil))
            .previewLayout(.sizeThatFits)
            .padding()
            .previewCases()
    }
}
