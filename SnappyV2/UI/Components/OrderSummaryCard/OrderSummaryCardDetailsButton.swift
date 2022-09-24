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

#if DEBUG
struct OrderSummaryCardDetailsButton_Previews: PreviewProvider {
    static var previews: some View {
        OrderSummaryCardDetailsButton(viewModel: .init(container: .preview, order:   PlacedOrder(
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
                    size: nil,
                    options: nil
                ), refundAmount: 0,
                storeNote: nil
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
                    size: nil,
                    options: nil
                ), refundAmount: 0,
                storeNote: nil
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
            currency: .init(currencyCode: "GBP", symbol: "&pound;", ratio: 0, symbolChar: "£", name: "Great British Pound"),
            totalOrderValue: 20,
            totalRefunded: 0
        )), orderSummaryCardViewModel: .init(container: .preview, order: nil, basket: nil))
    }
}
#endif
