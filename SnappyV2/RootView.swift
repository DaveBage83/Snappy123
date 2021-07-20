//
//  ContentView.swift
//  SnappyV2Study
//
//  Created by Henrik Gustavii on 11/06/2021.
//

import os.log
import SwiftUI

class RootViewModel: ObservableObject {
    @Published var selectedTab = 1
}

struct RootView: View {
    @StateObject var viewModel = RootViewModel()
    @StateObject var selectedStore = SelectedStoreToolbarItemViewModel()
    
    init() {
        UINavigationBar.appearance().backgroundColor = .clear
    }
    
    var body: some View {
        ZStack {
            NavigationView {
                TabView(selection: $viewModel.selectedTab) {
                    StoresView()
                        .environmentObject(selectedStore)
                        .environmentObject(viewModel)
                        .tabItem {
                            Image(systemName: "house")
                            Text("Stores")
                        }.tag(1)
                    
                    ProductsView()
                        .tabItem {
                            Image(systemName: "square.grid.2x2")
                            Text("Menu")
                        }.tag(2)
                    
                    BasketView(basketItems: MockData.resultsData)
                        .tabItem {
                            Image(systemName: "bag")
                            Text("Basket")
                        }.tag(3)
                    
                    CheckoutView()
                        .tabItem {
                            Image(systemName: "person")
                            Text("Account")
                        }.tag(4)
                    
                    Text("More")
                        .tabItem {
                            Image(systemName: "ellipsis")
                            Text("More")
                        }.tag(5)
                }
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .principal) {
                        SelectedStoreToolBarItemView()
                            .environmentObject(selectedStore)
                    }
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
                Text(selectedStore.selectedStore?.name ?? "No store")
                    .bold().padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .foregroundColor(Color.white)
                
                Button(action: {
                    selectedStore.delivery = true
                    selectedStore.showPopover = false
                }) {
                    Label("Delivery", systemImage: "car")
                }
                
                Button(action: {
                    selectedStore.delivery = false
                    selectedStore.showPopover = false
                }) {
                    Label("Collection", systemImage: "house")
                }
                
                Divider()
                
                Button(action: {
                    selectedStore.showPopover = false
                }) {
                    Text("Change Store")
                }
                
                Divider()
                
                Button(action: {
                    selectedStore.showPopover = false
                }) {
                    Text("Close")
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
        RootView().environmentObject(SelectedStoreToolbarItemViewModel())
            .previewCases()
    }
}
