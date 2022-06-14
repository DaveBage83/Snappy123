//
//  ProductCategoryCardView.swift
//  SnappyV2Study
//
//  Created by Henrik Gustavii on 23/06/2021.
//

import SwiftUI

class ProductCategoryCardViewModel {
    let container: DIContainer
    let categoryDetails: RetailStoreMenuCategory
    
    init(container: DIContainer, categoryDetails: RetailStoreMenuCategory) {
        self.container = container
        self.categoryDetails = categoryDetails
    }
}

struct ProductCategoryCardView: View {
    @Environment(\.colorScheme) var colorScheme
    
    struct Constants {
        static let imageXOffset: CGFloat = -30
        static let imageYOffset: CGFloat = 70
        static let height: CGFloat = 199
        static let width: CGFloat = 165
    }
    
    let viewModel: ProductCategoryCardViewModel
    
    var colorPalette: ColorPalette {
        ColorPalette(container: viewModel.container, colorScheme: colorScheme)
    }
    
    var body: some View {
        ZStack {
            if let image = viewModel.categoryDetails.image?[AppV2Constants.API.imageScaleFactor]?.absoluteString,
               let imageURL = URL(string: image) {
                RemoteImageView(viewModel: .init(container: viewModel.container, imageURL: imageURL))
                    .scaledToFit()
                    .offset(x: Constants.imageXOffset, y: Constants.imageYOffset)
            } else {
                Image("bottle-cats")
                    .resizable()
                    .scaledToFit()
            }
            
            VStack {
                HStack {
                    Text(viewModel.categoryDetails.name)
                        .font(.heading4())
                        .foregroundColor(colorPalette.primaryBlue)
                        .multilineTextAlignment(.leading)
                    
                    Spacer()
                }
                .padding()
                
                Spacer()
            }
        }
        .frame(width: Constants.width, height: Constants.height)
        .background(colorPalette.secondaryWhite)
        .standardCardFormat()
    }
}

#if DEBUG
struct ProductCategoryCardView_Previews: PreviewProvider {
    static var previews: some View {
        ProductCategoryCardView(viewModel: .init(container: .preview, categoryDetails: RetailStoreMenuCategory(id: 123, parentId: 21, name: "Drinks", image: nil, description: "")))
            .previewLayout(.sizeThatFits)
            .padding()
            .previewCases()
    }
}
#endif
