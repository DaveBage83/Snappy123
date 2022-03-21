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
    }
    
    @ObservedObject var viewModel: MemberDashboardHomeViewModel
    
    var body: some View {
        VStack(spacing: Constants.vSpacing) {
            if viewModel.hasPastOrders, let orders = viewModel.pastOrders {
                ForEach(orders, id: \.id) { order in
                    OrderSummaryCard(viewModel: .init(container: viewModel.container, order: order))
                }
            } else {
                Text(Strings.MemberDashboard.Orders.noOrders.localized)
            }
            ClipboardReferralCodeField(viewModel: .init(code: viewModel.referralCode))
        }
        .padding()
    }
}

struct DashboardHomeView_Previews: PreviewProvider {
    static var previews: some View {
        DashboardHomeView(viewModel: .init(container: .preview, profile: MemberProfile(firstname: "Alan", lastname: "Shearer", emailAddress: "alan.shearer@nufc.com", type: .customer, referFriendCode: "ALANSHEARER2022", referFriendBalance: 5.0, numberOfReferrals: 0, mobileContactNumber: "08893939383", mobileValidated: false, acceptedMarketing: false, defaultBillingDetails: nil, savedAddresses: nil, fetchTimestamp: nil)))
    }
}

#warning("To remove once getPastOrders call is fixed from backend, we can use this for now to mock past orders")

struct TestPastOrder {
    static let order =
        PastOrder(
            id: 123,
            businessOrderId: 123,
            status: "Sent to store",
            store: PastOrderStore(
                id: 123,
                name: "Shearer's store",
                originalStoreId: 123,
                storeLogo: nil,
                address1: "Test Store 1",
                address2: nil,
                town: "Newcastle",
                postcode: "NCL 123",
                telephone: "08897829304",
                lat: 1,
                lng: 1),
            fulfilmentMethod: PastOrderFulfilmentMethod(
                name: .delivery,
                processingStatus: "Done",
                datetime: PastOrderFulfilmentMethodDateTime(
                    requestedDate: "01-01-22",
                    requestedTime: "09:01",
                    estimated: "09:01",
                    fulfilled: "yes"),
                place: nil,
                address: nil,
                driverTip: 0,
                refund: 0,
                cost: 23.40,
                driverTipRefunds: nil),
            createdAt: "",
            updatedAt: "",
            totalPrice: 23.40,
            totalDiscounts: 0,
            totalSurcharge: nil,
            totalToPay: nil,
            orderLines: [
            PastOrderLine(
                id: 123,
                item: PastOrderLineItem(
                    id: 123,
                    name: "Newcastle Brown Ale",
                    image: nil,
                    price: 10.40),
                quantity: 1,
                rewardPoints: 0,
                pricePaid: 10.4,
                discount: 0,
                substitutionAllowed: false)
            ],
            customer: PastOrderCustomer(firstname: "Alan", lastname: "Shearer"),
            discount: nil,
            surcharges: nil,
            loyaltyPoints: nil)
}

struct TestPastOrder_2 {
    static let order =
        PastOrder(
            id: 222,
            businessOrderId: 123,
            status: "Awaiting collection",
            store: PastOrderStore(
                id: 123,
                name: "Dave's Store",
                originalStoreId: 123,
                storeLogo: nil,
                address1: "Test Store 1",
                address2: nil,
                town: "Newcastle",
                postcode: "NCL 123",
                telephone: "08897829304",
                lat: 1,
                lng: 1),
            fulfilmentMethod: PastOrderFulfilmentMethod(
                name: .collection,
                processingStatus: "Done",
                datetime: PastOrderFulfilmentMethodDateTime(
                    requestedDate: "03-02-22",
                    requestedTime: "10:44",
                    estimated: "0:44",
                    fulfilled: "yes"),
                place: nil,
                address: nil,
                driverTip: 0,
                refund: 0,
                cost: 23.40,
                driverTipRefunds: nil),
            createdAt: "",
            updatedAt: "",
            totalPrice: 10.24,
            totalDiscounts: 0,
            totalSurcharge: nil,
            totalToPay: nil,
            orderLines: [
            PastOrderLine(
                id: 123,
                item: PastOrderLineItem(
                    id: 123,
                    name: "Newcastle Brown Ale",
                    image: nil,
                    price: 10.40),
                quantity: 1,
                rewardPoints: 0,
                pricePaid: 10.4,
                discount: 0,
                substitutionAllowed: false)
            ],
            customer: PastOrderCustomer(firstname: "Alan", lastname: "Shearer"),
            discount: nil,
            surcharges: nil,
            loyaltyPoints: nil)
}
