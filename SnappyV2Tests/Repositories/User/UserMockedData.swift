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
    
    static let mockedDataChangedProfileName = MemberProfile(
        firstname: "Henry",
        lastname: "Kissinger",
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
    
    static let mockedDataNoBillingAddresses = MemberProfile(
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
        defaultBillingDetails: nil,
        savedAddresses: Address.mockedSavedAddressArrayNoBilling,
        fetchTimestamp: Date()
    )
    
    static let mockedDataNoDeliveryAddresses = MemberProfile(
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
        defaultBillingDetails: nil,
        savedAddresses: Address.mockedSavedAddressArrayNoDelivery,
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
        location: nil,
        email: nil,
        telephone: nil
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
        location: nil,
        email: nil,
        telephone: nil
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
        ),
        email: nil,
        telephone: nil
    )
    
    static let mockedRepeatOrderAddress = Address(
        id: 910,
        isDefault: false,
        addressName: nil,
        firstName: "Harold",
        lastName: "Brown",
        addressLine1: "Gallanach Rd",
        addressLine2: nil,
        town: "Oban",
        postcode: "PA34 4PD",
        county: nil,
        countryCode: "GB",
        type: .delivery,
        location: Location(
            latitude: 56.492564100000003,
            longitude: -2.9086242000000002
        ),
        email: "testemail@email.com",
        telephone: "09998278888"
    )
    
    static let mockedAddressIncomplete = Address(
        id: 910,
        isDefault: false,
        addressName: nil,
        firstName: "Harold",
        lastName: "Brown",
        addressLine1: "Gallanach Rd",
        addressLine2: nil,
        town: "Oban",
        postcode: "PA34 4PD",
        county: nil,
        countryCode: "GB",
        type: .delivery,
        location: Location(
            latitude: 56.492564100000003,
            longitude: -2.9086242000000002
        ),
        email: "testemail@email.com",
        telephone: nil
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
        ),
        email: nil,
        telephone: nil
    )
    
    static let mockedSavedAddressArrayNoBilling: [Address] = [
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
            ),
            email: nil,
            telephone: nil
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
            ),
            email: nil,
            telephone: nil
        )
    ]

    static let mockedSavedAddressArrayNoDelivery: [Address] = [
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
            type: .billing,
            location: Location(
                latitude: 56.460570599999997,
                longitude: -2.9989202000000001
            ),
            email: nil,
            telephone: nil
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
            type: .billing,
            location: Location(
                latitude: 56.410461900000001,
                longitude: -5.4764108
            ),
            email: nil,
            telephone: nil
        )
    ]
    
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
            ),
            email: nil,
            telephone: nil
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
            ),
            email: nil,
            telephone: nil
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
            ),
            email: nil,
            telephone: nil
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
            ),
            email: nil,
            telephone: nil
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
            ),
            email: nil,
            telephone: nil
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
    
    static let mockedRegistrationSuccessData = "{\n    \"success\": true,\r\n\t\"token\": {\n        \"refresh_token\": \"def50200c9218fde9b90ec6862dd3db401740e89c1bcd49db5127e75366995e70acf27bcb59937fd82ecb23345e118ec71d9f1a806977afd7749138316a310995f3e7776d9837539abef32409ca6ea07a6ad6fc11ff664b5887357104c14e9ace1d9f8d067fcbbaa4dc769c814838f84aed3a660dc8190781f72c98f6a7b0c64123a6de07c4e94738975ccad706dab468ae232a608b2250256b1aca51766a8a808d21926f2213eee18925effef1ad0b8e034c4fd64bc20b01abb0aff27f4f9fd178188066833a64cc932e611d28a9f0f5c9aa054c8ed32bf78d464033429dd0b0ae31701ed3ebf09df98f9cfb8d7b8d9d9bbbf6912097e4f26072535d60ba13ef4565fc3cc0acd42b253fdf405d2dc40d4b62348f50a2650424424394e4d4654e3f2fc2ca0b1153fe4bb91adb790b05dce59e602295e43b3f852ce386de68a48102d04745eef3e72ed9e6950e505cfd90d320bbfd3bfb1b1282376041fb30c89122592eb3b044427f7c2873f8784d4177564b83e382d7b8b4b1b3be217891cd7cd6136015b707c14b7a299\",\n        \"token_type\" : \"Bearer\",\n        \"expires_in\" : 86400,\n        \"access_token\" : \"eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiJ9.eyJhdWQiOiI5NDRkNWIyZC1hOGQ1LTRmZDAtYWM0MC05MWJkNmNkMmFkNGQiLCJqdGkiOiJkZDcxODc1NGIyNWVhYTA3Njk1OGFhMzdlY2VhNTFmMmNkZjI1ZmRlOGZkNjcxMzFkYWM4OWE0NmJhMjBkYzRjNmU2YzM2MThmMGI1NzlmOCIsImlhdCI6MTY1MDc4OTMyNy45NzYzMDQsIm5iZiI6MTY1MDc4OTMyNy45NzYzMDgsImV4cCI6MTY1MDg3NTcyNy45NzI5NTgsInN1YiI6Ijk4OTU3Iiwic2NvcGVzIjpbIioiXSwic2Vzc2lvbl9pZCI6IjUxNmI1NDg0MzIwZWQxNWZiODM1MWMxMjljNzFhMDgwIiwiYnVzaW5lc3NfaWQiOjE1fQ.sC-cZ6-maBuS_9lA4IJek-CbCWaVZvgMOeSpRpdN6lCMNtB4N5sY8CyqQw4yZ8oinxIdksYXqYPH4xWbSOGINM-LagbA-I7Y576vSGdUsn65-3NHzxwE-jubmvb4YWdeTpUWcJBVK5sLtPxud9xB1zoL7HgWTmnGk2utqJA6fy2oA-_SFe90WU-sfIst1nuTQBBGCT4DlH8f-urqwCySqgV9kHDJtT5yfiWUlNMURTfEM1v2LkdwQWhP7b8GcfkQYVZqjSXxG2YdbaPzzBXnSAjsD13_w9lU3iy4F_lTj3_n74srM4XFuHykaRJ1X2BC0hdeCe4A-5_iQjQzv4y2tFCAhChHHa0NlKG2rAVe1JRpD3SLAu61TDnZdYxEY42yT2U5Y3dhQarWL6ja30HNoV5RJJxj8AOqNx5_gXjxhg5346t6jlgAaCLpSItuDG3tJoCS4WshEdk0UkuJQD5ks6-sTKkeP1CSNYucN7-Ex4NCTUe_brdvV4h--D_S9CdRnUKy1dUzmZVkGMkf8IQD0dGLJBEazXjgD0Wnug2_xREQLw01YFq3kP1BC0SZGIbsuKTDgrA3xlYTa_J3psMElgwMcqPXA4UIE7eW-6MzrL4wy-UKDy4XVPFMMMSK806Ttzl4leQdUZhJwijCqwv9AR4ORx38VbwGjGiGJ5U6bUA\"\n    }\n}".data(using: .utf8) ?? Data()
    
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
        platform: AppV2Constants.Client.platform,
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
    
    static let mockedDataRepeatOrder = PlacedOrder(
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
    
    static let mockedDataIncompleteAddress = PlacedOrder(
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
        fulfilmentMethod: PlacedOrderFulfilmentMethod.mockedDataIncompleteAddress,
        paymentMethod: PlacedOrderPaymentMethod.mockedData,
        orderLines: PlacedOrderLine.mockedArrayData,
        customer: PlacedOrderCustomer.mockedData,
        discount: PlacedOrderDiscount.mockedArrayData,
        surcharges: PlacedOrderSurcharge.mockedArrayData,
        loyaltyPoints: PlacedOrderLoyaltyPoints.mockedData,
        coupon: PlacedOrderCoupon.mockedData
    )

    static let mockedDataNoDeliveryAddress = PlacedOrder(
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
        fulfilmentMethod: PlacedOrderFulfilmentMethod.mockedDataNoDeliveryAddress,
        paymentMethod: PlacedOrderPaymentMethod.mockedData,
        orderLines: PlacedOrderLine.mockedArrayData,
        customer: PlacedOrderCustomer.mockedData,
        discount: PlacedOrderDiscount.mockedArrayData,
        surcharges: PlacedOrderSurcharge.mockedArrayData,
        loyaltyPoints: PlacedOrderLoyaltyPoints.mockedData,
        coupon: PlacedOrderCoupon.mockedData
    )
    
    static let mockedDataCollection = PlacedOrder(
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
        fulfilmentMethod: PlacedOrderFulfilmentMethod.mockedDataCollection,
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
    
    static let mockedDataStatusComplete = PlacedOrder(
        id: 1963404,
        businessOrderId: 2106,
        status: "delivered",
        statusText: "delivered",
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
    
    static let mockedDataAddressLine2Present = PlacedOrderStore(
        id: 910,
        name: "Master Testtt",
        originalStoreId: nil,
        storeLogo: [
            "mdpi_1x": URL(string: "https://www.snappyshopper.co.uk/uploads/images/stores/mdpi_1x/1589564824552274_13470292_2505971_9c972622_image.png")!,
            "xhdpi_2x": URL(string: "https://www.snappyshopper.co.uk/uploads/images/stores/xhdpi_2x/1589564824552274_13470292_2505971_9c972622_image.png")!,
            "xxhdpi_3x": URL(string: "https://www.snappyshopper.co.uk/uploads/images/stores/xxhdpi_3x/1589564824552274_13470292_2505971_9c972622_image.png")!
        ],
        address1: "Gallanach Rd",
        address2: "Line 2 test",
        town: "Oban",
        postcode: "PA34 4PD",
        telephone: "07986238097",
        latitude: 56.4087526,
        longitude: -5.4875930999999998
    )
    
    static let mockedDataNoTelephone = PlacedOrderStore(
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
        telephone: nil,
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
        address: Address.mockedRepeatOrderAddress,
        driverTip: 1.5,
        refund: nil,
        deliveryCost: 1,
        driverTipRefunds: nil
    )
    
    static let mockedDataIncompleteAddress = PlacedOrderFulfilmentMethod(
        name: RetailStoreOrderMethodType.delivery,
        processingStatus: "Store Accepted / Picking",
        datetime: PlacedOrderFulfilmentMethodDateTime.mockedData,
        place: nil,
        address: Address.mockedAddressIncomplete,
        driverTip: 1.5,
        refund: nil,
        deliveryCost: 1,
        driverTipRefunds: nil
    )

    static let mockedDataCollection = PlacedOrderFulfilmentMethod(
        name: RetailStoreOrderMethodType.collection,
        processingStatus: "Store Accepted / Picking",
        datetime: PlacedOrderFulfilmentMethodDateTime.mockedData,
        place: nil,
        address: nil,
        driverTip: 1.5,
        refund: nil,
        deliveryCost: 1,
        driverTipRefunds: nil
    )
    
    static let mockedDataRepeatOrder = PlacedOrderFulfilmentMethod(
        name: RetailStoreOrderMethodType.delivery,
        processingStatus: "Store Accepted / Picking",
        datetime: PlacedOrderFulfilmentMethodDateTime.mockedData,
        place: nil,
        address: Address.mockedKnownDeliveryData,
        driverTip: 1.5,
        refund: nil,
        deliveryCost: 1,
        driverTipRefunds: nil
    )
    
    static let mockedDataNoDeliveryAddress = PlacedOrderFulfilmentMethod(
        name: RetailStoreOrderMethodType.delivery,
        processingStatus: "Store Accepted / Picking",
        datetime: PlacedOrderFulfilmentMethodDateTime.mockedData,
        place: nil,
        address: nil,
        driverTip: 1.5,
        refund: nil,
        deliveryCost: 1,
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
    
    static let mockedDataRejectedLine = PlacedOrderLine(
        id: 12136536,
        substitutesOrderLineId: nil,
        quantity: 1,
        rewardPoints: nil,
        pricePaid: 10,
        discount: 0,
        substitutionAllowed: nil,
        customerInstructions: nil,
        rejectionReason: "test_reason",
        item: PastOrderLineItem.mockedData
    )
    
    static let mockedDataDiscounted = PlacedOrderLine(
        id: 12136536,
        substitutesOrderLineId: nil,
        quantity: 1,
        rewardPoints: nil,
        pricePaid: 10,
        discount: 5,
        substitutionAllowed: nil,
        customerInstructions: nil,
        rejectionReason: "test_reason",
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
        images: [
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

extension CheckRegistrationResult {
    
    static let mockedData = CheckRegistrationResult(
        loginRequired: true,
        contacts: CheckRegistrationContactResult.mockedArrayData
    )
}

extension CheckRegistrationContactResult {
    
    static let mockedSMSData = CheckRegistrationContactResult(
        type: .sms,
        display: "Send SMS to XXXXXXXX12"
    )
    
    static let mockedEmailData = CheckRegistrationContactResult(
        type: .email,
        display: "Send email to XXXX@XXXXXX.XX"
    )
    
    static let mockedArrayData = [
        CheckRegistrationContactResult.mockedSMSData,
        CheckRegistrationContactResult.mockedEmailData
    ]
    
}

extension OneTimePasswordSendResult {
    
    static let mockedData = OneTimePasswordSendResult(
        success: true,
        message: "SMS sent"
    )
    
}
