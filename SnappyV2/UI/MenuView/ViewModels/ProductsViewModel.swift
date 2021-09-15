//
//  ProductsViewModel.swift
//  SnappyV2
//
//  Created by Henrik Gustavii on 12/08/2021.
//

import Foundation

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
