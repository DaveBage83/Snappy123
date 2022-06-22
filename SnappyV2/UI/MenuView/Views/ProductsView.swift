//
//  ProductsView.swift
//  SnappyV2Study
//
//  Created by Henrik Gustavii on 23/06/2021.
//

import SwiftUI

struct ProductsView: View {
    // MARK: - Environment objects
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
        struct RootGrid {
            static let spacing: CGFloat = 20
        }
        
        struct ItemsGrid {
            static let spacing: CGFloat = 14
            static let padding: CGFloat = 4
        }
        
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
        
        struct Logo {
            static let width: CGFloat = 207.25
            static let largeScreenWidthMultiplier: CGFloat = 1.5
        }
    }

    // MARK: - View model
    @StateObject var viewModel: ProductsViewModel
    
    // MARK: - Properties
    private let resultGridLayout = [GridItem(.adaptive(minimum: 160), spacing: 10, alignment: .top)]
    
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
            VStack {
                if viewModel.viewState == .rootCategories {
                    Image.Branding.Logo.inline
                        .resizable()
                        .scaledToFit()
                        .frame(width: Constants.Logo.width * (sizeClass == .compact ? 1 : Constants.Logo.largeScreenWidthMultiplier))
                        .padding(.top)
                }
                
                ScrollViewReader { proxy in
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 0) {
                            ProductsNavigationAndSearch(
                                productsViewModel: viewModel,
                                text: $viewModel.searchText,
                                isEditing: $viewModel.isEditing)
                            .id(topID)
                            
                            if let itemWithOptions = viewModel.itemOptions {
                                ProductOptionsView(viewModel: .init(container: viewModel.container, item: itemWithOptions))
                            } else {
                                mainProducts()
                                    .onChange(of: viewModel.viewState) { _ in
                                        proxy.scrollTo(topID)
                                    }
                            }
                        }
                        .background(colorPalette.backgroundMain)
                    }
                }
            }
        }
        .onTapGesture {
            hideKeyboard()
        }
        .toast(isPresenting: .constant(viewModel.rootCategoriesIsLoading || viewModel.isSearching)) {
            AlertToast(displayMode: .alert, type: .loading)
        }
    }
    
    // MARK: - Main products view
    private func mainProducts() -> some View {
                productsResultsViews
                    .onAppear {
                        viewModel.getCategories()
                    }
                    .background(colorScheme == .dark ? Color.black : Color.snappyBGMain)
                    .dismissableNavBar(
                        presentation: nil,
                        color: colorPalette.primaryBlue,
                        title: viewModel.currentNavigationTitle,
                        navigationDismissType: .back,
                        backButtonAction: {
                            viewModel.backButtonTapped()
                        })
                    .navigationBarHidden(viewModel.viewState == .rootCategories)
        .bottomSheet(item: $viewModel.productDetail) { product in
            ProductDetailBottomSheetView(viewModel: .init(container: viewModel.container, menuItem: product))
        }
    }
    
    // MARK: - Results view
    @ViewBuilder var productsResultsViews: some View {
        if viewModel.isSearching {
            // When searching, we do not want to show previously found items
            EmptyView()
        } else if viewModel.showEnterMoreCharactersView {
            enterMoreCharacters
        } else if viewModel.isEditing {
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
                specialOfferView()
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
            LazyVStack(spacing: Constants.CategoriesView.vSpacing) {
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
    
    // MARK: - Subcategories
    @ViewBuilder private func subCategoriesView() -> some View {
        if sizeClass == .compact {
            LazyVStack(spacing: Constants.CategoriesView.vSpacing) {
                ForEach(viewModel.subCategories, id: \.id) { details in
                    Button(action: { viewModel.categoryTapped(with: details, fromState: .subCategories) }) {
                        ProductCategoryCardView(container: viewModel.container, categoryDetails: details)
                            .padding(.horizontal)
                    }
                }
            }
            .padding(.vertical)

        } else {
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
        }
    }
    
    // MARK: - Items
    private func itemsView() -> some View {
        VStack(alignment: .leading, spacing: AppConstants.productCardGridSpacing) {
            ForEach(viewModel.splitItems(storeItems: viewModel.items, into: numberOfColumns), id: \.self) { itemCouple in
                HStack(spacing: AppConstants.productCardGridSpacing) {
                    ForEach(itemCouple, id: \.self) { item in
                        ProductCardView(viewModel: .init(container: viewModel.container, menuItem: item))
                            .environmentObject(viewModel)
                    }
                }
            }
            .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.horizontal, AppConstants.productCardGridSpacing)
        .padding(.vertical)
    }
    
    // MARK: - Special offers
    private func specialOfferView() -> some View {
        VStack {
            if let offerText = viewModel.offerText {
                MultiBuyBanner(offerText: offerText)
            }
            if let items = viewModel.specialOfferItems {
                LazyVGrid(columns: resultGridLayout, spacing: Constants.ItemsGrid.spacing) {
                    ForEach(items, id: \.id) { result in
                        ProductCardView(viewModel: .init(container: viewModel.container, menuItem: result))
                            .environmentObject(viewModel)
                    }
                }
                .padding(.horizontal, Constants.ItemsGrid.padding)
            }
        }
        .padding(.vertical)
    }

    // MARK: - Product search
    private func searchView() -> some View {
        LazyVStack(alignment: .leading) {
            // Search result category carousel
            if viewModel.showSearchResultCategories {
                Text(Strings.ProductsView.ProductCard.Search.resultThatIncludesCategories.localizedFormat("\(viewModel.searchResultCategories.count)", "\(viewModel.searchText)"))
                    .font(.Body1.semiBold())
                    .padding(.leading)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(viewModel.searchResultCategories, id: \.self) { category in
                            Button(action: { viewModel.searchCategoryTapped(categoryID: category.id)} ) {
                                GlobalSearchCategoryCard(container: viewModel.container, category: category)
                            }
                        }
                        .padding(.bottom)
                    }
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.leading)
                }
            }
            
            // Search result items card list
            if viewModel.showSearchResultItems {
                Text(Strings.ProductsView.ProductCard.Search.resultThatIncludesItems.localizedFormat("\(viewModel.searchResultItems.count)", "\(viewModel.searchText)"))
                    .font(.Body1.semiBold())
                    .padding(.leading)
                
                ScrollView() {
                    VStack(spacing: AppConstants.productCardGridSpacing) {
                        ForEach(viewModel.splitItems(storeItems: viewModel.searchResultItems, into: numberOfColumns), id: \.self) { itemCouple in
                            HStack(spacing: AppConstants.productCardGridSpacing) {
                                ForEach(itemCouple, id: \.self) { item in
                                    ProductCardView(viewModel: .init(container: viewModel.container, menuItem: item))
                                        .environmentObject(viewModel)
                                }
                            }
                        }
                        .fixedSize(horizontal: false, vertical: true)
                        .frame(maxWidth: .infinity)
                    }
                    .padding(.horizontal, AppConstants.productCardGridSpacing)
                }
                .background(colorPalette.backgroundMain)
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
        RetailStoreMenuItem(id: 123, name: "Some whiskey or other that possibly is not Scottish", eposCode: nil, outOfStock: false, ageRestriction: 18, description: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Curabitur feugiat pharetra aliquam. Sed eget commodo dolor. Quisque purus nisi, commodo sit amet augue at, convallis placerat erat. Donec in euismod turpis, in dictum est. Vestibulum imperdiet interdum tempus. Mauris pellentesque tellus scelerisque, vestibulum lacus volutpat, placerat felis. Morbi placerat, nulla quis euismod eleifend, dui dui laoreet massa, sed suscipit arcu nunc facilisis odio. Morbi tempor libero eget viverra vulputate. Curabitur ante orci, auctor id hendrerit sit amet, tincidunt ut nisi.", quickAdd: true, acceptCustomerInstructions: false, basketQuantityLimit: 500, price: RetailStoreMenuItemPrice(price: 20.90, fromPrice: 19, unitMetric: "", unitsInPack: 0, unitVolume: 0, wasPrice: 24.45), images: nil, menuItemSizes: nil, menuItemOptions: nil, availableDeals: nil, itemCaptions: ["portionSize": "495 Kcal per 100g"], mainCategory: MenuItemCategory(id: 123, name: "Whiskey")),
        RetailStoreMenuItem(id: 234, name: "Another whiskey", eposCode: nil, outOfStock: false, ageRestriction: 18, description: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Curabitur feugiat pharetra aliquam. Sed eget commodo dolor. Quisque purus nisi, commodo sit amet augue at, convallis placerat erat. Donec in euismod turpis, in dictum est. Vestibulum imperdiet interdum tempus. Mauris pellentesque tellus scelerisque, vestibulum lacus volutpat, placerat felis. Morbi placerat, nulla quis euismod eleifend, dui dui laoreet massa, sed suscipit arcu nunc facilisis odio. Morbi tempor libero eget viverra vulputate. Curabitur ante orci, auctor id hendrerit sit amet, tincidunt ut nisi.", quickAdd: true, acceptCustomerInstructions: false, basketQuantityLimit: 500, price: RetailStoreMenuItemPrice(price: 24.95, fromPrice: 0, unitMetric: "", unitsInPack: 0, unitVolume: 0, wasPrice: nil), images: nil, menuItemSizes: nil, menuItemOptions: nil, availableDeals: nil, itemCaptions: ["portionSize": "495 Kcal per 100g"], mainCategory: MenuItemCategory(id: 123, name: "Whiskey")),
        RetailStoreMenuItem(id: 345, name: "Yet another whiskey", eposCode: nil, outOfStock: false, ageRestriction: 18, description: nil, quickAdd: true, acceptCustomerInstructions: false, basketQuantityLimit: 500, price: RetailStoreMenuItemPrice(price: 20.90, fromPrice: 0, unitMetric: "", unitsInPack: 0, unitVolume: 0, wasPrice: 24.45), images: nil, menuItemSizes: nil, menuItemOptions: nil, availableDeals: nil, itemCaptions: ["portionSize": "495 Kcal per 100g"], mainCategory: MenuItemCategory(id: 123, name: "Whiskey")),
        RetailStoreMenuItem(id: 456, name: "Really, another whiskey?", eposCode: nil, outOfStock: false, ageRestriction: 18, description: nil, quickAdd: true, acceptCustomerInstructions: false, basketQuantityLimit: 500, price: RetailStoreMenuItemPrice(price: 34.70, fromPrice: 0, unitMetric: "", unitsInPack: 0, unitVolume: 0, wasPrice: nil), images: nil, menuItemSizes: nil, menuItemOptions: nil, availableDeals: nil, itemCaptions: ["portionSize": "495 Kcal per 100g"], mainCategory: MenuItemCategory(id: 123, name: "Whiskey")),
        RetailStoreMenuItem(id: 567, name: "Some whiskey or other that possibly is not Scottish", eposCode: nil, outOfStock: false, ageRestriction: 18, description: nil, quickAdd: true, acceptCustomerInstructions: false, basketQuantityLimit: 500, price: RetailStoreMenuItemPrice(price: 20.90, fromPrice: 0, unitMetric: "", unitsInPack: 0, unitVolume: 0, wasPrice: 24.45), images: nil, menuItemSizes: nil, menuItemOptions: nil, availableDeals: nil, itemCaptions: ["portionSize": "495 Kcal per 100g"], mainCategory: MenuItemCategory(id: 123, name: "Whiskey")),
        RetailStoreMenuItem(id: 678, name: "Another whiskey", eposCode: nil, outOfStock: false, ageRestriction: 18, description: nil, quickAdd: true, acceptCustomerInstructions: false, basketQuantityLimit: 500, price: RetailStoreMenuItemPrice(price: 20.90, fromPrice: 0, unitMetric: "", unitsInPack: 0, unitVolume: 0, wasPrice: 24.45), images: nil, menuItemSizes: nil, menuItemOptions: nil, availableDeals: nil, itemCaptions: ["portionSize": "495 Kcal per 100g"], mainCategory: MenuItemCategory(id: 123, name: "Whiskey"))]
}

#endif


struct DeviceRotationViewModifier: ViewModifier {
    let action: (UIDeviceOrientation) -> Void

    func body(content: Content) -> some View {
        content
            .onAppear()
            .onReceive(NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)) { _ in
                action(UIDevice.current.orientation)
            }
    }
}

// A View wrapper to make the modifier easier to use
extension View {
    func onRotate(perform action: @escaping (UIDeviceOrientation) -> Void) -> some View {
        self.modifier(DeviceRotationViewModifier(action: action))
    }
}
