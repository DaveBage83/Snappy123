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
    let resultGridLayout = [GridItem(.adaptive(minimum: 160), spacing: 10)]
    
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
                SearchBarView(label: Strings.ProductsView.searchStore.localized, text: $viewModel.searchText, isEditing: $viewModel.isEditing) { viewModel.cancelSearch() } 
                    .padding(.top)
                
                // Show search screen when search call has been triggered. Dismiss when search has been cleared.
                if viewModel.isEditing {
                     searchView()
                } else {
                    productsResultsViews
                        .padding(.top)
                        .background(colorScheme == .dark ? Color.black : Color.snappyBGMain)
                }
            }
        }
        .background(Color.snappyBGMain)
        .bottomSheet(item: $viewModel.productDetail) { product in
            ProductDetailBottomSheetView(productDetail: product)
        }
        .onAppear {
            viewModel.getCategories()
        }
        .onDisappear {
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
            if let rootCategories = viewModel.rootCategories {
                ForEach(rootCategories, id: \.id) { details in
                    ProductCategoryCardView(categoryDetails: details)
                        .environmentObject(viewModel)
                }
            }
        }
    }
    
    func subCategoriesView() -> some View {
        LazyVStack {
            if let subCategories = viewModel.subCategories {
                ForEach(subCategories, id: \.id) { details in
                    ProductSubCategoryCardView(subCategoryDetails: details)
                        .environmentObject(viewModel)
                }
            }
        }
    }
    
    func itemsView() -> some View {
        VStack {
            filterButton()
                .padding(.bottom)
            if let items = viewModel.items {
                LazyVGrid(columns: resultGridLayout, spacing: Constants.ItemsGrid.spacing) {
                    ForEach(items, id: \.id) { result in
                        ProductCardView(viewModel: .init(container: viewModel.container, menuItem: result))
                            .environmentObject(viewModel)
                    }
                }
                .padding(.horizontal, Constants.ItemsGrid.padding)
            }
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
                if viewModel.searchResultCategories.isEmpty == false {
                    Text("\(viewModel.searchResultCategories.count) categories that include \"\(viewModel.searchText)\"")
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
                if viewModel.searchResultItems.isEmpty == false {
                    Text("\(viewModel.searchResultItems.count) product results for \"\(viewModel.searchText)\"")
                        .font(.snappyBody)
                        .padding()
                    
                    ScrollView() {
                        VStack {
                            ForEach(viewModel.searchResultItems, id: \.self) { item in
                                ProductCardView(viewModel: .init(container: viewModel.container, menuItem: item, showSearchProductCard: true))
                            }
                        }
                    }
                }
                
                // No search result
                if viewModel.noSearchResult {
                    Text("Sorry, there are no results for \"\(viewModel.searchText)\"")
                        .font(.snappyBody)
                        .padding()
                }
            }
        }
    }
}

struct ProductCategoryView_Previews: PreviewProvider {
    static var previews: some View {
        ProductsView(viewModel: .init(container: .preview))
            .previewCases()
    }
}


#if DEBUG

extension MockData {
    static let resultsData = [
        RetailStoreMenuItem(id: 123, name: "Some whiskey or other that possibly is not Scottish", eposCode: nil, outOfStock: false, ageRestriction: 18, description: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Curabitur feugiat pharetra aliquam. Sed eget commodo dolor. Quisque purus nisi, commodo sit amet augue at, convallis placerat erat. Donec in euismod turpis, in dictum est. Vestibulum imperdiet interdum tempus. Mauris pellentesque tellus scelerisque, vestibulum lacus volutpat, placerat felis. Morbi placerat, nulla quis euismod eleifend, dui dui laoreet massa, sed suscipit arcu nunc facilisis odio. Morbi tempor libero eget viverra vulputate. Curabitur ante orci, auctor id hendrerit sit amet, tincidunt ut nisi.", quickAdd: true, price: RetailStoreMenuItemPrice(price: 20.90, fromPrice: 0, unitMetric: "", unitsInPack: 0, unitVolume: 0, wasPrice: 24.45), images: nil, menuItemSizes: nil, menuItemOptions: nil, availableDeals: nil),
        RetailStoreMenuItem(id: 234, name: "Another whiskey", eposCode: nil, outOfStock: false, ageRestriction: 18, description: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Curabitur feugiat pharetra aliquam. Sed eget commodo dolor. Quisque purus nisi, commodo sit amet augue at, convallis placerat erat. Donec in euismod turpis, in dictum est. Vestibulum imperdiet interdum tempus. Mauris pellentesque tellus scelerisque, vestibulum lacus volutpat, placerat felis. Morbi placerat, nulla quis euismod eleifend, dui dui laoreet massa, sed suscipit arcu nunc facilisis odio. Morbi tempor libero eget viverra vulputate. Curabitur ante orci, auctor id hendrerit sit amet, tincidunt ut nisi.", quickAdd: true, price: RetailStoreMenuItemPrice(price: 24.95, fromPrice: 0, unitMetric: "", unitsInPack: 0, unitVolume: 0, wasPrice: nil), images: nil, menuItemSizes: nil, menuItemOptions: nil, availableDeals: nil),
        RetailStoreMenuItem(id: 345, name: "Yet another whiskey", eposCode: nil, outOfStock: false, ageRestriction: 18, description: nil, quickAdd: true, price: RetailStoreMenuItemPrice(price: 20.90, fromPrice: 0, unitMetric: "", unitsInPack: 0, unitVolume: 0, wasPrice: 24.45), images: nil, menuItemSizes: nil, menuItemOptions: nil, availableDeals: nil),
        RetailStoreMenuItem(id: 456, name: "Really, another whiskey?", eposCode: nil, outOfStock: false, ageRestriction: 18, description: nil, quickAdd: true, price: RetailStoreMenuItemPrice(price: 34.70, fromPrice: 0, unitMetric: "", unitsInPack: 0, unitVolume: 0, wasPrice: nil), images: nil, menuItemSizes: nil, menuItemOptions: nil, availableDeals: nil),
        RetailStoreMenuItem(id: 567, name: "Some whiskey or other that possibly is not Scottish", eposCode: nil, outOfStock: false, ageRestriction: 18, description: nil, quickAdd: true, price: RetailStoreMenuItemPrice(price: 20.90, fromPrice: 0, unitMetric: "", unitsInPack: 0, unitVolume: 0, wasPrice: 24.45), images: nil, menuItemSizes: nil, menuItemOptions: nil, availableDeals: nil),
        RetailStoreMenuItem(id: 678, name: "Another whiskey", eposCode: nil, outOfStock: false, ageRestriction: 18, description: nil, quickAdd: true, price: RetailStoreMenuItemPrice(price: 20.90, fromPrice: 0, unitMetric: "", unitsInPack: 0, unitVolume: 0, wasPrice: 24.45), images: nil, menuItemSizes: nil, menuItemOptions: nil, availableDeals: nil)]
}

#endif
