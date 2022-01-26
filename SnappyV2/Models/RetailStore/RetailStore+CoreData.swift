//
//  RetailStore+CoreData.swift
//  SnappyV2
//
//  Created by Kevin Palser on 21/09/2021.
//

import Foundation
import CoreData

extension RetailStoresSearchMO: ManagedEntity { }
extension RetailStoreMO: ManagedEntity { }
extension RetailStoreOrderMethodMO: ManagedEntity { }
extension RetailStoreProductTypeMO: ManagedEntity { }
extension RetailStoreProductTypeImageMO: ManagedEntity { }
extension RetailStoreDetailsMO: ManagedEntity { }
extension RetailStoreFulfilmentDayMO: ManagedEntity { }
extension RetailStoreTimeSlotsMO: ManagedEntity { }
extension RetailStoreSlotDayMO: ManagedEntity { }
extension RetailStoreSlotDayTimeSlotMO: ManagedEntity { }

extension RetailStoresSearch {
    
    init?(managedObject: RetailStoresSearchMO) {
        
        var storeProductTypes: [RetailStoreProductType]?
        var stores: [RetailStore]?
        
        if
            let productTypesFound = managedObject.productTypesFound,
            let productTypesFoundArray = productTypesFound.array as? [RetailStoreProductTypeMO]
        {
            storeProductTypes = productTypesFoundArray
                .reduce(nil, { (productTypeArray, record) -> [RetailStoreProductType]? in
                    guard let productType = RetailStoreProductType(managedObject: record)
                    else { return productTypeArray }
                    var array = productTypeArray ?? []
                    array.append(productType)
                    return array
                })
        }
        
        if
            let storesFound = managedObject.storesFound,
            let storesFoundArray = storesFound.array as? [RetailStoreMO]
        {
            stores = storesFoundArray
                .reduce(nil, { (storeArray, record) -> [RetailStore]? in
                    guard let store = RetailStore(managedObject: record)
                    else { return storeArray }
                    var array = storeArray ?? []
                    array.append(store)
                    return array
                })
        }
        
        self.init(
            storeProductTypes: storeProductTypes,
            stores: stores,
            fulfilmentLocation: FulfilmentLocation(
                country: managedObject.countryCode ?? "",
                latitude: managedObject.latitude?.doubleValue ?? 0,
                longitude: managedObject.longitude?.doubleValue ?? 0,
                postcode: managedObject.postcode ?? ""
            )
        )
    }
    
    @discardableResult
    func store(in context: NSManagedObjectContext) -> RetailStoresSearchMO? {
        
        guard let search = RetailStoresSearchMO.insertNew(in: context)
            else { return nil }
        
        var productTypesDictionary: [Int: RetailStoreProductTypeMO] = [:]
        
        if let productTypes = storeProductTypes {
            search.productTypesFound = NSOrderedSet(array: productTypes.compactMap({ productType -> RetailStoreProductTypeMO? in
                let productTypeMO = productType.store(in: context)
                if let productTypeMO = productTypeMO {
                    productTypesDictionary[Int(productTypeMO.id)] = productTypeMO
                }
                return productTypeMO
            }))
        }
        
        if let stores = stores {
            search.storesFound = NSOrderedSet(array: stores.compactMap({ retailStore -> RetailStoreMO? in
                let retailStoreMO = retailStore.store(in: context)
                if
                    let retailStoreMO = retailStoreMO,
                    let storeProductTypes = retailStore.storeProductTypes
                {
                    retailStoreMO.productTypes = NSOrderedSet(array: storeProductTypes.compactMap({ productTypeId -> RetailStoreProductTypeMO? in
                        return productTypesDictionary[productTypeId]
                    }))
                }
                return retailStoreMO
            }))
        }
        
        search.postcode = fulfilmentLocation.postcode
        search.latitude = NSNumber(value: fulfilmentLocation.latitude)
        search.longitude = NSNumber(value: fulfilmentLocation.longitude)
        search.countryCode = fulfilmentLocation.country
        
        search.timestamp = Date()
        
        return search
    }
}

extension RetailStore {
    
    init?(managedObject: RetailStoreMO) {
        
        var storeLogo: [String : URL]?
        var storeProductTypes: [Int]?
        var orderMethods: [String: RetailStoreOrderMethod]?
        
        if
            let logos = managedObject.logoImages,
            let logosArray = logos.array as? [ImagePathMO]
        {
            storeLogo = logosArray
                .reduce(nil, { (dict, record) -> [String: URL]? in
                    guard
                        let scale = record.scale,
                        let url = record.url
                    else { return dict }
                    var dict = dict ?? [:]
                    dict[scale] = url
                    return dict
                })
        }
        
        if
            let productTypes = managedObject.productTypes,
            let productTypesArray = productTypes.array as? [RetailStoreProductTypeMO]
        {
            storeProductTypes = productTypesArray
                .reduce(nil, { (intArray, record) -> [Int]? in
                    var array = intArray ?? []
                    array.append(Int(record.id))
                    return array
                })
        }
        
        if let methods = managedObject.orderMethods {
            orderMethods = methods
                .toArray(of: RetailStoreOrderMethodMO.self)
                .reduce(nil, { (dict, record) -> [String: RetailStoreOrderMethod]? in
                    guard
                        let orderMethod = RetailStoreOrderMethod(managedObject: record)
                    else { return dict }
                    var dict = dict ?? [:]
                    dict[orderMethod.name.rawValue] = orderMethod
                    return dict
                })
        }
        
        self.init(
            id: Int(managedObject.id),
            storeName: managedObject.name ?? "",
            distance: managedObject.distance,
            storeLogo: storeLogo,
            storeProductTypes: storeProductTypes,
            orderMethods: orderMethods
        )

    }
    
    @discardableResult
    func store(in context: NSManagedObjectContext) -> RetailStoreMO? {
        
        guard let store = RetailStoreMO.insertNew(in: context)
            else { return nil }
        
        store.id = Int64(id)
        store.name = storeName
        store.distance = distance

        if let images = storeLogo {
            store.logoImages = NSOrderedSet(array: images.compactMap({ (scale, url) -> ImagePathMO? in
                guard let logo = ImagePathMO.insertNew(in: context)
                else { return nil }
                logo.scale = scale
                logo.url = url
                return logo
            }))
        }
        
        if let methods = orderMethods {
            store.orderMethods = NSSet(array: methods.compactMap({ (_, method) -> RetailStoreOrderMethodMO? in
                return method.store(in: context)
            }))
        }
        
        return store
    }
    
}

extension RetailStoreOrderMethod {
    
    init?(managedObject: RetailStoreOrderMethodMO) {
        
        let name: RetailStoreOrderMethodType
        if
            let dbName = managedObject.name,
            let methodName = RetailStoreOrderMethodType(rawValue: dbName)
        {
            name = methodName
        } else {
            name = .delivery
        }
        
        let status: RetailStoreOrderMethodStatus
        if
            let dbStatus = managedObject.status,
            let methodStatus = RetailStoreOrderMethodStatus(rawValue: dbStatus)
        {
            status = methodStatus
        } else {
            status = .open
        }
        
        self.init(
            name: name,
            earliestTime: managedObject.earliestTime,
            status: status,
            cost: managedObject.cost?.doubleValue,
            fulfilmentIn: managedObject.fulfilmentIn
        )
    }
    
    @discardableResult
    func store(in context: NSManagedObjectContext) -> RetailStoreOrderMethodMO? {
        
        guard let orderMethod = RetailStoreOrderMethodMO.insertNew(in: context)
            else { return nil }
        
        orderMethod.name = name.rawValue
        orderMethod.earliestTime = earliestTime
        orderMethod.status = status.rawValue
        if let cost = cost {
            orderMethod.cost = NSNumber(value: cost)
        }
        orderMethod.fulfilmentIn = fulfilmentIn
        
        return orderMethod
    }
    
}

extension RetailStoreProductType {
    
    init?(managedObject: RetailStoreProductTypeMO) {
        
        var typeLogo: [String : URL]?
        
        if let images = managedObject.images {
            typeLogo = images
                .toArray(of: RetailStoreProductTypeImageMO.self)
                .reduce(nil, { (dict, record) -> [String: URL]? in
                    guard
                        let scale = record.scale,
                        let url = record.url
                    else { return dict }
                    var dict = dict ?? [:]
                    dict[scale] = url
                    return dict
                })
        }

        self.init(
            id: Int(managedObject.id),
            name: managedObject.name ?? "",
            image: typeLogo
        )
    }
    
    @discardableResult
    func store(in context: NSManagedObjectContext) -> RetailStoreProductTypeMO? {
        
        guard let productType = RetailStoreProductTypeMO.insertNew(in: context)
            else { return nil }
        
        productType.id = Int64(id)
        productType.name = name

        if let imageArray = image {
            let productTypeImages = imageArray.compactMap({ (scale, url) -> RetailStoreProductTypeImageMO? in
                guard let image = RetailStoreProductTypeImageMO.insertNew(in: context)
                else { return nil }
                image.scale = scale
                image.url = url
                return image
            })
            
            if productTypeImages.count != 0 {
                productType.images = NSSet(array: productTypeImages)
            }
        }
        
        return productType
    }
    
}

extension RetailStoreDetails {
    
    init?(managedObject: RetailStoreDetailsMO) {
        
        let distance: Double?
        if let distanceMO = managedObject.distance {
            distance = distanceMO.doubleValue
        } else {
            distance = nil
        }
        
        var storeLogo: [String : URL]?
        var storeProductTypes: [Int]?
        var orderMethods: [String: RetailStoreOrderMethod]?
        var deliveryDays: [RetailStoreFulfilmentDay]?
        var collectionDays: [RetailStoreFulfilmentDay]?
        
        if
            let logos = managedObject.logoImages,
            let logosArray = logos.array as? [ImagePathMO]
        {
            storeLogo = logosArray
                .reduce(nil, { (dict, record) -> [String: URL]? in
                    guard
                        let scale = record.scale,
                        let url = record.url
                    else { return dict }
                    var dict = dict ?? [:]
                    dict[scale] = url
                    return dict
                })
        }
        
        if
            let productTypes = managedObject.productTypes,
            let productTypesArray = productTypes.array as? [RetailStoreProductTypeMO]
        {
            storeProductTypes = productTypesArray
                .reduce(nil, { (intArray, record) -> [Int]? in
                    var array = intArray ?? []
                    array.append(Int(record.id))
                    return array
                })
        }
        
        if let methods = managedObject.orderMethods {
            orderMethods = methods
                .toArray(of: RetailStoreOrderMethodMO.self)
                .reduce(nil, { (dict, record) -> [String: RetailStoreOrderMethod]? in
                    guard
                        let orderMethod = RetailStoreOrderMethod(managedObject: record)
                    else { return dict }
                    var dict = dict ?? [:]
                    dict[orderMethod.name.rawValue] = orderMethod
                    return dict
                })
        }
        
        if
            let fulfilmentDays = managedObject.fulfilmentDays,
            let fulfilmentDaysArray = fulfilmentDays.array as? [RetailStoreFulfilmentDayMO]
        {
            for storeDay in fulfilmentDaysArray {
                if let day = RetailStoreFulfilmentDay(managedObject: storeDay, timeZone: managedObject.timeZone) {
                    if storeDay.type == "delivery" {
                        deliveryDays = deliveryDays ?? []
                        deliveryDays?.append(day)
                    } else {
                        collectionDays = collectionDays ?? []
                        collectionDays?.append(day)
                    }
                }
            }
        }
        
        self.init(
            id: Int(managedObject.id),
            menuGroupId: Int(managedObject.menuGroupId),
            storeName: managedObject.storeName ?? "",
            telephone: managedObject.telephone ?? "",
            lat: managedObject.latitude,
            lng: managedObject.longitude,
            ordersPaused: managedObject.ordersPaused,
            canDeliver: managedObject.canDeliver,
            distance: distance,
            pausedMessage: managedObject.pausedMessage,
            address1: managedObject.address1 ?? "",
            address2: managedObject.address2, // optional
            town: managedObject.town ?? "",
            postcode: managedObject.postcode ?? "",
            storeLogo: storeLogo,
            storeProductTypes: storeProductTypes,
            orderMethods: orderMethods,
            deliveryDays: deliveryDays,
            collectionDays: collectionDays,
            timeZone: managedObject.timeZone,
            // populated by request and cached data
            searchPostcode: managedObject.searchPostcode
            
        )
    }
    
    @discardableResult
    func store(in context: NSManagedObjectContext) -> RetailStoreDetailsMO? {
        
        guard let storeDetails = RetailStoreDetailsMO.insertNew(in: context)
            else { return nil }
        
        storeDetails.id = Int64(id)
        storeDetails.menuGroupId = Int64(menuGroupId)
        storeDetails.storeName = storeName
        storeDetails.telephone = telephone
        storeDetails.latitude = lat
        storeDetails.longitude = lng
        storeDetails.ordersPaused = ordersPaused
        storeDetails.canDeliver = canDeliver
        storeDetails.timeZone = timeZone
        
        if let distance = distance {
            storeDetails.distance = NSNumber(value: distance)
        }
        
        storeDetails.pausedMessage = pausedMessage
        storeDetails.address1 = address1
        storeDetails.address2 = address2
        storeDetails.town = town
        storeDetails.postcode = postcode
        
        if let images = storeLogo {
            storeDetails.logoImages = NSOrderedSet(array: images.compactMap({ (scale, url) -> ImagePathMO? in
                guard let logo = ImagePathMO.insertNew(in: context)
                else { return nil }
                logo.scale = scale
                logo.url = url
                return logo
            }))
        }
        
        if let productTypes = storeProductTypes {
            storeDetails.productTypes = NSOrderedSet(array: productTypes.compactMap({ productTypeId -> RetailStoreProductTypeMO? in
                let productTypeMO = RetailStoreProductTypeMO.insertNew(in: context)
                productTypeMO?.id = Int64(productTypeId)
                productTypeMO?.name = "dummy entry"
                return productTypeMO
            }))
        }
        
        if let methods = orderMethods {
            storeDetails.orderMethods = NSSet(array: methods.compactMap({ (_, method) -> RetailStoreOrderMethodMO? in
                return method.store(in: context)
            }))
        }
        
        var fulfilmentDays = NSMutableOrderedSet()
        if let deliveryDays = deliveryDays {
            fulfilmentDays = NSMutableOrderedSet(array: deliveryDays.compactMap({ day -> RetailStoreFulfilmentDayMO? in
                return day.store(in: context, type: "delivery")
            }))
        }
        if let collectionDays = collectionDays {
            fulfilmentDays.addObjects(
                from: collectionDays.compactMap({ day -> RetailStoreFulfilmentDayMO? in
                    return day.store(in: context, type: "collection")
                })
            )
        }
        storeDetails.fulfilmentDays = fulfilmentDays
        
        storeDetails.timestamp = Date()
        
        return storeDetails
    }
    
}

extension RetailStoreFulfilmentDay {
    
    init?(managedObject: RetailStoreFulfilmentDayMO, timeZone: String?) {
        
        // pass back a date object as a convenience for the service consumers
        var startDate: Date?
        var endDate: Date?
        
        if let date = managedObject.date {
            
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
            
            startDate = formatter.date(from: date + " 00:00:00")
            endDate = formatter.date(from: date + " 23:59:59")
        }
        
        self.init(
            date: managedObject.date ?? "",
            start: managedObject.start ?? "",
            end: managedObject.end ?? "",
            storeDateStart: startDate,
            storeDateEnd: endDate
        )
    }
    
    @discardableResult
    func store(in context: NSManagedObjectContext, type: String) -> RetailStoreFulfilmentDayMO? {
        
        guard let day = RetailStoreFulfilmentDayMO.insertNew(in: context)
            else { return nil }
        
        day.type = type
        day.date = date
        day.start = start
        day.end = end
        
        return day
    }
    
}

extension RetailStoreTimeSlots {
    
    init?(managedObject: RetailStoreTimeSlotsMO) {
        
        var slotDays: [RetailStoreSlotDay]?
        
        if
            let slotDaysMO = managedObject.slotDays,
            let slotDaysArray = slotDaysMO.array as? [RetailStoreSlotDayMO]
        {
            slotDays = slotDaysArray
                .reduce(nil, { (slotArray, record) -> [RetailStoreSlotDay]? in
                    guard let slot = RetailStoreSlotDay(managedObject: record)
                    else { return slotArray }
                    var array = slotArray ?? []
                    array.append(slot)
                    return array
                })
        }
        
        self.init(
            startDate: managedObject.startDate ?? Date(),
            endDate: managedObject.endDate ?? Date(),
            fulfilmentMethod: managedObject.fulfilmentMethod ?? "",
            slotDays: slotDays,
            searchStoreId: Int(managedObject.storeId),
            searchLatitude: managedObject.latitude?.doubleValue,
            searchLongitude: managedObject.longitude?.doubleValue
        )
    }
    
    @discardableResult
    func store(in context: NSManagedObjectContext) -> RetailStoreTimeSlotsMO? {
        
        guard let timeSlots = RetailStoreTimeSlotsMO.insertNew(in: context)
            else { return nil }
        
        timeSlots.startDate = startDate
        timeSlots.endDate = endDate
        timeSlots.fulfilmentMethod = fulfilmentMethod
        
        if let slotDays = slotDays {
            timeSlots.slotDays = NSOrderedSet(array: slotDays.compactMap({ day -> RetailStoreSlotDayMO? in
                return day.store(in: context)
            }))
        }
        
        timeSlots.timestamp = Date()
        
        return timeSlots
    }
    
}

extension RetailStoreSlotDay {
    
    init?(managedObject: RetailStoreSlotDayMO) {
        
        var slots: [RetailStoreSlotDayTimeSlot]?
        
        if
            let dayTimeSlots = managedObject.dayTimeSlots,
            let dayTimeSlotsArray = dayTimeSlots.array as? [RetailStoreSlotDayTimeSlotMO]
        {
            slots = dayTimeSlotsArray
                .reduce(nil, { (slotArray, record) -> [RetailStoreSlotDayTimeSlot]? in
                    guard let slot = RetailStoreSlotDayTimeSlot(managedObject: record)
                    else { return slotArray }
                    var array = slotArray ?? []
                    array.append(slot)
                    return array
                })
        }
        
        self.init(
            status: managedObject.status ?? "",
            reason: managedObject.reason ?? "",
            slotDate: managedObject.slotDate ?? "",
            slots: slots
        )
    }
    
    @discardableResult
    func store(in context: NSManagedObjectContext) -> RetailStoreSlotDayMO? {
        
        guard let slotDay = RetailStoreSlotDayMO.insertNew(in: context)
            else { return nil }
        
        slotDay.status = status
        slotDay.reason = reason
        slotDay.slotDate = slotDate
        
        if let slots = slots {
            slotDay.dayTimeSlots = NSOrderedSet(array: slots.compactMap({ slot -> RetailStoreSlotDayTimeSlotMO? in
                return slot.store(in: context)
            }))
        }
        
        return slotDay
    }
    
}

extension RetailStoreSlotDayTimeSlot {
    
    init?(managedObject: RetailStoreSlotDayTimeSlotMO) {
        
        self.init(
            slotId: managedObject.slotId ?? "",
            startTime: managedObject.startTime ?? Date(),
            endTime: managedObject.endTime ?? Date(),
            daytime: managedObject.daytime ?? "",
            info: RetailStoreSlotDayTimeSlotInfo(
                status: managedObject.status ?? "",
                isAsap: managedObject.isAsap,
                price: managedObject.price,
                fulfilmentIn: managedObject.fulfilmentIn ?? ""
            )
        )
    }
    
    @discardableResult
    func store(in context: NSManagedObjectContext) -> RetailStoreSlotDayTimeSlotMO? {
        
        guard let timeSlot = RetailStoreSlotDayTimeSlotMO.insertNew(in: context)
            else { return nil }
        
        timeSlot.slotId = slotId
        timeSlot.startTime = startTime
        timeSlot.endTime = endTime
        timeSlot.daytime = daytime
        
        timeSlot.status = info.status
        timeSlot.isAsap = info.isAsap
        timeSlot.price = info.price
        timeSlot.fulfilmentIn = info.fulfilmentIn
        
        return timeSlot
    }
    
}
