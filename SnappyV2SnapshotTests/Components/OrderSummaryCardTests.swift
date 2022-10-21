//
//  OrderSummaryCardTests.swift
//  SnappyV2SnapshotTests
//
//  Created by David Bage on 15/05/2022.
//

import XCTest
import SwiftUI
@testable import SnappyV2

class OrderSummaryCardTests: XCTestCase {
    func _testinit() {
        let sut = makeSUT()
        let iPhone12Snapshot = sut.snapshot(for: .iPhone12(style: .light))
        let iPad8thGenSnapshot = sut.snapshot(for: .iPad8thGen(style: .light))
        
        assert(snapshot: iPhone12Snapshot, sut: sut)
        assert(snapshot: iPad8thGenSnapshot, sut: sut)
    }
    
    func makeSUT() -> OrderSummaryCard {
        OrderSummaryCard(
            container: .preview,
            order: .init(
                id: 1963404,
                businessOrderId: 2106,
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
                status: "Store Accepted / Picking",
                statusText: "store_accepted_picking",
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
                totalPrice: 11.25),
            basket: nil)
    }
}
