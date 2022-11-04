//
//  RetailStoreMenuMockedData.swift
//  SnappyV2Tests
//
//  Created by Kevin Palser on 31/01/2022.
//

import Foundation
@testable import SnappyV2

extension RetailStoreMenuFetch {
    
    static let mockedDataFromAPI = RetailStoreMenuFetch(
        id: 543,
        name: "Name",
        categories: RetailStoreMenuCategory.mockedArrayData,
        menuItems: RetailStoreMenuItem.mockedArrayData,
        dealSections: nil,
        fetchStoreId: nil,
        fetchCategoryId: nil,
        fetchFulfilmentMethod: nil,
        fetchFulfilmentDate: nil,
        fetchTimestamp: nil
    )
    
    static let mockedData = RetailStoreMenuFetch(
        id: 543,
        name: "Name",
        categories: RetailStoreMenuCategory.mockedArrayData,
        menuItems: RetailStoreMenuItem.mockedArrayData,
        dealSections: nil,
        fetchStoreId: 910,
        fetchCategoryId: 0,
        fetchFulfilmentMethod: .delivery,
        fetchFulfilmentDate: "2021-05-15",
        fetchTimestamp: Date()
    )
    
    static let mockedDataCategories = RetailStoreMenuFetch(
        id: 543,
        name: "Name",
        categories: RetailStoreMenuCategory.mockedArrayData,
        menuItems: nil,
        dealSections: nil,
        fetchStoreId: 910,
        fetchCategoryId: 0,
        fetchFulfilmentMethod: .delivery,
        fetchFulfilmentDate: "2021-05-15",
        fetchTimestamp: Date()
    )
    
    static let mockedDataCategoriesFromAPI = RetailStoreMenuFetch(
        id: 543,
        name: "Name",
        categories: RetailStoreMenuCategory.mockedArrayData,
        menuItems: nil,
        dealSections: nil,
        fetchStoreId: nil,
        fetchCategoryId: nil,
        fetchFulfilmentMethod: nil,
        fetchFulfilmentDate: nil,
        fetchTimestamp: nil
    )
    
    static let mockedDataItems = RetailStoreMenuFetch(
        id: 543,
        name: "Name",
        categories: nil,
        menuItems: RetailStoreMenuItem.mockedArrayData,
        dealSections: nil,
        fetchStoreId: 910,
        fetchCategoryId: 0,
        fetchFulfilmentMethod: .delivery,
        fetchFulfilmentDate: "2021-05-15",
        fetchTimestamp: Date()
    )
    
    static let mockedDataItemsFromAPI = RetailStoreMenuFetch(
        id: 543,
        name: "Name",
        categories: nil,
        menuItems: RetailStoreMenuItem.mockedArrayData,
        dealSections: nil,
        fetchStoreId: nil,
        fetchCategoryId: nil,
        fetchFulfilmentMethod: nil,
        fetchFulfilmentDate: nil,
        fetchTimestamp: nil
    )
    
    static let mockedDataItemsWithDealSectionsFromAPI = RetailStoreMenuFetch(
        id: 543,
        name: "Name",
        categories: nil,
        menuItems: RetailStoreMenuItem.mockedArrayData,
        dealSections: [MenuItemCategory.mockedData],
        fetchStoreId: nil,
        fetchCategoryId: nil,
        fetchFulfilmentMethod: nil,
        fetchFulfilmentDate: nil,
        fetchTimestamp: nil
    )
    
    var recordsCount: Int {
        
        var count = 1
        
        if let categories = categories {
            for category in categories {
                count += category.recordsCount
            }
        }
        
        if let menuItems = menuItems {
            for menuItem in menuItems {
                count += menuItem.recordsCount
            }
        }

        return count
    }
    
}

extension RetailStoreMenuCategory {
    
    static let mockedData = RetailStoreMenuCategory(
        id: 202839,
        parentId: 0,
        name: "Test Item Options",
        image: [
            "mdpi_1x": URL(string: "https://www.snappyshopper.co.uk/uploads/mobile_app_images/mdpi_1x/1486735455210x210icon.png")!,
            "xhdpi_2x": URL(string: "https://www.snappyshopper.co.uk/uploads/mobile_app_images/xhdpi_2x/1486735455210x210icon.png")!,
            "xxhdpi_3x": URL(string: "https://www.snappyshopper.co.uk/uploads/mobile_app_images/xxhdpi_3x/1486735455210x210icon.png")!
        ],
        description: "<div class=\"wysiwyg\"></div>",
        action: nil
    )
    
    static let mockedArrayData: [RetailStoreMenuCategory] = [
        RetailStoreMenuCategory.mockedData
    ]
    
    var recordsCount: Int {
        
        var count = 1
        
        if let image = image {
            // images
            count += image.count
        }

        return count
    }
}

extension ItemDetails {
    
    static let mockedData = ItemDetails(
        header: "Test details",
        elements: [ItemDetailElement.mockedData])
}

extension ItemDetailElement {
    
    static let mockedData = ItemDetailElement(
        type: "Element",
        text: "Test",
        rows: [
            ItemDetailElementRow(columns: ["Test", "Test"])
        ])
}

extension RetailStoreMenuItem {
    
    static let mockedData = RetailStoreMenuItem(
        id: 3206127,
        name: "Basket limit conflict",
        eposCode: nil,
        outOfStock: false,
        ageRestriction: 0,
        description: "",
        quickAdd: true,
        acceptCustomerInstructions: false,
        basketQuantityLimit: 500,
        price: RetailStoreMenuItemPrice.mockedData,
        images: [
            [
                "mdpi_1x": URL(string: "https://www.snappyshopper.co.uk/uploads/mobile_app_images/mdpi_1x/1486738973default.png")!,
                "xhdpi_2x": URL(string: "https://www.snappyshopper.co.uk/uploads/mobile_app_images/xhdpi_2x/1486738973default.png")!,
                "xxhdpi_3x": URL(string: "https://www.snappyshopper.co.uk/uploads/mobile_app_images/xxhdpi_3x/1486738973default.png")!
            ]
        ],
        menuItemSizes: nil,
        menuItemOptions: nil,
        availableDeals: nil,
        itemCaptions: ItemCaptions(portionSize: "182 Kcal per 100g"),
        mainCategory: MenuItemCategory.mockedData, itemDetails: nil,
        deal: nil
    )
    
    static let mockedDataWithQuickAddFalse = RetailStoreMenuItem(
        id: 3206127,
        name: "Basket limit conflict",
        eposCode: nil,
        outOfStock: false,
        ageRestriction: 0,
        description: "Some Important Info",
        quickAdd: false,
        acceptCustomerInstructions: false,
        basketQuantityLimit: 500,
        price: RetailStoreMenuItemPrice.mockedData,
        images: [
            [
                "mdpi_1x": URL(string: "https://www.snappyshopper.co.uk/uploads/mobile_app_images/mdpi_1x/1486738973default.png")!,
                "xhdpi_2x": URL(string: "https://www.snappyshopper.co.uk/uploads/mobile_app_images/xhdpi_2x/1486738973default.png")!,
                "xxhdpi_3x": URL(string: "https://www.snappyshopper.co.uk/uploads/mobile_app_images/xxhdpi_3x/1486738973default.png")!
            ]
        ],
        menuItemSizes: nil,
        menuItemOptions: nil,
        availableDeals: nil,
        itemCaptions: ItemCaptions(portionSize: "182 Kcal per 100g"),
        mainCategory: MenuItemCategory.mockedData, itemDetails: nil,
        deal: nil
    )
    
    static let mockedDataWithAvailableDeals = RetailStoreMenuItem(
        id: 3206127,
        name: "Basket limit conflict",
        eposCode: nil,
        outOfStock: false,
        ageRestriction: 0,
        description: "",
        quickAdd: true,
        acceptCustomerInstructions: false,
        basketQuantityLimit: 500,
        price: RetailStoreMenuItemPrice.mockedData,
        images: [
            [
                "mdpi_1x": URL(string: "https://www.snappyshopper.co.uk/uploads/mobile_app_images/mdpi_1x/1486738973default.png")!,
                "xhdpi_2x": URL(string: "https://www.snappyshopper.co.uk/uploads/mobile_app_images/xhdpi_2x/1486738973default.png")!,
                "xxhdpi_3x": URL(string: "https://www.snappyshopper.co.uk/uploads/mobile_app_images/xxhdpi_3x/1486738973default.png")!
            ]
        ],
        menuItemSizes: nil,
        menuItemOptions: nil,
        availableDeals: RetailStoreMenuItemAvailableDeal.mockedMultipleDealData,
        itemCaptions: ItemCaptions(portionSize: "182 Kcal per 100g"),
        mainCategory: MenuItemCategory.mockedData,
        itemDetails: nil,
        deal: nil // Needs to be populated
    )
    
    static let mockedDataWithItemDetails = RetailStoreMenuItem(
        id: 3206127,
        name: "Basket limit conflict",
        eposCode: nil,
        outOfStock: false,
        ageRestriction: 0,
        description: "",
        quickAdd: true,
        acceptCustomerInstructions: false,
        basketQuantityLimit: 500,
        price: RetailStoreMenuItemPrice.mockedData,
        images: [
            [
                "mdpi_1x": URL(string: "https://www.snappyshopper.co.uk/uploads/mobile_app_images/mdpi_1x/1486738973default.png")!,
                "xhdpi_2x": URL(string: "https://www.snappyshopper.co.uk/uploads/mobile_app_images/xhdpi_2x/1486738973default.png")!,
                "xxhdpi_3x": URL(string: "https://www.snappyshopper.co.uk/uploads/mobile_app_images/xxhdpi_3x/1486738973default.png")!
            ]
        ],
        menuItemSizes: nil,
        menuItemOptions: nil,
        availableDeals: nil,
        itemCaptions: ItemCaptions(portionSize: "182 Kcal per 100g"),
        mainCategory: MenuItemCategory.mockedData,
        itemDetails: [ItemDetails.mockedData],
        deal: nil
    )

    static let mockedDataComplex = RetailStoreMenuItem(
        id: 2923969,
        name: "Option Grid Max(2) Min (0) Mutually Exclusive (true)",
        eposCode: nil,
        outOfStock: false,
        ageRestriction: 0,
        description: "This example contrasts the previous case where every option value in the grid can only be selected a maximum of once.",
        quickAdd: false,
        acceptCustomerInstructions: false,
        basketQuantityLimit: 500,
        price: RetailStoreMenuItemPrice.mockedData2,
        images: [
            [
                "mdpi_1x": URL(string: "https://www.snappyshopper.co.uk/uploads/mobile_app_images/mdpi_1x/1486738973default.png")!,
                "xhdpi_2x": URL(string: "https://www.snappyshopper.co.uk/uploads/mobile_app_images/xhdpi_2x/1486738973default.png")!,
                "xxhdpi_3x": URL(string: "https://www.snappyshopper.co.uk/uploads/mobile_app_images/xxhdpi_3x/1486738973default.png")!
            ]
        ],
        menuItemSizes: RetailStoreMenuItemSize.mockedArrayData,
        menuItemOptions: RetailStoreMenuItemOption.mockedArrayData,
        availableDeals: RetailStoreMenuItemAvailableDeal.mockedArrayData,
        itemCaptions: ItemCaptions(portionSize: "142 Kcal per 100g"),
        mainCategory: MenuItemCategory.mockedData,
        itemDetails: nil,
        deal: nil
    )
    
    static let mockedArrayData: [RetailStoreMenuItem] = [
        RetailStoreMenuItem.mockedData,
        RetailStoreMenuItem.mockedDataComplex
    ]

    var recordsCount: Int {
        
        var count = 2 // including mainCategory
        
        if let images = images {
            // images
            count += images.count
            for image in images {
                // size variation for each image
                count += image.count
            }
        }
        
        if let menuItemSizes = menuItemSizes {
            count += menuItemSizes.count
        }
        
        if let menuItemOptions = menuItemOptions {
            // options
            count += menuItemOptions.count
            for option in menuItemOptions {
                // dependencies
                count += option.dependencies.count
                
                if let values = option.values {
                    // values
                    for value in values {
                        count += value.recordsCount
                    }
                }
            }
        }
        
        if let availableDeals = availableDeals {
            // options
            count += availableDeals.count
        }
        
        return count
    }
}

extension RetailStoreMenuItemPrice {
    static let mockedData = RetailStoreMenuItemPrice(
        price: 10,
        fromPrice: 10,
        unitMetric: "none",
        unitsInPack: 1,
        unitVolume: 0,
        wasPrice: nil
    )
    
    static let mockedData2 = RetailStoreMenuItemPrice(
        price: 5,
        fromPrice: 5,
        unitMetric: "none",
        unitsInPack: 1,
        unitVolume: 0,
        wasPrice: nil
    )
}

extension RetailStoreMenuItemSize {
    
    static let mockedArrayData = [
        RetailStoreMenuItemSize.mockedData
    ]
    
    static let mockedData = RetailStoreMenuItemSize(
        id: 123,
        name: "Small",
        price: MenuItemSizePrice.mockedData
    )
    
}

extension MenuItemSizePrice {
    static let mockedData = MenuItemSizePrice(price: 8)
}

extension RetailStoreMenuItemOption {
    
    static let mockedArrayData = [
        RetailStoreMenuItemOption.mockedData
    ]
    
    static let mockedData = RetailStoreMenuItemOption(
        id: 134357,
        name: "Grid Example Option",
        type: .item,
        placeholder: "Choose your toppings",
        instances: 2,
        displayAsGrid: true,
        mutuallyExclusive: true,
        minimumSelected: 0,
        extraCostThreshold: 0,
        dependencies: [1, 2, 3],
        values: RetailStoreMenuItemOptionValue.mockedArrayData
    )
    
}

extension RetailStoreMenuItemOptionValue {
    
    static let mockedArrayData = [
        RetailStoreMenuItemOptionValue.mockedData
    ]
    
    static let mockedData = RetailStoreMenuItemOptionValue(
        id: 1190561,
        name: "Value A",
        extraCost: 0.25,
        defaultSelection: 0,
        sizeExtraCost: RetailStoreMenuItemOptionValueSizeCost.mockedArrayData
    )
    
    var recordsCount: Int {
        return 1 + (sizeExtraCost?.count ?? 0)
    }
    
}

extension RetailStoreMenuItemOptionValueSizeCost {
    
    static let mockedArrayData = [
        RetailStoreMenuItemOptionValueSizeCost.mockedData
    ]
    
    static let mockedData = RetailStoreMenuItemOptionValueSizeCost(
        id: 123,
        sizeId: 123,
        extraCost: 0.1
    )
}

extension MenuItemCategory {
    static let mockedData = MenuItemCategory(id: 345, name: "Bakery")
}

extension RetailStoreMenuItemAvailableDeal {
    
    static let mockedArrayData = [
        RetailStoreMenuItemAvailableDeal.mockedData
    ]
    
    static let mockedData = RetailStoreMenuItemAvailableDeal(
        id: 216298,
        name: "2 for the price of 1 (test)",
        type: "nforn"
    )
}

extension RetailStoreMenuItemAvailableDeal {
    static let mockedMultipleDealData = [
        RetailStoreMenuItemAvailableDeal(id: 123, name: "Test1", type: "Test"),
        RetailStoreMenuItemAvailableDeal(id: 456, name: "Test2", type: "Test"),
        RetailStoreMenuItemAvailableDeal(id: 789, name: "Test2", type: "Test")
    ]
}

extension RetailStoreMenuGlobalSearch {
    
    static let mockedData = RetailStoreMenuGlobalSearch(
        categories: GlobalSearchResult.mockedCategoriesData,
        menuItems: GlobalSearchItemsResult.mockedData,
        deals: GlobalSearchResult.mockedEmptyData,
        noItemFoundHint: GlobalSearchNoItemHint.mockedData,
        fetchStoreId: 910,
        fetchFulfilmentMethod: .delivery,
        fetchSearchTerm: "Test",
        fetchSearchScope: nil,
        fetchTimestamp: nil,
        fetchItemsLimit: nil,
        fetchItemsPage: nil,
        fetchCategoriesLimit: nil,
        fetchCategoryPage: nil
    )
    
    static let mockedDataFromAPI = RetailStoreMenuGlobalSearch(
        categories: GlobalSearchResult.mockedCategoriesData,
        menuItems: GlobalSearchItemsResult.mockedData,
        deals: GlobalSearchResult.mockedEmptyData,
        noItemFoundHint: GlobalSearchNoItemHint.mockedData,
        fetchStoreId: nil,
        fetchFulfilmentMethod: nil,
        fetchSearchTerm: nil,
        fetchSearchScope: nil,
        fetchTimestamp: nil,
        fetchItemsLimit: nil,
        fetchItemsPage: nil,
        fetchCategoriesLimit: nil,
        fetchCategoryPage: nil
    )
    
    var recordsCount: Int {
        return 1 + (noItemFoundHint != nil ? 1 : 0) + (categories?.recordsCount ?? 0) + (menuItems?.recordsCount ?? 0) + (deals?.recordsCount ?? 0)
    }
    
}

extension GlobalSearchResult {
    
    static let mockedCategoriesData = GlobalSearchResult(
        pagination: GlobalSearchResultPagination(
            page: 1,
            perPage: 3,
            totalCount: 5,
            pageCount: 2
        ),
        records: [
            GlobalSearchResultRecord(
                id: 319245,
                name: "Bags",
                image: [
                    "mdpi_1x": URL(string: "https://www.snappyshopper.co.uk/uploads/images/categories/originals/1637064287Bags.png")!,
                    "xhdpi_2x": URL(string: "https://www.snappyshopper.co.uk/uploads/images/categories/originals/1637064287Bags.png")!,
                    "xxhdpi_3x": URL(string: "https://www.snappyshopper.co.uk/uploads/images/categories/originals/1637064287Bags.png")!
                ],
                price: nil
            ),
            GlobalSearchResultRecord(
                id: 194446,
                name: "Bags & Wrap",
                image: [
                    "mdpi_1x": URL(string: "https://www.snappyshopper.co.uk/uploads/images/categories/originals/1563882645bagandwraps.png")!,
                    "xhdpi_2x": URL(string: "https://www.snappyshopper.co.uk/uploads/images/categories/originals/1563882645bagandwraps.png")!,
                    "xxhdpi_3x": URL(string: "https://www.snappyshopper.co.uk/uploads/images/categories/originals/1563882645bagandwraps.png")!
                ],
                price: nil
            ),
            GlobalSearchResultRecord(
                id: 108483,
                name: "Bags & Wrap",
                image: [
                    "mdpi_1x": URL(string: "https://www.snappyshopper.co.uk/uploads/images/categories/originals/1563882645bagandwraps.png")!,
                    "xhdpi_2x": URL(string: "https://www.snappyshopper.co.uk/uploads/images/categories/originals/1563882645bagandwraps.png")!,
                    "xxhdpi_3x": URL(string: "https://www.snappyshopper.co.uk/uploads/images/categories/originals/1563882645bagandwraps.png")!
                ],
                price: nil
            ),
        ]
    )
    
    static let mockedEmptyData = GlobalSearchResult(
        pagination: nil,
        records: []
    )
    
    var recordsCount: Int {
        
        var count = 1 + (pagination != nil ? 1 : 0)
        
        if let records = records {
            for record in records {
                count += record.recordsCount
            }
        }
        
        return count
    }
    
}

extension GlobalSearchResultRecord {
    
    var recordsCount: Int {
        return 1 + (image?.count ?? 0)
    }
    
}

extension GlobalSearchItemsResult {
    
    static let mockedData = GlobalSearchItemsResult(
        pagination: GlobalSearchResultPagination(
            page: 1,
            perPage: 2,
            totalCount: 2,
            pageCount: 1
        ),
        records: [
            RetailStoreMenuItem.mockedData,
            RetailStoreMenuItem.mockedDataComplex
        ]
    )
    
    var recordsCount: Int {
        
        var count = 1 + (pagination != nil ? 1 : 0)
        
        if let records = records {
            for record in records {
                count += record.recordsCount
            }
        }
        
        return count
    }
    
}

extension GlobalSearchNoItemHint {
    
    static let mockedData = GlobalSearchNoItemHint(
        numberToCall: "0132 123 456",
        label: "Do you think the item is sold by our store? Please give us a call to rectify."
    )
    
}

extension RetailStoreMenuItemRequest {
    
    static let mockedData = RetailStoreMenuItemRequest(
        itemId: 9999,
        storeId: 910,
        categoryId: 8888,
        fulfilmentMethod: .delivery,
        fulfilmentDate: "2020-06-28"
    )
    
}
