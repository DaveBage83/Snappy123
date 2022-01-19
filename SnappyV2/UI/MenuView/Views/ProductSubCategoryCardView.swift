//
//  ProductSubCategoryCardView.swift
//  SnappyV2Study
//
//  Created by Henrik Gustavii on 06/07/2021.
//

import SwiftUI

struct ProductSubCategoryCardView: View {
    struct Constants {
        static let cornerRadius: CGFloat = 8
        static let clipShapeCornerRadius: CGFloat = 8
        static let width: CGFloat = 350
        static let height: CGFloat = 70
        
        struct RemoteImage {
            static let width: CGFloat = 150
            static let height: CGFloat = 190
            static let offsetX: CGFloat = -30
            static let offsetY: CGFloat = 70
            static let cornerRadius: CGFloat = 10
        }
        
        struct PlaceholderImage {
            static let width: CGFloat = 70
            static let height: CGFloat = 70
            static let offsetX: CGFloat = -15
            static let offsetY: CGFloat = 16
            static let cornerRadius: CGFloat = Constants.RemoteImage.cornerRadius
        }
    }
    
    @Environment(\.colorScheme) var colorScheme
    
    let subCategoryDetails: RetailStoreMenuCategory
    
    var body: some View {
        HStack {
            if let imageURL = subCategoryDetails.image?["xhdpi_2x"]?.absoluteString {
                RemoteImage(url: imageURL) // Temporary: To be removed for more suitable image loading
                    .scaledToFit()
                    .frame(width: Constants.RemoteImage.width, height: Constants.RemoteImage.height)
                    .cornerRadius(Constants.RemoteImage.cornerRadius)
                    .offset(x: Constants.RemoteImage.offsetX, y: Constants.RemoteImage.offsetY)
                    .clipShape(RoundedRectangle(cornerRadius: Constants.clipShapeCornerRadius))
            } else {
                Image.Products.bottles
                    .resizable()
                    .scaledToFit()
                    .frame(width: Constants.PlaceholderImage.width, height: Constants.PlaceholderImage.height)
                    .cornerRadius(Constants.PlaceholderImage.cornerRadius)
                    .offset(x: Constants.PlaceholderImage.offsetX, y: Constants.PlaceholderImage.offsetY)
                    .clipShape(RoundedRectangle(cornerRadius: Constants.clipShapeCornerRadius))
            }
            
            HStack {
                Text(subCategoryDetails.name)
                    .font(.snappyBody)
                    .foregroundColor(colorScheme == .dark ? .white : .black)
                
                Spacer()
            }
        }
        .frame(width: Constants.width, height: Constants.height)
        .background(
            RoundedRectangle(cornerRadius: Constants.cornerRadius)
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
