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
    
    @Published var productDetail: RetailStoreMenuItem?
    
    @Published var selectedRetailStoreDetails: Loadable<RetailStoreDetails>
    @Published var selectedFulfilmentMethod: RetailStoreOrderMethodType
    @Published var rootCategoriesMenuFetch: Loadable<RetailStoreMenuFetch> = .notRequested
    @Published var specialOffersMenuFetch: Loadable<RetailStoreMenuFetch> = .notRequested
    @Published var missedOffersMenuFetch: Loadable<RetailStoreMenuFetch> = .notRequested
    @Published var subcategoriesOrItemsMenuFetch: Loadable<RetailStoreMenuFetch> = .notRequested
    
    @Published var rootCategories: [RetailStoreMenuCategory]?
    @Published var subCategories: [RetailStoreMenuCategory]?
    @Published var items: [RetailStoreMenuItem]?
    @Published var specialOfferItems: [RetailStoreMenuItem]?
    
    @Published var itemOptions: RetailStoreMenuItem?
    var selectedOffer: RetailStoreMenuItemAvailableDeal?
    var missedOffer: BasketItemMissedPromotion?
    
    var offerText: String? // Text used for the banner in missed offers / special offers summary view
    
    // Search variables
    @Published var searchText = ""
    @Published var isEditing = false
    @Published var searchResult: Loadable<RetailStoreMenuGlobalSearch> = .notRequested
    @Published var searchResultCategories = [GlobalSearchResultRecord]()
    @Published var searchResultItems = [GlobalSearchResultRecord]()
    
    private var cancellables = Set<AnyCancellable>()
    
    init(container: DIContainer, missedOffer: BasketItemMissedPromotion? = nil) {
        self.container = container
        let appState = container.appState
        
        _selectedRetailStoreDetails = .init(initialValue: appState.value.userData.selectedStore)
        _selectedFulfilmentMethod = .init(initialValue: appState.value.userData.selectedFulfilmentMethod)
        
        setupSelectedRetailStoreDetails(with: appState)
        setupSelectedFulfilmentMethod(with: appState)
        
        if let missedOffer = missedOffer {
            getMissedPromotion(offer: missedOffer)
            setupMissedPromotions()
        }
        
        setupRootCategories()
        setupSubCategoriesOrItems()
        
        setupSearchText()
        setupCategoriesOrItemSearchResult()
        setupSpecialOffers()
    }
    
    var viewState: ProductViewState {
        if specialOfferItems != nil {
            return .offers
        } else if subCategories == nil && items != nil {
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
            specialOfferItems = nil
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
    
    var isSearching: Bool {
        switch searchResult {
        case .isLoading(last: _, cancelBag: _):
            return true
        default:
            return false
        }
    }

var specialOffersIsLoading: Bool {
        switch specialOffersMenuFetch {
        case .isLoading(last: _, cancelBag: _):
            return true
        default:
            return false
        }
    }
    
    private func setupSelectedRetailStoreDetails(with appState: Store<AppState>) {
        appState
            .map(\.userData.selectedStore)
            .removeDuplicates()
            .assignWeak(to: \.selectedRetailStoreDetails, on: self)
            .store(in: &cancellables)
    }
    
    private func setupSelectedFulfilmentMethod(with appState: Store<AppState>) {
        appState
            .map(\.userData.selectedFulfilmentMethod)
            .removeDuplicates()
            .assignWeak(to: \.selectedFulfilmentMethod, on: self)
            .store(in: &cancellables)
    }
    
    private func setupRootCategories() {
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
    
    private func setupSubCategoriesOrItems() {
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
    
    func setupSearchText() {
        $searchText
            .dropFirst()
            .debounce(for: 0.4, scheduler: RunLoop.main)
            .sink { [weak self] searchText in
                guard let self = self else { return }
                
                if searchText.isEmpty == false {
                    self.search(text: searchText)
                }
            }
            .store(in: &cancellables)
    }
    
    func setupCategoriesOrItemSearchResult() {
        $searchResult
            .receive(on: RunLoop.main)
            .sink { [weak self] result in
                guard let self = self else { return }
                
                if let categories = result.value?.categories?.records {
                    self.searchResultCategories = categories
                }
                
                if let items = result.value?.menuItems?.records {
                    self.searchResultItems = items
                }
            }
            .store(in: &cancellables)
    }

private func setupSpecialOffers() {
        $specialOffersMenuFetch
            .receive(on: RunLoop.main)
            .sink { [weak self] menu in
                guard let self = self else { return }
                if let offerItems = menu.value?.menuItems {
                    self.specialOfferItems = offerItems
                }
            }
            .store(in: &cancellables)
    }
    
    private func setupMissedPromotions() {
        $missedOffersMenuFetch
            .receive(on: RunLoop.main)
            .sink { [weak self] menu in
                guard let self = self else { return }
                if let offerItems = menu.value?.menuItems {
                    self.specialOfferItems = offerItems
                }
            }
            .store(in: &cancellables)
    }
    
    func clearState() {
        subcategoriesOrItemsMenuFetch = .notRequested
        rootCategoriesMenuFetch = .notRequested
        specialOffersMenuFetch = .notRequested
        missedOffersMenuFetch = .notRequested
        items = nil
        subCategories = nil
        rootCategories = nil
        specialOfferItems = nil
        selectedOffer = nil
        offerText = nil
    }
    
    enum ProductViewState {
        case rootCategories
        case subCategories
        case items
        case offers
    }
    
    func getCategories() {
        container.services.retailStoreMenuService.getRootCategories(menuFetch: loadableSubject(\.rootCategoriesMenuFetch))
    }
    
    func categoryTapped(categoryID: Int) {
        container.services.retailStoreMenuService.getChildCategoriesAndItems(menuFetch: loadableSubject(\.subcategoriesOrItemsMenuFetch), categoryId: categoryID)
    }
    
    func search(text: String) {
        container.services.retailStoreMenuService.globalSearch(searchFetch: loadableSubject(\.searchResult), searchTerm: text, scope: nil, itemsPagination: nil, categoriesPagination: nil)
    }

	func specialOfferPillTapped(offer: RetailStoreMenuItemAvailableDeal) {
        selectedOffer = offer
        offerText = selectedOffer?.name
        container.services.retailStoreMenuService.getItems(menuFetch: loadableSubject(\.specialOffersMenuFetch), menuItemIds: nil, discountId: offer.id, discountSectionId: nil)
    }
    
    func getMissedPromotion(offer: BasketItemMissedPromotion) {
        missedOffer = offer
        offerText = missedOffer?.name
        container.services.retailStoreMenuService.getItems(menuFetch: loadableSubject(\.specialOffersMenuFetch), menuItemIds: nil, discountId: offer.referenceId, discountSectionId: nil)
    }
}
