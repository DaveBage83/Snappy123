//
//  RetailStoreMenuMockedData.swift
//  SnappyV2Tests
//
//  Created by Kevin Palser on 31/01/2022.
//

import Foundation
@testable import SnappyV2

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
        availableDeals: nil
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
        price: RetailStoreMenuItemPrice.mockedData,
        images: [
            [
                "mdpi_1x": URL(string: "https://www.snappyshopper.co.uk/uploads/mobile_app_images/mdpi_1x/1486738973default.png")!,
                "xhdpi_2x": URL(string: "https://www.snappyshopper.co.uk/uploads/mobile_app_images/xhdpi_2x/1486738973default.png")!,
                "xxhdpi_3x": URL(string: "https://www.snappyshopper.co.uk/uploads/mobile_app_images/xxhdpi_3x/1486738973default.png")!
            ]
        ],
        menuItemSizes: RetailStoreMenuItemSize.mockedArrayData,
        menuItemOptions: RetailStoreMenuItemOption.mockedArrayData,
        availableDeals: RetailStoreMenuItemAvailableDeal.mockedArrayData
    )

    var recordsCount: Int {
        
        var count = 1
        
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
                if let dependencies = option.dependencies {
                    count += dependencies.count
                }
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
