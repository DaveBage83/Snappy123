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
    
    var noBillingAddresses: Bool {
        billingAddresses.isEmpty
    }
    
    var noDeliveryAddresses: Bool {
        deliveryAddresses.isEmpty
    }
    
    var deliveryAddresses: [Address] {
        return profile?.savedAddresses?.filter {
            $0.type == .delivery
        } ?? []
    }
        
    var billingAddresses: [Address] {
        return profile?.savedAddresses?.filter {
            $0.type == .billing
        } ?? []
    }

    let container: DIContainer
    
    @Published var profile: MemberProfile?
    @Published var viewState: ViewState = .dashboard
    @Published var loggingOut = false

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
    
    func addAddress(address: Address) {
        container.services.userService.addAddress(address: address)
            .receive(on: RunLoop.main)
            .sink { completion in
                switch completion {
                case .failure(let err):
                    Logger.member.error("Failed to add address with ID \(String(address.id ?? 0)): \(err.localizedDescription)")
                case .finished:
                    Logger.member.log("Successfully added address with ID \(String(address.id ?? 0))")
                }
            }
            .store(in: &cancellables)
    }
    
   func updateAddress(address: Address) {
        container.services.userService.updateAddress(address: address)
            .receive(on: RunLoop.main)
            .sink { completion in
                switch completion {
                case .failure(let err):
                    Logger.member.error("Failed to update address with ID \(address.id ?? 0) : \(err.localizedDescription)")
                case .finished:
                    Logger.member.log("Successfully update address with ID \(address.id ?? 0)")
                }
            }
            .store(in: &cancellables)
    }

    func logOut() {
        loggingOut = true
        
        Task { @MainActor [weak self] in
            guard let self = self else { return }
            do {
                try await self.container.services.userService.logout().singleOutput()
                self.loggingOut = false
                self.viewState = .dashboard
            } catch {
                #warning("Error toast to be added")
                Logger.member.error("Failed to log user out: \(error.localizedDescription)")
            }
        }
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