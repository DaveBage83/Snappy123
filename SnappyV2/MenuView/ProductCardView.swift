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
    
    let productDetail: ProductDetail
    
    @State var quantity: Int = 0
    
    var body: some View {
        VStack {
            Button(action: { productsViewModel.productDetail = productDetail }) {
                Image(productDetail.image)
                    .resizable()
                    .scaledToFit()
            }
            
            VStack(alignment: .leading) {
                Button(action: { productsViewModel.productDetail = productDetail }) {
                    Text(productDetail.label)
                        .font(.snappyFootnote)
                        .padding(.bottom, 4)
                }
                
                Label("Vegetarian", systemImage: "checkmark.circle.fill")
                    .font(.snappyCaption)
                    .foregroundColor(.snappyTextGrey2)
                    .padding(.bottom, 4)
                
                HStack {
                    VStack(alignment: .leading) {
                        Text(productDetail.currentPrice)
                            .font(.snappyFootnote)
                            .foregroundColor(.snappyRed)
                        
                        if let previousPrice = productDetail.previousPrice {
                            Text(previousPrice)
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
        .overlay(
            VStack {
                HStack {
                    if let offer = productDetail.offer {
                        Text(offer)
                            .font(.snappyCaption2)
                            .fontWeight(.bold)
                            .padding(EdgeInsets(top: 4, leading: 8, bottom: 4, trailing: 8))
                            .foregroundColor(.white)
                            .background(Capsule().fill(Color.snappyRed))
                            .offset(x: 4, y: 4)
                    }
                    Spacer()
                }
                Spacer()
            }
            .padding(2)
        )
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

struct ProductDetail: Equatable, Identifiable {
    let id = UUID()
    let label: String
    let image: String
    let currentPrice: String
    let previousPrice: String?
    let offer: String?
    let description: String?
    let ingredients: String?
}

struct ProductCardView_Previews: PreviewProvider {
    static var previews: some View {
        ProductCardView(productDetail: ProductDetail(label: "Some whiskey or other that possibly is not Scottish", image: "whiskey1", currentPrice: "£20.90", previousPrice: "£24.45", offer: "20% off", description: nil, ingredients: nil))
            .previewLayout(.sizeThatFits)
            .padding()
            .previewCases()
    }
}
