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
                Text(Strings.ProductCarousel.offers.localized)
                    .font(.snappyHeadline)
                    .foregroundColor(.snappyBlue)
                
                Spacer()
            }
            .padding(.horizontal, 10)
            
            ScrollView(.horizontal) {
                LazyHStack {
                    ForEach(MockData.resultsData, id:\.id) { item in
                        #warning("Change preview to passing on container from viewModel and missing EnvObj")
                        ProductCardView(viewModel: .init(container: .preview, menuItem: item, showSearchProductCard: false))
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
