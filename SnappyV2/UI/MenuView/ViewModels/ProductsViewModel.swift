//
//  ProductsViewModel.swift
//  SnappyV2
//
//  Created by Henrik Gustavii on 12/08/2021.
//

import Foundation
import Combine

// 3rd Party
import Firebase

@MainActor
class ProductsViewModel: ObservableObject {
    enum ProductViewState {
        case rootCategories
        case subCategories
        case items
        case offers
    }
    
    enum Errors: Swift.Error, LocalizedError {
        case categoryEmpty
        
        var errorDescription: String? {
            switch self {
            case .categoryEmpty:
                return Strings.ProductsView.Alerts.noItemsInCategory.localized
            }
        }
    }
    
    // MARK: - Publishers
    @Published var productDetail: RetailStoreMenuItem?
    @Published var selectedRetailStoreDetails: Loadable<RetailStoreDetails>
    @Published var selectedFulfilmentMethod: RetailStoreOrderMethodType
    @Published var rootCategoriesMenuFetch: Loadable<RetailStoreMenuFetch> = .notRequested
    @Published var specialOffersMenuFetch: Loadable<RetailStoreMenuFetch> = .notRequested
    @Published var subcategoriesOrItemsMenuFetch: Loadable<RetailStoreMenuFetch> = .notRequested
    @Published var rootCategories = [RetailStoreMenuCategory]()
    @Published var subCategories: [[RetailStoreMenuCategory]]
    @Published var unsortedItems: [RetailStoreMenuItem]
    @Published var sortedItems = [RetailStoreMenuItem]()
    @Published var specialOfferItems: [RetailStoreMenuItem]
    @Published var missedOfferMenus = [MissedOfferMenu]()
    @Published var itemOptions: RetailStoreMenuItem?
    @Published var showEnterMoreCharactersView = false
    @Published var selectedItem: RetailStoreMenuItem?
    @Published var error: Error?
    
    // Search variables
    @Published var searchText: String
    @Published var isSearchActive = false
    @Published var searchResult: Loadable<RetailStoreMenuGlobalSearch> = .notRequested
    @Published var searchResultCategories: [GlobalSearchResultRecord]
    @Published var searchResultItems: [RetailStoreMenuItem]
    @Published var navigationWithIsSearchActive: Int
    
    // Titles
    @Published var subCategoryNavigationTitle: [String]
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
            return subCategoryNavigationTitle.last
        case .items:
            return itemNavigationTitle
        default:
            return nil
        }
    }
    
    var lastSubCategories: [RetailStoreMenuCategory] {
        if let subCategories = subCategories.last {
            return subCategories
        }
        return []
    }

    var splitSubCategories: [[RetailStoreMenuCategory]] {
        if let subCategories = subCategories.last {
            return subCategories.chunked(into: 2)
        }
        return []
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
    
    var showSearchView: Bool {
        return isSearchActive && navigationWithIsSearchActive == 0
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
        
        // general menu navigation
        _selectedRetailStoreDetails = .init(initialValue: appState.value.userData.selectedStore)
        _selectedFulfilmentMethod = .init(initialValue: appState.value.userData.selectedFulfilmentMethod)
        _rootCategories = .init(initialValue: appState.value.storeMenu.rootCategories)
        _subCategories = .init(initialValue: appState.value.storeMenu.subCategories)
        _unsortedItems = .init(initialValue: appState.value.storeMenu.unsortedItems)
        _specialOfferItems = .init(initialValue: appState.value.storeMenu.specialOfferItems)
        
        // menu search navigation
        _searchText = .init(initialValue: appState.value.storeMenu.searchText)
        _searchResultCategories = .init(initialValue: appState.value.storeMenu.searchResultCategories)
        _searchResultItems = .init(initialValue: appState.value.storeMenu.searchResultItems)
        _navigationWithIsSearchActive = .init(initialValue: appState.value.storeMenu.navigationWithIsSearchActive)
        
        // titles
        _subCategoryNavigationTitle = .init(initialValue: appState.value.storeMenu.subCategoryNavigationTitle)
        _itemNavigationTitle = .init(initialValue: appState.value.storeMenu.itemNavigationTitle)
        
        // no need to have the isSearchActive represented in the appState as it can be
        // established by the searchText being or not
        if searchText.isEmpty == false {
            isSearchActive = true
        }
        
        setupSelectedRetailStoreDetails(with: appState)
        setupSelectedFulfilmentMethod(with: appState)
        setupRootCategories()
        setupSubCategoriesOrItems()
        setupSearchText()
        setupCategoriesOrItemSearchResult()
        setupSpecialOffers()
        setupIsSearchActive()
        setupRootCategoriesBinding(with: appState)
        setupSubCategoriesBinding(with: appState)
        setupUnsortedItemsBinding(with: appState)
        setupSpecialOfferItemsBinding(with: appState)
        setupSearchTextBinding(with: appState)
        setupSearchResultCategoriesBinding(with: appState)
        setupSearchResultItemsBinding(with: appState)
        setupNavigationWithIsSearchActiveBinding(with: appState)
        setupSubCategoryNavigationTitleBinding(with: appState)
        setupItemNavigationTitleBinding(with: appState)
        
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
            .receive(on: RunLoop.main)
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
            .receive(on: RunLoop.main)
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
            .receive(on: RunLoop.main)
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
            .receive(on: RunLoop.main)
            .sink { appState.value.storeMenu.specialOfferItems = $0 }
            .store(in: &cancellables)
    }
    
    private func setupSearchTextBinding(with appState: Store<AppState>) {
        appState
            .map(\.storeMenu.searchText)
            .removeDuplicates()
            .receive(on: RunLoop.main)
            .assignWeak(to: \.searchText, on: self)
            .store(in: &cancellables)
        
        $searchText
            .receive(on: RunLoop.main)
            .sink { appState.value.storeMenu.searchText = $0 }
            .store(in: &cancellables)
    }
    
    private func setupSearchResultCategoriesBinding(with appState: Store<AppState>) {
        appState
            .map(\.storeMenu.searchResultCategories)
            .removeDuplicates()
            .receive(on: RunLoop.main)
            .assignWeak(to: \.searchResultCategories, on: self)
            .store(in: &cancellables)
        
        $searchResultCategories
            .receive(on: RunLoop.main)
            .sink { appState.value.storeMenu.searchResultCategories = $0 }
            .store(in: &cancellables)
    }
    
    private func setupSearchResultItemsBinding(with appState: Store<AppState>) {
        appState
            .map(\.storeMenu.searchResultItems)
            .removeDuplicates()
            .receive(on: RunLoop.main)
            .assignWeak(to: \.searchResultItems, on: self)
            .store(in: &cancellables)
        
        $searchResultItems
            .receive(on: RunLoop.main)
            .sink { appState.value.storeMenu.searchResultItems = $0 }
            .store(in: &cancellables)
    }
    
    private func setupNavigationWithIsSearchActiveBinding(with appState: Store<AppState>) {
        appState
            .map(\.storeMenu.navigationWithIsSearchActive)
            .removeDuplicates()
            .receive(on: RunLoop.main)
            .assignWeak(to: \.navigationWithIsSearchActive, on: self)
            .store(in: &cancellables)
        
        $navigationWithIsSearchActive
            .receive(on: RunLoop.main)
            .sink { appState.value.storeMenu.navigationWithIsSearchActive = $0 }
            .store(in: &cancellables)
    }
    
    private func setupSubCategoryNavigationTitleBinding(with appState: Store<AppState>) {
        appState
            .map(\.storeMenu.subCategoryNavigationTitle)
            .removeDuplicates()
            .receive(on: RunLoop.main)
            .assignWeak(to: \.subCategoryNavigationTitle, on: self)
            .store(in: &cancellables)
        
        $subCategoryNavigationTitle
            .receive(on: RunLoop.main)
            .sink { appState.value.storeMenu.subCategoryNavigationTitle = $0 }
            .store(in: &cancellables)
    }
    
    private func setupItemNavigationTitleBinding(with appState: Store<AppState>) {
        appState
            .map(\.storeMenu.itemNavigationTitle)
            .removeDuplicates()
            .receive(on: RunLoop.main)
            .assignWeak(to: \.itemNavigationTitle, on: self)
            .store(in: &cancellables)
        
        $itemNavigationTitle
            .receive(on: RunLoop.main)
            .sink { appState.value.storeMenu.itemNavigationTitle = $0 }
            .store(in: &cancellables)
    }

    func backButtonTapped() {
        
        guard (isSearchActive && navigationWithIsSearchActive == 0) == false else {
            // stepping back to a subcategory that was prior to the search
            searchText = ""
            return
        }
        
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
            if subCategoryNavigationTitle.isEmpty == false {
                subCategoryNavigationTitle.removeLast()
            }
            if navigationWithIsSearchActive > 0 {
                navigationWithIsSearchActive -= 1
            }
        case .offers:
            specialOfferItems = []
            specialOffersMenuFetch = .notRequested
        default:
            if subCategories.isEmpty == false {
                subCategories.removeLast()
            }
            if subCategoryNavigationTitle.isEmpty == false {
                subCategoryNavigationTitle.removeLast()
            }
            if subCategories.isEmpty {
                subcategoriesOrItemsMenuFetch = .notRequested
            }
            if navigationWithIsSearchActive > 0 {
                navigationWithIsSearchActive -= 1
            }
            unsortedItems = []
            sortedItems = []
            specialOfferItems = []
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
            .filter { $0.value != nil }
            .receive(on: RunLoop.main)
            .sink { [weak self] menu in
                guard let self = self else { return }
                
                if let menuItems = menu.value?.menuItems {
                    self.unsortedItems = menuItems
                    if self.isSearchActive {
                        self.navigationWithIsSearchActive += 1
                    }
                } else if let subCategories = menu.value?.categories {
                    // Despite the .removeDuplicates() above something causes a repeat of
                    // the same sub categories reaching here so the same subcategory is
                    // added twice without this condition
                    if self.subCategories.last != subCategories {
                        self.subCategories.append(subCategories)
                        if self.isSearchActive {
                            self.navigationWithIsSearchActive += 1
                        }
                    }
                } else {
                    self.error = Errors.categoryEmpty
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
    
    private func setupIsSearchActive() {
        $isSearchActive
            .removeDuplicates()
            .filter { $0 == false }
            .sink { [weak self] _ in
                guard let self = self else { return }
                if self.navigationWithIsSearchActive > 0 {
                    // if there has been navigation away from the search view, whilist displaying the
                    // search, then clear the subcategories and return the user back to the root
                    // category
                    self.unsortedItems = []
                    self.sortedItems = []
                    self.subCategories = []
                    self.subcategoriesOrItemsMenuFetch = .notRequested
                    self.navigationWithIsSearchActive = 0
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
                
                // whenever a new search is triggered and there was navigation with the previous
                // search results, then clear the history
                if self.navigationWithIsSearchActive > 0 {
                    self.unsortedItems = []
                    self.sortedItems = []
                    self.subCategories = []
                    self.subcategoriesOrItemsMenuFetch = .notRequested
                    self.navigationWithIsSearchActive = 0
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
        navigationWithIsSearchActive = 0
    }
    
    private func getCategories() {
        container.services.retailStoreMenuService.getRootCategories(menuFetch: loadableSubject(\.rootCategoriesMenuFetch))
    }

    func categoryTapped(with category: RetailStoreMenuCategory, fromState: ProductViewState? = nil) {
        switch fromState {
        case .rootCategories, .subCategories:
            self.subCategoryNavigationTitle.append(category.name)
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
        sendSearchResultSelectionEvent(categoryId: category.id, name: category.name)
        isFromSearchRequest = true
        //isSearchActive = false
        subCategories = []
        subCategoryNavigationTitle = []
        unsortedItems = []
        sortedItems = []
        categoryTapped(with: category)
    }
    
    func logItemIteraction(with item: RetailStoreMenuItem) {
        sendSearchResultSelectionEvent(categoryId: item.mainCategory.id, itemId: item.id, name: item.name)
    }
    
    private func sendSearchResultSelectionEvent(categoryId: Int, itemId: Int? = nil, dealId: Int? = nil, name: String) {
        // only record the event if the activity is from the first step of the fetched
        // search results
        guard
            let searchResult = searchResult.value,
            let fetchSearchTerm = searchResult.fetchSearchTerm,
            isSearchActive && navigationWithIsSearchActive == 0
        else { return }
        var firebaseAnalyticsParams: [String : Any] = [
            AnalyticsParameterSearchTerm: fetchSearchTerm,
            "name": name,
            "category_id": categoryId
        ]
        if let itemId = itemId {
            firebaseAnalyticsParams["item_id"] = itemId
        }
        
        if let dealId = dealId {
            firebaseAnalyticsParams["deal_id"] = dealId
        }
        container.eventLogger.sendEvent(for: .searchResultSelection, with: .firebaseAnalytics, params: firebaseAnalyticsParams)
    }
    
    func search(text: String) {
        container.services.retailStoreMenuService.globalSearch(searchFetch: loadableSubject(\.searchResult), searchTerm: text, scope: nil, itemsPagination: nil, categoriesPagination: nil)
    }

    func specialOfferPillTapped(offer: RetailStoreMenuItemAvailableDeal, fromItem item: RetailStoreMenuItem, offersRetrieved: (() -> Void)? = nil) {
        sendSearchResultSelectionEvent(
            categoryId: item.mainCategory.id,
            itemId: item.id,
            dealId: offer.id,
            name: offer.name
        )
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
