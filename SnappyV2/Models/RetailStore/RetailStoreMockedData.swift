//
//  RetailStoreMockedData.swift
//  SnappyV2
//
//  Created by Kevin Palser on 26/09/2021.
//

import Foundation

#if DEBUG

extension RetailStoresSearch {
    // just one entry because normally dealing with a single result
    static let mockedData = RetailStoresSearch(
        storeProductTypes: RetailStoreProductType.mockedData,
        stores: RetailStore.mockedData,
        postcode: nil,
        latitude: nil,
        longitude: nil
    )
}

extension RetailStoreProductType {
    static let mockedData: [RetailStoreProductType] = [
        RetailStoreProductType(
            id: 21,
            name: "Convenience Stores",
            image: [
                "mdpi_1x": URL(string: "https://www.snappyshopper.co.uk/uploads/images/store_types_full_width/mdpi_1x/1613754190stores.png")!,
                "xhdpi_2x": URL(string: "https://www.snappyshopper.co.uk/uploads/images/store_types_full_width/xhdpi_2x/1613754190stores.png")!,
                "xxhdpi_3x": URL(string: "https://www.snappyshopper.co.uk/uploads/images/store_types_full_width/xxhdpi_3x/1613754190stores.png")!
            ]
        ),
        RetailStoreProductType(
            id: 32,
            name: "Greengrocers",
            image: [
                "mdpi_1x": URL(string: "https://www.snappyshopper.co.uk/uploads/images/store_types_half_width/mdpi_1x/1613754280greengrocers.png")!,
                "xhdpi_2x": URL(string: "https://www.snappyshopper.co.uk/uploads/images/store_types_half_width/xhdpi_2x/1613754280greengrocers.png")!,
                "xxhdpi_3x": URL(string: "https://www.snappyshopper.co.uk/uploads/images/store_types_half_width/xxhdpi_3x/1613754280greengrocers.png")!
            ]
        )
    ]
}

extension RetailStore {
    static let mockedData: [RetailStore] = [
        RetailStore(
            id: 1944,
            storeName: "Premier Nethergate",
            distance: 0.579,
            storeLogo: [
                "mdpi_1x": URL(string: "https://www.snappyshopper.co.uk/uploads/mobile_app_images/mdpi_1x/14867386811484320803snappy_store_logo.png")!,
                "xhdpi_2x": URL(string: "https://www.snappyshopper.co.uk/uploads/mobile_app_images/xhdpi_2x/14867386811484320803snappy_store_logo.png")!,
                "xxhdpi_3x": URL(string: "https://www.snappyshopper.co.uk/uploads/mobile_app_images/xxhdpi_3x/14867386811484320803snappy_store_logo.png")!
            ],
            storeProductTypes: [21],
            orderMethods: [
                "delivery" : RetailStoreOrderMethod(
                    name: .delivery,
                    earliestTime: "13:20 - 14:20",
                    status: .open,
                    cost: 5.0,
                    fulfilmentIn: "6 to 66 mins"
                ),
                "collection" : RetailStoreOrderMethod(
                    name: .collection,
                    earliestTime: "13:15 - 13:20",
                    status: .open,
                    cost: 0,
                    fulfilmentIn: "1 to 6 mins"
                )
            ]
        ),
        RetailStore(
            id: 1414,
            storeName: "Polish Deli Kubus",
            distance: 0.849,
            storeLogo: [
                "mdpi_1x": URL(string: "https://www.snappyshopper.co.uk/uploads/images/stores/mdpi_1x/1599144659Untitleddesign20200903T155045.296.png")!,
                "xhdpi_2x": URL(string: "https://www.snappyshopper.co.uk/uploads/images/stores/xhdpi_2x/1599144659Untitleddesign20200903T155045.296.png")!,
                "xxhdpi_3x": URL(string: "https://www.snappyshopper.co.uk/uploads/images/stores/xxhdpi_3x/1599144659Untitleddesign20200903T155045.296.png")!
            ],
            storeProductTypes: [21],
            orderMethods: [
                "delivery" : RetailStoreOrderMethod(
                    name: .delivery,
                    earliestTime: "13:45 - 14:00",
                    status: .open,
                    cost: 3.0,
                    fulfilmentIn: "31 to 46 mins"
                )
            ]
        ),
        RetailStore(
            id: 1807,
            storeName: "SPAR Perth Road",
            distance: 1.439,
            storeLogo: [
                "mdpi_1x": URL(string: "https://www.snappyshopper.co.uk/uploads/images/stores/mdpi_1x/1605800838sparlogo.png")!,
                "xhdpi_2x": URL(string: "https://www.snappyshopper.co.uk/uploads/images/stores/xhdpi_2x/1605800838sparlogo.png")!,
                "xxhdpi_3x": URL(string: "https://www.snappyshopper.co.uk/uploads/images/stores/xxhdpi_3x/1605800838sparlogo.png")!
            ],
            storeProductTypes: [21],
            orderMethods: [
                "delivery" : RetailStoreOrderMethod(
                    name: .delivery,
                    earliestTime: "13:45 - 14:00",
                    status: .open,
                    cost: 1.0,
                    fulfilmentIn: "31 to 46 min"
                ),
                "collection" : RetailStoreOrderMethod(
                    name: .collection,
                    earliestTime: nil,
                    status: .closed,
                    cost: 0,
                    fulfilmentIn: nil
                )
            ]
        )
    ]
}

#endif
