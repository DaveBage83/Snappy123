//
//  ProductCarouselView.swift
//  SnappyV2Study
//
//  Created by Henrik Gustavii on 13/07/2021.
//

import SwiftUI

struct ProductCarouselView: View {
    var body: some View {
        VStack {
            HStack {
                Text("Offers just for you")
                    .font(.snappyHeadline)
                    .foregroundColor(.snappyBlue)
                
                Spacer()
            }
            .padding(.horizontal, 10)
            
            ScrollView(.horizontal) {
                LazyHStack {
                    ForEach(MockData.resultsData, id:\.id) { product in
                        ProductCardView(productDetail: product)
                    }
                }
                .padding()
            }
        }
        .padding(.vertical)
        .background(Color.snappyBGMain)
    }
}

struct ProductCarouselView_Previews: PreviewProvider {
    static var previews: some View {
        ProductCarouselView()
            .previewLayout(.sizeThatFits)
            .padding()
            .previewCases()
    }
}