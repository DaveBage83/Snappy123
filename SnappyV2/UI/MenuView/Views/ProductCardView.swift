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
    @EnvironmentObject var productsViewModel: ProductsViewModel
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
            }
            
            struct Calories {
                static let height: CGFloat = 12
                static let spacing: CGFloat = 8
            }
        }
    }
    
    // MARK: - View model
    @StateObject var viewModel: ProductCardViewModel
    
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
        standardProductCard()
    }
    
    // MARK: - Standard card
    func standardProductCard() -> some View {
        ZStack(alignment: .topLeading) {
            
            VStack(alignment: .center) {
                Button(action: { productsViewModel.productDetail = viewModel.itemDetail }) {
                    productImage
                }
                
                Spacer()
                
                Button(action: { productsViewModel.productDetail = viewModel.itemDetail }) {
                    Text(viewModel.itemDetail.name)
                        .font(.Body1.regular())
                        .foregroundColor(colorPalette.typefacePrimary)
                        .fixedSize(horizontal: false, vertical: true) // stops text from truncating when long
                }
                
                Spacer()
                
                VStack(alignment: .center) {
                    if let calorieDetails = viewModel.itemDetail.itemCaptions?[ItemCaptionsKeys.portionSize.rawValue] {
                        calories(calorieDetails)
                    }
                    
                    if viewModel.hasFromPrice {
                        VStack {
                            Text(Strings.ProductsView.ProductDetail.from.localized)
                                .font(.Caption1.bold())
                            HStack {
                                Text(viewModel.itemDetail.price.fromPrice.toCurrencyString())
                                    .font(.heading4())
                                    .foregroundColor(viewModel.isReduced ? colorPalette.primaryRed : colorPalette.primaryBlue)
                                
                                if let wasPrice = viewModel.wasPrice {
                                    Text(wasPrice)
                                        .font(.Body2.semiBold())
                                        .strikethrough()
                                        .foregroundColor(.snappyTextGrey2)
                                }
                            }
                        }
                    } else {
                        Text(viewModel.itemDetail.price.price.toCurrencyString())
                            .font(.heading4())
                            .foregroundColor(viewModel.isReduced ? colorPalette.primaryRed : colorPalette.primaryBlue)
                        
                        if let wasPrice = viewModel.wasPrice {
                            Text(wasPrice)
                                .font(.Body2.semiBold())
                                .strikethrough()
                                .foregroundColor(.snappyTextGrey2)
                        }
                    }
                }
                
                Spacer()
                
                ProductIncrementButton(viewModel: .init(container: viewModel.container, menuItem: viewModel.itemDetail), size: .large)
            }
            .frame(width: standardCardWidth)
            .padding(.vertical, Constants.padding)
            .padding(.horizontal)
            .background(
                RoundedRectangle(cornerRadius: Constants.cornerRadius)
                    .fill(colorScheme == .dark ? Color.black : Color.white)
                    .snappyShadow()
            )
        }
    }
    
    // MARK: - Item image
    @ViewBuilder var productImage: some View {
        ZStack(alignment: .topLeading) {
            
            AsyncImage(urlString: viewModel.itemDetail.images?.first?[AppV2Constants.API.imageScaleFactor]?.absoluteString, placeholder: {
                Image.Placeholders.productPlaceholder
                    .resizable()
                    .scaledToFit()
                    .frame(height: viewModel.showSearchProductCard ? Constants.Card.ProductImage.searchHeight * scale : Constants.Card.ProductImage.standardHeight * scale)
                    .cornerRadius(Constants.cornerRadius)
            })
            .scaledToFit()
            .frame(height: viewModel.showSearchProductCard ? Constants.Card.ProductImage.searchHeight * scale : Constants.Card.ProductImage.standardHeight * scale)
            .cornerRadius(Constants.cornerRadius)
 
            offerPill
        }
    }
    
    // MARK: - Special offer pill
    @ViewBuilder var offerPill: some View {
        if let latestOffer = viewModel.latestOffer, productsViewModel.viewState != .offers {
            Button {
                productsViewModel.specialOfferPillTapped(offer: latestOffer)
            } label: {
                SpecialOfferPill(container: viewModel.container, offerText: latestOffer.name, type: .chip, size: .small)
            }
        }
    }
    
    // MARK: - Calories display
    func calories(_ calories: String) -> some View {
        HStack(alignment: .center, spacing: Constants.Card.Calories.spacing) {
            Image.Icons.WeightScale.filled
                .renderingMode(.template)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: Constants.Card.Calories.height * scale)
                .foregroundColor(colorPalette.textGrey2)
            
            Text(calories.lowercased())
                .font(.Caption1.semiBold())
                .foregroundColor(colorPalette.textGrey2)
        }
    }
}

#if DEBUG
struct ProductCardView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            // standard card - fromPrice 0 - no wasPrice - quickAdd true
            ProductCardView(viewModel: .init(container: .preview, menuItem: RetailStoreMenuItem(id: 123, name: "Some whiskey or other that possibly is not Scottish", eposCode: nil, outOfStock: false, ageRestriction: 18, description: nil, quickAdd: true, acceptCustomerInstructions: false, basketQuantityLimit: 500, price: RetailStoreMenuItemPrice(price: 20.90, fromPrice: 0, unitMetric: "", unitsInPack: 0, unitVolume: 0, wasPrice: nil), images: nil, menuItemSizes: nil, menuItemOptions: nil, availableDeals: nil, itemCaptions: ["portionSize": "495 Kcal per 100g"], mainCategory: MenuItemCategory(id: 0, name: "")), showSearchProductCard: false))
                .environmentObject(ProductsViewModel(container: .preview))
            
            // standard card - fromPrice 0 - no wasPrice - quickAdd false
            ProductCardView(viewModel: .init(container: .preview, menuItem: RetailStoreMenuItem(id: 123, name: "Some whiskey or other that possibly is not Scottish", eposCode: nil, outOfStock: false, ageRestriction: 18, description: nil, quickAdd: false, acceptCustomerInstructions: false, basketQuantityLimit: 500, price: RetailStoreMenuItemPrice(price: 20.90, fromPrice: 0, unitMetric: "", unitsInPack: 0, unitVolume: 0, wasPrice: nil), images: nil, menuItemSizes: nil, menuItemOptions: nil, availableDeals: nil, itemCaptions: ["portionSize": "495 Kcal per 100g"], mainCategory: MenuItemCategory(id: 0, name: "")), showSearchProductCard: false))
                .environmentObject(ProductsViewModel(container: .preview))
            
            // standard card - fromPrice present - no wasPrice - quickAdd true
            ProductCardView(viewModel: .init(container: .preview, menuItem: RetailStoreMenuItem(id: 123, name: "Some whiskey or other that possibly is not Scottish", eposCode: nil, outOfStock: false, ageRestriction: 18, description: nil, quickAdd: true, acceptCustomerInstructions: false, basketQuantityLimit: 500, price: RetailStoreMenuItemPrice(price: 20.90, fromPrice: 22, unitMetric: "", unitsInPack: 0, unitVolume: 0, wasPrice: nil), images: nil, menuItemSizes: nil, menuItemOptions: nil, availableDeals: nil, itemCaptions: ["portionSize": "495 Kcal per 100g"], mainCategory: MenuItemCategory(id: 0, name: "")), showSearchProductCard: false))
                .environmentObject(ProductsViewModel(container: .preview))
            
            // standard card - fromPrice present - no wasPrice - quickAdd false
            ProductCardView(viewModel: .init(container: .preview, menuItem: RetailStoreMenuItem(id: 123, name: "Some whiskey or other that possibly is not Scottish", eposCode: nil, outOfStock: false, ageRestriction: 18, description: nil, quickAdd: false, acceptCustomerInstructions: false, basketQuantityLimit: 500, price: RetailStoreMenuItemPrice(price: 20.90, fromPrice: 22, unitMetric: "", unitsInPack: 0, unitVolume: 0, wasPrice: nil), images: nil, menuItemSizes: nil, menuItemOptions: nil, availableDeals: nil, itemCaptions: ["portionSize": "495 Kcal per 100g"], mainCategory: MenuItemCategory(id: 0, name: "")), showSearchProductCard: false))
                .environmentObject(ProductsViewModel(container: .preview))
            
            // standard card - fromPrice 0 - wasPrice present - quickAdd true
            ProductCardView(viewModel: .init(container: .preview, menuItem: RetailStoreMenuItem(id: 123, name: "Some whiskey or other that possibly is not Scottish", eposCode: nil, outOfStock: false, ageRestriction: 18, description: nil, quickAdd: true, acceptCustomerInstructions: false, basketQuantityLimit: 500, price: RetailStoreMenuItemPrice(price: 20.90, fromPrice: 0, unitMetric: "", unitsInPack: 0, unitVolume: 0, wasPrice: 22), images: nil, menuItemSizes: nil, menuItemOptions: nil, availableDeals: nil, itemCaptions: ["portionSize": "495 Kcal per 100g"], mainCategory: MenuItemCategory(id: 0, name: "")), showSearchProductCard: false))
                .environmentObject(ProductsViewModel(container: .preview))
            
            // standard card - fromPrice 0 - wasPrice present - quickAdd false
            ProductCardView(viewModel: .init(container: .preview, menuItem: RetailStoreMenuItem(id: 123, name: "Some whiskey or other that possibly is not Scottish", eposCode: nil, outOfStock: false, ageRestriction: 18, description: nil, quickAdd: false, acceptCustomerInstructions: false, basketQuantityLimit: 500, price: RetailStoreMenuItemPrice(price: 20.90, fromPrice: 0, unitMetric: "", unitsInPack: 0, unitVolume: 0, wasPrice: 22), images: nil, menuItemSizes: nil, menuItemOptions: nil, availableDeals: nil, itemCaptions: ["portionSize": "495 Kcal per 100g"], mainCategory: MenuItemCategory(id: 0, name: "")), showSearchProductCard: false))
                .environmentObject(ProductsViewModel(container: .preview))
            
            // standard card - fromPrice present - wasPrice present - quickAdd true
            ProductCardView(viewModel: .init(container: .preview, menuItem: RetailStoreMenuItem(id: 123, name: "Some whiskey or other that possibly is not Scottish", eposCode: nil, outOfStock: false, ageRestriction: 18, description: nil, quickAdd: true, acceptCustomerInstructions: false, basketQuantityLimit: 500, price: RetailStoreMenuItemPrice(price: 20.90, fromPrice: 22, unitMetric: "", unitsInPack: 0, unitVolume: 0, wasPrice: 24), images: nil, menuItemSizes: nil, menuItemOptions: nil, availableDeals: nil, itemCaptions: ["portionSize": "495 Kcal per 100g"], mainCategory: MenuItemCategory(id: 0, name: "")), showSearchProductCard: false))
                .environmentObject(ProductsViewModel(container: .preview))
            
            // standard card - fromPrice present - wasPrice present - quickAdd false
            ProductCardView(viewModel: .init(container: .preview, menuItem: RetailStoreMenuItem(id: 123, name: "Some whiskey or other that possibly is not Scottish", eposCode: nil, outOfStock: false, ageRestriction: 18, description: nil, quickAdd: false, acceptCustomerInstructions: false, basketQuantityLimit: 500, price: RetailStoreMenuItemPrice(price: 20.90, fromPrice: 22, unitMetric: "", unitsInPack: 0, unitVolume: 0, wasPrice: 24), images: nil, menuItemSizes: nil, menuItemOptions: nil, availableDeals: nil, itemCaptions: ["portionSize": "495 Kcal per 100g"], mainCategory: MenuItemCategory(id: 0, name: "")), showSearchProductCard: false))
                .environmentObject(ProductsViewModel(container: .preview))
        }
        
        Group {
            // search card - fromPrice 0 - no wasPrice - quickAdd true
            ProductCardView(viewModel: .init(container: .preview, menuItem: RetailStoreMenuItem(id: 123, name: "Some whiskey or other that possibly is not Scottish", eposCode: nil, outOfStock: false, ageRestriction: 18, description: nil, quickAdd: true, acceptCustomerInstructions: false, basketQuantityLimit: 500, price: RetailStoreMenuItemPrice(price: 20.90, fromPrice: 0, unitMetric: "", unitsInPack: 0, unitVolume: 0, wasPrice: nil), images: nil, menuItemSizes: nil, menuItemOptions: nil, availableDeals: nil, itemCaptions: ["portionSize": "495 Kcal per 100g"], mainCategory: MenuItemCategory(id: 0, name: "")), showSearchProductCard: true))
                .environmentObject(ProductsViewModel(container: .preview))
            
            // search card - fromPrice 0 - no wasPrice - quickAdd false
            ProductCardView(viewModel: .init(container: .preview, menuItem: RetailStoreMenuItem(id: 123, name: "Some whiskey or other that possibly is not Scottish", eposCode: nil, outOfStock: false, ageRestriction: 18, description: nil, quickAdd: false, acceptCustomerInstructions: false, basketQuantityLimit: 500, price: RetailStoreMenuItemPrice(price: 20.90, fromPrice: 0, unitMetric: "", unitsInPack: 0, unitVolume: 0, wasPrice: nil), images: nil, menuItemSizes: nil, menuItemOptions: nil, availableDeals: nil, itemCaptions: ["portionSize": "495 Kcal per 100g"], mainCategory: MenuItemCategory(id: 0, name: "")), showSearchProductCard: true))
                .environmentObject(ProductsViewModel(container: .preview))
            
            // search card - fromPrice present - no wasPrice - quickAdd true
            ProductCardView(viewModel: .init(container: .preview, menuItem: RetailStoreMenuItem(id: 123, name: "Some whiskey or other that possibly is not Scottish", eposCode: nil, outOfStock: false, ageRestriction: 18, description: nil, quickAdd: true, acceptCustomerInstructions: false, basketQuantityLimit: 500, price: RetailStoreMenuItemPrice(price: 20.90, fromPrice: 30, unitMetric: "", unitsInPack: 0, unitVolume: 0, wasPrice: nil), images: nil, menuItemSizes: nil, menuItemOptions: nil, availableDeals: nil, itemCaptions: ["portionSize": "495 Kcal per 100g"], mainCategory: MenuItemCategory(id: 0, name: "")), showSearchProductCard: true))
                .environmentObject(ProductsViewModel(container: .preview))
            
            // search card - fromPrice present - wasPrice present - quickAdd true
            ProductCardView(viewModel: .init(container: .preview, menuItem: RetailStoreMenuItem(id: 123, name: "Some whiskey or other that possibly is not Scottish", eposCode: nil, outOfStock: false, ageRestriction: 18, description: nil, quickAdd: true, acceptCustomerInstructions: false, basketQuantityLimit: 500, price: RetailStoreMenuItemPrice(price: 20.90, fromPrice: 20, unitMetric: "", unitsInPack: 0, unitVolume: 0, wasPrice: 22), images: nil, menuItemSizes: nil, menuItemOptions: nil, availableDeals: nil, itemCaptions: ["portionSize": "495 Kcal per 100g"], mainCategory: MenuItemCategory(id: 0, name: "")), showSearchProductCard: true))
                .environmentObject(ProductsViewModel(container: .preview))
            
            // search card - fromPrice 0 - wasPrice present - quickAdd true
            ProductCardView(viewModel: .init(container: .preview, menuItem: RetailStoreMenuItem(id: 123, name: "Some whiskey or other that possibly is not Scottish", eposCode: nil, outOfStock: false, ageRestriction: 18, description: nil, quickAdd: true, acceptCustomerInstructions: false, basketQuantityLimit: 500, price: RetailStoreMenuItemPrice(price: 20.90, fromPrice: 0, unitMetric: "", unitsInPack: 0, unitVolume: 0, wasPrice: 22), images: nil, menuItemSizes: nil, menuItemOptions: nil, availableDeals: nil, itemCaptions: ["portionSize": "495 Kcal per 100g"], mainCategory: MenuItemCategory(id: 0, name: "")), showSearchProductCard: true))
                .environmentObject(ProductsViewModel(container: .preview))
            
            // search card - fromPrice 0 - wasPrice present - quickAdd false
            ProductCardView(viewModel: .init(container: .preview, menuItem: RetailStoreMenuItem(id: 123, name: "Some whiskey or other that possibly is not Scottish", eposCode: nil, outOfStock: false, ageRestriction: 18, description: nil, quickAdd: false, acceptCustomerInstructions: false, basketQuantityLimit: 500, price: RetailStoreMenuItemPrice(price: 20.90, fromPrice: 0, unitMetric: "", unitsInPack: 0, unitVolume: 0, wasPrice: 22), images: nil, menuItemSizes: nil, menuItemOptions: nil, availableDeals: [RetailStoreMenuItemAvailableDeal(id: 123, name: "20% off", type: "Discount"), RetailStoreMenuItemAvailableDeal(id: 123, name: "20% off", type: "Discount")], itemCaptions: ["portionSize": "495 Kcal per 100g"], mainCategory: MenuItemCategory(id: 0, name: "")), showSearchProductCard: true))
                .environmentObject(ProductsViewModel(container: .preview))
        }
    }
}
#endif
