//
//  AppState.swift
//  SnappyV2
//
//  Created by Henrik Gustavii on 15/09/2021.
//

import Foundation
import SwiftUI

struct AppState: Equatable {
    static func == (lhs: AppState, rhs: AppState) -> Bool { true }
    
    var system = System()
    var routing = ViewRouting()
    var openViews = OpenViews()
    var businessData = BusinessData()
    var userData = UserData()
    var staticCacheData = StaticCacheData()
    var notifications = Notifications()
    var permissions = Permissions()
    var pushNotifications = PushNotifications()
    var postponedActions = PostponedActions()
    var storeMenu = StoreMenu()
    var retailStoreReview: RetailStoreReview?
    var passwordResetCode: String?
    
    // Toast properties
    var viewIDs = [UUID]() // Used to ensure toast only displayed on latest view. Ensures toasts are not presented on sheets and views beneathe sheets simultaneously
    var errors: [Swift.Error] = []
    var successToastStrings = [String]()
    var latestViewID: UUID? {
        viewIDs.last
    }
    
    var latestSuccessToast: String? {
        successToastStrings.first
    }
    
    var latestError: Swift.Error? {
        errors.first
    }
}

extension AppState {
    struct ViewRouting: Equatable {
        var showInitialView = true
        var selectedTab: Tab = .stores
        var urlToOpen: URL?
        var showVerifyMobileView = false
        var displayedDriverLocation: DriverLocationMapParameters?
        var showOrder: PlacedOrder?
    }
}

extension AppState {
    struct StoreMenu: Equatable {
        // for general menu navigation
        var rootCategories = [RetailStoreMenuCategory]()
        var subCategories = [[RetailStoreMenuCategory]]()
        var unsortedItems = [RetailStoreMenuItem]()
        var specialOfferItems = [RetailStoreMenuItem]()
        // for the search state restore:
        var searchText = ""
        var searchResultCategories = [GlobalSearchResultRecord]()
        var searchResultItems = [RetailStoreMenuItem]()
        var navigationWithIsSearchActive = 0
        // titles
        var subCategoryNavigationTitle = [String]()
        var itemNavigationTitle: String? = nil
        
        // settings
        var showHorizontalItemCards = UIDevice.current.userInterfaceIdiom == .phone ? true : false
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
        var successCheckoutBasket: Basket?
        var confirmedAge: Int = 0
        
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
            subTitle: .constant(Strings.ToastNotifications.BasketChangeTitle.basketChangeSubtitle.localized), tapToDismiss: false
        )
    }
}

extension AppState {
    struct PushNotifications: Equatable {
        var showPushNotificationsEnablePromptView: Bool = false
        var displayableNotification: DisplayablePushNotification?
        var driverNotification: RawNotification?
        var driverMapNotification: RawNotification?
        var driverMapOpenNotification: RawNotification?
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
        var marketingPushNotifications: Permission.Status = .unknown
    }
    
    static func permissionKeyPath(for permission: Permission) -> WritableKeyPath<AppState, Permission.Status> {
        let pathToPermissions = \AppState.permissions
        switch permission {
        case .pushNotifications:
            return pathToPermissions.appending(path: \.push)
        case .marketingPushNotifications:
            return pathToPermissions.appending(path: \.marketingPushNotifications)
        }
    }
}

extension AppState {
    struct PostponedActions: Equatable {
        /// flag used to indicate whether processing should be postponed or actioned immediately
        var restoreFinished = false
        var deepLinks: [DeepLink] = []
        var pushNotifications: [PushNotification] = []
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
