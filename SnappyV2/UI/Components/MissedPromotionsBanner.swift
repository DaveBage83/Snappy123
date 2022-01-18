//
//  MissedPromotionsBanner.swift
//  SnappyV2
//
//  Created by David Bage on 17/01/2022.
//

import SwiftUI

struct MissedPromotionsBanner: View {
    struct Constants {
        static let vPadding: CGFloat = 5
        static let hPadding: CGFloat = 8
        static let arrowSize: CGFloat = 13
    }
    
    let text: String
    var body: some View {
        HStack {
            Text(text)
                .foregroundColor(.white)
                .font(.snappyCaption2.weight(.semibold))
                
            Spacer()
            
            Image.General.rightArrow
                .foregroundColor(.white)
                .font(.system(size: Constants.arrowSize))
        }
        .padding(.vertical, Constants.vPadding)
        .padding(.horizontal, Constants.hPadding)
        .frame(maxWidth: .infinity)
        .background(Color.snappyOfferBasket)
    }
}

struct MissedPromotionsBanner_Previews: PreviewProvider {
    static var previews: some View {
        MissedPromotionsBanner(text: "3 for 2 offer missed - take advantage and don't miss out on this")
    }
}
