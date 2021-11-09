//
//  ProductsView.swift
//  SnappyV2Study
//
//  Created by Henrik Gustavii on 23/06/2021.
//

import SwiftUI

struct ProductsView: View {
    @Environment(\.colorScheme) var colorScheme
    @StateObject var viewModel = ProductsViewModel(container: .preview)
    #warning("Need to change where creation of view model is handled")
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
            case .subCategory:
                subCategoryView()
            case .result:
                resultsView()
            default:
                categoryView()
            }
    }
    
    func categoryView() -> some View {
        LazyVGrid(columns: gridLayout, spacing: 20) {
            ForEach(MockData.categoryData, id: \.id) { details in
                ProductCategoryCardView(categoryDetails: details)
                    .environmentObject(viewModel)
            }
        }
    }
    
    func subCategoryView() -> some View {
        LazyVStack {
            ForEach(MockData.subCategoryData, id: \.id) { details in
                ProductSubCategoryCardView(subCategoryDetails: details)
                    .environmentObject(viewModel)
            }
        }
    }
    
    func resultsView() -> some View {
        VStack {
            filterButton()
                .padding(.bottom)
            
            LazyVGrid(columns: resultGridLayout, spacing: 14) {
                ForEach(MockData.resultsData, id: \.id) { results in
                    ProductCardView(productDetail: results)
                        .environmentObject(viewModel)
                }
            }
            .padding(.horizontal, 4)
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
        ProductsView()
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
        ProductDetail(label: "Some whiskey or other that possibly is not Scottish", image: "whiskey1", currentPrice: "£20.90", previousPrice: "£24.45", offer: "20% off", description: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Curabitur feugiat pharetra aliquam. Sed eget commodo dolor. Quisque purus nisi, commodo sit amet augue at, convallis placerat erat. Donec in euismod turpis, in dictum est. Vestibulum imperdiet interdum tempus. Mauris pellentesque tellus scelerisque, vestibulum lacus volutpat, placerat felis. Morbi placerat, nulla quis euismod eleifend, dui dui laoreet massa, sed suscipit arcu nunc facilisis odio. Morbi tempor libero eget viverra vulputate. Curabitur ante orci, auctor id hendrerit sit amet, tincidunt ut nisi.", ingredients: """
Lorem ipsum dolor sit amet
Vestibulum euismod ex ac erat suscipit
Donec at metus et magna accumsan cursus eu in neque
In efficitur dolor scelerisque metus varius
Duis mollis diam iaculis elit auctor
"""),
        ProductDetail(label: "Another whiskey", image: "whiskey2", currentPrice: "£24.95", previousPrice: nil, offer: nil, description: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Curabitur feugiat pharetra aliquam. Sed eget commodo dolor. Quisque purus nisi, commodo sit amet augue at, convallis placerat erat. Donec in euismod turpis, in dictum est. Vestibulum imperdiet interdum tempus. Mauris pellentesque tellus scelerisque, vestibulum lacus volutpat, placerat felis. Morbi placerat, nulla quis euismod eleifend, dui dui laoreet massa, sed suscipit arcu nunc facilisis odio. Morbi tempor libero eget viverra vulputate. Curabitur ante orci, auctor id hendrerit sit amet, tincidunt ut nisi.", ingredients: """
Lorem ipsum dolor sit amet
Vestibulum euismod ex ac erat suscipit
Donec at metus et magna accumsan cursus eu in neque
In efficitur dolor scelerisque metus varius
Duis mollis diam iaculis elit auctor
"""),
        ProductDetail(label: "Yet another whiskey", image: "whiskey3", currentPrice: "£20.90", previousPrice: "£24.45", offer: "Meal Deal", description: nil, ingredients: nil),
        ProductDetail(label: "Really, another whiskey?", image: "whiskey4", currentPrice: "£34.70", previousPrice: nil, offer: "3 for 2", description: nil, ingredients: nil),
        ProductDetail(label: "Some whiskey or other that possibly is not Scottish", image: "whiskey1", currentPrice: "£20.90", previousPrice: "£24.45", offer: nil, description: nil, ingredients: nil),
        ProductDetail(label: "Another whiskey", image: "whiskey2", currentPrice: "£20.90", previousPrice: "£24.45", offer: nil, description: nil, ingredients: nil)]
}

#endif
