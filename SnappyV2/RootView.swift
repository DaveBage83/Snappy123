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
                    
                    BasketView(basketItems: resultsData)
                        .tabItem {
                            Image(systemName: "bag")
                            Text("Basket")
                        }.tag(3)
                    
                    Text("Account")
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
    
    let resultsData = [ProductDetail(label: "Some whiskey or other that possibly is not Scottish", image: "whiskey1", currentPrice: "£20.90", previousPrice: "£24.45", offer: "20% off", description: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Curabitur feugiat pharetra aliquam. Sed eget commodo dolor. Quisque purus nisi, commodo sit amet augue at, convallis placerat erat. Donec in euismod turpis, in dictum est. Vestibulum imperdiet interdum tempus. Mauris pellentesque tellus scelerisque, vestibulum lacus volutpat, placerat felis. Morbi placerat, nulla quis euismod eleifend, dui dui laoreet massa, sed suscipit arcu nunc facilisis odio. Morbi tempor libero eget viverra vulputate. Curabitur ante orci, auctor id hendrerit sit amet, tincidunt ut nisi.", ingredients: """
Lorem ipsum dolor sit amet
Vestibulum euismod ex ac erat suscipit
Donec at metus et magna accumsan cursus eu in neque
In efficitur dolor scelerisque metus varius
Duis mollis diam iaculis elit auctor
"""),
                       ProductDetail(label: "Another whiskey", image: "whiskey2", currentPrice: "£24.95", previousPrice: nil, offer: nil, description: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Curabitur feugiat pharetra aliquam. Sed eget commodo dolor. Quisque purus nisi, commodo sit amet augue at, convallis placerat erat. Donec in euismod turpis, in dictum est. Vestibulum imperdiet interdum tempus. Mauris pellentesque tellus scelerisque, vestibulum lacus volutpat, placerat felis. Morbi placerat, nulla quis euismod eleifend, dui dui laoreet massa, sed suscipit arcu nunc facilisis odio. Morbi tempor libero eget viverra vulputate. Curabitur ante orci, auctor id hendrerit sit amet, tincidunt ut nisi.", ingredients: """
Lorem ipsum dolor sit amet
Vestibulum euismod ex ac erat suscipit
Donec at metus et magna accumsan cursus eu in neque
In efficitur dolor scelerisque metus varius
Duis mollis diam iaculis elit auctor
"""),
                       ProductDetail(label: "Yet another whiskey", image: "whiskey3", currentPrice: "£20.90", previousPrice: "£24.45", offer: "Meal Deal", description: nil, ingredients: nil),
                       ProductDetail(label: "Really, another whiskey?", image: "whiskey4", currentPrice: "£34.70", previousPrice: nil, offer: "3 for 2", description: nil, ingredients: nil),
                       ProductDetail(label: "Some whiskey or other that possibly is not Scottish", image: "whiskey1", currentPrice: "£20.90", previousPrice: "£24.45", offer: nil, description: nil, ingredients: nil),
                       ProductDetail(label: "Another whiskey", image: "whiskey2", currentPrice: "£20.90", previousPrice: "£24.45", offer: nil, description: nil, ingredients: nil)]
}

struct RootView_Previews: PreviewProvider {

    static var previews: some View {
        RootView().environmentObject(SelectedStoreToolbarItemViewModel())
            .previewCases()
    }
}
