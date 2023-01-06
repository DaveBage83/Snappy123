//
//  MemberDashboardViewModel.swift
//  SnappyV2
//
//  Created by David Bage on 18/03/2022.
//

import Foundation
import Combine
import OSLog
import SwiftUI

// 3rd party
import DriverInterface

@MainActor
class MemberDashboardViewModel: ObservableObject {
    typealias OptionStrings = Strings.MemberDashboard.Options

    enum OptionType {
        case dashboard
        case orders
        case myDetails
        case profile
        case loyalty
        case logOut
        case startDriverShift
        case verifyAccount
        
        var title: String {
            switch self {
            case .dashboard:
                return OptionStrings.dashboard.localized
            case .orders:
                return OptionStrings.orders.localized
            case .myDetails:
                return OptionStrings.addressesCards.localized
            case .profile:
                return OptionStrings.profile.localized
            case .loyalty:
                return OptionStrings.loyalty.localized
            case .logOut:
                return GeneralStrings.Logout.title.localized
            case .startDriverShift:
                return GeneralStrings.DriverInterface.startShift.localized
            case .verifyAccount:
                return OptionStrings.verifyAccount.localized
            }
        }
    }
    
    var optionsAvailable: [MemberDashboardOption] = [
        .init(type: .dashboard),
        .init(type: .orders),
        .init(type: .myDetails),
        .init(type: .profile),
        .init(type: .loyalty),
        .init(type: .logOut)
    ]
    
    var visibleOptions: [MemberDashboardOption] {
        var initialOptions = optionsAvailable
        
        if showVerifyAccountOption {
            initialOptions.insert(.init(type: .verifyAccount), at: initialOptions.count - 1)
        }
        
        if showDriverStartShiftOption {
            initialOptions.insert(.init(type: .startDriverShift), at: initialOptions.count - 1)
        }
        
        return initialOptions
    }
    
    struct ResetToken: Identifiable, Equatable {
        var id: String
    }
    
    // MARK: - Profile
    
    // We unwrap these computed strings here in the viewModel and replace with err messages if they are empty.
    // We should never be in this situation though, as we are making sure we have a profile before
    // displaying any of these fields.
    
    var firstNamePresent: Bool {
        profile?.firstname != nil
    }
    
    var noMemberFound: Bool {
        profile == nil
    }
    
    var showDriverStartShiftOption: Bool {
        container.appState.value.userData.memberProfile?.type == .driver
    }
    
    var showVerifyAccountOption: Bool {
        if let memberProfile = container.appState.value.userData.memberProfile {
            return memberProfile.mobileValidated == false && (memberProfile.mobileContactNumber?.count ?? 0) > 6
        }
        return false
    }
    
    let container: DIContainer
    private let dateGenerator: () -> Date
    
    @Published var profile: MemberProfile?
    @Published var viewState: OptionType = .dashboard
    @Published var loggingOut = false
    @Published var loading = false
    @Published var driverSettingsLoading = false
    @Published var driverDependencies: DriverDependencyInjectionContainer?
    @Published var driverPushNotification: [AnyHashable : Any]
    @Published var appIsInForeground: Bool
    @Published var requestingVerifyCode = false
    @Published var resetToken: ResetToken?
    @Published var activeOptionButton: OptionType = .dashboard
    
    // Forget member properties
    @Published var showInitialForgetMemberAlert = false
    @Published var showEnterForgetMemberCodeAlert = false {
        didSet {
            print(showEnterForgetMemberCodeAlert)
        }
    }
    @Published var forgetMemberRequestLoading = false
    @Published var enterForgetCodeTitle = ""
    @Published var enterForgetCodePrompt = ""
    @Published var forgetCode = ""

    var isFromInitialView: Bool {
        container.appState.value.routing.showInitialView
    }

    private var cancellables = Set<AnyCancellable>()
    
    init(container: DIContainer, dateGenerator: @escaping () -> Date = Date.init) {
        self.container = container
        self.dateGenerator = dateGenerator
        let appState = container.appState
        
        self._profile = .init(initialValue: appState.value.userData.memberProfile)
        self._appIsInForeground = .init(wrappedValue: appState.value.system.isInForeground)
        self._driverPushNotification = .init(initialValue: appState.value.pushNotifications.driverNotification?.data ?? [:])
        
        setupBindToProfile(with: appState)
        setupDriverNotification(with: appState)
        setupAppIsInForegound(with: appState)
        setupResetPaswordDeepLinkNavigation(with: appState)
        setupActiveState()
    }

    private func setupBindToProfile(with appState: Store<AppState>) {
        appState
            .map(\.userData.memberProfile)
            .receive(on: RunLoop.main)
            .sink { [weak self] profile in
                guard
                    let self = self,
                    profile != self.profile
                else { return }
                self.profile = profile
                // silently trigger fetching a mobile verification code if required by the coupon
                if
                    let registeredMemberRequirement = appState.value.userData.basket?.coupon?.registeredMemberRequirement,
                    registeredMemberRequirement != .none,
                    let profile = profile,
                    profile.mobileValidated == false,
                    (profile.mobileContactNumber?.count ?? 0) > 7
                {
                    Task {
                        do {
                            let openView = try await self.container.services.memberService.requestMobileVerificationCode()
                            if openView {
                                // The main SnappyV2App will display the app state because the view can
                                // also be requested in various other places within the app such as
                                // from the member area
                                self.container.appState.value.routing.showVerifyMobileView = true
                            }
                        } catch {
                            Logger.member.error("Failed to request SMS Mobile verification code: \(error.localizedDescription)")
                        }
                    }
                }
            }
            .store(in: &cancellables)
    }
        
    private func setupActiveState() {
        $viewState
            .removeDuplicates()
            .receive(on: RunLoop.main)
            .assignWeak(to: \.activeOptionButton, on: self)
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
                self.driverPushNotification = driverNotification.data
            }.store(in: &cancellables)
    }
    
    private func setupAppIsInForegound(with appState: Store<AppState>) {
        appState
            .map(\.system.isInForeground)
            .removeDuplicates()
            .assignWeak(to: \.appIsInForeground, on: self)
            .store(in: &cancellables)
    }
    
    private func setupResetPaswordDeepLinkNavigation(with appState: Store<AppState>) {
        appState
            .map(\.passwordResetCode)
            .removeDuplicates()
            .receive(on: RunLoop.main)
            .sink { [weak self] token in
                guard
                    let self = self,
                    let token = token
                else { return }
                self.resetToken = ResetToken(id: token)
            }.store(in: &cancellables)
        
        $resetToken
            .removeDuplicates()
            .receive(on: RunLoop.main)
            .sink { [weak self] token in
                self?.container.appState.value.passwordResetCode = nil
            }.store(in: &cancellables)
    }
    
    private func setError(_ err: Error) {
        container.appState.value.errors.append(err)
    }

    func logOut() async {
        loggingOut = true
        do {
            try await self.container.services.memberService.logout()
            self.loggingOut = false
            self.viewState = .dashboard
        } catch {
            self.setError(error)
            Logger.member.error("Failed to log user out: \(error.localizedDescription)")
        }
    }
    
    func startDriverShiftTapped() async {
        driverSettingsLoading = true
        do {
            let sessionSettings = try await container.services.memberService.getDriverSessionSettings()
            startDriverInterface(with: sessionSettings)
            driverSettingsLoading = false
        } catch {
            self.setError(error)
            driverSettingsLoading = false
            Logger.initial.error("Failed to fetch driver settings: \(error.localizedDescription)")
        }
    }
    
    func verifyAccountTapped() async {
        viewState = viewState
        requestingVerifyCode = true
        do {
            let openView = try await container.services.memberService.requestMobileVerificationCode()
            if openView {
                // The main SnappyV2App will display the app state because the view can
                // also be requested in various other places within the app such as
                // when adding coupons
                container.appState.value.routing.showVerifyMobileView = true
            }
            requestingVerifyCode = false
        } catch {
            self.setError(error)
            requestingVerifyCode = false
            Logger.member.error("Failed to request SMS Mobile verification code: \(error.localizedDescription)")
        }
    }
    
    func onAppearSendEvent() {
        container.eventLogger.sendEvent(for: .viewScreen(.outside, .rootAccount), with: .appsFlyer, params: [:])
    }
    
    func onAppearAddressViewSendEvent() {
        container.eventLogger.sendEvent(for: .viewScreen(.outside, .deliveryAddressList), with: .appsFlyer, params: [:])
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
    
    func isOptionActive(_ option: OptionType) -> Bool {
        activeOptionButton == option
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
    
    func switchState(to optionType: OptionType) {
        viewState = optionType
    }
    
    // Forget member methods
    
    func formetMeTapped() {
        showInitialForgetMemberAlert = true
    }
    
    func continueToForgetMeTapped() async throws {
        forgetMemberRequestLoading = true
        
        do {
            let sendForgetCodeRequest = try await container.services.memberService.sendForgetCode()
            enterForgetCodeTitle = sendForgetCodeRequest.message_title ?? Strings.ForgetMe.defaultTitle.localized
            enterForgetCodePrompt = sendForgetCodeRequest.message ?? Strings.ForgetMe.defaultPrompt.localized
            
            DispatchQueue.main.async {
                self.showEnterForgetMemberCodeAlert = true
            }
        } catch {
            container.appState.value.errors.append(error)
        }
        
        forgetMemberRequestLoading = false
    }
    
    func forgetMemberRequested(code: String) async throws {
        do {
            let _ = try await container.services.memberService.forgetMember(confirmationCode: code)
            showEnterForgetMemberCodeAlert = false
        } catch {
            container.appState.value.errors.append(error)
        }
        forgetCode = ""
    }
}
