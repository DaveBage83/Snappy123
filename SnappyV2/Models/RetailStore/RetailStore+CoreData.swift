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
extension RetailStoreRatingsMO: ManagedEntity { }
extension PaymentMethodMO: ManagedEntity { }
extension PaymentGatewayMO: ManagedEntity { }
extension PaymentMethodSettingsEnabledMethodMO: ManagedEntity { }
extension PaymentGatewayFieldMO: ManagedEntity { }
extension PaymentMethodGatewayMO: ManagedEntity { }
extension RetailStoreTipMO: ManagedEntity { }
extension AllowedMarketingChannelMO: ManagedEntity { }
extension RetailStoreCustomerMO: ManagedEntity { }
extension DeliveryTierMO: ManagedEntity { }

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
        
        search.timestamp = Date().trueDate
        
        return search
    }
}

extension RetailStore {
    
    init?(managedObject: RetailStoreMO) {
        
        var storeLogo: [String : URL]?
        var storeProductTypes: [Int]?
        var orderMethods: [String: RetailStoreOrderMethod]?
        var ratings: RetailStoreRatings?
        
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
        
        if let ratingsMO = managedObject.ratings {
            ratings = RetailStoreRatings(managedObject: ratingsMO)
        }
        
        self.init(
            id: Int(managedObject.id),
            storeName: managedObject.name ?? "",
            distance: managedObject.distance,
            storeLogo: storeLogo,
            storeProductTypes: storeProductTypes,
            orderMethods: orderMethods,
            ratings: ratings,
            currency: RetailStoreCurrency(
                currencyCode: managedObject.currencyCode ?? "",
                symbol: managedObject.currencySymbol ?? "",
                ratio: managedObject.currencyRatio,
                symbolChar: managedObject.currencySymbolChar ?? "",
                name: managedObject.currencyName ?? ""
            )
        )

    }
    
    @discardableResult
    func store(in context: NSManagedObjectContext) -> RetailStoreMO? {
        
        guard let store = RetailStoreMO.insertNew(in: context)
            else { return nil }
        
        store.id = Int64(id)
        store.name = storeName
        store.distance = distance
        store.currencyCode = currency.currencyCode
        store.currencySymbol = currency.symbol
        store.currencyRatio = currency.ratio
        store.currencySymbolChar = currency.symbolChar
        store.currencyName = currency.name

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
        
        if let ratings = ratings {
            store.ratings = ratings.store(in: context)
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
        
        var deliveryTiers = [DeliveryTier]()
        
        if
            let storedDeliveryTiers = managedObject.deliveryTiers,
            let deliveryTiersArray = storedDeliveryTiers.array as? [DeliveryTierMO]
        {
            deliveryTiersArray.forEach { tier in
                deliveryTiers.append(.init(minBasketSpend: tier.minBasketSpend, deliveryFee: tier.deliveryFee))
            }
        }
        
        self.init(
            name: name,
            earliestTime: managedObject.earliestTime,
            status: status,
            cost: managedObject.cost?.doubleValue,
            fulfilmentIn: managedObject.fulfilmentIn,
            freeFulfilmentMessage: managedObject.freeFulfilmentMessage,
            deliveryTiers: deliveryTiers.isEmpty ? nil : deliveryTiers,
            freeFrom: managedObject.freeFrom?.doubleValue,
            minSpend: managedObject.minSpend?.doubleValue,
            earliestOpeningDate: managedObject.earliestOpeningDate
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
        orderMethod.freeFulfilmentMessage = freeFulfilmentMessage
        orderMethod.earliestOpeningDate = earliestOpeningDate
        
        if let freeFrom = freeFrom {
            orderMethod.freeFrom = NSNumber(value: freeFrom)
        }
        
        if
            let deliveryTiers = deliveryTiers,
            deliveryTiers.count > 0
        {
            orderMethod.deliveryTiers = NSOrderedSet(array: deliveryTiers.compactMap({ tier -> DeliveryTierMO? in
                return tier.store(in: context)
            }))
        }
        
        if let minSpend = minSpend {
            orderMethod.minSpend = NSNumber(value: minSpend)
        }
        
        return orderMethod
    }
}

extension DeliveryTier {
    @discardableResult
    func store(in context: NSManagedObjectContext) -> DeliveryTierMO? {
        
        guard let tier = DeliveryTierMO.insertNew(in: context)
            else { return nil }

        tier.deliveryFee = deliveryFee
        tier.minBasketSpend = minBasketSpend
        
        return tier
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
        
        let memberEmailCheck: Bool?
        if let memberEmailCheckMO = managedObject.memberEmailCheck {
            memberEmailCheck = memberEmailCheckMO.boolValue
        } else {
            memberEmailCheck = nil
        }
        
        let retailCustomer: RetailStoreCustomer?
        if let retailCustomerMO = managedObject.retailCustomer {
            retailCustomer = RetailStoreCustomer(managedObject: retailCustomerMO)
        } else {
            retailCustomer = nil
        }
        
        var storeLogo: [String : URL]?
        var storeProductTypes: [Int]?
        var orderMethods: [String: RetailStoreOrderMethod]?
        var deliveryDays: [RetailStoreFulfilmentDay]?
        var collectionDays: [RetailStoreFulfilmentDay]?
        var ratings: RetailStoreRatings?
        var paymentMethods: [PaymentMethod]?
        var paymentGateways: [PaymentGateway]?
        var tips: [RetailStoreTip]?
        var allowedMarketingChannels: [AllowedMarketingChannel]?
        
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
        
        if let channels = managedObject.allowedMarketingChannels,
           let channelsArray = channels.array as? [AllowedMarketingChannelMO]
        {
            allowedMarketingChannels = channelsArray
                .compactMap({ channel in
                    return AllowedMarketingChannel(id: Int(channel.id), name: channel.name ?? "")
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
        
        if let tipsArray = managedObject.tips?.array as? [RetailStoreTipMO] {
            tips = tipsArray
                .reduce(nil, { (tipsArray, record) -> [RetailStoreTip]? in
                    guard let tip = RetailStoreTip(managedObject: record) else {
                        return tipsArray
                    }
                    var array = tipsArray ?? []
                    array.append(tip)
                    return array
                })
        }
        
        if let ratingsMO = managedObject.ratings {
            ratings = RetailStoreRatings(managedObject: ratingsMO)
        }
        
        if let paymentMethodsArray = managedObject.paymentMethods?.array as? [PaymentMethodMO] {
            paymentMethods = paymentMethodsArray
                .reduce(nil, { (methodArray, record) -> [PaymentMethod]? in
                    guard let paymentMethod = PaymentMethod(managedObject: record) else {
                        return methodArray
                    }
                    var array = methodArray ?? []
                    array.append(paymentMethod)
                    return array
                })
        }
        
        if let paymentGatewaysArray = managedObject.paymentGateways?.array as? [PaymentGatewayMO] {
            paymentGateways = paymentGatewaysArray
                .reduce(nil, { (gatewayArray, record) -> [PaymentGateway]? in
                    guard let gateway = PaymentGateway(managedObject: record) else {
                        return gatewayArray
                    }
                    var array = gatewayArray ?? []
                    array.append(gateway)
                    return array
                })
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
            customerOrderNotePlaceholder: managedObject.customerOrderNotePlaceholder,
            memberEmailCheck: memberEmailCheck,
            guestCheckoutAllowed: managedObject.guestCheckoutAllowed,
            basketOnlyTimeSelection: managedObject.basketOnlyTimeSelection,
            ratings: ratings,
            tips: tips,
            storeLogo: storeLogo,
            storeProductTypes: storeProductTypes,
            orderMethods: orderMethods,
            deliveryDays: deliveryDays ?? [],
            collectionDays: collectionDays ?? [],
            paymentMethods: paymentMethods,
            paymentGateways: paymentGateways,
            allowedMarketingChannels: allowedMarketingChannels ?? [],
            timeZone: managedObject.timeZone,
            currency: RetailStoreCurrency(
                currencyCode: managedObject.currencyCode ?? "",
                symbol: managedObject.currencySymbol ?? "",
                ratio: managedObject.currencyRatio,
                symbolChar: managedObject.currencySymbolChar ?? "",
                name: managedObject.currencyName ?? ""
            ),
            retailCustomer: retailCustomer,
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
        storeDetails.customerOrderNotePlaceholder = customerOrderNotePlaceholder
        if let memberEmailCheck = memberEmailCheck {
            storeDetails.memberEmailCheck = NSNumber(value: memberEmailCheck)
        }
        storeDetails.guestCheckoutAllowed = guestCheckoutAllowed
        storeDetails.basketOnlyTimeSelection = basketOnlyTimeSelection
        storeDetails.currencyCode = currency.currencyCode
        storeDetails.currencySymbol = currency.symbol
        storeDetails.currencyRatio = currency.ratio
        storeDetails.currencySymbolChar = currency.symbolChar
        storeDetails.currencyName = currency.name
        
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
        
        storeDetails.allowedMarketingChannels = NSOrderedSet(array: allowedMarketingChannels.compactMap({ channel -> AllowedMarketingChannelMO? in
            let allowedMarketingChannel = AllowedMarketingChannelMO.insertNew(in: context)
            allowedMarketingChannel?.name = channel.name
            allowedMarketingChannel?.id = Int64(channel.id)
            return allowedMarketingChannel
        }))
        
        var fulfilmentDays = NSMutableOrderedSet()
        fulfilmentDays = NSMutableOrderedSet(array: deliveryDays.compactMap({ day -> RetailStoreFulfilmentDayMO? in
            return day.store(in: context, type: "delivery")
        }))
        fulfilmentDays.addObjects(
            from: collectionDays.compactMap({ day -> RetailStoreFulfilmentDayMO? in
                return day.store(in: context, type: "collection")
            })
        )
        storeDetails.fulfilmentDays = fulfilmentDays
        
        if let ratings = ratings {
            storeDetails.ratings = ratings.store(in: context)
        }
        
        if let tips = tips {
            storeDetails.tips = NSOrderedSet(array: tips.compactMap({ tip -> RetailStoreTipMO? in
                return tip.store(in: context)
            }))
        }
        
        if let paymentMethods = paymentMethods {
            storeDetails.paymentMethods = NSOrderedSet(array: paymentMethods.compactMap({ paymentMethod -> PaymentMethodMO? in
                return paymentMethod.store(in: context)
            }))
        }
        
        if let paymentGateways = paymentGateways {
            storeDetails.paymentGateways = NSOrderedSet(array: paymentGateways.compactMap({ gateway -> PaymentGatewayMO? in
                return gateway.store(in: context)
            }))
        }
        
        if let retailCustomer = retailCustomer {
            storeDetails.retailCustomer = retailCustomer.store(in: context)
        }
        
        storeDetails.timestamp = Date().trueDate
        
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
            holidayMessage: managedObject.holidayMessage,
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
        day.holidayMessage = holidayMessage
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
        
        timeSlots.timestamp = Date().trueDate
        
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

extension RetailStoreRatings {

    init?(managedObject: RetailStoreRatingsMO) {
        self.init(
            averageRating: managedObject.averageRatings,
            numRatings: Int(managedObject.numRatings)
        )
    }
    
    @discardableResult
    func store(in context: NSManagedObjectContext) -> RetailStoreRatingsMO? {
        
        guard let ratings = RetailStoreRatingsMO.insertNew(in: context)
            else { return nil }
        
        ratings.averageRatings = averageRating
        ratings.numRatings = Int64(numRatings)
        
        return ratings
    }
    
}

extension PaymentMethod {
    
    init?(managedObject: PaymentMethodMO) {
        
        var saveCards: Bool?
        if let settingsSavedCards = managedObject.settingsSavedCards {
            saveCards = settingsSavedCards.boolValue
        }
        
        var enabledForMethods: [RetailStoreOrderMethodType] = []
        if let enabledForMethodsMOArray = managedObject.enabledForMethods?.array as? [PaymentMethodSettingsEnabledMethodMO] {
            enabledForMethods = enabledForMethodsMOArray
                .reduce([], { (methodsArray, record) -> [RetailStoreOrderMethodType] in
                    guard
                        let methodString = record.fulfilmentMethod,
                        let method = RetailStoreOrderMethodType(rawValue: methodString)
                    else { return methodsArray }
                    var array = methodsArray
                    array.append(method)
                    return array
                })
        }
        
        var paymentGateways: [String]?
        if let paymentGatewaysMOArray = managedObject.gateways?.array as? [PaymentMethodGatewayMO] {
            paymentGateways = paymentGatewaysMOArray
                .reduce(nil, { (gatewayArray, record) -> [String]? in
                    guard let gatewayName = record.gatewayName else { return gatewayArray }
                    var array = gatewayArray ?? []
                    array.append(gatewayName)
                    return array
                })
        }
        
        self.init(
            name: managedObject.name ?? "",
            title: managedObject.title ?? "",
            description: managedObject.methodDescription,
            settings: PaymentMethodSettings(
                title: managedObject.settingsTitle ?? "",
                instructions: managedObject.settingsInstructions,
                enabledForMethod: enabledForMethods,
                paymentGateways: paymentGateways,
                saveCards: saveCards,
                cutOffTime: managedObject.settingsCutoffTime
            )
        )
    }
    
    @discardableResult
    func store(in context: NSManagedObjectContext) -> PaymentMethodMO? {
        
        guard let method = PaymentMethodMO.insertNew(in: context)
            else { return nil }
        
        method.name = name
        method.title = title
        method.methodDescription = description
        method.settingsTitle = settings.title
        method.settingsInstructions = settings.instructions
        method.enabledForMethods = NSOrderedSet(array: settings.enabledForMethod.compactMap({ enabledMethod -> PaymentMethodSettingsEnabledMethodMO? in
            guard let enabledMethodMO = PaymentMethodSettingsEnabledMethodMO.insertNew(in: context)
                else { return nil }
            enabledMethodMO.fulfilmentMethod = enabledMethod.rawValue
            return enabledMethodMO
        }))
        if let paymentGateways = settings.paymentGateways {
            method.gateways = NSOrderedSet(array: paymentGateways.compactMap({ gatewayName -> PaymentMethodGatewayMO? in
                guard let gatewayMO = PaymentMethodGatewayMO.insertNew(in: context)
                    else { return nil }
                gatewayMO.gatewayName = gatewayName
                return gatewayMO
            }))
        }
        if let saveCards = settings.saveCards {
            method.settingsSavedCards = NSNumber(value: saveCards)
        }
        method.settingsCutoffTime = settings.cutOffTime
        
        return method
    }
    
}

extension PaymentGateway {
    
    init?(managedObject: PaymentGatewayMO) {
        
        var fields: [String: Any]?
        if let fieldsMOArray = managedObject.fields?.array as? [PaymentGatewayFieldMO] {
            fields = fieldsMOArray
                .reduce([:], { (methodsDictionary, record) -> [String: Any]? in
                    
                    var insertValue: Any?
                    
                    guard
                        let fieldName = record.fieldName,
                        let fieldType = record.fieldType
                    else { return methodsDictionary }
                    
                    switch fieldType {
                    case "string":
                        if let stringValue = record.stringFieldValue {
                            insertValue = stringValue
                        } else {
                            return methodsDictionary
                        }
                    case "double":
                        insertValue = record.doubleFieldValue
                    case "integer":
                        insertValue = record.intFieldValue
                    case "boolean":
                        insertValue = record.boolFieldValue
                    default:
                        return methodsDictionary
                    }
                    
                    var array = methodsDictionary ?? [String: Any]()
                    array[fieldName] = insertValue
                    return array
                })
        }
        self.init(
            name: managedObject.name ?? "",
            mode: PaymentGatewayMode(rawValue: managedObject.mode ?? "") ?? .sandbox,
            fields: fields
        )
    }
    
    @discardableResult
    func store(in context: NSManagedObjectContext) -> PaymentGatewayMO? {
        
        guard let gateway = PaymentGatewayMO.insertNew(in: context)
            else { return nil }
        
        gateway.name = name
        gateway.mode = mode.rawValue
        
        if
            let fields = fields,
            fields.count != 0
        {
            gateway.fields = NSOrderedSet(array: fields.compactMap({ (key, value) -> PaymentGatewayFieldMO? in
                
                if let boolValue = value as? Bool {
                    guard let fieldMO = PaymentGatewayFieldMO.insertNew(in: context)
                        else { return nil }
                    fieldMO.fieldName = key
                    fieldMO.fieldType = "boolean"
                    fieldMO.boolFieldValue = boolValue
                    return fieldMO
                } else if let integerValue = value as? Int {
                    guard let fieldMO = PaymentGatewayFieldMO.insertNew(in: context)
                        else { return nil }
                    fieldMO.fieldName = key
                    fieldMO.fieldType = "integer"
                    fieldMO.intFieldValue = Int64(integerValue)
                    return fieldMO
                } else if let doubleValue = value as? Double {
                    guard let fieldMO = PaymentGatewayFieldMO.insertNew(in: context)
                        else { return nil }
                    fieldMO.fieldName = key
                    fieldMO.fieldType = "double"
                    fieldMO.doubleFieldValue = doubleValue
                    return fieldMO
                } else if let stringValue = value as? String {
                    guard let fieldMO = PaymentGatewayFieldMO.insertNew(in: context)
                        else { return nil }
                    fieldMO.fieldName = key
                    fieldMO.fieldType = "string"
                    fieldMO.stringFieldValue = stringValue
                    return fieldMO
                }
                
                return nil
            }))
        }
        
        return gateway
    }
    
}

extension RetailStoreTip {
    
    init?(managedObject: RetailStoreTipMO) {
        
        var refundDriverTipsForLateOrders: Bool?
        if let refundDriverTipsForLateOrdersNSNumber = managedObject.refundDriverTipsForLateOrders {
            refundDriverTipsForLateOrders = refundDriverTipsForLateOrdersNSNumber.boolValue
        }
        
        var refundDriverTipsAfterLateByMinutes: Int?
        if let refundDriverTipsAfterLateByMinutesNSNumber = managedObject.refundDriverTipsAfterLateByMinutes {
            refundDriverTipsAfterLateByMinutes = refundDriverTipsAfterLateByMinutesNSNumber.intValue
        }
        
        self.init(
            enabled: managedObject.enabled,
            defaultValue: managedObject.defaultValue,
            type: managedObject.type ?? "",
            refundDriverTipsForLateOrders: refundDriverTipsForLateOrders,
            refundDriverTipsAfterLateByMinutes: refundDriverTipsAfterLateByMinutes
        )
    }
    
    @discardableResult
    func store(in context: NSManagedObjectContext) -> RetailStoreTipMO? {
        
        guard let tip = RetailStoreTipMO.insertNew(in: context)
            else { return nil }
        
        tip.enabled = enabled
        tip.defaultValue = defaultValue
        tip.type = type
        if let refundDriverTipsForLateOrders = refundDriverTipsForLateOrders {
            tip.refundDriverTipsForLateOrders = NSNumber(value: refundDriverTipsForLateOrders)
        }
        if let refundDriverTipsAfterLateByMinutes = refundDriverTipsAfterLateByMinutes {
            tip.refundDriverTipsAfterLateByMinutes = NSNumber(value: refundDriverTipsAfterLateByMinutes)
        }
        
        return tip
    }
    
}

extension RetailStoreCustomer {
    
    init?(managedObject: RetailStoreCustomerMO) {
        self.init(
            hasMembership: managedObject.hasMembership,
            membershipIdPromptText: managedObject.membershipIdPromptText,
            membershipIdFieldPlaceholder: managedObject.membershipIdFieldPlaceholder
        )
    }
    
    @discardableResult
    func store(in context: NSManagedObjectContext) -> RetailStoreCustomerMO? {
        
        guard let customer = RetailStoreCustomerMO.insertNew(in: context)
            else { return nil }
        
        customer.hasMembership = hasMembership
        customer.membershipIdPromptText = membershipIdPromptText
        customer.membershipIdFieldPlaceholder = membershipIdFieldPlaceholder
        
        return customer
    }
    
}
