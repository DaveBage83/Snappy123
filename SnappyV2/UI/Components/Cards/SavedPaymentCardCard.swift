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

struct SavedCard {
    let id: Int
    let cardNumber: String
    let expiry: String
    let isDefault: Bool
    let type: PaymentCardType
}

class SavedPaymentCardCardViewModel: ObservableObject {
    let container: DIContainer
    let card: SavedCard
    
    var formattedCardString: String {
        card.cardNumber.unfoldSubSequences(limitedTo: 4).joined(separator: " ")
    }
    
    var maskedString: String {
        return card.cardNumber.cardNumberFormat
    }
    
    var showIsDefaultLabel: Bool {
        card.isDefault
    }
    
    init(container: DIContainer, card: SavedCard) {
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
                viewModel.card.type.logo
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: Constants.cardTypeLogoHeight)
                
                if viewModel.showIsDefaultLabel {
                    IsDefaultLabelView(container: viewModel.container)
                }
            }
            
            HStack(spacing: Constants.hSpacing) {
                Text(viewModel.maskedString)
                
                Text(viewModel.card.expiry)
            }
            .font(.Body1.regular())
            .foregroundColor(colorPalette.typefacePrimary)
        }
    }
}

#if DEBUG
struct SavedPaymentCardCard_Previews: PreviewProvider {
    static var previews: some View {
        SavedPaymentCardCard(viewModel: .init(container: .preview, card: SavedCard(id: 123, cardNumber: "4556685578559665", expiry: "04/25", isDefault: true, type: .visa)))
    }
}
#endif
