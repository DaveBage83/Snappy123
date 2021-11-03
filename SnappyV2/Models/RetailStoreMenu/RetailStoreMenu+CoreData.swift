//
//  RetailStoreMenu+CoreData.swift
//  SnappyV2
//
//  Created by Kevin Palser on 19/10/2021.
//

import Foundation
import CoreData

extension RetailStoreMenuFetchMO: ManagedEntity { }
extension RetailStoreMenuCategoryMO: ManagedEntity { }
extension RetailStoreMenuItemMO: ManagedEntity { }

extension RetailStoreMenuFetch {
    
    init(managedObject: RetailStoreMenuFetchMO) {
        
        var categories: [RetailStoreMenuCategory]?
        var menuItems: [RetailStoreMenuItem]?
        
        if
            let categoriesFound = managedObject.categories,
            let categoriesFoundArray = categoriesFound.array as? [RetailStoreMenuCategoryMO]
        {
            categories = categoriesFoundArray
                .reduce(nil, { (categoryArray, record) -> [RetailStoreMenuCategory]? in
                    guard let category = RetailStoreMenuCategory(managedObject: record)
                    else { return categoryArray }
                    var array = categoryArray ?? []
                    array.append(category)
                    return array
                })
        }
        
        if
            let itemsFound = managedObject.menuItems,
            let itemsFoundArray = itemsFound.array as? [RetailStoreMenuItemMO]
        {
            menuItems = itemsFoundArray
                .reduce(nil, { (itemArray, record) -> [RetailStoreMenuItem]? in
                    guard let item = RetailStoreMenuItem(managedObject: record)
                    else { return itemArray }
                    var array = itemArray ?? []
                    array.append(item)
                    return array
                })
        }
        
        self.init(
            categories: categories,
            menuItems: menuItems,
            fetchStoreId: Int(managedObject.fetchStoreId),
            fetchCategoryId: Int(managedObject.fetchCategoryId),
            fetchFulfilmentMethod: FulfilmentMethod(rawValue: managedObject.fetchFulfilmentMethod ?? ""),
            fetchTimestamp: managedObject.timestamp
        )
    }
    
    @discardableResult
    func store(in context: NSManagedObjectContext) -> RetailStoreMenuFetchMO? {
        
        guard let fetch = RetailStoreMenuFetchMO.insertNew(in: context)
            else { return nil }
        
        if let categories = categories {
            fetch.categories = NSOrderedSet(array: categories.compactMap({ category -> RetailStoreMenuCategoryMO? in
                return category.store(in: context)
            }))
        }
        
        if let items = menuItems {
            fetch.menuItems = NSOrderedSet(array: items.compactMap({ item -> RetailStoreMenuItemMO? in
                return item.store(in: context)
            }))
        }

        fetch.timestamp = Date()
        
        return fetch
    }
}


extension RetailStoreMenuCategory {
    
    init?(managedObject: RetailStoreMenuCategoryMO) {
        
        self.init(
            id: Int(managedObject.id),
            parentId: Int(managedObject.parentId),
            name: managedObject.name ?? "",
            image: ImagePathMO.dictionary(from: managedObject.imagePaths)
        )
        
    }
    
    @discardableResult
    func store(in context: NSManagedObjectContext) -> RetailStoreMenuCategoryMO? {
        
        guard let category = RetailStoreMenuCategoryMO.insertNew(in: context)
            else { return nil }
        
        category.id = Int64(id)
        category.parentId = Int64(parentId)
        category.name = name
        
        category.imagePaths = ImagePathMO.set(from: image, in: context)
        
        return category
    }
    
}

extension RetailStoreMenuItem {
    
    init?(managedObject: RetailStoreMenuItemMO) {
        
        self.init(
            id: Int(managedObject.id),
            name: managedObject.name ?? "",
            eposCode: managedObject.eposCode,
            outOfStock: managedObject.outOfStock,
            ageRestriction: Int(managedObject.ageRestriction),
            description: managedObject.itemDescription,
            quickAdd: managedObject.quickAdd,
            price: RetailStoreMenuItemPrice(
                price: managedObject.price,
                fromPrice: managedObject.fromPrice,
                unitMetric: managedObject.unitMetric ?? "",
                unitsInPack: Int(managedObject.unitsInPack),
                unitVolume: managedObject.unitVolume
            ),
            images: ImagePathMO.arrayOfDictionaries(from: managedObject.images)
        )
        
    }
    
    @discardableResult
    func store(in context: NSManagedObjectContext) -> RetailStoreMenuItemMO? {
        
        guard let item = RetailStoreMenuItemMO.insertNew(in: context)
            else { return nil }
        
        item.id = Int64(id)
        item.eposCode = eposCode
        item.name = name
        item.itemDescription = description
        item.quickAdd = quickAdd
        item.outOfStock = outOfStock
        item.ageRestriction = Int16(ageRestriction)
        item.price = price.price
        item.fromPrice = price.fromPrice
        item.unitMetric = price.unitMetric
        item.unitsInPack = Int16(price.unitsInPack)
        item.unitVolume = price.unitVolume
        
        item.images = ImagePathMO.orderedSet(from: images, in: context)
        
        return item
    }
    
}
