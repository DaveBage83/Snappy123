//
//  MissedPromotionsBanner.swift
//  SnappyV2
//
//  Created by David Bage on 17/01/2022.
//

import SwiftUI

struct MissedPromotionsBanner: View {
    @Environment(\.colorScheme) var colorScheme
    struct Constants {
        static let vPadding: CGFloat = 8
        static let hPadding: CGFloat = 8
        static let plusSize: CGFloat = 6.5
    }
    
    let container: DIContainer
    let text: String
    
    private var colorPalette: ColorPalette {
        ColorPalette(container: container, colorScheme: colorScheme)
    }
    
    var body: some View {
        HStack {
            Text(text)
                .foregroundColor(colorPalette.typefacePrimary)
                .font(.Body2.semiBold())
                
            Spacer()
            
            Image.Icons.Plus.heavy
                .renderingMode(.template)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .foregroundColor(colorPalette.typefacePrimary)
                .frame(width: Constants.plusSize)
        }
        .padding(.vertical, Constants.vPadding)
        .padding(.horizontal, Constants.hPadding)
        .frame(maxWidth: .infinity)
        .background(colorPalette.offer)
    }
}

#if DEBUG
struct MissedPromotionsBanner_Previews: PreviewProvider {
    static var previews: some View {
        MissedPromotionsBanner(container: .preview, text: "3 for 2 offer missed - take advantage and don't miss out on this")
    }
}
#endif
