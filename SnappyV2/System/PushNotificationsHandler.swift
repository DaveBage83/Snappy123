//
//  PushNotificationsHandler.swift
//  SnappyV2
//
//  Created by Kevin Palser on 10/08/2022.
//

import UserNotifications
import UIKit

protocol PushNotificationsHandlerProtocol { }

final class PushNotificationsHandler: NSObject, PushNotificationsHandlerProtocol {
    
    private let appState: Store<AppState>
    private let deepLinksHandler: DeepLinksHandlerProtocol
    
    init(appState: Store<AppState>, deepLinksHandler: DeepLinksHandlerProtocol) {
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
        
        if AppV2PushNotificationConstants.checkNotificationSource && (userInfo["sendSource"] as? String)?.lowercased() != "main_server" {
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

            let imageURL: URL?
            if
                let imageURLString = userInfo["imageURL"] as? String,
                let url = URL(string: imageURLString)
            {
                imageURL = url
            } else {
                imageURL = nil
            }
            
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
            
            if let deepLink = userInfo["deepLink"] as? [String: Any] {
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
                
            } else if userInfo["driverLocation"] as? Bool ?? false {
                // if user is not a driver and the map is not already showing then
                // trigger a check with the server that will result in the map view
                // being opened
                if appState.value.userData.memberProfile?.type != .driver && appState.value.openViews.driverLocationMap == false {
                    appState.value.pushNotifications.driverMapOpenNotification = userInfo
                }
                
            } else if userInfo["driverUpdate"] as? Bool ?? false {
                
                if appState.value.openViews.driverInterface {
                    // if the driver interface is showing then trigger a refresh but continue
                    // to display the message
                    appState.value.pushNotifications.driverNotification = userInfo
                    displayGenericMessage = true
                    
                } else if appState.value.openViews.driverLocationMap {
                    // if the driver map is showing then force a refresh (no message shown)
                    appState.value.pushNotifications.driverMapNotification = userInfo
                }
                
            } else if userInfo["storeReview"] as? Bool ?? false {
                // trigger displaying the customer store review interface
                if
                    let orderId = userInfo["orderId"] as? Int,
                    let hash = userInfo["hash"] as? String,
                    let name = userInfo["storeName"] as? String,
                    let address = userInfo["storeAddress"] as? String
                {
                    var logo: URL?
                    if let imageURL = userInfo["storeImage"] as? String {
                        logo = URL(string: imageURL)
                    }
                    appState.value.retailStoreReview = RetailStoreReview(
                        orderId: orderId,
                        hash: hash,
                        logo: logo,
                        name: name,
                        address: address
                    )
                }
            } else if
                let orderId = userInfo["orderIdUpdate"] as? Int,
                let orderToken = userInfo["orderTokenUpdate"] as? String
            {
                // fetched the placed order and display the changes
            } else {
                displayGenericMessage = true
            }
            
            if displayGenericMessage {
                appState.value.pushNotifications.displayableNotification = DisplayablePushNotification(
                    image: imageURL,
                    message: message,
                    link: link,
                    telephone: telephone
                )
            }
            
            willPresentCompletionHandler?([])
            didReceiveCompletionHandler?()
        }

    }
}

