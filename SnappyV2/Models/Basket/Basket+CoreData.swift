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
        
        self.init(
            basketToken: managedObject.basketToken ?? "",
            isNewBasket: managedObject.isNewBasket,
            items: items,
            fulfilmentMethod: BasketFulfilmentMethod(
                type: RetailStoreOrderMethodType(rawValue: managedObject.fulfilmentMethod ?? "") ?? .delivery//,
                //datetime: managedObject.fulfilmentMethodDateTime ?? Date()
            )
        )
        
    }
    
    @discardableResult
    func store(in context: NSManagedObjectContext) -> BasketMO? {
        
        guard let basket = BasketMO.insertNew(in: context)
            else { return nil }
        
        basket.items = NSOrderedSet(array: items.compactMap({ item -> BasketItemMO? in
            return item.store(in: context)
        }))
        
        basket.fulfilmentMethod = fulfilmentMethod.type.rawValue
        //basket.fulfilmentMethodDateTime = fulfilmentMethod.datetime
        
        basket.basketToken = basketToken
        basket.isNewBasket = isNewBasket
        
        basket.timestamp = Date()
        
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
                price: RetailStoreMenuItemPrice(price: 0, fromPrice: 0, unitMetric: "", unitsInPack: 1, unitVolume: 0, wasPrice: nil),
                images: nil,
                menuItemSizes: nil,
                menuItemOptions: nil
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
        
        self.init(
            basketLineId: Int(managedObject.basketLineId),
            menuItem: menuItem,
            totalPrice: managedObject.totalPrice,
            totalPriceBeforeDiscounts: managedObject.totalPriceBeforeDiscounts,
            price: managedObject.price,
            pricePaid: managedObject.pricePaid,
            quantity: Int(managedObject.quantity),
            size: size,
            selectedOptions: selectedOptions
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
        
        item.basketLineId = Int64(basketLineId)
        item.menuItem = menuItem.store(in: context)
        item.totalPrice = totalPrice
        item.totalPriceBeforeDiscounts = totalPriceBeforeDiscounts
        item.price = price
        item.pricePaid = pricePaid
        item.quantity = Int16(quantity)
        
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
            // TODO: id needs to be an Int when the API is fixed
            id: "\(managedObject.id)",
            selectedValues: selectedValues
        )
        
    }
    
    @discardableResult
    func store(in context: NSManagedObjectContext) -> BasketItemSelectedOptionMO? {
        
        guard let selectedOption = BasketItemSelectedOptionMO.insertNew(in: context)
            else { return nil }
        
        // TODO: id needs to come from an Int when the API is fixed
        selectedOption.id = Int64(id) ?? 0
        
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
