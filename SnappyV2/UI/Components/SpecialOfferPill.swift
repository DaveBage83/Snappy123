//
//  SpecialOfferPill.swift
//  SnappyV2
//
//  Created by David Bage on 10/01/2022.
//

import SwiftUI

struct SpecialOfferPill: View {
    let offerText: String
    
    struct Constants {
        static let cornerRadius: CGFloat = 20
        static let hPadding: CGFloat = 10
        static let vPadding: CGFloat = 5
    }
    
    var body: some View {
        Text(offerText)
            .padding(.horizontal, Constants.hPadding)
            .padding(.vertical, Constants.vPadding)
            .background(Color.snappyRed)
            .clipShape(RoundedRectangle(cornerRadius: Constants.cornerRadius))
            .foregroundColor(.white)
            .font(.snappyCaption2.weight(.semibold))
    }
}

struct SpecialOfferPill_Previews: PreviewProvider {
    static var previews: some View {
        SpecialOfferPill(offerText: "2 for £7.00")
    }
}
