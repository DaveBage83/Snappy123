//
//  EmailField.swift
//  SnappyV2
//
//  Created by David Bage on 29/07/2022.
//

import SwiftUI

struct EmailField: View {
    @Environment(\.colorScheme) var colorScheme
    
    private struct Constants {
        struct EmailFieldWarning {
            static let xOffset: CGFloat = -6
            static let yOffset: CGFloat = 4
        }
    }
    
    let container: DIContainer
    @Binding var emailText: String
    @Binding var hasError: Bool
    @Binding var showInvalidEmailWarning: Bool
    
    private var colorPalette: ColorPalette {
        ColorPalette(container: container, colorScheme: colorScheme)
    }
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            SnappyTextfield(container: container, text: $emailText, hasError: $hasError, labelText: GeneralStrings.Login.emailAddress.localized, largeTextLabelText: nil, keyboardType: .emailAddress)

            if showInvalidEmailWarning {
                Text(Strings.CheckoutDetails.ContactDetails.emailInvalid.localized)
                    .font(.Caption2.semiBold())
                    .foregroundColor(colorPalette.primaryRed)
                    .offset(x: Constants.EmailFieldWarning.xOffset, y: Constants.EmailFieldWarning.yOffset)
            }
        }
    }
}

#if DEBUG
struct EmailField_Previews: PreviewProvider {
    static var previews: some View {
        EmailField(container: .preview, emailText: .constant("test@test.com"), hasError: .constant(false), showInvalidEmailWarning: .constant(false))
    }
}
#endif
