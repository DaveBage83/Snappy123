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
    
    var referralCode: String {
        // In theory we should always have a code as we will only be here
        // if user is signed in and therefore there is a profile present
        profile?.referFriendCode ?? Strings.MemberDashboard.Loyalty.noCode.localized
    }

    init(container: DIContainer) {
        self.container = container
        let appstate = container.appState
        self.profile = appstate.value.userData.memberProfile
    }
}
