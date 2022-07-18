//
//  LoginCard.swift
//  SnappyV2
//
//  Created by David Bage on 13/05/2022.
//

import SwiftUI

struct UserStatusCard: View {
    @Environment(\.colorScheme) var colorScheme
    @ScaledMetric var scale: CGFloat = 1 // Used to scale icon for accessibility options
    @Environment(\.sizeCategory) var sizeCategory: ContentSizeCategory
    @Environment(\.horizontalSizeClass) var sizeClass

    typealias CheckoutStrings = Strings.CheckoutView
    
    enum ActionType {
        case guestCheckout
        case login
        case createAccount
        
        var title: String {
            switch self {
            case .guestCheckout:
                return CheckoutStrings.GuestCheckoutCard.guest.localized
            case .login:
                return CheckoutStrings.LoginToAccount.login.localized.capitalizingFirstLetterOnly()
            case .createAccount:
                return Strings.CreateAccount.newTitle.localized
            }
        }
        
        var subtitle: String {
            switch self {
            case .guestCheckout:
                return CheckoutStrings.GuestCheckoutCard.noTies.localized
            case .login:
                return CheckoutStrings.LoginToAccount.earnPoints.localized
            case .createAccount:
                return CheckoutStrings.CreateAccount.subtitle.localized
            }
        }
        
        var icon: Image {
            switch self {
            case .guestCheckout:
                return Image.Icons.PersonWalking.standard
            case .login:
                return Image.Icons.User.standard
            case .createAccount:
                return Image.Icons.UserPlus.standard
            }
        }
    }
    
    struct Constants {
        struct Icon {
            static let height: CGFloat = 24
            static let containerWidth: CGFloat = 20
        }
        
        struct Text {
            static let height: CGFloat = 24
            static let spacing: CGFloat = 5
        }
    
        struct HStack {
            static let spacing: CGFloat = 17.5
        }
        
        struct General {
            static let hPadding: CGFloat = 17.5
            static let minimalLayoutThreshold: Int = 7
        }
        
        struct Chevron {
            static let height: CGFloat = 14
        }
    }
    
    let container: DIContainer
    let actionType: ActionType
    
    private var colorPalette: ColorPalette {
        ColorPalette(container: container, colorScheme: colorScheme)
    }
    
    private var minimalLayout: Bool {
        sizeCategory.size > Constants.General.minimalLayoutThreshold && sizeClass == .compact
    }
    
    var body: some View {
        HStack(spacing: Constants.HStack.spacing) {
            if minimalLayout == false {
                ZStack {
                    actionType.icon
                        .renderingMode(.template)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: Constants.Icon.height * scale)
                        .foregroundColor(colorPalette.typefacePrimary)
                }
                .frame(width: Constants.Icon.containerWidth * scale)
            }
            
            VStack(alignment: .leading, spacing: Constants.Text.spacing) {
                Text(actionType.title)
                    .font(.heading4())
                    .foregroundColor(colorPalette.primaryBlue)
                    .multilineTextAlignment(.leading)
                Text(actionType.subtitle)
                    .font(.Body2.regular())
                    .foregroundColor(colorPalette.typefacePrimary)
                    .multilineTextAlignment(.leading)
            }
            
            Spacer()
            
            if minimalLayout == false {
                Image.Icons.Chevrons.Right.medium
                    .renderingMode(.template)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: Constants.Chevron.height * scale)
                    .foregroundColor(colorPalette.typefacePrimary)
            }
        }
        .padding(.vertical)
        .padding(.horizontal, Constants.General.hPadding)
        .background(colorPalette.secondaryWhite)
        .standardCardFormat()
    }
}

#if DEBUG
struct LoginCard_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            UserStatusCard(container: .preview, actionType: .guestCheckout)
            UserStatusCard(container: .preview, actionType: .login)
            UserStatusCard(container: .preview, actionType: .createAccount)
        }
    }
}
#endif
