//
//  AppV2PushNotificationConstants.swift
//  SnappyV2
//
//  Created by Kevin Palser on 26/08/2022.
//

// This file is separate from the AppV2Constants so that its target
// membership can be set for both the main SnappyV2 target and the
// Notification Service. We cannot

import Foundation

struct AppV2PushNotificationConstants {
    // with integrations like Iterable we need to check if the data came
    // from our own server or needs to be passed on directly to the 3rd
    // party SDK
    static let checkNotificationSource = true
}
