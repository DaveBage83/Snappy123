//
//  ProductSubCategoryCardView.swift
//  SnappyV2Study
//
//  Created by Henrik Gustavii on 06/07/2021.
//

import SwiftUI

struct ProductSubCategoryCardView: View {
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var productsViewModel: ProductsViewModel
    
    let subCategoryDetails: ProductSubCategory
    
    var body: some View {
        Button(action: { productsViewModel.viewState = .result }) {
            HStack {
                Image(subCategoryDetails.image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 70, height: 70)
                    .cornerRadius(10)
                    .offset(x: -15, y: 16)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                
                
                HStack {
                    Text(subCategoryDetails.subCategoryName)
                        .font(.snappyBody)
                        .foregroundColor(colorScheme == .dark ? .white : .black)
                    
                    Spacer()
                }
            }
        }
        .frame(width: 350, height: 70)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(colorScheme == .dark ? Color.black : Color.white)
                .snappyShadow()
        )
    }
}

struct ProductSubCategory {
    let id = UUID()
    let subCategoryName: String
    let image: String
}

struct ProductSubcategoryCardView_Previews: PreviewProvider {
    static var previews: some View {
        ProductSubCategoryCardView(subCategoryDetails: ProductSubCategory(subCategoryName: "Drinks", image: "bottle-cats"))
            .previewLayout(.sizeThatFits)
            .padding()
            .previewCases()
    }
}
