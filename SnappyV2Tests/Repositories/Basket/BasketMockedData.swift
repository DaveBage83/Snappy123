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
        tips: BasketTip.mockedArrayData,
        addresses: BasketAddressResponse.mockedArrayData,
        orderSubtotal: 18.1,
        orderTotal: 23.3,
        storeId: 1569,
        basketItemRemoved: nil
    )
    
    static let mockedDataStoreIdMismatch = Basket(
        basketToken: "8c6f3a9a1f2ffa9e93a9ec2920a4a911",
        isNewBasket: false,
        items: BasketItem.mockedArrayData,
        fulfilmentMethod: BasketFulfilmentMethod.mockedData,
        selectedSlot: BasketSelectedSlot.mockedTodayData,
        savings: BasketSaving.mockedArrayData,
        coupon: BasketCoupon.mockedData,
        fees: BasketFee.mockedArrayData,
        tips: BasketTip.mockedArrayData,
        addresses: BasketAddressResponse.mockedArrayData,
        orderSubtotal: 18.1,
        orderTotal: 23.3,
        storeId: 30,
        basketItemRemoved: nil
    )
    
    static let mockedDataStoreFulfilmentMismatch = Basket(
        basketToken: "8c6f3a9a1f2ffa9e93a9ec2920a4a911",
        isNewBasket: false,
        items: BasketItem.mockedArrayData,
        fulfilmentMethod: BasketFulfilmentMethod.mockedDataCollection,
        selectedSlot: BasketSelectedSlot.mockedTodayData,
        savings: BasketSaving.mockedArrayData,
        coupon: BasketCoupon.mockedData,
        fees: BasketFee.mockedArrayData,
        tips: BasketTip.mockedArrayData,
        addresses: BasketAddressResponse.mockedArrayData,
        orderSubtotal: 18.1,
        orderTotal: 23.3,
        storeId: 30,
        basketItemRemoved: nil
    )
    
    static let mockedDataOrderTotalIsZero = Basket(
        basketToken: "8c6f3a9a1f2ffa9e93a9ec2920a4a911",
        isNewBasket: false,
        items: BasketItem.mockedArrayData,
        fulfilmentMethod: BasketFulfilmentMethod.mockedDataCollection,
        selectedSlot: BasketSelectedSlot.mockedTodayData,
        savings: BasketSaving.mockedArrayData,
        coupon: BasketCoupon.mockedData,
        fees: BasketFee.mockedArrayData,
        tips: BasketTip.mockedArrayData,
        addresses: BasketAddressResponse.mockedArrayData,
        orderSubtotal: 0,
        orderTotal: 0,
        storeId: 0,
        basketItemRemoved: nil
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
        
        if let tips = tips {
            count += tips.count
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
        instructions: nil,
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
        instructions: nil,
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
    
    static let mockedData = BasketFulfilmentMethod(type: .delivery, cost: 2.5, minSpend: 10)
    
    static let mockedDataCollection = BasketFulfilmentMethod(type: .collection, cost: 0, minSpend: 0)
    
}

extension BasketSelectedSlot {
    
    static let mockedTodayData = BasketSelectedSlot(todaySelected: true, start: nil, end: nil, expires: nil)
    
    static let mockedYesterdaySlot = BasketSelectedSlot(
        todaySelected: false,
        start: Date().dayBefore,
        end: Date().dayBefore,
        expires: Date().dayBefore)
    
}

fileprivate extension Date {
    static var yesterday: Date { return Date().dayBefore }
    var dayBefore: Date {
        return Calendar.current.date(byAdding: .day, value: -1, to: noon)!
    }
    
    var noon: Date {
        return Calendar.current.date(bySettingHour: 12, minute: 0, second: 0, of: self)!
    }
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
        deductCost: 2.1,
        iterableCampaignId: 3454356,
        type: "set",
        value: 5,
        freeDelivery: false
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

extension BasketItemRequest {
    
    static let mockedData = BasketItemRequest(
        menuItemId: 12345,
        quantity: 2,
        sizeId: 0,
        bannerAdvertId: 0,
        options: BasketItemRequestOption.mockedArrayData,
        instructions: nil
    )
    
}

extension BasketItemRequestOption {
    
    static let mockedData = BasketItemRequestOption(
        id: 45,
        values: [1, 3, 6],
        type: BasketItemRequestOptionType.item
    )
    
    static let mockedArrayData = [
        BasketItemRequestOption.mockedData
    ]
    
}

extension BasketContactDetailsRequest {
    
    static let mockedData = BasketContactDetailsRequest(
        firstName: "Harold",
        lastName: "Dover",
        email: "h.dover@me.com",
        telephone: "079230565621"
    )
    
}

extension BasketAddressRequest {
    
    static let mockedBillingData = BasketAddressRequest(
        firstName: "Harold",
        lastName: "Dover",
        addressLine1: "274B Blackness Road",
        addressLine2: "",
        town: "Dundee",
        postcode: "DD2 1RW",
        countryCode: "GB",
        type: "billing",
        email: "String",
        telephone: "079230565621",
        state: nil,
        county: "Angus",
        location: Location.mockedData
    )
    
    static let mockedDeliveryData = BasketAddressRequest(
        firstName: "Harold",
        lastName: "Dover",
        addressLine1: "274B Blackness Road",
        addressLine2: "",
        town: "Dundee",
        postcode: "DD2 1RW",
        countryCode: "GB",
        type: "billing",
        email: "String",
        telephone: "079230565621",
        state: nil,
        county: "Angus",
        location: Location.mockedData
    )
    
}

extension Location {
    
    static let mockedData = Location(
        latitude: 56.473358599999997,
        longitude: -3.0111853000000002
    )
    
}
