//
//  EventLogger.swift
//  SnappyV2
//
//  Created by Kevin Palser on 13/04/2022.
//

import Foundation
import Combine
import OSLog

// 3rd party libraries
import AppsFlyerLib
import FBSDKCoreKit
import IterableSDK
import Sentry
import Firebase

enum EventLoggerError: Swift.Error {
    case invalidParameters([String])
}

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
	case addBillingInfo
    case viewScreen
    case mentionMeError
    case mentionMeOfferView
    case mentionMeRefereeView
    case mentionMeDashboardView
    case apiError
    case otpPresented
    case otpEmail
    case otpSms
    case otpLogin
    case otpWrong
    
    var toAppsFlyerString: String? {
        switch self {
        case .firstOpened:              return "first_open"
        case .sessionStarted:           return "session_start"
        case .selectStore:              return "select_store"
        case .addToBasket:              return AFEventAddToCart
        case .purchase:                 return AFEventPurchase
        case .firstPurchase:            return "first_purchase"
        case .storeSearch:              return "store_search"
        case .initiatedCheckout:        return AFEventInitiatedCheckout
        case .completeRegistration:     return AFEventCompleteRegistration
        case .applyCoupon:              return "apply_coupon"
        case .search:                   return AFEventSearch
        case .futureContact:            return "future_contact"
        case .viewContentList:          return "view_content_list"
        case .contentView:              return AFEventContentView
        case .paymentFailure:           return "payment_failure"
        case .login:				    return AFEventLogin
        case .couponReject:			    return "coupon_reject"
        case .viewCart:				    return "view_cart"
        case .removeFromCart:		    return "remove_from_cart"
        case .updateCart:			    return "update_cart"
		case .addBillingInfo:		    return "add_billing_info"
        case .viewScreen:               return "view_screen"
        case .mentionMeError:           return "mentionme_error"
        case .mentionMeOfferView:       return "mentionme_offer_view"
        case .mentionMeRefereeView:     return "mentionme_referee_view"
        case .mentionMeDashboardView:   return "mentionme_dashboard_view"
        case .apiError:                 return "api_error"
        case .otpPresented:             return "otc_presented"
        case .otpEmail:                 return "otc_email"
        case .otpSms:                   return "otc_sms"
        case .otpLogin:                 return "otc_login"
        case .otpWrong:                 return "otc_wrong"
        }
    }
    
    var toIterableString: String? {
        switch self {
        case .viewCart:                 return "viewBasket"
        case .viewContentList:          return "viewMenuCategory"
        case .contentView:              return "viewMenuItemDetail"
        case .storeSearch:              return "searchStores"
        default:                        return nil
        }
    }
    
    var toFirebaseString: String? {
        switch self {
        case .purchase:                 return "viewBasket"
        default:                        return nil
        }
    }
}

enum EventLoggerType {
    case appsFlyer
    case firebaseAnalytics
    case facebook
    case iterable
}

protocol EventLoggerProtocol {
    // Separate from initialiseLoggers(container: DIContainer) method because Sentry
    // will be intended for monitoring even the initial network calls
    func initialiseSentry()
    static func initialiseAppsFlyer(delegate: AppsFlyerLibDelegate)
    func initialiseLoggers(container: DIContainer)
    func sendEvent(for event: AppEvent, with type: EventLoggerType, params: [String: Any])
    func sendMentionMeConsumerOrderEvent(businessOrderId: Int) async
    func setCustomerID(profileUUID: String)
    func clearCustomerID()
    func pushNotificationDeviceRegistered(deviceToken: Data)
}

class EventLogger: EventLoggerProtocol {

    let webRepository: EventLoggerWebRepositoryProtocol
    let appState: Store<AppState>
    private var cancellables = Set<AnyCancellable>()
    private var iterableInitialised: Bool = false
    private var initialised: Bool = false
    private var launchCount: UInt = 1
    private var mentionMeHandler: MentionMeHandler?
    
    // Static so that the AppDelegate can set ready for when Iterable can be initialised
    // after its API key is established
    static var launchOptions: [UIApplication.LaunchOptionsKey : Any]?
    
    // cached value until Iterable is initialised
    private var deviceToken: Data?
    
    private let facebookDecimalBehavior = NSDecimalNumberHandler(
        roundingMode: .plain,
        scale: 2,
        raiseOnExactness: false,
        raiseOnOverflow: false,
        raiseOnUnderflow: false,
        raiseOnDivideByZero: true
    )
    
    init(webRepository: EventLoggerWebRepositoryProtocol, appState: Store<AppState>) {
        self.webRepository = webRepository
        self.appState = appState
    }
    
    func initialiseSentry() {
        if let dsn = AppV2Constants.EventsLogging.sentrySettings.dsn {
            SentrySDK.start { options in
                options.dsn = dsn
                options.debug = AppV2Constants.EventsLogging.sentrySettings.debugLogs
                options.tracesSampleRate = AppV2Constants.EventsLogging.sentrySettings.tracesSampleRate
            }
        }
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
    
    func initialiseLoggers(container: DIContainer) {
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
            
            // Mention Me
            mentionMeHandler = MentionMeHandler(container: container)
            
            // Iterable
            setupMemberBinding()
            
            initialised = true
        }
    }
    
    private func setupMemberBinding() {
        appState
            .map(\.userData.memberProfile)
            .removeDuplicates()
            .sink { [weak self] memberProfile in
                guard
                    let self = self,
                    let iterableMobileApiKey = self.appState.value.businessData.businessProfile?.iterableMobileApiKey
                else { return }
                if let memberProfile = memberProfile {
                    if self.iterableInitialised == false {
                        self.initialiseIterable(apiKey: iterableMobileApiKey)
                        IterableAPI.email = memberProfile.emailAddress
                    }
                } else {
                    if self.iterableInitialised {
                        IterableAPI.logoutUser()
                    }
                }
            }.store(in: &cancellables)
    }
    
    private func initialiseIterable(apiKey: String) {
        let config = IterableConfig()
        config.authDelegate = self
        config.allowedProtocols = ["http", "tel", "custom"]
        IterableAPI.initialize(
            apiKey: apiKey,
            launchOptions: EventLogger.launchOptions,
            config: config
        )
        EventLogger.launchOptions = nil
        iterableInitialised = true
        // complete the registration of the device
        if let deviceToken = deviceToken {
            IterableAPI.register(token: deviceToken)
            self.deviceToken = nil
        }
    }
    
    private func mergeWhitelLableFields(rawDataFields: [String: Any]) -> [String: Any] {
        if let appWhiteLabelProfileId = AppV2Constants.Business.appWhiteLabelProfileId {
            var newDataFields = rawDataFields
            newDataFields["white_label_id"] = appWhiteLabelProfileId
            // in the future we could add white_label_name if it comes back in the
            // business profile
            return newDataFields
        }
        return rawDataFields
    }
    
    func sendEvent(for event: AppEvent, with type: EventLoggerType, params: [String: Any] = [:]) {
        
        let sendParams = type != .iterable ? addDefaultParameters(to: params) : params
        
        switch type {
        case .appsFlyer:
            guard
                let name = event.toAppsFlyerString,
                AppV2Constants.EventsLogging.appsFlyerSettings.key != nil
            else { return }
            AppsFlyerLib.shared().logEvent(
                name: name,
                values: sendParams,
                completionHandler: { (response: [String : Any]?, error: Error?) in
                    if let error = error {
                        Logger.eventLogger.error("Error sending AppsFlyer event: \(event.rawValue) Error: \(error.localizedDescription)")
                    }
                }
            )
            
        case .firebaseAnalytics:
            guard
                let name = event.toFirebaseString,
                AppV2Constants.EventsLogging.firebaseAnalyticsSettings.enabled
            else { return }
            Analytics.logEvent(name, parameters: params)
        
        case .facebook:
            // Facebook has its own mapping / specific methods for the purchase event
            switch event {
            case .purchase, .firstPurchase:
                AppEvents.shared.logPurchase(
                    amount: params["checkedOutTotalCost"] as? Double ?? 0,
                    currency: params["currency"] as? String ?? "GBP",
                    parameters: params["facebookParams"] as? [AppEvents.ParameterName : Any]
                )
                
            case .addToBasket, .removeFromCart, .updateCart:
                AppEvents.shared.logEvent(
                    .addedToCart,
                    valueToSum: NSDecimalNumber(
                        value: params["valueToSum"] as? Double ?? 0.0
                    ).rounding(accordingToBehavior: facebookDecimalBehavior).doubleValue,
                    parameters: params["facebookParams"] as? [AppEvents.ParameterName : Any]
                )
            
            // Note: in v1 we had ".searched" for Facebook when a search result was tapped
            // to take the user to menu view. In v2 there is no concept of a search result
            // being followed as entries are presented immediately in a view that can be used
            // to add items to the basket directly.
            default:
                break
            }
            
        case .iterable:
            guard
                let name = event.toIterableString,
                iterableInitialised,
                // do not send events when the user is signed out
                appState.value.userData.memberProfile != nil
            else { return }
            IterableAPI.track(
                event: name,
                dataFields: mergeWhitelLableFields(rawDataFields: params)
            )
        }
    }
    
    func sendMentionMeConsumerOrderEvent(businessOrderId: Int) async {
        _ = try? await mentionMeHandler?.perform(request: .consumerOrder, businessOrderId: businessOrderId)
    }
    
    private func addDefaultParameters(to parameters: [String : Any]) -> [String : Any] {
        var sendParams = mergeWhitelLableFields(rawDataFields: parameters)
        
        // default values that are always sent
        sendParams["platform"] = AppV2Constants.Client.platform
        if let appVersion = AppV2Constants.Client.appVersion {
            sendParams["app_version"] = appVersion
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
    
    func setCustomerID(profileUUID: String) {
        AppsFlyerLib.shared().customerUserID = profileUUID
    }
    
    func clearCustomerID() {
        AppsFlyerLib.shared().customerUserID = nil
    }
    
    func pushNotificationDeviceRegistered(deviceToken: Data) {
        if iterableInitialised {
            IterableAPI.register(token: deviceToken)
        } else {
            // store the token data to use when/if Iterable is initialised
            self.deviceToken = deviceToken
        }
    }
}

extension EventLogger: IterableAuthDelegate {
    func onAuthTokenRequested(completion: @escaping AuthTokenRetrievalHandler) {
        // At the time of coding the decision is to only ever activate Iterable while a member is
        // signed in. This is to avoid the charge for anonymous placeholder userIds on the
        // Iterable server.
        guard let email = appState.value.userData.memberProfile?.emailAddress else {
            completion(nil)
            return
        }
        Task {
            do {
                let result = try await webRepository.getIterableJWT(email: email, userId: nil)
                completion(result.jwt)
            } catch {
                Logger.eventLogger.error("Error getting JWT for Iterable: \(error.localizedDescription)")
                completion(nil)
            }
        }
    }
}

struct StubEventLogger: EventLoggerProtocol {
    func initialiseSentry() {}
    func initialiseIterable(apiKey: String) {}
    static func initialiseAppsFlyer(delegate: AppsFlyerLibDelegate) { }
    func initialiseLoggers(container: DIContainer) {}
    func sendEvent(for event: AppEvent, with type: EventLoggerType, params: [String : Any]) { }
    func sendMentionMeConsumerOrderEvent(businessOrderId: Int) async { }
    func setCustomerID(profileUUID: String) {}
    func clearCustomerID() {}
    func pushNotificationDeviceRegistered(deviceToken: Data) {}
}

#if DEBUG
// This hack is neccessary in order to expose 'addDefaultParameter'. These cannot easily be tested without.
extension EventLogger {
    func exposeAddDefaultParameters(to parameters: [String : Any]) -> [String : Any] {
        return self.addDefaultParameters(to: parameters)
    }
}
#endif
