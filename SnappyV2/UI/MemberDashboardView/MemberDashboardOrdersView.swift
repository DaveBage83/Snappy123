//
//  MemberDashboardOrdersView.swift
//  SnappyV2
//
//  Created by David Bage on 05/04/2022.
//

import SwiftUI

struct MemberDashboardOrdersView: View {
    
    private typealias OrdersStrings = Strings.PlacedOrders.MainView
    
    // MARK: - Constants
    
    struct Constants {
        struct Main {
            static let padding: CGFloat = 30
        }
        
        struct ViewMoreOrders {
            static let padding: CGFloat = 4
        }
        
        struct LoadingView {
            static let height: CGFloat = 200
        }
    }
    
    @StateObject var viewModel: MemberDashboardOrdersViewModel
    
    init(viewModel: MemberDashboardOrdersViewModel) {
        self._viewModel = .init(wrappedValue: viewModel)
    }
    
    // MARK: - Main body
    
    var body: some View {
        if viewModel.ordersAreLoading {
            VStack {
                Spacer()
                LoadingView()
                Spacer()
            }
            .frame(height: Constants.LoadingView.height)
            
        } else {
            VStack(alignment: .leading) {
                if viewModel.categoriseOrders {
                    if viewModel.currentOrdersPresent {
                        currentOrdersView
                    }
                    
                    if viewModel.pastOrdersPresent {
                        pastOrdersView
                    }
                } else {
                    ForEach(viewModel.allOrders, id: \.id) { order in
                        OrderSummaryCard(container: viewModel.container, order: order, includeAddress: false)
                    }
                }
                
                viewMoreOrdersView
            }
            .padding(Constants.Main.padding)
        }
    }
    
    // MARK: - Current orders view
    
    @ViewBuilder private var currentOrdersView: some View {
        VStack(alignment: .leading) {
            header(OrdersStrings.currentOrders.localized)
            
            ForEach(viewModel.currentOrders, id: \.id) { order in
                OrderSummaryCard(container: viewModel.container, order: order, includeAddress: false)
            }
        }
    }
    
    // MARK: - Past orders view
    
    @ViewBuilder private var pastOrdersView: some View {
        header(OrdersStrings.pastOrders.localized)
        
        ForEach(viewModel.pastOrders, id: \.id) { order in
            OrderSummaryCard(container: viewModel.container, order: order)
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
            Button {
                withAnimation {
                    viewModel.getMoreOrdersTapped()
                }
                
            } label: {
                Text(OrdersStrings.moreOrders.localized)
                    .frame(maxWidth: .infinity)
                    .padding(Constants.ViewMoreOrders.padding)
            }
            .buttonStyle(SnappyPrimaryButtonStyle())
        }
    }
    
    // MARK: - Header creation
    
    private func header(_ title: String) -> some View {
        Text(title)
            .font(.snappyBody)
            .fontWeight(.bold)
    }
}

#if DEBUG
struct MemberDashboardOrdersView_Previews: PreviewProvider {
    static var previews: some View {
        MemberDashboardOrdersView(viewModel: .init(container: .preview))
    }
}
#endif
