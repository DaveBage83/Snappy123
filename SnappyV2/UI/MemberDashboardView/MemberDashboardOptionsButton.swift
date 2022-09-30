//
//  MemberDashboardOptionsButton.swift
//  SnappyV2
//
//  Created by David Bage on 30/09/2022.
//

import SwiftUI

struct MemberDashboardOptionsButton: View {
    @ScaledMetric var scale: CGFloat = 1 // Used to scale icon for accessibility options
    @Environment(\.colorScheme) var colorScheme
    
    struct Constants {
        static let iconSize: CGFloat = 32
        static let vPadding: CGFloat = 17
        static let stackSpacing: CGFloat = 8
        static let textHeight: CGFloat = 16
        static let minFontScale: CGFloat = 0.7
        static let textHPadding: CGFloat = 5
    }
    
    @ObservedObject var viewModel: MemberDashboardViewModel
    let option: MemberDashboardViewModel.OptionType
    
    var icon: Image {
        switch option {
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
    
    var isActive: Bool {
        viewModel.viewState == option
    }
    
    var colorPalette: ColorPalette {
        ColorPalette(container: viewModel.container, colorScheme: colorScheme)
    }
    
    var body: some View {
        Button {
            viewModel.switchState(to: option)
        } label: {
            VStack(spacing: Constants.stackSpacing) {
                icon
                    .renderingMode(.template)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: Constants.iconSize * scale)
                    .foregroundColor(isActive ? colorPalette.secondaryWhite : colorPalette.primaryBlue)
                
                Text(option.title)
                    .foregroundColor(isActive ? colorPalette.secondaryWhite : colorPalette.primaryBlue)
                    .font(.Body2.semiBold())
                    .frame(maxWidth: .infinity)
                    .minimumScaleFactor(Constants.minFontScale)
                    .frame(height: Constants.textHeight * scale)
                    .padding(.horizontal, Constants.textHPadding)
            }
        }
        .padding(.vertical, Constants.vPadding)
        .background(isActive ? colorPalette.primaryBlue : colorPalette.secondaryWhite)
        .standardCardFormat()
    }
}

#if DEBUG
struct MemberDashboardOptionsButton_Previews: PreviewProvider {
    static var previews: some View {
        MemberDashboardOptionsButton(viewModel: .init(container: .preview), option: .dashboard)
    }
}
#endif
