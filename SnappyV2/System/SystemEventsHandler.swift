//
//  SystemEventsHandler.swift
//  SnappyV2
//
//  Created by Kevin Palser on 11/08/2022.
//

import UIKit
import Combine
import OSLog

// 3rd party
import KeychainAccess

protocol SystemEventsHandlerProtocol {
    func sceneOpenURLContexts(_ urlContexts: Set<UIOpenURLContext>)
    /// The completed: is just for test purposes because of complications with the Task block
    func handlePushRegistration(result: Result<Data, Error>, completed: (()->Void)?)
}

struct SystemEventsHandler: SystemEventsHandlerProtocol {
    
    let container: DIContainer
    private let deepLinksHandler: DeepLinksHandlerProtocol
    private let pushNotificationsHandler: PushNotificationsHandlerProtocol
    private let pushNotificationsWebRepository: PushNotificationWebRepositoryProtocol
    
    // same keys used in v1 app
    static let keyTokenRegistered = "notificationDeviceTokenRegistered"
    static let keyToken = "notificationDeviceToken"
    static let keyFcmToken = "fcmNotificationDeviceToken"
    
    private var cancelBag = CancelBag()
    
    init(container: DIContainer,
         deepLinksHandler: DeepLinksHandlerProtocol,
         pushNotificationsHandler: PushNotificationsHandlerProtocol,
         pushNotificationsWebRepository: PushNotificationWebRepositoryProtocol) {
        
        self.container = container
        self.deepLinksHandler = deepLinksHandler
        self.pushNotificationsHandler = pushNotificationsHandler
        self.pushNotificationsWebRepository = pushNotificationsWebRepository
        
        #if TEST
        // we want the installPushNotificationsSubscriberOnLaunch setup but we do not
        // want its binding triggered by previous states with a local simulator testing
        container.appState.value.permissions.push = .unknown
        #else
        refreshNotificationSubscriberOnAppForeground()
        #endif
        
        // needs to be included in test mode so that test_subscribesOnPushIfGranted
        // can check its binding logic
        installPushNotificationsSubscriberOnLaunch()
        
        // set the last registered token
        container.appState.value.system.notificationDeviceToken = UserDefaults.standard.string(forKey: SystemEventsHandler.keyToken)
    }
     
    private func installPushNotificationsSubscriberOnLaunch() {
        weak var permissions = container.services.userPermissionsService
        container.appState
            .updates(for: AppState.permissionKeyPath(for: .pushNotifications))
            .first(where: { $0 != .unknown })
            .sink { status in
                if status == .granted {
                    // If the permission was granted on previous launch
                    // requesting the push token again. The token can
                    // change typically after app or significant OS updates.
                    permissions?.request(permission: .pushNotifications)
                }
            }
            .store(in: cancelBag)
    }
    
    private func refreshNotificationSubscriberOnAppForeground() {
        container.appState
            .updates(for: \AppState.system.isInForeground)
            .sink { isInForeground in
                if isInForeground {
                    container.services.userPermissionsService.resolveStatus(
                        for: .pushNotifications,
                        // in case it changes via device settings whilst the app
                        // is sent to the background
                        reconfirmIfKnown: true
                    )
                }
            }
            .store(in: cancelBag)
    }
    
    func sceneOpenURLContexts(_ urlContexts: Set<UIOpenURLContext>) {
        guard let url = urlContexts.first?.url else { return }
        handle(url: url)
    }
    
    private func handle(url: URL) {
        guard let deepLink = DeepLink(url: url) else { return }
        deepLinksHandler.open(deepLink: deepLink)
    }
    
    func handlePushRegistration(result: Result<Data, Error>, completed: (()->Void)?) {
        do {
            let pushNotificationToken = try result.get()
            // process the Data to return the hexidecimal string version
            let deviceTokenString = pushNotificationToken.reduce("", { (resultString, byte) -> String in
                var deviceTokenString = resultString
                if byte < 16 {
                    deviceTokenString += "0"
                }
                deviceTokenString += "\(String(byte, radix: 16, uppercase: false))"
                return deviceTokenString
            })
            
            guard deviceTokenString.isEmpty == false else {
                completed?()
                return
            }
            
            Logger.pushNotification.info("Received push notification device token: \(deviceTokenString)")
            
            container.appState.value.system.notificationDeviceToken = deviceTokenString
            
            let userDefaults = UserDefaults.standard
            let oldDeviceToken = userDefaults.string(forKey: SystemEventsHandler.keyToken)
            let tokenRegistered = userDefaults.bool(forKey: SystemEventsHandler.keyTokenRegistered)
            
            let oldToken = oldDeviceToken != nil && oldDeviceToken != deviceTokenString && tokenRegistered ? oldDeviceToken : nil
            
            guard tokenRegistered == false || oldToken != nil || container.services.userPermissionsService.unsavedPushNotificationPreferences else {
                Logger.pushNotification.info("No changes to push notification device token")
                completed?()
                return
            }
            
            // set the token as not registered if it has changed
            if oldDeviceToken != deviceTokenString {
                userDefaults.setValue(false, forKey: SystemEventsHandler.keyTokenRegistered)
            }
            
            // build the request
            let request = PushNotificationDeviceRequest(
                deviceMessageToken: deviceTokenString,
                firebaseCloudMessageToken: nil,
                oldDeviceMessageToken: oldToken,
                optOut: container.services.userPermissionsService.userPushNotificationMarketingSelection
            )
    
            Task {
                do {
                    let result = try await self.pushNotificationsWebRepository.registerDevice(request: request)
                    if result.status {
                        // set the saved values that have been communicated to the server
                        userDefaults.setValue(deviceTokenString, forKey: SystemEventsHandler.keyToken)
                        userDefaults.setValue(true, forKey: SystemEventsHandler.keyTokenRegistered)
                        container.services.userPermissionsService.setSavedPushNotificationMarketingSelection()
                    }
                    
                } catch {
                    Logger.pushNotification.error("Error when update push notification on server: \(error.localizedDescription)")
                }
                completed?()
            }

        } catch {
            Logger.pushNotification.error("Error when registering for push notifications: \(error.localizedDescription)")
            completed?()
        }
    }
    
}

// MARK: - Notifications

private extension NotificationCenter {
    var keyboardHeightPublisher: AnyPublisher<CGFloat, Never> {
        let willShow = publisher(for: UIApplication.keyboardWillShowNotification)
            .map { $0.keyboardHeight }
        let willHide = publisher(for: UIApplication.keyboardWillHideNotification)
            .map { _ in CGFloat(0) }
        return Publishers.Merge(willShow, willHide)
            .eraseToAnyPublisher()
    }
}

private extension Notification {
    var keyboardHeight: CGFloat {
        return (userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?
            .cgRectValue.height ?? 0
    }
}
