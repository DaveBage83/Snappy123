//
//  MemberDashboardViewModel.swift
//  SnappyV2
//
//  Created by David Bage on 18/03/2022.
//

import Foundation
import Combine
import OSLog

class MemberDashboardViewModel: ObservableObject {
    typealias OptionStrings = Strings.MemberDashboard.Options

    enum ViewState {
        case dashboard
        case orders
        case addresses
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
        viewState == .addresses
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

    private var cancellables = Set<AnyCancellable>()
    
    init(container: DIContainer) {
        self.container = container
        let appState = container.appState
        
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
    
    #warning("This is temporary only - full logout flow not yet implemented")
    func logOut() {
        container.services.userService.logout()
            .sink { completion in
                Logger.member.info("Logged out")
            }
            .store(in: &cancellables)
    }

    func dashboardTapped() {
        viewState = .dashboard
    }
    
    func ordersTapped() {
        viewState = .orders
    }
    
    func addressesTapped() {
        viewState = .addresses
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
}
