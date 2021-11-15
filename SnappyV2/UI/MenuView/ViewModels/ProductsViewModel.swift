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
    
    @Published var selectedRetailStoreDetails: Loadable<RetailStoreDetails>
    @Published var selectedFulfilmentMethod: RetailStoreOrderMethodType
    @Published var rootCategoriesMenuFetch: Loadable<RetailStoreMenuFetch> = .notRequested
    @Published var subcategoriesOrItemsMenuFetch: Loadable<RetailStoreMenuFetch> = .notRequested
    
    @Published var rootCategories: [RetailStoreMenuCategory]?
    @Published var subCategories: [RetailStoreMenuCategory]?
    @Published var items: [RetailStoreMenuItem]?
    
    @Published var itemOptions: RetailStoreMenuItem?
    
    private var cancellables = Set<AnyCancellable>()
    
    init(container: DIContainer) {
        self.container = container
        let appState = container.appState
        
        _selectedRetailStoreDetails = .init(initialValue: appState.value.userData.selectedStore)
        _selectedFulfilmentMethod = .init(initialValue: appState.value.userData.selectedFulfilmentMethod)
        
        setupSelectedRetailStoreDetails(with: appState)
        setupSelectedFulfilmentMethod(with: appState)
        
        setupRootCategories()
        setupSubCategoriesOrItems()
    }
    
    var viewState: ProductViewState {
        if subCategories == nil && items != nil {
            return .items
        } else if subCategories != nil && items == nil {
            return .subCategories
        } else if subCategories != nil && items != nil {
            return .items
        }
        return .rootCategories
    }
    
    func backButtonTapped() {
        if viewState == .items {
            items = nil
        } else {
            subCategories = nil
        }
    }
    
    var rootCategoriesIsLoading: Bool {
        switch rootCategoriesMenuFetch {
        case .isLoading(last: _, cancelBag: _):
            return true
        default:
            return false
        }
    }
    
    var subCategoriesOrItemsIsLoading: Bool {
        switch subcategoriesOrItemsMenuFetch {
        case .isLoading(last: _, cancelBag: _):
            return true
        default:
            return false
        }
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
    
    func setupRootCategories() {
        $rootCategoriesMenuFetch
            .receive(on: RunLoop.main)
            .sink { [weak self] menu in
                guard let self = self else { return }
                if let categories = menu.value?.categories {
                    self.rootCategories = categories
                }
            }
            .store(in: &cancellables)
    }
    
    func setupSubCategoriesOrItems() {
        $subcategoriesOrItemsMenuFetch
            .receive(on: RunLoop.main)
            .sink { [weak self] menu in
                guard let self = self else { return }
                if let menuItems = menu.value?.menuItems {
                    self.items = menuItems
                }
            }
            .store(in: &cancellables)
        
        $subcategoriesOrItemsMenuFetch
            .receive(on: RunLoop.main)
            .sink { [weak self] menu in
                guard let self = self else { return }
                if let sunCategories = menu.value?.categories {
                    self.subCategories = sunCategories
                }
            }
            .store(in: &cancellables)
    }
    
    func clearState() {
        subcategoriesOrItemsMenuFetch = .notRequested
        rootCategoriesMenuFetch = .notRequested
        items = nil
        subCategories = nil
        rootCategories = nil
    }
    
    enum ProductViewState {
        case rootCategories
        case subCategories
        case items
    }
    
    func getCategories() {
        if let storeID = selectedRetailStoreDetails.value?.id {
            container.services.retailStoreMenuService.getRootCategories(menuFetch: loadableSubject(\.rootCategoriesMenuFetch), storeId: storeID)
        }
    }
    
    func categoryTapped(categoryID: Int) {
        if let storeID = selectedRetailStoreDetails.value?.id {
            container.services.retailStoreMenuService.getChildCategoriesAndItems(menuFetch: loadableSubject(\.subcategoriesOrItemsMenuFetch), storeId: storeID, categoryId: categoryID)
        }
    }
}
