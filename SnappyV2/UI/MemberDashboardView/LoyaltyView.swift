//
//  LoyaltyView.swift
//  SnappyV2
//
//  Created by David Bage on 19/03/2022.
//

import SwiftUI

struct LoyaltyView: View {
    typealias ReferFriendStrings = Strings.MemberDashboard.Loyalty.ReferFriend
    typealias ReferralStrings = Strings.MemberDashboard.Loyalty.Referrals
    
    struct Constants {
        struct General {
            static let vSpacing: CGFloat = 20
        }
        
        struct Cards {
            static let minCornerRadius: CGFloat = 8
            static let maxCornerRadius: CGFloat = 15
        }
    }
    
    @StateObject var viewModel: MemberDashboardLoyaltyViewModel
    
    var body: some View {
        VStack(spacing: Constants.General.vSpacing) {
            ClipboardReferralCodeField(viewModel: .init(code: viewModel.referralCode))
    
            HStack {
                loyaltyCardView(
                    headline: viewModel.referralBalance,
                    subtitle: ReferFriendStrings.subtitle.localized,
                    caption: ReferFriendStrings.caption.localized,
                    color: .snappyTeal)
                
                loyaltyCardView(
                    headline: viewModel.numberOfReferrals,
                    subtitle: ReferralStrings.subtitle.localized,
                    caption: ReferralStrings.caption.localized,
                    color: .snappyBlue)
            }
        }
    }
    
    func loyaltyCardView(headline: String, subtitle: String, caption: String, color: Color) -> some View {
        VStack(alignment: .leading) {
            Text(headline)
                .font(.snappyTitle)
                .fontWeight(.bold)
            Text(subtitle)
                .font(.snappyBody)
                .fontWeight(.semibold)
            Text(caption)
                .font(.snappyCaption)
        }
        .frame(maxWidth: .infinity)
        .foregroundColor(.white)
        .padding(.vertical)
        .background(color)
        .cornerRadius(Constants.Cards.minCornerRadius, corners: [.topLeft, .bottomRight])
        .cornerRadius(Constants.Cards.maxCornerRadius, corners: [.topRight, .bottomLeft])
        
    }
}

#if DEBUG
struct LoyaltyView_Previews: PreviewProvider {
    static var previews: some View {
        LoyaltyView(viewModel: .init(profile: MemberProfile(
            firstname: "Alan",
            lastname: "Shearer",
            emailAddress: "test@test.com",
            type: .customer,
            referFriendCode: "123456",
            referFriendBalance: 15,
            numberOfReferrals: 3,
            mobileContactNumber: nil,
            mobileValidated: false,
            acceptedMarketing: false,
            defaultBillingDetails: nil,
            savedAddresses: nil,
            fetchTimestamp: nil)))
    }
}
#endif
