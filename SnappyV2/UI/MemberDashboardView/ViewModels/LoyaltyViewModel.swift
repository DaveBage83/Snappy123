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

        // If the referral balance is a round number, no need to show decimals
        if Int(exactly: profile.referFriendBalance) != nil {
            return String(Int(profile.referFriendBalance))
        }
        // Otherwise show to 2 decimals
        return String(format: "%.2f", profile.referFriendBalance)
    }
    
    init(profile: MemberProfile?) {
        self.profile = profile
    }
}
