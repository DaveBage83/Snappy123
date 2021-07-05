//
//  ProductCategoryView.swift
//  SnappyV2Study
//
//  Created by Henrik Gustavii on 23/06/2021.
//

import SwiftUI

class ProductCategoryViewModel: ObservableObject {
    @Published var searchText = ""
}

struct ProductCategoryView: View {
    @StateObject var viewModel = ProductCategoryViewModel()
    let gridLayout = [GridItem(spacing: 10), GridItem(spacing: 10)]
    
    var body: some View {
        ScrollView {
            LazyVStack {
                SearchBarView(label: "Search Store", text: $viewModel.searchText)
                    .padding(.vertical)
                
                LazyVGrid(columns: gridLayout, spacing: 20) {
                    ForEach(categoryData, id: \.id) { details in
                        ProductCategoryCardView(categoryDetails: details)
                    }
                }
            }
        }
    }
    
    let categoryData = [ProductCategory(categoryName: "Juices", image: "bottle-cats"), ProductCategory(categoryName: "Sauces", image: "sauce-cats"), ProductCategory(categoryName: "Sauces", image: "sauce-cats"), ProductCategory(categoryName: "Juices", image: "bottle-cats"), ProductCategory(categoryName: "Juices", image: "bottle-cats"), ProductCategory(categoryName: "Sauces", image: "sauce-cats"), ProductCategory(categoryName: "Sauces", image: "sauce-cats"), ProductCategory(categoryName: "Juices", image: "bottle-cats")]
}

struct ProductCategoryView_Previews: PreviewProvider {
    static var previews: some View {
        ProductCategoryView()
    }
}
