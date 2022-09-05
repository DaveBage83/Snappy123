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
    
    // MARK: - Constants
    
    struct Constants {
        struct Main {
            static let vSpacing: CGFloat = 20
            static let padding: CGFloat = 30
        }
        
        struct DragCapsule {
            static let width: CGFloat = 35
            static let height: CGFloat = 5
        }
        
        struct ProgressBar {
            static let height: CGFloat = 6
        }
        
        struct DeliveryInfo {
            static let hStackSpacing: CGFloat = 13
        }
        
        struct RepeatOrderButton {
            static let padding: CGFloat = 8
        }
    }
    
    // MARK: - View models
    
    @StateObject var viewModel: OrderDetailsViewModel
    @ObservedObject var orderSummaryCardViewModel: OrderSummaryCardViewModel
    
    // MARK: - Main body
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: Constants.Main.vSpacing) {
                    headerView
                    
                    orderNumberView
                    progressBarView
                    orderSummaryView
                    
                    OrderStoreView(viewModel: .init(container: viewModel.container, store: viewModel.order.store))
                    
                    OrderListView(viewModel: .init(container: viewModel.container, orderLines: viewModel.order.orderLines))
                    
                    orderTotalizerView
                    
                    if viewModel.showTrackOrderButton {
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
                .padding(Constants.Main.padding)
                .navigationBarHidden(true)
                
                NavigationLink("", isActive: $viewModel.showDriverMap) {
                    if let driverLocation = viewModel.driverLocation {
                        DriverMapView(viewModel: .init(
                            container: viewModel.container,
                            mapParameters: DriverLocationMapParameters(
                                businessOrderId: viewModel.order.businessOrderId,
                                driverLocation: driverLocation,
                                lastDeliveryOrder: nil,
                                placedOrder: viewModel.order),
                            dismissDriverMapHandler: {
                                viewModel.driverMapDismissAction()
                            }))
                    }
                }
            }
            .withStandardAlert(
                container: viewModel.container,
                isPresenting: $viewModel.showMapError,
                type: .error,
                title: Strings.DriverMap.Error.title.localized,
                subtitle: Strings.DriverMap.Error.body.localized)
        }
        .onAppear {
            viewModel.onAppearSendEvent()
        }
    }
    
    // MARK: - Header with drag capsule
    
    private var headerView: some View {
        HStack {
            Spacer()
            Capsule()
                .fill(Color.secondary)
                .frame(width: Constants.DragCapsule.width, height: Constants.DragCapsule.height)
            Spacer()
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
                .font(.snappyCaption)
                .foregroundColor(.snappyTextGrey1)
            Spacer()
            Text(viewModel.orderNumber)
                .font(.snappyCaption)
                .foregroundColor(.snappyDark)
                .fontWeight(.semibold)
        }
    }
    
    // MARK: - Order progress view display
    
    private var progressBarView: some View {
        ProgressBarView(value: viewModel.order.orderProgress, maxValue: 1, foregroundColor: orderSummaryCardViewModel.statusType == .success ? .green : orderSummaryCardViewModel.statusType == .error ? .snappyRed : .snappyBlue)
            .frame(height: Constants.ProgressBar.height)
    }
    
    // MARK: - Order summary - delivery info + order total details
    
    private var orderSummaryView: some View {
        HStack {
            deliveryInfoView
            
            Spacer()
            
            VStack(alignment: .trailing) {
                Text(OrderDetailsStrings.orderTotal.localized)
                    .font(.snappyCaption)
                    .foregroundColor(.snappyTextGrey1)
                Text("\(viewModel.numberOfItems) | \(viewModel.subTotal)")
                    .font(.snappyCaption)
                    .foregroundColor(.snappyBlue)
                    .fontWeight(.semibold)
            }
        }
    }
    
    // MARK: - Delivery info
    
    private var deliveryInfoView: some View {
        HStack(spacing: Constants.DeliveryInfo.hStackSpacing) {
            if viewModel.order.fulfilmentMethod.name == .delivery {
                Image.Checkout.delivery
                    .foregroundColor(.snappyBlue)
            } else if viewModel.order.fulfilmentMethod.name == .collection {
                Image.Tabs.basket
                    .foregroundColor(.snappyBlue)
            }
            
            VStack(alignment: .leading) {
                Text(viewModel.fulfilmentMethod)
                    .font(.snappyCaption)
                    .foregroundColor(.snappyTextGrey1)
                
                HStack {
                    Text(orderSummaryCardViewModel.selectedSlot ?? "")
                        .font(.snappyCaption)
                        .foregroundColor(.snappyBlue)
                        .fontWeight(.semibold)
                }
            }
        }
    }
    
    // MARK: - Order totalizer
    
    private var orderTotalizerView: some View {
        VStack {
            orderTotalizerLine(title: OrderDetailsStrings.orderSubtotal.localized, price: viewModel.subTotal)
            
            ForEach(viewModel.displayableSurcharges) { surcharge in
                orderTotalizerLine(title: surcharge.name, price: surcharge.amount)
            }
            
            if let deliveryCostPriceString = viewModel.deliveryCostPriceString {
                orderTotalizerLine(title: OrderDetailsStrings.deliveryFee.localized, price: deliveryCostPriceString)
            }
            
            if let driverTipPriceString = viewModel.driverTipPriceString {
                orderTotalizerLine(title: OrderDetailsStrings.driverTip.localized, price: driverTipPriceString)
            }
            
            orderTotalizerLine(title: OrderDetailsStrings.orderTotal.localized, price: viewModel.totalToPay, isTotal: true)
        }
    }
    
    // MARK: - Order totalizer line creation
    
    private func orderTotalizerLine(title: String, price: String, isTotal: Bool = false) -> some View {
        VStack {
            HStack {
                Text(title)
                    .font(.snappyBody2)
                    .fontWeight(isTotal ? .bold : .regular)
                Spacer()
                Text(price)
                    .font(.snappyBody2)
                    .fontWeight(isTotal ? .bold : .regular)
            }
            
            Divider()
        }
    }
}

#if DEBUG
struct OrderDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        OrderDetailsView(viewModel: .init(
            container: .preview,
            order: PlacedOrder(
                id: 1963404,
                businessOrderId: 2106,
                status: "Store Accepted / Picking",
                statusText: "store_accepted_picking",
                totalPrice: 11.25,
                totalDiscounts: 0,
                totalSurcharge: 0.58999999999999997,
                totalToPay: 13.09,
                platform: AppV2Constants.Client.platform,
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
                    address: nil,
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
             )),
                         orderSummaryCardViewModel: .init(
                            container: .preview,
                            order: PlacedOrder(
                                id: 1963404,
                                businessOrderId: 2106,
                                status: "Store Accepted / Picking",
                                statusText: "en_route",
                                totalPrice: 11.25,
                                totalDiscounts: 0,
                                totalSurcharge: 0.58999999999999997,
                                totalToPay: 13.09,
                                platform: AppV2Constants.Client.platform,
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
                                    address: nil,
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
                            ), basket: nil))
        
    }
}
#endif
