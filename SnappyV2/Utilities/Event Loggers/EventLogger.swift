//
//  EventLogger.swift
//  SnappyV2
//
//  Created by Kevin Palser on 13/04/2022.
//

import Foundation
import OSLog

// 3rd party libraries
import AppsFlyerLib

enum AppEvent: String {
    case firstOpened
    case sessionStarted
    case selectStore
    case addToBasket
    case purchase
    case firstPurchase
    case storeSearch
    case initiatedCheckout
    case completeRegistration
    case applyCoupon
    case search
    case futureContact
    case viewContentList
    case contentView
    case paymentFailure
	case login
	case couponReject
	case viewCart
	case removeFromCart
	case updateCart
    case viewScreen
    
    var toString: String {
        switch self {
        case .firstOpened:          return "first_open"
        case .sessionStarted:       return "session_start"
        case .selectStore:          return "select_store"
        case .addToBasket:          return AFEventAddToCart
        case .purchase:             return AFEventPurchase
        case .firstPurchase:        return "first_purchase"
        case .storeSearch:          return "store_search"
        case .initiatedCheckout:    return AFEventInitiatedCheckout
        case .completeRegistration: return AFEventCompleteRegistration
        case .applyCoupon:          return "apply_coupon"
        case .search:               return AFEventSearch
        case .futureContact:        return "future_contact"
        case .viewContentList:      return "view_content_list"
        case .contentView:          return AFEventContentView
        case .paymentFailure:       return "payment_failure"
        case .login:				return AFEventLogin
        case .couponReject:			return "coupon_reject"
        case .viewCart:				return "view_cart"
        case .removeFromCart:		return "remove_from_cart"
        case .updateCart:			return "update_cart"
        case .viewScreen:           return "view_screen"
        }
    }
}

enum EventLoggerType {
    case appsFlyer
    case firebaseAnalytics
}

protocol EventLoggerProtocol {
    static func initialiseAppsFlyer(delegate: AppsFlyerLibDelegate)
    func initialiseLoggers()
    func sendEvent(for event: AppEvent, with type: EventLoggerType, params: [String: Any])
}

class EventLogger: EventLoggerProtocol {
    
    let appState: Store<AppState>
    private var initialised: Bool = true
    private var launchCount: UInt = 1
    
    init(appState: Store<AppState>) {
        self.appState = appState
    }
    
    static func initialiseAppsFlyer(delegate: AppsFlyerLibDelegate) {
        if let key = AppV2Constants.EventsLogging.appsFlyerSettings.key {
            let appsFlyerLib = AppsFlyerLib.shared()
            appsFlyerLib.appsFlyerDevKey = key
            appsFlyerLib.appleAppID = AppV2Constants.Business.appleAppIdentifier
            
            #if DEBUG
            // To see AppsFlyer debug logs
            appsFlyerLib.isDebug = AppV2Constants.EventsLogging.appsFlyerSettings.debugLogs
            #endif
            
            // Must be called AFTER setting appsFlyerDevKey and appleAppID
            appsFlyerLib.delegate = delegate
            
            appsFlyerLib.waitForATTUserAuthorization(timeoutInterval: 60)
        }
    }
    
    func initialiseLoggers() {
        if initialised == false {
            
            // Persistently store the number of times the app is launched. This is done here
            // instead of the init because we do not want to record possiblities of app
            // services awaking the app for background services like location services
            // detecting significant movement.
            let userDefaults = UserDefaults.standard
            if userDefaults.object(forKey: "launchCount") as? Int == nil {
                // first time the app has been launched
                userDefaults.set(launchCount, forKey: "launchCount")
            } else {
                launchCount = UInt(userDefaults.integer(forKey: "launchCount"))
                launchCount = launchCount &+ 1
                userDefaults.set(launchCount, forKey: "launchCount")
            }

            // AppsFlyer
            if AppV2Constants.EventsLogging.appsFlyerSettings.key != nil {
                let appsFlyerLib = AppsFlyerLib.shared()
                if appsFlyerLib.isDebug {
                    appsFlyerLib.start(completionHandler: { [weak self] (dictionary, error) in
                        if let error = error {
                            Logger.eventLogger.error("Error when starting AppsFlyer: \(error.localizedDescription)")
                        } else {
                            if let dictionary = dictionary {
                                Logger.eventLogger.log("AppsFlyer started: \(dictionary)")
                            } else {
                                Logger.eventLogger.log("AppsFlyer started")
                            }
                            guard let self = self else { return }
        
                            // first AppsFlyer event
                            self.sendEvent(
                                for: self.launchCount == 1 ? .firstOpened : .sessionStarted,
                                with: .appsFlyer
                            )
                        }
                    })
                } else {
                    appsFlyerLib.start()
                }
            }
            initialised = true
        }
    }
    
    func sendEvent(for event: AppEvent, with type: EventLoggerType, params: [String: Any] = [:]) {
        
        let sendParams = addDefaultParameters(to: params)
        
        switch type {
        case .appsFlyer:
            if AppV2Constants.EventsLogging.appsFlyerSettings.key != nil {
                AppsFlyerLib.shared().logEvent(
                    name: event.toString,
                    values: sendParams,
                    completionHandler: { (response: [String : Any]?, error: Error?) in
                        if let error = error {
                            Logger.eventLogger.error("Error sending AppsFlyer event: \(event.rawValue) Error: \(error.localizedDescription)")
                        }
                    }
                )
            }
        case .firebaseAnalytics:
            break
        }
        
    }
    
    private func addDefaultParameters(to parameters: [String : Any]) -> [String : Any] {
        var sendParams = parameters
        
        // default values that are always sent
        sendParams["platform"] = AppV2Constants.Client.platform
        if let bundleNumber: Any = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") {
            sendParams["app_version"] = "\(bundleNumber)"
        }
        
        // Return zero if no store selected like Android
        if let selectedStore = appState.value.userData.selectedStore.value {
            sendParams["store_id"] = selectedStore.id
            sendParams["store_name"] = selectedStore.storeName
        } else {
            sendParams["store_id"] = 0
        }
        
        return sendParams
    }
    
}

struct StubEventLogger: EventLoggerProtocol {
    static func initialiseAppsFlyer(delegate: AppsFlyerLibDelegate) { }
    func initialiseLoggers() {}
    func sendEvent(for event: AppEvent, with type: EventLoggerType, params: [String : Any]) { }
}

#if DEBUG
// This hack is neccessary in order to expose 'addDefaultParameter'. These cannot easily be tested without.
extension EventLogger {
    func exposeAddDefaultParameters(to parameters: [String : Any]) -> [String : Any] {
        return self.addDefaultParameters(to: parameters)
    }
}
#endif
