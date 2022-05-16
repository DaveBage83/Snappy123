//
//  StoresView.swift
//  SnappyV2Study
//
//  Created by Henrik Gustavii on 14/06/2021.
//

import SwiftUI

struct StoresView: View {
    typealias StoreTypesStrings = Strings.StoresView.StoreTypes
    typealias StoreStatusStrings = Strings.StoresView.StoreStatus
    typealias FailedSearchStrings = Strings.StoresView.FailedSearch
    
    struct Constants {
        static let loadingMaskOpacity: CGFloat = 0.8
    }
    
    @Environment(\.colorScheme) var colorScheme
    @StateObject var viewModel: StoresViewModel
    
    var body: some View {
        NavigationView {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading) {
                    Spacer()
                    
                    locationSelectorView()
                    
                    VStack {
                        if viewModel.shownRetailStores.isEmpty {
                            unsuccessfulStoreSearch()
                        } else {
                            storesTypesAvailableHorisontalScrollView()
                            
                            storesAvailableListView
                                .padding([.leading, .trailing], 10)
                        }
                    }
                    .redacted(reason: viewModel.storesSearchIsLoading ? .placeholder : [])
                    .background(colorScheme == .dark ? Color.black : Color.snappyBGMain)
                    
                    Spacer()
                    
					// MARK: NavigationLinks
                    NavigationLink("", isActive: $viewModel.showFulfilmentSlotSelection) {
                        FulfilmentTimeSlotSelectionView(viewModel: .init(container: viewModel.container, timeslotSelectedAction: {
                            viewModel.navigateToProductsView()
                        }))
                    }
                }
                .frame(maxWidth: .infinity)
                .navigationTitle(Text(Strings.StoresView.available.localized))
            }
        }
    }
    
    func locationSelectorView() -> some View {
        HStack {
            Image.Actions.Search.standard
            
            FocusTextField(text: $viewModel.postcodeSearchString, isFocused: $viewModel.isFocused)
            
            if viewModel.isFocused {
                Button(action: { viewModel.searchPostcode() }) {
                    Label(GeneralStrings.Search.searchPostcode.localized, systemImage: "magnifyingglass")
                        .font(.snappyCaption)
                        .padding(7)
                        .foregroundColor(.white)
                        .background(Color.snappyBlue)
                        .cornerRadius(6)
                }
            } else {
                Button(action: {
                    viewModel.fulfilmentMethodButtonTapped(.delivery)
                }) {
                    Label(GeneralStrings.delivery.localized, systemImage: "car")
                        .font(.snappyCaption)
                        .padding(7)
                        .foregroundColor(viewModel.isDeliverySelected ? .white : (colorScheme == .dark ? .white : .snappyBlue))
                        .background(viewModel.isDeliverySelected ? Color.snappyBlue : (colorScheme == .dark ? .black : .snappyBGFields2))
                        .cornerRadius(6)
                }
                
                Button(action: {
                    viewModel.fulfilmentMethodButtonTapped(.collection)
                }) {
                    Label(GeneralStrings.collection.localized, systemImage: "case")
                        .font(.snappyCaption)
                        .padding(7)
                        .foregroundColor(viewModel.isDeliverySelected ? (colorScheme == .dark ? .white : .snappyBlue) : .white)
                        .background(viewModel.isDeliverySelected ? (colorScheme == .dark ? .black : .snappyBGFields2) : Color.snappyBlue)
                        .cornerRadius(6)
                }
            }
        }
        .frame(height: 50)
        .padding(.horizontal)
    }
    
    func storesTypesAvailableHorisontalScrollView() -> some View {
        VStack {
            HStack {
                Text(StoreTypesStrings.browse.localized)
                    .font(.snappyHeadline)
                    .foregroundColor(.snappyBlue)
                
                Spacer()
                
                #warning("Not clear that this is a button")
                Button(action: { viewModel.clearFilteredRetailStoreType() } ) {
                    Text(Strings.General.showAll.localized)
                        .font(.snappyHeadline)
                        .foregroundColor(.snappyBlue)
                }
            }
            .padding(.horizontal, 10)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    if let storeTypes = viewModel.retailStoreTypes {
                        ForEach(storeTypes, id: \.self) { storeType in
                            Button(action: { viewModel.selectFilteredRetailStoreType(id: storeType.id) }) {
                                StoreTypeCard(container: viewModel.container, storeType: storeType, selected: .constant(viewModel.filteredRetailStoreType == storeType.id))
                            }
                        }
                    }
                }
                .padding(4)
            }
            .padding(.leading, 4)
        }
    }
    
    func storeCardView(details: RetailStore) -> some View {
        ZStack {
            StoreCardInfoView(viewModel: StoreCardInfoViewModel(container: viewModel.container, storeDetails: details))
            if viewModel.selectedStoreIsLoading, viewModel.selectedStoreID == details.id {
                Rectangle()
                    .fill(.white.opacity(Constants.loadingMaskOpacity))
                ProgressView()
            }
        }
    }
    
    @ViewBuilder var storesAvailableListView: some View {
        if viewModel.showOpenStores.isEmpty == false {
            storeCardList(stores: viewModel.showOpenStores, headerText: StoreStatusStrings.openStores.localized)
        }
        
        if viewModel.showClosedStores.isEmpty == false {
            storeCardList(stores: viewModel.showClosedStores, headerText: StoreStatusStrings.closedStores.localized)
        }
        
        if viewModel.showPreorderStores.isEmpty == false {
            storeCardList(stores: viewModel.showPreorderStores, headerText: StoreStatusStrings.preorderstores.localized)
        }
    }
    
    func storeCardList(stores: [RetailStore], headerText: String) -> some View {
        LazyVStack(alignment: .center) {
            Section(header: storeStatusHeader(title: headerText)) {
                ForEach(stores, id: \.self) { details in
                    Button(action: { viewModel.selectStore(id: details.id )}) {
                        storeCardView(details: details)
                    }
					.disabled(viewModel.selectedStoreIsLoading)
                }
            }
        }
        .frame(maxWidth: .infinity)
    }
    
    func unsuccessfulStoreSearch() -> some View {
        VStack {
            VStack {
                Text(FailedSearchStrings.notInArea.localized)
                    .font(.snappyTitle2)
                    .fontWeight(.semibold)
                    .foregroundColor(.snappyBlue)
                    .padding(.bottom, 1)
                
                Text(FailedSearchStrings.showInterest.localized)
                    .font(.snappyCaption)
            }
            .padding([.bottom, .top])
            
            HStack {
                VStack {
                    Image.General.thumbsUp
                        .foregroundColor(.snappyRed)
                        .padding(.bottom, 2)
                    
                    Text(FailedSearchStrings.showInterestPrompt.localized)
                }
                
                Spacer()
                
                VStack {
                    Image.Actions.edit
                        .foregroundColor(.snappyRed)
                        .padding(.bottom, 2)
                    
                    Text(FailedSearchStrings.snappyWillLog.localized)
                }
                
                Spacer()
                
                VStack {
                    Image.General.alert
                        .foregroundColor(.snappyRed)
                        .padding(.bottom, 2)
                    
                    Text(FailedSearchStrings.snappyWillNotify.localized)
                }
            }
            .font(.snappyBody)
            .multilineTextAlignment(.center)
            .padding(.bottom)
            
            SnappyTextField(title: GeneralStrings.Login.email.localized.capitalized, fieldString: $viewModel.emailToNotify)
                .padding(.bottom)
            
            Button(action: { viewModel.sendNotificationEmail() }) {
                Text(FailedSearchStrings.getNotifications.localized)
                    .fontWeight(.semibold)
                    .font(.snappyTitle3)
                    .foregroundColor(.white)
                    .padding(10)
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.snappyDark)
                    )
            }
        }
        .padding()
    }
    
    func storeStatusHeader(title: String) -> some View {
        HStack {
            Image.Stores.note
                .foregroundColor(.snappyBlue)
            
            Text(title)
                .font(.snappyHeadline)
                .foregroundColor(.snappyBlue)
            
            Spacer()
        }
        .padding(.top, 8)
        .foregroundColor(.blue)
    }
}

struct StoresView_Previews: PreviewProvider {
    static var previews: some View {
        StoresView(viewModel: .init(container: .preview))
            .previewCases()
    }
}
