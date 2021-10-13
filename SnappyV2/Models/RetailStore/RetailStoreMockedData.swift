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
        fulfilmentLocation: FulfilmentLocation.mockedData
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

extension FulfilmentLocation {
    static let mockedData = FulfilmentLocation(
        countryCode: "UK",
        lat: -2.95885,
        lng: 56.462502000000001,
        postcode: "DD1 3JA"
    )
}

extension RetailStoreDetails {
    static let mockedData = RetailStoreDetails(
        id: 30,
        menuGroupId: 30,
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
                fulfilmentIn: "2 hour(s)"
            ),
            "collection" : RetailStoreOrderMethod(
                name: .collection,
                earliestTime: "11:00 - 11:05",
                status: .open,
                cost: 0,
                fulfilmentIn: "1 hour(s)"
            )
        ],
        deliveryDays: [
            RetailStoreFulfilmentDay(
                date: "2021-10-12",
                start: "09:30:00",
                end: "22:30:00",
                storeDate: nil
            ),
            RetailStoreFulfilmentDay(
                date: "2021-10-13",
                start: "09:30:00",
                end: "22:30:00",
                storeDate: nil
            )
        ],
        collectionDays: [
            RetailStoreFulfilmentDay(
                date: "2021-10-12",
                start: "09:30:00",
                end: "22:30:00",
                storeDate: nil
            ),
            RetailStoreFulfilmentDay(
                date: "2021-10-13",
                start: "09:30:00",
                end: "22:30:00",
                storeDate: nil
            )
        ],
        timeZone: "Europe/London",
        searchPostcode: "DD1 3JA"
    )
}

extension RetailStoreTimeSlots {
    static let mockedData: RetailStoreTimeSlots = {
        
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
            searchStoreId: 30,
            searchLatitude: 56.473358599999997,
            searchLongitude: -3.0111853000000002
        )
    }()
}

extension RetailStoreSlotDay {
    static func mockedData(start: Date, end: Date, timeZone: TimeZone) -> [RetailStoreSlotDay] {
        
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = timeZone
        formatter.dateFormat = "yyyy-MM-dd"
        
        return [
            RetailStoreSlotDay(
                status: "available",
                reason: "",
                slotDate: formatter.string(from: start),
                slots: RetailStoreSlotDayTimeSlot.mockedData(start: start, end: end, timeZone: timeZone)
            )
        ]
    }
}

extension RetailStoreSlotDayTimeSlot {
    static func mockedData(start: Date, end: Date, timeZone: TimeZone) -> [RetailStoreSlotDayTimeSlot] {
        
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = timeZone
        formatter.dateFormat = "yyyy-MM-dd"
        
        return [
            //RetailStoreSlotDayTimeSlot(slotId: <#T##String#>, startTime: <#T##Date#>, endTime: <#T##Date#>, daytime: <#T##RetailStoreSlotDayTimeSlotDaytime#>, info: <#T##RetailStoreSlotDayTimeSlotInfo#>)
        ]
    }
}

#endif
