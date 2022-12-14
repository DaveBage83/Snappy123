//
//  AppDelegate.swift
//  SnappyV2
//
//  Created by Henrik Gustavii on 15/09/2021.
//

import SwiftUI

// 3rd party
import FacebookCore
import AppsFlyerLib
import Firebase

typealias NotificationPayload = [AnyHashable: Any]
typealias FetchCompletion = (UIBackgroundFetchResult) -> Void

class AppDelegate: NSObject, UIApplicationDelegate, ObservableObject {
    static var orientationLock = UIInterfaceOrientationMask.all
    
    var systemEventsHandler: SystemEventsHandlerProtocol?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        
        #if TEST
        #else
        // Firebase
        if AppV2Constants.EventsLogging.firebaseAnalyticsSettings.enabled {
            FirebaseApp.configure()
        }
        
        // Facebook
        ApplicationDelegate.shared.application(
            application,
            didFinishLaunchingWithOptions: launchOptions
        )

        // AppsFlyer
        EventLogger.initialiseAppsFlyer(delegate: self)
        
        // For Iterable
        EventLogger.launchOptions = launchOptions
        #endif
        
        return true
    }
    
    // For reference - not performed here see SnappyV2App and https://developer.apple.com/forums/thread/657601 :
    // func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {}
    
    // MARK: - Push Notifications Methods
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        systemEventsHandler?.handlePushRegistration(result: .success(deviceToken), completed: nil)
    }

    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        systemEventsHandler?.handlePushRegistration(result: .failure(error), completed: nil)
    }
    
    // For reference - deprecated method that is not called when didReceive method (PushNotificationHandler)
    // is implemented. Probably a mistake that it was included in the clean architecture SWIFTUI example
    // project, which is not backwards compatible to iOS 10 :
    // func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: NotificationPayload, fetchCompletionHandler completionHandler: @escaping FetchCompletion)
    
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return AppDelegate.orientationLock
    }
}

// MARK: - AppsFlyerLibDelegate
extension AppDelegate: AppsFlyerLibDelegate {
    
    func onConversionDataSuccess(_ conversionInfo: [AnyHashable : Any]) {
        
    }
    
    func onConversionDataFail(_ error: Error) {
        
    }
    
}
