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
    
    var recordsCount: Int {
        return 1 + (image?.count ?? 0)
    }
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
            ],
            ratings: RetailStoreRatings(averageRating: 4.8, numRatings: 375)
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
            ],
            ratings: nil
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
            ],
            ratings: nil
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
            start: "09:30:00",
            end: "22:30:00",
            storeDateStart: nil,
            storeDateEnd: nil
        )

        let fulfilmentDay2 = RetailStoreFulfilmentDay(
            date: "2021-10-13",
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
            ratings: RetailStoreRatings(averageRating: 4.8, numRatings: 379),
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
                fulfilmentDay1,
                fulfilmentDay2
            ],
            collectionDays: [
                fulfilmentDay1,
                fulfilmentDay2
            ],
            timeZone: "Europe/London",
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
            start: "09:30:00",
            end: "22:30:00",
            storeDateStart: fulfilmentDay1StartAndEnd?.start,
            storeDateEnd: fulfilmentDay1StartAndEnd?.end
        )

        let fulfilmentDay2 = RetailStoreFulfilmentDay(
            date: "2021-10-13",
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
            ratings: RetailStoreRatings(averageRating: 4.8, numRatings: 379),
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
                fulfilmentDay1,
                fulfilmentDay2
            ],
            collectionDays: [
                fulfilmentDay1,
                fulfilmentDay2
            ],
            timeZone: timeZone,
            searchPostcode: "DD1 3JA"
        )
    }
    
    var recordsCount: Int {
        // note that storeProductTypes is not counted because the entries generated
        // based on the same records within RetailStoresSearch.storeProductTypes
        return 1 + (storeLogo?.count ?? 0) + (storeProductTypes?.count ?? 0) + (orderMethods?.count ?? 0) + (deliveryDays?.count ?? 0) + (collectionDays?.count ?? 0) + (ratings != nil ? 1 : 0)
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