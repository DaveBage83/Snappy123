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
    
    let viewModel: ProductCategoryCardViewModel

    var body: some View {
        ZStack {
            if let image = viewModel.categoryDetails.image?[AppV2Constants.API.imageScaleFactor]?.absoluteString,
               let imageURL = URL(string: image) {
                RemoteImageView(viewModel: .init(container: viewModel.container, imageURL: imageURL))
                    .scaledToFit()
                    .frame(width: 150, height: 190)
                    .cornerRadius(10)
                    .offset(x: -30, y: 70)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            } else {
                Image("bottle-cats")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 150, height: 190)
                    .cornerRadius(10)
                    .offset(x: -30, y: 70)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }
            
            VStack {
                HStack {
                    Text(viewModel.categoryDetails.name)
                        .font(.snappyBody)
                        .foregroundColor(colorScheme == .dark ? .white : .black)
                    
                    Spacer()
                }
                .padding(.top, 10)
                .padding(.leading, 15)
                
                Spacer()
            }
        }
        .frame(width: 150, height: 190)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(colorScheme == .dark ? Color.black : Color.white)
                .snappyShadow()
        )
    }
}

struct ProductCategoryCardView_Previews: PreviewProvider {
    static var previews: some View {
        ProductCategoryCardView(viewModel: .init(container: .preview, categoryDetails: RetailStoreMenuCategory(id: 123, parentId: 21, name: "Drinks", image: nil)))            
            .previewLayout(.sizeThatFits)
            .padding()
            .previewCases()
    }
}
