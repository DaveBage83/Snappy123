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

    @Published var viewState: NavigationDestination?
    
    @Published var driverSettingsLoading = false
    
    @Published var businessProfileLoadingError: Error?
    
    var showDriverStartShift: Bool {
        container.appState.value.userData.memberProfile?.type == .driver && businessProfileIsLoaded && isRestoring == false
    }
    
    var showAccountButton: Bool {
        businessProfileIsLoaded && isRestoring == false
    }
        
    @Published var driverDependencies: DriverDependencyInjectionContainer?

    @Published var searchResult: Loadable<RetailStoresSearch>
    
    @Published var loggingIn: Bool = false
    @Published var isRestoring: Bool = false
    @Published var businessProfileIsLoading = false
    @Published var businessProfileIsLoaded: Bool
    @Published var showAlert: AlertInfo?
    
    private var cancellables = Set<AnyCancellable>()
    
    private let dateGenerator: () -> Date

    init(container: DIContainer, search: Loadable<RetailStoresSearch> = .notRequested, dateGenerator: @escaping () -> Date = Date.init, locationManager: LocationManager = LocationManager()) {
        
        #if DEBUG
        self.postcode = "PA34 4AG"
        #else
        self.postcode = ""
        #endif
        self.container = container
        self.searchResult = search
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
        bindToVersionChecked(with: appState)
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
            
            if showVersionUpgradeAlert == false {
                isRestoring = true
                await restoreLastUser()
                await restorePreviousState(with: container.appState)
            }
        } catch {
            businessProfileIsLoading = false
            businessProfileLoadingError = error
            showAlert = AlertInfo(id: .errorLoadingBusinessProfile)
            Logger.initial.fault("Failed to load business profile - Error: \(error.localizedDescription)")
        }
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
    
    @Published var showVersionUpgradeAlert = false
    
    var updateMessage: String {
        guard let profile = container.appState.value.businessData.businessProfile,
              let orderingClientUpdateRequirements = profile.orderingClientUpdateRequirements.filter({ $0.platform == "ios" }).first else { return Strings.VersionUpateAlert.defaultPrompt.localized }
        
        return orderingClientUpdateRequirements.updateDescription
    }
    
    var appUpgradeUrl: String? {
        guard let profile = container.appState.value.businessData.businessProfile,
              let orderingClientUpdateRequirements = profile.orderingClientUpdateRequirements.filter({ $0.platform == "ios" }).first else { return nil }
        
        return orderingClientUpdateRequirements.updateUrl
    }
    
    private func bindToVersionChecked(with appState: Store<AppState>) {
        appState
            .map(\.userData.versionUpdateChecked)
            .removeDuplicates()
            .receive(on: RunLoop.main)
            .sink { [weak self] versionChecked in
                guard let self = self else { return }
                if versionChecked == true {
                    self.showVersionUpgradeAlert = false
                }
            }
            .store(in: &cancellables)
    }
    
    private func setupBusinessProfileIsLoaded(with appState: Store<AppState>) {
        appState
            .map(\.businessData.businessProfile)
            .filter { $0 != nil }
            .removeDuplicates()
            .receive(on: RunLoop.main)
            .sink { [weak self] profile in
                guard let self = self else { return }
                
                if self.container.appState.value.userData.versionUpdateChecked == false {
                    self.showVersionUpgradeAlert = self.encourageUserUpgrade(profile: profile)
                }
                
                self.businessProfileIsLoaded = true
            }.store(in: &cancellables)
    }
    
    private func encourageUserUpgrade(profile: BusinessProfile?) -> Bool {
        // If we do not have any orderingClientUpdateRequirements then we do not have enough info to encourage a user upgrade. We should not end up here
        // as these requirements are required fields
        guard let orderingClientUpdateRequirements = profile?.orderingClientUpdateRequirements.filter({ $0.platform == "ios" }).first,
              AppV2Constants.Client.systemVersion.versionUpToDate(String(orderingClientUpdateRequirements.minimumOSVersion))
        else { return false }

        let currentAppVersion = Bundle.main.infoDictionary?["CFBundleVersion"] as? String // User's current
        let minBuildVersion = Int(orderingClientUpdateRequirements.minimumBuildVersion)
        
        // If there is a current app version and minBuild version, then we check if the current version is out of date.
        // If it is, then return true.
        if let currentAppVersion, let version = Int(currentAppVersion), let minBuildVersion {
           return version < minBuildVersion
        }
        
        // If we do not have the currentAppVersion or minBuildVersion data then do not encourage an upgrade
        return false
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
    }
    
    func navigateToUserArea() {
        if container.appState.value.userData.memberProfile == nil {
            viewState = .login
        } else {
            viewState = .memberDashboard
        }
    }
}

#if DEBUG || TEST
// This hack is neccessary in order to expose 'addDefaultParameter'. These cannot easily be tested without.
extension InitialViewModel {
    func exposeRegisterForNotificationsHandler() async -> NotificationsEnabledStatus {
        return await self.registerForNotificationsHandler()
    }
}
#endif
