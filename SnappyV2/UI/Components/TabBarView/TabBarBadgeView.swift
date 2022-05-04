//
//  TabBarBadge.swift
//  SnappyV2
//
//  Created by David Bage on 01/05/2022.
//

import SwiftUI

struct TabBarBadgeView: View {
    @Environment(\.colorScheme) var colorScheme
    
    struct Constants {
        static let width: CGFloat = 44
        static let height: CGFloat = 14
        static let cornerRadius: CGFloat = 8
    }
    
    var contentText: String
    let container: DIContainer
    
    var colorPalette: ColorPalette {
        ColorPalette(container: container, colorScheme: colorScheme)
    }
    
    var body: some View {
        Text(contentText)
            .frame(width: Constants.width, height: Constants.height)
            .font(.Caption1.semiBold())
            .background(colorPalette.alertSuccess)
            .cornerRadius(Constants.cornerRadius)
            .foregroundColor(colorPalette.secondaryWhite)
    }
}

struct TabBarBadge_Previews: PreviewProvider {
    static var previews: some View {
        TabBarBadgeView(contentText: "£3.20", container: .preview)
    }
}
