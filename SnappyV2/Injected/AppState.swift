//
//  AppState.swift
//  SnappyV2
//
//  Created by Henrik Gustavii on 15/09/2021.
//

import Foundation

struct AppState: Equatable {
    var system = System()
    var routing = ViewRouting()
    var businessData = BusinessData()
    var userData = UserData()
    var notifications = Notifications()
}

extension AppState {
    struct ViewRouting: Equatable {
        var showInitialView: Bool = true
        var selectedTab = 1
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
    struct Notifications: Equatable {
        // Add/change/remove item to/in/from basket toasts
        var showAddItemToBasketToast: Bool = false
        var addItemToBasketAlertToast: AlertToast = AlertToast(
            displayMode: .banner(.pop),
            type: .complete(.snappyRed),
            title: Strings.ToastNotifications.BasketChangeTitle.basketChange.localized,
            subTitle: Strings.ToastNotifications.BasketChangeTitle.basketChangeSubtitle.localized
        )
    }
}

extension AppState {
    struct System: Equatable {
        var isInForeground: Bool = false
        var isConnected: Bool = false
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
