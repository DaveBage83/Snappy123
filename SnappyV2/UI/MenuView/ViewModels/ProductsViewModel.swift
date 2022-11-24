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
    private var fetchingGlobalSearchResultRecord: GlobalSearchResultRecord?
    
    // MARK: - Computed variables
    var splitRootCategories: [[RetailStoreMenuCategory]] {
        rootCategories.chunked(into: 2)
    }
    
    var showFilterButton: Bool {
        viewState == .items
    }
    
    var showToolbarCategoryMenu: Bool {
        container.appState.value.storeMenu.showDropdownCategoryMenu && showSearchView == false
    }
    
    var showRootCategoriesCarousel: Bool {
        container.appState.value.storeMenu.showDropdownCategoryMenu == false
    }
    
    var items: [RetailStoreMenuItem] {
        guard sortedItems.isEmpty else {
            return sortedItems
        }
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
        if viewState == .rootCategories && showSearchView == false {
            return false
        }
        return true
    }
    
    var hideNavBar: Bool {
        viewState == .rootCategories
    }
    
    var showHorizontalItemCards: Bool { container.appState.value.storeMenu.showHorizontalItemCards }
    
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
    
    // used by this view model and injected into ProductCardViewModel
    var associatedSearchTerm: String? {
        // only record the event if the activity is from the first step of the fetched
        // search results
        guard
            let searchResult = searchResult.value,
            let fetchSearchTerm = searchResult.fetchSearchTerm,
            isSearchActive && navigationWithIsSearchActive == 0
        else { return nil }
        return fetchSearchTerm
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
    
    // We use this only to display a redacted view for when the root categories are loading
    var dummyRootCategory: RetailStoreMenuCategory {
        RetailStoreMenuCategory(id: 1, parentId: 1, name: "Dummy Category", image: nil, description: "Dummy Category Desctiption", action: nil)
    }
    
    var showCaloriesSort: Bool {
        unsortedItems.contains(where: { $0.itemCaptions?.portionSize != nil })
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
        setupBindingsToStoreDisplayedStates(with: appState)
        
        if let missedOffer = missedOffer {
            getMissedPromotion(offer: missedOffer)
        } else {
            if viewState == .rootCategories {
                getCategories()
            }
        }
    }
    
    func setupBindingsToStoreDisplayedStates(with appState: Store<AppState>) {
        
        // Whenever a local display state is modified copy it to its AppState
        // storeMenu equivalent. Only the $searchText does not have a binding
        // here because this is handled in its own binding with a debounce to
        // trigger API search request and set other view states.
        
        $rootCategories
            .receive(on: RunLoop.main)
            .sink { appState.value.storeMenu.rootCategories = $0 }
            .store(in: &cancellables)
        
        $subCategories
            .receive(on: RunLoop.main)
            .sink { appState.value.storeMenu.subCategories = $0 }
            .store(in: &cancellables)
        
        $unsortedItems
            .receive(on: RunLoop.main)
            .sink { appState.value.storeMenu.unsortedItems = $0 }
            .store(in: &cancellables)
        
        $specialOfferItems
            .receive(on: RunLoop.main)
            .sink { appState.value.storeMenu.specialOfferItems = $0 }
            .store(in: &cancellables)
        
        $searchResultCategories
            .receive(on: RunLoop.main)
            .sink { appState.value.storeMenu.searchResultCategories = $0 }
            .store(in: &cancellables)
        
        $searchResultItems
            .receive(on: RunLoop.main)
            .sink { appState.value.storeMenu.searchResultItems = $0 }
            .store(in: &cancellables)
        
        $navigationWithIsSearchActive
            .receive(on: RunLoop.main)
            .sink { appState.value.storeMenu.navigationWithIsSearchActive = $0 }
            .store(in: &cancellables)
        
        $subCategoryNavigationTitle
            .receive(on: RunLoop.main)
            .sink { appState.value.storeMenu.subCategoryNavigationTitle = $0 }
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
            unsortedItems = []
            sortedItems = []
            subcategoriesOrItemsMenuFetch = .notRequested
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
            subcategoriesOrItemsMenuFetch = .notRequested
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
            .filter { $0 != .notRequested }
            .removeDuplicates()
            .receive(on: RunLoop.main)
            .sink { [weak self] menu in
                guard let self = self else { return }
                
                guard let value = menu.value else {
                    if let error = menu.error {
                        self.container.appState.value.errors.append(error)
                    }
                    return
                }
                
                if
                    let fetchCategoryId = value.fetchCategoryId,
                    let searchCategoryId = self.fetchingGlobalSearchResultRecord?.id,
                    fetchCategoryId == searchCategoryId && (value.menuItems?.isEmpty == false || value.categories?.isEmpty == false)
                {
                    // the search category has been confirmed so set the neccessary states
                    self.subCategories = []
                    self.subCategoryNavigationTitle = []
                    self.unsortedItems = []
                    self.sortedItems = []
                    self.itemNavigationTitle = self.fetchingGlobalSearchResultRecord?.name
                    self.navigationWithIsSearchActive = 0
                    self.fetchingGlobalSearchResultRecord = nil
                }

                if let menuItems = value.menuItems {
                    self.unsortedItems = menuItems
                    if self.isSearchActive {
                        self.navigationWithIsSearchActive += 1
                    }
                } else if let subCategories = value.categories {
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
                    self.container.appState.value.errors.append(Errors.categoryEmpty)
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
                
                self.container.appState.value.storeMenu.searchText = searchText
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
        specialOffersMenuFetch = .notRequested
        sortedItems = []
        unsortedItems = []
        subCategories = []
        specialOfferItems = []
        selectedOffer = nil
        offerText = nil
        navigationWithIsSearchActive = 0
        searchText = ""
    }
    
    private func getCategories() {
        container.services.retailStoreMenuService.getRootCategories(menuFetch: loadableSubject(\.rootCategoriesMenuFetch))
    }
    
    func carouselCategoryTapped(with category: RetailStoreMenuCategory) {
        clearState()
        categoryTapped(with: category, fromState: .rootCategories)
    }

    func categoryTapped(with category: RetailStoreMenuCategory, fromState: ProductViewState? = nil) {
        switch fromState {
        case .rootCategories, .subCategories:
            self.subCategoryNavigationTitle.append(category.name)
            self.itemNavigationTitle = category.name
        default:
            break
        }
        fetchingGlobalSearchResultRecord = nil
        if let action = category.action, let discountId = action.params?.discountId {
            container.services.retailStoreMenuService.getItems(menuFetch: loadableSubject(\.specialOffersMenuFetch), menuItemIds: nil, discountId: discountId, discountSectionId: nil)
        } else {
            container.services.retailStoreMenuService.getChildCategoriesAndItems(menuFetch: loadableSubject(\.subcategoriesOrItemsMenuFetch), categoryId: category.id)
        }
    }

    func searchCategoryTapped(category: GlobalSearchResultRecord) {
        sendSearchResultSelectionEvent(categoryId: category.id, name: category.name)
        fetchingGlobalSearchResultRecord = category
        container.services.retailStoreMenuService.getChildCategoriesAndItems(menuFetch: loadableSubject(\.subcategoriesOrItemsMenuFetch), categoryId: category.id)
    }
    
    func logItemIteraction(with item: RetailStoreMenuItem) {
        sendSearchResultSelectionEvent(categoryId: item.mainCategory.id, itemId: item.id, name: item.name)
    }
    
    private func sendSearchResultSelectionEvent(categoryId: Int, itemId: Int? = nil, dealId: Int? = nil, name: String) {
        guard let associatedSearchTerm = associatedSearchTerm else { return }
        var firebaseAnalyticsParams: [String : Any] = [
            AnalyticsParameterSearchTerm: associatedSearchTerm,
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
        // Setting max 10 categories and 100 items to be shown
        container.services.retailStoreMenuService.globalSearch(searchFetch: loadableSubject(\.searchResult), searchTerm: text, scope: nil, itemsPagination: (100, 0), categoriesPagination: (10, 0))
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
            sortedItems = sortedByCaloriesAndAtoZ()
        }
    }
    
    private func sortedByCaloriesAndAtoZ() -> [RetailStoreMenuItem] {
        let alphabeticallySorted = unsortedItems.sorted(by: \.name)
        return alphabeticallySorted.sorted(by: \.calories)
    }
    
    func resetSelectedItem() {
        selectedItem = nil
    }
    
    func selectItem(_ item: RetailStoreMenuItem, logSearchEvent: Bool = false) {
        selectedItem = item
        if logSearchEvent {
            logItemIteraction(with: item)
        }
    }
}
