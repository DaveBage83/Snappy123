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
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.tabViewHeight) var tabViewHeight
    @Environment(\.mainWindowSize) var mainWindowSize

    struct Constants {
        struct General {
            static let vSpacing: CGFloat = 20
        }
        
        struct Cards {
            static let minCornerRadius: CGFloat = 8
            static let maxCornerRadius: CGFloat = 15
        }
        
        struct Credit {
            static let iconWidth: CGFloat = 32
            static let cardWidthMultiplier: CGFloat = 0.5
        }
        
        struct MentionMe {
            static let spacing: CGFloat = 20
            static let bottomPadding: CGFloat = 34
            static let hPadding: CGFloat = 40.5
        }
    }
    
    @StateObject var viewModel: MemberDashboardLoyaltyViewModel
    
    private var colorPalette: ColorPalette {
        .init(container: viewModel.container, colorScheme: colorScheme)
    }
    
    var body: some View {
        VStack(spacing: Constants.General.vSpacing) {
            credit
            
            Spacer()
            mentionMeView
                .redacted(reason: viewModel.showMentionMeLoading ? .placeholder : [])
                .padding(.bottom, tabViewHeight)
        }
        .snappySheet(container: viewModel.container, isPresented: $viewModel.showMentionMeWebView,
                     sheetContent: MentionMeWebView(
                        viewModel: MentionMeWebViewModel(
                            container: viewModel.container,
                            mentionMeRequestResult: viewModel.mentionMeDashboardRequestResult,
                            dismissWebViewHandler: { _ in
                                viewModel.mentionMeWebViewDismissed()
                            }
                        )
                     ))
        .onChange(of: viewModel.webViewURL) { url in
            if let url = url {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
    }
    
    @ViewBuilder private var credit: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(viewModel.referralBalance)
                    .font(.heading1.bold())
                Spacer()
                Image.Icons.MoneyBill1Wave.filled
                    .renderingMode(.template)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: Constants.Credit.iconWidth)
                    .foregroundColor(.white.withOpacity(.twenty))
            }
            
            Text(Strings.MemberDashboard.Loyalty.ReferFriend.subtitle.localized)
                .font(.Body1.semiBold())
                .padding(.bottom)
            Text(Strings.MemberDashboard.Loyalty.ReferFriend.caption.localized)
                .font(.Caption1.semiBold())
        }
        .frame(maxWidth: mainWindowSize.width * Constants.Credit.cardWidthMultiplier)
        .foregroundColor(.white)
        .padding()
        .background(colorPalette.alertSuccess)
        .standardCardFormat()
    }
    
    @ViewBuilder private var mentionMeView: some View {
        VStack(spacing: Constants.MentionMe.spacing) {
            VStack {
                Text(viewModel.mentionMeButtonText ?? Strings.MentionMe.Main.referForDiscount.localized)
                    .font(.heading2.bold())
                    .foregroundColor(colorPalette.primaryBlue)
                
                Text(Strings.MentionMe.Main.tellFriends.localized)
                    .font(.Body1.regular())
                    .foregroundColor(colorPalette.primaryBlue)
            }
            
            SnappyButton(
                container: viewModel.container,
                type: .primary,
                size: .large,
                title: Strings.MentionMe.Main.learnHow.localized,
                largeTextTitle: nil,
                icon: nil) {
                    viewModel.showMentionMeDashboard()
                }
        }
        .padding(.top)
        .padding(.horizontal, Constants.MentionMe.hPadding)
    }
}

#if DEBUG
struct LoyaltyView_Previews: PreviewProvider {
    static var previews: some View {
        LoyaltyView(viewModel: .init(
            container: .preview,
            profile: MemberProfile(
                uuid: "UUID-SOME-THING",
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
