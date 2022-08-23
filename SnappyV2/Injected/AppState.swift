//
//  AppState.swift
//  SnappyV2
//
//  Created by Henrik Gustavii on 15/09/2021.
//

import Foundation
import SwiftUI

struct AppState: Equatable {
    var system = System()
    var routing = ViewRouting()
    var openViews = OpenViews()
    var businessData = BusinessData()
    var userData = UserData()
    var staticCacheData = StaticCacheData()
    var notifications = Notifications()
    var permissions = Permissions()
    var pushNotifications = PushNotifications()
}

extension AppState {
    struct ViewRouting: Equatable {
        var showInitialView = true
        var selectedTab: Tab = .stores
    }
}

extension AppState {
    struct OpenViews: Equatable {
        var driverInterface = false
        var driverLocationMap = false
    }
}

extension AppState {
    struct BusinessData: Equatable {
        var businessProfile: BusinessProfile?
    }
}

extension AppState {
    struct UserData: Equatable {
        var selectedStore: Loadable<RetailStoreDetails> = .notRequested
        var selectedFulfilmentMethod: RetailStoreOrderMethodType = .delivery
        var searchResult: Loadable<RetailStoresSearch> = .notRequested
        var basket: Basket?
        
        // currentFulfilmentLocation comes from the store search but only set
        // once a store is chosen.
        var currentFulfilmentLocation: FulfilmentLocation?
        var tempTodayTimeSlot: RetailStoreSlotDayTimeSlot?
        var basketDeliveryAddress: Address?
        var memberProfile: MemberProfile?
    }
}

extension AppState {
    struct StaticCacheData: Equatable {
        var mentionMeRefereeResult: MentionMeRequestResult?
        var mentionMeOfferResult: MentionMeRequestResult?
        var mentionMeDashboardResult: MentionMeRequestResult?
    }
}

extension AppState {
    struct Notifications: Equatable {
        // Add/change/remove item to/in/from basket toasts
        var showAddItemToBasketToast = false
        var addItemToBasketAlertToast: AlertToast = AlertToast(
            displayMode: .banner(.pop),
            type: .complete(.snappyRed),
            title: Strings.ToastNotifications.BasketChangeTitle.basketChange.localized,
            subTitle: Strings.ToastNotifications.BasketChangeTitle.basketChangeSubtitle.localized
        )
    }
}

extension AppState {
    struct PushNotifications: Equatable {
        var showPushNotificationsEnablePromptView: Bool = false
        var displayableNotification: DisplayablePushNotification?
        var driverNotification: [AnyHashable: Any]?
        // required to cope with the Any in driverNotification
        static func == (lhs: AppState.PushNotifications, rhs: AppState.PushNotifications) -> Bool {
            var driverNotificationEqual = false
            if
                let lhsDriverNotification = lhs.driverNotification,
                let rhsDriverNotification = rhs.driverNotification,
                lhsDriverNotification.isEqual(to: rhsDriverNotification)
            {
                driverNotificationEqual = true
            } else {
                driverNotificationEqual = lhs.driverNotification == nil && rhs.driverNotification == nil
            }
            return lhs.showPushNotificationsEnablePromptView == rhs.showPushNotificationsEnablePromptView && lhs.displayableNotification == rhs.displayableNotification && driverNotificationEqual
        }
    }
}

extension AppState {
    struct System: Equatable {
        var isInForeground = false
        var isConnected = false
        var notificationDeviceToken: String?
    }
}

extension AppState {
    struct Permissions: Equatable {
        var push: Permission.Status = .unknown
    }
    
    static func permissionKeyPath(for permission: Permission) -> WritableKeyPath<AppState, Permission.Status> {
        let pathToPermissions = \AppState.permissions
        switch permission {
        case .pushNotifications:
            return pathToPermissions.appending(path: \.push)
        }
    }
}

#if DEBUG
extension AppState {
    static var preview: AppState {
        var state = AppState()
        state.system.isInForeground = true
        return state
    }
}
#endif
