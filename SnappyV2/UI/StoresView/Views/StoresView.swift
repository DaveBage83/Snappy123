//
//  StoresView.swift
//  SnappyV2Study
//
//  Created by Henrik Gustavii on 14/06/2021.
//

import SwiftUI
import Combine

class StoresViewModel: ObservableObject {
    @Published var postcodeSearchString = ""
    @Published var isDeliverySelected = false
    @Published var emailToNotify = ""
    
    var hasReturnedResult: Bool = false
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        
        // Temporary sub to demonstrate view change
        $postcodeSearchString
            .sink { value in
                self.hasReturnedResult = value.isEmpty == false
            }
            .store(in: &cancellables)
    }
    
    func sendNotificationEmail() {
        // send email address to server
    }
}

struct StoresView: View {
    @Environment(\.colorScheme) var colorScheme
    @StateObject var viewModel = StoresViewModel()
    @EnvironmentObject var selectedStoreViewModel: SelectedStoreToolbarItemViewModel
    @EnvironmentObject var rootViewModel: RootViewModel
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading) {
                Spacer()
                
                locationSelectorView()
                
                VStack {
                    storesTypesAvailableHorisontalScrollView()
                    
                    storesAvailableListView
                        .padding([.leading, .trailing], 10)
                }
                .background(colorScheme == .dark ? Color.black : Color.snappyBGMain)
                
                Spacer()
            }
            .frame(maxWidth: .infinity)
            .navigationTitle(Text("Stores Available"))
        }
            
    }
    
    func locationSelectorView() -> some View {
        HStack {
            Image(systemName: "magnifyingglass")
            TextField("Postcode", text: $viewModel.postcodeSearchString)
            Button(action: { viewModel.isDeliverySelected = true }) {
                Label("Delivery", systemImage: "car")
                    .font(.snappyCaption)
                    .padding(7)
                    .foregroundColor(viewModel.isDeliverySelected ? .white : (colorScheme == .dark ? .white : .snappyBlue))
                    .background(viewModel.isDeliverySelected ? Color.snappyBlue : (colorScheme == .dark ? .black : .snappyBGFields2))
                    .cornerRadius(6)
            }
            
            Button(action: { viewModel.isDeliverySelected = false }) {
                Label("Collection", systemImage: "case")
                    .font(.snappyCaption)
                    .padding(7)
                    .foregroundColor(viewModel.isDeliverySelected ? (colorScheme == .dark ? .white : .snappyBlue) : .white)
                    .background(viewModel.isDeliverySelected ? (colorScheme == .dark ? .black : .snappyBGFields2) : Color.snappyBlue)
                    .cornerRadius(6)
            }
        }
        .frame(height: 50)
        .padding(.horizontal)
    }
    
    func storesTypesAvailableHorisontalScrollView() -> some View {
        VStack {
            HStack {
                Text("Stores Available")
                    .font(.snappyHeadline)
                    .foregroundColor(.snappyBlue)
                
                Spacer()
            }
            .padding(.horizontal, 10)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(MockData.StoreType.allCases, id: \.self) { storeType in
                        Image(storeType.getStoreTypeData().image)
                            .resizable()
                            .cornerRadius(10)
                            .frame(width: 100.0, height: 100.0)
                            .shadow(color: .gray, radius: 5)
                            .padding(4)
                    }
                }
                .padding(4)
            }
            .padding(.leading, 4)
        }
    }
    
    @ViewBuilder var storesAvailableListView: some View {
        if viewModel.hasReturnedResult {
            LazyVStack(alignment: .center) {
                Section(header: storeStatusOpenHeader()) {
                    ForEach(MockData.stores1, id: \.id) { details in
                        NavigationLink(destination: DeliverySlotSelectionView().environmentObject(self.rootViewModel)
                                        .onAppear {
                                            selectedStoreViewModel.selectedStore = details
                                        }) {
                            StoreCardInfoView(storeDetails: details)
                        }
                    }
                }
                Section(header: storeStatusPreOrderClosedHeader()) {
                    ForEach(MockData.stores2, id: \.id) { details in
                        StoreCardInfoView(storeDetails: details)
                    }
                }
                
                Section(header: storeStatusPreOrderHeader()) {
                    ForEach(MockData.stores3, id: \.id) { details in
                        StoreCardInfoView(storeDetails: details)
                    }
                }
                
            }
            .frame(maxWidth: .infinity)
        } else {
            unsuccessfulStoreSearch()
        }
    }
    
    func unsuccessfulStoreSearch() -> some View {
        VStack {
            VStack {
                Text("We're not in your area yet")
                    .font(.snappyTitle2)
                    .fontWeight(.semibold)
                    .foregroundColor(.snappyBlue)
                    .padding(.bottom, 1)
                
                Text("Let us know your interest in having snappy in your area")
                    .font(.snappyCaption)
            }
            .padding([.bottom, .top])
            
            HStack {
                VStack {
                    Image(systemName: "hand.thumbsup")
                        .foregroundColor(.snappyRed)
                        .padding(.bottom, 2)
                    
                    Text("Let us know your interest")
                }
                
                Spacer()
                
                VStack {
                    Image(systemName: "rectangle.and.pencil.and.ellipsis")
                        .foregroundColor(.snappyRed)
                        .padding(.bottom, 2)
                    
                    Text("Snappy will log it")
                }
                
                Spacer()
                
                VStack {
                    Image(systemName: "bell")
                        .foregroundColor(.snappyRed)
                        .padding(.bottom, 2)
                    
                    Text("We'll notify of arrival")
                }
            }
            .font(.snappyBody)
            .multilineTextAlignment(.center)
            .padding(.bottom)
            
            SnappyTextField(title: "Email", fieldString: $viewModel.emailToNotify)
                .padding(.bottom)
            
            Button(action: { viewModel.sendNotificationEmail() }) {
                Text("Get Notifications")
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
    
    func storeStatusOpenHeader() -> some View {
        HStack {
            Image(systemName: "note.text")
                .foregroundColor(.snappyBlue)
            
            Text("Open Stores")
                .font(.snappyHeadline)
                .foregroundColor(.snappyBlue)
            
            Spacer()
        }
        .padding(.top, 8)
        .foregroundColor(.blue)
    }
    
    func storeStatusPreOrderClosedHeader() -> some View {
        HStack {
            Image(systemName: "clock")
                .foregroundColor(.snappyBlue)
            
            Text("Pre Order Closed Stores")
                .font(.snappyHeadline)
                .foregroundColor(.snappyBlue)
            
            Spacer()
        }
        .padding(.top, 8)
        .foregroundColor(.snappyBlue)
    }
    
    func storeStatusPreOrderHeader() -> some View {
        HStack {
            Image(systemName: "bookmark")
                .foregroundColor(.snappyBlue)
            
            Text("Pre Order Closed Stores")
                .font(.snappyHeadline)
                .foregroundColor(.snappyBlue)
            
            Spacer()
        }
        .padding(.top, 4)
        .foregroundColor(.blue)
    }
}

#if DEBUG

struct StoresView_Previews: PreviewProvider {
    static var previews: some View {
        StoresView()
            .environmentObject(RootViewModel(container: .preview))
            .previewCases()
    }
}

extension MockData {
    static let stores1 = [
        StoreCardDetails(name: "Coop", logo: "coop-logo", address: "Newhaven Road", deliveryTime: "20-30 mins", distaceToDeliver: 1.3, deliveryCharge: nil, isNewStore: true),
        StoreCardDetails(name: "SPAR", logo: "spar-logo", address: "Someother Street", deliveryTime: "15-30 mins", distaceToDeliver: 1, deliveryCharge: 2.5, isNewStore: false),
        StoreCardDetails(name: "KeyStore", logo: "keystore-logo", address: "Othersideoftown Rd", deliveryTime: "30-45 mins", distaceToDeliver: 2.3, deliveryCharge: 3.5, isNewStore: false)]
    
    static let stores2 = [
        StoreCardDetails(name: "Premier", logo: "premier-logo", address: "High Street", deliveryTime: "20-30 mins", distaceToDeliver: 2, deliveryCharge: 4, isNewStore: false),
        StoreCardDetails(name: "Filco Market", logo: "filco-logo", address: "Nextdoor Street", deliveryTime: "15-30 mins", distaceToDeliver: 1, deliveryCharge: 2.5, isNewStore: false),
        ]
    
    static let stores3 = [StoreCardDetails(name: "Coop", logo: "coop-logo", address: "Lessersideoftown Av", deliveryTime: "40-50 mins", distaceToDeliver: 3.5, deliveryCharge: 5, isNewStore: true)]
}

#endif
