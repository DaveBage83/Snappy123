//
//  PushNotificationsHandler.swift
//  SnappyV2
//
//  Created by Kevin Palser on 10/08/2022.
//

import UserNotifications
import UIKit

protocol PushNotificationsHandlerProtocol { }

class PushNotificationsHandler: NSObject, PushNotificationsHandlerProtocol {
    
    private let appState: Store<AppState>
    private let deepLinksHandler: DeepLinksHandler
    
    init(appState: Store<AppState>, deepLinksHandler: DeepLinksHandler) {
        self.appState = appState
        self.deepLinksHandler = deepLinksHandler
        super.init()
        UNUserNotificationCenter.current().delegate = self
    }
}

// MARK: - UNUserNotificationCenterDelegate

extension PushNotificationsHandler: UNUserNotificationCenterDelegate {
    
    // Generally used to decide what to do when user is already inside the app and a notification arrives.
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler:
        @escaping (UNNotificationPresentationOptions) -> Void)
    {
        handleNotification(
            userInfo: notification.request.content.userInfo,
            willPresentCompletionHandler: completionHandler,
            didReceiveCompletionHandler: nil
        )
    }
    
    // Generally used to redirect the user to a particular screen of the app after user taps on the notification.
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void)
    {
        handleNotification(
            userInfo: response.notification.request.content.userInfo,
            willPresentCompletionHandler: nil,
            didReceiveCompletionHandler: completionHandler
        )
    }
    
    func handleNotification(
        userInfo: [AnyHashable: Any],
        willPresentCompletionHandler: ((UNNotificationPresentationOptions) -> Void)?,
        didReceiveCompletionHandler: (() -> Void)?
    ) {
        
        if AppV2Constants.Business.checkNotificationSource && (userInfo["sendSource"] as? String)?.lowercased() != "main_server" {
            // Iterable intergration goes here
            willPresentCompletionHandler?([])
            didReceiveCompletionHandler?()
            
        } else {
            
            // the aps payload is at least a requirement
            guard let apsPayload = userInfo["aps"] as? NotificationPayload else {
                willPresentCompletionHandler?([])
                didReceiveCompletionHandler?()
                return
            }
            
            // there should always be
            let message: String
            if
                let alert = apsPayload["alert"] as? [String: AnyObject],
                let body = alert["body"] as? String
            {
                // new style
                message = body
            } else if let alert: String = apsPayload["alert"] as? String {
                // old server style
                message = alert
            } else {
                willPresentCompletionHandler?([])
                didReceiveCompletionHandler?()
                return
            }
            
            var displayGenericMessage = false

            let link: URL?
            if
                let linkString = userInfo["link"] as? String,
                let linkURL = URL(string: linkString)
            {
                link = linkURL
            } else {
                link = nil
            }
            let telephone = userInfo["telephone"] as? String
            
            if let deepLink = apsPayload["deepLink"] as? [String: Any] {
                // display a pop up which will consist of:
                // image (optional)
                // message body
                // view button (optional)
                // add button (optional)
                
//                self.processDeepLinkMessage(
//                    message: message,
//                    deepLinkPayload: deepLink,
//                    viewController: rootViewController
//                )
                
            } else if apsPayload["driverLocation"] as? Bool ?? false {
                // if user is not a driver and the map is not already showing then show the driver's location
                
//                if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
//                    appDelegate.driverLocationViewHelper.driverEnRouteNotificationReceived()
//                }
                
            } else if apsPayload["driverUpdate"] as? Bool ?? false {
                
                if appState.value.openViews.driverInterface {
                    // if the driver interface is showing then trigger a refresh but continue to display
                    // the message
                    appState.value.pushNotifications.driverNotification = userInfo
                    displayGenericMessage = true
                } else if appState.value.openViews.driverLocationMap {
                    // if the driver map is showing then force a refresh (no message shown)
                    
                }
                
                
                
            } else if apsPayload["storeReview"] as? Bool ?? false {
                // need to trigger displaying the customer store review interface
            } else if
                let orderId = apsPayload["orderIdUpdate"] as? Int,
                let orderToken = apsPayload["orderTokenUpdate"] as? String
            {
                // fetched the placed order and display the changes
            } else {
                displayGenericMessage = true
            }
            
            if displayGenericMessage {
                appState.value.pushNotifications.displayableNotification = DisplayablePushNotification(
                    message: message,
                    link: link,
                    telephone: telephone
                )
            }
            
            willPresentCompletionHandler?([])
            didReceiveCompletionHandler?()
        }
        
        

        // deepLinksHandler.open(deepLink: .showStore(id: Int))
    }
    
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        
        print("****** didRegisterForRemoteNotificationsWithDeviceToken")
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("****** didFailToRegisterForRemoteNotificationsWithError")
    }
}

