//
//  LoginCard.swift
//  SnappyV2
//
//  Created by David Bage on 13/05/2022.
//

import SwiftUI

struct UserStatusCard: View {
    @Environment(\.colorScheme) var colorScheme
    
    typealias CheckoutStrings = Strings.CheckoutView
    
    struct Constants {
        struct Icon {
            static let height: CGFloat = 24
        }
        
        struct Text {
            static let height: CGFloat = 24
        }
    
        struct HStack {
            static let spacing: CGFloat = 17.5
        }
        
        struct General {
            static let height: CGFloat = 72
            static let vPadding: CGFloat = 16
            static let hPadding: CGFloat = 17.5
        }
        
        struct Chevron {
            static let height: CGFloat = 14
        }
    }
    
    enum CheckoutType {
        case guest
        case member
        
        var title: String {
            switch self {
            case .guest:
                return CheckoutStrings.GuestCheckoutCard.guest.localized
            case .member:
                return CheckoutStrings.LoginToAccount.login.localized
            }
        }
        
        var subtitle: String {
            switch self {
            case .guest:
                return CheckoutStrings.GuestCheckoutCard.noTies.localized
            case .member:
                return CheckoutStrings.LoginToAccount.earnPoints.localized
            }
        }
    }
    
    let container: DIContainer
    let checkoutType: CheckoutType
    
    var colorPalette: ColorPalette {
        ColorPalette(container: container, colorScheme: colorScheme)
    }
    
    var body: some View {
        HStack(spacing: Constants.HStack.spacing) {
            Image.Icons.User.standard
                .renderingMode(.template)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: Constants.Icon.height)
            VStack(alignment: .leading, spacing: 0) {
                Text(checkoutType.title)
                    .font(.heading4())
                    .foregroundColor(colorPalette.primaryBlue)
                    .frame(height: Constants.Text.height)
                Text(checkoutType.subtitle)
                    .font(.Body2.regular())
                    .foregroundColor(colorPalette.textGrey1)
                    .frame(height: Constants.Text.height)
            }
            
            Spacer()
            
            Image.Icons.Chevrons.Right.heavy
                .renderingMode(.template)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: Constants.Chevron.height)
        }
        .frame(height: Constants.General.height)
        .padding(.vertical, Constants.General.vPadding)
        .padding(.horizontal, Constants.General.hPadding)
        .background(colorPalette.secondaryWhite)
        .standardCardFormat()
    }
}

#if DEBUG
struct LoginCard_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            UserStatusCard(container: .preview, checkoutType: .guest)
            UserStatusCard(container: .preview, checkoutType: .member)
        }
    }
}
#endif
