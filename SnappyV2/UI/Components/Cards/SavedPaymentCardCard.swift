//
//  SavedPaymentCardCard.swift
//  SnappyV2
//
//  Created by David Bage on 25/07/2022.
//

import SwiftUI

enum PaymentCardType {
    case visa
    case masterCard
    case jcb
    case discover
    case amex
    
    var logo: Image {
        switch self {
        case .visa:
            return Image.PaymentCards.visa
        case .masterCard:
            return Image.PaymentCards.masterCard
        case .jcb:
            return Image.PaymentCards.jcb
        case .discover:
            return Image.PaymentCards.discover
        case .amex:
            return Image.PaymentCards.amex
        }
    }
}

class SavedPaymentCardCardViewModel: ObservableObject {
    let container: DIContainer
    let card: MemberCardDetails
    
    var formattedCardString: String {
        "**** **** **** " + card.last4
    }
    
    var cardType: PaymentCardType? {
        if card.scheme?.lowercased() == "visa" {
            return .visa
        } else if card.scheme?.lowercased() == "mastercard" {
            return .masterCard
        } else if card.scheme?.lowercased() == "jcb" {
            return .jcb
        } else if card.scheme?.lowercased() == "discover" {
            return .discover
        } else if card.scheme?.lowercased() == "amex" {
            return .amex
        } else { return nil }
    }
    
    var expiryYear: Int {
        return card.expiryYear-2000
    }
    
    init(container: DIContainer, card: MemberCardDetails) {
        self.container = container
        self.card = card
    }
}

struct SavedPaymentCardCard: View {
    @Environment(\.colorScheme) var colorScheme
    @StateObject var viewModel: SavedPaymentCardCardViewModel
    
    private struct Constants {
        static let hSpacing: CGFloat = 33
        static let height: CGFloat = 94
        static let cardTypeLogoHeight: CGFloat = 20
    }
    
    private var colorPalette: ColorPalette {
        ColorPalette(container: viewModel.container, colorScheme: colorScheme)
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                if let logo = viewModel.cardType?.logo {
                    logo
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: Constants.cardTypeLogoHeight)
                }
                
                if viewModel.card.isDefault {
                    IsDefaultLabelView(container: viewModel.container)
                }
            }
            
            HStack(spacing: Constants.hSpacing) {
                Text(viewModel.formattedCardString)
                
                Text("\(viewModel.card.expiryMonth)/\(viewModel.expiryYear)")
            }
            .font(.Body1.regular())
            .foregroundColor(colorPalette.typefacePrimary)
        }
    }
}

#if DEBUG
struct SavedPaymentCardCard_Previews: PreviewProvider {
    static var previews: some View {
        SavedPaymentCardCard(viewModel: .init(container: .preview, card: MemberCardDetails(id: "", isDefault: true, expiryMonth: 04, expiryYear: 2025, scheme: "mastercard", last4: "4242")))
    }
}
#endif
