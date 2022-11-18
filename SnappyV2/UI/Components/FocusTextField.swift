//
//  FocusTextField.swift
//  SnappyV2
//
//  Created by Henrik Gustavii on 06/10/2021.
//

import SwiftUI

// Copied from: https://swiftuirecipes.com/blog/focus-change-in-securefield
struct FocusTextField: UIViewRepresentable {
    @ScaledMetric var scale: CGFloat = 1 // Used to scale icon for accessibility options
    @Environment(\.sizeCategory) var sizeCategory: ContentSizeCategory

    @Binding var text: String
    @Binding var isEnabled: Bool
    @Binding var isRevealed: Bool
    @Binding var isFocused: Bool
    let placeholder: String?
    let largeTextPlaceholder: String?
    let keyboardType: UIKeyboardType?
    let autoCaps: UITextAutocapitalizationType?
    let spellCheckingEnabled: Bool

    func makeUIView(context: UIViewRepresentableContext<FocusTextField>) -> UITextField {
        let tf = TextFieldWithPadding(frame: .zero)
        tf.isUserInteractionEnabled = true
        tf.delegate = context.coordinator
        tf.keyboardType = keyboardType ?? .default
        tf.autocorrectionType = spellCheckingEnabled ? .default : .no
        tf.autocapitalizationType = autoCaps ?? .none
        tf.font =  .body1Regular
        tf.adjustsFontForContentSizeCategory = true
        tf.font = UIFontMetrics(forTextStyle: .body).scaledFont(for: .body1Regular ?? .systemFont(ofSize: 14))
        tf.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        
        return tf
    }

    func makeCoordinator() -> FocusTextField.Coordinator {
        return Coordinator(text: $text, isEnabled: $isEnabled, isFocused: $isFocused)
    }

    func updateUIView(_ uiView: UITextField, context: Context) {
        uiView.text = text
        uiView.isSecureTextEntry = !isRevealed
        uiView.placeholder = sizeCategory.size < 8 ? placeholder : largeTextPlaceholder
    }

    class Coordinator: NSObject, UITextFieldDelegate {
        @Binding var text: String
        @Binding var isFocused: Bool

        init(text: Binding<String>, isEnabled: Binding<Bool>, isFocused: Binding<Bool>, placeholder: String? = nil, largeTextPlaceholder: String? = nil) {
            _text = text
            _isFocused = isFocused
        }

        func textFieldDidChangeSelection(_ textField: UITextField) {
            text = textField.text ?? ""
        }

        func textFieldDidBeginEditing(_ textField: UITextField) {
            DispatchQueue.main.async {
               self.isFocused = true
            }
        }

        func textFieldDidEndEditing(_ textField: UITextField) {
            DispatchQueue.main.async {
                self.isFocused = false
            }
        }

        func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            textField.resignFirstResponder()
            return false
        }
    }
}

// Used to add padding to the textfield in order to align with floating label
class TextFieldWithPadding: UITextField {
    var textPadding = UIEdgeInsets(
        top: 0,
        left: 0,
        bottom: 0,
        right: 10
    )

    override func textRect(forBounds bounds: CGRect) -> CGRect {
        let rect = super.textRect(forBounds: bounds)
        return rect.inset(by: textPadding)
    }

    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        let rect = super.editingRect(forBounds: bounds)
        return rect.inset(by: textPadding)
    }
}
