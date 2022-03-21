//
//  DashboardOptionsView.swift
//  SnappyV2
//
//  Created by David Bage on 18/03/2022.
//

import SwiftUI

struct MemberDashboardOptionsView: View {
    struct Constants {
        static let hPadding: CGFloat = 10
    }
    
    @ObservedObject var viewModel: MemberDashboardViewModel
    
    var body: some View {
        VStack {
            HStack {
                MemberDashboardOptionButton(viewModel: .init(.dashboard, action: viewModel.dashboardTapped, isActive: viewModel.isDashboardSelected))
                MemberDashboardOptionButton(viewModel: .init(.orders, action: viewModel.ordersTapped, isActive: viewModel.isOrdersSelected))
                MemberDashboardOptionButton(viewModel: .init(.addresses, action: viewModel.addressesTapped, isActive: (viewModel.isAddressesSelected)))
            }
            
            HStack {
                MemberDashboardOptionButton(viewModel: .init(.profile, action: viewModel.profileTapped, isActive: viewModel.isProfileSelected))
                MemberDashboardOptionButton(viewModel: .init(.loyalty, action: viewModel.loyaltyTapped, isActive: viewModel.isLoyaltySelected))
                MemberDashboardOptionButton(viewModel: .init(.logOut, action: viewModel.logOutTapped, isActive: viewModel.isLogOutSelected))
            }
        }
        .padding(.horizontal, Constants.hPadding)
    }
}

struct MemberDashboardOptionButton: View {
    struct Constants {
        static let cornerRadius: CGFloat = 10
        static let iconSize: CGFloat = 30
        static let vPadding: CGFloat = 2
    }
    
    @ObservedObject var viewModel: MemberDashboardOptionsViewModel
    
    var body: some View {
        Button {
            viewModel.action()
        } label: {
            VStack {
                icon
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: Constants.iconSize)
                    .foregroundColor(viewModel.isActive ? .white : .snappyBlue)
                    .padding(.bottom, Constants.vPadding)
                    
                Text(viewModel.title)
                    .foregroundColor(viewModel.isActive ? .white : .snappyBlue)
                    .font(.snappyBody2)
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
            }
        }
        .padding()
        .background(viewModel.isActive ? Color.snappyBlue : Color.white)
        .cornerRadius(Constants.cornerRadius)

        .snappyShadow()
    }
    
    var icon: Image {
        switch viewModel.optionType {
        case .dashboard:
            return Image.MemberDashboard.Options.dashboard
        case .orders:
            return Image.MemberDashboard.Options.orders
        case .addresses:
            return Image.MemberDashboard.Options.addresses
        case .profile:
            return Image.MemberDashboard.Options.profile
        case .loyalty:
            return Image.MemberDashboard.Options.loyalty
        case .logOut:
            return Image.MemberDashboard.Options.logOut
        }
    }
}

struct MemberDashboardOptionsView_Previews: PreviewProvider {
    static var previews: some View {
        MemberDashboardOptionsView(viewModel: .init(container: .preview))
    }
}
