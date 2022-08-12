//
//  ContentView.swift
//  SnappyV2Study
//
//  Created by Henrik Gustavii on 11/06/2021.
//

import os.log
import SwiftUI

typealias GeneralStrings = Strings.General

private struct TabViewHeightKey: EnvironmentKey {
    static let defaultValue: CGFloat = 60
}

struct RootView: View {
    typealias TabStrings = Strings.RootView.Tabs
    typealias ChangeStoreStrings = Strings.RootView.ChangeStore
    
    struct Constants {
        static let additionalTabBarPadding: CGFloat = 10
    }
        
    @ObservedObject var viewModel: RootViewModel
    @StateObject var selectedStore = SelectedStoreToolbarItemViewModel()
    @State var tabViewHeight: CGFloat = 0.0
    
    init(viewModel: RootViewModel) {
        self._viewModel = .init(wrappedValue: viewModel)
        UINavigationBar.appearance().backgroundColor = .clear
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            switch viewModel.selectedTab {
            case .stores:
                StoresView(viewModel: .init(container: viewModel.container))
            case .menu:
                ProductsView(viewModel: .init(container: viewModel.container))
            case .account:
                MemberDashboardView(viewModel: .init(container: viewModel.container))
            case .basket:
                BasketView(viewModel: .init(container: viewModel.container))
            }
            
            TabBarView(viewModel: .init(container: viewModel.container))
                .padding(.bottom, Constants.additionalTabBarPadding)
                .fixedSize(horizontal: false, vertical: true)
                .overlay(GeometryReader { geo in
                    Text("")
                        .onAppear {
                            tabViewHeight = geo.size.height + Constants.additionalTabBarPadding
                        }
                })
                .environment(\.tabViewHeight, tabViewHeight)
            
            if $selectedStore.showPopover.wrappedValue {
                changeStorePopover()
            }
        }
        .edgesIgnoringSafeArea(.bottom)
        .sheet(isPresented: $viewModel.displayDriverMap) {
            DriverMapView(
                viewModel: DriverMapViewModel(
                    container: viewModel.container,
                    mapParameters: viewModel.driverMapParameters,
                    dismissDriverMapHandler: {
                        viewModel.dismissDriverMap()
                    }
                ), isModal: true
            )
        }
        .onAppear() {
            viewModel.viewShown()
        }
        .onDisappear() {
            viewModel.viewRemoved()
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

extension EnvironmentValues {
  var tabViewHeight: CGFloat {
    get { self[TabViewHeightKey.self] }
    set { self[TabViewHeightKey.self] = newValue }
  }
}

#if DEBUG
struct RootView_Previews: PreviewProvider {

    static var previews: some View {
        RootView(viewModel: .init(container: .preview))
            .previewCases()
    }
}
#endif
