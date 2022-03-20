//
//  OrderSummaryCard.swift
//  SnappyV2
//
//  Created by David Bage on 28/02/2022.
//

import SwiftUI

struct OrderSummaryCard: View {
    typealias SummaryStrings = Strings.OrderSummaryCard
    
    struct Constants {
        struct General {
            static let cornerRadius: CGFloat = 15
        }
        
        struct StoreLogo {
            static let size: CGFloat = 100
            static let cornerRadius: CGFloat = 10
        }
        
        struct DeliveryStatus {
            static let vPadding: CGFloat = 3
            static let hPadding: CGFloat = 10
            static let cornerRadiung: CGFloat = 15
            static let deliveryIconSize: CGFloat = 30
        }
        
        struct ProgressBar {
            static let height: CGFloat = 6
        }
    }
    
    @StateObject var viewModel: OrderSummaryCardViewModel
    
    var body: some View {
        HStack {
            storeLogo
            orderSummaryStack
        }
        .padding()
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: Constants.General.cornerRadius))
        .snappyShadow()
        
    }
    
    @ViewBuilder var storeLogo: some View {
        if let logo = viewModel.storeLogo {
            logo
                .scaledToFit()
                .frame(width: Constants.StoreLogo.size, height: Constants.StoreLogo.size)
                .cornerRadius(Constants.StoreLogo.cornerRadius)
        } else {
            Image.Stores.convenience
                .resizable()
                .scaledToFit()
                .frame(width: Constants.StoreLogo.size, height: Constants.StoreLogo.size)
                .cornerRadius(Constants.StoreLogo.cornerRadius)
        }
    }
    
    var deliveryStatus: some View {
        HStack {
            Text(viewModel.status)
                .font(.snappyBody)
                .fontWeight(.medium)
                .foregroundColor(.white)
                .padding(.vertical, Constants.DeliveryStatus.vPadding)
                .padding(.horizontal, Constants.DeliveryStatus.hPadding)
                .background(Color.snappyBlue)
                .clipShape(RoundedRectangle(cornerRadius: Constants.DeliveryStatus.cornerRadiung))
            Spacer()
            (viewModel.fulfilmentType == .delivery ? Image.Checkout.car : Image.Tabs.basket)
                .foregroundColor(.snappyBlue)
                .font(.system(size: Constants.DeliveryStatus.deliveryIconSize))
        }
    }
    
    var orderTotal: some View {
        VStack(alignment: .leading) {
            
            Text(SummaryStrings.total.localized)
                .foregroundColor(.snappyTextGrey2)
            
            Text(viewModel.orderTotal)
                .fontWeight(.medium)
                .foregroundColor(.snappyBlue)
        }
        .font(.snappyBody)
    }
    
    var viewOrderButton: some View {
        Button {
            #warning("Replace with method to take user to order summary view - awaiting backend")
            print("Button pressed")
        } label: {
            Text(SummaryStrings.view.localized)
        }
        .buttonStyle((SnappySecondaryButtonStyle()))
    }
    
    var orderTotalStack: some View {
        HStack {
            orderTotal
            Spacer()
            viewOrderButton
        }
    }
    
    var orderSummaryStack: some View {
        VStack(alignment: .leading) {
            deliveryStatus
            Text(viewModel.selectedSlot)
                .font(.snappyBody)
                .fontWeight(.medium)
                .foregroundColor(.snappyBlue)
            #warning("Progress bar values will come from viewModel once PastOrders call is ready")
            ProgressBarView(value: 1, maxValue: 4, backgroundColor: .snappyBGFields1, foregroundColor: .snappyBlue)
                .frame(height: Constants.ProgressBar.height)
            orderTotalStack
        }
    }
}

struct OrderSummaryCard_Previews: PreviewProvider {
    static var previews: some View {
        OrderSummaryCard(viewModel: OrderSummaryCardViewModel(container: .preview, order: TestPastOrder.order))
    }
}
