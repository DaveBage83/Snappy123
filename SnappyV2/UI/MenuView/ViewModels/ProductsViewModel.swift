//
//  ProductsViewModel.swift
//  SnappyV2
//
//  Created by Henrik Gustavii on 12/08/2021.
//

import Foundation
import Combine

class ProductsViewModel: ObservableObject {
    enum ProductViewState {
        case rootCategories
        case subCategories
        case items
        case offers
    }
    
    // MARK: - Publishers
    @Published var productDetail: RetailStoreMenuItem?
    @Published var selectedRetailStoreDetails: Loadable<RetailStoreDetails>
    @Published var selectedFulfilmentMethod: RetailStoreOrderMethodType
    @Published var rootCategoriesMenuFetch: Loadable<RetailStoreMenuFetch> = .notRequested
    @Published var specialOffersMenuFetch: Loadable<RetailStoreMenuFetch> = .notRequested
    @Published var missedOffersMenuFetch: Loadable<RetailStoreMenuFetch> = .notRequested
    @Published var subcategoriesOrItemsMenuFetch: Loadable<RetailStoreMenuFetch> = .notRequested
    @Published var rootCategories = [RetailStoreMenuCategory]()
    @Published var subCategories = [RetailStoreMenuCategory]()
    @Published var items = [RetailStoreMenuItem]()
    @Published var specialOfferItems = [RetailStoreMenuItem]()
    @Published var itemOptions: RetailStoreMenuItem?
    @Published var showEnterMoreCharactersView = false
    
    // Search variables
    @Published var searchText = ""
    @Published var isEditing = false
    @Published var searchResult: Loadable<RetailStoreMenuGlobalSearch> = .notRequested
    @Published var searchResultCategories = [GlobalSearchResultRecord]()
    @Published var searchResultItems = [RetailStoreMenuItem]()
    @Published var subCategoryNavigationTitle: String?
    @Published var itemNavigationTitle: String?
    
    // MARK: - Properties
    let container: DIContainer
    var selectedOffer: RetailStoreMenuItemAvailableDeal?
    var missedOffer: BasketItemMissedPromotion?
    var offerText: String? // Text used for the banner in missed offers / special offers summary view
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Computed variables
    var splitRootCategories: [[RetailStoreMenuCategory]] {
        rootCategories.chunked(into: 2)
    }
    
    var currentNavigationTitle: String? {
        switch viewState {
        case .subCategories:
            return subCategoryNavigationTitle
        case .items:
            return itemNavigationTitle
        default:
            return nil
        }
    }
    
    var splitSubCategories: [[RetailStoreMenuCategory]] {
        subCategories.chunked(into: 2)
    }
    
    var viewState: ProductViewState {
        if specialOfferItems.isEmpty == false {
            return .offers
        } else if items.isEmpty == false {
            return .items
        } else if subCategories.isEmpty == false {
            return .subCategories
        }
        return .rootCategories
    }

    // MARK: - Init
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

    func backButtonTapped() {
        switch viewState {
        case .items:
            items = []
            // If subcategories is empty then we came directly from the root menu so we need to set subcategoriesOrItemsMenuFetch to .notRequested
            if subCategories.isEmpty {
                subcategoriesOrItemsMenuFetch = .notRequested
            }
        default:
            subCategories = []
            items = []
            specialOfferItems = []
            subcategoriesOrItemsMenuFetch = .notRequested
        }
    }
    
    var showBackButton: Bool {
        if viewState == .rootCategories { return false }
        if isEditing { return false }
        return true
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
    
    var categoryLoading: Bool {
        rootCategoriesIsLoading || subCategoriesOrItemsIsLoading || specialOffersIsLoading
    }
    
    var searchIsLoaded: Bool {
        switch searchResult {
        case .loaded(_):
            return true
        default:
            return false
        }
    }
    
    var showSearchResultCategories: Bool {
        searchResultCategories.isEmpty == false && searchText.count > 1
    }
    
    var showSearchResultItems: Bool {
        searchResultItems.isEmpty == false && searchText.count > 1
    }
    
    var noSearchResult: Bool {
        searchIsLoaded && (searchResultItems.isEmpty && searchResultCategories.isEmpty)
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
            .removeDuplicates()
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
            .removeDuplicates()
            .receive(on: RunLoop.main)
            .sink { [weak self] menu in
                guard let self = self else { return }
                
                if let menuItems = menu.value?.menuItems {
                    self.items = menuItems
                }
                
                if let subCategories = menu.value?.categories {
                    self.subCategories = subCategories
                }
            }
            .store(in: &cancellables)
    }
    
    private func setupSearchText() {
        $searchText
            .debounce(for: 0.4, scheduler: RunLoop.main)
            .sink { [weak self] searchText in
                guard let self = self else { return }
                
                if searchText.count == 1 {
                    self.showEnterMoreCharactersView = true
                    self.isEditing = true
                } else if searchText.count > 1 {
                    self.showEnterMoreCharactersView = false
                    self.search(text: searchText)
                    self.isEditing = true
                } else {
                    self.showEnterMoreCharactersView = false
                    self.isEditing = false
                }
            }
            .store(in: &cancellables)
    }
    
    private func setupCategoriesOrItemSearchResult() {
        $searchResult
            .receive(on: RunLoop.main)
            .sink { [weak self] result in
                guard let self = self else { return }
                
                if let categories = result.value?.categories?.records {
                    self.searchResultCategories = categories
                } else { self.searchResultCategories = [] }
                
                if let items = result.value?.menuItems?.records {
                    self.searchResultItems = items
                } else { self.searchResultItems = [] }
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
        items = []
        subCategories = []
        rootCategories = []
        specialOfferItems = []
        selectedOffer = nil
        offerText = nil
    }
    
    func getCategories() {
        container.services.retailStoreMenuService.getRootCategories(menuFetch: loadableSubject(\.rootCategoriesMenuFetch))
    }

    func categoryTapped(with category: RetailStoreMenuCategory, fromState: ProductViewState? = nil) {
        switch fromState {
        case .rootCategories:
            self.subCategoryNavigationTitle = category.name
            self.itemNavigationTitle = category.name
        case .subCategories:
            self.itemNavigationTitle = category.name
        default:
            break
        }
        
        container.services.retailStoreMenuService.getChildCategoriesAndItems(menuFetch: loadableSubject(\.subcategoriesOrItemsMenuFetch), categoryId: category.id)
    }
    
    func categoryTapped(with categoryId: Int) {
        container.services.retailStoreMenuService.getChildCategoriesAndItems(menuFetch: loadableSubject(\.subcategoriesOrItemsMenuFetch), categoryId: categoryId)
    }

    func searchCategoryTapped(categoryID: Int) {
        isEditing = false
        items = []
        categoryTapped(with: categoryID)
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
    
    func cancelSearchButtonTapped() {
        searchResult = .notRequested
    }
    
    /// Splits an array of RetailStoreMenuItem into an array of [RetailStoreMenuItem],
    /// with each inner array containing the specified number of elements
    func splitItems(storeItems: [RetailStoreMenuItem], into: Int) -> [[RetailStoreMenuItem]] {
        storeItems.chunked(into: into)
    }
}
