//
//  ProductsView.swift
//  SnappyV2Study
//
//  Created by Henrik Gustavii on 23/06/2021.
//

import SwiftUI

struct ProductsView: View {
    @Environment(\.colorScheme) var colorScheme
    @StateObject var viewModel: ProductsViewModel
    let gridLayout = [GridItem(spacing: 1), GridItem(spacing: 1)]
    let resultGridLayout = [GridItem(.adaptive(minimum: 160), spacing: 10)]
    
    var body: some View {
        VStack {
            ScrollView {
                SearchBarView(label: "Search Store", text: $viewModel.searchText)
                    .padding(.top)
                
                productsResultsViews
                    .padding(.top)
                    .background(colorScheme == .dark ? Color.black : Color.snappyBGMain)
            }
        }
        .bottomSheet(item: $viewModel.productDetail) { product in
            ProductDetailBottomSheetView(productDetail: product)
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
            default:
                rootCategoriesView()
                    .redacted(reason: viewModel.rootCategoriesIsLoading ? .placeholder : [])
            }
    }
    
    func rootCategoriesView() -> some View {
        LazyVGrid(columns: gridLayout, spacing: 20) {
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
                LazyVGrid(columns: resultGridLayout, spacing: 14) {
                    ForEach(items, id: \.id) { results in
                        ProductCardView(productDetail: results)
                            .environmentObject(viewModel)
                    }
                }
                .padding(.horizontal, 4)
            }
        }
    }
    
    func filterButton() -> some View {
        Button(action: {}) {
            Text("Filter Selection")
        }
        .buttonStyle(SnappySecondaryButtonStyle())
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
    static let categoryData = [
        RetailStoreMenuCategory(id: 123, parentId: 0, name: "Juices", image: nil),
        RetailStoreMenuCategory(id: 234, parentId: 0, name: "Sauces", image: nil),
        RetailStoreMenuCategory(id: 345, parentId: 0, name: "Sauces", image: nil),
        RetailStoreMenuCategory(id: 456, parentId: 0, name: "Juices", image: nil),
        RetailStoreMenuCategory(id: 567, parentId: 0, name: "Juices", image: nil),
        RetailStoreMenuCategory(id: 678, parentId: 0, name: "Sauces", image: nil),
        RetailStoreMenuCategory(id: 789, parentId: 0, name: "Sauces", image: nil),
        RetailStoreMenuCategory(id: 890, parentId: 0, name: "Juices", image: nil)
    ]
    
    static let subCategoryData = [
        RetailStoreMenuCategory(id: 123, parentId: 12, name: "Juices", image: nil),
        RetailStoreMenuCategory(id: 234, parentId: 23, name: "Sauces", image: nil),
        RetailStoreMenuCategory(id: 345, parentId: 34, name: "Sauces", image: nil),
        RetailStoreMenuCategory(id: 456, parentId: 45, name: "Juices", image: nil),
        RetailStoreMenuCategory(id: 567, parentId: 56, name: "Juices", image: nil),
        RetailStoreMenuCategory(id: 678, parentId: 67, name: "Sauces", image: nil),
        RetailStoreMenuCategory(id: 789, parentId: 78, name: "Sauces", image: nil),
        RetailStoreMenuCategory(id: 890, parentId: 89, name: "Juices", image: nil)]
    
    static let resultsData = [
        RetailStoreMenuItem(id: 123, name: "Some whiskey or other that possibly is not Scottish", eposCode: nil, outOfStock: false, ageRestriction: 18, description: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Curabitur feugiat pharetra aliquam. Sed eget commodo dolor. Quisque purus nisi, commodo sit amet augue at, convallis placerat erat. Donec in euismod turpis, in dictum est. Vestibulum imperdiet interdum tempus. Mauris pellentesque tellus scelerisque, vestibulum lacus volutpat, placerat felis. Morbi placerat, nulla quis euismod eleifend, dui dui laoreet massa, sed suscipit arcu nunc facilisis odio. Morbi tempor libero eget viverra vulputate. Curabitur ante orci, auctor id hendrerit sit amet, tincidunt ut nisi.", quickAdd: true, price: RetailStoreMenuItemPrice(price: 20.90, fromPrice: 0, unitMetric: "", unitsInPack: 0, unitVolume: 0, wasPrice: 24.45), images: nil, sizes: nil, options: nil),
        RetailStoreMenuItem(id: 234, name: "Another whiskey", eposCode: nil, outOfStock: false, ageRestriction: 18, description: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Curabitur feugiat pharetra aliquam. Sed eget commodo dolor. Quisque purus nisi, commodo sit amet augue at, convallis placerat erat. Donec in euismod turpis, in dictum est. Vestibulum imperdiet interdum tempus. Mauris pellentesque tellus scelerisque, vestibulum lacus volutpat, placerat felis. Morbi placerat, nulla quis euismod eleifend, dui dui laoreet massa, sed suscipit arcu nunc facilisis odio. Morbi tempor libero eget viverra vulputate. Curabitur ante orci, auctor id hendrerit sit amet, tincidunt ut nisi.", quickAdd: true, price: RetailStoreMenuItemPrice(price: 24.95, fromPrice: 0, unitMetric: "", unitsInPack: 0, unitVolume: 0, wasPrice: nil), images: nil, sizes: nil, options: nil),
        RetailStoreMenuItem(id: 345, name: "Yet another whiskey", eposCode: nil, outOfStock: false, ageRestriction: 18, description: nil, quickAdd: true, price: RetailStoreMenuItemPrice(price: 20.90, fromPrice: 0, unitMetric: "", unitsInPack: 0, unitVolume: 0, wasPrice: 24.45), images: nil, sizes: nil, options: nil),
        RetailStoreMenuItem(id: 456, name: "Really, another whiskey?", eposCode: nil, outOfStock: false, ageRestriction: 18, description: nil, quickAdd: true, price: RetailStoreMenuItemPrice(price: 34.70, fromPrice: 0, unitMetric: "", unitsInPack: 0, unitVolume: 0, wasPrice: nil), images: nil, sizes: nil, options: nil),
        RetailStoreMenuItem(id: 567, name: "Some whiskey or other that possibly is not Scottish", eposCode: nil, outOfStock: false, ageRestriction: 18, description: nil, quickAdd: true, price: RetailStoreMenuItemPrice(price: 20.90, fromPrice: 0, unitMetric: "", unitsInPack: 0, unitVolume: 0, wasPrice: 24.45), images: nil, sizes: nil, options: nil),
        RetailStoreMenuItem(id: 678, name: "Another whiskey", eposCode: nil, outOfStock: false, ageRestriction: 18, description: nil, quickAdd: true, price: RetailStoreMenuItemPrice(price: 20.90, fromPrice: 0, unitMetric: "", unitsInPack: 0, unitVolume: 0, wasPrice: 24.45), images: nil, sizes: nil, options: nil)]
}

#endif
