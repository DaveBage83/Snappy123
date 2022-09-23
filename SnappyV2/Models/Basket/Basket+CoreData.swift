//
//  Basket+CoreData.swift
//  SnappyV2
//
//  Created by Kevin Palser on 31/10/2021.
//

import Foundation
import CoreData

extension BasketMO: ManagedEntity { }
extension BasketItemMO: ManagedEntity { }
extension BasketItemSelectedOptionMO: ManagedEntity { }
extension BasketItemSelectedOptionValueMO: ManagedEntity { }
extension BasketItemSelectedSizeMO: ManagedEntity { }
extension BasketItemMissedPromotionMO: ManagedEntity { }
extension BasketItemMissedPromotionSectionMO: ManagedEntity { }
extension BasketSelectedSlotMO: ManagedEntity { }
extension BasketSavingMO: ManagedEntity { }
extension BasketSavingLineMO: ManagedEntity { }
extension BasketCouponMO: ManagedEntity { }
extension BasketFeeMO: ManagedEntity { }
extension BasketAddressMO: ManagedEntity { }
extension BasketTipMO: ManagedEntity { }

extension Basket {
    
    init(managedObject: BasketMO) {
        
        var items: [BasketItem] = []
        if
            let itemsAssociated = managedObject.items,
            let itemsAssociatedArray = itemsAssociated.array as? [BasketItemMO]
        {
            items = itemsAssociatedArray
                .reduce([], { (itemArray, record) -> [BasketItem] in
                    var array = itemArray
                    array.append(BasketItem(managedObject: record))
                    return array
                })
        }
        
        var selectedSlot: BasketSelectedSlot?
        if let managedSelectedSlot = managedObject.selectedSlot {
            selectedSlot = BasketSelectedSlot(managedObject: managedSelectedSlot)
        }
        
        var savings: [BasketSaving]?
        if
            let managedSavings = managedObject.savings,
            let managedSavingsArray = managedSavings.array as? [BasketSavingMO]
        {
            savings = managedSavingsArray
                .reduce(nil, { (savingArray, record) -> [BasketSaving]? in
                    var array = savingArray ?? []
                    array.append(BasketSaving(managedObject: record))
                    return array
                })
        }
        
        var coupon: BasketCoupon?
        if let managedCoupon = managedObject.coupon {
            coupon = BasketCoupon(managedObject: managedCoupon)
        }
        
        var fees: [BasketFee]?
        if
            let managedFees = managedObject.fees,
            let managedFeesArray = managedFees.array as? [BasketFeeMO]
        {
            fees = managedFeesArray
                .reduce(nil, { (feesArray, record) -> [BasketFee]? in
                    var array = feesArray ?? []
                    array.append(BasketFee(managedObject: record))
                    return array
                })
        }
        
        var tips: [BasketTip]?
        if
            let managedTips = managedObject.tips,
            let managedTipsArray = managedTips.array as? [BasketTipMO]
        {
            tips = managedTipsArray
                .reduce(nil, { (feesArray, record) -> [BasketTip]? in
                    var array = feesArray ?? []
                    array.append(BasketTip(managedObject: record))
                    return array
                })
        }
        
        var addresses: [BasketAddressResponse]?
        if
            let managedAddresses = managedObject.addresses,
            let managedAddressesArray = managedAddresses.array as? [BasketAddressMO]
        {
            addresses = managedAddressesArray
                .reduce(nil, { (managedAddressesArray, record) -> [BasketAddressResponse]? in
                    var array = managedAddressesArray ?? []
                    array.append(BasketAddressResponse(managedObject: record))
                    return array
                })
        }
        
        let basketItemRemoved: Bool?
        if let basketItemRemovedMO = managedObject.basketItemRemoved {
            basketItemRemoved = basketItemRemovedMO.boolValue
        } else {
            basketItemRemoved = nil
        }
        
        // In order to avoid faffing about with NSNumber, I'll have to presume that there'll never be a storeId of 0.
        let storeId: Int? = managedObject.storeId == 0 ? nil : Int(managedObject.storeId)
        
        self.init(
            basketToken: managedObject.basketToken ?? "",
            isNewBasket: managedObject.isNewBasket,
            items: items,
            fulfilmentMethod: BasketFulfilmentMethod(
                type: RetailStoreOrderMethodType(rawValue: managedObject.fulfilmentMethod ?? "") ?? .delivery,//,
                cost: managedObject.fulfilmentMethodCost,
                minSpend: managedObject.fulfilmentMethodMinSpend
            ),
            selectedSlot: selectedSlot,
            savings: savings,
            coupon: coupon,
            fees: fees,
            tips: tips,
            addresses: addresses,
            orderSubtotal: managedObject.orderSubtotal,
            orderTotal: managedObject.orderTotal,
            storeId: storeId,
            basketItemRemoved: basketItemRemoved
        )
        
    }
    
    @discardableResult
    func store(in context: NSManagedObjectContext) -> BasketMO? {
        
        guard let basket = BasketMO.insertNew(in: context)
            else { return nil }
        
        basket.items = NSOrderedSet(array: items.compactMap({ item -> BasketItemMO? in
            return item.store(in: context)
        }))
        
        if let savings = savings {
            basket.savings = NSOrderedSet(array: savings.compactMap({ saving -> BasketSavingMO? in
                return saving.store(in: context)
            }))
        }
        
        if let fees = fees {
            basket.fees = NSOrderedSet(array: fees.compactMap({ fee -> BasketFeeMO? in
                return fee.store(in: context)
            }))
        }
        
        if let tips = tips {
            basket.tips = NSOrderedSet(array: tips.compactMap({ tip -> BasketTipMO? in
                return tip.store(in: context)
            }))
        }
        
        if let addresses = addresses {
            basket.addresses = NSOrderedSet(array: addresses.compactMap({ address -> BasketAddressMO? in
                return address.store(in: context)
            }))
        }
        
        if let coupon = coupon {
            basket.coupon = coupon.store(in: context)
        }
        
        if let basketItemRemoved = basketItemRemoved {
            basket.basketItemRemoved = NSNumber(value: basketItemRemoved)
        }
        
        if let storeId = storeId {
            basket.storeId = Int64(storeId)
        }
        
        basket.selectedSlot = selectedSlot?.store(in: context)
        
        basket.fulfilmentMethod = fulfilmentMethod.type.rawValue
        basket.fulfilmentMethodCost = fulfilmentMethod.cost
        basket.fulfilmentMethodMinSpend = fulfilmentMethod.minSpend
        //basket.fulfilmentMethodDateTime = fulfilmentMethod.datetime
        
        basket.basketToken = basketToken
        basket.isNewBasket = isNewBasket
        basket.orderSubtotal = orderSubtotal
        basket.orderTotal = orderTotal
        
        basket.timestamp = Date().trueDate
        
        return basket
    }
}

extension BasketItem {
    
    init(managedObject: BasketItemMO) {
        
        let menuItem: RetailStoreMenuItem
        if
            let menuItemMO = managedObject.menuItem,
            let item = RetailStoreMenuItem(managedObject: menuItemMO)
        {
            menuItem = item
        } else {
            // in therory it should never get here but Core Data insists
            // on an optional. So to avoid a force unwrap we return an
            // empty item.
            
            menuItem = RetailStoreMenuItem(
                id: 0,
                name: "",
                eposCode: nil,
                outOfStock: true,
                ageRestriction: 0,
                description: nil,
                quickAdd: true,
                acceptCustomerInstructions: false,
                basketQuantityLimit: 500,
                price: RetailStoreMenuItemPrice(
                    price: 0,
                    fromPrice: 0,
                    unitMetric: "",
                    unitsInPack: 1,
                    unitVolume: 0,
                    wasPrice: nil),
                images: nil,
                menuItemSizes: nil,
                menuItemOptions: nil,
                availableDeals: nil,
                itemCaptions: nil,
                mainCategory: MenuItemCategory(id: 0, name: ""),
                itemDetails: nil,
                deal: nil
            )
        }
        
        var size: BasketItemSelectedSize?
        if let managedSize = managedObject.size {
            size = BasketItemSelectedSize(managedObject: managedSize)
        }
        
        var selectedOptions: [BasketItemSelectedOption]?
        if
            let selectedOptionsFound = managedObject.selectedOptions,
            let selectedOptionsFoundArray = selectedOptionsFound.array as? [BasketItemSelectedOptionMO]
        {
            selectedOptions = selectedOptionsFoundArray
                .reduce(nil, { (selectedOptionsArray, record) -> [BasketItemSelectedOption]? in
                    var array = selectedOptionsArray ?? []
                    array.append(BasketItemSelectedOption(managedObject: record))
                    return array
                })
        }
        
        var missedPromotions: [BasketItemMissedPromotion]?
        if
            let missedPromotionsFound = managedObject.missedPromotions,
            let missedPromotionsFoundArray = missedPromotionsFound.array as? [BasketItemMissedPromotionMO]
        {
            missedPromotions = missedPromotionsFoundArray
                .reduce(nil, { (missedPromotionsArray, record) -> [BasketItemMissedPromotion]? in
                    var array = missedPromotionsArray ?? []
                    array.append(BasketItemMissedPromotion(managedObject: record))
                    return array
                })
        }
        
        self.init(
            basketLineId: Int(managedObject.basketLineId),
            menuItem: menuItem,
            totalPrice: managedObject.totalPrice,
            totalPriceBeforeDiscounts: managedObject.totalPriceBeforeDiscounts,
            price: managedObject.price,
            pricePaid: managedObject.pricePaid,
            quantity: Int(managedObject.quantity),
            instructions: managedObject.instructions,
            size: size,
            selectedOptions: selectedOptions,
            missedPromotions: missedPromotions,
            isAlcohol: managedObject.isAlcohol
        )
    }
    
    @discardableResult
    func store(in context: NSManagedObjectContext) -> BasketItemMO? {
        
        guard let item = BasketItemMO.insertNew(in: context)
            else { return nil }
        
        if let selectedSize = size {
            item.size = selectedSize.store(in: context)
        }
        
        if let selectedOptions = selectedOptions {
            item.selectedOptions = NSOrderedSet(array: selectedOptions.compactMap({ selectedOption -> BasketItemSelectedOptionMO? in
                return selectedOption.store(in: context)
            }))
        }
        
        if let missedPromotions = missedPromotions {
            item.missedPromotions = NSOrderedSet(array: missedPromotions.compactMap({ missedPromotion -> BasketItemMissedPromotionMO? in
                return missedPromotion.store(in: context)
            }))
        }
        
        item.basketLineId = Int64(basketLineId)
        item.menuItem = menuItem.store(in: context)
        item.totalPrice = totalPrice
        item.totalPriceBeforeDiscounts = totalPriceBeforeDiscounts
        item.price = price
        item.pricePaid = pricePaid
        item.quantity = Int16(quantity)
        item.instructions = instructions
        item.isAlcohol = isAlcohol
        
        return item
    }
    
}

extension BasketItemSelectedOption {
    
    init(managedObject: BasketItemSelectedOptionMO) {
        
        var selectedValues: [Int] = []
        if
            let foundSelectedValues = managedObject.selectedValues,
            let selectedValuesArray = foundSelectedValues.array as? [BasketItemSelectedOptionValueMO]
        {
            selectedValues = selectedValuesArray
                .reduce([], { (intArray, record) -> [Int] in
                    var array = intArray
                    array.append(Int(record.valueId))
                    return array
                })
        }
        
        self.init(
            id: Int(managedObject.id),
            selectedValues: selectedValues
        )
        
    }
    
    @discardableResult
    func store(in context: NSManagedObjectContext) -> BasketItemSelectedOptionMO? {
        
        guard let selectedOption = BasketItemSelectedOptionMO.insertNew(in: context)
            else { return nil }
        
        selectedOption.id = Int64(id)
        
        if selectedValues.count > 0 {
            selectedOption.selectedValues = NSOrderedSet(array: selectedValues.compactMap({ valueId -> BasketItemSelectedOptionValueMO? in
                guard let optionValue = BasketItemSelectedOptionValueMO.insertNew(in: context)
                    else { return nil }
                optionValue.valueId = Int64(valueId)
                return optionValue
            }))
        }

        return selectedOption
    }
    
}

extension BasketItemSelectedSize {
    
    init(managedObject: BasketItemSelectedSizeMO) {
        self.init(
            id: Int(managedObject.id),
            name: managedObject.name
        )
    }
    
    @discardableResult
    func store(in context: NSManagedObjectContext) -> BasketItemSelectedSizeMO? {
        
        guard let selectedSize = BasketItemSelectedSizeMO.insertNew(in: context)
            else { return nil }
        
        selectedSize.id = Int64(id)
        selectedSize.name = name

        return selectedSize
    }
    
}

extension BasketItemMissedPromotion {
    
    init(managedObject: BasketItemMissedPromotionMO) {

        var missedSections: [BasketItemMissedPromotionSection]?
        if
            let foundSections = managedObject.sections,
            let sectionsArray = foundSections.array as? [BasketItemMissedPromotionSectionMO]
        {
            missedSections = sectionsArray
                .reduce(nil, { (sectionsArray, record) -> [BasketItemMissedPromotionSection]? in
                    var array = sectionsArray ?? []
                    array.append(BasketItemMissedPromotionSection(managedObject: record))
                    return array
                })
        }
        
        self.init(
            id: Int(managedObject.referenceId),
            name: managedObject.name ?? "",
            type: BasketItemMissedPromotionType(rawValue: managedObject.type ?? "") ?? .discount,
            missedSections: missedSections
        )
    }
    
    @discardableResult
    func store(in context: NSManagedObjectContext) -> BasketItemMissedPromotionMO? {
        
        guard let missedPromotion = BasketItemMissedPromotionMO.insertNew(in: context)
            else { return nil }
        
        missedPromotion.referenceId = Int64(id)
        missedPromotion.name = name
        missedPromotion.type = type.rawValue
        
        if
            let missedSections = missedSections,
            missedSections.count > 0
        {
            missedPromotion.sections = NSOrderedSet(array: missedSections.compactMap({ section -> BasketItemMissedPromotionSectionMO? in
                return section.store(in: context)
            }))
        }

        return missedPromotion
    }
    
}

extension BasketItemMissedPromotionSection {
    
    init(managedObject: BasketItemMissedPromotionSectionMO) {
        self.init(
            id: Int(managedObject.id),
            name: managedObject.name ?? ""
        )
    }
    
    @discardableResult
    func store(in context: NSManagedObjectContext) -> BasketItemMissedPromotionSectionMO? {
        
        guard let section = BasketItemMissedPromotionSectionMO.insertNew(in: context)
            else { return nil }
        
        section.id = Int64(id)
        section.name = name

        return section
    }
    
}

extension BasketSelectedSlot {
    
    init(managedObject: BasketSelectedSlotMO) {
        self.init(
            // todaySelected is not returned from the API
            // when false
            todaySelected: managedObject.todaySelected == false ? nil : true,
            start: managedObject.start,
            end: managedObject.end,
            expires: managedObject.expires
        )
    }
    
    @discardableResult
    func store(in context: NSManagedObjectContext) -> BasketSelectedSlotMO? {
        
        guard let selectedSlot = BasketSelectedSlotMO.insertNew(in: context)
            else { return nil }
        
        selectedSlot.todaySelected = todaySelected ?? false
        selectedSlot.start = start
        selectedSlot.end = end
        selectedSlot.expires = expires

        return selectedSlot
    }
    
}

extension BasketSaving {
    
    init(managedObject: BasketSavingMO) {
        
        var lines: [Int]?
        if
            let foundLines = managedObject.lines,
            let foundLinesArray = foundLines.array as? [BasketSavingLineMO]
        {
            lines = foundLinesArray
                .reduce([], { (intArray, record) -> [Int] in
                    var array = intArray
                    array.append(Int(record.lineId))
                    return array
                })
        }
        
        self.init(
            name: managedObject.name ?? "",
            amount: managedObject.amount,
            type: managedObject.type,
            lines: lines
        )
    }
    
    @discardableResult
    func store(in context: NSManagedObjectContext) -> BasketSavingMO? {
        
        guard let saving = BasketSavingMO.insertNew(in: context)
            else { return nil }
        
        if
            let lines = lines,
            lines.count > 0
        {
            saving.lines = NSOrderedSet(array: lines.compactMap({ lineId -> BasketSavingLineMO? in
                guard let line = BasketSavingLineMO.insertNew(in: context)
                    else { return nil }
                line.lineId = Int64(lineId)
                return line
            }))
        }
        
        saving.name = name
        saving.amount = amount
        saving.type = type
        
        return saving
    }
    
}

extension BasketCoupon {
    
    init(managedObject: BasketCouponMO) {
        
        // In order to avoid faffing about with NSNumber, we'll have to presume that there'll never be a iterableCampaignId of 0.
        let iterableCampaignId: Int? = managedObject.iterableCampaignId == 0 ? nil : Int(managedObject.iterableCampaignId)
        
        self.init(
            code: managedObject.code ?? "",
            name: managedObject.name ?? "",
            deductCost: managedObject.deductCost,
            iterableCampaignId: iterableCampaignId,
            type: managedObject.type ?? "",
            value: managedObject.value,
            freeDelivery: managedObject.freeDelivery
        )
    }
    
    @discardableResult
    func store(in context: NSManagedObjectContext) -> BasketCouponMO? {
        
        guard let coupon = BasketCouponMO.insertNew(in: context)
            else { return nil }

        coupon.code = code
        coupon.name = name
        coupon.deductCost = deductCost
        coupon.type = type
        coupon.value = value
        coupon.freeDelivery = freeDelivery
        
        if let iterable = iterableCampaignId {
            coupon.iterableCampaignId = Int64(iterable)
        }
        
        if let iterable = iterableCampaignId {
            coupon.iterableCampaignId = Int64(iterable)
        }
        
        if let iterable = iterableCampaignId {
            coupon.iterableCampaignId = Int64(iterable)
        }
        
        return coupon
    }
}

extension BasketFee {
    init(managedObject: BasketFeeMO) {
        self.init(
            typeId: Int(managedObject.typeId),
            title: managedObject.title ?? "",
            description: managedObject.optionalDescription,
            isOptional: managedObject.isOptional,
            amount: managedObject.amount
        )
    }
    
    @discardableResult
    func store(in context: NSManagedObjectContext) -> BasketFeeMO? {
        
        guard let fee = BasketFeeMO.insertNew(in: context)
            else { return nil }

        fee.typeId = Int64(typeId)
        fee.title = title
        fee.optionalDescription = description
        fee.isOptional = isOptional
        fee.amount = amount
        
        return fee
    }
}

extension BasketAddressResponse {
    init(managedObject: BasketAddressMO) {
        
        let location: Location?
        if
            let latitude = managedObject.latitude?.doubleValue,
            let longitude = managedObject.longitude?.doubleValue
        {
            location = Location(latitude: latitude, longitude: longitude)
        } else {
            location = nil
        }
        
        self.init(
            firstName: managedObject.firstName,
            lastName: managedObject.lastName,
            addressLine1: managedObject.addressLine1,
            addressLine2: managedObject.addressLine2,
            town: managedObject.town ?? "",
            postcode: managedObject.postcode ?? "",
            countryCode: managedObject.countryCode,
            type: managedObject.type ?? "",
            email: managedObject.email,
            telephone: managedObject.telephone,
            state: managedObject.state,
            county: managedObject.county,
            location: location
        )

    }
    
    @discardableResult
    func store(in context: NSManagedObjectContext) -> BasketAddressMO? {
        
        guard let address = BasketAddressMO.insertNew(in: context)
            else { return nil }

        address.firstName = firstName
        address.lastName = lastName
        address.addressLine1 = addressLine1
        address.addressLine2 = addressLine2
        address.town = town
        address.postcode = postcode
        address.countryCode = countryCode
        address.type = type
        address.email = email
        address.telephone = telephone
        address.state = state
        address.county = county
        
        if let location = location {
            address.latitude = NSNumber(value: location.latitude)
            address.longitude = NSNumber(value: location.longitude)
        }
        
        return address
    }
}

extension BasketTip {
    init(managedObject: BasketTipMO) {
        self.init(
            type: managedObject.type ?? "",
            amount: managedObject.amount
        )
    }
    
    @discardableResult
    func store(in context: NSManagedObjectContext) -> BasketTipMO? {
        
        guard let tip = BasketTipMO.insertNew(in: context)
            else { return nil }

        tip.type = type
        tip.amount = amount
        
        return tip
    }
}
