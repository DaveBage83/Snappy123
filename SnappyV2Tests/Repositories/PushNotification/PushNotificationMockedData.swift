//
//  PushNotificationMockedData.swift
//  SnappyV2Tests
//
//  Created by Kevin Palser on 31/08/2022.
//

import Foundation
@testable import SnappyV2

extension PushNotificationDeviceRequest {
    
    static let mockedData = PushNotificationDeviceRequest(
        deviceMessageToken: "23b194c52dd65f9dda2b2ac67074a23f9829b9703e1f0439fd08fd3a803ef0d7",
        firebaseCloudMessageToken: "something",
        oldDeviceMessageToken: "99b184c52dd65f9dda2b2ad67074a23f9829b9703e1f0439fe08fd3a803ef0ee",
        optOut: PushNotificationDeviceMarketingOptIn.optIn
    )
    
}

extension RegisterPushNotificationDeviceResult {
    
    static let mockedData = RegisterPushNotificationDeviceResult(status: true)
    
}
