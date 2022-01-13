//
//  ProductSubCategoryCardView.swift
//  SnappyV2Study
//
//  Created by Henrik Gustavii on 06/07/2021.
//

import SwiftUI

struct ProductSubCategoryCardView: View {
    @Environment(\.colorScheme) var colorScheme
    
    let subCategoryDetails: RetailStoreMenuCategory
    
    var body: some View {
        HStack {
            if let imageURL = subCategoryDetails.image?["xhdpi_2x"]?.absoluteString {
                RemoteImage(url: imageURL) // Temporary: To be removed for more suitable image loading
                    .scaledToFit()
                    .frame(width: 150, height: 190)
                    .cornerRadius(10)
                    .offset(x: -30, y: 70)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            } else {
                Image.Products.bottles
                    .resizable()
                    .scaledToFit()
                    .frame(width: 70, height: 70)
                    .cornerRadius(10)
                    .offset(x: -15, y: 16)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }
            
            HStack {
                Text(subCategoryDetails.name)
                    .font(.snappyBody)
                    .foregroundColor(colorScheme == .dark ? .white : .black)
                
                Spacer()
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

struct ProductSubcategoryCardView_Previews: PreviewProvider {
    static var previews: some View {
        ProductSubCategoryCardView(subCategoryDetails: RetailStoreMenuCategory(id: 123, parentId: 12, name: "Drinks", image: nil))
            .previewLayout(.sizeThatFits)
            .padding()
            .previewCases()
    }
}
