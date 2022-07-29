//
//  MemberDashboardViewModel.swift
//  SnappyV2
//
//  Created by David Bage on 18/03/2022.
//

import Foundation
import Combine
import OSLog

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

    let container: DIContainer
    
    @Published var profile: MemberProfile?
    @Published var viewState: ViewState = .dashboard
    @Published var loggingOut = false
    @Published var loading = false
    @Published var error: Error?
    @Published var showSettings = false

    private var cancellables = Set<AnyCancellable>()
    
    init(container: DIContainer) {
        self.container = container
        let appState = container.appState
        
        self._profile = .init(initialValue: appState.value.userData.memberProfile)
        setupBindToProfile(with: appState)
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
    
    func onAppearSendEvent() {
        container.eventLogger.sendEvent(for: .viewScreen, with: .appsFlyer, params: ["screen_reference": "root_account"])
    }
    
    func onAppearAddressViewSendEvent() {
        container.eventLogger.sendEvent(for: .viewScreen, with: .appsFlyer, params: ["screen_reference": "delivery_address_list"])
    }
}
