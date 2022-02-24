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
        var memberSignedIn = false
        var basketContactDetails: BasketContactDetails?
        var tempTodaySlot: RetailStoreSlotDayTimeSlot?
    }
}

extension AppState {
    struct System: Equatable {
        var isInForeground: Bool = false
        var isConnected: Bool = false
    }
}

struct BasketContactDetails: Equatable {
    let firstName: String
    let surname: String
    let email: String
    let telephoneNumber: String
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
