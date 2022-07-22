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

    func makeUIView(context: UIViewRepresentableContext<FocusTextField>) -> UITextField {
        let tf = UITextField(frame: .zero)
        tf.isUserInteractionEnabled = true
        tf.delegate = context.coordinator
        tf.keyboardType = keyboardType ?? .default
        tf.autocapitalizationType = .none
        tf.adjustsFontForContentSizeCategory = true
        tf.font = .body1Regular
        tf.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        
        return tf
    }

    func makeCoordinator() -> FocusTextField.Coordinator {
        return Coordinator(text: $text, isEnabled: $isEnabled, isFocused: $isFocused)
    }

    func updateUIView(_ uiView: UITextField, context: Context) {
        uiView.text = text
        uiView.isSecureTextEntry = !isRevealed
        uiView.placeholder = isFocused == false ? "" : sizeCategory.size < 8 ? placeholder : largeTextPlaceholder
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
