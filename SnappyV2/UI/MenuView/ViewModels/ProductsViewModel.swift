//
//  ProductsViewModel.swift
//  SnappyV2
//
//  Created by Henrik Gustavii on 12/08/2021.
//

import Foundation
import Combine

class ProductsViewModel: ObservableObject {
    let container: DIContainer
    @Published var searchText = ""
    @Published var productDetail: RetailStoreMenuItem?
    @Published var viewState: ProductViewState = .category
    
    @Published var selectedRetailStoreDetails: Loadable<RetailStoreDetails>
    @Published var selectedFulfilmentMethod: RetailStoreOrderMethodType
    @Published var menuFetch: Loadable<RetailStoreMenuFetch> = .notRequested
    
    private var cancellables = Set<AnyCancellable>()
    
    init(container: DIContainer) {
        self.container = container
        let appState = container.appState
        
        _selectedRetailStoreDetails = .init(initialValue: appState.value.userData.selectedStore)
        _selectedFulfilmentMethod = .init(initialValue: appState.value.userData.selectedFulfilmentMethod)
        
        setupSelectedRetailStoreDetails(with: appState)
        setupSelectedFulfilmentMethod(with: appState)
    }
    
    func setupSelectedRetailStoreDetails(with appState: Store<AppState>) {
        appState
            .map(\.userData.selectedStore)
            .removeDuplicates()
            .assignWeak(to: \.selectedRetailStoreDetails, on: self)
            .store(in: &cancellables)
    }
    
    func setupSelectedFulfilmentMethod(with appState: Store<AppState>) {
        appState
            .map(\.userData.selectedFulfilmentMethod)
            .removeDuplicates()
            .assignWeak(to: \.selectedFulfilmentMethod, on: self)
            .store(in: &cancellables)
    }
    
    enum ProductViewState {
        case category
        case subCategory
        case result
        case detail
    }
    
    func getCategories() {
        if let storeID = selectedRetailStoreDetails.value?.id {
            container.services.retailStoreMenuService.getRootCategories(menuFetch: loadableSubject(\.menuFetch), storeId: storeID)
        }
    }
    
    func getSubCategoriesAndItems(categoryID: Int) {
        if let storeID = selectedRetailStoreDetails.value?.id {
            container.services.retailStoreMenuService.getChildCategoriesAndItems(menuFetch: loadableSubject(\.menuFetch), storeId: storeID, categoryId: categoryID, fulfilmentMethod: container.appState.value.userData.selectedFulfilmentMethod)
            #warning("Should fulfilment method come from view model or should service layer handle that automatically?")
        }
    }
}
