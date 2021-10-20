//
//  FocusTextField.swift
//  SnappyV2
//
//  Created by Henrik Gustavii on 06/10/2021.
//

import SwiftUI

// Copied from: https://swiftuirecipes.com/blog/focus-change-in-securefield
struct FocusTextField: UIViewRepresentable {
    @Binding var text: String
    @Binding var isFocused: Bool
    
    func makeUIView(context: UIViewRepresentableContext<FocusTextField>) -> UITextField{
        let textfield = UITextField(frame: .zero)
        textfield.isUserInteractionEnabled = true
        textfield.delegate = context.coordinator
        return textfield
    }
    
    func makeCoordinator() -> FocusTextField.Coordinator {
        return Coordinator(text: $text, isFocused: $isFocused)
    }
    
    func updateUIView(_ uiView: UITextField, context: Context) {
        uiView.text = text
    }
    
    class Coordinator: NSObject, UITextFieldDelegate {
        @Binding var text: String
        @Binding var isFocused: Bool
        
        init(text: Binding<String>, isFocused: Binding<Bool>) {
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
            self.isFocused = false
            return false
        }
    }
}
