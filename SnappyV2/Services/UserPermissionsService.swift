//
//  UserPermissionsService.swift
//  SnappyV2
//
//  Created by Kevin Palser on 11/08/2022.
//

import Foundation
import UserNotifications
import UIKit

enum Permission {
    case pushNotifications
}

extension Permission {
    enum Status: Equatable {
        case unknown
        case notRequested
        case granted
        case denied
    }
}

protocol UserPermissionsServiceProtocol: AnyObject {
    func resolveStatus(for permission: Permission)
    func request(permission: Permission)
    var pushNotificationPreferencesRequired: Bool { get }
    var unsavedPushNotificationPreferences: Bool { get }
    var userDoesNotWantPushNotifications: Bool { get }
    var userPushNotificationMarketingSelection: PushNotificationDeviceMarketingOptIn { get }
    func setUserDoesNotWantPushNotifications()
    func setSavedPushNotificationMarketingSelection()
    func setPushNotificationMarketingSelection(to: PushNotificationDeviceMarketingOptIn)
}

// MARK: - UserPermissionsService

final class UserPermissionsService: UserPermissionsServiceProtocol {
    
    private let appState: Store<AppState>
    private let openAppSettings: () -> Void
    
    // Taken from v1 - values need to remain the same for existing selections in the UserDefaults:
    
    // setting for user to allow notifications
    private let keyNoPushNotifications = "no_notifications"
    // 0 = not decided, 1 = don't want, 2 = allow
    private let keyMarketingNotificationSetting = "marketing_notification" // user's selection
    private let keySavedMarketingNotificationSetting = "saved_marketing_notification" // confirmed saved selection
    
    init(appState: Store<AppState>, openAppSettings: @escaping () -> Void) {
        self.appState = appState
        self.openAppSettings = openAppSettings
    }
    
    func resolveStatus(for permission: Permission) {
        let keyPath = AppState.permissionKeyPath(for: permission)
        let currentStatus = appState[keyPath]
        guard currentStatus == .unknown else { return }
        let onResolve: (Permission.Status) -> Void = { [weak appState] status in
            appState?[keyPath] = status
        }
        switch permission {
        case .pushNotifications:
            pushNotificationsPermissionStatus(onResolve)
        }
    }
    
    func request(permission: Permission) {
        let keyPath = AppState.permissionKeyPath(for: permission)
        let currentStatus = appState[keyPath]
        guard currentStatus != .denied else {
            openAppSettings()
            return
        }
        switch permission {
        case .pushNotifications:
            requestPushNotificationsPermission()
        }
    }
    
    // User preferences/decisions made directly with the app UI
    
    var pushNotificationPreferencesRequired: Bool {
        let userDefaults = UserDefaults.standard
        return userDefaults.bool(forKey: keyNoPushNotifications) == false && userDefaults.integer(forKey: keyMarketingNotificationSetting) == 0
    }
    
    var unsavedPushNotificationPreferences: Bool {
        let userDefaults = UserDefaults.standard
        return userDefaults.integer(forKey: keyMarketingNotificationSetting) != userDefaults.integer(forKey: keySavedMarketingNotificationSetting)
    }
    
    var userDoesNotWantPushNotifications: Bool {
        UserDefaults.standard.bool(forKey: keyNoPushNotifications)
    }
    
    var userPushNotificationMarketingSelection: PushNotificationDeviceMarketingOptIn {
        PushNotificationDeviceMarketingOptIn(rawValue: UserDefaults.standard.integer(forKey: keyMarketingNotificationSetting)) ?? .undecided
    }
    
    func setUserDoesNotWantPushNotifications() {
        UserDefaults.standard.set(true, forKey: keyNoPushNotifications)
    }
    
    func setSavedPushNotificationMarketingSelection() {
        let userDefaults = UserDefaults.standard
        userDefaults.setValue(userDefaults.integer(forKey: keyMarketingNotificationSetting), forKey: keySavedMarketingNotificationSetting)
    }
    
    func setPushNotificationMarketingSelection(to preference: PushNotificationDeviceMarketingOptIn) {
        UserDefaults.standard.set(preference.rawValue, forKey: keyMarketingNotificationSetting)
        // By requesting permission if this is the first, then the system dialog will be displayed.
        // Subsequently, the token should still be returned without the prompt and the app will
        // call the register endpoint with the appropriate preferences.
        requestPushNotificationsPermission()
    }
}
    
// MARK: - Push Notifications

extension UNAuthorizationStatus {
    var map: Permission.Status {
        switch self {
        case .denied: return .denied
        case .authorized: return .granted
        case .notDetermined, .provisional, .ephemeral: return .notRequested
        @unknown default: return .notRequested
        }
    }
}

private extension UserPermissionsService {
    
    // System privilege results - those set interacting with the push notifications system
    // prompt or main device settings
    
    func pushNotificationsPermissionStatus(_ resolve: @escaping (Permission.Status) -> Void) {
        let center = UNUserNotificationCenter.current()
        center.getNotificationSettings { settings in
            DispatchQueue.main.async {
                resolve(settings.authorizationStatus.map)
            }
        }
    }
    
    func requestPushNotificationsPermission() {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.sound, .alert, .badge]) { (isGranted, error) in
            DispatchQueue.main.async {
                self.appState[\.permissions.push] = isGranted ? .granted : .denied
                if isGranted && error == nil {
                    let deafultCategory = UNNotificationCategory(identifier: "ImagePush", actions: [], intentIdentifiers: [], options: [])
                    center.setNotificationCategories(Set([deafultCategory]))
                    UIApplication.shared.registerForRemoteNotifications()
                }
            }
        }
    }

}

// MARK: -

final class StubUserPermissionsService: UserPermissionsServiceProtocol {
    func resolveStatus(for permission: Permission) {}
    func request(permission: Permission) {}
    var pushNotificationPreferencesRequired = false
    var userPushNotificationMarketingSelection: PushNotificationDeviceMarketingOptIn = .undecided
    var unsavedPushNotificationPreferences = false
    var userDoesNotWantPushNotifications = false
    func setUserDoesNotWantPushNotifications() {}
    func setSavedPushNotificationMarketingSelection() {}
    func setPushNotificationMarketingSelection(to: PushNotificationDeviceMarketingOptIn) {}
}
