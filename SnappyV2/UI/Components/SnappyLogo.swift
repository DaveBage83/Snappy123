//
//  SnappyLogo.swift
//  SnappyV2
//
//  Created by David Bage on 02/08/2022.
//

import SwiftUI

struct SnappyLogo: View {
    @Environment(\.horizontalSizeClass) var sizeClass
    
    struct Constants {
        struct Logo {
            static let width: CGFloat = 207.25
            static let largeScreenWidthMultiplier: CGFloat = 1.5
        }
    }
    var body: some View {
        Image.Branding.Logo.inline
            .resizable()
            .scaledToFit()
            .frame(width: Constants.Logo.width * (sizeClass == .compact ? 1 : Constants.Logo.largeScreenWidthMultiplier))
    }
}

struct SnappyLogo_Previews: PreviewProvider {
    static var previews: some View {
        SnappyLogo()
    }
}
