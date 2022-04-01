//
//  MemberDashboardHomeViewModel.swift
//  SnappyV2
//
//  Created by David Bage on 20/03/2022.
//

import Foundation
import Combine

class MemberDashboardHomeViewModel: ObservableObject {
    let profile: MemberProfile?
    let container: DIContainer
    private var cancellables = Set<AnyCancellable>()
    
    #warning("We need to come back to this as currently the past orders fetch is not working properly from backend")
    @Published var pastOrdersFetch: Loadable<[PlacedOrder]?> = .notRequested
    @Published var pastOrders: [PlacedOrder]?
    
    var referralCode: String {
        // In theory we should always have a code as we will only be here
        // if user is signed in and therefore there is a profile present
        profile?.referFriendCode ?? Strings.MemberDashboard.Loyalty.noCode.localized
    }
    
    var hasPastOrders: Bool {
        pastOrders != nil
    }
    
    init(container: DIContainer, profile: MemberProfile?) {
        self.container = container
        self.profile = profile
//        setupPastOrdersFetch()
        getPastOrders()
        
        #warning("To remove once getPastOrders call is fixed from backend")
        self.pastOrders = [TestPastOrder.order, TestPastOrder_2.order]
    }
    
    private func setupPastOrdersFetch() {
        $pastOrdersFetch
            .sink { [weak self] orders in
                guard let self = self, let orders = orders.value else { return }
                self.pastOrders = orders
            }
            .store(in: &cancellables)
    }

    private func getPastOrders() {
        container.services.userService.getPastOrders(pastOrders: loadableSubject(\.pastOrdersFetch), dateFrom: nil, dateTo: nil, status: nil, page: nil, limit: nil)
    }
}
