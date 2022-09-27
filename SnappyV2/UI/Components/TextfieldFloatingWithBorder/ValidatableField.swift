//
//  EmailField.swift
//  SnappyV2
//
//  Created by David Bage on 29/07/2022.
//

import SwiftUI

struct ValidatableField: View {
    @Environment(\.colorScheme) var colorScheme
    
    private struct Constants {
        struct FieldWarning {
            static let xOffset: CGFloat = -6
            static let yOffset: CGFloat = 4
        }
    }
    
    let container: DIContainer
    let labelText: String
    let largeLabelText: String?
    let warningText: String
    let keyboardType: UIKeyboardType
    
    @Binding var fieldText: String
    @Binding var hasError: Bool
    @Binding var showInvalidFieldWarning: Bool
    
    private var colorPalette: ColorPalette {
        ColorPalette(container: container, colorScheme: colorScheme)
    }
    
    init(container: DIContainer, labelText: String, largeLabelText: String?, warningText: String, keyboardType: UIKeyboardType?, fieldText: Binding<String>, hasError: Binding<Bool>, showInvalidFieldWarning: Binding<Bool>) {
        self.container = container
        self.labelText = labelText
        self.largeLabelText = largeLabelText
        self.warningText = warningText
        self.keyboardType = keyboardType ?? .default
        self._fieldText = fieldText
        self._hasError = hasError
        self._showInvalidFieldWarning = showInvalidFieldWarning
    }
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            SnappyTextfield(container: container, text: $fieldText, hasError: $hasError, labelText: labelText, largeTextLabelText: largeLabelText, keyboardType: keyboardType)

            if showInvalidFieldWarning {
                Text(warningText)
                    .font(.Caption2.semiBold())
                    .foregroundColor(colorPalette.primaryRed)
                    .offset(x: Constants.FieldWarning.xOffset, y: Constants.FieldWarning.yOffset)
            }
        }
    }
}

#if DEBUG
struct EmailField_Previews: PreviewProvider {
    static var previews: some View {
        ValidatableField(container: .preview, labelText: "Email Address", largeLabelText: nil, warningText: "Invalid field", keyboardType: .emailAddress, fieldText: .constant("test@test.com"), hasError: .constant(false), showInvalidFieldWarning: .constant(false))
    }
}
#endif
