//
//  SpecialOfferPill.swift
//  SnappyV2
//
//  Created by David Bage on 10/01/2022.
//

import SwiftUI

struct SpecialOfferPill: View {
    @Environment(\.colorScheme) var colorScheme
    
    enum Size {
        case large
        case small
        
        var font: Font {
            switch self {
            case .large:
                return .Body2.semiBold()
            case .small:
                return .Caption1.semiBold()
            }
        }
    }
    
    enum PillType {
        case chip
        case text
    }
    
    let container: DIContainer
    let offerText: String
    let type: PillType
    let size: Size
    
    var colorPalette: ColorPalette {
        ColorPalette(container: container, colorScheme: colorScheme)
    }
    
    struct Constants {
        static let cornerRadius: CGFloat = 20
        static let hPadding: CGFloat = 16
        static let vPadding: CGFloat = 4
    }
    
    var body: some View {
        Text(offerText)
            .padding(.horizontal, type == .chip ? Constants.hPadding : 0)
            .padding(.vertical, type == .chip ? Constants.vPadding : 0)
            .background(type == .chip ? colorPalette.primaryRed : colorPalette.typefaceInvert)
            .clipShape(RoundedRectangle(cornerRadius: Constants.cornerRadius))
            .foregroundColor(type == .chip ? colorPalette.typefaceInvert : colorPalette.primaryRed)
            .font(size.font)
    }
}

struct SpecialOfferPill_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            SpecialOfferPill(container: .preview, offerText: "2 for £7.00", type: .chip, size: .large)
            SpecialOfferPill(container: .preview, offerText: "2 for £7.00", type: .chip, size: .small)
            SpecialOfferPill(container: .preview, offerText: "2 for £7.00", type: .text, size: .large)
            SpecialOfferPill(container: .preview, offerText: "2 for £7.00", type: .text, size: .small)
                
            SpecialOfferPill(container: .preview, offerText: "2 for £7.00", type: .chip, size: .large)
                .environment(\.sizeCategory, .accessibilityExtraExtraExtraLarge)
        }
    }
}
