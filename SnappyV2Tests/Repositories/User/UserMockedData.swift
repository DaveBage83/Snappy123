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
        firstName: "Harold",
        lastName: "Brown",
        emailAddress: "h.brown@gmail.com",
        type: .customer,
        fetchTimestamp: Date()
    )
    
    static let mockedDataFromAPI = MemberProfile(
        firstName: "Harold",
        lastName: "Brown",
        emailAddress: "h.brown@gmail.com",
        type: .customer,
        fetchTimestamp: nil
    )
    
    var recordsCount: Int {
        
        let count = 1
        
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
