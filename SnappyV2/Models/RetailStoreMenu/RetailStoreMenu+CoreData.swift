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
extension RetailStoreMenuItemSizeMO: ManagedEntity { }
extension RetailStoreMenuItemOptionMO: ManagedEntity { }
extension RetailStoreMenuItemOptionDependencyMO: ManagedEntity { }
extension RetailStoreMenuItemOptionValueMO: ManagedEntity { }
extension RetailStoreMenuItemOptionValueSizeCostMO: ManagedEntity { }

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
            fetchFulfilmentMethod: RetailStoreOrderMethodType(rawValue: managedObject.fetchFulfilmentMethod ?? ""),
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
        
        var sizes: [RetailStoreMenuItemSize]?
        
        if
            let sizesFound = managedObject.sizes,
            let sizesFoundArray = sizesFound.array as? [RetailStoreMenuItemSizeMO]
        {
            sizes = sizesFoundArray
                .reduce(nil, { (sizeArray, record) -> [RetailStoreMenuItemSize]? in
                    guard let size = RetailStoreMenuItemSize(managedObject: record)
                    else { return sizeArray }
                    var array = sizeArray ?? []
                    array.append(size)
                    return array
                })
        }
        
        var options: [RetailStoreMenuItemOption]?
        
        if
            let optionsFound = managedObject.options,
            let optionsFoundArray = optionsFound.array as? [RetailStoreMenuItemOptionMO]
        {
            options = optionsFoundArray
                .reduce(nil, { (optionArray, record) -> [RetailStoreMenuItemOption]? in
                    guard let option = RetailStoreMenuItemOption(managedObject: record)
                    else { return optionArray }
                    var array = optionArray ?? []
                    array.append(option)
                    return array
                })
        }
        
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
                unitVolume: managedObject.unitVolume,
                wasPrice: managedObject.wasPrice?.doubleValue
            ),
            images: ImagePathMO.arrayOfDictionaries(from: managedObject.images),
            menuItemSizes: sizes,
            menuItemOptions: options
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
        
        if let wasPrice = price.wasPrice {
            item.wasPrice = NSNumber(value: wasPrice)
        }
        
        item.images = ImagePathMO.orderedSet(from: images, in: context)
        
        if let sizes = menuItemSizes {
            item.sizes = NSOrderedSet(array: sizes.compactMap({ size -> RetailStoreMenuItemSizeMO? in
                return size.store(in: context)
            }))
        }
        
        if let options = menuItemOptions {
            item.options = NSOrderedSet(array: options.compactMap({ option -> RetailStoreMenuItemOptionMO? in
                return option.store(in: context)
            }))
        }
        
        return item
    }
    
}


extension RetailStoreMenuItemSize {
    
    init?(managedObject: RetailStoreMenuItemSizeMO) {
        
        self.init(
            id: Int(managedObject.id),
            name: managedObject.name ?? "",
            price: MenuItemSizePrice(price: managedObject.price)
        )
        
    }
    
    @discardableResult
    func store(in context: NSManagedObjectContext) -> RetailStoreMenuItemSizeMO? {
        
        guard let size = RetailStoreMenuItemSizeMO.insertNew(in: context)
            else { return nil }
        
        size.id = Int64(id)
        size.name = name
        size.price = price.price
        
        return size
    }
    
}


extension RetailStoreMenuItemOption {
    
    init?(managedObject: RetailStoreMenuItemOptionMO) {
        
        var dependencies: [Int]?
        var values: [RetailStoreMenuItemOptionValue]?
        
        if
            let managedDependencies = managedObject.dependencies,
            let dependenciesArray = managedDependencies.array as? [RetailStoreMenuItemOptionDependencyMO]
        {
            dependencies = dependenciesArray
                .reduce(nil, { (intArray, record) -> [Int]? in
                    var array = intArray ?? []
                    array.append(Int(record.id))
                    return array
                })
        }
        
        if
            let managedValues = managedObject.values,
            let valuesArray = managedValues.array as? [RetailStoreMenuItemOptionValueMO]
        {
            values = valuesArray
                .reduce(nil, { (newArray, record) -> [RetailStoreMenuItemOptionValue]? in
                    guard let optionValue = RetailStoreMenuItemOptionValue(managedObject: record)
                    else { return newArray }
                    var array = newArray ?? []
                    array.append(optionValue)
                    return array
                })
        }
        
        self.init(
            id: Int(managedObject.id),
            name: managedObject.name ?? "",
            type: RetailStoreMenuItemOptionSource(rawValue: managedObject.type ?? "") ?? .item,
            placeholder: managedObject.placeholder ?? "",
            instances: Int(managedObject.instances),
            displayAsGrid: managedObject.displayAsGrid,
            mutuallyExclusive: managedObject.mutuallyExclusive,
            minimumSelected: Int(managedObject.minimumSelected),
            extraCostThreshold: managedObject.extraCostThreshold,
            dependencies: dependencies,
            values: values
        )
        
    }
    
    @discardableResult
    func store(in context: NSManagedObjectContext) -> RetailStoreMenuItemOptionMO? {
        
        guard let option = RetailStoreMenuItemOptionMO.insertNew(in: context)
            else { return nil }
        
        option.id = Int64(id)
        option.name = name
        option.type = type.rawValue
        option.placeholder = placeholder
        option.instances = Int16(instances)
        option.displayAsGrid = displayAsGrid
        option.mutuallyExclusive = mutuallyExclusive
        option.minimumSelected = Int16(minimumSelected)
        option.extraCostThreshold = extraCostThreshold
        
        if let dependencies = dependencies {
            option.dependencies = NSOrderedSet(array: dependencies.compactMap({ optionId -> RetailStoreMenuItemOptionDependencyMO? in
                let dependencyMO = RetailStoreMenuItemOptionDependencyMO.insertNew(in: context)
                dependencyMO?.id = Int64(optionId)
                return dependencyMO
            }))
        }
        
        if let values = values {
            option.values = NSOrderedSet(array: values.compactMap({ value -> RetailStoreMenuItemOptionValueMO? in
                return value.store(in: context)
            }))
        }

        return option
    }
    
}


extension RetailStoreMenuItemOptionValue {
    
    init?(managedObject: RetailStoreMenuItemOptionValueMO) {
        
        var sizeCosts: [RetailStoreMenuItemOptionValueSizeCost]?
        
        if
            let managedSizeCosts = managedObject.sizeCosts,
            let sizeCostsArray = managedSizeCosts.array as? [RetailStoreMenuItemOptionValueSizeCostMO]
        {
            sizeCosts = sizeCostsArray
                .reduce(nil, { (newArray, record) -> [RetailStoreMenuItemOptionValueSizeCost]? in
                    guard let sizeCost = RetailStoreMenuItemOptionValueSizeCost(managedObject: record)
                    else { return newArray }
                    var array = newArray ?? []
                    array.append(sizeCost)
                    return array
                })
        }
        
        self.init(
            id: Int(managedObject.id),
            name: managedObject.name ?? "",
            extraCost: managedObject.extraCost,
            default: Int(managedObject.defaultSelection),
            sizeExtraCost: sizeCosts
        )
        
    }
    
    @discardableResult
    func store(in context: NSManagedObjectContext) -> RetailStoreMenuItemOptionValueMO? {
        
        guard let value = RetailStoreMenuItemOptionValueMO.insertNew(in: context)
            else { return nil }
        
        value.id = Int64(id)
        value.name = name
        value.extraCost = extraCost
        value.defaultSelection = Int16(`default`)
        
        if let sizeExtraCosts = sizeExtraCost {
            value.sizeCosts = NSOrderedSet(array: sizeExtraCosts.compactMap({ sizeExtraCost -> RetailStoreMenuItemOptionValueSizeCostMO? in
                return sizeExtraCost.store(in: context)
            }))
        }
        
        return value
        
    }
    
}


extension RetailStoreMenuItemOptionValueSizeCost {
    
    init?(managedObject: RetailStoreMenuItemOptionValueSizeCostMO) {
        
        self.init(
            id: Int(managedObject.id),
            sizeId: Int(managedObject.sizeId),
            extraCost: managedObject.extraCost
        )
        
    }
    
    @discardableResult
    func store(in context: NSManagedObjectContext) -> RetailStoreMenuItemOptionValueSizeCostMO? {
        
        guard let sizeCost = RetailStoreMenuItemOptionValueSizeCostMO.insertNew(in: context)
            else { return nil }
        
        sizeCost.id = Int64(id)
        sizeCost.sizeId = Int64(sizeId)
        sizeCost.extraCost = extraCost
        
        return sizeCost
        
    }
    
}
