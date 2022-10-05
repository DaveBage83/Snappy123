//
//  ProductCardView.swift
//  SnappyV2Study
//
//  Created by Henrik Gustavii on 06/07/2021.
//

import SwiftUI

struct ProductCardView: View {
    // MARK: - Environment objects
    @Environment(\.mainWindowSize) var mainWindowSize
    @Environment(\.colorScheme) var colorScheme
    
    @ScaledMetric var scale: CGFloat = 1 // Used to scale icon for accessibility options

    // MARK: - Constants
    struct Constants {
        static let padding: CGFloat = 16
        static let cornerRadius: CGFloat = 8
        
        struct Card {
            struct Search {
                static let spacing: CGFloat = 5
            }
        
            struct ProductImage {
                static let standardHeight: CGFloat = 124
                static let searchHeight: CGFloat = 98
                static let offerHeight: CGFloat = 50
                static let cornerRadius: CGFloat = 8
                static let lineWidth: CGFloat = 1
            }
            
            struct Calories {
                static let height: CGFloat = 12
                static let spacing: CGFloat = 8
            }
            
            struct StandardCard {
                static let bottomPadding: CGFloat = 9
                static let buttonHeight: CGFloat = 36
                static let internalStackHeight: CGFloat = 100
                static let spacing: CGFloat = 8
            }
        }
    }
    
    // MARK: - View model
    @StateObject var viewModel: ProductCardViewModel
    @ObservedObject var productsViewModel: ProductsViewModel
    
    // MARK: - Computed variables
    var colorPalette: ColorPalette {
        ColorPalette(container: viewModel.container, colorScheme: colorScheme)
    }
    
    var standardCardWidth: CGFloat {
        if AppV2Constants.Business.productCardWidth * scale < mainWindowSize.width {
            return AppV2Constants.Business.productCardWidth * scale
        } else {
            return mainWindowSize.width
        }
    }
    
    // MARK: - Main view
    var body: some View {
        if viewModel.isOffer {
            offerProductCard()
        } else {
            standardProductCard()
        }
    }
    
    //MARK: - Offer card
    func offerProductCard() -> some View {
        HStack {
            productImageButton
                .padding(.trailing, Constants.Card.StandardCard.spacing)
            
            VStack(alignment: .leading) {
                offerPillButton
                productDetails
                price
            }
            Spacer()
            ProductIncrementButton(viewModel: .init(container: viewModel.container, menuItem: viewModel.itemDetail), size: .large)
                .frame(height: Constants.Card.StandardCard.buttonHeight * scale)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, Constants.padding)
        .padding(.horizontal)
        .background(colorPalette.secondaryWhite)
        .standardCardFormat()
    }
    
    // MARK: - Standard card
    func standardProductCard() -> some View {
        ZStack(alignment: .topLeading) {
            
            VStack(alignment: .center) {
                productImageButton
                                
                productDetails
                
                Spacer()
                
                VStack {
                    calories
                    
                    Spacer()
                    
                    price
                    
                    Spacer()
                    
                    ProductIncrementButton(viewModel: .init(container: viewModel.container, menuItem: viewModel.itemDetail), size: .large)
                        .frame(height: Constants.Card.StandardCard.buttonHeight * scale)
                }
                .frame(height: Constants.Card.StandardCard.internalStackHeight * scale)
            }
            .frame(width: standardCardWidth)
            .padding(.vertical, Constants.padding)
            .padding(.horizontal)
            .background(colorPalette.secondaryWhite)
            .standardCardFormat()
        }
    }
    
    private var productImageButton: some View {
        Button(action: {
            Task {
                try await viewModel.productCardTapped()
            }
        }) {
            if viewModel.isOffer {
                offerProductImage
            } else {
                productImage
            }
        }
    }
    
    private var productDetails: some View {
        Button(action: {
            Task {
                try await viewModel.productCardTapped()
            }
        }) {
            Text(viewModel.itemDetail.name)
                .font(.Body1.regular())
                .multilineTextAlignment(viewModel.isOffer ? .leading : .center)
                .foregroundColor(colorPalette.typefacePrimary)
                .fixedSize(horizontal: false, vertical: true) // stops text from truncating when long
        }
        .withLoadingToast(loading: $viewModel.isGettingProductDetails)
    }
    
    @ViewBuilder private var price: some View {
        if let fromPriceString = viewModel.fromPriceString {
            VStack(alignment: viewModel.isOffer ? .leading : .center) {
                Text(Strings.ProductsView.ProductDetail.from.localized)
                    .font(.Caption1.bold())
                HStack {
                    Text(fromPriceString)
                        .font(.heading4())
                        .foregroundColor(viewModel.isReduced ? colorPalette.primaryRed : colorPalette.primaryBlue)
                    
                    if let wasPrice = viewModel.wasPriceString {
                        Text(wasPrice)
                            .font(.Body2.semiBold())
                            .strikethrough()
                            .foregroundColor(.snappyTextGrey2)
                    }
                }
            }
        } else {
            Text(viewModel.priceString)
                .font(.heading4())
                .foregroundColor(viewModel.isReduced ? colorPalette.primaryRed : colorPalette.primaryBlue)
            
            if let wasPrice = viewModel.wasPriceString {
                Text(wasPrice)
                    .font(.Body2.semiBold())
                    .strikethrough()
                    .foregroundColor(.snappyTextGrey2)
            }
        }
    }
    
    // MARK: - Item image
    @ViewBuilder var productImage: some View {
        ZStack(alignment: .topLeading) {
            AsyncImage(urlString: viewModel.itemDetail.images?.first?[AppV2Constants.API.imageScaleFactor]?.absoluteString, placeholder: {
                Image.Placeholders.productPlaceholder
                    .resizable()
                    .scaledToFit()
                    .cornerRadius(Constants.cornerRadius)
                    .frame(height: viewModel.showSearchProductCard ? Constants.Card.ProductImage.searchHeight * scale : Constants.Card.ProductImage.standardHeight * scale)
            })
            .cornerRadius(Constants.cornerRadius)
            .scaledToFit()
            .frame(height: viewModel.showSearchProductCard ? Constants.Card.ProductImage.searchHeight * scale : Constants.Card.ProductImage.standardHeight * scale)
            .padding(.horizontal)
            .overlay(
                RoundedRectangle(cornerRadius: Constants.Card.ProductImage.cornerRadius)
                    .stroke(colorPalette.typefacePrimary.withOpacity(.ten), lineWidth: Constants.Card.ProductImage.lineWidth)
            )
 
            if viewModel.showSpecialOfferPillAsButton {
                offerPillButton
            } else {
                offerPill
            }
        }
    }
    
    @ViewBuilder var offerProductImage: some View {
        AsyncImage(urlString: viewModel.itemDetail.images?.first?[AppV2Constants.API.imageScaleFactor]?.absoluteString, placeholder: {
            Image.Placeholders.productPlaceholder
                .resizable()
                .scaledToFit()
                .cornerRadius(Constants.cornerRadius)
                .frame(height: Constants.Card.ProductImage.offerHeight * scale)
        })
        .cornerRadius(Constants.cornerRadius)
        .scaledToFit()
        .frame(height: Constants.Card.ProductImage.offerHeight * scale)
        .padding()
        .overlay(
            RoundedRectangle(cornerRadius: Constants.Card.ProductImage.cornerRadius)
                .stroke(colorPalette.typefacePrimary.withOpacity(.ten), lineWidth: Constants.Card.ProductImage.lineWidth)
        )
    }
    
    // MARK: - Special offer pill
    @ViewBuilder var offerPillButton: some View {
        if let latestOffer = viewModel.latestOffer, productsViewModel.viewState != .offers {
            Button {
                productsViewModel.specialOfferPillTapped(offer: latestOffer)
            } label: {
                offerPill
            }
        }
    }
    
    @ViewBuilder private var offerPill: some View {
        if let latestOffer = viewModel.latestOffer {
            SpecialOfferPill(container: viewModel.container, offerText: latestOffer.name, type: .chip, size: .small)
        }
    }
    
    // MARK: - Calories display
    @ViewBuilder var calories: some View {
        if let calorieDetails = viewModel.itemDetail.itemCaptions?.portionSize {
            HStack(alignment: .center, spacing: Constants.Card.Calories.spacing) {
                Image.Icons.WeightScale.filled
                    .renderingMode(.template)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: Constants.Card.Calories.height * scale)
                    .foregroundColor(colorPalette.textGrey2)
                
                Text(calorieDetails.lowercased())
                    .font(.Caption1.semiBold())
                    .foregroundColor(colorPalette.textGrey2)
            }
        }
    }
}

#if DEBUG
struct ProductCardView_Previews: PreviewProvider {
    @StateObject static var productsViewModel = ProductsViewModel(container: .preview)
    
    static var previews: some View {
        Group {
            // standard card - fromPrice 0 - no wasPrice - quickAdd true
            ProductCardView(viewModel: .init(container: .preview, menuItem: RetailStoreMenuItem(id: 123, name: "Some whiskey or other that possibly is not Scottish", eposCode: nil, outOfStock: false, ageRestriction: 18, description: nil, quickAdd: true, acceptCustomerInstructions: false, basketQuantityLimit: 500, price: RetailStoreMenuItemPrice(price: 20.90, fromPrice: 0, unitMetric: "", unitsInPack: 0, unitVolume: 0, wasPrice: nil), images: nil, menuItemSizes: nil, menuItemOptions: nil, availableDeals: nil, itemCaptions: ItemCaptions(portionSize: "495 Kcal per 100g"), mainCategory: MenuItemCategory(id: 0, name: ""), itemDetails: nil, deal: nil), productSelected: {_ in}), productsViewModel: productsViewModel)
            
            // standard card - fromPrice 0 - no wasPrice - quickAdd false
            ProductCardView(viewModel: .init(container: .preview, menuItem: RetailStoreMenuItem(id: 123, name: "Some whiskey or other that possibly is not Scottish", eposCode: nil, outOfStock: false, ageRestriction: 18, description: nil, quickAdd: false, acceptCustomerInstructions: false, basketQuantityLimit: 500, price: RetailStoreMenuItemPrice(price: 20.90, fromPrice: 0, unitMetric: "", unitsInPack: 0, unitVolume: 0, wasPrice: nil), images: nil, menuItemSizes: nil, menuItemOptions: nil, availableDeals: nil, itemCaptions: ItemCaptions(portionSize: "495 Kcal per 100g"), mainCategory: MenuItemCategory(id: 0, name: ""), itemDetails: nil, deal: nil), productSelected: {_ in}), productsViewModel: productsViewModel)
            
            // standard card - fromPrice present - no wasPrice - quickAdd true
            ProductCardView(viewModel: .init(container: .preview, menuItem: RetailStoreMenuItem(id: 123, name: "Some whiskey or other that possibly is not Scottish", eposCode: nil, outOfStock: false, ageRestriction: 18, description: nil, quickAdd: true, acceptCustomerInstructions: false, basketQuantityLimit: 500, price: RetailStoreMenuItemPrice(price: 20.90, fromPrice: 22, unitMetric: "", unitsInPack: 0, unitVolume: 0, wasPrice: nil), images: nil, menuItemSizes: nil, menuItemOptions: nil, availableDeals: nil, itemCaptions: ItemCaptions(portionSize: "495 Kcal per 100g"), mainCategory: MenuItemCategory(id: 0, name: ""), itemDetails: nil, deal: nil), productSelected: {_ in}), productsViewModel: productsViewModel)
            
            // standard card - fromPrice present - no wasPrice - quickAdd false
            ProductCardView(viewModel: .init(container: .preview, menuItem: RetailStoreMenuItem(id: 123, name: "Some whiskey or other that possibly is not Scottish", eposCode: nil, outOfStock: false, ageRestriction: 18, description: nil, quickAdd: false, acceptCustomerInstructions: false, basketQuantityLimit: 500, price: RetailStoreMenuItemPrice(price: 20.90, fromPrice: 22, unitMetric: "", unitsInPack: 0, unitVolume: 0, wasPrice: nil), images: nil, menuItemSizes: nil, menuItemOptions: nil, availableDeals: nil, itemCaptions: ItemCaptions(portionSize: "495 Kcal per 100g"), mainCategory: MenuItemCategory(id: 0, name: ""), itemDetails: nil, deal: nil), productSelected: {_ in}), productsViewModel: productsViewModel)
            
            // standard card - fromPrice 0 - wasPrice present - quickAdd true
            ProductCardView(viewModel: .init(container: .preview, menuItem: RetailStoreMenuItem(id: 123, name: "Some whiskey or other that possibly is not Scottish", eposCode: nil, outOfStock: false, ageRestriction: 18, description: nil, quickAdd: true, acceptCustomerInstructions: false, basketQuantityLimit: 500, price: RetailStoreMenuItemPrice(price: 20.90, fromPrice: 0, unitMetric: "", unitsInPack: 0, unitVolume: 0, wasPrice: 22), images: nil, menuItemSizes: nil, menuItemOptions: nil, availableDeals: nil, itemCaptions: ItemCaptions(portionSize: "495 Kcal per 100g"), mainCategory: MenuItemCategory(id: 0, name: ""), itemDetails: nil, deal: nil), productSelected: {_ in}), productsViewModel: productsViewModel)
            
            // standard card - fromPrice 0 - wasPrice present - quickAdd false
            ProductCardView(viewModel: .init(container: .preview, menuItem: RetailStoreMenuItem(id: 123, name: "Some whiskey or other that possibly is not Scottish", eposCode: nil, outOfStock: false, ageRestriction: 18, description: nil, quickAdd: false, acceptCustomerInstructions: false, basketQuantityLimit: 500, price: RetailStoreMenuItemPrice(price: 20.90, fromPrice: 0, unitMetric: "", unitsInPack: 0, unitVolume: 0, wasPrice: 22), images: nil, menuItemSizes: nil, menuItemOptions: nil, availableDeals: nil, itemCaptions: ItemCaptions(portionSize: "495 Kcal per 100g"), mainCategory: MenuItemCategory(id: 0, name: ""), itemDetails: nil, deal: nil), productSelected: {_ in}), productsViewModel: productsViewModel)
            
            // standard card - fromPrice present - wasPrice present - quickAdd true
            ProductCardView(viewModel: .init(container: .preview, menuItem: RetailStoreMenuItem(id: 123, name: "Some whiskey or other that possibly is not Scottish", eposCode: nil, outOfStock: false, ageRestriction: 18, description: nil, quickAdd: true, acceptCustomerInstructions: false, basketQuantityLimit: 500, price: RetailStoreMenuItemPrice(price: 20.90, fromPrice: 22, unitMetric: "", unitsInPack: 0, unitVolume: 0, wasPrice: 24), images: nil, menuItemSizes: nil, menuItemOptions: nil, availableDeals: nil, itemCaptions: ItemCaptions(portionSize: "495 Kcal per 100g"), mainCategory: MenuItemCategory(id: 0, name: ""), itemDetails: nil, deal: nil), productSelected: {_ in}), productsViewModel: productsViewModel)
            
            // standard card - fromPrice present - wasPrice present - quickAdd false
            ProductCardView(viewModel: .init(container: .preview, menuItem: RetailStoreMenuItem(id: 123, name: "Some whiskey or other that possibly is not Scottish", eposCode: nil, outOfStock: false, ageRestriction: 18, description: nil, quickAdd: false, acceptCustomerInstructions: false, basketQuantityLimit: 500, price: RetailStoreMenuItemPrice(price: 20.90, fromPrice: 22, unitMetric: "", unitsInPack: 0, unitVolume: 0, wasPrice: 24), images: nil, menuItemSizes: nil, menuItemOptions: nil, availableDeals: nil, itemCaptions: ItemCaptions(portionSize: "495 Kcal per 100g"), mainCategory: MenuItemCategory(id: 0, name: ""), itemDetails: nil, deal: nil), productSelected: {_ in}), productsViewModel: productsViewModel)
        }
        
        Group {
            // search card - fromPrice 0 - no wasPrice - quickAdd true
            ProductCardView(viewModel: .init(container: .preview, menuItem: RetailStoreMenuItem(id: 123, name: "Some whiskey or other that possibly is not Scottish", eposCode: nil, outOfStock: false, ageRestriction: 18, description: nil, quickAdd: true, acceptCustomerInstructions: false, basketQuantityLimit: 500, price: RetailStoreMenuItemPrice(price: 20.90, fromPrice: 0, unitMetric: "", unitsInPack: 0, unitVolume: 0, wasPrice: nil), images: nil, menuItemSizes: nil, menuItemOptions: nil, availableDeals: nil, itemCaptions: ItemCaptions(portionSize: "495 Kcal per 100g"), mainCategory: MenuItemCategory(id: 0, name: ""), itemDetails: nil, deal: nil), productSelected: {_ in}), productsViewModel: productsViewModel)
            
            // search card - fromPrice 0 - no wasPrice - quickAdd false
            ProductCardView(viewModel: .init(container: .preview, menuItem: RetailStoreMenuItem(id: 123, name: "Some whiskey or other that possibly is not Scottish", eposCode: nil, outOfStock: false, ageRestriction: 18, description: nil, quickAdd: false, acceptCustomerInstructions: false, basketQuantityLimit: 500, price: RetailStoreMenuItemPrice(price: 20.90, fromPrice: 0, unitMetric: "", unitsInPack: 0, unitVolume: 0, wasPrice: nil), images: nil, menuItemSizes: nil, menuItemOptions: nil, availableDeals: nil, itemCaptions: ItemCaptions(portionSize: "495 Kcal per 100g"), mainCategory: MenuItemCategory(id: 0, name: ""), itemDetails: nil, deal: nil), productSelected: {_ in}), productsViewModel: productsViewModel)
            
            // search card - fromPrice present - no wasPrice - quickAdd true
            ProductCardView(viewModel: .init(container: .preview, menuItem: RetailStoreMenuItem(id: 123, name: "Some whiskey or other that possibly is not Scottish", eposCode: nil, outOfStock: false, ageRestriction: 18, description: nil, quickAdd: true, acceptCustomerInstructions: false, basketQuantityLimit: 500, price: RetailStoreMenuItemPrice(price: 20.90, fromPrice: 30, unitMetric: "", unitsInPack: 0, unitVolume: 0, wasPrice: nil), images: nil, menuItemSizes: nil, menuItemOptions: nil, availableDeals: nil, itemCaptions: ItemCaptions(portionSize: "495 Kcal per 100g"), mainCategory: MenuItemCategory(id: 0, name: ""), itemDetails: nil, deal: nil), productSelected: {_ in}), productsViewModel: productsViewModel)
            
            // search card - fromPrice present - wasPrice present - quickAdd true
            ProductCardView(viewModel: .init(container: .preview, menuItem: RetailStoreMenuItem(id: 123, name: "Some whiskey or other that possibly is not Scottish", eposCode: nil, outOfStock: false, ageRestriction: 18, description: nil, quickAdd: true, acceptCustomerInstructions: false, basketQuantityLimit: 500, price: RetailStoreMenuItemPrice(price: 20.90, fromPrice: 20, unitMetric: "", unitsInPack: 0, unitVolume: 0, wasPrice: 22), images: nil, menuItemSizes: nil, menuItemOptions: nil, availableDeals: nil, itemCaptions: ItemCaptions(portionSize: "495 Kcal per 100g"), mainCategory: MenuItemCategory(id: 0, name: ""), itemDetails: nil, deal: nil), productSelected: {_ in}), productsViewModel: productsViewModel)
            
            // search card - fromPrice 0 - wasPrice present - quickAdd true
            ProductCardView(viewModel: .init(container: .preview, menuItem: RetailStoreMenuItem(id: 123, name: "Some whiskey or other that possibly is not Scottish", eposCode: nil, outOfStock: false, ageRestriction: 18, description: nil, quickAdd: true, acceptCustomerInstructions: false, basketQuantityLimit: 500, price: RetailStoreMenuItemPrice(price: 20.90, fromPrice: 0, unitMetric: "", unitsInPack: 0, unitVolume: 0, wasPrice: 22), images: nil, menuItemSizes: nil, menuItemOptions: nil, availableDeals: nil, itemCaptions: ItemCaptions(portionSize: "495 Kcal per 100g"), mainCategory: MenuItemCategory(id: 0, name: ""), itemDetails: nil, deal: nil), productSelected: {_ in}), productsViewModel: productsViewModel)
            
            // search card - fromPrice 0 - wasPrice present - quickAdd false
            ProductCardView(viewModel: .init(container: .preview, menuItem: RetailStoreMenuItem(id: 123, name: "Some whiskey or other that possibly is not Scottish", eposCode: nil, outOfStock: false, ageRestriction: 18, description: nil, quickAdd: false, acceptCustomerInstructions: false, basketQuantityLimit: 500, price: RetailStoreMenuItemPrice(price: 20.90, fromPrice: 0, unitMetric: "", unitsInPack: 0, unitVolume: 0, wasPrice: 22), images: nil, menuItemSizes: nil, menuItemOptions: nil, availableDeals: [RetailStoreMenuItemAvailableDeal(id: 123, name: "20% off", type: "Discount"), RetailStoreMenuItemAvailableDeal(id: 123, name: "20% off", type: "Discount")], itemCaptions: ItemCaptions(portionSize: "495 Kcal per 100g"), mainCategory: MenuItemCategory(id: 0, name: ""), itemDetails: nil, deal: nil), productSelected: {_ in}), productsViewModel: productsViewModel)
        }
    }
}
#endif
