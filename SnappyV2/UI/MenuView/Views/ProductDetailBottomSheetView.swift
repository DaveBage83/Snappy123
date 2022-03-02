//
//  ProductDetailBottomSheetView.swift
//  SnappyV2Study
//
//  Created by Henrik Gustavii on 07/07/2021.
//

import SwiftUI

struct ProductDetailBottomSheetView: View {
    typealias ProductCardStrings = Strings.ProductsView.ProductCard
    typealias ProductDetailStrings = Strings.ProductsView.ProductDetail
    
    @Environment(\.colorScheme) var colorScheme
    
    @State var quantity = 0
    
    let container: DIContainer
    let productDetail: RetailStoreMenuItem
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack(alignment: .centerStackAlignmentGuide) {
                VStack(alignment: .leading) {
                    if let image = productDetail.images?.first?["xhdpi_2x"]?.absoluteString,
                       let imageURL = URL(string: image) {
                        RemoteImageView(imageURL: imageURL, container: container)
                            .scaledToFit()
                    } else {
                        Image("whiskey1")
                            .resizable()
                            .scaledToFit()
                    }
                    
                    if let previousPrice = productDetail.price.wasPrice {
                        HStack {
                            VStack(alignment: .leading) {
                                Text(ProductDetailStrings.now.localized)
                                    .font(.snappyCaption)
                                
                                Text(productDetail.price.price.toCurrencyString())
                            }
                            .foregroundColor(.snappyRed)
                            
                            VStack(alignment: .leading) {
                                Text(ProductDetailStrings.was.localized)
                                    .font(.snappyCaption)
                                    .foregroundColor(.snappyTextGrey2)
                                Text(previousPrice.toCurrencyString())
                            }
                        }
                        .alignmentGuide(.centerStackAlignmentGuide) { context in
                            context[.centerStackAlignmentGuide]
                        }
                    } else {
                        Text(productDetail.price.price.toCurrencyString())
                    }
                }
                
                VStack {
                    VStack(alignment: .leading) {
                        Text(productDetail.name)
                            .padding(.bottom)
                        
                        VStack {
                            Label(ProductCardStrings.vegetarian.localized, systemImage: "checkmark.circle.fill")
                                .font(.snappyCaption)
                                .foregroundColor(.snappyTextGrey2)
                            Label(ProductCardStrings.vegetarian.localized, systemImage: "checkmark.circle.fill")
                                .font(.snappyCaption)
                                .foregroundColor(.snappyTextGrey2)
                        }
                        .padding(.bottom)
                    }
                    
                    ProductAddButton(viewModel: .init(container: container, menuItem: productDetail))
                        .alignmentGuide(.centerStackAlignmentGuide) { context in
                            context[.centerStackAlignmentGuide]
                        }
                }
            }
            .padding(.bottom)
            
            
            VStack(alignment: .leading) {
                VStack(alignment: .leading) {
                    Text(GeneralStrings.description.localized)
                        .font(.snappyCaption).bold()
                        .foregroundColor(.snappyTextGrey2)
                        .padding(.bottom, 1)
                    
                    Text(productDetail.description ?? GeneralStrings.noDescription.localized)
                        .font(.snappyCaption)
                }
                .padding(.bottom)
                
//                VStack(alignment: .leading) {
//                    Text("Ingredients")
//                        .font(.snappyCaption).bold()
//                        .foregroundColor(.snappyTextGrey2)
//                        .padding(.bottom, 1)
//
//                    Text(productDetail.ingredients ?? "Unknown ingredients")
//                        .font(.snappyCaption)
//                }
            }
        }
        .padding()        
    }
    
    // Copied from ProductCardView, needs own component
    @ViewBuilder var addButton: some View {
        if quantity == 0 {
            Button(action: { quantity = 1 }) {
                Text(GeneralStrings.add.localized)
            }
            .buttonStyle(SnappyPrimaryButtonStyle())
        } else {
            HStack {
                Button(action: { quantity -= 1 }) {
                    Image.Actions.Remove.circleFilled
                        .foregroundColor(.snappyBlue)
                }
                
                Text("\(quantity)")
                    .font(.snappyBody)
                
                Button(action: { quantity += 1 }) {
                    Image.Actions.Add.circleFilled
                        .foregroundColor(.snappyBlue)
                }
            }
        }
    }
}

struct ProductDetailBottomSheetView_Previews: PreviewProvider {
    static var previews: some View {
        ProductDetailBottomSheetView(container: .preview, productDetail: RetailStoreMenuItem(id: 123, name: "Random Whiskey 70cl with additional features", eposCode: nil, outOfStock: false, ageRestriction: 18, description: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Curabitur feugiat pharetra aliquam. Sed eget commodo dolor. Quisque purus nisi, commodo sit amet augue at, convallis placerat erat. Donec in euismod turpis, in dictum est. Vestibulum imperdiet interdum tempus. Mauris pellentesque tellus scelerisque, vestibulum lacus volutpat, placerat felis. Morbi placerat, nulla quis euismod eleifend, dui dui laoreet massa, sed suscipit arcu nunc facilisis odio. Morbi tempor libero eget viverra vulputate. Curabitur ante orci, auctor id hendrerit sit amet, tincidunt ut nisi.", quickAdd: true, price: RetailStoreMenuItemPrice(price: 24.99, fromPrice: 0, unitMetric: "", unitsInPack: 0, unitVolume: 0, wasPrice: 29.99), images: nil, menuItemSizes: nil, menuItemOptions: nil, availableDeals: nil))
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
