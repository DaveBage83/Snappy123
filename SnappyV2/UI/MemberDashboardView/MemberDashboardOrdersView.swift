//
//  MemberDashboardOrdersView.swift
//  SnappyV2
//
//  Created by David Bage on 05/04/2022.
//

import SwiftUI

struct MemberDashboardOrdersView: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.tabViewHeight) var tabViewHeight

    private typealias OrdersStrings = Strings.PlacedOrders.MainView
    
    // MARK: - Constants
    
    struct Constants {
        struct Main {
            static let padding: CGFloat = 30
            static let vSpacing: CGFloat = 16
        }
        
        struct FirstOrderView {
            static let spacing: CGFloat = 16
        }
    }
    
    @StateObject var viewModel: MemberDashboardOrdersViewModel
    
    private var colorPalette: ColorPalette {
        ColorPalette(container: viewModel.container, colorScheme: colorScheme)
    }

    // MARK: - Main body
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: Constants.Main.vSpacing) {
            
            if viewModel.initialOrdersLoading {
                if viewModel.categoriseOrders {
                    header(OrdersStrings.currentOrders.localized)
                        .padding(.top, Constants.Main.padding)
                        .redacted(reason: viewModel.initialOrdersLoading ? .placeholder: [])
                }
                
                ForEach(1...10, id: \.self) { _ in
                    OrderSummaryCard(container: viewModel.container, order: viewModel.placeholderOrder, basket: nil)
                }
                .redacted(reason: viewModel.initialOrdersLoading ? .placeholder: [])
                
            } else if viewModel.categoriseOrders {
                if viewModel.currentOrdersPresent {
                    header(OrdersStrings.currentOrders.localized)
                        .padding(.top, Constants.Main.padding)
                    orderSummaryCards(orders: viewModel.currentOrders)
                }

                if viewModel.pastOrdersPresent {
                    header(OrdersStrings.pastOrders.localized)
                        .padding(.top, Constants.Main.padding)
                    orderSummaryCards(orders: viewModel.pastOrders)
                }
            } else {
                orderSummaryCards(orders: viewModel.allOrders)
            }
            
            if viewModel.showViewMoreOrdersView {
                viewMoreOrdersView
            } else if viewModel.showPlaceFirstOrderView {
                VStack(spacing: Constants.FirstOrderView.spacing) {
                    Text(Strings.MemberDashboard.Orders.firstOrderTitle.localized)
                        .font(.heading3())
                        .foregroundColor(colorPalette.primaryBlue)
                        .multilineTextAlignment(.center)
                        .padding()
                    SnappyButton(
                        container: viewModel.container,
                        type: .primary,
                        size: .large,
                        title: Strings.MemberDashboard.Orders.firstOrderButton.localized,
                        largeTextTitle: nil,
                        icon: nil,
                        isEnabled: .constant(true),
                        isLoading: .constant(false),
                        clearBackground: false) {
                            viewModel.placeFirstOrderButtonTapped()
                        }
                }
                
                Spacer()
            }
            
            Spacer()
        }
        .sheet(item: $viewModel.selectedOrder, content: { order in
            ToastableViewContainer(content: {
                OrderDetailsView(viewModel: .init(container: viewModel.container, order: order, showTrackOrderButton: viewModel.showTrackOrderButton))
            }, viewModel: .init(container: viewModel.container, isModal: false))
        })
        .withLoadingToast(loading: $viewModel.initialOrdersLoading)
        .onAppear {
            viewModel.onAppearSendEvent()
        }
    }
    
    @ViewBuilder private func orderSummaryCards(orders: [PlacedOrderSummary]) -> some View {
        ForEach(orders, id: \.id) { order in
            Button {
                Task {
                    await viewModel.getPlacedOrder(businessOrderId: order.businessOrderId)
                }
            } label: {
                OrderSummaryCard(container: viewModel.container, order: order, basket: nil, includeAddress: false)
            }
            .withLoadingToast(loading: .constant(viewModel.currentOrderIsLoading(businessOrderId: order.businessOrderId)))
            .disabled(viewModel.disableCard(businessOrderId: order.businessOrderId))
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
                .padding(.bottom, tabViewHeight)
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
                .padding(.bottom, tabViewHeight)
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
