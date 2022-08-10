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
extension RetailStoreMenuItemAvailableDealMO: ManagedEntity {}
extension RetailStoreMenuItemFetchMO: ManagedEntity {}
extension RetailStoreMenuGlobalSearchMO: ManagedEntity {}
extension GlobalSearchResultMO: ManagedEntity {}
extension GlobalSearchNoItemHintMO: ManagedEntity {}
extension GlobalSearchResultPaginationMO: ManagedEntity {}
extension GlobalSearchResultRecordMO: ManagedEntity {}
extension MenuItemCategoryMO: ManagedEntity {}
extension ItemDetailsMO: ManagedEntity {}

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
            id: Int(managedObject.id),
            name: managedObject.name ?? "",
            categories: categories,
            menuItems: menuItems,
            fetchStoreId: Int(managedObject.fetchStoreId),
            fetchCategoryId: Int(managedObject.fetchCategoryId),
            fetchFulfilmentMethod: RetailStoreOrderMethodType(rawValue: managedObject.fetchFulfilmentMethod ?? ""),
            fetchFulfilmentDate: managedObject.fetchFulfilmentDate,
            fetchTimestamp: managedObject.timestamp
        )
    }
    
    @discardableResult
    func store(in context: NSManagedObjectContext) -> RetailStoreMenuFetchMO? {
        
        guard let fetch = RetailStoreMenuFetchMO.insertNew(in: context)
            else { return nil }
        
        if let id = id {
            fetch.id = Int64(id)
        }
        fetch.name = name
        
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

        fetch.timestamp = Date().trueDate
        
        return fetch
    }
}


extension RetailStoreMenuCategory {
    
    init?(managedObject: RetailStoreMenuCategoryMO) {
        
        let action: RetailStoreMenuCategoryAction? = managedObject.discountId == 0 ? nil : RetailStoreMenuCategoryAction(name: nil, params: RetailStoreMenuCategoryActionParams(discountId: Int(managedObject.discountId)))
        
        self.init(
            id: Int(managedObject.id),
            parentId: Int(managedObject.parentId),
            name: managedObject.name ?? "",
            image: ImagePathMO.dictionary(from: managedObject.imagePaths),
            description: managedObject.categoryDescription ?? "",
            action: action
        )
        
    }
    
    @discardableResult
    func store(in context: NSManagedObjectContext) -> RetailStoreMenuCategoryMO? {
        
        guard let category = RetailStoreMenuCategoryMO.insertNew(in: context)
            else { return nil }
        
        category.id = Int64(id)
        category.parentId = Int64(parentId)
        category.name = name
        category.categoryDescription = description
        
        if let action = action, let discountId = action.params?.discountId {
            category.discountId = Int64(discountId)
        }
        
        category.imagePaths = ImagePathMO.set(from: image, in: context)
        
        return category
    }
    
}

extension MenuItemCategory {
    init?(managedObject: MenuItemCategoryMO) {
        self.init(
            id: Int(managedObject.id),
            name: managedObject.name ?? ""
        )
    }
    
    @discardableResult
    func store(in context: NSManagedObjectContext) -> MenuItemCategoryMO? {
        
        guard let category = MenuItemCategoryMO.insertNew(in: context)
            else { return nil }
        
        category.id = Int64(id)
        category.name = name
        
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
        
        var availableDeals: [RetailStoreMenuItemAvailableDeal]?
        
        if
            let dealsFound = managedObject.availableDeals,
            let dealsFoundArray = dealsFound.array as? [RetailStoreMenuItemAvailableDealMO]
        {
            availableDeals = dealsFoundArray
                .reduce(nil, { (dealArray, record) -> [RetailStoreMenuItemAvailableDeal]? in
                    guard let option = RetailStoreMenuItemAvailableDeal(managedObject: record)
                    else { return dealArray }
                    var array = dealArray ?? []
                    array.append(option)
                    return array
                })
        }

        var itemDetails: [ItemDetails]?
        
        if let managedItemDetails = managedObject.itemDetails,
           let foundItemDetails = managedItemDetails.array as? [ItemDetailsMO] {
            itemDetails = foundItemDetails
                .reduce(nil, { (itemDetailsArray, record) -> [ItemDetails]? in
                    var array = itemDetailsArray ?? []
                    if let itemDetails = ItemDetails.mapFromCoreData(record) {
                        array.append(itemDetails)
                    }
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
            acceptCustomerInstructions: managedObject.acceptCustomerInstructions,
            basketQuantityLimit: Int(managedObject.basketQuantityLimit),
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
            menuItemOptions: options,
            availableDeals: availableDeals,
            itemCaptions: ItemCaptions(portionSize: managedObject.portionSize),
            mainCategory: MenuItemCategory(id: Int(managedObject.mainCategory?.id ?? 0), name: managedObject.mainCategory?.name ?? ""),
            itemDetails: itemDetails
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
        item.acceptCustomerInstructions = acceptCustomerInstructions
        item.basketQuantityLimit = Int16(basketQuantityLimit)
        item.outOfStock = outOfStock
        item.ageRestriction = Int16(ageRestriction)
        item.price = price.price
        item.fromPrice = price.fromPrice
        item.unitMetric = price.unitMetric
        item.unitsInPack = Int16(price.unitsInPack)
        item.unitVolume = price.unitVolume
        item.mainCategory = MenuItemCategory(id: mainCategory.id, name: mainCategory.name).store(in: context)
        

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
        
        if let deals = availableDeals {
            item.availableDeals = NSOrderedSet(array: deals.compactMap({ deal -> RetailStoreMenuItemAvailableDealMO? in
                return deal.store(in: context)
            }))
        }
        
        if let itemCaptions = itemCaptions, let portionSize = itemCaptions.portionSize {
            item.portionSize = portionSize
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
            defaultSelection: Int(managedObject.defaultSelection),
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
        value.defaultSelection = Int16(defaultSelection)
        
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

extension RetailStoreMenuItemAvailableDeal {
    
    init?(managedObject: RetailStoreMenuItemAvailableDealMO) {
    
        self.init(
            id: Int(managedObject.id),
            name: managedObject.name ?? "",
            type: managedObject.type ?? ""
        )
        
    }
    
    @discardableResult
    func store(in context: NSManagedObjectContext) -> RetailStoreMenuItemAvailableDealMO? {
        
        guard let deal = RetailStoreMenuItemAvailableDealMO.insertNew(in: context)
            else { return nil }
        
        deal.id = Int64(id)
        deal.name = name
        deal.type = type
        
        return deal
    }
    
}

extension RetailStoreMenuItemFetch {

    init?(managedObject: RetailStoreMenuItemFetchMO) {

        guard
            let itemMO = managedObject.item,
            let item = RetailStoreMenuItem(managedObject: itemMO)
        else { return nil }

        self.init(
            itemId: Int(managedObject.fetchItemId),
            storeId: Int(managedObject.fetchStoreId),
            categoryId: managedObject.fetchCategoryId?.intValue,
            fulfilmentMethod: RetailStoreOrderMethodType(rawValue: managedObject.fetchFulfilmentMethod ?? "") ?? .delivery,
            fulfilmentDate: managedObject.fetchFulfilmentDate,
            item: item,
            fetchTimestamp: managedObject.timestamp
        )
    }

    @discardableResult
    func store(in context: NSManagedObjectContext) -> RetailStoreMenuItemFetchMO? {

        guard let fetch = RetailStoreMenuItemFetchMO.insertNew(in: context)
            else { return nil }

        fetch.fetchItemId = Int64(itemId)
        fetch.fetchStoreId = Int64(storeId)
        if let categoryId = categoryId {
            fetch.fetchCategoryId = NSNumber(value: categoryId)
        }
        fetch.fetchFulfilmentMethod = fulfilmentMethod.rawValue
        fetch.fetchFulfilmentDate = fulfilmentDate

        fetch.item = item.store(in: context)
        fetch.timestamp = Date().trueDate

        return fetch
    }
}

extension RetailStoreMenuGlobalSearch {
    
    init?(managedObject: RetailStoreMenuGlobalSearchMO) {
        
        var categories: GlobalSearchResult?
        if let managedCategories = managedObject.categories {
            categories = GlobalSearchResult(managedObject: managedCategories)
        }
        
        var menuItems: GlobalSearchItemsResult?
        if let managedMenuItems = managedObject.menuItems {
            menuItems = GlobalSearchItemsResult(managedObject: managedMenuItems)
        }
        
        var deals: GlobalSearchResult?
        if let managedDeals = managedObject.deals {
            deals = GlobalSearchResult(managedObject: managedDeals)
        }
        
        var noItemHint: GlobalSearchNoItemHint?
        if let managedNoItemHint = managedObject.noItemHint {
            noItemHint = GlobalSearchNoItemHint(managedObject: managedNoItemHint)
        }
        
        // the pagination is only relevant if non zero limits were set
        
        var fetchItemsLimit: Int?
        var fetchItemsPage: Int?
        if managedObject.fetchItemsLimit > 0 {
            fetchItemsLimit = Int(managedObject.fetchItemsLimit)
            fetchItemsPage = Int(managedObject.fetchItemsPage)
        }
        
        var fetchCategoriesLimit: Int?
        var fetchCategoryPage: Int?
        if managedObject.fetchCategoriesLimit > 0 {
            fetchCategoriesLimit = Int(managedObject.fetchCategoriesLimit)
            fetchCategoryPage = Int(managedObject.fetchCategoryPage)
        }
        
        self.init(
            categories: categories,
            menuItems: menuItems,
            deals: deals,
            noItemFoundHint: noItemHint,
            fetchStoreId: Int(managedObject.fetchStoreId),
            fetchFulfilmentMethod: RetailStoreOrderMethodType(rawValue: managedObject.fetchFulfilmentMethod ?? ""),
            fetchSearchTerm: managedObject.fetchSearchTerm,
            fetchSearchScope: RetailStoreMenuGlobalSearchScope(rawValue: managedObject.fetchSearchScope ?? ""),
            fetchTimestamp: managedObject.timestamp,
            fetchItemsLimit: fetchItemsLimit,
            fetchItemsPage: fetchItemsPage,
            fetchCategoriesLimit: fetchCategoriesLimit,
            fetchCategoryPage: fetchCategoryPage
        )
        
    }
    
    @discardableResult
    func store(in context: NSManagedObjectContext) -> RetailStoreMenuGlobalSearchMO? {
        
        guard let search = RetailStoreMenuGlobalSearchMO.insertNew(in: context)
            else { return nil }
        
        search.categories = categories?.store(in: context)
        search.menuItems = menuItems?.store(in: context)
        search.deals = deals?.store(in: context)
        search.noItemHint = noItemFoundHint?.store(in: context)
        
        search.timestamp = Date().trueDate
        
        return search
    }
    
}

extension GlobalSearchResult {
    
    init?(managedObject: GlobalSearchResultMO) {
        
        var pagination: GlobalSearchResultPagination?
        if let managedPagination = managedObject.pagination {
            pagination = GlobalSearchResultPagination(managedObject: managedPagination)
        }
        
        var records: [GlobalSearchResultRecord]?
        if
            let managedRecords = managedObject.records,
            let recordsArray = managedRecords.array as? [GlobalSearchResultRecordMO]
        {
            records = recordsArray
                .reduce(nil, { (newArray, record) -> [GlobalSearchResultRecord]? in
                    guard let resultRecord = GlobalSearchResultRecord(managedObject: record)
                    else { return newArray }
                    var array = newArray ?? []
                    array.append(resultRecord)
                    return array
                })
        }
        
        self.init(
            pagination: pagination,
            records: records
        )
    }
    
    @discardableResult
    func store(in context: NSManagedObjectContext) -> GlobalSearchResultMO? {
        
        guard let result = GlobalSearchResultMO.insertNew(in: context)
            else { return nil }
        
        result.pagination = pagination?.store(in: context)
        
        if let records = records {
            result.records = NSOrderedSet(array: records.compactMap({ record -> GlobalSearchResultRecordMO? in
                return record.store(in: context)
            }))
        }
        
        return result
    }
    
}

// GlobalSearchItemsResult uses the same managed object as GlobalSearchResult but
// uses the menuItemRecords instead of the records relationship

extension GlobalSearchItemsResult {
    
    init?(managedObject: GlobalSearchResultMO) {
        
        var pagination: GlobalSearchResultPagination?
        if let managedPagination = managedObject.pagination {
            pagination = GlobalSearchResultPagination(managedObject: managedPagination)
        }
        
        var records: [RetailStoreMenuItem]?
        if
            let managedRecords = managedObject.menuItemRecords,
            let recordsArray = managedRecords.array as? [RetailStoreMenuItemMO]
        {
            records = recordsArray
                .reduce(nil, { (newArray, record) -> [RetailStoreMenuItem]? in
                    guard let resultRecord = RetailStoreMenuItem(managedObject: record)
                    else { return newArray }
                    var array = newArray ?? []
                    array.append(resultRecord)
                    return array
                })
        }
        
        self.init(
            pagination: pagination,
            records: records
        )
    }
    
    @discardableResult
    func store(in context: NSManagedObjectContext) -> GlobalSearchResultMO? {
        
        guard let result = GlobalSearchResultMO.insertNew(in: context)
            else { return nil }
        
        result.pagination = pagination?.store(in: context)
        
        if let records = records {
            result.menuItemRecords = NSOrderedSet(array: records.compactMap({ record -> RetailStoreMenuItemMO? in
                return record.store(in: context)
            }))
        }
        
        return result
    }
    
}

extension GlobalSearchNoItemHint {
    
    init?(managedObject: GlobalSearchNoItemHintMO) {
        self.init(
            numberToCall: managedObject.numberToCall,
            label: managedObject.label ?? ""
        )
    }
    
    @discardableResult
    func store(in context: NSManagedObjectContext) -> GlobalSearchNoItemHintMO? {
        
        guard let hint = GlobalSearchNoItemHintMO.insertNew(in: context)
            else { return nil }
        
        hint.numberToCall = numberToCall
        hint.label = label
        
        return hint
    }
    
}

extension GlobalSearchResultPagination {
    
    init?(managedObject: GlobalSearchResultPaginationMO) {
        self.init(
            page: Int(managedObject.page),
            perPage: Int(managedObject.perPage),
            totalCount: Int(managedObject.totalCount),
            pageCount: Int(managedObject.pageCount)
        )
    }
    
    @discardableResult
    func store(in context: NSManagedObjectContext) -> GlobalSearchResultPaginationMO? {
        
        guard let pagination = GlobalSearchResultPaginationMO.insertNew(in: context)
            else { return nil }
        
        pagination.page = Int16(page)
        pagination.perPage = Int16(perPage)
        pagination.totalCount = Int16(totalCount)
        pagination.pageCount = Int16(pageCount)
        
        return pagination
    }
    
}

extension GlobalSearchResultRecord {
    
    init?(managedObject: GlobalSearchResultRecordMO) {
        
        var price: RetailStoreMenuItemPrice?
        if let managedPrice = managedObject.price {
            price = RetailStoreMenuItemPrice(
                price: managedPrice.doubleValue,
                fromPrice: managedObject.fromPrice?.doubleValue ?? 0.0,
                unitMetric: managedObject.unitMetric ?? "",
                unitsInPack: managedObject.unitsInPack?.intValue ?? 0,
                unitVolume: managedObject.unitVolume?.doubleValue ?? 0,
                wasPrice: managedObject.wasPrice?.doubleValue
            )
        }
        
        self.init(
            id: Int(managedObject.id),
            name: managedObject.name ?? "",
            image: ImagePathMO.dictionary(from: managedObject.imagePaths),
            price: price
        )
    }
    
    @discardableResult
    func store(in context: NSManagedObjectContext) -> GlobalSearchResultRecordMO? {
        
        guard let resultRecord = GlobalSearchResultRecordMO.insertNew(in: context)
            else { return nil }
        
        if let price = price {
            resultRecord.price = NSNumber(value: price.price)
            resultRecord.fromPrice = NSNumber(value: price.fromPrice)
            resultRecord.unitMetric = price.unitMetric
            resultRecord.unitsInPack = NSNumber(value: price.unitsInPack)
            resultRecord.unitVolume = NSNumber(value: price.unitVolume)
            if let wasPrice = price.wasPrice {
                resultRecord.wasPrice = NSNumber(value: wasPrice)
            }
        }
        
        resultRecord.imagePaths = ImagePathMO.orderedSet(from: image, in: context)
        
        resultRecord.id = Int64(id)
        resultRecord.name = name
        
        return resultRecord
    }
}

extension ItemDetails {
    static func mapFromCoreData(_ storedItemDetails: ItemDetailsMO?) -> ItemDetails? {
        guard let storedItemDetails = storedItemDetails else { return nil }
        
        var elements: [ItemDetailElement]?
        
        if let managedElements = storedItemDetails.elements,
           let foundElements = managedElements.array as? [ItemDetailElementMO] {
            elements = foundElements
                .reduce(nil, { (elementsArray, record) -> [ItemDetailElement]? in
                    var array = elementsArray ?? []
                    if let element = ItemDetailElement.mapFromCoreData(record) {
                        array.append(element)
                    }
                    return array
                })
        }
        
        return ItemDetails(
            header: storedItemDetails.header,
            elements: elements)
    }
}

extension ItemDetailElement {
    static func mapFromCoreData(_ storedItemElement: ItemDetailElementMO?) -> ItemDetailElement? {
        guard let storedItemElement = storedItemElement else { return nil }

        var rows: [ItemDetailElementRow]?
        
        if let managedRows = storedItemElement.rows,
           let foundRows = managedRows.array as? [ItemDetailElementRowMO] {
            rows = foundRows
                .reduce(nil, { (rowsArray, record) -> [ItemDetailElementRow]? in
                    var array = rowsArray ?? []
                    if let row = ItemDetailElementRow.mapFromCoreData(record) {
                        array.append(row)
                    }
                    return array
                })
        }
        
        return ItemDetailElement(
            type: storedItemElement.type ?? "",
            text: storedItemElement.text,
            rows: rows)
    }
}

extension ItemDetailElementRow {
    static func mapFromCoreData(_ storedRow: ItemDetailElementRowMO?) -> ItemDetailElementRow? {
        guard let storedRow = storedRow else { return nil }

        var columns: [String]?
        
        if let managedColumns = storedRow.columns {
            columns = managedColumns
        }

        return ItemDetailElementRow(columns: columns)
    }
}

extension ItemDetails {
    func mapToCoreData(in context: NSManagedObjectContext) -> ItemDetailsMO? {
        let itemDetails = ItemDetailsMO(context: context)
        
        var elements: [ItemDetailElementMO]?
        
        if let itemDetailElements = self.elements {
            elements = itemDetailElements
                .reduce(nil, { (elementsArray, record) -> [ItemDetailElementMO]? in
                    var array = elementsArray ?? []
                    if let element = record.mapToCoreData(in: context) {
                        array.append(element)
                    }
                    return array
                })
        }
                
        itemDetails.header = header
        
        if let elements = elements {
            itemDetails.elements = NSOrderedSet(array: elements)
        }

        return itemDetails
    }
}

extension ItemDetailElement {
    func mapToCoreData(in context: NSManagedObjectContext) -> ItemDetailElementMO? {
        let element = ItemDetailElementMO(context: context)
        
        var rows: [ItemDetailElementRowMO]?
        
        if let itemDetailElementRows = self.rows {
            rows = itemDetailElementRows
                .reduce(nil, { (rowsArray, record) -> [ItemDetailElementRowMO]? in
                    var array = rowsArray ?? []
                    if let row = record.mapToCoreData(in: context) {
                        array.append(row)
                    }
                    return array
                })
        }
        
        element.type = type
        element.text = text
        
        if let rows = rows {
            element.rows = NSOrderedSet(array: rows)
        }
        
        return element
    }
}

extension ItemDetailElementRow {
    func mapToCoreData(in context: NSManagedObjectContext) -> ItemDetailElementRowMO? {
        let row = ItemDetailElementRowMO(context: context)
        
        row.columns = self.columns
        
        return row
    }
}
