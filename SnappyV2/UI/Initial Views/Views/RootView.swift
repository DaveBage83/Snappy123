//
//  ContentView.swift
//  SnappyV2Study
//
//  Created by Henrik Gustavii on 11/06/2021.
//

import os.log
import SwiftUI

typealias GeneralStrings = Strings.General

struct RootView: View {
    typealias TabStrings = Strings.RootView.Tabs
    typealias ChangeStoreStrings = Strings.RootView.ChangeStore
    
    @StateObject var viewModel: RootViewModel
    @StateObject var selectedStore = SelectedStoreToolbarItemViewModel()
    
    init(viewModel: RootViewModel) {
        self._viewModel = StateObject(wrappedValue: viewModel)
        UINavigationBar.appearance().backgroundColor = .clear
    }
    
    var body: some View {
        ZStack {
                TabView(selection: $viewModel.selectedTab) {
                    StoresView(viewModel: .init(container: viewModel.container))
                        .tabItem {
                            Image.Tabs.home
                            Text(TabStrings.stores.localized)
                        }
                        .tag(1)
                    
                    ProductsView(viewModel: .init(container: viewModel.container))
                        .tabItem {
                            Image.Tabs.menu
                            Text(TabStrings.menu.localized)
                        }
                        .tag(2)
                    
                    // Only iOS 15 users will see the basket "badge"
                    if #available(iOS 15.0, *) {
                        BasketView(viewModel: .init(container: viewModel.container))
                            .tabItem {
                                Image.Tabs.basket
                                Text(TabStrings.basket.localized)
                            }
                            .badge(viewModel.basketTotal)
                            .tag(3)
                    } else {
                        BasketView(viewModel: .init(container: viewModel.container))
                            .tabItem {
                                Image.Tabs.basket
                                Text(TabStrings.basket.localized)
                            }
                            .tag(3)
                    }
                    
                    CheckoutView(viewModel: .init(container: viewModel.container))
                        .tabItem {
                            Image.Login.User.standard
                            Text(TabStrings.account.localized)
                        }
                        .tag(4)
                    
                    ProductOptionsView(viewModel: ProductOptionsViewModel(container: .preview, item: MockData.item))
                        .tabItem {
                            Image.Tabs.more
                            Text(GeneralStrings.more.localized)
                        }
                        .tag(5)
                }
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .principal) {
                        SelectedStoreToolBarItemView()
                            .environmentObject(selectedStore)
                    }
                }
            
            if $selectedStore.showPopover.wrappedValue {
                changeStorePopover()
            }
        }
    }
    
    func changeStorePopover() -> some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                Text(selectedStore.selectedStore?.name ?? ChangeStoreStrings.noStore.localized)
                    .bold().padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .foregroundColor(Color.white)
                
                Button(action: {
                    selectedStore.delivery = true
                    selectedStore.showPopover = false
                }) {
                    Label(GeneralStrings.delivery.localized, systemImage: "car")
                }
                
                Button(action: {
                    selectedStore.delivery = false
                    selectedStore.showPopover = false
                }) {
                    Label(GeneralStrings.collection.localized, systemImage: "house")
                }
                
                Divider()
                
                Button(action: {
                    selectedStore.showPopover = false
                }) {
                    Text(ChangeStoreStrings.changeStore.localized)
                }
                
                Divider()
                
                Button(action: {
                    selectedStore.showPopover = false
                }) {
                    Text(GeneralStrings.close.localized)
                }
                
                Spacer()
            }
            .frame(width: 300, height: 270)
            .background(Color.white)
            .cornerRadius(20).shadow(radius: 20)
        }
    }
}

struct RootView_Previews: PreviewProvider {

    static var previews: some View {
        RootView(viewModel: .init(container: .preview))
            .previewCases()
    }
}
