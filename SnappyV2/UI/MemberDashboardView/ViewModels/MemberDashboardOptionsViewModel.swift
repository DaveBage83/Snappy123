//
//  MemberDashboardOptionsViewModel.swift
//  SnappyV2
//
//  Created by David Bage on 20/03/2022.
//

import SwiftUI

class MemberDashboardOptionsViewModel: ObservableObject {
    typealias OptionStrings = Strings.MemberDashboard.Options
    
    enum MemberDashboardOptionType {
        case dashboard
        case orders
        case addresses
        case profile
        case loyalty
        case logOut
    }
    
    var isActive: Bool
    
    let optionType: MemberDashboardOptionType
    let action: () -> Void
    
    var title: String {
        switch optionType {
        case .dashboard:
            return OptionStrings.dashboard.localized
        case .orders:
            return OptionStrings.orders.localized
        case .addresses:
            return OptionStrings.addresses.localized
        case .profile:
            return OptionStrings.profile.localized
        case .loyalty:
            return OptionStrings.loyalty.localized
        case .logOut:
            return GeneralStrings.Logout.title.localized
        }
    }

    init(_ optionType: MemberDashboardOptionType, action: @escaping () -> Void, isActive: Bool) {
        self.optionType = optionType
        self.action = action
        self.isActive = isActive
    }
}
