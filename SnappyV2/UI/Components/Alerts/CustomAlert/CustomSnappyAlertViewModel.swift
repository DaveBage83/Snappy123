//
//  CustomSnappyAlertViewModel.swift
//  SnappyV2
//
//  Created by David Bage on 09/01/2023.
//

import Foundation

class CustomSnappyAlertViewModel: ObservableObject {
    let container: DIContainer
    let title: String
    let prompt: String
    
    /// Optionally passed into CustomSnappyAlertView to present a textfield in the CustomSnappyAlert
    let textField: AlertTextField?
    let buttons: [AlertActionButton]?
    
    @Published var textfieldContent = ""
    
    var useVerticalButtonStack: Bool {
        guard let buttons else { return false }
        if let textField, let _ = textField.submitButton {
            return buttons.count > 1
        }
        
        return buttons.count > 2
    }
    
    var invalidFieldEntry: Bool {
        guard let textField, let minCharacters = textField.minCharacters else { return false }
        return textfieldContent.count < minCharacters
    }
    
    var totalButtons: Int {
        guard let buttons else { return 0 }
        
        if let textField, textField.submitButton != nil {
            return buttons.count + 1
        }
        
        return buttons.count
    }
    
    var noActionButtons: Bool {
        guard let buttons, buttons.count == 0 else { return false }
        return true
    }
    
    init(container: DIContainer, title: String, prompt: String, textField: AlertTextField? = nil, buttons: [AlertActionButton]?) {
        self.container = container
        self.title = title
        self.prompt = prompt.condensedWhitespace
        self.textField = textField
        self.buttons = buttons
    }

    func addDivider(buttonIndex: Int) -> Bool {
        if useVerticalButtonStack {
           return buttonIndex != totalButtons - 1
        }
        return buttonIndex == 0 && totalButtons == 2
    }
}
