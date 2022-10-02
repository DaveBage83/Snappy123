//
//  PushNotificationsHandler.swift
//  SnappyV2
//
//  Created by Kevin Palser on 10/08/2022.
//

import UserNotifications
import Combine
import IterableSDK
import UIKit

protocol PushNotificationsHandlerProtocol { }

final class PushNotificationsHandler: NSObject, PushNotificationsHandlerProtocol {
    
    private let appState: Store<AppState>
    private let deepLinksHandler: DeepLinksHandlerProtocol
    private var cancellables = Set<AnyCancellable>()
    
    private(set) var lastResponsePassedToIterable: UNNotificationResponse?
    
    init(appState: Store<AppState>, deepLinksHandler: DeepLinksHandlerProtocol) {
        self.appState = appState
        self.deepLinksHandler = deepLinksHandler
        super.init()
        UNUserNotificationCenter.current().delegate = self
        self.setupRestoreFinishedBinding(with: appState)
    }
    
    private func setupRestoreFinishedBinding(with appState: Store<AppState>) {
        appState
            .map(\.postponedActions.restoreFinished)
            .first { $0 }
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                guard let self = self else { return }
                for pushNotification in self.appState.value.postponedActions.pushNotifications {
                    self.handleNotification(
                        notification: pushNotification.notification,
                        willPresentCompletionHandler: pushNotification.willPresentCompletionHandler,
                        response: pushNotification.response,
                        didReceiveCompletionHandler: pushNotification.didReceiveCompletionHandler
                    )
                }
                self.appState.value.postponedActions.pushNotifications.removeAll()
            }
            .store(in: &cancellables)
    }
    
    private func handleNotification(
        // testUserInfo: was to simplify testing because of private Apple API for initialising
        // UNNotification & UNNotificationPresentationOptions. The current approach in
        // PushNotificationsHandlerTests.swift of using private methods to create test objects
        // might need to revert to the testUserInfo if Apple makes changes.
        // testUserInfo: [AnyHashable: Any] = [:],
        notification: UNNotification? = nil,
        willPresentCompletionHandler: ((UNNotificationPresentationOptions) -> Void)? = nil,
        response: UNNotificationResponse? = nil,
        didReceiveCompletionHandler: (() -> Void)? = nil
    ) {

        // postpone processing the notification if the app is still restoring
        guard appState.value.postponedActions.restoreFinished else {
            appState.value.postponedActions.pushNotifications.append(
                PushNotification(
                    notification: notification,
                    willPresentCompletionHandler: willPresentCompletionHandler,
                    response: response,
                    didReceiveCompletionHandler: didReceiveCompletionHandler
                )
            )
            return
        }
        
        // The userInfo is extracted here rather than in the calling functions because the original
        // UNNotification or UNNotificationResponse may be need for Iterable
        var userInfo: [AnyHashable: Any] = [:] // testUserInfo if testing approach is reverted
        if let notification = notification {
            userInfo = notification.request.content.userInfo
        } else if let response = response {
            userInfo = response.notification.request.content.userInfo
        }
        
        if AppV2PushNotificationConstants.checkNotificationSource && (userInfo["sendSource"] as? String)?.lowercased() != "main_server" {
            
            if
                let response = response,
                let didReceiveCompletionHandler = didReceiveCompletionHandler
            {
                // No need to check if the Iterable SDK has been initialised because it has its
                // own postponed handling logic
                lastResponsePassedToIterable = response
                IterableAppIntegration.userNotificationCenter(
                    UNUserNotificationCenter.current(),
                    didReceive: response,
                    withCompletionHandler: didReceiveCompletionHandler
                )
            } else {
                // TODO: Waiting on designs decisions for pop-up body
                willPresentCompletionHandler?([])
            }
            return
            
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

// MARK: - UNUserNotificationCenterDelegate

extension PushNotificationsHandler: UNUserNotificationCenterDelegate {
    
    // Generally used to decide what to do when user is already inside the app and a notification arrives.
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler:
        @escaping (UNNotificationPresentationOptions) -> Void)
    {
        handleNotification(
            notification: notification,
            willPresentCompletionHandler: completionHandler
        )
    }
    
    // Generally used to redirect the user to a particular screen of the app after user taps on the notification.
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void)
    {
        handleNotification(
            response: response,
            didReceiveCompletionHandler: completionHandler
        )
    }
}

