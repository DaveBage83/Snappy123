//
//  ProductsNavigationAndSearch.swift
//  SnappyV2
//
//  Created by David Bage on 13/06/2022.
//

import SwiftUI

struct ProductsNavigationAndSearch: View {
    // MARK: - Environment objects
    @Environment(\.sizeCategory) var sizeCategory: ContentSizeCategory
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.horizontalSizeClass) var sizeClass
    
    // MARK: - Constants
    private struct Constants {
        struct Logo {
            static let width: CGFloat = 207.25
            static let largeScreenWidthMultiplier: CGFloat = 1.5
        }
        
        struct SearchBar {
            static let padding: CGFloat = 10
        }
    }
    
    // MARK: - Properties
    @ObservedObject var productsViewModel: ProductsViewModel
    let withLogo: Bool
    
    // MARK: - Binding properties
    @Binding var text: String
    @Binding var isEditing: Bool
    
    // MARK: - Computed variables
    private var colorPalette: ColorPalette {
        ColorPalette(container: productsViewModel.container, colorScheme: colorScheme)
    }
    
    private var adoptMinimalLayout: Bool {
        sizeCategory.size > 7 && sizeClass == .compact
    }
    
    // MARK: - Main view
    var body: some View {
        VStack {
            if withLogo {
                Image.Branding.Logo.inline
                    .resizable()
                    .scaledToFit()
                    .frame(width: Constants.Logo.width * (sizeClass == .compact ? 1 : Constants.Logo.largeScreenWidthMultiplier))
                    .padding(.top)
            }
            
            HStack {
                SearchBarView(container: productsViewModel.container, label: Strings.ProductsView.searchStore.localized, text: $text, isEditing: $isEditing)
                
                if productsViewModel.showFilterButton {
                    Menu {
                        Button(action: { productsViewModel.sort(by: .default) }) {
                            Text(Strings.ProductsView.ProductCard.Sort.default.localized)
                                .font(.Body2.regular())
                        }
                        Button(action: { productsViewModel.sort(by: .aToZ) }) {
                            Text(Strings.ProductsView.ProductCard.Sort.aToZ.localized)
                                .font(.Body2.regular())
                        }
                        Button(action: { productsViewModel.sort(by: .zToA) }) {
                            Text(Strings.ProductsView.ProductCard.Sort.zToA.localized)
                                .font(.Body2.regular())
                        }
                        Button(action: { productsViewModel.sort(by: .priceHighToLow) }) {
                            Text(Strings.ProductsView.ProductCard.Sort.priceHighToLow.localized)
                                .font(.Body2.regular())
                        }
                        Button(action: { productsViewModel.sort(by: .priceLowToHigh) }) {
                            Text(Strings.ProductsView.ProductCard.Sort.priceLowToHigh.localized)
                                .font(.Body2.regular())
                        }
                    } label: {
                        Image.Products.sort
                            .foregroundColor(colorPalette.typefacePrimary)
                            .font(.title)
                    }
                }
            }
            .padding(.top, Constants.SearchBar.padding)
            .padding(.bottom, adoptMinimalLayout ? Constants.SearchBar.padding : 0)
            
            if !adoptMinimalLayout, let store = productsViewModel.container.appState.value.userData.selectedStore.value {
                StoreInfoBar(container: productsViewModel.container, store: store)
            }
        }
        .padding(.horizontal)
        .background(colorPalette.secondaryWhite)
    }
}

#if DEBUG
struct SnappyTopNavigation_Previews: PreviewProvider {
    static var previews: some View {
        ProductsNavigationAndSearch(productsViewModel: ProductsViewModel(container: .preview), withLogo: true, text: .constant(""), isEditing: .constant(false))
    }
}
#endif
