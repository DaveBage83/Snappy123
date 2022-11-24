//
//  ProductDetailBottomSheetView.swift
//  SnappyV2Study
//
//  Created by Henrik Gustavii on 07/07/2021.
//

import SwiftUI

struct ProductDetailBottomSheetView: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.presentationMode) var presentation
    @Environment(\.mainWindowSize) var mainWindowSize
    
    typealias ProductCardStrings = Strings.ProductsView.ProductCard
    typealias ProductDetailStrings = Strings.ProductsView.ProductDetail
    
    struct Constants {
        struct ItemImage {
            static let size: CGFloat = 144
            static let cornerRadius: CGFloat = 8
        }
    }
    
    @StateObject var viewModel: ProductDetailBottomSheetViewModel
    @ObservedObject var productsViewModel: ProductsViewModel
    @State var fixScrollHeight = false
    
    let dismissViewHandler: () -> Void
    
    private var colorPalette: ColorPalette {
        ColorPalette(container: viewModel.container, colorScheme: colorScheme)
    }
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            mainContent
                .padding(.bottom)
        }
    }
    
    @ViewBuilder private var mainContent: some View {
        VStack(alignment: .leading) {
            HStack(alignment: .top, spacing: 16) {
                VStack(alignment: .leading) {
                    AsyncImage(container: viewModel.container, urlString: viewModel.item.images?.first?[AppV2Constants.API.imageScaleFactor]?.absoluteString)
                        .cornerRadius(Constants.ItemImage.cornerRadius)
                        .frame(width: Constants.ItemImage.size, height: Constants.ItemImage.size)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(colorPalette.typefacePrimary.withOpacity(.twenty), lineWidth: 1)
                        )
                }
                
                VStack {
                    VStack(alignment: .leading) {
                        offerPill

                        Text(viewModel.item.name)
                            .font(.heading3())
                            .padding(.bottom)

                        if let calorieInformation = viewModel.calories {
                            calories(calorieInformation)
                        }
                    }
                }
            }
            .padding(.bottom)
            
            if viewModel.quantityLimitReached {
                basketLimitBanner()
            }
            
            Divider()
            
            price
                
            if viewModel.hasElements {
                itemDetails
            }
        }
        .padding()
    }
    
    @ViewBuilder private var itemDetails: some View {
        VStack(alignment: .leading, spacing: 20) {
            if let details = viewModel.itemDetailElements {
                Divider()

                ForEach(details, id: \.self) { details in
                    ItemDetailsView(viewModel: .init(container: viewModel.container, itemDetails: details))
                }
            }
        }
        
        
    }
    
    @ViewBuilder private var price: some View {
        if let wasPriceString = viewModel.wasPriceString {
            HStack(spacing: 16) {
                VStack(alignment: .leading) {
                    Text(ProductDetailStrings.now.localized)
                        .font(.Caption1.semiBold())
                        .foregroundColor(colorPalette.typefacePrimary)
                    
                    Text(viewModel.priceString)
                        .font(.heading2.bold())
                        .foregroundColor(colorPalette.primaryRed)
                }

                VStack(alignment: .leading) {
                    Text(ProductDetailStrings.was.localized)
                        .font(.Caption1.semiBold())

                    Text(wasPriceString)
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
                Text(viewModel.priceString)
                    .font(.heading2.bold())
                    .foregroundColor(colorPalette.textGrey1.withOpacity(.eighty))
                
                Spacer()
                
                ProductIncrementButton(viewModel: .init(container: viewModel.container, menuItem: viewModel.item), size: .large)
            }
        }
    }
    
    // MARK: - Special offer pill
    @ViewBuilder var offerPill: some View {
        if let latestOffer = viewModel.latestOffer, productsViewModel.viewState != .offers {
            Button {
                productsViewModel.specialOfferPillTapped(offer: latestOffer, fromItem: viewModel.item) {
                    dismissViewHandler()
                }
            } label: {
                SpecialOfferPill(container: viewModel.container, offerText: latestOffer.name, type: .chip, size: .small)
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
        ProductDetailBottomSheetView(viewModel: .init(container: .preview, menuItem: RetailStoreMenuItem(id: 123, name: "Random Whiskey 70cl with additional features", eposCode: nil, outOfStock: false, ageRestriction: 18, description: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Curabitur feugiat pharetra aliquam. Sed eget commodo dolor. Quisque purus nisi, commodo sit amet augue at, convallis placerat erat. Donec in euismod turpis, in dictum est. Vestibulum imperdiet interdum tempus. Mauris pellentesque tellus scelerisque, vestibulum lacus volutpat, placerat felis. Morbi placerat, nulla quis euismod eleifend, dui dui laoreet massa, sed suscipit arcu nunc facilisis odio. Morbi tempor libero eget viverra vulputate. Curabitur ante orci, auctor id hendrerit sit amet, tincidunt ut nisi.", quickAdd: true, acceptCustomerInstructions: false, basketQuantityLimit: 500, price: RetailStoreMenuItemPrice(price: 24.99, fromPrice: 0, unitMetric: "", unitsInPack: 0, unitVolume: 0, wasPrice: 29.99), images: nil, menuItemSizes: nil, menuItemOptions: nil, availableDeals: nil, itemCaptions: ItemCaptions(portionSize: "495 Kcal per 100g"), mainCategory: MenuItemCategory(id: 0, name: ""), itemDetails: nil, deal: nil)), productsViewModel: .init(container: .preview), dismissViewHandler: {})
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
