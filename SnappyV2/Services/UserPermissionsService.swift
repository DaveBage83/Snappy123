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
    case marketingPushNotifications
}

extension Permission {
    enum Status: Equatable {
        case unknown // not yet established for the permission service
        case notRequested
        case granted
        case denied
    }
}

protocol UserPermissionsServiceProtocol: AnyObject {
    func resolveStatus(for permission: Permission, reconfirmIfKnown: Bool)
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
    
    private let userDefaultsRepository: UserPermissionsUserDefaultsRepositoryProtocol
    
    private let appState: Store<AppState>
    private let openAppSettings: () -> Void
    
    init(userDefaultsRepository: UserPermissionsUserDefaultsRepositoryProtocol, appState: Store<AppState>, openAppSettings: @escaping () -> Void) {
        self.userDefaultsRepository = userDefaultsRepository
        self.appState = appState
        self.openAppSettings = openAppSettings
    }
    
    func resolveStatus(for permission: Permission, reconfirmIfKnown: Bool) {
        let keyPath = AppState.permissionKeyPath(for: permission)
        let currentStatus = appState[keyPath]
        guard currentStatus == .unknown || reconfirmIfKnown else { return }
        let onResolve: (Permission.Status) -> Void = { [weak appState, weak self] status in
            guard let self = self else { return }
            appState?[keyPath] = status
            // if the user subsequently enables notifications from the settings
            // then not wanting notification should be unset
            if permission == .pushNotifications && status == .granted {
                self.userDefaultsRepository.setUserChoseNoNotifications(to: false)
            }
        }
        switch permission {
        case .pushNotifications:
            pushNotificationsPermissionStatus(onResolve)
        case .marketingPushNotifications:
            userPushNotificationMarketingSelection(onResolve)
        }
    }
    
    func request(permission: Permission) {
        // only intended for device app permissions
        guard permission == .pushNotifications else { return }
        
        let keyPath = AppState.permissionKeyPath(for: permission)
        let currentStatus = appState[keyPath]
        guard currentStatus != .denied else {
            openAppSettings()
            return
        }
        switch permission {
        case .pushNotifications:
            requestPushNotificationsPermission()
        default:
            break
        }
    }
    
    // User preferences/decisions made directly with the app UI
    
    var pushNotificationPreferencesRequired: Bool {
        userDefaultsRepository.userChoseNoNotifications == false && userDefaultsRepository.userPushNotificationMarketingSelection == .undecided
    }
    
    var unsavedPushNotificationPreferences: Bool {
        userDefaultsRepository.userPushNotificationMarketingSelection != userDefaultsRepository.userPushNotificationMarketingRegisteredSelection
    }
    
    var userDoesNotWantPushNotifications: Bool {
        userDefaultsRepository.userChoseNoNotifications
    }
    
    var userPushNotificationMarketingSelection: PushNotificationDeviceMarketingOptIn {
        userDefaultsRepository.userPushNotificationMarketingSelection
    }
    
    func setUserDoesNotWantPushNotifications() {
        userDefaultsRepository.setUserChoseNoNotifications(to: true)
    }
    
    func setSavedPushNotificationMarketingSelection() {
        userDefaultsRepository.setUserPushNotificationMarketingRegisteredSelection(to: userDefaultsRepository.userPushNotificationMarketingSelection)
    }
    
    func setPushNotificationMarketingSelection(to preference: PushNotificationDeviceMarketingOptIn) {
        guard userPushNotificationMarketingSelection != preference else { return }
        // set the locally stored value
        userDefaultsRepository.setUserPushNotificationMarketingSelection(to: preference)
        // set the live value used for listening subscriptions
        self.appState[\.permissions.marketingPushNotifications] = preference.map
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

extension PushNotificationDeviceMarketingOptIn {
    var map: Permission.Status {
        switch self {
        case .optIn: return .granted
        case .optOut: return .denied
        case .undecided: return .notRequested
        }
    }
}

private extension UserPermissionsService {
    
    // System privilege results - those set interacting with the push notifications system
    // prompt or main device settings
    
    func pushNotificationsPermissionStatus(_ resolve: @escaping (Permission.Status) -> Void) {
        let center = UNUserNotificationCenter.current()
        center.getNotificationSettings { settings in
            guaranteeMainThread {
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
    
    // settings not linked to device-app system prompts
    
    func userPushNotificationMarketingSelection(_ resolve: @escaping (Permission.Status) -> Void) {
        resolve(userPushNotificationMarketingSelection.map)
    }

}

// MARK: -

final class StubUserPermissionsService: UserPermissionsServiceProtocol {
    func resolveStatus(for permission: Permission, reconfirmIfKnown: Bool) {}
    func request(permission: Permission) {}
    var pushNotificationPreferencesRequired = false
    var userPushNotificationMarketingSelection: PushNotificationDeviceMarketingOptIn = .undecided
    var unsavedPushNotificationPreferences = false
    var userDoesNotWantPushNotifications = false
    func setUserDoesNotWantPushNotifications() {}
    func setSavedPushNotificationMarketingSelection() {}
    func setPushNotificationMarketingSelection(to: PushNotificationDeviceMarketingOptIn) {}
}
