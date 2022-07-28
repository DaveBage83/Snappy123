//
//  MemberDashboardOrdersView.swift
//  SnappyV2
//
//  Created by David Bage on 05/04/2022.
//

import SwiftUI

struct MemberDashboardOrdersView: View {
    @Environment(\.colorScheme) var colorScheme
    private typealias OrdersStrings = Strings.PlacedOrders.MainView
    
    // MARK: - Constants
    
    struct Constants {
        struct Main {
            static let padding: CGFloat = 30
            static let vSpacing: CGFloat = 16
        }
        
        struct ViewMoreOrders {
            static let padding: CGFloat = 4
        }
        
        struct LoadingView {
            static let height: CGFloat = 200
        }
    }
    
    @StateObject var viewModel: MemberDashboardOrdersViewModel
    
    private var colorPalette: ColorPalette {
        ColorPalette(container: viewModel.container, colorScheme: colorScheme)
    }
    
    init(viewModel: MemberDashboardOrdersViewModel) {
        self._viewModel = .init(wrappedValue: viewModel)
    }
    
    // MARK: - Main body
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: Constants.Main.vSpacing) {
            if viewModel.categoriseOrders {
                if viewModel.currentOrdersPresent {
                    currentOrdersView
                        .padding(.top, Constants.Main.padding)
                }
                
                if viewModel.pastOrdersPresent {
                    pastOrdersView
                        .padding(.top, Constants.Main.padding)
                }
            } else {
                ForEach(viewModel.allOrders, id: \.id) { order in
                    OrderSummaryCard(container: viewModel.container, order: order, includeAddress: false)
                }
            }
            
            if viewModel.showViewMoreOrdersView {
                viewMoreOrdersView
            }
        }
        .toast(isPresenting: $viewModel.initialOrdersLoading) {
            AlertToast(displayMode: .alert, type: .loading)
        }
        .onAppear {
            viewModel.onAppearSendEvent()
        }
    }
    
    // MARK: - Current orders view
    
    @ViewBuilder private var currentOrdersView: some View {
        VStack(alignment: .leading, spacing: Constants.Main.vSpacing) {
            header(OrdersStrings.currentOrders.localized)
            
            ForEach(viewModel.currentOrders, id: \.id) { order in
                OrderSummaryCard(container: viewModel.container, order: order, includeAddress: false)
            }
        }
    }
    
    // MARK: - Past orders view
    
    @ViewBuilder private var pastOrdersView: some View {
        VStack(alignment: .leading, spacing: Constants.Main.vSpacing) {
            header(OrdersStrings.pastOrders.localized)
            
            ForEach(viewModel.pastOrders, id: \.id) { order in
                OrderSummaryCard(container: viewModel.container, order: order)
            }
        }
    }
    
    // MARK: - View more orders view
    
    // If all the orders have been fetched from the API, we replace the button with text
    
    @ViewBuilder private var viewMoreOrdersView: some View {
        if viewModel.allOrdersFetched {
            Text(OrdersStrings.noMoreOrders.localized)
                .font(.snappyCaption)
                .foregroundColor(.snappyTextGrey2)
                .frame(maxWidth: .infinity)
                .multilineTextAlignment(.center)
        } else {
            SnappyButton(
                container: viewModel.container,
                type: .primary,
                size: .large,
                title: OrdersStrings.moreOrders.localized,
                largeTextTitle: nil,
                icon: nil,
                isLoading: $viewModel.moreOrdersLoading) {
                    withAnimation {
                        viewModel.getMoreOrdersTapped()
                    }
                }
        }
    }
    
    // MARK: - Header creation
    
    private func header(_ title: String) -> some View {
        Text(title)
            .font(.heading4())
            .foregroundColor(colorPalette.primaryBlue)
    }
}

#if DEBUG
struct MemberDashboardOrdersView_Previews: PreviewProvider {
    static var previews: some View {
        MemberDashboardOrdersView(viewModel: .init(container: .preview))
    }
}
#endif
