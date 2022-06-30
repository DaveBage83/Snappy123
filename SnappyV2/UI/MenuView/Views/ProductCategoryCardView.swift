//
//  ProductSubCategoryCardView.swift
//  SnappyV2Study
//
//  Created by Henrik Gustavii on 06/07/2021.
//

import SwiftUI

struct ProductCategoryCardView: View {
    // MARK: - Environment objects
    @Environment(\.colorScheme) var colorScheme
    @ScaledMetric var scale: CGFloat = 1 // Used to scale icon for accessibility options
    
    // MARK: - Constants
    struct Constants {
        static let cornerRadius: CGFloat = 8
        static let clipShapeCornerRadius: CGFloat = 8
        static let width: CGFloat = 350
        static let height: CGFloat = 72
        static let spacing: CGFloat = 10
        static let hPadding: CGFloat = 10
        
        struct ItemImage {
            static let padding: CGFloat = 5
            static let size: CGFloat = 60
            static let cornerRadius: CGFloat = 8
            static let backgroundOpacity: CGFloat = 0.07
        }
    }
    
    // MARK: - Properties
    let container: DIContainer
    let categoryDetails: RetailStoreMenuCategory
    
    // MARK: - Computed variables
    private var colorPalette: ColorPalette {
        ColorPalette(container: container, colorScheme: colorScheme)
    }
    
    // MARK: - Main body
    var body: some View {
        HStack(spacing: Constants.spacing) {
            itemImage
            itemDescription
        }
        .padding(.horizontal, Constants.hPadding)
        .frame(height: Constants.height * scale)
        .background(colorPalette.secondaryWhite)
        .standardCardFormat()
    }
    
    // MARK: - Item image
    private var itemImage: some View {
        AsyncImage(urlString: categoryDetails.image?[AppV2Constants.API.imageScaleFactor]?.absoluteString, placeholder: {
            Image.Placeholders.productPlaceholder
                .resizable()
                .cornerRadius(Constants.ItemImage.cornerRadius)
            
                .scaledToFit()
                .padding(Constants.ItemImage.padding)
        })
        .scaledToFit()
        .cornerRadius(Constants.ItemImage.cornerRadius)
        .frame(width: Constants.ItemImage.size * scale)
        .padding(Constants.ItemImage.padding)
        .overlay(
            RoundedRectangle(cornerRadius: Constants.ItemImage.cornerRadius)
                .fill(colorPalette.textGrey1.opacity(Constants.ItemImage.backgroundOpacity))
            
        )
        .frame(width: Constants.ItemImage.size * scale, height: Constants.ItemImage.size * scale)
        .padding(Constants.ItemImage.padding)
        
    }
    
    // MARK: - Item description
    private var itemDescription: some View {
        HStack {
            Text(categoryDetails.name)
                .font(.heading4())
                .foregroundColor(colorPalette.primaryBlue)
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true) // stops text from truncating when long
            
            Spacer()
        }
    }
}

#if DEBUG
struct ProductCategoryCardView_Previews: PreviewProvider {

    static var previews: some View {
        Group {
            ProductCategoryCardView(container: .preview, categoryDetails: RetailStoreMenuCategory(id: 123, parentId: 21, name: "Drinks", image: nil, description: ""))
            
            ProductCategoryCardView(container: .preview, categoryDetails: RetailStoreMenuCategory(id: 123, parentId: 21, name: "Drinks", image: nil, description: ""))
        }
        .previewLayout(.sizeThatFits)
        .padding()
    }
}
#endif
