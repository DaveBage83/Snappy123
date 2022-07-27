//
//  IsDefaultLabelView.swift
//  SnappyV2
//
//  Created by David Bage on 25/07/2022.
//

import SwiftUI

struct IsDefaultLabelView: View {
    @Environment(\.colorScheme) var colorScheme
    
    private struct Constants {
        static let iconWidth: CGFloat = 16
    }
    
    let container: DIContainer
    
    private var colorPalette: ColorPalette {
        ColorPalette(container: container, colorScheme: colorScheme)
    }
    
    var body: some View {
        HStack {
            Image.Icons.CircleCheck.filled
                .renderingMode(.template)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: Constants.iconWidth)
            .foregroundColor(colorPalette.primaryBlue)
            
            Text("(Default)")
                .font(.Caption1.semiBold())
                .foregroundColor(colorPalette.primaryBlue)
        }
    }
}

struct IsDefaultLabelView_Previews: PreviewProvider {
    static var previews: some View {
        IsDefaultLabelView(container: .preview)
    }
}
