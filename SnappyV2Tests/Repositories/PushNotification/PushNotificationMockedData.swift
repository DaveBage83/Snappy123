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
    
    static let mockedData = RegisterPushNotificationDeviceResult(success: true)
    
}

extension DisplayablePushNotification {
    
    static let mockedSimpleMessageData = DisplayablePushNotification(
        image: nil,
        message: "Simple message body",
        link: nil,
        telephone: nil,
        businessOrderId: nil,
        hash: nil
    )
    
    static let mockedAllOptionsMessageData = DisplayablePushNotification(
        image: URL(string: "https://www.kevin2.dev.snappyshopper.co.uk/uploads/images/notifications/xxhdpi_3x/1574176411multibuy.png")!,
        message: "All options message body",
        link: URL(string: "https://www.snappyshopper.co.uk")!,
        telephone: "0333 900 1250",
        businessOrderId: nil,
        hash: nil
    )
    
    static let mockedLinkedOptionMessageData = DisplayablePushNotification(
        image: nil,
        message: "Linked option message body",
        link: URL(string: "https://www.snappyshopper.co.uk")!,
        telephone: nil,
        businessOrderId: nil,
        hash: nil
    )
    
    static let mockedCallOptionMessageData = DisplayablePushNotification(
        image: nil,
        message: "Call option message body",
        link: nil,
        telephone: "0333 900 1250",
        businessOrderId: nil,
        hash: nil
    )
    
    static let mockedViewUpdateOrderMessageData = DisplayablePushNotification(
        image: nil,
        message: "Order #1234 has been modified. Please check the packaging for allergen information.",
        link: nil,
        telephone: nil,
        businessOrderId: 1234,
        hash: "bf456eaf4556adc345ea"
    )
    
}
