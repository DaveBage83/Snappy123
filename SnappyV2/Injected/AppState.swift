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
        var searchResult: Loadable<RetailStoresSearch> = .notRequested
        var selectedStore: Loadable<RetailStoreDetails> = .notRequested
    }
}

extension AppState {
    struct System: Equatable {
        var isActive: Bool = false // Not sure yet what this is for, probably will have to go
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
