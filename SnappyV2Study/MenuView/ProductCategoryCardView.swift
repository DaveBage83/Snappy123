//
//  ProductCategoryCardView.swift
//  SnappyV2Study
//
//  Created by Henrik Gustavii on 23/06/2021.
//

import SwiftUI

struct ProductCategoryCardView: View {
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var productsViewModel: ProductsViewModel
    
    let categoryDetails: ProductCategory
    
    var body: some View {
        ZStack {
            Image(categoryDetails.image)
                .resizable()
                .scaledToFit()
                .frame(width: 150, height: 190)
                .cornerRadius(10)
                .offset(x: -30, y: 70)
                .clipShape(RoundedRectangle(cornerRadius: 8))
            
            Button(action: { productsViewModel.viewState = .subCategory }) {
                VStack {
                    HStack {
                        Text(categoryDetails.categoryName)
                            .font(.snappyBody)
                            .foregroundColor(colorScheme == .dark ? .white : .black)
                        
                        Spacer()
                    }
                    .padding(.top, 10)
                    .padding(.leading, 15)
                    
                    Spacer()
                }
            }
        }
        .frame(width: 150, height: 190)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(colorScheme == .dark ? Color.black : Color.white)
                .shadow(.grey16, x: 0, y: 5)
        )
    }
}

struct ProductCategory {
    let id = UUID()
    let categoryName: String
    let image: String
}

struct ProductCategoryCardView_Previews: PreviewProvider {
    static var previews: some View {
        ProductCategoryCardView(categoryDetails: ProductCategory(categoryName: "Drinks", image: "bottle-cats"))
            .previewLayout(.sizeThatFits)
            .padding()
            .previewCases()
    }
}
