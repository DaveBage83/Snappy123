//
//  ProductDetailBottomSheetView.swift
//  SnappyV2Study
//
//  Created by Henrik Gustavii on 07/07/2021.
//

import SwiftUI

struct ProductDetailBottomSheetView: View {
    @Environment(\.colorScheme) var colorScheme
    
    @State var quantity = 0
    
    let productDetail: ProductDetail
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack(alignment: .centerStackAlignmentGuide) {
                VStack(alignment: .leading) {
                    Image(productDetail.image)
                        .resizable()
                        .scaledToFit()
                    
                    if let previousPrice = productDetail.previousPrice {
                        HStack {
                            VStack(alignment: .leading) {
                                Text("Now")
                                    .font(.snappyCaption)
                                Text(productDetail.currentPrice)
                            }
                            .foregroundColor(.snappyRed)
                            
                            VStack(alignment: .leading) {
                                Text("Was")
                                    .font(.snappyCaption)
                                    .foregroundColor(.snappyTextGrey2)
                                Text(previousPrice)
                            }
                        }
                        .alignmentGuide(.centerStackAlignmentGuide) { context in
                            context[.centerStackAlignmentGuide]
                        }
                    } else {
                        Text(productDetail.currentPrice)
                    }
                }
                
                VStack {
                    VStack(alignment: .leading) {
                        Text(productDetail.label)
                            .padding(.bottom)
                        
                        VStack {
                            Label("Vegetarian", systemImage: "checkmark.circle.fill")
                                .font(.snappyCaption)
                                .foregroundColor(.snappyTextGrey2)
                            Label("Vegetarian", systemImage: "checkmark.circle.fill")
                                .font(.snappyCaption)
                                .foregroundColor(.snappyTextGrey2)
                        }
                        .padding(.bottom)
                    }
                    
                    addButton
                        .alignmentGuide(.centerStackAlignmentGuide) { context in
                            context[.centerStackAlignmentGuide]
                        }
                }
            }
            .padding(.bottom)
            
            
            VStack(alignment: .leading) {
                VStack(alignment: .leading) {
                    Text("Description")
                        .font(.snappyCaption).bold()
                        .foregroundColor(.snappyTextGrey2)
                        .padding(.bottom, 1)
                    
                    Text(productDetail.description ?? "No description")
                        .font(.snappyCaption)
                }
                .padding(.bottom)
                
                VStack(alignment: .leading) {
                    Text("Ingredients")
                        .font(.snappyCaption).bold()
                        .foregroundColor(.snappyTextGrey2)
                        .padding(.bottom, 1)
                    
                    Text(productDetail.ingredients ?? "Unknown ingredients")
                        .font(.snappyCaption)
                }
            }
        }
        .padding()        
    }
    
    // Copied from ProductCardView, needs own component
    @ViewBuilder var addButton: some View {
        if quantity == 0 {
            Button(action: { quantity = 1 }) {
                Text("Add +")
            }
            .buttonStyle(SnappyPrimaryButtonStyle())
        } else {
            HStack {
                Button(action: { quantity -= 1 }) {
                    Image(systemName: "minus.circle.fill")
                        .foregroundColor(.snappyBlue)
                }
                
                Text("\(quantity)")
                    .font(.snappyBody)
                
                Button(action: { quantity += 1 }) {
                    Image(systemName: "plus.circle.fill")
                        .foregroundColor(.snappyBlue)
                }
            }
        }
    }
}

struct ProductDetailBottomSheetView_Previews: PreviewProvider {
    static var previews: some View {
        ProductDetailBottomSheetView(productDetail: ProductDetail(label: "Random Whiskey 70cl with additional features", image: "whiskey1", currentPrice: "£24.99", previousPrice: "£29.99", offer: nil, description: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Curabitur feugiat pharetra aliquam. Sed eget commodo dolor. Quisque purus nisi, commodo sit amet augue at, convallis placerat erat. Donec in euismod turpis, in dictum est. Vestibulum imperdiet interdum tempus. Mauris pellentesque tellus scelerisque, vestibulum lacus volutpat, placerat felis. Morbi placerat, nulla quis euismod eleifend, dui dui laoreet massa, sed suscipit arcu nunc facilisis odio. Morbi tempor libero eget viverra vulputate. Curabitur ante orci, auctor id hendrerit sit amet, tincidunt ut nisi.", ingredients: """
Lorem ipsum dolor sit amet
Vestibulum euismod ex ac erat suscipit
Donec at metus et magna accumsan cursus eu in neque
In efficitur dolor scelerisque metus varius
Duis mollis diam iaculis elit auctor
"""))
            .previewLayout(.sizeThatFits)
            .padding()
            .previewCases()
    }
}

extension VerticalAlignment {
    /// A custom vertical alignment to center stack views
    private struct CenterStackAlignment: AlignmentID {
        static func defaultValue(in context: ViewDimensions) -> CGFloat {
            context[VerticalAlignment.center]
        }
    }
    
    static let centerStackAlignmentGuide = VerticalAlignment(CenterStackAlignment.self)
}
