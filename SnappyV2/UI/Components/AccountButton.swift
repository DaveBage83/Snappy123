//
//  AccountButton.swift
//  SnappyV2
//
//  Created by David Bage on 18/03/2022.
//

import SwiftUI

struct AccountButton: View {
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
                Image.Icons.User.standard
                    .renderingMode(.template)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: Constants.Icon.size)
                    .foregroundColor(colorPalette.typefaceDarkInvert)
                Text(container.appState.value.userData.memberProfile == nil ? GeneralStrings.Login.login.localized : Strings.RootView.Tabs.account.localized)
                    .font(.Body1.regular())
                    .foregroundColor(colorPalette.typefaceDarkInvert)
                    .fontWeight(.semibold)
                    .padding(.vertical, Constants.General.vPadding)
                    .padding(.horizontal, Constants.General.hPadding)
            }
        }
        .background(RoundedRectangle(cornerRadius: Constants.Icon.borderRadius).strokeBorder(style: StrokeStyle(lineWidth: Constants.Icon.borderLineWidth, dash: [Constants.Icon.borderLineStroke])).foregroundColor(colorPalette.typefacePrimary.withOpacity(.twenty)))
    }
}

#if DEBUG
struct AccountButton_Previews: PreviewProvider {
    static var previews: some View {
        AccountButton(container: .preview, action: {})
    }
}
#endif
