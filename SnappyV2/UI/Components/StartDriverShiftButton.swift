//
//  StartDriverShiftButton.swift
//  SnappyV2
//
//  Created by Kevin Palser on 27/07/2022.
//

import SwiftUI

struct StartDriverShiftButton: View {
    @Environment(\.colorScheme) var colorScheme
    
    struct Constants {
        struct Icon {
            static let size: CGFloat = 16
            static let borderRadius: CGFloat = 8
            static let borderLineWidth: CGFloat = 1
            static let borderLineStroke: CGFloat = 2
        }
        
        struct General {
            static let hSpacing: CGFloat = 9
            static let vPadding: CGFloat = 5
            static let hPadding: CGFloat = 4
        }
    }
    
    let container: DIContainer
    let action: () -> Void
    
    var colorPalette: ColorPalette {
        ColorPalette(container: container, colorScheme: colorScheme)
    }
    
    var body: some View {
        Button {
            action()
        } label: {
            HStack(spacing: Constants.General.hSpacing) {
                Image.Icons.Delivery.standard
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: Constants.Icon.size)
                    .foregroundColor(.snappyDark)
                Text(GeneralStrings.DriverInterface.startShift.localized)
                    .font(.Body1.regular())
                    .foregroundColor(colorPalette.typefacePrimary)
                    .fontWeight(.semibold)
            }
            .padding(.vertical, Constants.General.vPadding)
            .padding(.horizontal, Constants.General.hPadding)
        }
        .background(RoundedRectangle(cornerRadius: Constants.Icon.borderRadius).strokeBorder(style: StrokeStyle(lineWidth: Constants.Icon.borderLineWidth, dash: [Constants.Icon.borderLineStroke])).foregroundColor(colorPalette.typefacePrimary.withOpacity(.twenty)))
    }
}

#if DEBUG
struct StartDriverShiftButton_Previews: PreviewProvider {
    static var previews: some View {
        StartDriverShiftButton(container: .preview, action: {})
    }
}
#endif

