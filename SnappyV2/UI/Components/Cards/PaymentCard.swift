//
//  PaymentCard.swift
//  SnappyV2
//
//  Created by David Bage on 13/05/2022.
//

import SwiftUI

struct PaymentCard: View {
    @ScaledMetric var scale: CGFloat = 1 // Used to scale icon for accessibility options
    @Environment(\.colorScheme) var colorScheme
    
    typealias PaymentStrings = Strings.PayMethods
    
    struct Constants {
        static let padding: CGFloat = 16
        static let height: CGFloat = 72
        static let width: CGFloat = 343
        static let stackSpacing: CGFloat = 16.68
        static let textHeight: CGFloat = 24
    }
    
    enum PaymentMethod {
        case card
        case cash
        case apple
        
        var icon: Image {
            switch self {
            case .card:
                return Image.Icons.CreditCard.standard
            case .cash:
                return Image.Icons.MoneyBill.standard
            case .apple:
                return Image.PaymentMethods.applePay
            }
        }
        
        var iconWidth: CGFloat {
            switch self {
            case .cash, .card:
                return 32
            case .apple:
                return 30.63
            }
        }
        
        var title: String {
            switch self {
            case .card:
                return PaymentStrings.Card.title.localized
            case .cash:
                return PaymentStrings.Cash.title.localized
            case .apple:
                return PaymentStrings.Apple.title.localized
            }
        }
        
        var subTitle: String {
            switch self {
            case .card:
                return PaymentStrings.Card.subtitle.localized
            case .cash:
                return PaymentStrings.Cash.subtitle.localized
            case .apple:
                return PaymentStrings.Apple.subtitle.localized
            }
        }
    }
    
    var colorPalette: ColorPalette {
        ColorPalette(container: container, colorScheme: colorScheme)
    }
    
    let container: DIContainer
    let paymentMethod: PaymentMethod
    var disabled = false
    
    var body: some View {
        HStack(spacing: Constants.stackSpacing * scale) {
            paymentMethod.icon
                .renderingMode(.template)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: paymentMethod.iconWidth * scale)
                .foregroundColor(disabled ? colorPalette.textGrey2 : colorPalette.textBlack)
            VStack(alignment: .leading, spacing: 0) {
                Text(paymentMethod.title)
                    .font(.heading4())
                    .frame(height: Constants.textHeight * scale)
                    .foregroundColor(disabled ? colorPalette.textGrey2 : colorPalette.textBlack)
                Text(paymentMethod.subTitle)
                    .font(.Body2.regular())
                    .frame(height: Constants.textHeight * scale)
                    .foregroundColor(disabled ? colorPalette.textGrey2 : colorPalette.textGrey1)
            }
            Spacer()
        }
        .frame(width: Constants.width * scale, height: Constants.height * scale)
        .padding(Constants.padding)
        .background(disabled ? colorPalette.textGrey4 : colorPalette.secondaryWhite)
        .standardCardCornerRadius()
        .cardShadow()
    }
}

struct PaymentCard_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            PaymentCard(container: .preview, paymentMethod: .apple)
            PaymentCard(container: .preview, paymentMethod: .card)
            PaymentCard(container: .preview, paymentMethod: .cash)
            
            PaymentCard(container: .preview, paymentMethod: .apple, disabled: true)
            PaymentCard(container: .preview, paymentMethod: .card, disabled: true)
            PaymentCard(container: .preview, paymentMethod: .cash, disabled: true)
            
            PaymentCard(container: .preview, paymentMethod: .apple)
                .environment(\.sizeCategory, .accessibilityExtraExtraExtraLarge)
        }
    }
}
