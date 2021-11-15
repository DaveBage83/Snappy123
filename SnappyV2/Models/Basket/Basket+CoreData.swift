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
                options: nil
            )
        }
        
        self.init(
            basketLineId: Int(managedObject.basketLineId),
            menuItem: menuItem,
            totalPrice: managedObject.totalPrice,
            price: managedObject.price,
            quantity: Int(managedObject.quantity)
        )
    }
    
    @discardableResult
    func store(in context: NSManagedObjectContext) -> BasketItemMO? {
        
        guard let item = BasketItemMO.insertNew(in: context)
            else { return nil }
        
        item.basketLineId = Int64(basketLineId)
        item.menuItem = menuItem.store(in: context)
        item.totalPrice = totalPrice
        item.price = price
        item.quantity = Int16(quantity)

        return item
    }
    
}
