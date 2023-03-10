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
    
    // MARK: - Main view
    var body: some View {
        VStack {
            HStack {
                SearchBarView(container: productsViewModel.container, label: Strings.ProductsView.searchStore.localized, text: $text, isEditing: $isEditing)
                    .withSearchHistory(
                        container: productsViewModel.container,
                        searchResults: $productsViewModel.itemSearchHistoryResults,
                        textfieldTextSetter: { searchTerm in
                            productsViewModel.selectedSearchTerm = searchTerm
                        })
                    .onTapGesture {
                        productsViewModel.configureSearchHistoryResults()
                    }
                
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
                        if productsViewModel.showCaloriesSort {
                            Button(action: { productsViewModel.sort(by: .caloriesLowToHigh) }) {
                                Text(Strings.ProductsView.ProductCard.Sort.caloriesLowToHigh.localized)
                                    .font(.Body2.regular())
                            }
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
        .onAppear {
            Task {
                await productsViewModel.populateStoredSearches()
            }
        }
        .padding(.horizontal)
        .background(colorPalette.typefaceInvert)
        .zIndex(1)
    }
}

#if DEBUG
struct SnappyTopNavigation_Previews: PreviewProvider {
    static var previews: some View {
        ProductsNavigationAndSearch(productsViewModel: ProductsViewModel(container: .preview), text: .constant(""), isEditing: .constant(false))
    }
}
#endif
