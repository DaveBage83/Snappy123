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
    
    @StateObject var viewModel: MemberDashboardViewModel
    
    var body: some View {
        ScrollView {
            VStack {
                if viewModel.noMemberFound {
                    // We should never be here as account button is only visible when member signed in, so we should always have a profile
                    Spacer()
                    #warning("This warning is temporary - awaiting designs")
                    Text(Strings.MemberDashboard.errorFindingAccount.localized)
                        .foregroundColor(.snappyRed)
                        .padding()
                } else {
                    dashboardHeaderView
                    mainContentView
                }
                Spacer()
            }
        }
        .padding(.top)
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
            DashboardHomeView(viewModel: .init(container: viewModel.container, profile: viewModel.profile))
        case .orders:
            Text("Orders view here")
        case .addresses:
            Text("Addresses view here")
        case .profile:
            Text("Profile view here")

        case .loyalty:
            LoyaltyView(viewModel: .init(profile: viewModel.profile))
                .padding()
        case .logOut:
            #warning("This is temporary - log out flow not yet implemented")
            Button {
                viewModel.logOut()
            } label: {
                Text("Log out")
            }

        }
    }
}

struct MemberDashboardView_Previews: PreviewProvider {
    static var previews: some View {
        MemberDashboardView(viewModel: .init(container: .preview))
    }
}
