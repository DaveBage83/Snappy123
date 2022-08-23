//
//  MemberDashboardViewModel.swift
//  SnappyV2
//
//  Created by David Bage on 18/03/2022.
//

import Foundation
import Combine
import OSLog

// 3rd party
import DriverInterface

@MainActor
class MemberDashboardViewModel: ObservableObject {
    typealias OptionStrings = Strings.MemberDashboard.Options

    enum ViewState {
        case dashboard
        case orders
        case myDetails
        case profile
        case loyalty
        case logOut
    }
    
    // MARK: - Profile
    
    // We unwrap these computed strings here in the viewModel and replace with err messages if they are empty.
    // We should never be in this situation though, as we are making sure we have a profile before
    // displaying any of these fields.
    
    var firstNamePresent: Bool {
        profile?.firstname != nil
    }

    var isDashboardSelected: Bool {
        viewState == .dashboard
    }
    
    var isOrdersSelected: Bool {
        viewState == .orders
    }
    
    var isAddressesSelected: Bool {
        viewState == .myDetails
    }
    
    var isProfileSelected: Bool {
        viewState == .profile
    }
    
    var isLoyaltySelected: Bool {
        viewState == .loyalty
    }
    
    var isLogOutSelected: Bool {
        viewState == .logOut
    }
    
    var noMemberFound: Bool {
        profile == nil
    }
    
    var showDriverStartShift: Bool {
        container.appState.value.userData.memberProfile?.type == .driver
    }

    let container: DIContainer
    private let dateGenerator: () -> Date
    
    @Published var profile: MemberProfile?
    @Published var viewState: ViewState = .dashboard
    @Published var loggingOut = false
    @Published var loading = false
    @Published var error: Error?
    @Published var successMessage: String?
    @Published var showSettings = false
    @Published var driverSettingsLoading = false
    @Published var driverDependencies: DriverDependencyInjectionContainer?
    @Published var driverPushNotification: [AnyHashable : Any]
    @Published var appIsInForeground: Bool

    private var cancellables = Set<AnyCancellable>()
    
    init(container: DIContainer, dateGenerator: @escaping () -> Date = Date.init) {
        self.container = container
        self.dateGenerator = dateGenerator
        let appState = container.appState
        
        self._profile = .init(initialValue: appState.value.userData.memberProfile)
        self._appIsInForeground = .init(wrappedValue: appState.value.system.isInForeground)
        self._driverPushNotification = .init(initialValue: appState.value.pushNotifications.driverNotification ?? [:])
        
        setupBindToProfile(with: appState)
        setupDriverNotification(with: appState)
        setupAppIsInForegound(with: appState)
    }
    
    private func setupBindToProfile(with appState: Store<AppState>) {
        appState
            .map(\.userData.memberProfile)
            .receive(on: RunLoop.main)
            .sink { [weak self] profile in
                guard let self = self else { return }
                self.profile = profile
            }
            .store(in: &cancellables)
    }
    
    private func setupDriverNotification(with appState: Store<AppState>) {
        // no attempt to remove duplicates because similar in coming
        // notifications may be receieved
        appState
            .map(\.pushNotifications.driverNotification)
            .filter { $0 != nil }
            .sink { [weak self] driverNotification in
                guard
                    let self = self,
                    let driverNotification = driverNotification
                else { return }
                self.driverPushNotification = driverNotification
            }.store(in: &cancellables)
    }
    
    private func setupAppIsInForegound(with appState: Store<AppState>) {
        appState
            .map(\.system.isInForeground)
            .removeDuplicates()
            .assignWeak(to: \.appIsInForeground, on: self)
            .store(in: &cancellables)
    }
    
    func addAddress(address: Address) async {
        do {
            try await self.container.services.userService.addAddress(address: address)
            Logger.member.log("Successfully added address with ID \(String(address.id ?? 0))")
        } catch {
            self.error = error
            Logger.member.error("Failed to add address with ID \(String(address.id ?? 0)): \(error.localizedDescription)")
        }
    }
    
   func updateAddress(address: Address) async {
        do {
            try await self.container.services.userService.updateAddress(address: address)
            Logger.member.log("Successfully update address with ID \(String(address.id ?? 0))")
        } catch {
            self.error = error
            Logger.member.error("Failed to update address with ID \(String(address.id ?? 0)): \(error.localizedDescription)")
        }
    }

    func logOut() async {
        loggingOut = true
        do {
            try await self.container.services.userService.logout()
            self.loggingOut = false
            self.viewState = .dashboard
        } catch {
            self.error = error
            Logger.member.error("Failed to log user out: \(error.localizedDescription)")
        }
    }

    func dashboardTapped() {
        viewState = .dashboard
    }
    
    func ordersTapped() {
        viewState = .orders
    }
    
    func myDetailsTapped() {
        viewState = .myDetails
    }
    
    func profileTapped() {
        viewState = .profile
    }
    
    func loyaltyTapped() {
        viewState = .loyalty
    }
    
    func logOutTapped() {
        viewState = .logOut
    }
    
    func settingsTapped() {
        showSettings = true
    }
    
    func dismissSettings() {
        showSettings = false
    }
    
    func startDriverShiftTapped() async {
        driverSettingsLoading = true
        do {
            let sessionSettings = try await container.services.userService.getDriverSessionSettings()
            startDriverInterface(with: sessionSettings)
            driverSettingsLoading = false
        } catch {
            self.error = error
            driverSettingsLoading = false
            Logger.initial.error("Failed to fetch driver settings: \(error.localizedDescription)")
        }
    }
    
    func onAppearSendEvent() {
        container.eventLogger.sendEvent(for: .viewScreen, with: .appsFlyer, params: ["screen_reference": "root_account"])
    }
    
    func onAppearAddressViewSendEvent() {
        container.eventLogger.sendEvent(for: .viewScreen, with: .appsFlyer, params: ["screen_reference": "delivery_address_list"])
    }
    
    #warning("Temporarily methods until push notifications added")
    private func getNotificationsEnabledStatusHandler() async -> NotificationsEnabledStatus {
        return (enabled: true, denied: false)
    }
    private func registerForNotificationsHandler() async -> NotificationsEnabledStatus {
        return (enabled: true, denied: false)
    }
    
    private func startDriverInterface(with sessionSettings: DriverSessionSettings) {
        if let memberProfile = container.appState.value.userData.memberProfile {
            
            driverDependencies = DriverDependencyInjectionContainer(
                bussinessId: AppV2Constants.Business.id,
                apiRootPath: AppV2Constants.DriverInterface.baseURL,
                v1sessionToken: sessionSettings.v1sessionToken,
                businessLocationName: AppV2Constants.DriverInterface.businessLocationName,
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
}
