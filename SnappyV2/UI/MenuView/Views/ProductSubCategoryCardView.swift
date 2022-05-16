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
        static let height: CGFloat = 72
        static let spacing: CGFloat = 10
        
        struct PlaceholderImage {
            static let width: CGFloat = 70
            static let height: CGFloat = 70
            static let offsetX: CGFloat = -15
            static let offsetY: CGFloat = 16
        }
    }
    
    @Environment(\.colorScheme) var colorScheme
    
    let viewModel: ProductCategoryCardViewModel
    
    var colorPalette: ColorPalette {
        ColorPalette(container: viewModel.container, colorScheme: colorScheme)
    }
    
    var body: some View {
        HStack(spacing: Constants.spacing) {
            if let image = viewModel.categoryDetails.image?[AppV2Constants.API.imageScaleFactor]?.absoluteString,
               let imageURL = URL(string: image) {
                RemoteImageView(viewModel: .init(container: viewModel.container, imageURL: imageURL))
                    .scaledToFit()
                    .frame(width: Constants.width / 6)

            } else {
                Image.Products.bottles
                    .resizable()
                    .scaledToFit()
                    .frame(width: Constants.width / 6)
                    .clipShape(RoundedRectangle(cornerRadius: Constants.clipShapeCornerRadius))
            }
            
            HStack {
                Text(viewModel.categoryDetails.name)
                    .font(.heading4())
                    .foregroundColor(colorPalette.primaryBlue)
                
                Spacer()
            }
        }
        .frame(height: Constants.height)
        .background(colorPalette.secondaryWhite)
        .standardCardFormat()
    }
}

struct ProductSubcategoryCardView_Previews: PreviewProvider {
    static var previews: some View {
        ProductSubCategoryCardView(viewModel: .init(container: .preview, categoryDetails: RetailStoreMenuCategory(id: 123, parentId: 21, name: "Drinks", image: nil, description: "")))
            .previewLayout(.sizeThatFits)
            .padding()
            .previewCases()
    }
}
