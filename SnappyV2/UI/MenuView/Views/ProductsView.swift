//
//  ProductsView.swift
//  SnappyV2Study
//
//  Created by Henrik Gustavii on 23/06/2021.
//

import SwiftUI

struct ProductsView: View {
    
    struct Constants {
        struct RootGrid {
            static let spacing: CGFloat = 20
        }
        
        struct ItemsGrid {
            static let spacing: CGFloat = 14
            static let padding: CGFloat = 4
        }
    }
    
    @Environment(\.colorScheme) var colorScheme
    @StateObject var viewModel: ProductsViewModel
    
    let gridLayout = [GridItem(spacing: 1), GridItem(spacing: 1)]
    let resultGridLayout = [GridItem(.adaptive(minimum: 160), spacing: 10, alignment: .top)]
    
    var body: some View {
        if let itemWithOptions = viewModel.itemOptions {
            ProductOptionsView(viewModel: .init(container: viewModel.container, item: itemWithOptions))
        } else {
            mainProducts()
        }
    }
    
    func mainProducts() -> some View {
        VStack {
            ScrollView {
                HStack {
                    #warning("Temporary to demonstrate back button functionality")
                    if viewModel.showBackButton {
                        Button(action: { viewModel.backButtonTapped() } ) {
                            Image.Products.chevronLeft
                                .foregroundColor(.black)
                                .padding(.leading)
                        }
                    }

                    SearchBarView(label: Strings.ProductsView.searchStore.localized, text: $viewModel.searchText, isEditing: $viewModel.isEditing) { viewModel.cancelSearchButtonTapped()}
                }
                .padding(.top)

                // Show search screen when search call has been triggered. Dismiss when search has been cancelled.
                if viewModel.isEditing {
                    searchView()
                } else {
                    productsResultsViews
                        .onAppear {
                            viewModel.getCategories()
                        }
                        .padding(.top)
                        .background(colorScheme == .dark ? Color.black : Color.snappyBGMain)
                }
            }
        }
        .background(Color.snappyBGMain)
        .bottomSheet(item: $viewModel.productDetail) { product in
            ProductDetailBottomSheetView(viewModel: .init(container: viewModel.container, menuItem: product))
        }
        .onAppear {
            viewModel.clearState()
        }
    }
    
    @ViewBuilder var productsResultsViews: some View {
            switch viewModel.viewState {
            case .subCategories:
                subCategoriesView()
                    .redacted(reason: viewModel.subCategoriesOrItemsIsLoading ? .placeholder : [])
            case .items:
                itemsView()
                    .redacted(reason: viewModel.subCategoriesOrItemsIsLoading ? .placeholder : [])
            case .offers:
                specialOfferView()
                    .redacted(reason: viewModel.specialOffersIsLoading ? .placeholder : [])
            default:
                rootCategoriesView()
                    .redacted(reason: viewModel.rootCategoriesIsLoading ? .placeholder : [])
            }
    }
    
    func rootCategoriesView() -> some View {
        LazyVGrid(columns: gridLayout, spacing: Constants.RootGrid.spacing) {
            ForEach(viewModel.rootCategories, id: \.id) { details in
                Button(action: { viewModel.categoryTapped(categoryID: details.id) }) {
                    ProductCategoryCardView(viewModel: .init(container: viewModel.container, categoryDetails: details))
                }
            }
        }
    }
    
    func subCategoriesView() -> some View {
        LazyVStack(spacing: 16) {
            ForEach(viewModel.subCategories, id: \.id) { details in
                Button(action: { viewModel.categoryTapped(categoryID: details.id) }) {
                    ProductSubCategoryCardView(viewModel: .init(container: viewModel.container, categoryDetails: details))
                        .padding(.horizontal)
                }
            }
        }
    }
    
    func itemsView() -> some View {
        VStack {
            filterButton()
                .padding(.bottom)
            LazyVGrid(columns: resultGridLayout, spacing: Constants.ItemsGrid.spacing) {
                ForEach(viewModel.items, id: \.id) { result in
                    VStack {
                        ProductCardView(viewModel: .init(container: viewModel.container, menuItem: result))
                            .environmentObject(viewModel)
                    }
                }
            }
            .padding(.horizontal, Constants.ItemsGrid.padding)
        }
    }
    
    func specialOfferView() -> some View {
        VStack {
            if let offerText = viewModel.offerText {
                MultiBuyBanner(offerText: offerText)
            }
            if let items = viewModel.specialOfferItems {
                LazyVGrid(columns: resultGridLayout, spacing: Constants.ItemsGrid.spacing) {
                    ForEach(items, id: \.id) { result in
                        ProductCardView(viewModel: .init(container: viewModel.container, menuItem: result, showSearchProductCard: false))
                            .environmentObject(viewModel)
                    }
                }
                .padding(.horizontal, Constants.ItemsGrid.padding)
            }
        }
    }
    
    func filterButton() -> some View {
        Button(action: {}) {
            Text(Strings.ProductsView.filter.localized)
        }
        .buttonStyle(SnappySecondaryButtonStyle())
    }
    
    func searchView() -> some View {
        LazyVStack {
            if viewModel.isSearching {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .gray))
                    .padding()
                
                Spacer()
            } else {
                // Search result category carousel
                if viewModel.showSearchResultCategories {
                    Text(Strings.ProductsView.ProductCard.Search.resultThatIncludesCategories.localizedFormat("\(viewModel.searchResultCategories.count)", "\(viewModel.searchText)"))
                        .font(.snappyBody)
                        .padding()
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(viewModel.searchResultCategories, id: \.self) { category in
                                Button(action: { viewModel.searchCategoryTapped(categoryID: category.id)} ) {
                                    Text(category.name)
                                        .font(.snappyHeadline)
                                        .foregroundColor(.snappyBlue)
                                        .padding()
                                        .background(
                                            RoundedRectangle(cornerRadius: 8)
                                                .fill(colorScheme == .dark ? Color.black : Color.white)
                                                .snappyShadow()
                                        )
                                }
                            }
                            .padding(.vertical)
                        }
                        .padding(.leading)
                    }
                    .padding(.bottom)
                }
                
                // Search result items card list
                if viewModel.showSearchResultItems {
                    Text(Strings.ProductsView.ProductCard.Search.resultThatIncludesItems.localizedFormat("\(viewModel.searchResultItems.count)", "\(viewModel.searchText)"))
                        .font(.snappyBody)
                        .padding()
                    
                    ScrollView() {
                        VStack {
                            ForEach(viewModel.searchResultItems, id: \.self) { item in
                                ProductCardView(viewModel: .init(container: viewModel.container, menuItem: item, showSearchProductCard: true))
                                    .environmentObject(viewModel)
                            }
                        }
                    }
                }
                
                // No search result
                if viewModel.noSearchResult {
                    Text(Strings.ProductsView.ProductCard.Search.noResults.localizedFormat("\(viewModel.searchText)"))
                        .font(.snappyBody)
                        .padding()
                }
            }
        }
    }
}

#if DEBUG
struct ProductCategoryView_Previews: PreviewProvider {
    static var previews: some View {
        ProductsView(viewModel: .init(container: .preview))
            .previewCases()
    }
}

extension MockData {
    static let resultsData = [
        RetailStoreMenuItem(id: 123, name: "Some whiskey or other that possibly is not Scottish", eposCode: nil, outOfStock: false, ageRestriction: 18, description: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Curabitur feugiat pharetra aliquam. Sed eget commodo dolor. Quisque purus nisi, commodo sit amet augue at, convallis placerat erat. Donec in euismod turpis, in dictum est. Vestibulum imperdiet interdum tempus. Mauris pellentesque tellus scelerisque, vestibulum lacus volutpat, placerat felis. Morbi placerat, nulla quis euismod eleifend, dui dui laoreet massa, sed suscipit arcu nunc facilisis odio. Morbi tempor libero eget viverra vulputate. Curabitur ante orci, auctor id hendrerit sit amet, tincidunt ut nisi.", quickAdd: true, acceptCustomerInstructions: false, basketQuantityLimit: 500, price: RetailStoreMenuItemPrice(price: 20.90, fromPrice: 19, unitMetric: "", unitsInPack: 0, unitVolume: 0, wasPrice: 24.45), images: nil, menuItemSizes: nil, menuItemOptions: nil, availableDeals: nil, itemCaptions: ["portionSize": "495 Kcal per 100g"]),
        RetailStoreMenuItem(id: 234, name: "Another whiskey", eposCode: nil, outOfStock: false, ageRestriction: 18, description: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Curabitur feugiat pharetra aliquam. Sed eget commodo dolor. Quisque purus nisi, commodo sit amet augue at, convallis placerat erat. Donec in euismod turpis, in dictum est. Vestibulum imperdiet interdum tempus. Mauris pellentesque tellus scelerisque, vestibulum lacus volutpat, placerat felis. Morbi placerat, nulla quis euismod eleifend, dui dui laoreet massa, sed suscipit arcu nunc facilisis odio. Morbi tempor libero eget viverra vulputate. Curabitur ante orci, auctor id hendrerit sit amet, tincidunt ut nisi.", quickAdd: true, acceptCustomerInstructions: false, basketQuantityLimit: 500, price: RetailStoreMenuItemPrice(price: 24.95, fromPrice: 0, unitMetric: "", unitsInPack: 0, unitVolume: 0, wasPrice: nil), images: nil, menuItemSizes: nil, menuItemOptions: nil, availableDeals: nil, itemCaptions: ["portionSize": "495 Kcal per 100g"]),
        RetailStoreMenuItem(id: 345, name: "Yet another whiskey", eposCode: nil, outOfStock: false, ageRestriction: 18, description: nil, quickAdd: true, acceptCustomerInstructions: false, basketQuantityLimit: 500, price: RetailStoreMenuItemPrice(price: 20.90, fromPrice: 0, unitMetric: "", unitsInPack: 0, unitVolume: 0, wasPrice: 24.45), images: nil, menuItemSizes: nil, menuItemOptions: nil, availableDeals: nil, itemCaptions: ["portionSize": "495 Kcal per 100g"]),
        RetailStoreMenuItem(id: 456, name: "Really, another whiskey?", eposCode: nil, outOfStock: false, ageRestriction: 18, description: nil, quickAdd: true, acceptCustomerInstructions: false, basketQuantityLimit: 500, price: RetailStoreMenuItemPrice(price: 34.70, fromPrice: 0, unitMetric: "", unitsInPack: 0, unitVolume: 0, wasPrice: nil), images: nil, menuItemSizes: nil, menuItemOptions: nil, availableDeals: nil, itemCaptions: ["portionSize": "495 Kcal per 100g"]),
        RetailStoreMenuItem(id: 567, name: "Some whiskey or other that possibly is not Scottish", eposCode: nil, outOfStock: false, ageRestriction: 18, description: nil, quickAdd: true, acceptCustomerInstructions: false, basketQuantityLimit: 500, price: RetailStoreMenuItemPrice(price: 20.90, fromPrice: 0, unitMetric: "", unitsInPack: 0, unitVolume: 0, wasPrice: 24.45), images: nil, menuItemSizes: nil, menuItemOptions: nil, availableDeals: nil, itemCaptions: ["portionSize": "495 Kcal per 100g"]),
        RetailStoreMenuItem(id: 678, name: "Another whiskey", eposCode: nil, outOfStock: false, ageRestriction: 18, description: nil, quickAdd: true, acceptCustomerInstructions: false, basketQuantityLimit: 500, price: RetailStoreMenuItemPrice(price: 20.90, fromPrice: 0, unitMetric: "", unitsInPack: 0, unitVolume: 0, wasPrice: 24.45), images: nil, menuItemSizes: nil, menuItemOptions: nil, availableDeals: nil, itemCaptions: ["portionSize": "495 Kcal per 100g"])]
}

#endif
