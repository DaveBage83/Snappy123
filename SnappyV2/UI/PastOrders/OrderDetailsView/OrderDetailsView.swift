//
//  OrderDetailsView.swift
//  SnappyV2
//
//  Created by David Bage on 05/04/2022.
//

import SwiftUI
import OSLog

struct OrderDetailsView: View {
    private typealias OrderDetailsStrings = Strings.PlacedOrders.OrderDetailsView
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.presentationMode) var presentation
    
    // MARK: - Constants
    
    struct Constants {
        struct DragCapsule {
            static let width: CGFloat = 35
            static let height: CGFloat = 5
        }
        
        struct ProgressBar {
            static let height: CGFloat = 6
        }
        
        struct DeliveryInfo {
            static let hStackSpacing: CGFloat = 13
            static let iconWidth: CGFloat = 24
        }
        
        struct RepeatOrderButton {
            static let padding: CGFloat = 8
        }
        
        struct TopView {
            static let vPadding: CGFloat = 10
            static let spacing: CGFloat = 24
        }
        
        struct DriverTipRefunds {
            static let spacing: CGFloat = 14
        }
    }
    
    private var colorPalette: ColorPalette {
        .init(container: viewModel.container, colorScheme: colorScheme)
    }
    
    // MARK: - View models
    
    @StateObject var viewModel: OrderDetailsViewModel
    
    // MARK: - Main body
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                Divider()
                ScrollView(showsIndicators: false) {
                    
                    VStack(spacing: Constants.TopView.spacing) {
                        orderNumberView
                            .padding(.top)
                        progressBarView
                        orderSummaryView
                    }
                    
                    OrderStoreView(viewModel: .init(container: viewModel.container, store: viewModel.order.store))
                        .padding(.bottom)
                    
                    OrderListView(viewModel: .init(container: viewModel.container, order: viewModel.order))
                        .padding(.bottom)
                    
                    orderTotalizerView
                    
                    if viewModel.displayTrackOrderButton {
                        SnappyButton(
                            container: viewModel.container,
                            type: .primary,
                            size: .large,
                            title: Strings.DriverMap.Button.trackOrder.localized,
                            largeTextTitle: Strings.DriverMap.Button.trackOrderShort.localized,
                            icon: Image.Icons.LocationCrosshairs.standard,
                            isLoading: $viewModel.mapLoading) {
                                Task {
                                    await viewModel.displayDriverMap()
                                }
                            }
                    } else {
                        repeatOrderButton
                    }
                    
                    Spacer()
                }
                .background(colorPalette.backgroundMain)
                .padding(.horizontal)
            }
            .background(colorPalette.backgroundMain)
            .edgesIgnoringSafeArea(.bottom)
            .dismissableNavBar(presentation: presentation, color: colorPalette.primaryBlue, title: Strings.PlacedOrders.OrderDetailsView.title.localized, navigationDismissType: .close, backButtonAction: nil)
        }
        .onAppear {
            viewModel.onAppearSendEvent()
        }
    }

    // MARK: - Repeat order button
    
    private var repeatOrderButton: some View {
        Button {
            Task {
                await viewModel.repeatOrderTapped()
            }
        } label: {
            if !viewModel.repeatOrderRequested {
                Text(OrderDetailsStrings.orderAgain.localized)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, Constants.RepeatOrderButton.padding)
            } else {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, Constants.RepeatOrderButton.padding)
            }
        }
        .buttonStyle(SnappyPrimaryButtonStyle())
    }
    
    // MARK: - Order number view
    
    private var orderNumberView: some View {
        HStack {
            Text(OrderDetailsStrings.orderNumber.localized)
                .font(.Body2.regular())
                .foregroundColor(colorPalette.textGrey1)
            Spacer()
            Text(viewModel.orderNumber)
                .font(.Body2.semiBold())
                .foregroundColor(colorPalette.typefacePrimary)
                .fontWeight(.semibold)
        }
    }
    
    // MARK: - Order progress view display
    
    private var progressBarView: some View {
        ProgressBarView(value: viewModel.order.orderProgress, maxValue: 1, backgroundColor: colorPalette.secondaryDark.withOpacity(.ten), foregroundColor: viewModel.order.orderStatus.statusType == .success ? .green : viewModel.order.orderStatus.statusType == .error ? .snappyRed : .snappyBlue)
            .frame(height: Constants.ProgressBar.height)
    }
    
    // MARK: - Order summary - delivery info + order total details
    
    private var orderSummaryView: some View {
        HStack {
            deliveryInfoView
            
            Spacer()
            
            VStack(alignment: .trailing) {
                Text(OrderDetailsStrings.orderTotal.localized)
                    .font(.Body2.regular())
                    .foregroundColor(colorPalette.textGrey2)
                Text("\(viewModel.numberOfItems) | \(viewModel.adjustedTotal)")
                    .font(.Body2.semiBold())
                    .foregroundColor(colorPalette.primaryBlue)
                    .fontWeight(.semibold)
            }
        }
    }
    
    // MARK: - Delivery info
    
    private var deliveryInfoView: some View {
        HStack(spacing: Constants.DeliveryInfo.hStackSpacing) {
            (viewModel.order.fulfilmentMethod.name == .delivery ? Image.Icons.Delivery.standard : Image.Icons.BagShopping.standard)
                    .renderingMode(.template)
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(colorPalette.primaryBlue)
                    .frame(width: Constants.DeliveryInfo.iconWidth)

            VStack(alignment: .leading) {
                Text(viewModel.fulfilmentMethod)
                    .font(.Body2.regular())
                    .foregroundColor(colorPalette.textGrey2)
                
                HStack {
                    Text(viewModel.selectedSlot ?? "")
                        .font(.Body2.semiBold())
                        .foregroundColor(colorPalette.primaryBlue)
                }
            }
        }
    }
    
    // MARK: - Order totalizer
    
    private var orderTotalizerView: some View {
        VStack {
            
            ForEach(viewModel.displayableSurcharges) { surcharge in
                orderTotalizerLine(title: surcharge.name, price: surcharge.amount)
                Divider()
            }
            
            if let deliveryCostPriceString = viewModel.deliveryCostPriceString {
                orderTotalizerLine(title: OrderDetailsStrings.deliveryFee.localized, price: deliveryCostPriceString)
                Divider()
            }
            
            if let driverTipPriceString = viewModel.driverTipPriceString {
                if let driverTipRefunds = viewModel.driverTipRefund {
                    VStack(spacing: Constants.DriverTipRefunds.spacing) {
                        orderTotalizerLine(title: OrderDetailsStrings.driverTip.localized, price: driverTipPriceString, strikThrough: true)
                        ForEach(driverTipRefunds, id: \.self) { refund in
                            orderTotalizerLine(title: Strings.PlacedOrders.OrderDetailsView.refund.localized, price: "-\(refund.value.toCurrencyString(using: viewModel.order.currency))", infoText: refund.message)
                        }
                    }
                    Divider()
                } else {
                    orderTotalizerLine(title: OrderDetailsStrings.driverTip.localized, price: driverTipPriceString)
                    Divider()
                }
            }
            
            if viewModel.showTotalCostAdjustment {
                orderTotalizerLine(title: Strings.PlacedOrders.OrderDetailsView.originalTotal.localized, price: viewModel.totalToPay)
                Divider()
                
                orderTotalizerLine(title: Strings.PlacedOrders.OrderDetailsView.totalAdjustment.localized, price: viewModel.totalRefunded, isTotal: true)
                    .font(.Body2.semiBold())
                    .foregroundColor(colorPalette.alertSuccess)
                Divider()
            }
            
            orderTotalizerLine(title: Strings.PlacedOrders.OrderDetailsView.finalTotal.localized, price: viewModel.adjustedTotal, isTotal: true)
            Divider()
        }
    }
    
    // MARK: - Order totalizer line creation
    
    private func orderTotalizerLine(title: String, price: String, isTotal: Bool = false, strikThrough: Bool = false, infoText: String? = nil) -> some View {
        return VStack {
            HStack {
                if let infoText = infoText {
                    Text(title)
                        .font(isTotal ? .Body2.semiBold() : .Body2.regular())
                        .withInfoButtonAndText(container: viewModel.container, text: infoText)
                } else {
                    Text(title)
                        .font(isTotal ? .Body2.semiBold() : .Body2.regular())
                }
                
                Spacer()
                Text(price)
                    .font(isTotal ? .Body2.semiBold() : .Body2.regular())
                    .strikethrough(strikThrough, color: colorPalette.primaryRed)
            }
        }
    }
}

#if DEBUG
struct OrderDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        OrderDetailsView(viewModel: .init(
            container: .preview,
            order: .init(
                id: 1,
                businessOrderId: 1,
                status: "Sent to store",
                statusText: "Sent to store",
                totalPrice: 1,
                totalDiscounts: nil,
                totalSurcharge: nil,
                totalToPay: 10,
                platform: "",
                firstOrder: true,
                createdAt: "",
                updatedAt: "",
                store: .init(
                    id: 1,
                    name: "Test Store",
                    originalStoreId: 1,
                    storeLogo: nil,
                    address1: "Address Line 1",
                    address2: "Address Line 2",
                    town: "Test Town",
                    postcode: "TES T10",
                    telephone: "09992828282",
                    latitude: 1,
                    longitude: 1),
                fulfilmentMethod: .init(
                    name: .delivery,
                    processingStatus: "In progress",
                    datetime: .init(
                        requestedDate: nil,
                        requestedTime: nil,
                        estimated: nil,
                        fulfilled: nil),
                    place: nil,
                    address: nil,
                    driverTip: nil,
                    refund: nil,
                    deliveryCost: nil,
                    driverTipRefunds: nil),
                paymentMethod: .init(name: "", dateTime: ""),
                orderLines: [],
                customer: .init(firstname: "Darren", lastname: "Dimble"),
                discount: nil,
                surcharges: nil,
                loyaltyPoints: nil,
                coupon: nil,
                currency: .init(
                    currencyCode: "GBP",
                    symbol: "£",
                    ratio: 1,
                    symbolChar: "£",
                    name: "Great British Pound"),
                totalOrderValue: 10,
                totalRefunded: 0),
            showTrackOrderButton: false))
    }
}
#endif
