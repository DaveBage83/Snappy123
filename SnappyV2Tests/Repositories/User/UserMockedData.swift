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
        uuid: "0dfd2fdc-efd8-11ec-8ea0-0242ac120002",
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
    
    static let mockedDataWithDefaultAddresses = MemberProfile(
        uuid: "0dfd2fdc-efd8-11ec-8ea0-0242ac120002",
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
        savedAddresses: Address.mockedSavedAddressesArrayWithDefault,
        fetchTimestamp: Date()
    )
    
    static let mockedDataEmptySavedAddresses = MemberProfile(
        uuid: "0dfd2fdc-efd8-11ec-8ea0-0242ac120002",
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
        savedAddresses: [],
        fetchTimestamp: Date()
    )
    
    static let mockedDataNoAddresses = MemberProfile(
        uuid: "0dfd2fdc-efd8-11ec-8ea0-0242ac120002",
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
        savedAddresses: nil,
        fetchTimestamp: Date()
    )
    
    static let mockedDataChangedProfileName = MemberProfile(
        uuid:"170e4930-efd8-11ec-8ea0-0242ac120002",
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
        uuid: "1e11eaac-efd8-11ec-8ea0-0242ac120002",
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
        uuid: "25aad5c6-efd8-11ec-8ea0-0242ac120002",
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
            uuid: "2bf8a764-efd8-11ec-8ea0-0242ac120002",
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
            uuid: "32db0432-efd8-11ec-8ea0-0242ac120002",
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
        uuid: "385af2b4-efd8-11ec-8ea0-0242ac120002",
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
        uuid: "402e7fc4-efd8-11ec-8ea0-0242ac120002",
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
        uuid: "4ddf6204-efd9-11ec-8ea0-0242ac120002",
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
        uuid: "54f39240-efd9-11ec-8ea0-0242ac120002",
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
        uuid: "5b4f3e5a-efd9-11ec-8ea0-0242ac120002",
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

extension LoginResult {
    
    static let mockedSuccessDataWithoutRegistering = LoginResult(
        success: true,
        token: ApiAuthenticationResult(
            token_type: "Bearer",
            expires_in: 86400,
            access_token: "eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiJ9.eyJhdWQiOiI5NDRkNWIyZC1hOGQ1LTRmZDAtYWM0MC05MWJkNmNkMmFkNGQiLCJqdGkiOiIzYzhmZDA4ODVlYmJiZDUyODRmMTg4OTlkMDIyOWQ3M2ExYzM2Yzc1YzQ1YmE0ZjZjY2E3N2M2MWI2ZTUwZWQwZjA4ODY3MGVlNmU4MDYzNyIsImlhdCI6MTY1MTkxMTc5NS44NzY5NTQsIm5iZiI6MTY1MTkxMTc5NS44NzY5NTgsImV4cCI6MTY1MTk5ODE5NS44NzM1NjgsInN1YiI6Ijk4OTU3Iiwic2NvcGVzIjpbIioiXSwic2Vzc2lvbl9pZCI6Ijg1Zjk0YmZiYWJmY2Y0ZjRmZDBjYjYyMjk0NWE1Njc1IiwiYnVzaW5lc3NfaWQiOjE1fQ.vRxiRuQoh2UP6VklBy6gm-cT1nd1cri3MZJRafiifrU4pgoR1vSFiww0MI5HBQsuI_a2IDTfL8gG9O6c_hEMDONkYxFcZjJxYSOHfsYGWCJ1lSg5uJN5DUE-bf-_037iIgVZvRIRYMTewpXmS_FOTEX38ZxlG8DaGo3M2liEg6HSs9I3MsY33W_SY3GDoUUuRWhuw2YA2D-xnCaXBlAcuJI7UcSWcABW3pgL_er50nVerLBrNih_PI2trzA_fYyyKjlMM3yoTYAwpPipAGEEqXjoYJbrZHFyqmkbJQ9fb9U6XgC_sbTZ02Oh3BEsIeHsAXnR9No7SY-kLJLoChX0Gtr6vHPSBmRTAZVLjFDq-rx27ylTTvWSQUSI4Q5_0bAgmoQeXfMAusw62UAyJgnSeQkA9E5wg1hD1PF4d_dozvLt7DCefjDJAIcMNs6v4Q0FbIN8E0u8mNx3IVKJz3iFH6fGMmNdkX5HTequjITqwn9nzMtDOfO77ikx8Of19H7WvOuDbPWn6tHSnm0Xvpyt40iwljcFG8Wzu4UCtNU-FBx81WnJScDUKCMROzmUiz3Y7HkNlKfP2iXgLN8terMQllBVvZO_qCbXwFX35rlsbhQN99wkeumn2NpvXOn6QKVJgI9bZmaYiWFMjhv2-PtY8z-mqlbERwHEhV2UreEmN5M",
            refresh_token: "def50200c1ec38969a482c16e84f23b6ea7f37b817444bf2231cc232a29a29bebb450d56d5895e33fcb9aac162732530deea5cdfb07494b30397dc4ea1d51d963d3d968a7a898d3abb104093144c9afbdfa1d667e5a3cc1f22b5c5af36aa7cdc6374f530509a7ccfb0a7e0fa90674f27857e3a7115eb755e9af67943246376e3b84d952614e34818a7cbfb57264302b184bce6eb19e6f43f71f6500a30087f48428caeb67f9d3598e1a5b7113ec0de665408e876ab1405db10754d04865fc6b96d630d880211f81d69b2b0a2b2b8319bdc5548460b0dc201c1f7d840d15fbcbdca71955168983a7f57aec7684796cab499480bbfd1e02289cc735ef278565cc53fa34f68723040c994ee0938e6375adfe49ef58154c670f3beefd6a47647092566aa5aa3c432f2253813bd04ff63b7508f06155cb8b30ffda8df09a7055900f721410bcb005cdeee7ca5026ea1727ac7da4f64b138c74b288f6242cb3c722e5979802948c1cd96fedd635a5dc5bbb8ade17989ce1d66eb6d91f0ea6d29f4f68070a5d5a8a064fe07f031cf"
        )
    )
    
    static let mockedSuccessDataAndRegistering = LoginResult(
        success: true,
        token: ApiAuthenticationResult(
            token_type: "Bearer",
            expires_in: 86400,
            access_token: "eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiJ9.eyJhdWQiOiI5NDRkNWIyZC1hOGQ1LTRmZDAtYWM0MC05MWJkNmNkMmFkNGQiLCJqdGkiOiIzYzhmZDA4ODVlYmJiZDUyODRmMTg4OTlkMDIyOWQ3M2ExYzM2Yzc1YzQ1YmE0ZjZjY2E3N2M2MWI2ZTUwZWQwZjA4ODY3MGVlNmU4MDYzNyIsImlhdCI6MTY1MTkxMTc5NS44NzY5NTQsIm5iZiI6MTY1MTkxMTc5NS44NzY5NTgsImV4cCI6MTY1MTk5ODE5NS44NzM1NjgsInN1YiI6Ijk4OTU3Iiwic2NvcGVzIjpbIioiXSwic2Vzc2lvbl9pZCI6Ijg1Zjk0YmZiYWJmY2Y0ZjRmZDBjYjYyMjk0NWE1Njc1IiwiYnVzaW5lc3NfaWQiOjE1fQ.vRxiRuQoh2UP6VklBy6gm-cT1nd1cri3MZJRafiifrU4pgoR1vSFiww0MI5HBQsuI_a2IDTfL8gG9O6c_hEMDONkYxFcZjJxYSOHfsYGWCJ1lSg5uJN5DUE-bf-_037iIgVZvRIRYMTewpXmS_FOTEX38ZxlG8DaGo3M2liEg6HSs9I3MsY33W_SY3GDoUUuRWhuw2YA2D-xnCaXBlAcuJI7UcSWcABW3pgL_er50nVerLBrNih_PI2trzA_fYyyKjlMM3yoTYAwpPipAGEEqXjoYJbrZHFyqmkbJQ9fb9U6XgC_sbTZ02Oh3BEsIeHsAXnR9No7SY-kLJLoChX0Gtr6vHPSBmRTAZVLjFDq-rx27ylTTvWSQUSI4Q5_0bAgmoQeXfMAusw62UAyJgnSeQkA9E5wg1hD1PF4d_dozvLt7DCefjDJAIcMNs6v4Q0FbIN8E0u8mNx3IVKJz3iFH6fGMmNdkX5HTequjITqwn9nzMtDOfO77ikx8Of19H7WvOuDbPWn6tHSnm0Xvpyt40iwljcFG8Wzu4UCtNU-FBx81WnJScDUKCMROzmUiz3Y7HkNlKfP2iXgLN8terMQllBVvZO_qCbXwFX35rlsbhQN99wkeumn2NpvXOn6QKVJgI9bZmaYiWFMjhv2-PtY8z-mqlbERwHEhV2UreEmN5M",
            refresh_token: "def50200c1ec38969a482c16e84f23b6ea7f37b817444bf2231cc232a29a29bebb450d56d5895e33fcb9aac162732530deea5cdfb07494b30397dc4ea1d51d963d3d968a7a898d3abb104093144c9afbdfa1d667e5a3cc1f22b5c5af36aa7cdc6374f530509a7ccfb0a7e0fa90674f27857e3a7115eb755e9af67943246376e3b84d952614e34818a7cbfb57264302b184bce6eb19e6f43f71f6500a30087f48428caeb67f9d3598e1a5b7113ec0de665408e876ab1405db10754d04865fc6b96d630d880211f81d69b2b0a2b2b8319bdc5548460b0dc201c1f7d840d15fbcbdca71955168983a7f57aec7684796cab499480bbfd1e02289cc735ef278565cc53fa34f68723040c994ee0938e6375adfe49ef58154c670f3beefd6a47647092566aa5aa3c432f2253813bd04ff63b7508f06155cb8b30ffda8df09a7055900f721410bcb005cdeee7ca5026ea1727ac7da4f64b138c74b288f6242cb3c722e5979802948c1cd96fedd635a5dc5bbb8ade17989ce1d66eb6d91f0ea6d29f4f68070a5d5a8a064fe07f031cf",
            newMemberRegistered: true
        )
    )
    
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
    
    static let mockedSavedAddressesArrayWithDefault: [Address] = [
        Address(
            id: 127501,
            isDefault: false,
            addressName: "D Address",
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
            addressName: "C Address",
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
            addressName: "A Address",
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
            isDefault: true,
            addressName: "B Address",
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
        ),
        
        // Billing
        Address(
            id: 127501,
            isDefault: false,
            addressName: "D Address",
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
            addressName: "C Address",
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
        ),
        Address(
            id: 231976,
            isDefault: false,
            addressName: "A Address",
            firstName: "",
            lastName: "",
            addressLine1: "5A BALLUMBIE DRIVE",
            addressLine2: "",
            town: "DUNDEE",
            postcode: "DD4 0NP",
            county: nil,
            countryCode: "",
            type: .billing,
            location: Location(
                latitude: 56.492564100000003,
                longitude: -2.9086242000000002
            ),
            email: nil,
            telephone: nil
        ),
        Address(
            id: 233294,
            isDefault: true,
            addressName: "B Address",
            firstName: "",
            lastName: "",
            addressLine1: "SKILLS DEVELOPMENT SCOTLAND",
            addressLine2: "ALBANY STREET",
            town: "OBAN",
            postcode: "PA34 4AG",
            county: nil,
            countryCode: "",
            type: .billing,
            location: Location(
                latitude: 56.410693299999998,
                longitude: -5.4759440000000001
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
    
    static let mockedFailureData = "{\n    \"success\": false\n}".data(using: .utf8) ?? Data()
    
    static let mockedNonJSONData = "ERROR: NOT JSON EXAMPLE".data(using: .utf8) ?? Data()
    
}

extension UserSuccessResult {
    
    static let mockedSuccessData = UserSuccessResult(success: true)
    
    static let mockedFailureData = UserSuccessResult(success: false)
    
}

extension UserRegistrationResult {
    
    static let mockedSucess = UserRegistrationResult(
        success: true,
        token: ApiAuthenticationResult(
            token_type: "Bearer",
            expires_in: 86400,
            access_token: "eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiJ9.eyJhdWQiOiI5NDRkNWIyZC1hOGQ1LTRmZDAtYWM0MC05MWJkNmNkMmFkNGQiLCJqdGkiOiIzYzhmZDA4ODVlYmJiZDUyODRmMTg4OTlkMDIyOWQ3M2ExYzM2Yzc1YzQ1YmE0ZjZjY2E3N2M2MWI2ZTUwZWQwZjA4ODY3MGVlNmU4MDYzNyIsImlhdCI6MTY1MTkxMTc5NS44NzY5NTQsIm5iZiI6MTY1MTkxMTc5NS44NzY5NTgsImV4cCI6MTY1MTk5ODE5NS44NzM1NjgsInN1YiI6Ijk4OTU3Iiwic2NvcGVzIjpbIioiXSwic2Vzc2lvbl9pZCI6Ijg1Zjk0YmZiYWJmY2Y0ZjRmZDBjYjYyMjk0NWE1Njc1IiwiYnVzaW5lc3NfaWQiOjE1fQ.vRxiRuQoh2UP6VklBy6gm-cT1nd1cri3MZJRafiifrU4pgoR1vSFiww0MI5HBQsuI_a2IDTfL8gG9O6c_hEMDONkYxFcZjJxYSOHfsYGWCJ1lSg5uJN5DUE-bf-_037iIgVZvRIRYMTewpXmS_FOTEX38ZxlG8DaGo3M2liEg6HSs9I3MsY33W_SY3GDoUUuRWhuw2YA2D-xnCaXBlAcuJI7UcSWcABW3pgL_er50nVerLBrNih_PI2trzA_fYyyKjlMM3yoTYAwpPipAGEEqXjoYJbrZHFyqmkbJQ9fb9U6XgC_sbTZ02Oh3BEsIeHsAXnR9No7SY-kLJLoChX0Gtr6vHPSBmRTAZVLjFDq-rx27ylTTvWSQUSI4Q5_0bAgmoQeXfMAusw62UAyJgnSeQkA9E5wg1hD1PF4d_dozvLt7DCefjDJAIcMNs6v4Q0FbIN8E0u8mNx3IVKJz3iFH6fGMmNdkX5HTequjITqwn9nzMtDOfO77ikx8Of19H7WvOuDbPWn6tHSnm0Xvpyt40iwljcFG8Wzu4UCtNU-FBx81WnJScDUKCMROzmUiz3Y7HkNlKfP2iXgLN8terMQllBVvZO_qCbXwFX35rlsbhQN99wkeumn2NpvXOn6QKVJgI9bZmaYiWFMjhv2-PtY8z-mqlbERwHEhV2UreEmN5M",
            refresh_token: "def50200c1ec38969a482c16e84f23b6ea7f37b817444bf2231cc232a29a29bebb450d56d5895e33fcb9aac162732530deea5cdfb07494b30397dc4ea1d51d963d3d968a7a898d3abb104093144c9afbdfa1d667e5a3cc1f22b5c5af36aa7cdc6374f530509a7ccfb0a7e0fa90674f27857e3a7115eb755e9af67943246376e3b84d952614e34818a7cbfb57264302b184bce6eb19e6f43f71f6500a30087f48428caeb67f9d3598e1a5b7113ec0de665408e876ab1405db10754d04865fc6b96d630d880211f81d69b2b0a2b2b8319bdc5548460b0dc201c1f7d840d15fbcbdca71955168983a7f57aec7684796cab499480bbfd1e02289cc735ef278565cc53fa34f68723040c994ee0938e6375adfe49ef58154c670f3beefd6a47647092566aa5aa3c432f2253813bd04ff63b7508f06155cb8b30ffda8df09a7055900f721410bcb005cdeee7ca5026ea1727ac7da4f64b138c74b288f6242cb3c722e5979802948c1cd96fedd635a5dc5bbb8ade17989ce1d66eb6d91f0ea6d29f4f68070a5d5a8a064fe07f031cf"
        )
    )
    
}

extension APIErrorResult {
    
    static let mockedMemberAlreadyRegistered = APIErrorResult(
        errorCode: 150001,
        errorText: "AUTH_ERROR",
        errorTitle: "Member already registered",
        errorDisplay: "The email address has already been used with another customer member account."
    )
    
    static let mockedUnauthorized = APIErrorResult(
        errorCode: 401,
        errorText: "Unauthorized",
        errorDisplay: "Unauthorized"
    )
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
    
    static let mockedDataIncompleteAddress = PlacedOrder(
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
        platform: AppV2Constants.Client.platform,
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
        type: .mobile,
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
