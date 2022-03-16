//
//  TextFieldFloatingWithBorderViewModel.swift
//  SnappyV2
//
//  Created by David Bage on 08/03/2022.
//

import SwiftUI
import Combine

class TextFieldFloatingWithBorderViewModel: ObservableObject {
    @Binding var text: String
    @Binding var hasWarning: Bool
    @Published var isFocused: Bool
    @Published var isRevealed = false
    
    let title: String
    let isDisabled: Bool
    let isSecureField: Bool
    let disableAnimations: Bool
        
    var revealIcon: Image {
        isRevealed ? Image.Login.Password.hidePassword : Image.Login.Password.showPassword
    }
    
    init(title: String, text: Binding<String>, hasWarning: Binding<Bool> = .constant(false), isDisabled: Bool = false, isSecureField: Bool = false, disableAnimations: Bool = false, isFocused: Bool = false) {
        self.title = title
        self.isDisabled = isDisabled
        self.isSecureField = isSecureField
        self.disableAnimations = disableAnimations
        self.isFocused = isFocused

        if !isSecureField {
            isRevealed = true
        }
        
        _hasWarning = hasWarning
        _text = text
    }
    
    func toggleReveal() {
        isRevealed.toggle()
    }
    
    func focus(_ focus: Bool) {
        isFocused = focus
    }
}
