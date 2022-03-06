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
    
//    static let mockedData = MemberProfile(
//        firstName: "Harold",
//        lastName: "Brown",
//        emailAddress: "h.brown@gmail.com",
//        type: .customer,
//        fetchTimestamp: Date()
//    )
    
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
        addressline1: "50 BALLUMBIE DRIVE",
        addressline2: "",
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
        addressline1: "50 BALLUMBIE DRIVE",
        addressline2: "",
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
        addressline1: "50 BALLUMBIE DRIVE",
        addressline2: "",
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
    
    static let mockedSavedAddressesArray: [Address] = [
        Address.mockedBillingData,
        Address(
            id: 127501,
            isDefault: false,
            addressName: nil,
            firstName: "",
            lastName: "",
            addressline1: "268G BLACKNESS ROAD",
            addressline2: "",
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
            addressline1: "OBAN CHURCH",
            addressline2: "ALBANY STREET",
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
            addressline1: "5A BALLUMBIE DRIVE",
            addressline2: "",
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
            addressline1: "SKILLS DEVELOPMENT SCOTLAND",
            addressline2: "ALBANY STREET",
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
    
}

extension Data {
    
    static let mockedRegisterSuccessData = "{\n    \"success\": true\n}".data(using: .utf8) ?? Data()
    
    static let mockedRegisterEmailAlreadyUsedData = "{\n    \"email\": [\n        \"The email has already been taken\"\n    ]\n}".data(using: .utf8) ?? Data()
    
}
