//
//  PushNotification.swift
//  SnappyV2
//
//  Created by Kevin Palser on 11/08/2022.
//

import Foundation
import UserNotifications

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
    let success: Bool
}

struct DisplayablePushNotification: Equatable, Identifiable {
    let id = UUID() // to avoid confussion with similar notifications with onChange modifiers when queuing
    let image: URL?
    let message: String
    let link: URL?
    let telephone: String?
}

struct RawNotification: Equatable, Identifiable {
    let id = UUID() // to avoid confussion with similar incoming notifications
    let data: [AnyHashable: Any]
    static func == (lhs: RawNotification, rhs: RawNotification) -> Bool {
        lhs.id == rhs.id && lhs.data.isEqual(to: rhs.data)
    }
}

// The PushNotification struct is intended for:
// (1) storing notifications until the app can process them after the initial restore step
// (2) to encapsulate for passing on to the Iterable SDK methods
struct PushNotification: Equatable, Identifiable {
    
    let id = UUID() // to avoid confussion with similar notifications with onChange modifiers when queuing
    let notification: UNNotification?
    let willPresentCompletionHandler: ((UNNotificationPresentationOptions) -> Void)?
    let response: UNNotificationResponse?
    let didReceiveCompletionHandler: (() -> Void)?
    
    static func == (lhs: PushNotification, rhs: PushNotification) -> Bool {
        if let lhsNotification = lhs.notification {
            if let rhsNotification = rhs.notification {
                return lhsNotification.request.identifier == rhsNotification.request.identifier
            } else {
                return false
            }
        } else if let lhsResponse = lhs.response {
            if let rhsResponse = rhs.response {
                return lhsResponse.notification.request.identifier == rhsResponse.notification.request.identifier
            } else {
                return false
            }
        }
        // would only reach here if the struct were incorrectly populated
        return (lhs.willPresentCompletionHandler != nil && rhs.willPresentCompletionHandler != nil) || (lhs.didReceiveCompletionHandler != nil && rhs.didReceiveCompletionHandler != nil)
    }
}
