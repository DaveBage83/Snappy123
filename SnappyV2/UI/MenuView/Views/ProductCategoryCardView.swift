//
//  ProductCategoryCardView.swift
//  SnappyV2Study
//
//  Created by Henrik Gustavii on 23/06/2021.
//

import SwiftUI

struct ProductCategoryCardView: View {
    @Environment(\.colorScheme) var colorScheme
    
    let categoryDetails: RetailStoreMenuCategory
    
    var body: some View {
        ZStack {
            if let imageURL = categoryDetails.image?["xhdpi_2x"]?.absoluteString {
                #warning("Temporary: To be removed for more suitable image loading - Ticket: SBG-685")
                RemoteImage(url: imageURL)
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
                    Text(categoryDetails.name)
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
        ProductCategoryCardView(categoryDetails: RetailStoreMenuCategory(id: 123, parentId: 21, name: "Drinks", image: nil))
            .previewLayout(.sizeThatFits)
            .padding()
            .previewCases()
    }
}
