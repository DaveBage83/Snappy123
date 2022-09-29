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
    static let defaultValue: CGFloat = 70
}

struct RootView: View {
    typealias TabStrings = Strings.RootView.Tabs
    typealias ChangeStoreStrings = Strings.RootView.ChangeStore
    
    struct Constants {
        static let additionalTabBarPadding: CGFloat = 10
    }
        
    @ObservedObject var viewModel: RootViewModel
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
                MemberDashboardView(viewModel: .init(container: viewModel.container, isFromInitialView: false))
            case .basket:
                BasketView(viewModel: .init(container: viewModel.container))
            }
            
            TabBarView(viewModel: .init(container: viewModel.container))
                .fixedSize(horizontal: false, vertical: true)
                .overlay(GeometryReader { geo in
                    Text("")
                        .onAppear {
                            tabViewHeight = geo.size.height
                        }
                })
                .environment(\.tabViewHeight, tabViewHeight)
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
