//
//  ProductsView.swift
//  SnappyV2Study
//
//  Created by Henrik Gustavii on 23/06/2021.
//

import SwiftUI

class ProductsViewModel: ObservableObject {
    @Published var searchText = ""
    @Published var productDetail: ProductDetail?
    @Published var viewState: ProductViewState = .category
    
    enum ProductViewState {
        case category
        case subCategory
        case result
        case detail
    }
}

struct ProductsView: View {
    @StateObject var viewModel = ProductsViewModel()
    let gridLayout = [GridItem(spacing: 1), GridItem(spacing: 1)]
    
    var body: some View {
        ZStack {
            ScrollView {
                LazyVStack {
                    SearchBarView(label: "Search Store", text: $viewModel.searchText)
                        .padding(.vertical)
                    
                    productsResultsViews
                }
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
            ForEach(categoryData, id: \.id) { details in
                ProductCategoryCardView(categoryDetails: details)
                    .environmentObject(viewModel)
            }
        }
    }
    
    func subCategoryView() -> some View {
        LazyVStack {
            ForEach(subCategoryData, id: \.id) { details in
                ProductSubCategoryCardView(subCategoryDetails: details)
                    .environmentObject(viewModel)
            }
        }
    }
    
    func resultsView() -> some View {
        VStack {
            filterButton()
                .padding(.bottom)
            
            LazyVGrid(columns: gridLayout, spacing: 14) {
                ForEach(resultsData, id: \.id) { results in
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
    
    let categoryData = [ProductCategory(categoryName: "Juices", image: "bottle-cats"), ProductCategory(categoryName: "Sauces", image: "sauce-cats"), ProductCategory(categoryName: "Sauces", image: "sauce-cats"), ProductCategory(categoryName: "Juices", image: "bottle-cats"), ProductCategory(categoryName: "Juices", image: "bottle-cats"), ProductCategory(categoryName: "Sauces", image: "sauce-cats"), ProductCategory(categoryName: "Sauces", image: "sauce-cats"), ProductCategory(categoryName: "Juices", image: "bottle-cats")]
    
    let subCategoryData = [ProductSubCategory(subCategoryName: "Juices", image: "bottle-cats"), ProductSubCategory(subCategoryName: "Sauces", image: "sauce-cats"), ProductSubCategory(subCategoryName: "Sauces", image: "sauce-cats"), ProductSubCategory(subCategoryName: "Juices", image: "bottle-cats"), ProductSubCategory(subCategoryName: "Juices", image: "bottle-cats"), ProductSubCategory(subCategoryName: "Sauces", image: "sauce-cats"), ProductSubCategory(subCategoryName: "Sauces", image: "sauce-cats"), ProductSubCategory(subCategoryName: "Juices", image: "bottle-cats")]
    
    let resultsData = [ProductDetail(label: "Some whiskey or other that possibly is not Scottish", image: "whiskey1", currentPrice: "£20.90", previousPrice: "£24.45", offer: "20% off", description: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Curabitur feugiat pharetra aliquam. Sed eget commodo dolor. Quisque purus nisi, commodo sit amet augue at, convallis placerat erat. Donec in euismod turpis, in dictum est. Vestibulum imperdiet interdum tempus. Mauris pellentesque tellus scelerisque, vestibulum lacus volutpat, placerat felis. Morbi placerat, nulla quis euismod eleifend, dui dui laoreet massa, sed suscipit arcu nunc facilisis odio. Morbi tempor libero eget viverra vulputate. Curabitur ante orci, auctor id hendrerit sit amet, tincidunt ut nisi.", ingredients: """
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

struct ProductCategoryView_Previews: PreviewProvider {
    static var previews: some View {
        ProductsView()
            .previewCases()
    }
}
