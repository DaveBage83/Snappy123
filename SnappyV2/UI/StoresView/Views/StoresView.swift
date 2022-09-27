//
//  StoresView.swift
//  SnappyV2Study
//
//  Created by Henrik Gustavii on 14/06/2021.
//

import SwiftUI

struct StoresView: View {
    // MARK: - Environment objects
    @ScaledMetric var scale: CGFloat = 1 // Used to scale icon for accessibility options
    @Environment(\.sizeCategory) var sizeCategory: ContentSizeCategory
    @Environment(\.horizontalSizeClass) var sizeClass
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.tabViewHeight) var tabViewHeight
    
    // MARK: - Typealiases
    typealias StoreTypesStrings = Strings.StoresView.StoreTypes
    typealias StoreStatusStrings = Strings.StoresView.StoreStatus
    typealias FailedSearchStrings = Strings.StoresView.FailedSearch
    
    // MARK: - Store status enum
    enum StoreStatus {
        case open
        case closed
        case preOrder
        
        var title: String {
            switch self {
            case .open:
                return Strings.StoresView.StoreStatus.openStores.localized
            case .closed:
                return Strings.StoresView.StoreStatus.closedStores.localized
            case .preOrder:
                return Strings.StoresView.StoreStatus.preorderstores.localized
            }
        }
        
        var icon: Image {
            switch self {
            case .open:
                return Image.Icons.Store.standard
            case .closed:
                return Image.Icons.Clock.standard
            case .preOrder:
                return Image.Icons.Door.standard
            }
        }
    }
    
    // MARK: - Constants
    private struct Constants {
        struct LogoAndSearch {
            struct Logo {
                static let width: CGFloat = 207.25
                static let largeScreenWidthMultiplier: CGFloat = 1.5
            }
            
            struct Stack {
                static let spacing: CGFloat = 16
            }
        }
        
        struct HorizontalStoreTypeScroll {
            static let topPadding: CGFloat = 23
        }
        
        struct General {
            static let minimalViewLayoutThreshold: Int = 7
        }
        
        struct StoreCardList {
            static let spacing: CGFloat = 16
        }
        
        struct StoreStatus {
            static let iconSize: CGFloat = 24
        }
        
        struct FulfilmentSelectionToggle {
            static let largeScreenWidth: CGFloat = UIScreen.screenWidth * 0.3
            static let subtitlePadding: CGFloat = 26
        }
        
        struct UnsuccessfulSearch {
            struct Title {
                static let padding: CGFloat = 11
            }
            
            struct RegisterInterestSteps {
                static let bottomPadding: CGFloat = 50
                static let height: CGFloat = 23
                static let iconLargeScreenMultiplier: CGFloat = 2
            }
            
            struct NotifyEmailField {
                static let bottomPadding: CGFloat = 14
                static let largeScreenWidthMultiplier: CGFloat = 0.5
            }
            
            struct NotifyEmailButton {
                static let largeScreenWidthMultiplier: CGFloat = 0.5
            }
        }
    }
    
    // MARK: - View Model
    @StateObject var viewModel: StoresViewModel
    
    // MARK: - Computed variables
    private var colorPalette: ColorPalette {
        ColorPalette(container: viewModel.container, colorScheme: colorScheme)
    }
    
    private var minimalViewLayout: Bool {
        sizeCategory.size > Constants.General.minimalViewLayoutThreshold && sizeClass == .compact
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                Divider()
                
                ScrollView(.vertical, showsIndicators: false) {
                    HStack {
                        postcodeSearch
                        if sizeClass != .compact {
                            FulfilmentTypeSelectionToggle(viewModel: .init(container: viewModel.container))
                                .frame(maxWidth: Constants.FulfilmentSelectionToggle.largeScreenWidth, maxHeight: .infinity)
                        }
                    }
                    .padding()
                    VStack(alignment: .leading) {
                        if sizeClass == .compact {
                            FulfilmentTypeSelectionToggle(viewModel: .init(container: viewModel.container))
                                .padding(.horizontal)
                        }
                        
                        browseStores
                        
                        navigationLinks
                    }
                    .padding(.bottom, tabViewHeight)
                }
                .toolbar(content: {
                    ToolbarItem(placement: .principal) {
                        SnappyLogo()
                    }
                })
                .navigationBarTitleDisplayMode(.inline)
                .frame(maxHeight: .infinity)
                .background(colorPalette.backgroundMain)
            }
            .frame(maxHeight: .infinity)
        }
        .onAppear {
            viewModel.onAppearSendEvent()
        }
        .onTapGesture {
            hideKeyboard()
        }
        .toast(isPresenting: .constant(viewModel.locationIsLoading), alert: {
            AlertToast(displayMode: .alert, type: .loading)
        })
        .withStandardAlert(
            container: viewModel.container,
            isPresenting: $viewModel.invalidPostcodeError,
            type: .error,
            title: FailedSearchStrings.invalidPostcodeTitle.localized,
            subtitle: FailedSearchStrings.invalidPostcodeSubtitle.localized)
        .withStandardAlert(
            container: viewModel.container,
            isPresenting: $viewModel.successfullyRegisteredForNotifications,
            type: .success,
            title: Strings.ToastNotifications.StoreSearch.title.localized,
            subtitle: Strings.ToastNotifications.StoreSearch.subtitle.localized)
        .displayError(viewModel.error)
    }
    
    // MARK: - Postcode search bar and button
    private var postcodeSearch: some View {
        SnappyTextFieldWithButton(
            container: viewModel.container,
            text: $viewModel.postcodeSearchString,
            hasError: .constant(viewModel.invalidPostcodeError),
            isLoading: .constant(viewModel.storesSearchIsLoading),
            showInvalidFieldWarning: .constant(false),
            autoCaps: .allCharacters,
            labelText: GeneralStrings.Search.searchPostcode.localized,
            largeLabelText: GeneralStrings.Search.search.localized,
            warningText: nil,
            keyboardType: nil,
            mainButton: (GeneralStrings.Search.search.localized, {
                Task {
                    try await viewModel.postcodeSearchTapped()
                }
            }),
            mainButtonLargeTextLogo: Image.Icons.MagnifyingGlass.standard,
            internalButton: (Image.Icons.LocationCrosshairs.standard, {
                Task {
                    await viewModel.searchViaLocationTapped()
                }
            }))
    }
    
    // MARK: - Horizontal store type scroll view
    private func storesTypesAvailableHorisontalScrollView() -> some View {
        VStack(alignment: .leading) {
            AdaptableText(
                text: StoreTypesStrings.browse.localized,
                altText: StoreTypesStrings.browseShort.localized,
                threshold: Constants.General.minimalViewLayoutThreshold)
            .font(.heading4())
            .foregroundColor(colorPalette.primaryBlue)
            .padding(.horizontal)
            .padding(.top, Constants.HorizontalStoreTypeScroll.topPadding)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    if let storeTypes = viewModel.retailStoreTypes {
                        ForEach(storeTypes, id: \.self) { storeType in
                            Button(action: { viewModel.selectFilteredRetailStoreType(id: storeType.id) }) {
                                StoreTypeCard(container: viewModel.container, storeType: storeType, selected: .constant(viewModel.filteredRetailStoreType == storeType.id), viewModel: viewModel)
                            }
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
    }
    
    private var unsuccessfulStoreSearch: some View {
        VStack {
            Text(FailedSearchStrings.notInArea.localized)
                .font(.heading3())
                .foregroundColor(colorPalette.primaryBlue)
                .padding(.bottom, Constants.UnsuccessfulSearch.Title.padding)
                .fixedSize(horizontal: false, vertical: true)
            
            Text(FailedSearchStrings.showInterest.localized)
                .font(.Body2.regular())
                .foregroundColor(colorPalette.typefacePrimary)
                .padding(.bottom, Constants.FulfilmentSelectionToggle.subtitlePadding)
                .fixedSize(horizontal: false, vertical: true)
            
            if minimalViewLayout == false {
                HStack(alignment: .top) {
                    registerInterestStep(
                        icon: Image.Icons.ThumbsUp.standard,
                        text: FailedSearchStrings.showInterestPrompt.localized)
                    Spacer()
                    registerInterestStep(
                        icon: Image.Icons.Pen.standard,
                        text: FailedSearchStrings.snappyWillLog.localized)
                    Spacer()
                    registerInterestStep(
                        icon: Image.Icons.Comment.standard,
                        text: FailedSearchStrings.snappyWillNotify.localized)
                }
                .padding(.bottom, Constants.UnsuccessfulSearch.RegisterInterestSteps.bottomPadding)
            }
            
            SnappyTextfield(
                container: viewModel.container,
                text: $viewModel.emailToNotify,
                hasError: $viewModel.emailToNotifyHasError,
                labelText: GeneralStrings.Login.email.localized.capitalized,
                largeTextLabelText: nil)
            .padding(.bottom, Constants.UnsuccessfulSearch.NotifyEmailField.bottomPadding)
            .frame(maxWidth: UIScreen.screenWidth * (sizeClass == .compact ? 1 : Constants.UnsuccessfulSearch.NotifyEmailField.largeScreenWidthMultiplier))
            
            SnappyButton(
                container: viewModel.container,
                type: .primary,
                size: .large,
                title: FailedSearchStrings.getNotifications.localized,
                largeTextTitle: FailedSearchStrings.getNotificationsShort.localized,
                icon: nil) {
                    Task {
                        await viewModel.sendNotificationEmail()
                    }
                }
                .frame(maxWidth: UIScreen.screenWidth * (sizeClass == .compact ? 1 : Constants.UnsuccessfulSearch.NotifyEmailButton.largeScreenWidthMultiplier))
        }
        .frame(maxWidth: .infinity)
        .padding()
    }
    
    private func registerInterestStep(icon: Image, text: String) -> some View {
        VStack {
            icon
                .renderingMode(.template)
                .resizable()
                .scaledToFit()
                .frame(height: Constants.UnsuccessfulSearch.RegisterInterestSteps.height * (sizeClass == .compact ? 1 : Constants.UnsuccessfulSearch.RegisterInterestSteps.iconLargeScreenMultiplier))
                .foregroundColor(colorPalette.primaryRed)
            Text(text)
                .font(.Body2.regular())
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity)
    }
    
    // MARK: - Browse store view
    private var browseStores: some View {
        VStack {
            if viewModel.retailStores.isEmpty {
                unsuccessfulStoreSearch
                    .frame(maxHeight: .infinity)
                
            } else {
                if viewModel.showStoreTypes {
                    storesTypesAvailableHorisontalScrollView()
                }
                
                if viewModel.showNoStoresAvailableMessage {
                    HStack {
                        Spacer()
                        Text(Strings.StoresView.SearchCustom.noStores.localizedFormat(viewModel.fulfilmentString))
                            .font(.heading3())
                            .foregroundColor(colorPalette.primaryBlue)
                            .padding()
                        Spacer()
                    }
                } else {
                    storesAvailableListView
                        .padding()
                }
            }
        }
        .redacted(reason: viewModel.storesSearchIsLoading || viewModel.locationIsLoading ? .placeholder : [])
        .background(colorPalette.backgroundMain)
    }
    
    // MARK: - Navigation links
    private var navigationLinks: some View {
        // MARK: NavigationLinks
        NavigationLink("", isActive: $viewModel.showFulfilmentSlotSelection) {
            FulfilmentTimeSlotSelectionView(viewModel: .init(container: viewModel.container, timeslotSelectedAction: {
                viewModel.navigateToProductsView()
            }))
        }
    }
    
    // MARK: - Stores available list
    @ViewBuilder private var storesAvailableListView: some View {
        if viewModel.showOpenStores.isEmpty == false {
            storeCardList(stores: viewModel.showOpenStores, headerText: StoreStatusStrings.openStores.localized, status: .open)
        }
        
        if viewModel.showPreorderStores.isEmpty == false {
            storeCardList(stores: viewModel.showPreorderStores, headerText: StoreStatusStrings.preorderstores.localized, status: .preOrder)
        }
        
        if viewModel.showClosedStores.isEmpty == false {
            storeCardList(stores: viewModel.showClosedStores, headerText: StoreStatusStrings.closedStores.localized, status: .closed)
        }
    }

    // MARK: - Store card list
    @ViewBuilder private func storeCardList(stores: [RetailStore], headerText: String, status: StoreStatus) -> some View {
        if sizeClass == .compact {
            LazyVStack(alignment: .center, spacing: Constants.StoreCardList.spacing) {
                Section(header: storeStatusHeader(status: status)) {
                    ForEach(stores, id: \.self) { details in
                        Button(action: {
                            Task {
                                await viewModel.selectStore(id: details.id)
                            }
                            
                        }) {
                            StoreCardInfoView(viewModel: .init(container: viewModel.container, storeDetails: details, isClosed: status == .closed), isLoading: .constant(viewModel.storeIsLoading && viewModel.storeLoadingId == details.id))
                        }
                        .disabled(viewModel.storeIsLoading)
                    }
                }
            }
        } else {
            VStack {
                storeStatusHeader(status: status)
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())]) {
                    ForEach(stores, id: \.self) { details in
                        Button(action: {
                            Task {
                                await viewModel.selectStore(id: details.id)
                            }
                            
                        }) {
                            StoreCardInfoView(viewModel: .init(container: viewModel.container, storeDetails: details), isLoading: .constant(viewModel.storeIsLoading && viewModel.storeLoadingId == details.id))
                        }
                        .disabled(viewModel.storeIsLoading)
                    }
                }
            }
        }
    }
    
    // MARK: - Store status
    private func storeStatusHeader(status: StoreStatus) -> some View {
        HStack {
            status.icon
                .renderingMode(.template)
                .resizable()
                .scaledToFit()
                .frame(width: Constants.StoreStatus.iconSize * scale)
                .foregroundColor(colorPalette.primaryBlue)
            
            if minimalViewLayout {
                Text("\(status.title.capitalizingFirstLetter()) \(StoreStatusStrings.stores.localized)")
            } else if let name = viewModel.selectedStoreTypeName {
                Text("\(status.title.capitalizingFirstLetter()) ") + Text(name).foregroundColor(colorPalette.primaryBlue) + Text(" \(StoreStatusStrings.nearYou.localized)")
            } else {
                Text("\(status.title.capitalizingFirstLetter()) \(StoreStatusStrings.stores.localized) \(StoreStatusStrings.nearYou.localized)")
            }
            Spacer()
        }
        .font(.Body1.semiBold())
        .foregroundColor(colorPalette.typefacePrimary)
    }
}

#if DEBUG
struct StoresView_Previews: PreviewProvider {
    static var previews: some View {
        StoresView(viewModel: .init(container: .preview))
            .previewCases()
    }
}
#endif
