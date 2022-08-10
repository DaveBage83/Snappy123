//
//  ProductCarouselView.swift
//  SnappyV2Study
//
//  Created by Henrik Gustavii on 13/07/2021.
//

import SwiftUI

struct ProductCarouselView: View {
    let container: DIContainer
    let items: [RetailStoreMenuItem]
    
    init(container: DIContainer, items: [RetailStoreMenuItem] = []) {
        self.container = container
        self.items = items
    }
    
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
                    ForEach(items, id:\.id) { item in
                        ProductCardView(viewModel: .init(container: container, menuItem: item, productSelected: {_ in}))
                    }
                }
                .padding()
            }
        }
        .padding(.vertical)
        .background(Color.snappyBGMain)
    }
}

#if DEBUG
struct ProductCarouselView_Previews: PreviewProvider {
    static var previews: some View {
        ProductCarouselView(container: .preview, items: MockData.resultsData)
            .previewLayout(.sizeThatFits)
            .padding()
            .previewCases()
    }
}
#endif
