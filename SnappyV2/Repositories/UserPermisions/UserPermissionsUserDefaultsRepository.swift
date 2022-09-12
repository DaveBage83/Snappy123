//
//  UserPermissionsUserDefaultsRepository.swift
//  SnappyV2
//
//  Created by Kevin Palser on 08/09/2022.
//

import CoreData
import Combine
import CoreLocation

protocol UserPermissionsUserDefaultsRepositoryProtocol {
    // cannot have { get set } versions because the repository will be a "let" definition
    // within the service class
    var userChoseNoNotifications: Bool { get }
    var userPushNotificationMarketingSelection: PushNotificationDeviceMarketingOptIn { get }
    var userPushNotificationMarketingRegisteredSelection: PushNotificationDeviceMarketingOptIn { get }
    
    func setUserChoseNoNotifications(to: Bool)
    func setUserPushNotificationMarketingSelection(to: PushNotificationDeviceMarketingOptIn)
    func setUserPushNotificationMarketingRegisteredSelection(to: PushNotificationDeviceMarketingOptIn)
}

struct UserPermissionsUserDefaultsRepository: UserPermissionsUserDefaultsRepositoryProtocol {

    let userDefaults: UserDefaults
    
    // Taken from v1 - values need to remain the same for existing selections in the UserDefaults:
    
    // setting for user to allow notifications
    private let keyNoPushNotifications = "no_notifications"
    // 0 = not decided, 1 = don't want, 2 = allow
    private let keyMarketingNotificationSetting = "marketing_notification" // user's selection
    private let keySavedMarketingNotificationSetting = "saved_marketing_notification" // confirmed saved selection
    
    var userChoseNoNotifications: Bool {
        userDefaults.bool(forKey: keyNoPushNotifications)
    }
    
    var userPushNotificationMarketingSelection: PushNotificationDeviceMarketingOptIn {
        PushNotificationDeviceMarketingOptIn(rawValue: userDefaults.integer(forKey: keyMarketingNotificationSetting)) ?? .undecided
    }
    
    var userPushNotificationMarketingRegisteredSelection: PushNotificationDeviceMarketingOptIn {
        PushNotificationDeviceMarketingOptIn(rawValue: userDefaults.integer(forKey: keySavedMarketingNotificationSetting)) ?? .undecided
    }
    
    func setUserChoseNoNotifications(to newValue: Bool) {
        userDefaults.set(newValue, forKey: keyNoPushNotifications)
    }
    
    func setUserPushNotificationMarketingSelection(to newValue: PushNotificationDeviceMarketingOptIn) {
        userDefaults.set(newValue.rawValue, forKey: keyMarketingNotificationSetting)
    }
    
    func setUserPushNotificationMarketingRegisteredSelection(to newValue: PushNotificationDeviceMarketingOptIn) {
        userDefaults.set(newValue.rawValue, forKey: keySavedMarketingNotificationSetting)
    }
    
}
