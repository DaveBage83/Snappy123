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
            HStack {
                SearchBarView(container: productsViewModel.container, label: Strings.ProductsView.searchStore.localized, text: $text, isEditing: $isEditing)
                
                if productsViewModel.showFilterButton {
                    Menu {
                        Button(action: { productsViewModel.sort(by: .default) }) {
                            Text(Strings.ProductsView.ProductCard.Sort.default.localized)
                                .font(.Body2.regular())
                        }
                        Button(action: { productsViewModel.sort(by: .priceLowToHigh) }) {
                            Text(Strings.ProductsView.ProductCard.Sort.priceLowToHigh.localized)
                                .font(.Body2.regular())
                        }
                        Button(action: { productsViewModel.sort(by: .priceHighToLow) }) {
                            Text(Strings.ProductsView.ProductCard.Sort.priceHighToLow.localized)
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
                        Button(action: { productsViewModel.sort(by: .caloriesLowToHigh) }) {
                            Text(Strings.ProductsView.ProductCard.Sort.caloriesLowToHigh.localized)
                                .font(.Body2.regular())
                        }
                    } label: {
                        Image.Products.sort
                            .renderingMode(.template)
                            .foregroundColor(colorPalette.typefacePrimary.withOpacity(.eighty))
                            .font(.title)
                    }
                }
            }
            .padding(.bottom, Constants.SearchBar.padding)
        }
        .padding(.horizontal)
        .background(colorPalette.typefaceInvert)
    }
}

#if DEBUG
struct SnappyTopNavigation_Previews: PreviewProvider {
    static var previews: some View {
        ProductsNavigationAndSearch(productsViewModel: ProductsViewModel(container: .preview), text: .constant(""), isEditing: .constant(false))
    }
}
#endif
