//
//  MemberDashboardOptionsView.swift
//  SnappyV2
//
//  Created by David Bage on 18/03/2022.
//

import SwiftUI

struct MemberDashboardOptionsView: View {
    struct Constants {
        static let hPadding: CGFloat = 10
        static let tileSpacing: CGFloat = 17
    }
    
    @ObservedObject var viewModel: MemberDashboardViewModel
    
    var body: some View {
        VStack(spacing: Constants.tileSpacing) {
            HStack(spacing: Constants.tileSpacing) {
                MemberDashboardOptionButton(viewModel: .init(container: viewModel.container, optionType: .dashboard, action: {viewModel.dashboardTapped()}, isActive: viewModel.isDashboardSelected))
                MemberDashboardOptionButton(viewModel: .init(container: viewModel.container, optionType: .orders, action: {viewModel.ordersTapped()}, isActive: viewModel.isOrdersSelected))
                MemberDashboardOptionButton(viewModel: .init(container: viewModel.container, optionType: .myDetails, action: {viewModel.myDetailsTapped()}, isActive: (viewModel.isAddressesSelected)))
            }
            
            HStack(spacing: Constants.tileSpacing) {
                MemberDashboardOptionButton(viewModel: .init(container: viewModel.container, optionType: .profile, action: {viewModel.profileTapped()}, isActive: viewModel.isProfileSelected))
                MemberDashboardOptionButton(viewModel: .init(container: viewModel.container, optionType: .loyalty, action: {viewModel.loyaltyTapped()}, isActive: viewModel.isLoyaltySelected))
                MemberDashboardOptionButton(viewModel: .init(container: viewModel.container, optionType: .logOut, action: {viewModel.logOutTapped()}, isActive: viewModel.isLogOutSelected))
            }
            
            if viewModel.showDriverStartShiftOption {
                MemberDashboardOptionButton(
                    viewModel: .init(
                        container: viewModel.container,
                        optionType: .startDriverShift,
                        action: {
                            Task {
                                await viewModel.startDriverShiftTapped()
                            }
                        },
                        isActive: viewModel.isLogOutSelected,
                        isLoading: viewModel.driverSettingsLoading
                    )
                )
            }
            
            if viewModel.showVerifyAccountOption {
                MemberDashboardOptionButton(
                    viewModel: .init(
                        container: viewModel.container,
                        optionType: .verifyAccount,
                        action: {
                            Task {
                                await viewModel.verifyAccountTapped()
                            }
                        },
                        isActive: viewModel.isProfileSelected,
                        isLoading: viewModel.requestingVerifyCode
                    )
                )
            }
        }
    }
}

struct MemberDashboardOptionButton: View {
    @ScaledMetric var scale: CGFloat = 1 // Used to scale icon for accessibility options
    @Environment(\.colorScheme) var colorScheme

    struct Constants {
        static let iconSize: CGFloat = 32
        static let vPadding: CGFloat = 17
        static let stackSpacing: CGFloat = 8
        static let textHeight: CGFloat = 16
    }
    
    @ObservedObject var viewModel: MemberDashboardOptionsViewModel
    
    var icon: Image {
        switch viewModel.optionType {
        case .dashboard:
            return Image.Icons.House.standard
        case .orders:
            return Image.Icons.Receipt.standard
        case .myDetails:
            return Image.Icons.CircleUser.standard
        case .profile:
            return Image.Icons.CreditCard.standard
        case .loyalty:
            return Image.Icons.Piggy.standard
        case .logOut:
            return Image.Icons.Arrows.RightFromBracket.light
        case .startDriverShift:
            return Image.Icons.Truck.filled
        case .verifyAccount:
            return Image.Icons.VerifyMember.standard
        }
    }
    
    var colorPalette: ColorPalette {
        ColorPalette(container: viewModel.container, colorScheme: colorScheme)
    }
    
    var body: some View {
        Button {
            viewModel.action()
        } label: {
            VStack(spacing: Constants.stackSpacing) {
                
                if viewModel.isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: viewModel.isActive ? colorPalette.secondaryWhite : colorPalette.primaryBlue))
                        .frame(height: Constants.iconSize * scale)
                } else {
                    icon
                        .renderingMode(.template)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: Constants.iconSize * scale)
                        .foregroundColor(viewModel.isActive ? colorPalette.secondaryWhite : colorPalette.primaryBlue)
                }
                    
                Text(viewModel.title)
                    .foregroundColor(viewModel.isActive ? colorPalette.secondaryWhite : colorPalette.primaryBlue)
                    .font(.Body2.semiBold())
                    .frame(maxWidth: .infinity)
                    .frame(height: Constants.textHeight * scale)
            }
        }
        .padding(.vertical, Constants.vPadding)
        .background(viewModel.isActive ? colorPalette.primaryBlue : colorPalette.secondaryWhite)
        .standardCardFormat()
    }
}

#if DEBUG
struct MemberDashboardOptionsView_Previews: PreviewProvider {
    static var previews: some View {
        MemberDashboardOptionsView(viewModel: .init(container: .preview))
            .previewCases()
    }
}
#endif
