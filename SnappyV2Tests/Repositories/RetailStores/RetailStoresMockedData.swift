//
//  RetailStoresMockedData.swift
//  SnappyV2
//
//  Created by Kevin Palser on 26/09/2021.
//

import Foundation
@testable import SnappyV2

extension RetailStoresSearch {
    // just one entry because normally dealing with a single result
    static let mockedData = RetailStoresSearch(
        storeProductTypes: RetailStoreProductType.mockedData,
        stores: RetailStore.mockedData,
        fulfilmentLocation: FulfilmentLocation.mockedData
    )
    
    static let mockedDataNoMatchingStores = RetailStoresSearch(
        storeProductTypes: RetailStoreProductType.mockedData,
        stores: nil,
        fulfilmentLocation: FulfilmentLocation.mockedData
    )
    
    static let mockedDataOnlyClosedStores = RetailStoresSearch(
        storeProductTypes: RetailStoreProductType.mockedData,
        stores: RetailStore.mockedDataClosedStores,
        fulfilmentLocation: FulfilmentLocation.mockedData
    )
    
    var recordsCount: Int {
        
        var count = 1
        
        if let storeProductTypes = storeProductTypes {
            for storeProductType in storeProductTypes {
                count += storeProductType.recordsCount
            }
        }
        
        if let stores = stores {
            for store in stores {
                count += store.recordsCount
            }
        }
        
        return count
    }
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
    
    static let mockedDataOne1StoreType: [RetailStoreProductType] = [
        RetailStoreProductType(
            id: 21,
            name: "Convenience Stores",
            image: [
                "mdpi_1x": URL(string: "https://www.snappyshopper.co.uk/uploads/images/store_types_full_width/mdpi_1x/1613754190stores.png")!,
                "xhdpi_2x": URL(string: "https://www.snappyshopper.co.uk/uploads/images/store_types_full_width/xhdpi_2x/1613754190stores.png")!,
                "xxhdpi_3x": URL(string: "https://www.snappyshopper.co.uk/uploads/images/store_types_full_width/xxhdpi_3x/1613754190stores.png")!
            ]
        )
    ]
    
    var recordsCount: Int {
        return 1 + (image?.count ?? 0)
    }
}

extension RetailStoreCurrency {

    static let mockedGBPData = RetailStoreCurrency(
        currencyCode: "GBP",
        symbol: "&pound;",
        ratio: 0,
        symbolChar: "£",
        name: "Great British Pound"
    )

}
    
extension RetailStore {
    
    static func mockedDataWithDeliveryTiers(orderMethod: RetailStoreOrderMethod) -> RetailStore {
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
                "delivery" : orderMethod,
                "collection" : RetailStoreOrderMethod(
                    name: .collection,
                    earliestTime: "13:15 - 13:20",
                    status: .open,
                    cost: 0,
                    fulfilmentIn: "1 to 6 mins",
                    freeFulfilmentMessage: nil,
                    deliveryTiers: nil,
                    freeFrom: 0,
                    minSpend: 0
                )
            ],
            ratings: RetailStoreRatings(averageRating: 4.8, numRatings: 375),
            currency: RetailStoreCurrency.mockedGBPData
        )
    }
    
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
                    fulfilmentIn: "6 to 66 mins",
                    freeFulfilmentMessage: nil,
                    deliveryTiers: nil,
                    freeFrom: 0,
                    minSpend: 0
                ),
                "collection" : RetailStoreOrderMethod(
                    name: .collection,
                    earliestTime: "13:15 - 13:20",
                    status: .open,
                    cost: 0,
                    fulfilmentIn: "1 to 6 mins",
                    freeFulfilmentMessage: nil,
                    deliveryTiers: nil,
                    freeFrom: 0,
                    minSpend: 0
                )
            ],
            ratings: RetailStoreRatings(averageRating: 4.8, numRatings: 375),
            currency: RetailStoreCurrency.mockedGBPData
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
                    fulfilmentIn: "31 to 46 mins",
                    freeFulfilmentMessage: nil,
                    deliveryTiers: nil,
                    freeFrom: 0,
                    minSpend: 0
                )
            ],
            ratings: nil,
            currency: RetailStoreCurrency.mockedGBPData
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
                    fulfilmentIn: "31 to 46 min",
                    freeFulfilmentMessage: nil,
                    deliveryTiers: nil,
                    freeFrom: 0,
                    minSpend: 0
                ),
                "collection" : RetailStoreOrderMethod(
                    name: .collection,
                    earliestTime: nil,
                    status: .closed,
                    cost: 0,
                    fulfilmentIn: nil,
                    freeFulfilmentMessage: nil,
                    deliveryTiers: nil,
                    freeFrom: 0,
                    minSpend: 0
                )
            ],
            ratings: nil,
            currency: RetailStoreCurrency.mockedGBPData
        ),
        RetailStore(
            id: 910,
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
                    fulfilmentIn: "31 to 46 mins",
                    freeFulfilmentMessage: nil,
                    deliveryTiers: nil,
                    freeFrom: 0,
                    minSpend: 0
                )
            ],
            ratings: nil,
            currency: RetailStoreCurrency.mockedGBPData
        ),
    ]
    
    static let mockedDataIndividualStoreNoDelivery: RetailStore = .init(
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
            "collection" : RetailStoreOrderMethod(
                name: .collection,
                earliestTime: "13:15 - 13:20",
                status: .closed,
                cost: 0,
                fulfilmentIn: "1 to 6 mins",
                freeFulfilmentMessage: nil,
                deliveryTiers: nil,
                freeFrom: 0,
                minSpend: 0
            )
        ],
        ratings: RetailStoreRatings(averageRating: 4.8, numRatings: 375),
        currency: RetailStoreCurrency.mockedGBPData
    )
    
    static let mockedDataIndividualStoreWithNoDeliveryOffer: RetailStore = .init(
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
                name: .collection,
                earliestTime: "13:15 - 13:20",
                status: .closed,
                cost: 0,
                fulfilmentIn: "1 to 6 mins",
                freeFulfilmentMessage: nil,
                deliveryTiers: nil,
                freeFrom: 0,
                minSpend: 0
            )
        ],
        ratings: RetailStoreRatings(averageRating: 4.8, numRatings: 375),
        currency: RetailStoreCurrency.mockedGBPData
    )
    
    static let mockedDataIndividualStoreWithDeliveryOffer: RetailStore = .init(
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
                name: .collection,
                earliestTime: "13:15 - 13:20",
                status: .closed,
                cost: 0,
                fulfilmentIn: "1 to 6 mins",
                freeFulfilmentMessage: "Test",
                deliveryTiers: nil,
                freeFrom: 0,
                minSpend: 0
            )
        ],
        ratings: RetailStoreRatings(averageRating: 4.8, numRatings: 375),
        currency: RetailStoreCurrency.mockedGBPData
    )
    
    static let mockedDataIndividualStoreWithNilSpend: RetailStore = .init(
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
                name: .collection,
                earliestTime: "13:15 - 13:20",
                status: .closed,
                cost: 0,
                fulfilmentIn: "1 to 6 mins",
                freeFulfilmentMessage: "Test",
                deliveryTiers: nil,
                freeFrom: 0,
                minSpend: nil
            )
        ],
        ratings: RetailStoreRatings(averageRating: 4.8, numRatings: 375),
        currency: RetailStoreCurrency.mockedGBPData
    )
    
    static let mockedDataIndividualStoreWithZeroSpend: RetailStore = .init(
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
                name: .collection,
                earliestTime: "13:15 - 13:20",
                status: .closed,
                cost: 0,
                fulfilmentIn: "1 to 6 mins",
                freeFulfilmentMessage: "Test",
                deliveryTiers: nil,
                freeFrom: 0,
                minSpend: 0
            )
        ],
        ratings: RetailStoreRatings(averageRating: 4.8, numRatings: 375),
        currency: RetailStoreCurrency.mockedGBPData
    )
    
    static let mockedDataIndividualStoreWithMinSpend: RetailStore = .init(
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
                name: .collection,
                earliestTime: "13:15 - 13:20",
                status: .closed,
                cost: 0,
                fulfilmentIn: "1 to 6 mins",
                freeFulfilmentMessage: "Test",
                deliveryTiers: nil,
                freeFrom: 0,
                minSpend: 10
            )
        ],
        ratings: RetailStoreRatings(averageRating: 4.8, numRatings: 375),
        currency: RetailStoreCurrency.mockedGBPData
    )
    
    static let mockedDataClosedStores: [RetailStore] = [
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
                    status: .closed,
                    cost: 5.0,
                    fulfilmentIn: "6 to 66 mins",
                    freeFulfilmentMessage: nil,
                    deliveryTiers: nil,
                    freeFrom: 0,
                    minSpend: 0
                ),
                "collection" : RetailStoreOrderMethod(
                    name: .collection,
                    earliestTime: "13:15 - 13:20",
                    status: .closed,
                    cost: 0,
                    fulfilmentIn: "1 to 6 mins",
                    freeFulfilmentMessage: nil,
                    deliveryTiers: nil,
                    freeFrom: 0,
                    minSpend: 0
                )
            ],
            ratings: RetailStoreRatings(averageRating: 4.8, numRatings: 375),
            currency: RetailStoreCurrency.mockedGBPData
        ),
        RetailStore(
            id: 910,
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
                    status: .closed,
                    cost: 3.0,
                    fulfilmentIn: "31 to 46 mins",
                    freeFulfilmentMessage: nil,
                    deliveryTiers: nil,
                    freeFrom: 0,
                    minSpend: 0
                )
            ],
            ratings: nil,
            currency: RetailStoreCurrency.mockedGBPData
        )
    ]
    
    var recordsCount: Int {
        // note that storeProductTypes is not counted because the entries generated
        // based on the same records within RetailStoresSearch.storeProductTypes
        return 1 + (storeLogo?.count ?? 0) + (orderMethods?.count ?? 0) + (ratings != nil ? 1 : 0)
    }
}

extension RetailStoreDetails {
    static var mockedData: RetailStoreDetails {
        
        let fulfilmentDay1 = RetailStoreFulfilmentDay(
            date: "2021-10-12",
            holidayMessage: nil,
            start: "09:30:00",
            end: "22:30:00",
            storeDateStart: nil,
            storeDateEnd: nil
        )

        let fulfilmentDay2 = RetailStoreFulfilmentDay(
            date: "2021-10-13",
            holidayMessage: nil,
            start: "09:30:00",
            end: "22:30:00",
            storeDateStart: nil,
            storeDateEnd: nil
        )
        
        return RetailStoreDetails(
            id: 1569,//30,
            menuGroupId: 1218,//30,
            storeName: "Family Shopper Lochee",
            telephone: "01382621132",
            lat: 56.473358599999997,
            lng: -3.0111853000000002,
            ordersPaused: false,
            canDeliver: true,
            distance: 0,
            pausedMessage: "Delivery drivers are delayed due to the snow - we will be open again shortly - try again in 30 minutes. Thank you for your patience!",
            address1: "163-165 High Street",
            address2: nil,
            town: "Dundee",
            postcode: "DD2 3DB",
            customerOrderNotePlaceholder: "Please enter any instructions for the store or driver.",
            memberEmailCheck: false,
            guestCheckoutAllowed: true,
            basketOnlyTimeSelection: false,
            ratings: RetailStoreRatings(averageRating: 4.8, numRatings: 379),
            tips: [
                RetailStoreTip(
                    enabled: true,
                    defaultValue: 1.0,
                    type: "driver",
                    refundDriverTipsForLateOrders: false,
                    refundDriverTipsAfterLateByMinutes: 0
                )
            ],
            storeLogo: [
                "mdpi_1x": URL(string: "https://www.snappyshopper.co.uk/uploads/images/stores/mdpi_1x/1581190214Barassie3.png")!,
                "xhdpi_2x": URL(string: "https://www.snappyshopper.co.uk/uploads/images/stores/xhdpi_2x/1581190214Barassie3.png")!,
                "xxhdpi_3x": URL(string: "https://www.snappyshopper.co.uk/uploads/images/stores/xxhdpi_3x/1581190214Barassie3.png")!
            ],
            storeProductTypes: [21, 32],
            orderMethods: [
                "delivery" : RetailStoreOrderMethod(
                    name: .delivery,
                    earliestTime: "11:30 - 11:45",
                    status: .open,
                    cost: 3.5,
                    fulfilmentIn: "2 hour(s)",
                    freeFulfilmentMessage: nil,
                    deliveryTiers: nil,
                    freeFrom: 0,
                    minSpend: 0
                ),
                "collection" : RetailStoreOrderMethod(
                    name: .collection,
                    earliestTime: "11:00 - 11:05",
                    status: .open,
                    cost: 0,
                    fulfilmentIn: "1 hour(s)",
                    freeFulfilmentMessage: nil,
                    deliveryTiers: nil,
                    freeFrom: 0,
                    minSpend: 0
                )
            ],
            deliveryDays: [
                fulfilmentDay1,
                fulfilmentDay2
            ],
            collectionDays: [
                fulfilmentDay1,
                fulfilmentDay2
            ],
            paymentMethods: [
                PaymentMethod.mockedCashData,
                PaymentMethod.mockedApplePayData,
                PaymentMethod.mockedCardsData
            ],
            paymentGateways: [
                PaymentGateway.mockedWorldpayData,
                PaymentGateway.mockedStripeData,
                PaymentGateway.mockedRealexData
            ], allowedMarketingChannels: [
                AllowedMarketingChannel(id: 123, name: "Facebook")
            ],
            timeZone: "Europe/London",
            currency: RetailStoreCurrency.mockedGBPData,
            retailCustomer: nil,
            searchPostcode: "DD1 3JA"
        )
    }
    
    static var mockedDataWithRetailMembership: RetailStoreDetails {
        
        let fulfilmentDay1 = RetailStoreFulfilmentDay(
            date: "2021-10-12",
            holidayMessage: nil,
            start: "09:30:00",
            end: "22:30:00",
            storeDateStart: nil,
            storeDateEnd: nil
        )

        let fulfilmentDay2 = RetailStoreFulfilmentDay(
            date: "2021-10-13",
            holidayMessage: nil,
            start: "09:30:00",
            end: "22:30:00",
            storeDateStart: nil,
            storeDateEnd: nil
        )
        
        return RetailStoreDetails(
            id: 1569,//30,
            menuGroupId: 1218,//30,
            storeName: "Family Shopper Lochee",
            telephone: "01382621132",
            lat: 56.473358599999997,
            lng: -3.0111853000000002,
            ordersPaused: false,
            canDeliver: true,
            distance: 0,
            pausedMessage: "Delivery drivers are delayed due to the snow - we will be open again shortly - try again in 30 minutes. Thank you for your patience!",
            address1: "163-165 High Street",
            address2: nil,
            town: "Dundee",
            postcode: "DD2 3DB",
            customerOrderNotePlaceholder: "Please enter any instructions for the store or driver.",
            memberEmailCheck: false,
            guestCheckoutAllowed: true,
            basketOnlyTimeSelection: false,
            ratings: RetailStoreRatings(averageRating: 4.8, numRatings: 379),
            tips: [
                RetailStoreTip(
                    enabled: true,
                    defaultValue: 1.0,
                    type: "driver",
                    refundDriverTipsForLateOrders: false,
                    refundDriverTipsAfterLateByMinutes: 0
                )
            ],
            storeLogo: [
                "mdpi_1x": URL(string: "https://www.snappyshopper.co.uk/uploads/images/stores/mdpi_1x/1581190214Barassie3.png")!,
                "xhdpi_2x": URL(string: "https://www.snappyshopper.co.uk/uploads/images/stores/xhdpi_2x/1581190214Barassie3.png")!,
                "xxhdpi_3x": URL(string: "https://www.snappyshopper.co.uk/uploads/images/stores/xxhdpi_3x/1581190214Barassie3.png")!
            ],
            storeProductTypes: [21, 32],
            orderMethods: [
                "delivery" : RetailStoreOrderMethod(
                    name: .delivery,
                    earliestTime: "11:30 - 11:45",
                    status: .open,
                    cost: 3.5,
                    fulfilmentIn: "2 hour(s)",
                    freeFulfilmentMessage: nil,
                    deliveryTiers: nil,
                    freeFrom: 0,
                    minSpend: 0
                ),
                "collection" : RetailStoreOrderMethod(
                    name: .collection,
                    earliestTime: "11:00 - 11:05",
                    status: .open,
                    cost: 0,
                    fulfilmentIn: "1 hour(s)",
                    freeFulfilmentMessage: nil,
                    deliveryTiers: nil,
                    freeFrom: 0,
                    minSpend: 0
                )
            ],
            deliveryDays: [
                fulfilmentDay1,
                fulfilmentDay2
            ],
            collectionDays: [
                fulfilmentDay1,
                fulfilmentDay2
            ],
            paymentMethods: [
                PaymentMethod.mockedCashData,
                PaymentMethod.mockedApplePayData,
                PaymentMethod.mockedCardsData
            ],
            paymentGateways: [
                PaymentGateway.mockedWorldpayData,
                PaymentGateway.mockedStripeData,
                PaymentGateway.mockedRealexData
            ], allowedMarketingChannels: [
                AllowedMarketingChannel(id: 123, name: "Facebook")
            ],
            timeZone: "Europe/London",
            currency: RetailStoreCurrency.mockedGBPData,
            retailCustomer: RetailStoreCustomer.mockedDataWithMembership,
            searchPostcode: "DD1 3JA"
        )
    }
    
    static var mockedDataOnlyTodayDelivery: RetailStoreDetails {
        
        let fulfilmentDay1 = RetailStoreFulfilmentDay(
            date: Date().dateOnlyString(storeTimeZone: TimeZone.current),
            holidayMessage: nil,
            start: "09:30:00",
            end: "22:30:00",
            storeDateStart: nil,
            storeDateEnd: nil
        )
        
        return RetailStoreDetails(
            id: 1569,//30,
            menuGroupId: 1218,//30,
            storeName: "Family Shopper Lochee",
            telephone: "01382621132",
            lat: 56.473358599999997,
            lng: -3.0111853000000002,
            ordersPaused: false,
            canDeliver: true,
            distance: 0,
            pausedMessage: "Delivery drivers are delayed due to the snow - we will be open again shortly - try again in 30 minutes. Thank you for your patience!",
            address1: "163-165 High Street",
            address2: nil,
            town: "Dundee",
            postcode: "DD2 3DB",
            customerOrderNotePlaceholder: "Please enter any instructions for the store or driver.",
            memberEmailCheck: false,
            guestCheckoutAllowed: true,
            basketOnlyTimeSelection: false,
            ratings: RetailStoreRatings(averageRating: 4.8, numRatings: 379),
            tips: [
                RetailStoreTip(
                    enabled: true,
                    defaultValue: 1.0,
                    type: "driver",
                    refundDriverTipsForLateOrders: false,
                    refundDriverTipsAfterLateByMinutes: 0
                )
            ],
            storeLogo: [
                "mdpi_1x": URL(string: "https://www.snappyshopper.co.uk/uploads/images/stores/mdpi_1x/1581190214Barassie3.png")!,
                "xhdpi_2x": URL(string: "https://www.snappyshopper.co.uk/uploads/images/stores/xhdpi_2x/1581190214Barassie3.png")!,
                "xxhdpi_3x": URL(string: "https://www.snappyshopper.co.uk/uploads/images/stores/xxhdpi_3x/1581190214Barassie3.png")!
            ],
            storeProductTypes: [21, 32],
            orderMethods: [
                "delivery" : RetailStoreOrderMethod(
                    name: .delivery,
                    earliestTime: "11:30 - 11:45",
                    status: .open,
                    cost: 3.5,
                    fulfilmentIn: "2 hour(s)",
                    freeFulfilmentMessage: nil,
                    deliveryTiers: nil,
                    freeFrom: 0,
                    minSpend: 0
                ),
                "collection" : RetailStoreOrderMethod(
                    name: .collection,
                    earliestTime: "11:00 - 11:05",
                    status: .open,
                    cost: 0,
                    fulfilmentIn: "1 hour(s)",
                    freeFulfilmentMessage: nil,
                    deliveryTiers: nil,
                    freeFrom: 0,
                    minSpend: 0
                )
            ],
            deliveryDays: [
                fulfilmentDay1,
            ],
            collectionDays: [
                fulfilmentDay1,
            ],
            paymentMethods: [
                PaymentMethod.mockedCashData,
                PaymentMethod.mockedApplePayData,
                PaymentMethod.mockedCardsData
            ],
            paymentGateways: [
                PaymentGateway.mockedWorldpayData,
                PaymentGateway.mockedStripeData,
                PaymentGateway.mockedRealexData
            ], allowedMarketingChannels: [
                AllowedMarketingChannel(id: 123, name: "Facebook")
            ],
            timeZone: "Europe/London",
            currency: RetailStoreCurrency.mockedGBPData,
            retailCustomer: nil,
            searchPostcode: "DD1 3JA"
        )
    }
    
    static var mockedDataWithClosedDeliveryStatus: RetailStoreDetails {
        
        let fulfilmentDay1 = RetailStoreFulfilmentDay(
            date: "2021-10-12",
            holidayMessage: nil,
            start: "09:30:00",
            end: "22:30:00",
            storeDateStart: nil,
            storeDateEnd: nil
        )

        let fulfilmentDay2 = RetailStoreFulfilmentDay(
            date: "2021-10-13",
            holidayMessage: nil,
            start: "09:30:00",
            end: "22:30:00",
            storeDateStart: nil,
            storeDateEnd: nil
        )
        
        return RetailStoreDetails(
            id: 1569,//30,
            menuGroupId: 1218,//30,
            storeName: "Family Shopper Lochee",
            telephone: "01382621132",
            lat: 56.473358599999997,
            lng: -3.0111853000000002,
            ordersPaused: false,
            canDeliver: true,
            distance: 0,
            pausedMessage: "Delivery drivers are delayed due to the snow - we will be open again shortly - try again in 30 minutes. Thank you for your patience!",
            address1: "163-165 High Street",
            address2: nil,
            town: "Dundee",
            postcode: "DD2 3DB",
            customerOrderNotePlaceholder: "Please enter any instructions for the store or driver.",
            memberEmailCheck: false,
            guestCheckoutAllowed: true,
            basketOnlyTimeSelection: false,
            ratings: RetailStoreRatings(averageRating: 4.8, numRatings: 379),
            tips: [
                RetailStoreTip(
                    enabled: true,
                    defaultValue: 1.0,
                    type: "driver",
                    refundDriverTipsForLateOrders: false,
                    refundDriverTipsAfterLateByMinutes: 0
                )
            ],
            storeLogo: [
                "mdpi_1x": URL(string: "https://www.snappyshopper.co.uk/uploads/images/stores/mdpi_1x/1581190214Barassie3.png")!,
                "xhdpi_2x": URL(string: "https://www.snappyshopper.co.uk/uploads/images/stores/xhdpi_2x/1581190214Barassie3.png")!,
                "xxhdpi_3x": URL(string: "https://www.snappyshopper.co.uk/uploads/images/stores/xxhdpi_3x/1581190214Barassie3.png")!
            ],
            storeProductTypes: [21, 32],
            orderMethods: [
                "delivery" : RetailStoreOrderMethod(
                    name: .delivery,
                    earliestTime: "11:30 - 11:45",
                    status: .closed,
                    cost: 3.5,
                    fulfilmentIn: "2 hour(s)",
                    freeFulfilmentMessage: nil,
                    deliveryTiers: nil,
                    freeFrom: 0,
                    minSpend: 0
                ),
                "collection" : RetailStoreOrderMethod(
                    name: .collection,
                    earliestTime: "11:00 - 11:05",
                    status: .open,
                    cost: 0,
                    fulfilmentIn: "1 hour(s)",
                    freeFulfilmentMessage: nil,
                    deliveryTiers: nil,
                    freeFrom: 0,
                    minSpend: 0
                )
            ],
            deliveryDays: [
                fulfilmentDay1,
                fulfilmentDay2
            ],
            collectionDays: [
                fulfilmentDay1,
                fulfilmentDay2
            ],
            paymentMethods: [
                PaymentMethod.mockedCashData,
                PaymentMethod.mockedApplePayData,
                PaymentMethod.mockedCardsData
            ],
            paymentGateways: [
                PaymentGateway.mockedWorldpayData,
                PaymentGateway.mockedStripeData,
                PaymentGateway.mockedRealexData
            ], allowedMarketingChannels: [
                AllowedMarketingChannel(id: 123, name: "Facebook")
            ],
            timeZone: "Europe/London",
            currency: RetailStoreCurrency.mockedGBPData,
            retailCustomer: nil,
            searchPostcode: "DD1 3JA"
        )
    }
    
    static var mockedDataWithClosedCollectionStatus: RetailStoreDetails {
        
        let fulfilmentDay1 = RetailStoreFulfilmentDay(
            date: "2021-10-12",
            holidayMessage: nil,
            start: "09:30:00",
            end: "22:30:00",
            storeDateStart: nil,
            storeDateEnd: nil
        )

        let fulfilmentDay2 = RetailStoreFulfilmentDay(
            date: "2021-10-13",
            holidayMessage: nil,
            start: "09:30:00",
            end: "22:30:00",
            storeDateStart: nil,
            storeDateEnd: nil
        )
        
        return RetailStoreDetails(
            id: 1569,//30,
            menuGroupId: 1218,//30,
            storeName: "Family Shopper Lochee",
            telephone: "01382621132",
            lat: 56.473358599999997,
            lng: -3.0111853000000002,
            ordersPaused: false,
            canDeliver: true,
            distance: 0,
            pausedMessage: "Delivery drivers are delayed due to the snow - we will be open again shortly - try again in 30 minutes. Thank you for your patience!",
            address1: "163-165 High Street",
            address2: nil,
            town: "Dundee",
            postcode: "DD2 3DB",
            customerOrderNotePlaceholder: "Please enter any instructions for the store or driver.",
            memberEmailCheck: false,
            guestCheckoutAllowed: true,
            basketOnlyTimeSelection: false,
            ratings: RetailStoreRatings(averageRating: 4.8, numRatings: 379),
            tips: [
                RetailStoreTip(
                    enabled: true,
                    defaultValue: 1.0,
                    type: "driver",
                    refundDriverTipsForLateOrders: false,
                    refundDriverTipsAfterLateByMinutes: 0
                )
            ],
            storeLogo: [
                "mdpi_1x": URL(string: "https://www.snappyshopper.co.uk/uploads/images/stores/mdpi_1x/1581190214Barassie3.png")!,
                "xhdpi_2x": URL(string: "https://www.snappyshopper.co.uk/uploads/images/stores/xhdpi_2x/1581190214Barassie3.png")!,
                "xxhdpi_3x": URL(string: "https://www.snappyshopper.co.uk/uploads/images/stores/xxhdpi_3x/1581190214Barassie3.png")!
            ],
            storeProductTypes: [21, 32],
            orderMethods: [
                "delivery" : RetailStoreOrderMethod(
                    name: .delivery,
                    earliestTime: "11:30 - 11:45",
                    status: .open,
                    cost: 3.5,
                    fulfilmentIn: "2 hour(s)",
                    freeFulfilmentMessage: nil,
                    deliveryTiers: nil,
                    freeFrom: 0,
                    minSpend: 0
                ),
                "collection" : RetailStoreOrderMethod(
                    name: .collection,
                    earliestTime: "11:00 - 11:05",
                    status: .closed,
                    cost: 0,
                    fulfilmentIn: "1 hour(s)",
                    freeFulfilmentMessage: nil,
                    deliveryTiers: nil,
                    freeFrom: 0,
                    minSpend: 0
                )
            ],
            deliveryDays: [
                fulfilmentDay1,
                fulfilmentDay2
            ],
            collectionDays: [
                fulfilmentDay1,
                fulfilmentDay2
            ],
            paymentMethods: [
                PaymentMethod.mockedCashData,
                PaymentMethod.mockedApplePayData,
                PaymentMethod.mockedCardsData
            ],
            paymentGateways: [
                PaymentGateway.mockedWorldpayData,
                PaymentGateway.mockedStripeData,
                PaymentGateway.mockedRealexData
            ], allowedMarketingChannels: [
                AllowedMarketingChannel(id: 123, name: "Facebook")
            ],
            timeZone: "Europe/London",
            currency: RetailStoreCurrency.mockedGBPData,
            retailCustomer: nil,
            searchPostcode: "DD1 3JA"
        )
    }
    
    static var mockedDataWithEmptyDeliveryTiers: RetailStoreDetails {
        
        let fulfilmentDay1 = RetailStoreFulfilmentDay(
            date: "2021-10-12",
            holidayMessage: nil,
            start: "09:30:00",
            end: "22:30:00",
            storeDateStart: nil,
            storeDateEnd: nil
        )

        let fulfilmentDay2 = RetailStoreFulfilmentDay(
            date: "2021-10-13",
            holidayMessage: nil,
            start: "09:30:00",
            end: "22:30:00",
            storeDateStart: nil,
            storeDateEnd: nil
        )
        
        return RetailStoreDetails(
            id: 1569,//30,
            menuGroupId: 1218,//30,
            storeName: "Family Shopper Lochee",
            telephone: "01382621132",
            lat: 56.473358599999997,
            lng: -3.0111853000000002,
            ordersPaused: false,
            canDeliver: true,
            distance: 0,
            pausedMessage: "Delivery drivers are delayed due to the snow - we will be open again shortly - try again in 30 minutes. Thank you for your patience!",
            address1: "163-165 High Street",
            address2: nil,
            town: "Dundee",
            postcode: "DD2 3DB",
            customerOrderNotePlaceholder: "Please enter any instructions for the store or driver.",
            memberEmailCheck: false,
            guestCheckoutAllowed: true,
            basketOnlyTimeSelection: false,
            ratings: RetailStoreRatings(averageRating: 4.8, numRatings: 379),
            tips: [
                RetailStoreTip(
                    enabled: true,
                    defaultValue: 1.0,
                    type: "driver",
                    refundDriverTipsForLateOrders: false,
                    refundDriverTipsAfterLateByMinutes: 0
                )
            ],
            storeLogo: [
                "mdpi_1x": URL(string: "https://www.snappyshopper.co.uk/uploads/images/stores/mdpi_1x/1581190214Barassie3.png")!,
                "xhdpi_2x": URL(string: "https://www.snappyshopper.co.uk/uploads/images/stores/xhdpi_2x/1581190214Barassie3.png")!,
                "xxhdpi_3x": URL(string: "https://www.snappyshopper.co.uk/uploads/images/stores/xxhdpi_3x/1581190214Barassie3.png")!
            ],
            storeProductTypes: [21, 32],
            orderMethods: [
                "delivery" : RetailStoreOrderMethod(
                    name: .delivery,
                    earliestTime: "11:30 - 11:45",
                    status: .open,
                    cost: 3.5,
                    fulfilmentIn: "2 hour(s)",
                    freeFulfilmentMessage: nil,
                    deliveryTiers: [],
                    freeFrom: 0,
                    minSpend: 0
                ),
                "collection" : RetailStoreOrderMethod(
                    name: .collection,
                    earliestTime: "11:00 - 11:05",
                    status: .closed,
                    cost: 0,
                    fulfilmentIn: "1 hour(s)",
                    freeFulfilmentMessage: nil,
                    deliveryTiers: nil,
                    freeFrom: 0,
                    minSpend: 0
                )
            ],
            deliveryDays: [
                fulfilmentDay1,
                fulfilmentDay2
            ],
            collectionDays: [
                fulfilmentDay1,
                fulfilmentDay2
            ],
            paymentMethods: [
                PaymentMethod.mockedCashData,
                PaymentMethod.mockedApplePayData,
                PaymentMethod.mockedCardsData
            ],
            paymentGateways: [
                PaymentGateway.mockedWorldpayData,
                PaymentGateway.mockedStripeData,
                PaymentGateway.mockedRealexData
            ], allowedMarketingChannels: [
                AllowedMarketingChannel(id: 123, name: "Facebook")
            ],
            timeZone: "Europe/London",
            currency: RetailStoreCurrency.mockedGBPData,
            retailCustomer: nil,
            searchPostcode: "DD1 3JA"
        )
    }
    
    static var mockedDataWithDeliveryTiers: RetailStoreDetails {
        
        let fulfilmentDay1 = RetailStoreFulfilmentDay(
            date: "2021-10-12",
            holidayMessage: nil,
            start: "09:30:00",
            end: "22:30:00",
            storeDateStart: nil,
            storeDateEnd: nil
        )

        let fulfilmentDay2 = RetailStoreFulfilmentDay(
            date: "2021-10-13",
            holidayMessage: nil,
            start: "09:30:00",
            end: "22:30:00",
            storeDateStart: nil,
            storeDateEnd: nil
        )
        
        return RetailStoreDetails(
            id: 1569,//30,
            menuGroupId: 1218,//30,
            storeName: "Family Shopper Lochee",
            telephone: "01382621132",
            lat: 56.473358599999997,
            lng: -3.0111853000000002,
            ordersPaused: false,
            canDeliver: true,
            distance: 0,
            pausedMessage: "Delivery drivers are delayed due to the snow - we will be open again shortly - try again in 30 minutes. Thank you for your patience!",
            address1: "163-165 High Street",
            address2: nil,
            town: "Dundee",
            postcode: "DD2 3DB",
            customerOrderNotePlaceholder: "Please enter any instructions for the store or driver.",
            memberEmailCheck: false,
            guestCheckoutAllowed: true,
            basketOnlyTimeSelection: false,
            ratings: RetailStoreRatings(averageRating: 4.8, numRatings: 379),
            tips: [
                RetailStoreTip(
                    enabled: true,
                    defaultValue: 1.0,
                    type: "driver",
                    refundDriverTipsForLateOrders: false,
                    refundDriverTipsAfterLateByMinutes: 0
                )
            ],
            storeLogo: [
                "mdpi_1x": URL(string: "https://www.snappyshopper.co.uk/uploads/images/stores/mdpi_1x/1581190214Barassie3.png")!,
                "xhdpi_2x": URL(string: "https://www.snappyshopper.co.uk/uploads/images/stores/xhdpi_2x/1581190214Barassie3.png")!,
                "xxhdpi_3x": URL(string: "https://www.snappyshopper.co.uk/uploads/images/stores/xxhdpi_3x/1581190214Barassie3.png")!
            ],
            storeProductTypes: [21, 32],
            orderMethods: [
                "delivery" : RetailStoreOrderMethod(
                    name: .delivery,
                    earliestTime: "11:30 - 11:45",
                    status: .open,
                    cost: 3.5,
                    fulfilmentIn: "2 hour(s)",
                    freeFulfilmentMessage: nil,
                    deliveryTiers: [
                        .init(minBasketSpend: 5, deliveryFee: 5),
                        .init(minBasketSpend: 10, deliveryFee: 3),
                        .init(minBasketSpend: 15, deliveryFee: 2)
                    ],
                    freeFrom: 0,
                    minSpend: 0
                ),
                "collection" : RetailStoreOrderMethod(
                    name: .collection,
                    earliestTime: "11:00 - 11:05",
                    status: .closed,
                    cost: 0,
                    fulfilmentIn: "1 hour(s)",
                    freeFulfilmentMessage: nil,
                    deliveryTiers: nil,
                    freeFrom: 0,
                    minSpend: 0
                )
            ],
            deliveryDays: [
                fulfilmentDay1,
                fulfilmentDay2
            ],
            collectionDays: [
                fulfilmentDay1,
                fulfilmentDay2
            ],
            paymentMethods: [
                PaymentMethod.mockedCashData,
                PaymentMethod.mockedApplePayData,
                PaymentMethod.mockedCardsData
            ],
            paymentGateways: [
                PaymentGateway.mockedWorldpayData,
                PaymentGateway.mockedStripeData,
                PaymentGateway.mockedRealexData
            ], allowedMarketingChannels: [
                AllowedMarketingChannel(id: 123, name: "Facebook")
            ],
            timeZone: "Europe/London",
            currency: RetailStoreCurrency.mockedGBPData,
            retailCustomer: nil,
            searchPostcode: "DD1 3JA"
        )
    }
    
    static var mockedDataWithCheckoutComApplePay: RetailStoreDetails {
        
        let fulfilmentDay1 = RetailStoreFulfilmentDay(
            date: "2021-10-12",
            holidayMessage: nil,
            start: "09:30:00",
            end: "22:30:00",
            storeDateStart: nil,
            storeDateEnd: nil
        )

        let fulfilmentDay2 = RetailStoreFulfilmentDay(
            date: "2021-10-13",
            holidayMessage: nil,
            start: "09:30:00",
            end: "22:30:00",
            storeDateStart: nil,
            storeDateEnd: nil
        )
        
        return RetailStoreDetails(
            id: 1569,//30,
            menuGroupId: 1218,//30,
            storeName: "Family Shopper Lochee",
            telephone: "01382621132",
            lat: 56.473358599999997,
            lng: -3.0111853000000002,
            ordersPaused: false,
            canDeliver: true,
            distance: 0,
            pausedMessage: "Delivery drivers are delayed due to the snow - we will be open again shortly - try again in 30 minutes. Thank you for your patience!",
            address1: "163-165 High Street",
            address2: nil,
            town: "Dundee",
            postcode: "DD2 3DB",
            customerOrderNotePlaceholder: "Please enter any instructions for the store or driver.",
            memberEmailCheck: false,
            guestCheckoutAllowed: true,
            basketOnlyTimeSelection: false,
            ratings: RetailStoreRatings(averageRating: 4.8, numRatings: 379),
            tips: [
                RetailStoreTip(
                    enabled: true,
                    defaultValue: 1.0,
                    type: "driver",
                    refundDriverTipsForLateOrders: false,
                    refundDriverTipsAfterLateByMinutes: 0
                )
            ],
            storeLogo: [
                "mdpi_1x": URL(string: "https://www.snappyshopper.co.uk/uploads/images/stores/mdpi_1x/1581190214Barassie3.png")!,
                "xhdpi_2x": URL(string: "https://www.snappyshopper.co.uk/uploads/images/stores/xhdpi_2x/1581190214Barassie3.png")!,
                "xxhdpi_3x": URL(string: "https://www.snappyshopper.co.uk/uploads/images/stores/xxhdpi_3x/1581190214Barassie3.png")!
            ],
            storeProductTypes: [21, 32],
            orderMethods: [
                "delivery" : RetailStoreOrderMethod(
                    name: .delivery,
                    earliestTime: "11:30 - 11:45",
                    status: .open,
                    cost: 3.5,
                    fulfilmentIn: "2 hour(s)",
                    freeFulfilmentMessage: nil,
                    deliveryTiers: nil,
                    freeFrom: 0,
                    minSpend: 0
                ),
                "collection" : RetailStoreOrderMethod(
                    name: .collection,
                    earliestTime: "11:00 - 11:05",
                    status: .open,
                    cost: 0,
                    fulfilmentIn: "1 hour(s)",
                    freeFulfilmentMessage: nil,
                    deliveryTiers: nil,
                    freeFrom: 0,
                    minSpend: 0
                )
            ],
            deliveryDays: [
                fulfilmentDay1,
                fulfilmentDay2
            ],
            collectionDays: [
                fulfilmentDay1,
                fulfilmentDay2
            ],
            paymentMethods: [
                PaymentMethod.mockedCashData,
                PaymentMethod.mockedApplePayCheckoutComData,
                PaymentMethod.mockedCardsCheckoutcomFirstData
            ],
            paymentGateways: [
                PaymentGateway.mockedCheckoutcomData,
                PaymentGateway.mockedWorldpayData,
                PaymentGateway.mockedStripeData,
                PaymentGateway.mockedRealexData
            ], allowedMarketingChannels: [
                AllowedMarketingChannel(id: 123, name: "Facebook")
            ],
            timeZone: "Europe/London",
            currency: RetailStoreCurrency.mockedGBPData,
            retailCustomer: nil,
            searchPostcode: "DD1 3JA"
        )
    }
    
    static var mockedDataWithCheckoutComApplePayWithTestMode: RetailStoreDetails {
        
        let fulfilmentDay1 = RetailStoreFulfilmentDay(
            date: "2021-10-12",
            holidayMessage: nil,
            start: "09:30:00",
            end: "22:30:00",
            storeDateStart: nil,
            storeDateEnd: nil
        )

        let fulfilmentDay2 = RetailStoreFulfilmentDay(
            date: "2021-10-13",
            holidayMessage: nil,
            start: "09:30:00",
            end: "22:30:00",
            storeDateStart: nil,
            storeDateEnd: nil
        )
        
        return RetailStoreDetails(
            id: 1569,//30,
            menuGroupId: 1218,//30,
            storeName: "Family Shopper Lochee",
            telephone: "01382621132",
            lat: 56.473358599999997,
            lng: -3.0111853000000002,
            ordersPaused: false,
            canDeliver: true,
            distance: 0,
            pausedMessage: "Delivery drivers are delayed due to the snow - we will be open again shortly - try again in 30 minutes. Thank you for your patience!",
            address1: "163-165 High Street",
            address2: nil,
            town: "Dundee",
            postcode: "DD2 3DB",
            customerOrderNotePlaceholder: "Please enter any instructions for the store or driver.",
            memberEmailCheck: false,
            guestCheckoutAllowed: true,
            basketOnlyTimeSelection: false,
            ratings: RetailStoreRatings(averageRating: 4.8, numRatings: 379),
            tips: [
                RetailStoreTip(
                    enabled: true,
                    defaultValue: 1.0,
                    type: "driver",
                    refundDriverTipsForLateOrders: false,
                    refundDriverTipsAfterLateByMinutes: 0
                )
            ],
            storeLogo: [
                "mdpi_1x": URL(string: "https://www.snappyshopper.co.uk/uploads/images/stores/mdpi_1x/1581190214Barassie3.png")!,
                "xhdpi_2x": URL(string: "https://www.snappyshopper.co.uk/uploads/images/stores/xhdpi_2x/1581190214Barassie3.png")!,
                "xxhdpi_3x": URL(string: "https://www.snappyshopper.co.uk/uploads/images/stores/xxhdpi_3x/1581190214Barassie3.png")!
            ],
            storeProductTypes: [21, 32],
            orderMethods: [
                "delivery" : RetailStoreOrderMethod(
                    name: .delivery,
                    earliestTime: "11:30 - 11:45",
                    status: .open,
                    cost: 3.5,
                    fulfilmentIn: "2 hour(s)",
                    freeFulfilmentMessage: nil,
                    deliveryTiers: nil,
                    freeFrom: 0,
                    minSpend: 0
                ),
                "collection" : RetailStoreOrderMethod(
                    name: .collection,
                    earliestTime: "11:00 - 11:05",
                    status: .open,
                    cost: 0,
                    fulfilmentIn: "1 hour(s)",
                    freeFulfilmentMessage: nil,
                    deliveryTiers: nil,
                    freeFrom: 0,
                    minSpend: 0
                )
            ],
            deliveryDays: [
                fulfilmentDay1,
                fulfilmentDay2
            ],
            collectionDays: [
                fulfilmentDay1,
                fulfilmentDay2
            ],
            paymentMethods: [
                PaymentMethod.mockedCashData,
                PaymentMethod.mockedApplePayData,
                PaymentMethod.mockedApplePayCheckoutComData,
                PaymentMethod.mockedCardsCheckoutcomFirstData,
                PaymentMethod.mockedCardsData
            ],
            paymentGateways: [
                PaymentGateway.mockedCheckoutcomDataWithTestMode,
                PaymentGateway.mockedWorldpayData,
                PaymentGateway.mockedStripeData,
                PaymentGateway.mockedRealexData
            ], allowedMarketingChannels: [
                AllowedMarketingChannel(id: 123, name: "Facebook")
            ],
            timeZone: "Europe/London",
            currency: RetailStoreCurrency.mockedGBPData,
            retailCustomer: nil,
            searchPostcode: "DD1 3JA"
        )
    }
    
    static var mockedDataWithMemberEmailCheck: RetailStoreDetails{
        
        let fulfilmentDay1 = RetailStoreFulfilmentDay(
            date: "2021-10-12",
            holidayMessage: nil,
            start: "09:30:00",
            end: "22:30:00",
            storeDateStart: nil,
            storeDateEnd: nil
        )
        
        let fulfilmentDay2 = RetailStoreFulfilmentDay(
            date: "2021-10-13",
            holidayMessage: nil,
            start: "09:30:00",
            end: "22:30:00",
            storeDateStart: nil,
            storeDateEnd: nil
        )
        
        return RetailStoreDetails(
            id: 1569,//30,
            menuGroupId: 1218,//30,
            storeName: "Family Shopper Lochee",
            telephone: "01382621132",
            lat: 56.473358599999997,
            lng: -3.0111853000000002,
            ordersPaused: false,
            canDeliver: true,
            distance: 0,
            pausedMessage: "Delivery drivers are delayed due to the snow - we will be open again shortly - try again in 30 minutes. Thank you for your patience!",
            address1: "163-165 High Street",
            address2: nil,
            town: "Dundee",
            postcode: "DD2 3DB",
            customerOrderNotePlaceholder: "Please enter any instructions for the store or driver.",
            memberEmailCheck: true,
            guestCheckoutAllowed: true,
            basketOnlyTimeSelection: false,
            ratings: RetailStoreRatings(averageRating: 4.8, numRatings: 379),
            tips: [
                RetailStoreTip(
                    enabled: true,
                    defaultValue: 1.0,
                    type: "driver",
                    refundDriverTipsForLateOrders: false,
                    refundDriverTipsAfterLateByMinutes: 0
                )
            ],
            storeLogo: [
                "mdpi_1x": URL(string: "https://www.snappyshopper.co.uk/uploads/images/stores/mdpi_1x/1581190214Barassie3.png")!,
                "xhdpi_2x": URL(string: "https://www.snappyshopper.co.uk/uploads/images/stores/xhdpi_2x/1581190214Barassie3.png")!,
                "xxhdpi_3x": URL(string: "https://www.snappyshopper.co.uk/uploads/images/stores/xxhdpi_3x/1581190214Barassie3.png")!
            ],
            storeProductTypes: [21, 32],
            orderMethods: [
                "delivery" : RetailStoreOrderMethod(
                    name: .delivery,
                    earliestTime: "11:30 - 11:45",
                    status: .open,
                    cost: 3.5,
                    fulfilmentIn: "2 hour(s)",
                    freeFulfilmentMessage: nil,
                    deliveryTiers: nil,
                    freeFrom: 0,
                    minSpend: 0
                ),
                "collection" : RetailStoreOrderMethod(
                    name: .collection,
                    earliestTime: "11:00 - 11:05",
                    status: .open,
                    cost: 0,
                    fulfilmentIn: "1 hour(s)",
                    freeFulfilmentMessage: nil,
                    deliveryTiers: nil,
                    freeFrom: 0,
                    minSpend: 0
                )
            ],
            deliveryDays: [
                fulfilmentDay1,
                fulfilmentDay2
            ],
            collectionDays: [
                fulfilmentDay1,
                fulfilmentDay2
            ],
            paymentMethods: [
                PaymentMethod.mockedCashData,
                PaymentMethod.mockedApplePayData,
                PaymentMethod.mockedCardsData
            ],
            paymentGateways: [
                PaymentGateway.mockedWorldpayData,
                PaymentGateway.mockedStripeData,
                PaymentGateway.mockedRealexData
            ], allowedMarketingChannels: [
                AllowedMarketingChannel(id: 123, name: "Facebook")
            ],
            timeZone: "Europe/London",
            currency: RetailStoreCurrency.mockedGBPData,
            retailCustomer: nil,
            searchPostcode: "DD1 3JA"
        )
    }
    
    static func startAndEndTimes(forDate date: String?, withTimeZone timeZone: String?) -> (start: Date?, end: Date?)? {
        if let date = date {
        
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "en_US_POSIX")
            formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            
            if
                let storeTimeZone = timeZone,
                let timeZone = TimeZone(identifier: storeTimeZone)
            {
                formatter.timeZone = timeZone
            } else {
                formatter.timeZone = AppV2Constants.Business.defaultTimeZone
            }

            return (start: formatter.date(from: date + " 00:00:00"), end: formatter.date(from: date + " 23:59:59"))
        } else {
            return nil
        }
    }
    
    static var mockedDataWithStartAndEndDates: RetailStoreDetails {
        
        let timeZone = "Europe/London"
        
        let fulfilmentDay1StartAndEnd = startAndEndTimes(forDate: "2021-10-12", withTimeZone: timeZone)
        let fulfilmentDay2StartAndEnd = startAndEndTimes(forDate: "2021-10-13", withTimeZone: timeZone)
        
        let fulfilmentDay1 = RetailStoreFulfilmentDay(
            date: "2021-10-12",
            holidayMessage: nil,
            start: "09:30:00",
            end: "22:30:00",
            storeDateStart: fulfilmentDay1StartAndEnd?.start,
            storeDateEnd: fulfilmentDay1StartAndEnd?.end
        )

        let fulfilmentDay2 = RetailStoreFulfilmentDay(
            date: "2021-10-13",
            holidayMessage: nil,
            start: "09:30:00",
            end: "22:30:00",
            storeDateStart: fulfilmentDay2StartAndEnd?.start,
            storeDateEnd: fulfilmentDay2StartAndEnd?.end
        )
        
        return RetailStoreDetails(
            id: 1569,//30,
            menuGroupId: 1218,//30,
            storeName: "Family Shopper Lochee",
            telephone: "01382621132",
            lat: 56.473358599999997,
            lng: -3.0111853000000002,
            ordersPaused: false,
            canDeliver: true,
            distance: 0,
            pausedMessage: "Delivery drivers are delayed due to the snow - we will be open again shortly - try again in 30 minutes. Thank you for your patience!",
            address1: "163-165 High Street",
            address2: nil,
            town: "Dundee",
            postcode: "DD2 3DB",
            customerOrderNotePlaceholder: "Please enter any instructions for the store or driver.",
            memberEmailCheck: false,
            guestCheckoutAllowed: true,
            basketOnlyTimeSelection: false,
            ratings: RetailStoreRatings(averageRating: 4.8, numRatings: 379),
            tips: [
                RetailStoreTip(
                    enabled: true,
                    defaultValue: 1.0,
                    type: "driver",
                    refundDriverTipsForLateOrders: false,
                    refundDriverTipsAfterLateByMinutes: 0
                )
            ],
            storeLogo: [
                "mdpi_1x": URL(string: "https://www.snappyshopper.co.uk/uploads/images/stores/mdpi_1x/1581190214Barassie3.png")!,
                "xhdpi_2x": URL(string: "https://www.snappyshopper.co.uk/uploads/images/stores/xhdpi_2x/1581190214Barassie3.png")!,
                "xxhdpi_3x": URL(string: "https://www.snappyshopper.co.uk/uploads/images/stores/xxhdpi_3x/1581190214Barassie3.png")!
            ],
            storeProductTypes: [21, 32],
            orderMethods: [
                "delivery" : RetailStoreOrderMethod(
                    name: .delivery,
                    earliestTime: "11:30 - 11:45",
                    status: .open,
                    cost: 3.5,
                    fulfilmentIn: "2 hour(s)",
                    freeFulfilmentMessage: nil,
                    deliveryTiers: nil,
                    freeFrom: 0,
                    minSpend: 0
                ),
                "collection" : RetailStoreOrderMethod(
                    name: .collection,
                    earliestTime: "11:00 - 11:05",
                    status: .open,
                    cost: 0,
                    fulfilmentIn: "1 hour(s)",
                    freeFulfilmentMessage: nil,
                    deliveryTiers: nil,
                    freeFrom: 0,
                    minSpend: 0
                )
            ],
            deliveryDays: [
                fulfilmentDay1,
                fulfilmentDay2
            ],
            collectionDays: [
                fulfilmentDay1,
                fulfilmentDay2
            ],
            paymentMethods: [
                PaymentMethod.mockedCashData,
                PaymentMethod.mockedApplePayData,
                PaymentMethod.mockedCardsData
            ],
            paymentGateways: [
                PaymentGateway.mockedWorldpayData,
                PaymentGateway.mockedStripeData,
                PaymentGateway.mockedRealexData
            ], allowedMarketingChannels: [
                AllowedMarketingChannel(id: 123, name: "Facebook")
            ],
            timeZone: timeZone,
            currency: RetailStoreCurrency.mockedGBPData,
            retailCustomer: nil,
            searchPostcode: "DD1 3JA"
        )
    }
    
    static var mockedDataWithoutRealexAndNoDeliveryForStripe: RetailStoreDetails {
        
        let timeZone = "Europe/London"
        
        let fulfilmentDay1StartAndEnd = startAndEndTimes(forDate: "2021-10-12", withTimeZone: timeZone)
        let fulfilmentDay2StartAndEnd = startAndEndTimes(forDate: "2021-10-13", withTimeZone: timeZone)
        
        let fulfilmentDay1 = RetailStoreFulfilmentDay(
            date: "2021-10-12",
            holidayMessage: nil,
            start: "09:30:00",
            end: "22:30:00",
            storeDateStart: fulfilmentDay1StartAndEnd?.start,
            storeDateEnd: fulfilmentDay1StartAndEnd?.end
        )

        let fulfilmentDay2 = RetailStoreFulfilmentDay(
            date: "2021-10-13",
            holidayMessage: nil,
            start: "09:30:00",
            end: "22:30:00",
            storeDateStart: fulfilmentDay2StartAndEnd?.start,
            storeDateEnd: fulfilmentDay2StartAndEnd?.end
        )
        
        return RetailStoreDetails(
            id: 1569,//30,
            menuGroupId: 1218,//30,
            storeName: "Family Shopper Lochee",
            telephone: "01382621132",
            lat: 56.473358599999997,
            lng: -3.0111853000000002,
            ordersPaused: false,
            canDeliver: true,
            distance: 0,
            pausedMessage: "Delivery drivers are delayed due to the snow - we will be open again shortly - try again in 30 minutes. Thank you for your patience!",
            address1: "163-165 High Street",
            address2: nil,
            town: "Dundee",
            postcode: "DD2 3DB",
            customerOrderNotePlaceholder: "Please enter any instructions for the store or driver.",
            memberEmailCheck: false,
            guestCheckoutAllowed: true,
            basketOnlyTimeSelection: false,
            ratings: RetailStoreRatings(averageRating: 4.8, numRatings: 379),
            tips: [
                RetailStoreTip(
                    enabled: true,
                    defaultValue: 1.0,
                    type: "driver",
                    refundDriverTipsForLateOrders: false,
                    refundDriverTipsAfterLateByMinutes: 0
                )
            ],
            storeLogo: [
                "mdpi_1x": URL(string: "https://www.snappyshopper.co.uk/uploads/images/stores/mdpi_1x/1581190214Barassie3.png")!,
                "xhdpi_2x": URL(string: "https://www.snappyshopper.co.uk/uploads/images/stores/xhdpi_2x/1581190214Barassie3.png")!,
                "xxhdpi_3x": URL(string: "https://www.snappyshopper.co.uk/uploads/images/stores/xxhdpi_3x/1581190214Barassie3.png")!
            ],
            storeProductTypes: [21, 32],
            orderMethods: [
                "delivery" : RetailStoreOrderMethod(
                    name: .delivery,
                    earliestTime: "11:30 - 11:45",
                    status: .open,
                    cost: 3.5,
                    fulfilmentIn: "2 hour(s)",
                    freeFulfilmentMessage: nil,
                    deliveryTiers: nil,
                    freeFrom: 0,
                    minSpend: 0
                ),
                "collection" : RetailStoreOrderMethod(
                    name: .collection,
                    earliestTime: "11:00 - 11:05",
                    status: .open,
                    cost: 0,
                    fulfilmentIn: "1 hour(s)",
                    freeFulfilmentMessage: nil,
                    deliveryTiers: nil,
                    freeFrom: 0,
                    minSpend: 0
                )
            ],
            deliveryDays: [
                fulfilmentDay1,
                fulfilmentDay2
            ],
            collectionDays: [
                fulfilmentDay1,
                fulfilmentDay2
            ],
            paymentMethods: [
                PaymentMethod.mockedCashData,
                PaymentMethod.mockedApplePayData,
                PaymentMethod.mockedCardsDataWithoutDelivery
            ],
            paymentGateways: [
                PaymentGateway.mockedWorldpayData,
                PaymentGateway.mockedStripeData
                // No Realex
            ], allowedMarketingChannels: [
                AllowedMarketingChannel(id: 123, name: "Facebook")
            ],
            timeZone: timeZone,
            currency: RetailStoreCurrency.mockedGBPData,
            retailCustomer: nil,
            searchPostcode: "DD1 3JA"
        )
    }
    
    static var mockedDataWithGuestCheckoutDisabled: RetailStoreDetails {
        
        let fulfilmentDay1 = RetailStoreFulfilmentDay(
            date: "2021-10-12",
            holidayMessage: nil,
            start: "09:30:00",
            end: "22:30:00",
            storeDateStart: nil,
            storeDateEnd: nil
        )
        
        let fulfilmentDay2 = RetailStoreFulfilmentDay(
            date: "2021-10-13",
            holidayMessage: nil,
            start: "09:30:00",
            end: "22:30:00",
            storeDateStart: nil,
            storeDateEnd: nil
        )
        
        return RetailStoreDetails(
            id: 1569,//30,
            menuGroupId: 1218,//30,
            storeName: "Family Shopper Lochee",
            telephone: "01382621132",
            lat: 56.473358599999997,
            lng: -3.0111853000000002,
            ordersPaused: false,
            canDeliver: true,
            distance: 0,
            pausedMessage: "Delivery drivers are delayed due to the snow - we will be open again shortly - try again in 30 minutes. Thank you for your patience!",
            address1: "163-165 High Street",
            address2: nil,
            town: "Dundee",
            postcode: "DD2 3DB",
            customerOrderNotePlaceholder: "Please enter any instructions for the store or driver.",
            memberEmailCheck: false,
            guestCheckoutAllowed: false,
            basketOnlyTimeSelection: false,
            ratings: RetailStoreRatings(averageRating: 4.8, numRatings: 379),
            tips: [
                RetailStoreTip(
                    enabled: true,
                    defaultValue: 1.0,
                    type: "driver",
                    refundDriverTipsForLateOrders: false,
                    refundDriverTipsAfterLateByMinutes: 0
                )
            ],
            storeLogo: [
                "mdpi_1x": URL(string: "https://www.snappyshopper.co.uk/uploads/images/stores/mdpi_1x/1581190214Barassie3.png")!,
                "xhdpi_2x": URL(string: "https://www.snappyshopper.co.uk/uploads/images/stores/xhdpi_2x/1581190214Barassie3.png")!,
                "xxhdpi_3x": URL(string: "https://www.snappyshopper.co.uk/uploads/images/stores/xxhdpi_3x/1581190214Barassie3.png")!
            ],
            storeProductTypes: [21, 32],
            orderMethods: [
                "delivery" : RetailStoreOrderMethod(
                    name: .delivery,
                    earliestTime: "11:30 - 11:45",
                    status: .open,
                    cost: 3.5,
                    fulfilmentIn: "2 hour(s)",
                    freeFulfilmentMessage: nil,
                    deliveryTiers: nil,
                    freeFrom: 0,
                    minSpend: 0
                ),
                "collection" : RetailStoreOrderMethod(
                    name: .collection,
                    earliestTime: "11:00 - 11:05",
                    status: .open,
                    cost: 0,
                    fulfilmentIn: "1 hour(s)",
                    freeFulfilmentMessage: nil,
                    deliveryTiers: nil,
                    freeFrom: 0,
                    minSpend: 0
                )
            ],
            deliveryDays: [
                fulfilmentDay1,
                fulfilmentDay2
            ],
            collectionDays: [
                fulfilmentDay1,
                fulfilmentDay2
            ],
            paymentMethods: [
                PaymentMethod.mockedCashData,
                PaymentMethod.mockedApplePayData,
                PaymentMethod.mockedCardsData
            ],
            paymentGateways: [
                PaymentGateway.mockedWorldpayData,
                PaymentGateway.mockedStripeData,
                PaymentGateway.mockedRealexData
            ], allowedMarketingChannels: [
                AllowedMarketingChannel(id: 123, name: "Facebook")
            ],
            timeZone: "Europe/London",
            currency: RetailStoreCurrency.mockedGBPData,
            retailCustomer: nil,
            searchPostcode: "DD1 3JA"
        )
    }
    
    var recordsCount: Int {
        
        var count = 1
        
        if let paymentMethods = paymentMethods {
            for paymentMethod in paymentMethods {
                count += paymentMethod.recordsCount
            }
        }
        
        if let paymentGateways = paymentGateways {
            for paymentGateway in paymentGateways {
                count += paymentGateway.recordsCount
            }
        }
        
        // note that storeProductTypes is not counted because the entries generated
        // based on the same records within RetailStoresSearch.storeProductTypes
        return count +
        (storeLogo?.count ?? 0) +
        (storeProductTypes?.count ?? 0) +
        (orderMethods?.count ?? 0) +
        (deliveryDays.count) +
        (collectionDays.count) +
        (tips?.count ?? 0) +
        (ratings != nil ? 1 : 0) +
        (allowedMarketingChannels.count)
    }
}

extension RetailStoreTimeSlots {
    
    static let mockedAPIResponseData: RetailStoreTimeSlots = {
        
        // get todays date string for UK
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(identifier: "Europe/London")
        formatter.dateFormat = "yyyy-MM-dd"

        let dateUKString = formatter.string(from: Date())

        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"

        let startOfToday = formatter.date(from: dateUKString + " 00:00:00")!
        let endOfToday = formatter.date(from: dateUKString + " 23:59:59")!
        
        return RetailStoreTimeSlots(
            startDate: startOfToday,
            endDate: endOfToday,
            fulfilmentMethod: "delivery",
            slotDays: RetailStoreSlotDay.mockedData(start: startOfToday, end: endOfToday, timeZone: formatter.timeZone),
            searchStoreId: nil,
            searchLatitude: nil,
            searchLongitude: nil
        )
    }()
    
    static func mockedPersistedDataWithoutCoordinates(basedOn: RetailStoreTimeSlots) -> RetailStoreTimeSlots {
        
        return RetailStoreTimeSlots(
            startDate: basedOn.startDate,
            endDate: basedOn.endDate,
            fulfilmentMethod: basedOn.fulfilmentMethod,
            slotDays: basedOn.slotDays,
            searchStoreId: 30,
            searchLatitude: nil,
            searchLongitude: nil
        )
        
    }
    
    static func mockedPersistedDataWithCoordinates(basedOn: RetailStoreTimeSlots) -> RetailStoreTimeSlots {
        
        return RetailStoreTimeSlots(
            startDate: basedOn.startDate,
            endDate: basedOn.endDate,
            fulfilmentMethod: basedOn.fulfilmentMethod,
            slotDays: basedOn.slotDays,
            searchStoreId: 30,
            searchLatitude: 56.473358599999997,
            searchLongitude: -3.0111853000000002
        )
        
    }
    
    var recordsCount: Int {
        var count = 1
        if let slotDays = slotDays {
            for days in slotDays {
                count += 1 + (days.slots?.count ?? 0)
            }
        }
        return count
    }
}

extension RetailStoreSlotDay {
    static func mockedData(start: Date, end: Date, timeZone: TimeZone) -> [RetailStoreSlotDay] {
        
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = timeZone
        formatter.dateFormat = "yyyy-MM-dd"
        
        // add some realistic ranges
        if
            let start = Calendar.current.date(byAdding: .hour, value: 8, to: start),
            let end = Calendar.current.date(byAdding: .hour, value: -4, to: end)
        {
            return [
                RetailStoreSlotDay(
                    status: "available",
                    reason: "",
                    slotDate: formatter.string(from: start),
                    slots: RetailStoreSlotDayTimeSlot.mockedData(
                        start: start,
                        end: end,
                        timeZone: timeZone
                    )
                )
            ]
        } else {
            return []
        }
    }
}

extension RetailStoreSlotDayTimeSlot {
    
    static func randomSlotId(length: Int) -> String {
        let letters = "abcdef0123456789"
        return String((0..<length).map{ _ in letters.randomElement()! })
    }
    
    static func mockedData(start: Date, end: Date, timeZone: TimeZone) -> [RetailStoreSlotDayTimeSlot] {
        
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = timeZone
        formatter.dateFormat = "yyyy-MM-dd"
        
        let dateString = formatter.string(from: start)

        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"

        let noon = formatter.date(from: dateString + " 12:00:00")!
        let endOfAfternoon = formatter.date(from: dateString + " 18:00:00")!
        
        var slots: [RetailStoreSlotDayTimeSlot] = []
        
        var currentTime = start
        var first = true
        repeat {
            
            guard let nextTime = Calendar.current.date(byAdding: .minute, value: 15, to: currentTime) else {
                break
            }
            
            let dayTime: String
            if currentTime < noon {
                dayTime = "morning"
            } else if currentTime < endOfAfternoon {
                dayTime = "afternoon"
            } else {
                dayTime = "evening"
            }
            
            slots.append(
                RetailStoreSlotDayTimeSlot(
                    slotId: randomSlotId(length: 40),
                    startTime: currentTime,
                    endTime: nextTime,
                    daytime: dayTime,
                    info: RetailStoreSlotDayTimeSlotInfo(
                        status: "available",
                        isAsap: first,
                        price: 3.0,
                        fulfilmentIn: "X hour(s)"
                    )
                )
            )

            currentTime = nextTime
            first = false
            
        } while currentTime < end
        
        return slots
    }
}

extension FulfilmentLocation {
    static let mockedData = FulfilmentLocation(
        country: "UK",
        latitude: -2.95885,
        longitude: 56.462502000000001,
        postcode: "DD1 3JA"
    )
}

extension PaymentMethod {
    
    static let mockedCashData = PaymentMethod(
        name: "Cash",
        title: "Cash accepted",
        description: nil,
        settings: PaymentMethodSettings(
            title: "Cash",
            instructions: nil,
            enabledForMethod: [.delivery, .collection],
            paymentGateways: nil,
            saveCards: nil,
            cutOffTime: "17:59:00"
        )
    )
    
    static let mockedApplePayData = PaymentMethod(
        name: "ApplePay",
        title: "Apple Pay",
        description: nil,
        settings: PaymentMethodSettings(
            title: "Apple Pay",
            instructions: nil,
            enabledForMethod: [.delivery, .collection],
            paymentGateways: ["worldpay"],
            saveCards: nil,
            cutOffTime: nil
        )
    )
    
    static let mockedApplePayCheckoutComData = PaymentMethod(
        name: "ApplePay",
        title: "Apple Pay",
        description: nil,
        settings: PaymentMethodSettings(
            title: "Apple Pay",
            instructions: nil,
            enabledForMethod: [.delivery, .collection],
            paymentGateways: ["checkoutcom"],
            saveCards: nil,
            cutOffTime: nil
        )
    )
    
    static let mockedCardsCheckoutcomFirstData = PaymentMethod(
        name: "Cards",
        title: "Cards",
        description: nil,
        settings: PaymentMethodSettings(
            title: "Cards",
            instructions: nil,
            enabledForMethod: [.delivery, .collection],
            paymentGateways: ["checkoutcom", "realex"],
            saveCards: nil,
            cutOffTime: nil
        )
    )
    
    static let mockedCardsData = PaymentMethod(
        name: "Cards",
        title: "Cards",
        description: nil,
        settings: PaymentMethodSettings(
            title: "Cards",
            instructions: nil,
            enabledForMethod: [.delivery, .collection],
            paymentGateways: ["worldpay", "stripe", "realex"],
            saveCards: nil,
            cutOffTime: nil
        )
    )
    
    static let mockedCardsDataWithoutDelivery = PaymentMethod(
        name: "Cards",
        title: "Cards",
        description: nil,
        settings: PaymentMethodSettings(
            title: "Cards",
            instructions: nil,
            enabledForMethod: [.collection],
            paymentGateways: ["worldpay", "stripe", "realex"],
            saveCards: nil,
            cutOffTime: nil
        )
    )
    
    var recordsCount: Int {
        return 1 + settings.enabledForMethod.count + (settings.paymentGateways?.count ?? 0)
    }
}

extension PaymentGateway {
    
    static let mockedCheckoutcomData = PaymentGateway(
        name: "checkoutcom",
        mode: .sandbox,
        fields: [
            "applePayMerchantId": "merchant.5.com.mtcmobile.My-Mini-Mart",
            "publicKey": "pk_test_6ff46046-30af-41d9-bf58-929022d2cd14"
        ]
    )
    
    static let mockedCheckoutcomDataWithTestMode = PaymentGateway(
        name: "checkoutcom",
        mode: .test,
        fields: [
            "applePayMerchantId": "merchant.5.com.mtcmobile.My-Mini-Mart",
            "publicKey": "pk_test_6ff46046-30af-41d9-bf58-929022d2cd14"
        ]
    )
    
    static let mockedWorldpayData = PaymentGateway(
        name: "worldpay",
        mode: .sandbox,
        fields: [
            "merchantId": "45015cbe-24c9-4910-a3f4-2cbcb2d4f7ed",
            "clientKey": "L_C_cd36f34e-751e-4bdb-b14e-78100dd1658a",
            "boolTest": true,
            "doubleTest": 1.23,
            "integerTest": 34
        ]
    )
    
    static let mockedStripeData = PaymentGateway(
        name: "stripe",
        mode: .sandbox,
        fields: [
            "publicKey": "pk_test_H8UdbUUr0pHhI9872kcLbH6b",
            "applePayMerchantId": "merchant.7.com.mtcmobile.My-Mini-Mart",
            "googlePayMerchantId": ""
        ]
    )
    
    static let mockedRealexData = PaymentGateway(
        name: "realex",
        mode: .sandbox,
        fields: [
            "account": "3DS2",
            "hppVersion": "v2",
            "hppURL": "https://pay.sandbox.realexpayments.com/pay",
            "applePayMerchantId": "merchant.7.com.mtcmobile.My-Mini-Mart",
            "merchantId": "snappyshopperltd",
            "googlePayMerchantId": ""
        ]
    )
    
    var recordsCount: Int {
        return 1 + (fields?.count ?? 0)
    }
}

extension FutureContactRequestResponse {
    
    static let mockedData = FutureContactRequestResponse(
        result: FutureContactRequestResponseResult(
            status: true,
            message: "Email recorded",
            errors: nil
        )
    )
    
}

extension RetailStoreReview {
    
    static let mockedData = RetailStoreReview(
        orderId: 12345,
        hash: "eff123456ad4",
        logo: URL(string: "https://www.snappyshopper.co.uk/uploads/images/stores/xxhdpi_3x/1585850492Untitleddesign33.png")!,
        name: "1st Stop 2 Shop Forfar",
        address: "81 South St\nDD8 2BS"
    )
    
}

extension RetailStoreReviewResponse {
    
    static let mockedData = RetailStoreReviewResponse(status: true)
    
}

extension RetailStoreCustomer {
    
    static let mockedDataWithMembership = RetailStoreCustomer(
        hasMembership: true,
        membershipIdPromptText: "If you ACME membership, then please enter your number in the field below.",
        membershipIdFieldPlaceholder: "ACME Membership ID"
    )
    
}
