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
    func handlePushRegistration(result: Result<Data, Error>)
    func appDidReceiveRemoteNotification(payload: NotificationPayload,
                                         fetchCompletion: @escaping FetchCompletion)
}

struct SystemEventsHandler: SystemEventsHandlerProtocol {
    
    let container: DIContainer
    let deepLinksHandler: DeepLinksHandlerProtocol
    let pushNotificationsHandler: PushNotificationsHandlerProtocol
    let pushNotificationsWebRepository: PushNotificationWebRepositoryProtocol
    
    // same keys used in v1 app
    let keyTokenRegistered = "notificationDeviceTokenRegistered"
    let keyToken = "notificationDeviceToken"
    let keyFcmToken = "fcmNotificationDeviceToken"
    
    // settings to allow notifications
    let keyNoPushNotifications = "no_notifications"
    // 0 = not decided, 1 = don't want, 2 = allow
    let keyMarketingNotificationSetting = "marketing_notification" // user's selection
    let keySavedMarketingNotificationSetting = "saved_marketing_notification" // confirmed saved selection
    
    init(container: DIContainer,
         deepLinksHandler: DeepLinksHandlerProtocol,
         pushNotificationsHandler: PushNotificationsHandlerProtocol,
         pushNotificationsWebRepository: PushNotificationWebRepositoryProtocol) {
        
        self.container = container
        self.deepLinksHandler = deepLinksHandler
        self.pushNotificationsHandler = pushNotificationsHandler
        self.pushNotificationsWebRepository = pushNotificationsWebRepository
    }
     
//    private func installPushNotificationsSubscriberOnLaunch() {
//        weak var permissions = container.services.userPermissionsService
//        container.appState
//            .updates(for: AppState.permissionKeyPath(for: .pushNotifications))
//            .first(where: { $0 != .unknown })
//            .sink { status in
//                if status == .granted {
//                    // If the permission was granted on previous launch
//                    // requesting the push token again:
//                    permissions?.request(permission: .pushNotifications)
//                }
//            }
//            .store(in: cancelBag)
//    }
    
    func sceneOpenURLContexts(_ urlContexts: Set<UIOpenURLContext>) {
        guard let url = urlContexts.first?.url else { return }
        handle(url: url)
    }
    
    private func handle(url: URL) {
        guard let deepLink = DeepLink(url: url) else { return }
        deepLinksHandler.open(deepLink: deepLink)
    }
    
    func handlePushRegistration(result: Result<Data, Error>) {
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
                return
            }
            
            Logger.pushNotification.info("Received push notification device token: \(deviceTokenString)")
            
            container.appState.value.system.notificationDeviceToken = deviceTokenString
            
            let userDefaults = UserDefaults.standard
            let oldDeviceToken = userDefaults.string(forKey: keyToken)
            let tokenRegistered = userDefaults.bool(forKey: keyTokenRegistered)
            let marketingNotifications = userDefaults.integer(forKey: keyMarketingNotificationSetting)
            let savedMarketingNotifications = userDefaults.integer(forKey: keySavedMarketingNotificationSetting)
            
            let oldToken = oldDeviceToken != nil && oldDeviceToken != deviceTokenString && tokenRegistered ? oldDeviceToken : nil
            
            guard tokenRegistered == false || deviceTokenString != oldToken || marketingNotifications != savedMarketingNotifications else {
                Logger.pushNotification.info("No changes to push notification device token")
                return
            }
            
            // build the request
            let request = NewPushNotificationDeviceRequest(
                deviceMessageToken: deviceTokenString,
                firebaseCloudMessageToken: nil,
                oldDeviceMessageToken: oldToken,
                optOut: PushNotificationDeviceMarketingOptIn(rawValue: marketingNotifications)
            )
    
            Task {
                do {
                    let result = try await self.pushNotificationsWebRepository.registerDevice(request: request)
                    if result.status {
                        // set the saved values that have been communicated to the server
                        userDefaults.setValue(deviceTokenString, forKey: keyToken)
                        userDefaults.setValue(true, forKey: keyTokenRegistered)
                        userDefaults.setValue(marketingNotifications, forKey: keySavedMarketingNotificationSetting)
                    }
                } catch {
                    Logger.pushNotification.error("Error when update push notification on server: \(error.localizedDescription)")
                }
            }

        } catch {
            Logger.pushNotification.error("Error when registering for push notifications: \(error.localizedDescription)")
        }
    }
    
    func appDidReceiveRemoteNotification(payload: NotificationPayload, fetchCompletion: @escaping FetchCompletion) {
//        container.services.countriesService
//            .refreshCountriesList()
//            .sinkToResult { result in
//                fetchCompletion(result.isSuccess ? .newData : .failed)
//            }
//            .store(in: cancelBag)
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
