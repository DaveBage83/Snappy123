//
//  ProductsView.swift
//  SnappyV2Study
//
//  Created by Henrik Gustavii on 23/06/2021.
//

import SwiftUI

struct ProductsView: View {
    // MARK: - Environment objects
    @Environment(\.tabViewHeight) var tabViewHeight
    @Environment(\.presentationMode) var presentation
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.horizontalSizeClass) var sizeClass
    @Environment(\.mainWindowSize) var mainWindowSize
    @Environment(\.sizeCategory) var sizeCategory: ContentSizeCategory
    @ScaledMetric var scale: CGFloat = 1 // Used to scale icon for accessibility options
    
    // Namespace variable used in ScrollViewReader. We use ScrollViewReader as we are dynamically
    // changing the content within the ScrollView when the viewState changes. This means the scroll
    // is not automatically reset to the top, so we do this manually using ScrollViewReader when the
    // state changes
    @Namespace var topID
    
    // MARK: - Typealias
    typealias AppConstants = AppV2Constants.Business
    
    // MARK: - Constants
    struct Constants {
        static let standardViewPadding: CGFloat = 10
        static let specialItemsTopPadding: CGFloat = 6
        
        struct EnterMoreCharacters {
            static let spacing: CGFloat = 16
            static let imageHeight: CGFloat = 100
            static let topPadding: CGFloat = 56
        }
        
        struct CategoriesView {
            static let vSpacing: CGFloat = 16
        }
        
        struct NoResults {
            static let mainSpacing: CGFloat = 32
            static let imageHeight: CGFloat = 100
            static let textSpacing: CGFloat = 10
            static let topPadding: CGFloat = 56
        }
        
        struct RootCatagoryPills {
            static let hSpacing: CGFloat = 6
            static let vPadding: CGFloat = 4
            static let hPadding: CGFloat = 10
            static let maxWidth: CGFloat = 150
            static let strokeWidth: CGFloat = 1.5
        }
    }
    
    // MARK: - View model
    @StateObject var viewModel: ProductsViewModel
    
    // MARK: - Computed variables
    private var colorPalette: ColorPalette {
        ColorPalette(container: viewModel.container, colorScheme: colorScheme)
    }
    
    var numberOfColumns: Int {
        let spacing = AppConstants.productCardGridSpacing
        
        let finalNumber = Int(mainWindowSize.width / (((AppConstants.productCardWidth * scale) + spacing) + (spacing * 2)))
        
        return finalNumber > 0 ? finalNumber : 1
    }
    
    // MARK: - Main view
    var body: some View {
        NavigationView {
            if #available(iOS 15.0, *) {
                mainContent
                    .onTapGesture {
                        viewModel.clearSearchResults()
                    }
                    .snappyBottomSheet(container: viewModel.container, item: $viewModel.selectedItem, windowSize: mainWindowSize) { item in
                        ToastableViewContainer(content: {
                            bottomSheet(selectedItem: item)
                        }, viewModel: .init(container: viewModel.container, isModal: true))
                    }
            } else {
                mainContent
                    .onTapGesture {
                        viewModel.clearSearchResults()
                    }
                    .sheet(item: $viewModel.selectedItem, onDismiss: nil) { item in
                        ToastableViewContainer(content: {
                            bottomSheet(selectedItem: item)
                        }, viewModel: .init(container: viewModel.container, isModal: true))
                    }
            }
        }
        .onDisappear {
            viewModel.clearAppstateSearchQuery()
        }
        .toolbar(content: {
            ToolbarItem(placement: .navigationBarTrailing) {
                SettingsButton(viewModel: .init(container: viewModel.container))
            }
        })
    }
    
    private func bottomSheet(selectedItem: RetailStoreMenuItem) -> some View {
        ProductDetailBottomSheetView(
            viewModel: .init(container: viewModel.container, menuItem: selectedItem),
            productsViewModel: viewModel,
            dismissViewHandler: {
                viewModel.resetSelectedItem()
            })
    }
    
    @ViewBuilder private var mainContent: some View {
        if viewModel.showStandardView {
            VStack(spacing: 0) {
                Divider()
                
                ScrollViewReader { proxy in
                    ScrollView(showsIndicators: false) {
                            VStack(spacing: 0) {
                                
                                if viewModel.showStandardView {
                                    ProductsNavigationAndSearch(
                                        productsViewModel: viewModel,
                                        text: $viewModel.searchText,
                                        isEditing: $viewModel.isSearchActive)
                                    .padding(.top, Constants.standardViewPadding)
                                    .background(colorPalette.typefaceInvert)
                                    .id(topID)
                                    
                                    Divider()
                                }
                                
                                mainProducts()
                                    .onChange(of: viewModel.viewState) { _ in
                                        // Unfortunately, slight delay needed in order for this to work
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                                            proxy.scrollTo(topID)
                                        }
                                    }
                                
                                if viewModel.showMoreItemsButton {
                                    SnappyButton(
                                        container: viewModel.container,
                                        type: .primary,
                                        size: .large,
                                        title: Strings.Pagination.moreItems.localized,
                                        largeTextTitle: nil,
                                        icon: Image.Icons.Pagination.more,
                                        isLoading: $viewModel.loadingMoreItems,
                                        action: {
                                            Task {
                                              try await viewModel.search(text: viewModel.searchText)
                                            }
                                        })
                                    .padding()
                                }
                            }
                            .padding(.bottom, tabViewHeight)
                            .background(colorPalette.backgroundMain)
                    }
                    .simultaneousGesture(DragGesture().onChanged({ _ in
                        hideKeyboard()
                    }))
                }
                .toolbar(content: {
                    ToolbarItem(placement: .principal) {
                        if viewModel.showSnappyLogo {
                            SnappyLogo()
                        }
                    }
                })
            }
            .withLoadingToast(container: viewModel.container, loading: $viewModel.globalSearching)
            .background(colorPalette.backgroundMain)
            
        } else {
            VStack(spacing: 0) {
                ScrollViewReader { proxy in
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 0) {
                            mainProducts()
                                .onChange(of: viewModel.viewState) { _ in
                                    // Unfortunately, slight delay needed in order for this to work
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                                        proxy.scrollTo(topID)
                                    }
                                }
                        }
                        .padding(.bottom, tabViewHeight)
                        .background(colorPalette.backgroundMain)
                    }
                    .simultaneousGesture(DragGesture().onChanged({ _ in
                        hideKeyboard()
                    }))
                }
            }
            .background(colorPalette.backgroundMain)
        }
    }
    
    // MARK: - Main products view
    @ViewBuilder private func mainProducts() -> some View {
        if viewModel.showStandardView {
            productsResultsViews
                .background(colorPalette.backgroundMain)
                .dismissableNavBar(
                    presentation: nil,
                    color: /*viewModel.hideNavBar ? .clear :*/ colorPalette.primaryBlue,
                    title: viewModel.hideNavBar ? nil : viewModel.currentNavigationTitle,
                    navigationDismissType: viewModel.showBackButton ? .back : .none,
                    backButtonAction: {
                        viewModel.backButtonTapped()
                    })
        } else {
            productsResultsViews
                .background(colorPalette.backgroundMain)
        }
    }
    
    // MARK: - Results view
    @ViewBuilder var productsResultsViews: some View {
        if viewModel.globalSearching {
            // When searching, we do not want to show previously found items
            EmptyView()
        } else if viewModel.showDummyProductCards {
            VStack {
                // We use dummy content here in order to display a redacted view whilst loading
                ForEach(1...20, id: \.self) { _ in
                    ProductCategoryCardView(container: viewModel.container, categoryDetails: viewModel.dummyRootCategory)
                        .padding(.horizontal)
                        .redacted(reason: viewModel.rootCategoriesIsLoading ? .placeholder: [])
                }
            }
            .padding(.vertical)
        } else if viewModel.showEnterMoreCharactersView {
            enterMoreCharacters
        } else if viewModel.showSearchView {
            searchView()
        } else {
            switch viewModel.viewState {
            case .subCategories:
                subCategoriesView()
                    .redacted(reason: viewModel.categoryLoading ? .placeholder : [])
            case .items:
                itemsView()
                    .redacted(reason: viewModel.categoryLoading ? .placeholder : [])
                
            case .offers:
                missedOffersView()
                    .redacted(reason: viewModel.categoryLoading ? .placeholder : [])
                
            default:
                rootCategoriesView()
                    .redacted(reason: viewModel.categoryLoading ? .placeholder : [])
            }
        }
    }
    
    // MARK: - Enter more characters view
    private var enterMoreCharacters: some View {
        VStack(spacing: Constants.EnterMoreCharacters.spacing) {
            Image.Search.enterMoreCharacters
                .resizable()
                .scaledToFit()
                .frame(height: Constants.EnterMoreCharacters.imageHeight)
            Text(Strings.ProductsView.ProductCard.SearchStandard.enterMoreCharacters.localized)
                .font(.heading4())
                .multilineTextAlignment(.center)
        }
        .padding(.top, Constants.EnterMoreCharacters.topPadding)
    }
    
    // MARK: - Root categories
    @ViewBuilder private func rootCategoriesView() -> some View {
        if sizeClass == .compact {
            VStack(spacing: Constants.CategoriesView.vSpacing) {
                ForEach(viewModel.rootCategories, id: \.id) { details in
                    Button(action: { viewModel.categoryTapped(with: details, fromState: .rootCategories) }) {
                        ProductCategoryCardView(container: viewModel.container, categoryDetails: details)
                            .padding(.horizontal)
                    }
                }
            }
            .padding(.vertical)
        } else {
            VStack(alignment: .leading, spacing: AppConstants.productCardGridSpacing) {
                ForEach(viewModel.splitRootCategories, id: \.self) { categoryCouple in
                    HStack {
                        ForEach(categoryCouple, id: \.id) { category in
                            Button(action: { viewModel.categoryTapped(with: category, fromState: .rootCategories) }) {
                                ProductCategoryCardView(container: viewModel.container, categoryDetails: category)
                                    .padding(.horizontal)
                            }
                            .frame(maxWidth: (mainWindowSize.width / 2) - (AppConstants.productCardGridSpacing / 2)) // Modifier required for last item in stack to avoid taking full width on ipad
                        }
                    }
                }
                .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.vertical)
        }
    }
    
    @ViewBuilder func rootCategoriesCarousel() -> some View {
        if viewModel.showRootCategoriesCarousel {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: Constants.RootCatagoryPills.hSpacing) {
                    ForEach(viewModel.rootCategories) { details in
                        Button(action: { viewModel.carouselCategoryTapped(with: details)}) {
                            Text(details.name)
                                .font(.Body1.semiBold())
                                .foregroundColor(colorPalette.typefacePrimary)
                                .padding(.vertical, Constants.RootCatagoryPills.vPadding)
                                .padding(.horizontal, Constants.RootCatagoryPills.hPadding)
                        }
                        .frame(maxWidth: Constants.RootCatagoryPills.maxWidth)
                        .background(Capsule().strokeBorder(colorPalette.typefacePrimary, lineWidth: Constants.RootCatagoryPills.strokeWidth))
                        .accentColor(colorPalette.typefaceInvert)
                    }
                }
                .padding(.top)
                .padding(.leading)
            }
        }
    }
    
    @ViewBuilder func toolbarCategoryMenu() -> some View {
        if viewModel.showToolbarCategoryMenu {
            Menu {
                ForEach(viewModel.rootCategories) { details in
                    Button(action: { viewModel.carouselCategoryTapped(with: details) }) {
                        Text(details.name)
                    }
                }
            } label: {
                Image.Icons.CategoryMenu.standard
                    .accentColor(colorPalette.typefacePrimary)
            }
        }
    }
    
    // MARK: - Subcategories
    @ViewBuilder private func subCategoriesView() -> some View {
        if sizeClass == .compact {
            
            rootCategoriesCarousel()
            
            VStack(spacing: Constants.CategoriesView.vSpacing) {
                ForEach(viewModel.lastSubCategories, id: \.id) { details in
                    Button(action: { viewModel.categoryTapped(with: details, fromState: .subCategories) }) {
                        ProductCategoryCardView(container: viewModel.container, categoryDetails: details)
                            .padding(.horizontal)
                    }
                }
            }
            .padding(.vertical)
            .toolbar(content: {
                ToolbarItem(placement: .navigationBarTrailing) {
                    toolbarCategoryMenu()
                }
            })

        } else {
            
            rootCategoriesCarousel()
            
            VStack(alignment: .leading, spacing: AppConstants.productCardGridSpacing) {
                ForEach(viewModel.splitSubCategories, id: \.self) { categoryCouple in
                    HStack {
                        ForEach(categoryCouple, id: \.id) { category in
                            Button(action: { viewModel.categoryTapped(with: category, fromState: .subCategories) }) {
                                ProductCategoryCardView(container: viewModel.container, categoryDetails: category)
                                    .padding(.horizontal)
                            }
                            .frame(maxWidth: (mainWindowSize.width / 2) - (AppConstants.productCardGridSpacing / 2)) // Modifier required for last item in stack to avoid taking full width on ipad
                        }
                    }
                }
                .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.vertical)
            .toolbar(content: {
                ToolbarItem(placement: .navigationBarTrailing) {
                    toolbarCategoryMenu()
                }
            })
        }
    }
    
    // MARK: - Items
    @ViewBuilder private func itemsView() -> some View {
        
        rootCategoriesCarousel()
        
        if viewModel.showHorizontalItemCards {
            VStack(alignment: .leading, spacing: AppConstants.productCardGridSpacing) {
                ForEach(viewModel.splitItems(storeItems: viewModel.items, into: numberOfColumns), id: \.self) { itemCouple in
                    ForEach(itemCouple, id: \.self) { item in
                        ProductCardView(
                            viewModel: .init(
                                container: viewModel.container,
                                menuItem: item,
                                associatedSearchTerm: viewModel.associatedSearchTerm,
                                productSelected: { product in
                                    viewModel.selectItem(product)
                                    Task {
                                        await viewModel.storeSearchQuery(viewModel.searchText)
                                    }
                                }
                            ),
                            productsViewModel: viewModel
                        )
                    }
                }
                .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.horizontal, AppConstants.productCardGridSpacing)
            .padding(.vertical)
            .toolbar(content: {
                ToolbarItem(placement: .navigationBarTrailing) {
                    toolbarCategoryMenu()
                }
            })
            
        } else {
            VStack(alignment: .leading, spacing: AppConstants.productCardGridSpacing) {
                ForEach(viewModel.splitItems(storeItems: viewModel.items, into: numberOfColumns), id: \.self) { itemCouple in
                    HStack(spacing: AppConstants.productCardGridSpacing) {
                        ForEach(itemCouple, id: \.self) { item in
                            ProductCardView(
                                viewModel: .init(
                                    container: viewModel.container,
                                    menuItem: item,
                                    associatedSearchTerm: viewModel.associatedSearchTerm,
                                    productSelected: { product in
                                        viewModel.selectItem(product)
                                    }
                                ),
                                productsViewModel: viewModel
                            )
                        }
                    }
                }
                .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.horizontal, AppConstants.productCardGridSpacing)
            .padding(.vertical)
            .toolbar(content: {
                ToolbarItem(placement: .navigationBarTrailing) {
                    toolbarCategoryMenu()
                }
            })
        }
        
    }
    
    @ViewBuilder func missedOffersView() -> some View {
        if viewModel.showSpecialOfferItems {
            ForEach(viewModel.specialOfferItems) { item in
                ProductCardView(
                    viewModel: .init(
                        container: viewModel.container,
                        menuItem: item,
                        isOffer: true,
                        productSelected: { product in
                            viewModel.selectItem(product)
                        }
                    ),
                    productsViewModel: viewModel
                )
                .padding([.top, .horizontal])
            }
        } else {
            if let discountText = viewModel.missedOfferMenu?.discountText {
                ExpandableText(viewModel: .init(container: viewModel.container, title: "Description", shortTitle: nil, text: discountText, shortText: nil, isComplexItem: true, showExpandableText: true))
                    .padding(.top, Constants.specialItemsTopPadding)
            }
            
            if let missedOfferSections = viewModel.missedOfferMenu?.missedOfferSections {
                ForEach(missedOfferSections) { section in
                    ExpandableContentView(viewModel: .init(container: viewModel.container, title: section.name, shortTitle: nil, showExpandableContent: true)) {
                        ForEach(section.items) { item in
                            ProductCardView(
                                viewModel: .init(
                                    container: viewModel.container,
                                    menuItem: item,
                                    isOffer: true,
                                    associatedSearchTerm: viewModel.associatedSearchTerm,
                                    productSelected: { product in
                                        viewModel.selectItem(product)
                                    }
                                ),
                                productsViewModel: viewModel
                            )
                        }
                    }
                    .padding(.top)
                }
            }
        }
    }

    // MARK: - Product search
    private func searchView() -> some View {
        VStack(alignment: .leading) {
            // Search result category carousel
            if viewModel.showSearchResultCategories {
                Text(Strings.ProductsView.ProductCard.Search.resultThatIncludesCategories.localizedFormat("\(viewModel.searchResultCategories.count)", "\(viewModel.searchText)"))
                    .font(.Body1.semiBold())
                    .padding(.leading)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(viewModel.searchResultCategories, id: \.self) { category in
                            Button(action: { viewModel.searchCategoryTapped(category: category)} ) {
                                GlobalSearchCategoryCard(container: viewModel.container, category: category)
                            }
                        }
                        .padding(.bottom)
                    }
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.leading)
                }
                .redacted(reason: viewModel.subCategoriesOrItemsIsLoading ? .placeholder: [])
                .simultaneousGesture(DragGesture().onChanged({ _ in
                    hideKeyboard()
                }))
            }
            
            // Search result items card list
            Text(Strings.ProductsView.ProductCard.Search.resultThatIncludesItems.localizedFormat("\(viewModel.searchResultItems.count)", viewModel.totalItems, "\(viewModel.searchText)"))
                .font(.Body1.semiBold())
                .padding(.leading)
            if viewModel.showSearchResultItems {
                if viewModel.container.appState.value.storeMenu.showHorizontalItemCards {
                    VStack(alignment: .leading, spacing: AppConstants.productCardGridSpacing) {
                        ForEach(viewModel.splitItems(storeItems: viewModel.searchResultItems, into: numberOfColumns), id: \.self) { itemCouple in
                            ForEach(itemCouple, id: \.self) { item in
                                ProductCardView(
                                    viewModel: .init(
                                        container: viewModel.container,
                                        menuItem: item,
                                        associatedSearchTerm: viewModel.associatedSearchTerm,
                                        productSelected: { product in
                                            viewModel.selectItem(product)
                                        }
                                    ),
                                    productsViewModel: viewModel
                                )
                            }
                        }
                        .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding(.horizontal, AppConstants.productCardGridSpacing)
                    .padding(.vertical)
                    .redacted(reason: viewModel.subCategoriesOrItemsIsLoading ? .placeholder: [])
                    .simultaneousGesture(DragGesture().onChanged({ _ in
                        hideKeyboard()
                    }))
                } else {
                    VStack(alignment: .leading, spacing: AppConstants.productCardGridSpacing) {
                        ForEach(viewModel.splitItems(storeItems: viewModel.searchResultItems, into: numberOfColumns), id: \.self) { itemCouple in
                            HStack(spacing: AppConstants.productCardGridSpacing) {
                                ForEach(itemCouple, id: \.self) { item in
                                    ProductCardView(
                                        viewModel: .init(
                                            container: viewModel.container,
                                            menuItem: item,
                                            associatedSearchTerm: viewModel.associatedSearchTerm,
                                            productSelected: { product in
                                                viewModel.selectItem(product)
                                            }
                                        ),
                                        productsViewModel: viewModel
                                    )
                                }
                            }
                        }
                        .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding(.horizontal, AppConstants.productCardGridSpacing)
                    .padding(.vertical)
                    .redacted(reason: viewModel.subCategoriesOrItemsIsLoading ? .placeholder: [])
                    .simultaneousGesture(DragGesture().onChanged({ _ in
                        hideKeyboard()
                    }))
                }
            }
            
            // No search result
            if viewModel.noSearchResult {
                VStack(alignment: .center, spacing: Constants.NoResults.mainSpacing) {
                    Image.Search.noResults
                        .resizable()
                        .scaledToFit()
                        .frame(height: Constants.NoResults.imageHeight)
                    
                    VStack(spacing: Constants.NoResults.textSpacing) {
                        Text(Strings.ProductsView.ProductCard.Search.noResults.localizedFormat("\(viewModel.searchText)"))
                            .font(.heading4())
                        
                        Text(Strings.ProductsView.ProductCard.SearchStandard.tryAgain.localized)
                            .font(.heading4())
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.top, Constants.NoResults.topPadding)
            }
        }
        .padding(.vertical)
        .background(colorPalette.backgroundMain)
    }
}

#if DEBUG
struct ProductCategoryView_Previews: PreviewProvider {
    static var previews: some View {
        ProductsView(viewModel: .init(container: .preview))
            .previewCases()
    }
}
#endif

#if DEBUG
extension MockData {
    static let resultsData = [
        RetailStoreMenuItem(id: 123, name: "Some whiskey or other that possibly is not Scottish", eposCode: nil, outOfStock: false, ageRestriction: 18, description: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Curabitur feugiat pharetra aliquam. Sed eget commodo dolor. Quisque purus nisi, commodo sit amet augue at, convallis placerat erat. Donec in euismod turpis, in dictum est. Vestibulum imperdiet interdum tempus. Mauris pellentesque tellus scelerisque, vestibulum lacus volutpat, placerat felis. Morbi placerat, nulla quis euismod eleifend, dui dui laoreet massa, sed suscipit arcu nunc facilisis odio. Morbi tempor libero eget viverra vulputate. Curabitur ante orci, auctor id hendrerit sit amet, tincidunt ut nisi.", quickAdd: true, acceptCustomerInstructions: false, basketQuantityLimit: 500, price: RetailStoreMenuItemPrice(price: 20.90, fromPrice: 19, unitMetric: "", unitsInPack: 0, unitVolume: 0, wasPrice: 24.45), images: nil, menuItemSizes: nil, menuItemOptions: nil, availableDeals: nil, itemCaptions: ItemCaptions(portionSize: "495 Kcal per 100g"), mainCategory: MenuItemCategory(id: 123, name: "Whiskey"), itemDetails: nil, deal: nil),
        RetailStoreMenuItem(id: 234, name: "Another whiskey", eposCode: nil, outOfStock: false, ageRestriction: 18, description: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Curabitur feugiat pharetra aliquam. Sed eget commodo dolor. Quisque purus nisi, commodo sit amet augue at, convallis placerat erat. Donec in euismod turpis, in dictum est. Vestibulum imperdiet interdum tempus. Mauris pellentesque tellus scelerisque, vestibulum lacus volutpat, placerat felis. Morbi placerat, nulla quis euismod eleifend, dui dui laoreet massa, sed suscipit arcu nunc facilisis odio. Morbi tempor libero eget viverra vulputate. Curabitur ante orci, auctor id hendrerit sit amet, tincidunt ut nisi.", quickAdd: true, acceptCustomerInstructions: false, basketQuantityLimit: 500, price: RetailStoreMenuItemPrice(price: 24.95, fromPrice: 0, unitMetric: "", unitsInPack: 0, unitVolume: 0, wasPrice: nil), images: nil, menuItemSizes: nil, menuItemOptions: nil, availableDeals: nil, itemCaptions: ItemCaptions(portionSize: "495 Kcal per 100g"), mainCategory: MenuItemCategory(id: 123, name: "Whiskey"), itemDetails: nil, deal: nil),
        RetailStoreMenuItem(id: 345, name: "Yet another whiskey", eposCode: nil, outOfStock: false, ageRestriction: 18, description: nil, quickAdd: true, acceptCustomerInstructions: false, basketQuantityLimit: 500, price: RetailStoreMenuItemPrice(price: 20.90, fromPrice: 0, unitMetric: "", unitsInPack: 0, unitVolume: 0, wasPrice: 24.45), images: nil, menuItemSizes: nil, menuItemOptions: nil, availableDeals: nil, itemCaptions: ItemCaptions(portionSize: "495 Kcal per 100g"), mainCategory: MenuItemCategory(id: 123, name: "Whiskey"), itemDetails: nil, deal: nil),
        RetailStoreMenuItem(id: 456, name: "Really, another whiskey?", eposCode: nil, outOfStock: false, ageRestriction: 18, description: nil, quickAdd: true, acceptCustomerInstructions: false, basketQuantityLimit: 500, price: RetailStoreMenuItemPrice(price: 34.70, fromPrice: 0, unitMetric: "", unitsInPack: 0, unitVolume: 0, wasPrice: nil), images: nil, menuItemSizes: nil, menuItemOptions: nil, availableDeals: nil, itemCaptions: ItemCaptions(portionSize: "495 Kcal per 100g"), mainCategory: MenuItemCategory(id: 123, name: "Whiskey"), itemDetails: nil, deal: nil),
        RetailStoreMenuItem(id: 567, name: "Some whiskey or other that possibly is not Scottish", eposCode: nil, outOfStock: false, ageRestriction: 18, description: nil, quickAdd: true, acceptCustomerInstructions: false, basketQuantityLimit: 500, price: RetailStoreMenuItemPrice(price: 20.90, fromPrice: 0, unitMetric: "", unitsInPack: 0, unitVolume: 0, wasPrice: 24.45), images: nil, menuItemSizes: nil, menuItemOptions: nil, availableDeals: nil, itemCaptions: ItemCaptions(portionSize: "495 Kcal per 100g"), mainCategory: MenuItemCategory(id: 123, name: "Whiskey"), itemDetails: nil, deal: nil),
        RetailStoreMenuItem(id: 678, name: "Another whiskey", eposCode: nil, outOfStock: false, ageRestriction: 18, description: nil, quickAdd: true, acceptCustomerInstructions: false, basketQuantityLimit: 500, price: RetailStoreMenuItemPrice(price: 20.90, fromPrice: 0, unitMetric: "", unitsInPack: 0, unitVolume: 0, wasPrice: 24.45), images: nil, menuItemSizes: nil, menuItemOptions: nil, availableDeals: nil, itemCaptions: ItemCaptions(portionSize: "495 Kcal per 100g"), mainCategory: MenuItemCategory(id: 123, name: "Whiskey"), itemDetails: nil, deal: nil)]
}

#endif
