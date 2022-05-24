//
//  FocusTextField.swift
//  SnappyV2
//
//  Created by Henrik Gustavii on 06/10/2021.
//

import SwiftUI

// Copied from: https://swiftuirecipes.com/blog/focus-change-in-securefield
struct FocusTextField: UIViewRepresentable {
    
    struct Constants {
        static let font = UIFont(name: "Montserrat-Regular", size: 14)
    }

    @Binding var text: String
    @Binding var isEnabled: Bool
    @Binding var isRevealed: Bool
    @Binding var isFocused: Bool
    let placeholder: String?
    let keyboardType: UIKeyboardType?
    let autoCaps: UITextAutocapitalizationType?

    func makeUIView(context: UIViewRepresentableContext<FocusTextField>) -> UITextField {
        let tf = UITextField(frame: .zero)
        tf.isUserInteractionEnabled = true
        tf.delegate = context.coordinator
        tf.font = Constants.font
        tf.keyboardType = keyboardType ?? .default
        tf.autocapitalizationType = .none

        if let placeholder = placeholder {
            tf.placeholder = placeholder
        }
        return tf
    }

    func makeCoordinator() -> FocusTextField.Coordinator {
        return Coordinator(text: $text, isEnabled: $isEnabled, isFocused: $isFocused)
    }

    func updateUIView(_ uiView: UITextField, context: Context) {
        uiView.text = text
        uiView.isSecureTextEntry = !isRevealed
    }

    class Coordinator: NSObject, UITextFieldDelegate {
        @Binding var text: String
        @Binding var isFocused: Bool

        init(text: Binding<String>, isEnabled: Binding<Bool>, isFocused: Binding<Bool>, placeholder: String? = nil) {
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
