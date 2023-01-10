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
    
    var longButtonText: Bool {
        guard let buttons else { return false }
        
        let buttonsWithLongText = buttons.filter { $0.title.count > 10 }
        
        var submitButtonHasLongText = false
        
        if let submitButton = textField?.submitButton {
            submitButtonHasLongText = submitButton.title.count > 10
        }
        
        return buttonsWithLongText.count > 0 || submitButtonHasLongText
    }
    
    var useVerticalButtonStack: Bool {
        guard let buttons else { return false }
        
        if longButtonText {
            return true
        }
        
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
        guard let buttons else { return true }
        
        return buttons.isEmpty
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
