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
        var postcodeSearch = ""
        var selectedStoreId: Int?
        var selectedFulFilmentMethod: RetailStoreOrderMethodType = .delivery
        var searchResult: Loadable<RetailStoresSearch> = .notRequested
        var basket: Basket?
    }
}

extension AppState {
    struct System: Equatable {
        var isActive: Bool = false // Used for detecting if app is in background, not currently used
    }
}

#if DEBUG
extension AppState {
    static var preview: AppState {
        var state = AppState()
        state.system.isActive = true
        return state
    }
}
#endif
