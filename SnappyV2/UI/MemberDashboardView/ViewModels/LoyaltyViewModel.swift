//
//  LoyaltyViewModel.swift
//  SnappyV2
//
//  Created by David Bage on 20/03/2022.
//

import Foundation

class LoyaltyViewModel: ObservableObject {
    enum CardType {
        case credit
        case referrals
    }
    
    let profile: MemberProfile?
    
    var referralCode: String {
        profile?.referFriendCode ?? Strings.MemberDashboard.Loyalty.noCode.localized
    }
    
    var numberOfReferrals: String {
        guard let profile = profile else { return "0" }

        return String(profile.numberOfReferrals)
    }
    
    var referralBalance: String {
        guard let profile = profile else { return "0" }

        return profile.referFriendBalance.toCurrencyString()
    }
    
    init(profile: MemberProfile?) {
        self.profile = profile
    }
}
