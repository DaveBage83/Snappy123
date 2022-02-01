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
    var userData = UserData()
}

extension AppState {
    struct ViewRouting: Equatable {
        var showInitialView: Bool = true
        var selectedTab = 1
    }
}

extension AppState {
    struct UserData: Equatable {
        var selectedStore: Loadable<RetailStoreDetails> = .notRequested
        var selectedFulfilmentMethod: RetailStoreOrderMethodType = .delivery
        var searchResult: Loadable<RetailStoresSearch> = .notRequested
        var basket: Basket?
        var memberSignedIn = false
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
