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
                    ForEach(resultsData, id:\.id) { product in
                        ProductCardView(productDetail: product)
                    }
                }
                .padding()
            }
        }
        .padding(.vertical)
        .background(Color.snappyBGMain)
    }
    
    let resultsData = [ProductDetail(label: "Some whiskey or other that possibly is not Scottish", image: "whiskey1", currentPrice: "£20.90", previousPrice: "£24.45", offer: "20% off", description: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Curabitur feugiat pharetra aliquam. Sed eget commodo dolor. Quisque purus nisi, commodo sit amet augue at, convallis placerat erat. Donec in euismod turpis, in dictum est. Vestibulum imperdiet interdum tempus. Mauris pellentesque tellus scelerisque, vestibulum lacus volutpat, placerat felis. Morbi placerat, nulla quis euismod eleifend, dui dui laoreet massa, sed suscipit arcu nunc facilisis odio. Morbi tempor libero eget viverra vulputate. Curabitur ante orci, auctor id hendrerit sit amet, tincidunt ut nisi.", ingredients: """
Lorem ipsum dolor sit amet
Vestibulum euismod ex ac erat suscipit
Donec at metus et magna accumsan cursus eu in neque
In efficitur dolor scelerisque metus varius
Duis mollis diam iaculis elit auctor
"""),
                       ProductDetail(label: "Another whiskey", image: "whiskey2", currentPrice: "£24.95", previousPrice: nil, offer: nil, description: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Curabitur feugiat pharetra aliquam. Sed eget commodo dolor. Quisque purus nisi, commodo sit amet augue at, convallis placerat erat. Donec in euismod turpis, in dictum est. Vestibulum imperdiet interdum tempus. Mauris pellentesque tellus scelerisque, vestibulum lacus volutpat, placerat felis. Morbi placerat, nulla quis euismod eleifend, dui dui laoreet massa, sed suscipit arcu nunc facilisis odio. Morbi tempor libero eget viverra vulputate. Curabitur ante orci, auctor id hendrerit sit amet, tincidunt ut nisi.", ingredients: """
Lorem ipsum dolor sit amet
Vestibulum euismod ex ac erat suscipit
Donec at metus et magna accumsan cursus eu in neque
In efficitur dolor scelerisque metus varius
Duis mollis diam iaculis elit auctor
"""),
                       ProductDetail(label: "Yet another whiskey", image: "whiskey3", currentPrice: "£20.90", previousPrice: "£24.45", offer: "Meal Deal", description: nil, ingredients: nil),
                       ProductDetail(label: "Really, another whiskey?", image: "whiskey4", currentPrice: "£34.70", previousPrice: nil, offer: "3 for 2", description: nil, ingredients: nil),
                       ProductDetail(label: "Some whiskey or other that possibly is not Scottish", image: "whiskey1", currentPrice: "£20.90", previousPrice: "£24.45", offer: nil, description: nil, ingredients: nil),
                       ProductDetail(label: "Another whiskey", image: "whiskey2", currentPrice: "£20.90", previousPrice: "£24.45", offer: nil, description: nil, ingredients: nil)]
}

struct ProductCarouselView_Previews: PreviewProvider {
    static var previews: some View {
        ProductCarouselView()
            .previewLayout(.sizeThatFits)
            .padding()
            .previewCases()
    }
}
