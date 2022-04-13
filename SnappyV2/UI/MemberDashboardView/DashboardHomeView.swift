//
//  DashboardHomeView.swift
//  SnappyV2
//
//  Created by David Bage on 18/03/2022.
//

import SwiftUI
import Combine

struct DashboardHomeView: View {
    struct Constants {
        static let vSpacing: CGFloat = 20
        static let loadingViewHeight: CGFloat = 200
    }
    
    @ObservedObject var viewModel: MemberDashboardHomeViewModel
    
    var body: some View {
        VStack(spacing: Constants.vSpacing) {
            MemberDashboardOrdersView(viewModel: .init(container: viewModel.container))
            
            ClipboardReferralCodeField(viewModel: .init(code: viewModel.referralCode))
                .padding()
        }
    }
}

struct DashboardHomeView_Previews: PreviewProvider {
    static var previews: some View {
        DashboardHomeView(viewModel: .init(container: .preview))
    }
}

#warning("To remove once getPastOrders call is fixed from backend, we can use this for now to mock past orders")

struct TestPastOrder {
    static let order =
        PlacedOrder(
            id: 123,
            businessOrderId: 123,
            status: "Sent to store",
            statusText: "",
            totalPrice: 23.40,
            totalDiscounts: 0,
            totalSurcharge: nil,
            totalToPay: nil,
            platform: "website",
            firstOrder: true,
            createdAt: "",
            updatedAt: "",
            store: PlacedOrderStore(
                id: 123,
                name: "Shearer's store",
                originalStoreId: 123,
                storeLogo: nil,
                address1: "Test Store 1",
                address2: nil,
                town: "Newcastle",
                postcode: "NCL 123",
                telephone: "08897829304",
                latitude: 1,
                longitude: 1),
            fulfilmentMethod: PlacedOrderFulfilmentMethod(
                name: .delivery,
                processingStatus: "Done",
                datetime: PlacedOrderFulfilmentMethodDateTime(
                    requestedDate: "01-01-22",
                    requestedTime: "09:01",
                    estimated: nil,
                    fulfilled: nil),
                place: nil,
//                address: nil,
                driverTip: 0,
                refund: 0,
                deliveryCost: 1,
//                cost: 23.40,
                driverTipRefunds: nil
            ),
            paymentMethod: PlacedOrderPaymentMethod(
                name: "realex",
                dateTime: "2021-12-20 12:23:05"
            ),
            orderLines: [
            PlacedOrderLine(
                id: 123,
                substitutesOrderLineId: nil,
                quantity: 1,
                rewardPoints: 0,
                pricePaid: 10.4,
                discount: 0,
                substitutionAllowed: false,
                customerInstructions: nil,
                rejectionReason: nil,
                item: PastOrderLineItem(
                    id: 123,
                    name: "Newcastle Brown Ale",
                    images: nil,
                    price: 10.40)
            )
            ],
            customer: PlacedOrderCustomer(firstname: "Alan", lastname: "Shearer"),
            discount: nil,
            surcharges: nil,
            loyaltyPoints: nil,
            coupon: nil
        )
}

struct TestPastOrder_2 {
    static let order =
        PlacedOrder(
            id: 222,
            businessOrderId: 123,
            status: "Awaiting collection",
            statusText: "",
            totalPrice: 10.24,
            totalDiscounts: 0,
            totalSurcharge: nil,
            totalToPay: nil,
            platform: "ios",
            firstOrder: true,
            createdAt: "",
            updatedAt: "",
            store: PlacedOrderStore(
                id: 123,
                name: "Dave's Store",
                originalStoreId: 123,
                storeLogo: nil,
                address1: "Test Store 1",
                address2: nil,
                town: "Newcastle",
                postcode: "NCL 123",
                telephone: "08897829304",
                latitude: 1,
                longitude: 1),
            fulfilmentMethod: PlacedOrderFulfilmentMethod(
                name: .collection,
                processingStatus: "Done",
                datetime: PlacedOrderFulfilmentMethodDateTime(
                    requestedDate: "03-02-22",
                    requestedTime: "10:44",
                    estimated: nil,
                    fulfilled: nil),
                place: nil,
//                address: nil,
                driverTip: 0,
                refund: 0,
                deliveryCost: 1,
//                cost: 23.40,
                driverTipRefunds: nil),
            paymentMethod: PlacedOrderPaymentMethod(
                name: "realex",
                dateTime: "2021-12-20 12:23:05"
            ),
            orderLines: [
            PlacedOrderLine(
                id: 123,
                substitutesOrderLineId: nil,
                quantity: 1,
                rewardPoints: 0,
                pricePaid: 10.4,
                discount: 0,
                substitutionAllowed: false,
                customerInstructions: nil,
                rejectionReason: nil,
                item: PastOrderLineItem(
                    id: 123,
                    name: "Newcastle Brown Ale",
                    images: nil,
                    price: 10.40)
                )
            ],
            customer: PlacedOrderCustomer(firstname: "Alan", lastname: "Shearer"),
            discount: nil,
            surcharges: nil,
            loyaltyPoints: nil,
            coupon: nil)
}
