//
//  CustomSnappyAlertView.swift
//  SnappyV2
//
//  Created by David Bage on 05/01/2023.
//

import SwiftUI

/// Controls formatting of CustomSnappyAlert button text
enum AlertButtonActionType {
    case destructive
    case standard
    case success
    
    var fontColor: Color {
        switch self {
        case .destructive:
            return .red
        case .standard:
            return .blue
        case .success:
            return .green
        }
    }
}

/// Defines a textfield to be inserted into an alert
struct AlertTextField {
    let placeholder: String?
    let minCharacters: Int?
    let submitButton: AlertTextfieldSubmitButton?
}

/// Defines a button with action to be inserted into an alert
struct AlertActionButton {
    let title: String
    let actionType: AlertButtonActionType
    let requiresValidFieldEntry: Bool // Will disable textfield if criteria not met
    let action: () -> Void
    
    init(title: String, actionType: AlertButtonActionType = .standard, requiresValidFieldEntry: Bool = false, action: @escaping () -> Void) {
        self.title = title
        self.actionType = actionType
        self.requiresValidFieldEntry = requiresValidFieldEntry
        self.action = action
    }
}

/// Used for submitting contents of optional AlertTextField. Button action is defined by callback and returns the textfield contents
struct AlertTextfieldSubmitButton {
    let title: String
    let actionType: AlertButtonActionType
    let requiresValidFieldEntry: Bool // Will disable textfield if criteria not met
    
    init(title: String, actionType: AlertButtonActionType = .standard, requiresValidFieldEntry: Bool = false) {
        self.title = title
        self.actionType = actionType
        self.requiresValidFieldEntry = requiresValidFieldEntry
    }
}

/// A custom alert view that replicates the standard iOS formatting. With current limitations in SwiftUI meaning that alerts with textfields are only supported with
/// iOS15+ and even then, there is a lack of support for textfield validation, this component offers us a greater degree of flixbility.
/// NB: Component should be accessed via the modifier .withCustomSnappyAlert which includes a semi transparent screen to cover the background content.
/// Note however that this view will not be rendered above the tab bar in our project unless placed in the rootView.
struct CustomSnappyAlertView: View {
    @Environment(\.colorScheme) var colorScheme
        
    private var colorPalette: ColorPalette {
        .init(container: viewModel.container, colorScheme: colorScheme)
    }
    
    @StateObject var viewModel: CustomSnappyAlertViewModel
    
    // Passes the current value of the textfield (optional) String back to the parent view.
    // This action should be used as the completion action for a submit request which
    // needs to consume the textfield value
    let submitAction: (String) -> ()
    
    // MARK: - Constants
    struct Constants {
        static let vStackSpacing: CGFloat = 11
        static let opacity: CGFloat = 0.2
        
        struct Title {
            static let fontSize: CGFloat = 17
        }
        
        struct Prompt {
            static let fontSize: CGFloat = 13
        }
        
        struct SubmitButton {
            static let bottomPadding: CGFloat = 8
        }
        
        struct ConfiguredButton {
            static let vPadding: CGFloat = 12
            static let disabledOpacity: CGFloat = 0.7
        }
    }
    
    var body: some View {
        ZStack {
            Rectangle()
                .fill(Color.black.opacity(Constants.opacity))
                .ignoresSafeArea()
            
            VStack(spacing: Constants.vStackSpacing) {
                Text(viewModel.title)
                    .bold()
                    .padding(.top)
                    .frame(maxWidth: .infinity)
                    .font(.system(size: Constants.Title.fontSize))
                
                Text(viewModel.prompt)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                    .font(.system(size: Constants.Prompt.fontSize))
                
                if let textField = viewModel.textField {
                    TextField(textField.placeholder ?? Strings.CustomAlert.defaultPlaceholder.localized, text: $viewModel.textfieldContent)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .textCase(.lowercase)
                        .padding(.horizontal)
                }

                if let buttons = viewModel.buttons {
                    buttonsStack(buttons: buttons)
                }
            }
            .customAlert(container: viewModel.container)
        }
        .ignoresSafeArea(.all)
    }
    
    @ViewBuilder private func buttonsStack(buttons: [AlertActionButton]) -> some View {
        // If more than 2 buttons we present vertically...
        if viewModel.useVerticalButtonStack {
            VStack {
                Divider()
                ForEach(Array(buttons.enumerated()), id: \.offset) { index, button in
                    
                    configuredButton(button)
                    
                    // We do not want a divider if it is the last button in the array
                    if viewModel.addDivider(buttonIndex: index) {
                        Divider()
                    }
                }
                
                if let submitButton = viewModel.textField?.submitButton {
                    if viewModel.noActionButtons {
                        Divider()
                    }
                    
                    configuredButton(
                        .init(
                            title: submitButton.title,
                            actionType: submitButton.actionType,
                            requiresValidFieldEntry: submitButton.requiresValidFieldEntry,
                            action: {
                                submitAction(viewModel.textfieldContent)
                            })
                    )
                    .padding(.bottom, Constants.SubmitButton.bottomPadding)
                }
            }
        } else {
            // ... otherwise we present horizontally
            VStack(spacing: 0) {
                Divider()
                HStack {
                    ForEach(Array(buttons.enumerated()), id: \.offset) { index, button in
                        Spacer()
                        
                        configuredButton(button)
                        
                        Spacer()
                        
                        // For a stack of 2 buttons, we only want a divider after the first
                        if viewModel.addDivider(buttonIndex: index) {
                            Divider()
                        }
                    }
                    
                    if let submitButton = viewModel.textField?.submitButton {
                        Spacer()
                        configuredButton(
                            .init(
                                title: submitButton.title,
                                actionType: submitButton.actionType,
                                requiresValidFieldEntry: submitButton.requiresValidFieldEntry,
                                action: {
                                    submitAction(viewModel.textfieldContent)
                                }))
                        Spacer()
                    }
                }
            }
            .fixedSize(horizontal: false, vertical: true)
        }
    }
    
    // Returns either a buttonRequiringTextFieldValidation or standardButton.
    // A buttonRequiringTextFieldValidation will be linked to the viewModel's invalidFieldEntry
    // boolean and will be disabled if this is false
    @ViewBuilder private func configuredButton(_ button: AlertActionButton) -> some View {
        if button.requiresValidFieldEntry {
            buttonRequiringTextFieldValidation(button: button)
                .padding(.vertical, Constants.ConfiguredButton.vPadding)
        } else {
            standardButton(button: button)
                .padding(.vertical, Constants.ConfiguredButton.vPadding)
        }
    }
    
    private func buttonRequiringTextFieldValidation(button: AlertActionButton) -> some View {
        Button(action: {
            button.action()
        }) {
            Text(button.title)
                .foregroundColor(viewModel.invalidFieldEntry ? Color.gray.opacity(Constants.ConfiguredButton.disabledOpacity) : button.actionType.fontColor)
        }
        .disabled(viewModel.invalidFieldEntry)
    }
    
    private func standardButton(button: AlertActionButton) -> some View {
        Button(action: {
            button.action()
        }) {
            Text(button.title)
                .foregroundColor(button.actionType.fontColor)
        }
    }
}

#if DEBUG
struct CustomSnappyAlert_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            // With textfield and 1 button
            CustomSnappyAlertView(viewModel: .init(
                container: .preview,
                title: "Confirmation Code Sent",
                prompt: "Please check your emails and enter code below",
                textField: .init(
                placeholder: "Enter code",
                minCharacters: 4,
                submitButton: nil),
                buttons: [
                    .init(title: "Cancel", requiresValidFieldEntry: false, action: {
                        print("Cancel")
                    })
                ]), submitAction: { textfieldText in
                    print(textfieldText)
                })
            
            // With textfield 2 buttons
            CustomSnappyAlertView(viewModel: .init(
                container: .preview,
                title: "Confirmation Code Sent",
                prompt: "Please check your emails and enter code below",
                textField: .init(
                placeholder: "Enter code",
                minCharacters: 4,
                submitButton: .init(title: "Submit", actionType: .destructive, requiresValidFieldEntry: true)),
                buttons: [
                    .init(title: "Cancel", requiresValidFieldEntry: false, action: {
                        print("Cancel")
                    })]), submitAction: { textfieldText in
                    print(textfieldText)
                })
            
            // With textfield 3 buttons
            CustomSnappyAlertView(viewModel: .init(
                container: .preview,
                title: "Confirmation Code Sent",
                prompt: "Please check your emails and enter code below",
                textField: .init(
                placeholder: "Enter code",
                minCharacters: 4,
                submitButton: .init(title: "Submit", actionType: .destructive, requiresValidFieldEntry: true)),
                buttons: [
                    .init(title: "Cancel", requiresValidFieldEntry: false, action: {
                        print("Cancel")
                    }),
                    .init(title: "Test", requiresValidFieldEntry: false, action: {
                        print("Test")
                    }),
                    .init(title: "OK", requiresValidFieldEntry: false, action: {
                        print("OK")
                    })
                ]), submitAction: { textfieldText in
                    print(textfieldText)
                })
            
            // Without textfield
            CustomSnappyAlertView(viewModel: .init(container: .preview, title: "Confirmation Code Sent", prompt: "Please check your emails and enter code below", textField: nil, buttons: [
                
            ]), submitAction: { textfieldText in
                print(textfieldText)
            })
        }
    }
}
#endif
