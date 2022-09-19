//
//  OrderListItemView.swift
//  SnappyV2
//
//  Created by David Bage on 05/04/2022.
//

import SwiftUI

struct OrderListView: View {
    struct Constants {
        static let spacing: CGFloat = 14
    }
    
    @StateObject var viewModel: OrderListViewModel
    
    var body: some View {
        VStack(spacing: Constants.spacing) {
            ForEach(viewModel.groupedOrderLines, id: \.self) { orderLineGroups in
                OrderLine(viewModel: .init(container: viewModel.container, orderLines: orderLineGroups, currency: viewModel.currency))
            }
        }
    }
}

#if DEBUG
struct OrderListItemView_Previews: PreviewProvider {
    static var previews: some View {
        OrderListView(viewModel: .init(
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
                    address1: "Gallanach Rd sdssd sdsd s sd sdsdsd sdsd",
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
                        price: 10,
                        size: nil
                    ), refundAmount: 0
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
                        price: 10,
                        size: nil
                    ), refundAmount: 0
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
                ),
                currency: .init(currencyCode: "GBP", symbol: "&pound;", ratio: 0, symbolChar: "£", name: "Great British Pound")
            )
        ))
    }
}
#endif
