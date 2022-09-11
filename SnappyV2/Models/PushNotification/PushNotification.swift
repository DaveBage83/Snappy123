//
//  PushNotification.swift
//  SnappyV2
//
//  Created by Kevin Palser on 11/08/2022.
//

import Foundation

enum PushNotificationDeviceMarketingOptIn: Int, Equatable {
    case undecided = 0
    case optOut = 1
    case optIn = 2
}

struct PushNotificationDeviceRequest: Equatable {
    let deviceMessageToken: String
    let firebaseCloudMessageToken: String?
    let oldDeviceMessageToken: String?
    let optOut: PushNotificationDeviceMarketingOptIn?
}

struct RegisterPushNotificationDeviceResult: Codable, Equatable {
    let status: Bool
}

struct DisplayablePushNotification: Equatable, Identifiable {
    let id = UUID() // to avoid confussion with similar notifications with onChange modifiers when queuing
    let image: URL?
    let message: String
    let link: URL?
    let telephone: String?
}
