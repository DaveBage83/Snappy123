//
//  OrderSummaryCardDetailsButton.swift
//  SnappyV2
//
//  Created by David Bage on 02/09/2022.
//

import SwiftUI

struct OrderSummaryCardDetailsButton: View {
    @ScaledMetric var scale: CGFloat = 1 // Used to scale icon for accessibility options
    @Environment(\.colorScheme) var colorScheme
    @StateObject var viewModel: OrderDetailsViewModel
    @ObservedObject var orderSummaryCardViewModel: OrderSummaryCardViewModel
    
    struct Constants {
        struct Chevron {
            static let height: CGFloat = 14
        }
    }
    
    var colorPalette: ColorPalette {
        ColorPalette(container: viewModel.container, colorScheme: colorScheme)
    }
    
    var body: some View {
        Image.Icons.Chevrons.Right.heavy
            .renderingMode(.template)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(height: Constants.Chevron.height * scale)
            .foregroundColor(colorPalette.primaryBlue)
            .onTapGesture {
                // If orderProgress is 1 then order is complete / refunded / rejected and so no need to make call to retrieve
                // driver location
                Task {
                    await viewModel.getDriverLocationIfOrderIncomplete(orderProgress: viewModel.order.orderProgress)
                }
            }
            .sheet(isPresented: $viewModel.showDetailsView) {
                if let order = viewModel.order {
                    OrderDetailsView(viewModel: .init(container: viewModel.container, order: order), orderSummaryCardViewModel: orderSummaryCardViewModel)
                }
            }
    }
}

//struct OrderSummaryCardDetailsButton_Previews: PreviewProvider {
//    static var previews: some View {
//        OrderSummaryCardDetailsButton(viewModel: .init(container: .preview, order: PlacedOrder(id: <#T##Int#>, businessOrderId: <#T##Int#>, status: <#T##String#>, statusText: <#T##String#>, totalPrice: <#T##Double#>, totalDiscounts: <#T##Double?#>, totalSurcharge: <#T##Double?#>, totalToPay: <#T##Double?#>, platform: <#T##String#>, firstOrder: <#T##Bool#>, createdAt: <#T##String#>, updatedAt: <#T##String#>, store: <#T##PlacedOrderStore#>, fulfilmentMethod: <#T##PlacedOrderFulfilmentMethod#>, paymentMethod: <#T##PlacedOrderPaymentMethod#>, orderLines: <#T##[PlacedOrderLine]#>, customer: <#T##PlacedOrderCustomer#>, discount: <#T##[PlacedOrderDiscount]?#>, surcharges: <#T##[PlacedOrderSurcharge]?#>, loyaltyPoints: <#T##PlacedOrderLoyaltyPoints?#>, coupon: <#T##PlacedOrderCoupon?#>)))
//    }
//}
