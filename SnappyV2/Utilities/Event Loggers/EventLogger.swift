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

enum AppEventInCheckout: Equatable {
    case `in`
    case outside
}

enum AppEventScreen: Equatable {
    case pastOrderDetail
    case rootAccount
    case deliveryAddressList
    case pastOrdersList
    case editMemberProfile
    case initialStoreSearch
    case driverLocationMap
    case storeListSelection
    case accountSignIn
    case registerFromAccountSignIn
    case resetPassword
    case customerDetails // currently only at checkout
    
    var toAppsFlyerScreenReference: String? {
        switch self {
        case .pastOrderDetail:              return "past_order_detail"
        case .rootAccount:                  return "root_account"
        case .deliveryAddressList:          return "delivery_address_list"
        case .pastOrdersList:               return "past_orders_list"
        case .editMemberProfile:            return "edit_member_profile"
        case .initialStoreSearch:           return "initial_store_search"
        case .driverLocationMap:            return "driver_location_map"
        case .storeListSelection:           return "store_list_selection"
        case .accountSignIn:                return "account_sign_in"
        case .registerFromAccountSignIn:    return "register_from_account_sign_in"
        case .resetPassword:                return "reset_password"
        default:                            return nil
        }
    }
    
    func toFirebaseEventName(when: AppEventInCheckout) -> String? {
        if when == .outside {
            switch self {
            case .resetPassword:                return "view_password_reset"
            default:                            return nil
            }
        } else {
            switch self {
            case .resetPassword:                return "view_password_reset_at_checkout"
            case .customerDetails:              return "view_customer_details"
            default:                            return nil
            }
        }
    }
}

enum AppEvent: Equatable {
    case firstOpened
    case sessionStarted
    case selectStore
    case addToBasket
    case purchase
    case firstPurchase
    case storeSearch
    case storeSearchFromStartView
    case initiatedCheckout
    case completeRegistration
    case applyCoupon
    case applyCouponPressed
    case search
    case searchResultSelection
    case futureContact
    
    // For AppsFlyer: parameter "category_type": "child" or "items"
    case viewCategoryList
    
    // For Firebase: instead of parameter "category_type": "items"
    case viewProductList
    
    case viewItemDetail
    case paymentFailure
	case login(AppEventInCheckout)
	case couponReject
	case viewCart
	case removeFromBasket
	case updateCart
	case addBillingInfo
    case viewScreen(AppEventInCheckout?, AppEventScreen)
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
    case checkoutBlockedByMinimumSpend
    case couponAppliedAtBaskedView
    case couponRejectedAtBasketView
    case checkoutAsGuestChosen
    case checkoutAsNewMemberChosen
    case passwordResetPresented
    case cannotDeliverToAddress
    
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
        case .viewCategoryList:         return "view_content_list"
        case .viewItemDetail:           return AFEventContentView
        case .paymentFailure:           return "payment_failure"
        case .login:				    return AFEventLogin
        case .couponReject:			    return "coupon_reject"
        case .viewCart:				    return "view_cart"
        case .removeFromBasket:		    return "remove_from_cart"
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
        default:                        return nil
        }
    }
    
    var toIterableString: String? {
        switch self {
        case .viewCart:                 return "viewBasket"
        case .viewCategoryList:         return "viewMenuCategory"
        case .viewItemDetail:           return "viewMenuItemDetail"
        case .storeSearch:              return "searchStores"
        default:                        return nil
        }
    }
    
    var toFirebaseString: String? {
        switch self {
        case .addToBasket:                      return AnalyticsEventAddToCart
        case .removeFromBasket:                 return AnalyticsEventRemoveFromCart
        case .purchase:                         return AnalyticsEventPurchase
        case .storeSearchFromStartView:         return "store_search_requested_at_start_view"
        case .storeSearch:                      return "store_search"
        case .futureContact:                    return "no_stores_found_interest_form_submitted"
        case .viewCategoryList:                 return "view_category_list"
        case .viewProductList:                  return "view_product_list"
        case .viewItemDetail:                   return AnalyticsEventViewItem
        case .search:                           return AnalyticsEventSearch
        case .searchResultSelection:            return "menu_search_result_pressed"
        case .viewCart:                         return AnalyticsEventViewCart
        case .checkoutBlockedByMinimumSpend:    return "minimum_delivery_spend_warning"
        case .applyCouponPressed:               return "apply_coupon_pressed"
        case .couponAppliedAtBaskedView:        return "coupon_applied_at_basket"
        case .couponRejectedAtBasketView:       return "coupon_rejected_at_basket"
        case .initiatedCheckout:                return AnalyticsEventBeginCheckout
        case .checkoutAsGuestChosen:            return "continue_as_guest_pressed"
        case .checkoutAsNewMemberChosen:        return "continue_as_new_member_pressed"
        case let .login(checkout):              return checkout == .in ? "login_during_checkout" : AnalyticsEventLogin
        case let .viewScreen(checkout, screen): return screen.toFirebaseEventName(when: checkout ?? .outside)
        case .cannotDeliverToAddress:           return "cannot_deliver_to_location_warning"
        default:                                return nil
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
    static func getFirebaseItemsArray(from: [BasketItem]) -> [[String: Any]]
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
    
    static let decimalBehavior = NSDecimalNumberHandler(
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
        
        var sendParams = type != .iterable ? addDefaultParameters(to: params) : params
        
        switch type {
        case .appsFlyer:
            guard
                let name = event.toAppsFlyerString,
                AppV2Constants.EventsLogging.appsFlyerSettings.key != nil
            else { return }
            switch event {
            case let .viewScreen(_, screen):
                if let screenReference = screen.toAppsFlyerScreenReference {
                    sendParams["screen_reference"] = screenReference
                }
            default: break
            }
            AppsFlyerLib.shared().logEvent(
                name: name,
                values: sendParams,
                completionHandler: { (response: [String : Any]?, error: Error?) in
                    if let error = error {
                        Logger.eventLogger.error("Error sending AppsFlyer event: \(name) Error: \(error.localizedDescription)")
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
                
            case .addToBasket, .removeFromBasket, .updateCart:
                AppEvents.shared.logEvent(
                    .addedToCart,
                    valueToSum: NSDecimalNumber(
                        value: params["valueToSum"] as? Double ?? 0.0
                    ).rounding(accordingToBehavior: EventLogger.decimalBehavior).doubleValue,
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
    
    static func getFirebaseItemsArray(from lines: [BasketItem]) -> [[String: Any]] {
        var items: [[String: Any]] = []
        for line in lines {
            var item: [String: Any] = [
                AnalyticsParameterItemID: AppV2Constants.EventsLogging.analyticsItemIdPrefix + "\(line.menuItem.id)",
                AnalyticsParameterItemName: line.menuItem.name,
                // future reference:
                // AnalyticsParameterItemCategory: "pants",
                // AnalyticsParameterItemBrand: "Google",
                AnalyticsParameterPrice: NSDecimalNumber(value: line.price).rounding(accordingToBehavior: EventLogger.decimalBehavior).doubleValue,
                AnalyticsParameterQuantity: line.quantity
            ]
            if let size = line.size {
                item[AnalyticsParameterItemVariant] = AppV2Constants.EventsLogging.analticsSizeIdPrefix + "\(size.id)"
            }
            items.append(item)
        }
        return items
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
    static func getFirebaseItemsArray(from: [BasketItem]) -> [[String: Any]] { return [] }
}

#if DEBUG
// This hack is neccessary in order to expose 'addDefaultParameter'. These cannot easily be tested without.
extension EventLogger {
    func exposeAddDefaultParameters(to parameters: [String : Any]) -> [String : Any] {
        return self.addDefaultParameters(to: parameters)
    }
}
#endif
