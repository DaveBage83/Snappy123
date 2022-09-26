//
//  ProductsViewModel.swift
//  SnappyV2
//
//  Created by Henrik Gustavii on 12/08/2021.
//

import Foundation
import Combine

@MainActor
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
    @Published var subcategoriesOrItemsMenuFetch: Loadable<RetailStoreMenuFetch> = .notRequested
    @Published var rootCategories = [RetailStoreMenuCategory]()
    @Published var subCategories: [RetailStoreMenuCategory]
    @Published var unsortedItems: [RetailStoreMenuItem]
    @Published var sortedItems = [RetailStoreMenuItem]()
    @Published var specialOfferItems: [RetailStoreMenuItem]
    @Published var missedOfferMenus = [MissedOfferMenu]()
    @Published var itemOptions: RetailStoreMenuItem?
    @Published var showEnterMoreCharactersView = false
    @Published var selectedItem: RetailStoreMenuItem?
    
    // Search variables
    @Published var searchText = ""
    @Published var isSearchActive = false
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
    private var isFromSearchRequest = false
    
    // MARK: - Computed variables
    var splitRootCategories: [[RetailStoreMenuCategory]] {
        rootCategories.chunked(into: 2)
    }
    
    var showFilterButton: Bool {
        viewState == .items
    }
    
    var items: [RetailStoreMenuItem] {
            guard sortedItems.isEmpty else { return sortedItems }
            return unsortedItems
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
    
    var showStandardView: Bool { missedOffer == nil }
    
    var showBackButton: Bool {
        if viewState == .rootCategories { return false }
        if isSearchActive { return false }
        return true
    }
    
    var hideNavBar: Bool {
        viewState == .rootCategories
    }
    
    var showSnappyLogo: Bool {
        viewState == .rootCategories || isSearchActive
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

    // MARK: - Init
    init(container: DIContainer, missedOffer: BasketItemMissedPromotion? = nil) {
        self.container = container
        let appState = container.appState
        
        _selectedRetailStoreDetails = .init(initialValue: appState.value.userData.selectedStore)
        _selectedFulfilmentMethod = .init(initialValue: appState.value.userData.selectedFulfilmentMethod)
        _rootCategories = .init(initialValue: appState.value.storeMenu.rootCategories)
        _subCategories = .init(initialValue: appState.value.storeMenu.subCategories)
        _unsortedItems = .init(initialValue: appState.value.storeMenu.unsortedItems)
        _specialOfferItems = .init(initialValue: appState.value.storeMenu.specialOfferItems)
        
        setupSelectedRetailStoreDetails(with: appState)
        setupSelectedFulfilmentMethod(with: appState)
        setupRootCategories()
        setupSubCategoriesOrItems()
        setupSearchText()
        setupCategoriesOrItemSearchResult()
        setupSpecialOffers()
        setupRootCategoriesBinding(with: appState)
        setupSubCategoriesBinding(with: appState)
        setupUnsortedItemsBinding(with: appState)
        setupSpecialOfferItemsBinding(with: appState)
        
        if let missedOffer = missedOffer {
            getMissedPromotion(offer: missedOffer)
        } else {
            if viewState == .rootCategories {
                getCategories()
            }
        }
    }
    
    func setupRootCategoriesBinding(with appState: Store<AppState>) {
        appState
            .map(\.storeMenu.rootCategories)
            .removeDuplicates()
            .receive(on: RunLoop.main)
            .assignWeak(to: \.rootCategories, on: self)
            .store(in: &cancellables)
        
        $rootCategories
            .sink { appState.value.storeMenu.rootCategories = $0 }
            .store(in: &cancellables)
    }
    
    func setupSubCategoriesBinding(with appState: Store<AppState>) {
        appState
            .map(\.storeMenu.subCategories)
            .removeDuplicates()
            .receive(on: RunLoop.main)
            .assignWeak(to: \.subCategories, on: self)
            .store(in: &cancellables)
        
        $subCategories
            .sink { appState.value.storeMenu.subCategories = $0 }
            .store(in: &cancellables)
    }
    
    func setupUnsortedItemsBinding(with appState: Store<AppState>) {
        appState
            .map(\.storeMenu.unsortedItems)
            .removeDuplicates()
            .receive(on: RunLoop.main)
            .assignWeak(to: \.unsortedItems, on: self)
            .store(in: &cancellables)
        
        $unsortedItems
            .sink { appState.value.storeMenu.unsortedItems = $0 }
            .store(in: &cancellables)
    }
    
    func setupSpecialOfferItemsBinding(with appState: Store<AppState>) {
        appState
            .map(\.storeMenu.specialOfferItems)
            .removeDuplicates()
            .receive(on: RunLoop.main)
            .assignWeak(to: \.specialOfferItems, on: self)
            .store(in: &cancellables)
        
        $specialOfferItems
            .sink { appState.value.storeMenu.specialOfferItems = $0 }
            .store(in: &cancellables)
    }

    func backButtonTapped() {
        switch viewState {
        case .items:
            // This flag controls whether or not we show the search view when the back button is pressed from an item state
            if isFromSearchRequest {
                isSearchActive = true
                isFromSearchRequest = false
            }
            
            unsortedItems = []
            sortedItems = []
            // If subcategories is empty then we came directly from the root menu so we need to set subcategoriesOrItemsMenuFetch to .notRequested
            if subCategories.isEmpty {
                subcategoriesOrItemsMenuFetch = .notRequested
            }
        case .offers:
            specialOfferItems = []
            specialOffersMenuFetch = .notRequested
        default:
            subCategories = []
            unsortedItems = []
            sortedItems = []
            specialOfferItems = []
            subcategoriesOrItemsMenuFetch = .notRequested
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
                    self.unsortedItems = menuItems
                }
                
                if let subCategories = menu.value?.categories {
                    self.subCategories = subCategories
                }
            }
            .store(in: &cancellables)
    }
    
    private func setupSearchText() {
        $searchText
            .removeDuplicates()
            .debounce(for: 0.4, scheduler: RunLoop.main)
            .sink { [weak self] searchText in
                guard let self = self else { return }
                
                if searchText.count == 1 {
                    self.showEnterMoreCharactersView = true
                    self.isSearchActive = true
                } else if searchText.count > 1 {
                    self.showEnterMoreCharactersView = false
                    self.search(text: searchText)
                    self.isSearchActive = true
                } else {
                    self.showEnterMoreCharactersView = false
                    self.isSearchActive = false
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
                
                if let dealSections = menu.value?.dealSections {
                    self.assignSpecialOfferMenu(dealSections: dealSections)
                }
            }
            .store(in: &cancellables)
    }
    
    struct MissedOfferMenu: Identifiable {
        let id: Int
        let name: String
        let items: [RetailStoreMenuItem]
    }
    
    func assignSpecialOfferMenu(dealSections: [MenuItemCategory]) {
        // go through dealSections and find items that belong and assign to MissedOfferMenu
        var missedOfferMenus = [MissedOfferMenu]()
        for dealSection in dealSections {
            let missedItems = specialOfferItems.filter { $0.deal?.section?.id == dealSection.id }
            missedOfferMenus.append(MissedOfferMenu(id: dealSection.id, name: dealSection.name, items: missedItems))
        }
        self.missedOfferMenus = missedOfferMenus
    }
    
    func clearState() {
        subcategoriesOrItemsMenuFetch = .notRequested
        rootCategoriesMenuFetch = .notRequested
        specialOffersMenuFetch = .notRequested
        sortedItems = []
        unsortedItems = []
        subCategories = []
        rootCategories = []
        specialOfferItems = []
        selectedOffer = nil
        offerText = nil
    }
    
    private func getCategories() {
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
        
        if let action = category.action, let discountId = action.params?.discountId {
            container.services.retailStoreMenuService.getItems(menuFetch: loadableSubject(\.specialOffersMenuFetch), menuItemIds: nil, discountId: discountId, discountSectionId: nil)
        } else {
            container.services.retailStoreMenuService.getChildCategoriesAndItems(menuFetch: loadableSubject(\.subcategoriesOrItemsMenuFetch), categoryId: category.id)
        }
    }
    
    func categoryTapped(with globalSearchCategory: GlobalSearchResultRecord) {
        itemNavigationTitle = globalSearchCategory.name
        
        container.services.retailStoreMenuService.getChildCategoriesAndItems(menuFetch: loadableSubject(\.subcategoriesOrItemsMenuFetch), categoryId: globalSearchCategory.id)
    }

    func searchCategoryTapped(category: GlobalSearchResultRecord) {
        isFromSearchRequest = true
        isSearchActive = false
        unsortedItems = []
        sortedItems = []
        categoryTapped(with: category)
    }
    
    func search(text: String) {
        container.services.retailStoreMenuService.globalSearch(searchFetch: loadableSubject(\.searchResult), searchTerm: text, scope: nil, itemsPagination: nil, categoriesPagination: nil)
    }

    func specialOfferPillTapped(offer: RetailStoreMenuItemAvailableDeal, offersRetrieved: (() -> Void)? = nil) {
        selectedOffer = offer
        offerText = selectedOffer?.name
        container.services.retailStoreMenuService.getItems(menuFetch: loadableSubject(\.specialOffersMenuFetch), menuItemIds: nil, discountId: offer.id, discountSectionId: nil)
        if let offersRetrieved = offersRetrieved {
            offersRetrieved()
        }
    }
    
    func getMissedPromotion(offer: BasketItemMissedPromotion) {
        missedOffer = offer
        offerText = missedOffer?.name
        container.services.retailStoreMenuService.getItems(menuFetch: loadableSubject(\.specialOffersMenuFetch), menuItemIds: nil, discountId: offer.id, discountSectionId: nil)
    }
    
    func cancelSearchButtonTapped() {
        searchResult = .notRequested
    }
    
    /// Splits an array of RetailStoreMenuItem into an array of [RetailStoreMenuItem],
    /// with each inner array containing the specified number of elements
    func splitItems(storeItems: [RetailStoreMenuItem], into: Int) -> [[RetailStoreMenuItem]] {
        storeItems.chunked(into: into)
    }
    
    enum ItemSortMode {
        case `default`
        case aToZ
        case zToA
        case priceHighToLow
        case priceLowToHigh
        case caloriesLowToHigh
    }
    
    func sort(by sortMode: ProductsViewModel.ItemSortMode) {
        switch sortMode {
        case .default:
            sortedItems = []
        case .aToZ:
            sortedItems = unsortedItems.sorted(by: \.name)
        case .zToA:
            sortedItems = unsortedItems.sorted(by: \.name, using: >)
        case .priceHighToLow:
            sortedItems = unsortedItems.sorted(by: \.price.price, using: >)
        case .priceLowToHigh:
            sortedItems = unsortedItems.sorted(by: \.price.price)
        case .caloriesLowToHigh:
            sortedItems = unsortedItems.sorted(by: \.calories)
        }
    }
    
    func resetSelectedItem() {
        selectedItem = nil
    }
    
    func selectItem(_ item: RetailStoreMenuItem) {
        selectedItem = item
    }
}
