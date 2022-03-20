//
//  MemberDashboardViewModel.swift
//  SnappyV2
//
//  Created by David Bage on 18/03/2022.
//

import Foundation
import Combine

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

    let container: DIContainer
    
    @Published var profile: MemberProfile?
    @Published var profileFetch: Loadable<MemberProfile> = .notRequested
    @Published var viewState: ViewState = .dashboard
    
    var searchingForMember: Bool {
        switch profileFetch {
        case .isLoading(last: _, cancelBag: _):
            return true
        default:
            return false
        }
    }
    
    private var cancellables = Set<AnyCancellable>()
    
    init(container: DIContainer) {
        self.container = container
        getProfile()
        setupMemberProfileFetch()
    }
    
    private func setupMemberProfileFetch() {
        $profileFetch
            .map { profile in
                return profile.value
            }
            .receive(on: RunLoop.main)
            .assignWeak(to: \.profile, on: self)
            .store(in: &cancellables)
    }
    
    private func getProfile() {
        container.services.userService.getProfile(profile: loadableSubject(\.profileFetch), filterDeliveryAddresses: false)
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
