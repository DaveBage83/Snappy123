//
//  OrderSummaryCard.swift
//  SnappyV2
//
//  Created by David Bage on 28/02/2022.
//

import SwiftUI

struct OrderSummaryCard: View {
    
    private typealias SummaryStrings = Strings.OrderSummaryCard
    
    // MARK: - Constants
    
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
            static let deliveryIconSize: CGFloat = 25
        }
        
        struct ProgressBar {
            static let height: CGFloat = 6
        }
    }
    
    // MARK: - View model
    
    @StateObject var viewModel: OrderSummaryCardViewModel
    @StateObject var orderDetailsViewModel: OrderDetailsViewModel
    
    init(container: DIContainer, order: PlacedOrder) {
        self._viewModel = .init(wrappedValue: .init(container: container, order: order))
        self._orderDetailsViewModel = .init(wrappedValue: .init(container: container, order: order))
    }
    
    // MARK: - Main body
    
    var body: some View {
        HStack {
            storeLogoView
            orderSummaryView
        }
        .padding()
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: Constants.General.cornerRadius))
        .snappyShadow()
        
        // Order details view
        .sheet(isPresented: $orderDetailsViewModel.showDetailsView) {
            OrderDetailsView(viewModel: orderDetailsViewModel, orderSummaryCardViewModel: viewModel)
        }
    }
    
    // MARK: - Store logo
    
    @ViewBuilder private var storeLogoView: some View {
        if let logoURL = viewModel.storeLogoURL {
            RemoteImageView(viewModel: .init(container: viewModel.container, imageURL: logoURL))
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
    
    // MARK: - Delivery status view
    
    private var deliveryStatusView: some View {
        HStack {
            Text(viewModel.status)
                .font(.snappyCaption)
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .padding(.vertical, Constants.DeliveryStatus.vPadding)
                .padding(.horizontal, Constants.DeliveryStatus.hPadding)
                .background(viewModel.statusType == .error ? Color.snappyRed : viewModel.statusType == .success ? Color.green : Color.snappyBlue)
                .clipShape(RoundedRectangle(cornerRadius: Constants.DeliveryStatus.cornerRadiung))
            
            Spacer()
            
            (viewModel.fulfilmentType == .delivery ? Image.Checkout.delivery : Image.Tabs.basket)
                .foregroundColor(.snappyBlue)
                .font(.system(size: Constants.DeliveryStatus.deliveryIconSize))
        }
    }
    
    // MARK: - Order total view
    
    private var orderTotalView: some View {
        VStack(alignment: .leading) {
            
            Text(SummaryStrings.total.localized)
                .font(.snappyCaption)
                .foregroundColor(.snappyTextGrey2)
            
            Text(viewModel.orderTotal)
                .font(.snappyBody2)
                .fontWeight(.semibold)
                .foregroundColor(.snappyBlue)
        }
        .font(.snappyBody)
    }
    
    // MARK: - View order button
    
    private var viewOrderButton: some View {
        Button {
            orderDetailsViewModel.showDetailsView = true
        } label: {
            Text(SummaryStrings.view.localized)
                .font(.snappyCaption)
                .fontWeight(.semibold)
        }
        .buttonStyle((SnappySecondaryButtonStyle()))
    }
    
    // MARK: - Order total stack
    
    private var orderTotalStack: some View {
        HStack {
            orderTotalView
            Spacer()
            viewOrderButton
        }
    }
    
    // MARK: - Order summary stack
    
    private var orderSummaryView: some View {
        VStack(alignment: .leading) {
            deliveryStatusView
            Text(viewModel.selectedSlot)
                .font(.snappyBody2)
                .fontWeight(.semibold)
                .foregroundColor(.snappyBlue)
            ProgressBarView(value: viewModel.order.orderProgress, maxValue: 1, backgroundColor: .snappyBGFields1, foregroundColor: viewModel.statusType == .success ? .green : viewModel.statusType == .error ? .snappyRed : .snappyBlue)
                .frame(height: Constants.ProgressBar.height)
            orderTotalStack
        }
    }
}

struct OrderSummaryCard_Previews: PreviewProvider {
    static var previews: some View {
        OrderSummaryCard(container: .preview, order:  PlacedOrder(
            id: 1963404,
            businessOrderId: 2106,
            status: "Store Accepted / Picking",
            statusText: "store_accepted_picking",
            totalPrice: 11.25,
            totalDiscounts: 0,
            totalSurcharge: 0.58999999999999997,
            totalToPay: 13.09,
            platform: "ios",
            firstOrder: true,
            createdAt: "2022-02-23 10:35:10",
            updatedAt: "2022-02-23 10:35:10",
            store: PlacedOrderStore(
                id: 910,
                name: "Master Testtt",
                originalStoreId: nil,
                storeLogo: [
                    "mdpi_1x": URL(string: "https://www.snappyshopper.co.uk/uploads/images/stores/mdpi_1x/1589564824552274_13470292_2505971_9c972622_image.png")!,
                    "xhdpi_2x": URL(string: "https://www.snappyshopper.co.uk/uploads/images/stores/xhdpi_2x/1589564824552274_13470292_2505971_9c972622_image.png")!,
                    "xxhdpi_3x": URL(string: "https://www.snappyshopper.co.uk/uploads/images/stores/xxhdpi_3x/1589564824552274_13470292_2505971_9c972622_image.png")!
                ],
                address1: "Gallanach Rd",
                address2: nil,
                town: "Oban",
                postcode: "PA34 4PD",
                telephone: "07986238097",
                latitude: 56.4087526,
                longitude: -5.4875930999999998
            ),
            fulfilmentMethod: PlacedOrderFulfilmentMethod(
                name: RetailStoreOrderMethodType.delivery,
                processingStatus: "Store Accepted / Picking",
                datetime: PlacedOrderFulfilmentMethodDateTime(
                    requestedDate: "2022-02-18",
                    requestedTime: "17:40 - 17:55",
                    estimated: Date(timeIntervalSince1970: 1632146400),
                    fulfilled: nil
                ),
                place: nil,
//                address: nil,
                driverTip: 1.5,
                refund: nil,
                deliveryCost: 1,
                driverTipRefunds: nil
            ),
            paymentMethod: PlacedOrderPaymentMethod(
                name: "realex",
                dateTime: "2022-02-18 "
            ),
            orderLines: [PlacedOrderLine(
                id: 12136536,
                substitutesOrderLineId: nil,
                quantity: 12,
                rewardPoints: nil,
                pricePaid: 10,
                discount: 0,
                substitutionAllowed: nil,
                customerInstructions: nil,
                rejectionReason: nil,
                item: PastOrderLineItem(
                    id: 3206126,
                    name: "Max basket quantity 10",
                    images: [
                        [
                            "mdpi_1x": URL(string: "https://www.snappyshopper.co.uk/uploads/images/stores/mdpi_1x/1486738973default.png")!,
                            "xhdpi_2x": URL(string: "https://www.snappyshopper.co.uk/uploads/images/stores/xhdpi_2x/1486738973default.png")!,
                            "xxhdpi_3x": URL(string: "https://www.snappyshopper.co.uk/uploads/images/stores/xxhdpi_3x/1486738973default.png")!
                        ]
                    ],
                    price: 10
                )
            ), PlacedOrderLine(
                id: 12136526,
                substitutesOrderLineId: nil,
                quantity: 12,
                rewardPoints: nil,
                pricePaid: 10,
                discount: 0,
                substitutionAllowed: nil,
                customerInstructions: nil,
                rejectionReason: nil,
                item: PastOrderLineItem(
                    id: 3206126,
                    name: "Max basket quantity 10",
                    images: [
                        [
                            "mdpi_1x": URL(string: "https://www.snappyshopper.co.uk/uploads/images/stores/mdpi_1x/1486738973default.png")!,
                            "xhdpi_2x": URL(string: "https://www.snappyshopper.co.uk/uploads/images/stores/xhdpi_2x/1486738973default.png")!,
                            "xxhdpi_3x": URL(string: "https://www.snappyshopper.co.uk/uploads/images/stores/xxhdpi_3x/1486738973default.png")!
                        ]
                    ],
                    price: 10
                )
            )],
            customer: PlacedOrderCustomer(
                firstname: "Kevin",
                lastname: "Palser"
            ),
            discount: [PlacedOrderDiscount(
                name: "Multi Buy Example",
                amount: 0.4,
                type: "nforn",
                lines: [12136536]
            )],
            surcharges: [PlacedOrderSurcharge(
                name: "Service Charge",
                amount: 0.09
            )],
            loyaltyPoints: PlacedOrderLoyaltyPoints(
                type: "refer",
                name: "Friend Reward Discount",
                deductCost: 0
            ),
            coupon: PlacedOrderCoupon(
                title: "Test % Coupon",
                couponDeduct: 1.83,
                type: "percentage",
                freeDelivery: false,
                value: 1.83,
                iterableCampaignId: 0,
                percentage: 10,
                registeredMemberRequirement: false
            )
        ))
    }
}
