//
//  UserMockedData.swift
//  SnappyV2Tests
//
//  Created by Kevin Palser on 10/02/2022.
//

import Foundation
@testable import SnappyV2

extension MemberProfile {
    
    static let mockedData = MemberProfile(
        firstname: "Harold",
        lastname: "Brown",
        emailAddress: "h.brown@gmail.com",
        type: .customer,
        referFriendCode: "FAD4C",
        referFriendBalance: 12.45,
        numberOfReferrals: 2,
        mobileContactNumber: "0792334112",
        mobileValidated: true,
        acceptedMarketing: true,
        defaultBillingDetails: Address.mockedBillingData,
        savedAddresses: Address.mockedSavedAddressesArray,
        fetchTimestamp: Date()
    )
    
    static func mockedUpdatedMockedData(firstname: String, lastname: String, mobileContactNumber: String) -> MemberProfile {
        MemberProfile(
            firstname: firstname,
            lastname: lastname,
            emailAddress: "h.brown@gmail.com",
            type: .customer,
            referFriendCode: "FAD4C",
            referFriendBalance: 12.45,
            numberOfReferrals: 2,
            mobileContactNumber: mobileContactNumber,
            mobileValidated: true,
            acceptedMarketing: true,
            defaultBillingDetails: Address.mockedBillingData,
            savedAddresses: Address.mockedSavedAddressesArray,
            fetchTimestamp: Date()
        )
    }
    
    static let mockedAddAddressProfileResponse = MemberProfile(
            firstname: "Harold",
            lastname: "Brown",
            emailAddress: "h.brown@gmail.com",
            type: .customer,
            referFriendCode: "FAD4C",
            referFriendBalance: 12.45,
            numberOfReferrals: 2,
            mobileContactNumber: "0792334112",
            mobileValidated: true,
            acceptedMarketing: true,
            defaultBillingDetails: Address.mockedBillingData,
            savedAddresses: Address.addAddressArray(),
            fetchTimestamp: Date()
        )
    
    static let mockedUpdatedAddressProfile = MemberProfile(
        firstname: "Harold",
        lastname: "Brown",
        emailAddress: "h.brown@gmail.com",
        type: .customer,
        referFriendCode: "FAD4C",
        referFriendBalance: 12.45,
        numberOfReferrals: 2,
        mobileContactNumber: "0792334112",
        mobileValidated: true,
        acceptedMarketing: true,
        defaultBillingDetails: Address.mockedBillingData,
        savedAddresses: Address.updateAddressArray(),
        fetchTimestamp: Date())
    
    static let mockedDefaultAddressSetProfile = MemberProfile(
        firstname: "Harold",
        lastname: "Brown",
        emailAddress: "h.brown@gmail.com",
        type: .customer,
        referFriendCode: "FAD4C",
        referFriendBalance: 12.45,
        numberOfReferrals: 2,
        mobileContactNumber: "0792334112",
        mobileValidated: true,
        acceptedMarketing: true,
        defaultBillingDetails: Address.mockedBillingData,
        savedAddresses: Address.defaultAddressSetArray(),
        fetchTimestamp: Date())
    
    static let mockedDataNoPhone  = MemberProfile(
        firstname: "Harold",
        lastname: "Brown",
        emailAddress: "h.brown@gmail.com",
        type: .customer,
        referFriendCode: "FAD4C",
        referFriendBalance: 12.45,
        numberOfReferrals: 2,
        mobileContactNumber: "",
        mobileValidated: true,
        acceptedMarketing: true,
        defaultBillingDetails: Address.mockedBillingData,
        savedAddresses: Address.mockedSavedAddressesArray,
        fetchTimestamp: nil
    )
    
    static let mockedDataFromAPI = MemberProfile(
        firstname: "Harold",
        lastname: "Brown",
        emailAddress: "h.brown@gmail.com",
        type: .customer,
        referFriendCode: "FAD4C",
        referFriendBalance: 12.45,
        numberOfReferrals: 2,
        mobileContactNumber: "0792334112",
        mobileValidated: true,
        acceptedMarketing: true,
        defaultBillingDetails: Address.mockedBillingData,
        savedAddresses: Address.mockedSavedAddressesArray,
        fetchTimestamp: nil
    )
    
    static let mockedRemoveAddressProfile = MemberProfile(
        firstname: "Harold",
        lastname: "Brown",
        emailAddress: "h.brown@gmail.com",
        type: .customer,
        referFriendCode: "FAD4C",
        referFriendBalance: 12.45,
        numberOfReferrals: 2,
        mobileContactNumber: "0792334112",
        mobileValidated: true,
        acceptedMarketing: true,
        defaultBillingDetails: Address.mockedBillingData,
        savedAddresses: Address.removedAddressArray(),
        fetchTimestamp: nil
    )
    
    var recordsCount: Int {
        
        var count = 1
        
        if defaultBillingDetails != nil {
            count += 1
        }
        
        if let savedAddresses = savedAddresses {
            count += savedAddresses.count
        }
        
        return count
    }
    
}

extension MemberProfileRegisterRequest {
    
    static let mockedData = MemberProfileRegisterRequest(
        firstname: "Harold",
        lastname: "Brown",
        emailAddress: "h.brown@gmail.com",
        referFriendCode: "FAD4C",
        mobileContactNumber: "0792334112",
        defaultBillingDetails: Address.mockedBillingData,
        savedAddresses: Address.mockedSavedAddressesArray
    )
    
}

extension UserMarketingOptionsFetch {
    
    static let mockedDataNotificationDisabled = UserMarketingOptionsFetch(
        marketingPreferencesIntro: "Some intro string",
        marketingPreferencesGuestIntro: "Another intro string",
        marketingOptions: UserMarketingOptionResponse.mockedArrayData,
        fetchIsCheckout: false,
        fetchNotificationsEnabled: false,
        fetchBasketToken: nil,
        fetchTimestamp: Date()
    )
    
    static let mockedDataNotificationDisabledWithBasketToken = UserMarketingOptionsFetch(
        marketingPreferencesIntro: "Some intro string",
        marketingPreferencesGuestIntro: "Another intro string",
        marketingOptions: UserMarketingOptionResponse.mockedArrayData,
        fetchIsCheckout: true,
        fetchNotificationsEnabled: false,
        fetchBasketToken: "8c6f3a9a1f2ffa9e93a9ec2920a4a911",
        fetchTimestamp: Date()
    )
    
    static let mockedDataFromAPI = UserMarketingOptionsFetch(
        marketingPreferencesIntro: "Some intro string",
        marketingPreferencesGuestIntro: "Another intro string",
        marketingOptions: UserMarketingOptionResponse.mockedArrayData,
        fetchIsCheckout: nil,
        fetchNotificationsEnabled: nil,
        fetchBasketToken: nil,
        fetchTimestamp: nil
    )
    
    var recordsCount: Int {
        var count = 1
        
        if let marketingOptions = marketingOptions {
            count += marketingOptions.count
        }
        
        return count
    }
}

extension UserMarketingOptionResponse {
    
    static let mockedArrayData = [
        UserMarketingOptionResponse.mockedEmailData,
        UserMarketingOptionResponse.mockedSMSData
    ]
    
    static let mockedEmailData = UserMarketingOptionResponse(
        type: "email",
        text: "Mareketing Emails",
        opted: .in
    )
    
    static let mockedSMSData = UserMarketingOptionResponse(
        type: "sms",
        text: "SMS Marketing",
        opted: .out
    )
    
}

extension UserMarketingOptionRequest {
    
    static let mockedArrayData = [
        UserMarketingOptionRequest.mockedEmailData,
        UserMarketingOptionRequest.mockedSMSData
    ]
    
    static let mockedEmailData = UserMarketingOptionRequest(
        type: "email",
        opted: .in
    )
    
    static let mockedSMSData = UserMarketingOptionRequest(
        type: "sms",
        opted: .out
    )
    
}

extension UserMarketingOptionsUpdateResponse {
    
    static let mockedData = UserMarketingOptionsUpdateResponse(
        email: UserMarketingOptionState.in,
        directMail: nil,
        notification: nil,
        telephone: nil,
        sms: UserMarketingOptionState.out
    )
    
}

extension Address {
    
    static let mockedBillingData = Address(
        id: 102259,
        isDefault: false,
        addressName: nil,
        firstName: "Harold",
        lastName: "Brown",
        addressLine1: "50 BALLUMBIE DRIVE",
        addressLine2: "",
        town: "DUNDEE",
        postcode: "DD4 0NP",
        county: nil,
        countryCode: "GB",
        type: .billing,
        location: nil
    )
    
    static let mockedNewDeliveryData = Address(
        id: nil,
        isDefault: false,
        addressName: nil,
        firstName: "Harold",
        lastName: "Brown",
        addressLine1: "50 BALLUMBIE DRIVE",
        addressLine2: "",
        town: "DUNDEE",
        postcode: "DD4 0NP",
        county: nil,
        countryCode: "GB",
        type: .delivery,
        location: nil
    )
    
    static let mockedKnownDeliveryData = Address(
        id: 165035,
        isDefault: false,
        addressName: nil,
        firstName: "Harold",
        lastName: "Brown",
        addressLine1: "50 BALLUMBIE DRIVE",
        addressLine2: "",
        town: "DUNDEE",
        postcode: "DD4 0NP",
        county: nil,
        countryCode: "GB",
        type: .delivery,
        location: Location(
            latitude: 56.492564100000003,
            longitude: -2.9086242000000002
        )
    )
    
    static let addressToUpdate: Address = Address(
        id: 127501,
        isDefault: false,
        addressName: nil,
        firstName: "",
        lastName: "",
        addressLine1: "300 BLACKNESS ROAD",
        addressLine2: "",
        town: "DUNDEE",
        postcode: "DD2 1RW",
        county: nil,
        countryCode: "",
        type: .delivery,
        location: Location(
            latitude: 56.460570599999997,
            longitude: -2.9989202000000001
        )
    )

    static let mockedSavedAddressesArray: [Address] = [
        Address.mockedBillingData,
        Address(
            id: 127501,
            isDefault: false,
            addressName: nil,
            firstName: "",
            lastName: "",
            addressLine1: "268G BLACKNESS ROAD",
            addressLine2: "",
            town: "DUNDEE",
            postcode: "DD2 1RW",
            county: nil,
            countryCode: "",
            type: .delivery,
            location: Location(
                latitude: 56.460570599999997,
                longitude: -2.9989202000000001
            )
        ),
        Address(
            id: 165034,
            isDefault: false,
            addressName: nil,
            firstName: "",
            lastName: "",
            addressLine1: "OBAN CHURCH",
            addressLine2: "ALBANY STREET",
            town: "OBAN",
            postcode: "PA34 4AG",
            county: nil,
            countryCode: "",
            type: .delivery,
            location: Location(
                latitude: 56.410461900000001,
                longitude: -5.4764108
            )
        ),
        Address(
            id: 231976,
            isDefault: false,
            addressName: nil,
            firstName: "",
            lastName: "",
            addressLine1: "5A BALLUMBIE DRIVE",
            addressLine2: "",
            town: "DUNDEE",
            postcode: "DD4 0NP",
            county: nil,
            countryCode: "",
            type: .delivery,
            location: Location(
                latitude: 56.492564100000003,
                longitude: -2.9086242000000002
            )
        ),
        Address(
            id: 233294,
            isDefault: false,
            addressName: nil,
            firstName: "",
            lastName: "",
            addressLine1: "SKILLS DEVELOPMENT SCOTLAND",
            addressLine2: "ALBANY STREET",
            town: "OBAN",
            postcode: "PA34 4AG",
            county: nil,
            countryCode: "",
            type: .delivery,
            location: Location(
                latitude: 56.410693299999998,
                longitude: -5.4759440000000001
            )
        )
    ]
    
    static func addAddressArray() -> [Address] {
        var addresses = mockedSavedAddressesArray
        addresses.append(mockedNewDeliveryData)
        return addresses
    }
    
    static func updateAddressArray() -> [Address] {
        var addresses = mockedSavedAddressesArray
        addresses.removeFirst()
        addresses.insert(addressToUpdate, at: 0)
        return addresses
    }
    
    static func defaultAddressSetArray() -> [Address] {
        var addresses = mockedSavedAddressesArray
        addresses.removeFirst()
        let newAddress = Address(
            id: 127501,
            isDefault: true,
            addressName: nil,
            firstName: "",
            lastName: "",
            addressLine1: "268G BLACKNESS ROAD",
            addressLine2: "",
            town: "DUNDEE",
            postcode: "DD2 1RW",
            county: nil,
            countryCode: "",
            type: .delivery,
            location: Location(
                latitude: 56.460570599999997,
                longitude: -2.9989202000000001
            )
        )
        addresses.insert(newAddress, at: 0)
        return addresses
    }
    
    static func removedAddressArray() -> [Address] {
        var addresses = mockedSavedAddressesArray
        return [addresses.removeFirst()]
    }
}

extension Data {
    
    static let mockedSuccessData = "{\n    \"success\": true\n}".data(using: .utf8) ?? Data()
    
    static let mockedFailureData = "{\n    \"success\": false\n}".data(using: .utf8) ?? Data()
    
    static let mockedNonJSONData = "ERROR: NOT JSON EXAMPLE".data(using: .utf8) ?? Data()
    
    static let mockedRegisterEmailAlreadyUsedData = "{\n    \"email\": [\n        \"The email has already been taken\"\n    ]\n}".data(using: .utf8) ?? Data()
    
}

extension UserSuccessResult {
    
    static let mockedSuccessData = UserSuccessResult(success: true)
    
    static let mockedFailureData = UserSuccessResult(success: false)
    
}

extension PlacedOrder {
    
    static let mockedData = PlacedOrder(
        id: 1963404,
        businessOrderId: 2106,
        status: "Store Accepted / Picking",
        statusText: "store_accepted_picking",
        totalPrice: 11.25,
        totalDiscounts: 0,
        totalSurcharge: 0.58999999999999997,
        totalToPay: 13.09,
        platform: "ios",
        firstOrder: true,
        createdAt: "2022-02-23 10:35:10",
        updatedAt: "2022-02-23 10:35:10",
        store: PlacedOrderStore.mockedData,
        fulfilmentMethod: PlacedOrderFulfilmentMethod.mockedData,
        paymentMethod: PlacedOrderPaymentMethod.mockedData,
        orderLines: PlacedOrderLine.mockedArrayData,
        customer: PlacedOrderCustomer.mockedData,
        discount: PlacedOrderDiscount.mockedArrayData,
        surcharges: PlacedOrderSurcharge.mockedArrayData,
        loyaltyPoints: PlacedOrderLoyaltyPoints.mockedData,
        coupon: PlacedOrderCoupon.mockedData
    )
    
    static let mockedDataArray = [
        PlacedOrder.mockedData
    ]
    
}

extension PlacedOrderStore {
    
    static let mockedData = PlacedOrderStore(
        id: 910,
        name: "Master Testtt",
        originalStoreId: nil,
        storeLogo: [
            "mdpi_1x": URL(string: "https://www.snappyshopper.co.uk/uploads/images/stores/mdpi_1x/1589564824552274_13470292_2505971_9c972622_image.png")!,
            "xhdpi_2x": URL(string: "https://www.snappyshopper.co.uk/uploads/images/stores/xhdpi_2x/1589564824552274_13470292_2505971_9c972622_image.png")!,
            "xxhdpi_3x": URL(string: "https://www.snappyshopper.co.uk/uploads/images/stores/xxhdpi_3x/1589564824552274_13470292_2505971_9c972622_image.png")!
        ],
        address1: "Gallanach Rd",
        address2: nil,
        town: "Oban",
        postcode: "PA34 4PD",
        telephone: "07986238097",
        latitude: 56.4087526,
        longitude: -5.4875930999999998
    )
    
}

extension PlacedOrderFulfilmentMethod {
    
    static let mockedData = PlacedOrderFulfilmentMethod(
        name: RetailStoreOrderMethodType.delivery,
        processingStatus: "Store Accepted / Picking",
        datetime: PlacedOrderFulfilmentMethodDateTime.mockedData,
        place: nil,
        address: Address.mockedKnownDeliveryData,
        driverTip: 1.5,
        refund: nil,
        driverTipRefunds: nil
    )
    
}

extension PlacedOrderPaymentMethod {
    
    static let mockedData = PlacedOrderPaymentMethod(
        name: "realex",
        dateTime: "2022-02-18 "
    )
    
}

extension PlacedOrderFulfilmentMethodDateTime {
    
    static let mockedData: PlacedOrderFulfilmentMethodDateTime = {
        // Note: Date() would fail the XCTAssertEqual, set to a
        // specific date.
        let date = Date(timeIntervalSince1970: 1632146400) // Monday, 20 September 2021 15:00:00
        return PlacedOrderFulfilmentMethodDateTime(
            requestedDate: "2022-02-18",
            requestedTime: "17:40 - 17:55",
            estimated: date,
            fulfilled: nil
        )
    }()
    
}

extension PlacedOrderLine {
    
    static let mockedData = PlacedOrderLine(
        id: 12136536,
        substitutesOrderLineId: nil,
        quantity: 1,
        rewardPoints: nil,
        pricePaid: 10,
        discount: 0,
        substitutionAllowed: nil,
        customerInstructions: nil,
        rejectionReason: nil,
        item: PastOrderLineItem.mockedData
    )
    
    static let mockedArrayData = [
        PlacedOrderLine.mockedData
    ]
    
}

extension PastOrderLineItem {
    
    static let mockedData = PastOrderLineItem(
        id: 3206126,
        name: "Max basket quantity 10",
        image: [
            [
                "mdpi_1x": URL(string: "https://www.snappyshopper.co.uk/uploads/images/stores/mdpi_1x/1486738973default.png")!,
                "xhdpi_2x": URL(string: "https://www.snappyshopper.co.uk/uploads/images/stores/xhdpi_2x/1486738973default.png")!,
                "xxhdpi_3x": URL(string: "https://www.snappyshopper.co.uk/uploads/images/stores/xxhdpi_3x/1486738973default.png")!
            ]
        ],
        price: 10
    )
    
}

extension PlacedOrderCustomer {
    
    static let mockedData = PlacedOrderCustomer(
        firstname: "Kevin",
        lastname: "Palser"
    )
    
}

extension PlacedOrderDiscount {
    
    static let mockedData = PlacedOrderDiscount(
        name: "Multi Buy Example",
        amount: 0.4,
        type: "nforn",
        lines: [12136536]
    )
    
    static let mockedArrayData = [
        PlacedOrderDiscount.mockedData
    ]
    
}

extension PlacedOrderSurcharge {
    
    static let mockedServiceChargeData = PlacedOrderSurcharge(
        name: "Service Charge",
        amount: 0.09
    )
    
    static let mockedBagChargeData = PlacedOrderSurcharge(
        name: "Gov bag charge",
        amount: 0.01
    )
    
    static let mockedArrayData = [
        PlacedOrderSurcharge.mockedServiceChargeData,
        PlacedOrderSurcharge.mockedBagChargeData
    ]
    
}

extension PlacedOrderLoyaltyPoints {
    
    static let mockedData = PlacedOrderLoyaltyPoints(
        type: "refer",
        name: "Friend Reward Discount",
        deductCost: 0
    )
    
}

extension PlacedOrderCoupon {
    
    static let mockedData = PlacedOrderCoupon(
        title: "Test % Coupon",
        couponDeduct: 1.83,
        type: "percentage",
        freeDelivery: false,
        value: 1.83,
        iterableCampaignId: 0,
        percentage: 10,
        registeredMemberRequirement: false
    )
    
}
