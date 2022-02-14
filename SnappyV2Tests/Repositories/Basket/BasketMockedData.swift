//
//  BasketMockedData.swift
//  SnappyV2Tests
//
//  Created by Kevin Palser on 30/01/2022.
//

import Foundation
@testable import SnappyV2

extension Basket {

    static let mockedData = Basket(
        basketToken: "8c6f3a9a1f2ffa9e93a9ec2920a4a911",
        isNewBasket: false,
        items: BasketItem.mockedArrayData,
        fulfilmentMethod: BasketFulfilmentMethod.mockedData,
        selectedSlot: BasketSelectedSlot.mockedTodayData,
        savings: BasketSaving.mockedArrayData,
        coupon: BasketCoupon.mockedData,
        fees: BasketFee.mockedArrayData,
        addresses: BasketAddressResponse.mockedArrayData,
        orderSubtotal: 18.1,
        orderTotal: 23.3
    )
    
    var recordsCount: Int {
        
        var count = 1
        
        for item in items {
            count += item.recordsCount
        }
        
        if selectedSlot != nil {
            count += 1
        }
        
        if let savings = savings {
            for saving in savings {
                count += saving.recordsCount
            }
        }
        
        if coupon != nil {
            count += 1
        }
        
        if let fees = fees {
            count += fees.count
        }
        
        if let addresses = addresses {
            count += addresses.count
        }
        
        return count
    }
}

extension BasketItem {
    
    static let mockedData = BasketItem(
        basketLineId: 5304,
        menuItem: RetailStoreMenuItem.mockedData,
        totalPrice: 10,
        totalPriceBeforeDiscounts: 10,
        price: 10,
        pricePaid: 10,
        quantity: 1,
        size: nil,
        selectedOptions: nil,
        missedPromotions: nil
    )
    
    static let mockedDataComplex = BasketItem(
        basketLineId: 5305,
        menuItem: RetailStoreMenuItem.mockedDataComplex,
        totalPrice: 10.5,
        totalPriceBeforeDiscounts: 10.5,
        price: 10.5,
        pricePaid: 10.5,
        quantity: 1,
        size: BasketItemSelectedSize.mockedData,
        selectedOptions: BasketItemSelectedOption.mockedArrayData,
        missedPromotions: BasketItemMissedPromotion.mockedArrayData
    )
    
    static let mockedArrayData: [BasketItem] = [
        //mockedData,
        mockedDataComplex
    ]
    
    var recordsCount: Int {
        var count = 1
        count += menuItem.recordsCount
        if size != nil {
            count += 1
        }
        if let selectedOptions = selectedOptions {
            for selectedOption in selectedOptions {
                count += selectedOption.recordsCount
            }
        }
        if let missedPromotions = missedPromotions {
            for missedPromotion in missedPromotions {
                count += missedPromotion.recordsCount
            }
        }
        return count
    }
    
}

extension BasketFulfilmentMethod {
    
    static let mockedData = BasketFulfilmentMethod(type: .delivery)
    
}

extension BasketSelectedSlot {
    
    static let mockedTodayData = BasketSelectedSlot(todaySelected: true, start: nil, end: nil, expires: nil)
    
}

extension BasketSaving {
    
    static let mockedArrayData = [
        BasketSaving.mockedData
    ]
    
    static let mockedData = BasketSaving(
        name: "ACME discount",
        amount: 2.3,
        type: "percent",
        lines: [1, 2, 3]
    )
    
    var recordsCount: Int {
        var count = 1
        if let lines = lines {
            count += lines.count
        }
        return count
    }
    
}

extension BasketFee {
    
    static let mockedArrayData = [
        BasketFee.mockedData
    ]
    
    static let mockedData = BasketFee(
        typeId: 123,
        title: "ACME Fee",
        description: "Service Fee",
        isOptional: false,
        amount: 1.2
    )
    
}

extension BasketAddressResponse {
    
    static let mockedArrayData = [
        BasketAddressResponse.mockedDeliveryData,
        BasketAddressResponse.mockedBillingData
    ]
    
    static let mockedDeliveryData = BasketAddressResponse(
        firstName: nil,
        lastName: nil,
        addressLine1: "274E Blackness Road",
        addressLine2: "",
        town: "Dundee",
        postcode: "DD2 1RW",
        countryCode: nil,
        type: "delivery",
        email: nil,
        telephone: nil,
        state: nil,
        county: nil,
        location: nil
    )
    
    static let mockedBillingData = BasketAddressResponse(
        firstName: "Kevin",
        lastName: "Dover",
        addressLine1: "274E Blackness Road",
        addressLine2: "",
        town: "Dundee",
        postcode: "DD2 1RW",
        countryCode: "GB",
        type: "billing",
        email: "kevin.dover@me.com",
        telephone: "07925304522",
        state: nil,
        county: nil,
        location: nil
    )
    
}

extension BasketCoupon {
    
    static let mockedData = BasketCoupon(
        code: "ACME",
        name: "ACME Coupon",
        deductCost: 2.1
    )
    
}

extension BasketItemSelectedSize {
    
    static let mockedData = BasketItemSelectedSize(
        id: 123,
        name: "Small"
    )
    
}

extension BasketItemSelectedOption {
    
    static let mockedArrayData = [
        BasketItemSelectedOption.mockedData
    ]
    
    static let mockedData = BasketItemSelectedOption(
        id: 134357,
        selectedValues: [1190561, 1190562]
    )
    
    var recordsCount: Int {
        return 1 + selectedValues.count
    }
    
}

extension BasketItemMissedPromotion {
    
    static let mockedArrayData = [
        BasketItemMissedPromotion.mockedData
    ]
    
    static let mockedData = BasketItemMissedPromotion(
        referenceId: 216298,
        name: "2 for the price of 1 (test)",
        type: .discount,
        missedSections: BasketItemMissedPromotionSection.mockedArrayData
    )
    
    var recordsCount: Int {
        return 1 + (missedSections?.count ?? 0)
    }
    
}

extension BasketItemMissedPromotionSection {
    
    static let mockedArrayData = [
        BasketItemMissedPromotionSection.mockedData
    ]
    
    static let mockedData = BasketItemMissedPromotionSection(
        id: 123,
        name: "Drinks"
    )
    
}
