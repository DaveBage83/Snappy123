//
//  MemberDashboardView.swift
//  SnappyV2
//
//  Created by David Bage on 18/03/2022.
//

import SwiftUI

struct MemberDashboardView: View {
    typealias MemberStrings = Strings.MemberDashboard
    typealias CustomMemberStrings = Strings.CustomMemberDashboard
    
    struct Constants {
        struct LogoutButton {
            static let padding: CGFloat = 10
        }
    }
    
    @StateObject var viewModel: MemberDashboardViewModel
    
    var body: some View {
        ScrollView {
            if viewModel.noMemberFound {
                LoginView(loginViewModel: .init(container: viewModel.container), socialLoginViewModel: .init(container: viewModel.container))
                
            } else {
                
                VStack {
                    dashboardHeaderView
                    mainContentView
                    Spacer()
                }
                .padding(.top)
            }
        }
        .displayError(viewModel.error)
    }
    
    @ViewBuilder var dashboardHeaderView: some View {
        VStack {
            if viewModel.firstNamePresent, let name = viewModel.profile?.firstname {
                Text(CustomMemberStrings.welcome.localizedFormat(name))
                    .font(.snappyTitle2)
                    .fontWeight(.semibold)
                    .foregroundColor(.snappyBlue)
            }
            
            MemberDashboardOptionsView(viewModel: viewModel)
        }
    }
    
    @ViewBuilder var mainContentView: some View {
        switch viewModel.viewState {
        case .dashboard:
            DashboardHomeView(viewModel: .init(container: viewModel.container))
            
        case .orders:
            MemberDashboardOrdersView(viewModel: .init(container: viewModel.container, categoriseOrders: true))
        case .addresses:
            MemberDashboardAddressView(viewModel: viewModel)
        case .profile:
            MemberDashboardProfileView(container: viewModel.container)
        case .loyalty:
            LoyaltyView(viewModel: .init(profile: viewModel.profile))
                .padding()
        case .logOut:
            VStack {
                Text(GeneralStrings.Logout.verify.localized)
                    .font(.snappyBody2)
                    .foregroundColor(.snappyTextGrey1)
                
                Spacer()
                
                Button {
                    viewModel.logOut()
                } label: {
                    if viewModel.loggingOut {
                        ProgressView().progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, Constants.LogoutButton.padding)
                    } else {
                        Text(GeneralStrings.Logout.title.localized)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, Constants.LogoutButton.padding)
                    }
                }
                .buttonStyle(SnappyPrimaryButtonStyle())
                
                Spacer()
            }
            .padding()
        }
    }
}

struct MemberDashboardView_Previews: PreviewProvider {
    static var previews: some View {
        MemberDashboardView(viewModel: .init(container: .preview))
    }
}
