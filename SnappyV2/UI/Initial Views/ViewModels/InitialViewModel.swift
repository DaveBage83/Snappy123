//
//  InitialViewModel.swift
//  SnappyV2
//
//  Created by Henrik Gustavii on 16/09/2021.
//

import Combine
import OSLog

// just for testing with CLLocationCoordinate2D
import MapKit

// 3d party
import DriverInterface

@MainActor
class InitialViewModel: ObservableObject {
    
    enum NavigationDestination: Hashable {
            case login
            case create
            case memberDashboard
    }
    
    struct AlertInfo: Identifiable {
        enum AlertType {
            case locationServicesDenied
            case errorLoadingBusinessProfile
        }
        let id: AlertType
    }
    
    let container: DIContainer
    
    var locationManager: LocationManager
    
    @Published var postcode: String
    
    @Published var loginButtonPressed = false
    
    @Published var hasStore = false

    @Published var viewState: NavigationDestination?
    
    @Published var driverSettingsLoading = false
    
    @Published var businessProfileLoadingError: Error?
    
    var isMemberSignedIn: Bool {
        container.appState.value.userData.memberProfile != nil
    }
    
    var showLoginButtons: Bool {
        !isMemberSignedIn && !loggingIn
    }
    
    var showDriverStartShift: Bool {
        container.appState.value.userData.memberProfile?.type == .driver && businessProfileIsLoaded && isRestoring == false
    }
    
    var showAccountButton: Bool {
        businessProfileIsLoaded && isRestoring == false
    }
        
    @Published var driverDependencies: DriverDependencyInjectionContainer?

    @Published var searchResult: Loadable<RetailStoresSearch>
    @Published var details: Loadable<RetailStoreDetails>
    @Published var slots: Loadable<RetailStoreTimeSlots>
    @Published var menuFetch: Loadable<RetailStoreMenuFetch>
    @Published var globalSearch: Loadable<RetailStoreMenuGlobalSearch>
    
    @Published var showFirstView: Bool = false
    @Published var loggingIn: Bool = false
    @Published var isRestoring: Bool = false
    @Published var businessProfileIsLoading = false
    @Published var businessProfileIsLoaded: Bool
    @Published var showAlert: AlertInfo?
    
    private var cancellables = Set<AnyCancellable>()
    
    private let dateGenerator: () -> Date

    init(container: DIContainer, search: Loadable<RetailStoresSearch> = .notRequested, details: Loadable<RetailStoreDetails> = .notRequested, slots: Loadable<RetailStoreTimeSlots> = .notRequested, menuFetch: Loadable<RetailStoreMenuFetch> = .notRequested, globalSearch: Loadable<RetailStoreMenuGlobalSearch> = .notRequested, dateGenerator: @escaping () -> Date = Date.init, locationManager: LocationManager = LocationManager()) {
        
        #if DEBUG
        self.postcode = "PA34 4AG"
        #else
        self.postcode = ""
        #endif
        self.container = container
        self.searchResult = search
        self.details = details
        self.slots = slots
        self.menuFetch = menuFetch
        self.globalSearch = globalSearch
        self.dateGenerator = dateGenerator
        
        let appState = container.appState
        
        self._appIsInForeground = .init(wrappedValue: appState.value.system.isInForeground)
        self._driverPushNotification = .init(initialValue: appState.value.pushNotifications.driverNotification?.data ?? [:])
        self._businessProfileIsLoaded = .init(initialValue: appState.value.businessData.businessProfile != nil)
        self.locationManager = locationManager
        // Set initial isUserSignedIn flag to current appState value
        setupBindToRetailStoreSearch(with: appState)

        #if TEST
        #else
            Task {
                await loadBusinessProfile()
            }
        #endif
        
        setupLoginTracker(with: appState)
        setupAppIsInForegound(with: appState)
        setupDriverNotification(with: appState)
        setupBusinessProfileIsLoaded(with: appState)
        setupResetPaswordDeepLinkNavigation(with: appState)
        setupShowDeniedLocationAlert()
        clearAllStaleImageData()
    }
    
    private func clearAllStaleImageData() {
        container.services.imageService.clearAllStaleData()
    }

    private func restorePreviousState(with appState: Store<AppState>) async {
        isRestoring = true
        
        do {
            // check if the member is a driver that is on shift, if so, fetch their settings
            if appState.value.userData.memberProfile?.type == .driver && DriverConstants.isShiftStarted {
                let sessionSettings = try await container.services.memberService.getDriverSessionSettings()
                startDriverInterface(with: sessionSettings)
                
                // the driver was on shift no need to continue with the rest of the restore
                finishedRestoring()
                return
            }
            
            // check if store search exists in AppState, if not call server to check
            if appState.value.userData.searchResult == .notRequested {
                
                // restore previous search
                try await self.container.services.retailStoresService.repeatLastSearch()
            }
            
            // check if store search exists, if not, then stay on initial screen
            if appState.value.userData.searchResult == .notRequested {
                finishedRestoring()
                return
            }
            
            let postcode = appState.value.userData.searchResult.value?.fulfilmentLocation.postcode
            
            // check if selectedStore exists in appState, and if not restore from db
            if appState.value.userData.selectedStore == .notRequested, let postcode = postcode {
                do {
                    try await self.container.services.retailStoresService.restoreLastSelectedStore(postcode: postcode)
                } catch {
                    Logger.initial.info("Failed to retrieve last selected store from db - Error: \(error.localizedDescription)")
                }
            }
            
            // check if last selected store was retrieved from db, if not, show store selection tab
            if let selectedStore = appState.value.userData.selectedStore.value {
                
                // check if local basket exists,  if not, then fetch from server
                if appState.value.userData.basket == nil {
                    
                    // restore basket
                    do {
                        try await self.container.services.basketService.restoreBasket()
                    } catch {
                        Logger.initial.info("Failed to restore basket - Error: \(error.localizedDescription)")
                    }
                }
                
                // check if basket exists and unwrap, if not, then move to store selection tab
                if let basket = appState.value.userData.basket {
                    
                    // check if there is a fulfilmentMethod in the basket. If there is, set the appState selectedFulfilmentMethod accordingly
                    if let method = appState.value.userData.basket?.fulfilmentMethod.type {
                        appState.value.userData.selectedFulfilmentMethod = method
                    }
                    
                    // check if store search contains stores and filter store list by fulfilment, else
                    // go to store selection screen
                    if let stores = appState.value.userData.searchResult.value?.stores {
                        let basketMethod = basket.fulfilmentMethod.type
                        let filteredStores = stores.filter { value in
                            if let orderMethods = value.orderMethods {
                                return orderMethods.keys.contains(basketMethod.rawValue )
                            }
                            return false
                        }
                        
                        // check if selectedStore id  exists in store search, else go to store selection screen
                        if filteredStores.contains(where: { $0.id == selectedStore.id }) {
                            
                            // check if items in basket, and if so, move to basket tab
                            if basket.items.isEmpty == false {
                                self.container.appState.value.routing.selectedTab = .basket
                                self.container.appState.value.routing.showInitialView = false
                                finishedRestoring()
                                return
                            }
                            
                            // check if basket contains fulfilment time
                            if let slot = appState.value.userData.basket?.selectedSlot {
                                let dateNow = Date().trueDate
                                
                                // check if today has been selected
                                if let todaySelected = slot.todaySelected, todaySelected {
                                    
                                    // check if slots are available today, if so, then goto menu tab
                                    if
                                        let timeSlots = try? await container.services.retailStoresService.getStoreTimeSlots(
                                            storeId: selectedStore.id,
                                            startDate: dateNow.startOfDay,
                                            endDate: dateNow.endOfDay,
                                            method: basketMethod,
                                            location: appState.value.userData.searchResult.value?.fulfilmentLocation.location,
                                            clearCache: true
                                        )?.slotDays?.first?.slots,
                                        timeSlots.count > 0
                                    {
                                        self.container.appState.value.routing.selectedTab = .menu
                                        self.container.appState.value.routing.showInitialView = false
                                        finishedRestoring()
                                        return
                                    }
                                // check if expiry date exists and if it is still valid
                                } else if let expiryDate = slot.expires, dateNow < expiryDate {
                                    
                                    // check if the same slot still exists on that day, if so, goto menu tab
                                    do {
                                        if
                                            let startTime = slot.start,
                                            let timeSlots = try await container.services.retailStoresService.getStoreTimeSlots(
                                                storeId: selectedStore.id,
                                                startDate: startTime.startOfDay,
                                                endDate: startTime.endOfDay,
                                                method: basketMethod,
                                                location: appState.value.userData.searchResult.value?.fulfilmentLocation.location,
                                                clearCache: true
                                            )?.slotDays?.first?.slots,
                                            timeSlots.contains(where: { $0.startTime == slot.start && $0.endTime == slot.end })
                                        {
                                            self.container.appState.value.routing.selectedTab = .menu
                                            self.container.appState.value.routing.showInitialView = false
                                            self.finishedRestoring()
                                            return
                                        }
                                    } catch {
                                        Logger.initial.info("Failed to get store time slot - Error: \(error.localizedDescription)")
                                    }
                                }
                            }
                        }
                    }
                }
            }
            
            // default
            container.appState.value.routing.selectedTab = .stores
            container.appState.value.routing.showInitialView = false
            finishedRestoring()
            return
        } catch {
            #warning("Add an alert with a retry, in case of failed connection")
            finishedRestoring()
            Logger.initial.info("Could not complete session restore - Error: \(error.localizedDescription)")
        }
    }
    
    private func finishedRestoring() {
        isRestoring = false
        container.appState.value.postponedActions.restoreFinished = true
        if container.services.userPermissionsService.pushNotificationPreferencesRequired {
            container.appState.value.pushNotifications.showPushNotificationsEnablePromptView = true
        }
    }
    
    private func setupLoginTracker(with appState: Store<AppState>) {
        appState
            .map(\.userData.memberProfile)
            .map { profile in
               return profile != nil
            }
            .receive(on: RunLoop.main)
            .sink { [weak self] signedIn in
                guard let self = self, signedIn else { return }
                self.loggingIn = false
                
                // If we are in memberDashboard state, we do not want to navigate back to initial view
                if self.viewState != .memberDashboard {
                    self.viewState = .none
                }
            }
            .store(in: &cancellables)
    }

    var isLoading: Bool {
        switch searchResult {
        case .isLoading(last: _, cancelBag: _):
            return true
        default:
            return false
        }
    }
    
    @Published var locationIsLoading: Bool = false
    
    private func setError(_ error: Error) {
        self.container.appState.value.errors.append(error)
    }
    
    private func setupBindToRetailStoreSearch(with appState: Store<AppState>) {
        appState
            .map(\.userData.searchResult)
            .removeDuplicates()
            .assignWeak(to: \.searchResult, on: self)
            .store(in: &cancellables)
    }
    
    func restoreLastUser() async {
        do {
            try await container.services.memberService.restoreLastUser()
        } catch {
            setError(error)
        }
    }

    func loadBusinessProfile() async {
        
        businessProfileIsLoading = true
        do {
            try await container.services.businessProfileService.getProfile()
            businessProfileIsLoading = false
            showFirstView = true
            isRestoring = true
            await restoreLastUser()
            await restorePreviousState(with: container.appState)
            
        } catch {
            businessProfileIsLoading = false
            businessProfileLoadingError = error
            showAlert = AlertInfo(id: .errorLoadingBusinessProfile)
            Logger.initial.fault("Failed to load business profile - Error: \(error.localizedDescription)")
        }
    }
    
    func loginTapped() {
        viewState = .login
    }
    
    func signUpTapped() {
        viewState = .create
    }
    
    func dismissLocationAlertTapped() {
        locationManager.dismissAlert()
        locationIsLoading = false
    }
    
    // In order to get a better longevity on the subscription it has to be
    // run from the view model instead inside LocationManager so that service
    // calls can be made from inside the pipeline. Unfortunately this makes the
    // LocationManager object less independent. This function is not unit tested,
    // as it is difficult/convoluted to use protocols with @Published among other
    // things when mocking LocationManager.
    func searchViaLocationTapped() async {
        locationIsLoading = true
            
        locationManager.$lastLocation
            .removeDuplicates()
            .asyncMap { [weak self] lastLocation in
                guard let self = self else { return }
                guard let lastLocation = lastLocation else { return }
                
                let coordinate = lastLocation.coordinate
                
                try await self.container.services.retailStoresService.searchRetailStores(location: coordinate).singleOutput()
                
                self.container.eventLogger.sendEvent(
                    for: .storeSearchFromStartView,
                    with: .firebaseAnalytics,
                    params: [
                        "latitude": coordinate.latitude,
                        "longitude": coordinate.longitude
                    ]
                )
                
                self.container.appState.value.routing.showInitialView = false
                
                self.locationIsLoading = false
            }
            .sink {_ in}
            .store(in: &cancellables)
        
        locationManager.requestLocation()
    }
    
    func onAppearSendEvent() {
        container.eventLogger.sendEvent(for: .viewScreen(.outside, .initialStoreSearch), with: .appsFlyer, params: [:])
    }
    
    @Published var appIsInForeground: Bool
    
    private func setupAppIsInForegound(with appState: Store<AppState>) {
        appState
            .map(\.system.isInForeground)
            .removeDuplicates()
            .assignWeak(to: \.appIsInForeground, on: self)
            .store(in: &cancellables)
    }
    
    @Published var driverPushNotification: [AnyHashable : Any]
    
    private func setupDriverNotification(with appState: Store<AppState>) {
        // no attempt to remove duplicates because similar in coming
        // notifications may be receieved
        appState
            .map(\.pushNotifications.driverNotification)
            .filter { $0 != nil }
            .receive(on: RunLoop.main)
            .sink { [weak self] driverNotification in
                guard
                    let self = self,
                    let driverNotification = driverNotification
                else { return }
                self.driverPushNotification = driverNotification.data
            }.store(in: &cancellables)
    }
    
    private func setupBusinessProfileIsLoaded(with appState: Store<AppState>) {
        appState
            .map(\.businessData.businessProfile)
            .filter { $0 != nil }
            .removeDuplicates()
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                guard let self = self else { return }
                self.businessProfileIsLoaded = true
            }.store(in: &cancellables)
    }
    
    private func setupShowDeniedLocationAlert() {
        locationManager.$showDeniedLocationAlert
            .filter { $0 }
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                guard let self = self else { return }
                // clear the failure flag and show the alert
                self.locationManager.showDeniedLocationAlert = false
                self.showAlert = AlertInfo(id: .locationServicesDenied)
            }.store(in: &cancellables)
    }
    
    private func setupResetPaswordDeepLinkNavigation(with appState: Store<AppState>) {
        appState
            .map(\.passwordResetCode)
            .removeDuplicates()
            .receive(on: RunLoop.main)
            .sink { [weak self] token in
                guard
                    let self = self,
                    self.viewState != .memberDashboard,
                    token != nil
                else { return }
                self.viewState = .memberDashboard
            }.store(in: &cancellables)
    }
    
    private func getNotificationsEnabledStatusHandler() async -> NotificationsEnabledStatus {
        let currentStatus = container.appState.value[keyPath: AppState.permissionKeyPath(for: .pushNotifications)]
        return (enabled: currentStatus == .granted, denied: currentStatus == .denied)
    }
    
    private func registerForNotificationsHandler() async -> NotificationsEnabledStatus {
        // trigger the system prompt for push notifications
        container.services.userPermissionsService.request(permission: .pushNotifications)
        
        do {
            return try await container.appState
                .updates(for: AppState.permissionKeyPath(for: .pushNotifications))
                .first(where: { $0 != .unknown && $0 != .notRequested })
                .map { status in
                    return (enabled: status == .granted, denied: status == .denied)
                }
                .eraseToAnyPublisher()
                .singleOutput()
        } catch {
            return (enabled: false, denied: false)
        }
    }
    
    private func startDriverInterface(with sessionSettings: DriverSessionSettings) {
        if let memberProfile = container.appState.value.userData.memberProfile {
            
            driverDependencies = DriverDependencyInjectionContainer(
                bussinessId: AppV2Constants.Business.id,
                apiRootPath: AppV2Constants.DriverInterface.baseURL,
                v1sessionToken: sessionSettings.v1sessionToken,
                businessLocationName: AppV2Constants.Business.businessLocationName,
                driverUserDetails: DriverUserDetails(
                    firstName: memberProfile.firstname,
                    lastName: memberProfile.lastname,
                    endDriverShiftRestrictions: sessionSettings.endDriverShiftRestrictions.mapToDriverPackageRestriction(),
                    canRefundItems: sessionSettings.canRefundItems,
                    automaticEnRouteDetection: sessionSettings.automaticEnRouteDetection,
                    canRequestUnassignedOrders: sessionSettings.canRequestUnassignedOrders
                ),
                driverAppStoreSettings: sessionSettings.mapToDriverAppSettingsProfiles(),
                getTrueDateHandler: { [weak self] in
                    guard let self = self else { return Date().trueDate }
                    return self.dateGenerator().trueDate
                },
                getPriceStringHandler: { value in
                    #warning("Change required if non GBP currencies needed in driver interface")
                    // For the time being hard coded values because in v1
                    // from the drivers perspective no store was selected
                    // and GBP defaults were used. More radical API changes
                    // would need to be included to change this for drivers.
                    let formatter = NumberFormatter()
                    formatter.groupingSeparator = ","
                    formatter.decimalSeparator = "."
                    formatter.minimumFractionDigits = 2
                    formatter.maximumFractionDigits = 2
                    formatter.numberStyle = .decimal

                    if let price = formatter.string(from: NSNumber(value: value)) {
                        return "£" + price
                    } else {
                        return "£" + "NaN"
                    }
                },
                driverNotificationReceivedPublisher: self.$driverPushNotification,
                appEnteredForegroundPublisher: self.$appIsInForeground,
                getNotificationsEnabledStatusHandler: self.getNotificationsEnabledStatusHandler,
                registerForNotificationsHandler: self.registerForNotificationsHandler,
                apiErrorEventHandler: { [weak self] parameters in
                    guard let self = self else { return }
                    self.container.eventLogger.sendEvent(for: .apiError, with: .appsFlyer, params: parameters)
                },
                displayedStateHandler: { [weak self] displayed in
                    guard let self = self else { return }
                    self.container.appState.value.openViews.driverInterface = displayed
                }
            )
        }
    }
    
    func startDriverShiftTapped() async {
        driverSettingsLoading = true
        do {
            let sessionSettings = try await container.services.memberService.getDriverSessionSettings()
            startDriverInterface(with: sessionSettings)
            driverSettingsLoading = false
        } catch {
            setError(error)
            driverSettingsLoading = false
            Logger.initial.error("Failed to fetch driver settings: \(error.localizedDescription)")
        }
    }
    
    func tapLoadRetailStores() async {
        do {
            try await container.services.retailStoresService.searchRetailStores(postcode: postcode).singleOutput()
            
            container.eventLogger.sendEvent(
                for: .storeSearchFromStartView,
                with: .firebaseAnalytics,
                params: [
                    "search_text": postcode
                ]
            )
            
            self.container.appState.value.routing.showInitialView = false
        } catch {
            setError(error)
            Logger.initial.error("Failed to search for stores: \(error.localizedDescription)")
        }
            
//        container.services.retailStoresService.searchRetailStores(search: loadableSubject(\.search), postcode: "DD2 1RW")
//        container.services.retailStoresService.searchRetailStores(search: loadableSubject(\.search), postcode: "")
        
//        container.services.retailStoresService.searchRetailStores(
//            search: loadableSubject(\.search),
//            location: CLLocationCoordinate2D(latitude: 56.473358599999997, longitude: -3.0111853000000002)
//        )
        
//        container.services.retailStoresService.getStoreDetails(details: loadableSubject(\.details), storeId: 30, postcode: "DD1 3JA")

        
//        let formatter = DateFormatter()
//        formatter.locale = Locale(identifier: "en_US_POSIX")
//        formatter.timeZone = TimeZone(identifier: "Europe/London")
//        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
//
//        // for testing set the dates to the current or future date
//        if
//            let startDate = formatter.date(from: "2021-10-16 00:00:00"),
//            let endDate = formatter.date(from: "2021-10-16 23:59:59")
//        {
//            container.services.retailStoresService.getStoreDeliveryTimeSlots(
//                slots: loadableSubject(\.slots),
//                storeId: 30,
//                startDate: startDate,
//                endDate: endDate,
//                location: CLLocationCoordinate2D(latitude: 56.473358599999997, longitude: -3.0111853000000002)
//            )
//        }
        
//        container.services.retailStoreMenuService.getRootCategories(menuFetch: loadableSubject(\.menuFetch), storeId: 30, fulfilmentMethod: .delivery)
        
//        container.appState.value.userData.selectedFulfilmentMethod = .delivery
//        container.services.retailStoreMenuService.getChildCategoriesAndItems(menuFetch: loadableSubject(\.menuFetch), storeId: 910, categoryId: 179951)
        
//        container.services.basketService.test(delay: 2.0).sink(
//            receiveCompletion: { (error) in
//                print("test finished 0: \(String(describing: error))")
//            },
//            receiveValue: { value in
//                print("test 0: \(value)")
//            }
//        ).store(in: &cancellables)
        
//        container.appState.value.userData.selectedFulfilmentMethod = .delivery
//        container.appState.value.userData.selectedStore = .loaded(RetailStoreDetails.mockedData)
//
//        container.services.retailStoreMenuService.globalSearch(
//            searchFetch: loadableSubject(\.globalSearch),
//            searchTerm: "test",
//            scope: nil,
//            itemsPagination: nil,
//            categoriesPagination: nil
//        )
        

//
//        let item = BasketItemRequest(
//            menuItemId: 2827972,
//            quantity: 2,
//            sizeId: 0,
//            bannerAdvertId: 0,
//            options: []
//        )
//
//        container.services.basketService.addItem(item: item).sink(
//            receiveCompletion: { (error) in
//                print("add finished: \(String(describing: error))")
//            },
//            receiveValue: { value in
//                print("add: \(value)")
//            }
//        ).store(in: &cancellables)
//
//        DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) {
//            //call any function
//            self.container.services.basketService.applyCoupon(code: "KKTEST50PERCENTOFF").sink(
//                receiveCompletion: { (error) in
//                    print("restoreBasket finished: \(String(describing: error))")
//                },
//                receiveValue: { value in
//                    print("restoreBasket: \(value)")
//                }
//            ).store(in: &self.cancellables)
//        }
        
//        let item2 = BasketItemRequest(
//            menuItemId: 2896196,
//            quantity: 1,
//            sizeId: 0,
//            bannerAdvertId: 0,
//            options: []
//        )
//
//        container.services.basketService.addItem(item: item2).sink(
//            receiveCompletion: { (error) in
//                print("add finished: \(String(describing: error))")
//            },
//            receiveValue: { value in
//                print("add: \(value)")
//            }
//        ).store(in: &cancellables)
        
        
//        container.services.basketService.restoreBasket().sink(
//            receiveCompletion: { (error) in
//                print("restoreBasket finished: \(String(describing: error))")
//            },
//            receiveValue: { value in
//                print("restoreBasket: \(value)")
//            }
//        ).store(in: &cancellables)
//        
//        container.services.basketService.test(delay: 2.0).sink(
//            receiveCompletion: { (error) in
//                print("test finished 1: \(String(describing: error))")
//            },
//            receiveValue: { value in
//                print("test 1: \(value)")
//            }
//        ).store(in: &cancellables)
//
//        container.services.basketService.test(delay: 3.0).sink(
//            receiveCompletion: { (error) in
//                print("test finished 2: \(String(describing: error))")
//            },
//            receiveValue: { value in
//                print("test 2: \(value)")
//            }
//        ).store(in: &cancellables)

//        container.services.basketService.reserveTimeSlot(
//            timeSlotDate: "2021-12-13",
//            timeSlotTime: "11:00 - 12:00"
//        ).sink(
//            receiveCompletion: { (error) in
//                print("reserveTimeSlot finished: \(String(describing: error))")
//            },
//            receiveValue: { value in
//                print("reserveTimeSlot: \(value)")
//            }
//        ).store(in: &cancellables)
        
    }
    
    func navigateToUserArea() {
        if container.appState.value.userData.memberProfile == nil {
            viewState = .login
        } else {
            viewState = .memberDashboard
        }
    }
}

#if DEBUG
// This hack is neccessary in order to expose 'addDefaultParameter'. These cannot easily be tested without.
extension InitialViewModel {
    func exposeRegisterForNotificationsHandler() async -> NotificationsEnabledStatus {
        return await self.registerForNotificationsHandler()
    }
}
#endif
