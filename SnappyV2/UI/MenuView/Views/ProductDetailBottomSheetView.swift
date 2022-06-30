//
//  ProductDetailBottomSheetView.swift
//  SnappyV2Study
//
//  Created by Henrik Gustavii on 07/07/2021.
//

import SwiftUI

struct ProductDetailBottomSheetView: View {
    @Environment(\.colorScheme) var colorScheme
    typealias ProductCardStrings = Strings.ProductsView.ProductCard
    typealias ProductDetailStrings = Strings.ProductsView.ProductDetail
    
    struct Constants {
        struct ItemImage {
            static let size: CGFloat = 144
        }
    }
    
    @StateObject var viewModel: ProductDetailBottomSheetViewModel
    
    private var colorPalette: ColorPalette {
        ColorPalette(container: viewModel.container, colorScheme: colorScheme)
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack(alignment: .top, spacing: 16) {
                VStack(alignment: .leading) {
                    AsyncImage(urlString: viewModel.item.images?.first?[AppV2Constants.API.imageScaleFactor]?.absoluteString, placeholder: {
                        Image.Placeholders.productPlaceholder
                            .resizable()
                            .frame(width: Constants.ItemImage.size, height: Constants.ItemImage.size)
                            .cornerRadius(8)
                            .scaledToFill()
                        
                    })
                    .frame(width: Constants.ItemImage.size, height: Constants.ItemImage.size)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(colorPalette.typefacePrimary.withOpacity(.twenty), lineWidth: 1)
                    )
                    
                  
                }
                
                VStack {
                    VStack(alignment: .leading) {
                        Text(viewModel.item.name)
                            .font(.heading3())
                            .padding(.bottom)
                        
                        if let calorieInformation = viewModel.calories {
                            calories(calorieInformation)
                        }
                        
                        HStack {
                            Image.Icons.CircleCheck.filled
                                .renderingMode(.template)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(height: 12)
                                .foregroundColor(colorPalette.textGrey1.withOpacity(.eighty))
                            
                            Text(ProductCardStrings.vegetarian.localized)
                                .font(.Body1.semiBold())
                                .foregroundColor(colorPalette.textGrey1.withOpacity(.eighty))
                        }
                    }
                    
                    
//
//                    ProductAddButton(viewModel: .init(container: viewModel.container, menuItem: viewModel.item))
//                        .alignmentGuide(.centerStackAlignmentGuide) { context in
//                            context[.centerStackAlignmentGuide]
//                        }
                }
            }
            .padding(.bottom)
            
//            if viewModel.quantityLimitReached {
//                basketLimitBanner()
//            }
            
//            VStack(alignment: .leading) {
//                VStack(alignment: .leading) {
//                    Text(GeneralStrings.description.localized)
//                        .font(.snappyCaption).bold()
//                        .foregroundColor(.snappyTextGrey2)
//                        .padding(.bottom, 1)
//
//                    Text(viewModel.item.description ?? GeneralStrings.noDescription.localized)
//                        .font(.snappyCaption)
//                }
//                .padding(.bottom)
//            }
            
            Divider()
            
            price
        }
        .padding()        
    }
    
    @ViewBuilder private var price: some View {
        if let previousPrice = viewModel.item.price.wasPrice {
            HStack(spacing: 16) {
                VStack(alignment: .leading) {
                    Text(ProductDetailStrings.now.localized)
                        .font(.Caption1.semiBold())
                        .foregroundColor(colorPalette.typefacePrimary)
                    
                    Text(viewModel.item.price.price.toCurrencyString())
                        .font(.heading2.bold())
                        .foregroundColor(colorPalette.primaryRed)
                }

                
                VStack(alignment: .leading) {
                    Text(ProductDetailStrings.was.localized)
                        .font(.Caption1.semiBold())

                    Text(previousPrice.toCurrencyString())
                        .font(.heading4())
                }
                .foregroundColor(colorPalette.textGrey1.withOpacity(.eighty))
                
                Spacer()
                
                ProductIncrementButton(viewModel: .init(container: viewModel.container, menuItem: viewModel.item), size: .standard)
            }
            .alignmentGuide(.centerStackAlignmentGuide) { context in
                context[.centerStackAlignmentGuide]
            }
        } else {
            HStack {
                Text(viewModel.item.price.price.toCurrencyString())
                    .font(.heading2.bold())
                    .foregroundColor(colorPalette.textGrey1.withOpacity(.eighty))
                
                Spacer()
                
                ProductIncrementButton(viewModel: .init(container: viewModel.container, menuItem: viewModel.item), size: .large)
            }
        }
    }
    
    func calories(_ calorieInfo: String) -> some View {
        HStack(spacing: 8) {
            Image.Icons.WeightScale.filled
                .renderingMode(.template)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 12)
                .foregroundColor(colorPalette.textGrey1.withOpacity(.eighty))
            
            Text(calorieInfo)
                .font(.Body1.semiBold())
                .foregroundColor(colorPalette.textGrey1.withOpacity(.eighty))
        }
    }
    
    func basketLimitBanner() -> some View {
        Text(Strings.ProductsView.ProductDetail.orderLimitReached.localized)
            .foregroundColor(.white)
            .padding()
            .background(
                Rectangle()
                    .cornerRadius(10)
                    .foregroundColor(.snappyRed)
                    .frame(width: .infinity)
            )
    }
}

#if DEBUG
struct ProductDetailBottomSheetView_Previews: PreviewProvider {
    static var previews: some View {
        ProductDetailBottomSheetView(viewModel: .init(container: .preview, menuItem: RetailStoreMenuItem(id: 123, name: "Random Whiskey 70cl with additional features", eposCode: nil, outOfStock: false, ageRestriction: 18, description: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Curabitur feugiat pharetra aliquam. Sed eget commodo dolor. Quisque purus nisi, commodo sit amet augue at, convallis placerat erat. Donec in euismod turpis, in dictum est. Vestibulum imperdiet interdum tempus. Mauris pellentesque tellus scelerisque, vestibulum lacus volutpat, placerat felis. Morbi placerat, nulla quis euismod eleifend, dui dui laoreet massa, sed suscipit arcu nunc facilisis odio. Morbi tempor libero eget viverra vulputate. Curabitur ante orci, auctor id hendrerit sit amet, tincidunt ut nisi.", quickAdd: true, acceptCustomerInstructions: false, basketQuantityLimit: 500, price: RetailStoreMenuItemPrice(price: 24.99, fromPrice: 0, unitMetric: "", unitsInPack: 0, unitVolume: 0, wasPrice: 29.99), images: nil, menuItemSizes: nil, menuItemOptions: nil, availableDeals: nil, itemCaptions: ItemCaptions(portionSize: "495 Kcal per 100g"), mainCategory: MenuItemCategory(id: 0, name: ""))))
    }
}
#endif

extension VerticalAlignment {
    /// A custom vertical alignment to center stack views
    private struct CenterStackAlignment: AlignmentID {
        static func defaultValue(in context: ViewDimensions) -> CGFloat {
            context[VerticalAlignment.center]
        }
    }
    
    static let centerStackAlignmentGuide = VerticalAlignment(CenterStackAlignment.self)
}
