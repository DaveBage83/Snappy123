//
//  TextFieldFloatingWithBorder.swift
//  SnappyV2
//
//  Created by Henrik Gustavii on 25/01/2022.
//

import SwiftUI
#warning("To be deprecated in favour of SnappyTextfield")
struct TextFieldFloatingWithBorder: View {
    
    struct Constants {
        static let lineWidth: CGFloat = 1
        static let cornerRadius: CGFloat = 4
        static let frameHeight: CGFloat = 38
        
        struct Padding {
            static let horizontalIsEmpty: CGFloat = 0
            static let horizontalIsNotEmpty: CGFloat = 4
            static let horizontal: CGFloat = 16
            static let leading: CGFloat = 16
            static let top: CGFloat = 8
        }
        
        struct Offset {
            static let isEmpty: CGFloat = 0
            static let isNotEmptyRatio: Double = 1.25
        }
        
        struct ScaleEffect {
            static let isEmpty: CGFloat = 1
            static let isNotEmpty: CGFloat = 0.75
        }
        
        struct Animation {
            static let easeInOut: Double = 0.2
        }
    }
    
    @Binding var text: String
    @Binding var hasWarning: Bool
    @State var passwordTextMasked = true
    
    @available(iOS 15.0, *)
    @FocusState var isFocused: Bool // For users with <iOS 15 we default to .snappyBlue regardless of the focus state
    
    let title: String
    let background: Color
    let frameHeight: CGFloat
    let disableAnimations: Bool
    private let isDisabled: Bool
    let isSecureField: Bool
    var keyboardType: UIKeyboardType

    init(_ title: String, text: Binding<String>, hasWarning: Binding<Bool> = .constant(false), background: Color = Color(UIColor.systemBackground), height: CGFloat = Constants.frameHeight, isDisabled: Bool = false, disableAnimations: Bool = false, isSecureField: Bool = false, keyboardType: UIKeyboardType = .default) {
        self.title = title
        self._text = text
        self.background = background
        self._hasWarning = hasWarning
        self.frameHeight = height
        self.isDisabled = isDisabled
        self.disableAnimations = disableAnimations
        self.isSecureField = isSecureField
        self.keyboardType = keyboardType
    }
    
    var body: some View {
        ZStack(alignment: .leading) {
            border
            
            placeholder
            
            if isSecureField {
                if passwordTextMasked {
                    secureTextfieldView
                } else {
                    unmaskedSecureTextfield
                }
            } else {
                standardTextfieldView
            }
        }
        .frame(height: frameHeight)
        .background(background)
        .animation(disableAnimations ? nil : .easeInOut(duration: Constants.Animation.easeInOut))
        .padding(.top, Constants.Padding.top)
    }
    
    // MARK: - Border
    
    @ViewBuilder var border: some View {
        if #available(iOS 15.0, *) {
            RoundedRectangle(cornerRadius: Constants.cornerRadius, style: .continuous)
                .stroke(isFocused ? Color.snappyBlue : hasWarning ? .snappyRed : .snappyTextGrey2, lineWidth: Constants.lineWidth)
        } else {
            RoundedRectangle(cornerRadius: Constants.cornerRadius, style: .continuous)
                .stroke(hasWarning ? Color.snappyRed : Color.snappyBlue, lineWidth: Constants.lineWidth)
        }
    }
    
    // MARK: - Animated placeholder label
    
    @ViewBuilder var placeholder: some View {
        if #available(iOS 15.0, *) {
            label
                .foregroundColor(isFocused ? Color.snappyBlue : hasWarning ? .snappyRed : .snappyTextGrey2)
        } else {
            label
                .foregroundColor(hasWarning ? .snappyRed : .snappyBlue)
        }
    }
    
    private var label: some View {
        Text(title)
            .font(.snappyBody)
            .padding(.horizontal, text.isEmpty ? Constants.Padding.horizontalIsEmpty : Constants.Padding.horizontalIsNotEmpty)
            .background(text.isEmpty ? Color.clear : background)
            .padding(.leading, Constants.Padding.leading)
            .offset(y: text.isEmpty ? Constants.Offset.isEmpty : -(frameHeight / Constants.Offset.isNotEmptyRatio))
            .scaleEffect(text.isEmpty ? Constants.ScaleEffect.isEmpty : Constants.ScaleEffect.isNotEmpty, anchor: .leading)
    }
    
    // MARK: - Standard textfield
    
    @ViewBuilder var standardTextfieldView: some View {
        if #available(iOS 15.0, *) {
            standardTextField
                .focused($isFocused) // @FocusState only available in >iOS15
        } else {
            standardTextField
        }
    }
    
    private var standardTextField: some View {
        TextField("", text: $text)
            .font(.snappyBody)
            .padding(.horizontal, Constants.Padding.horizontal)
            .disabled(isDisabled)
            .disableAutocorrection(true)
            .keyboardType(keyboardType)
    }
    
    // MARK: - Secure textfield
    
    @ViewBuilder var unmaskedSecureTextfield: some View {
        if #available(iOS 15.0, *) {
            HStack {
                standardTextField
                    .focused($isFocused) // @FocusState only available in >iOS15
                
                toggleMaskTextButton
                    .foregroundColor(isFocused ? .snappyBlue : hasWarning ? .snappyRed : .snappyTextGrey2)
            }
            
        } else {
            HStack {
                standardTextField
                
                toggleMaskTextButton
                    .foregroundColor(.snappyBlue)
            }
        }
    }
    
    private var secureTextField: some View {
        SecureField("", text: $text)
            .font(.snappyBody)
            .padding(.horizontal, Constants.Padding.horizontal)
            .disabled(isDisabled)
            .autocapitalization(.none) // For SecureField we would never want caps enabled
            .disableAutocorrection(true)
            .keyboardType(keyboardType)
    }
    
    @ViewBuilder var secureTextfieldView: some View {
        if #available(iOS 15.0, *) {
            HStack {
                secureTextField
                    .focused($isFocused)
                
                toggleMaskTextButton
            }
        } else {
            HStack {
                secureTextField
                
                toggleMaskTextButton
            }
        }
    }
    
    // MARK: - Toggle mask text button
    
    @ViewBuilder var toggleMaskTextButton: some View {
        if #available(iOS 15.0, *) {
            Button {
                passwordTextMasked.toggle()
                
            } label: {
                (passwordTextMasked ? Image.Login.Password.showPassword : Image.Login.Password.hidePassword)
                    .padding(.trailing, Constants.Padding.horizontal)
                    .foregroundColor(isFocused ? .snappyBlue : hasWarning ? .snappyRed : .snappyTextGrey2)
            }
        } else {
            Button {
                passwordTextMasked.toggle()
            } label: {
                (passwordTextMasked ? Image.Login.Password.showPassword : Image.Login.Password.hidePassword)
                    .padding(.trailing, Constants.Padding.horizontal)
                    .foregroundColor(hasWarning ? .snappyRed : .snappyBlue)
            }
        }
        
    }
}

#if DEBUG
struct TextFieldFloatingWithBorder_Previews: PreviewProvider {
    static var previews: some View {
        TextFieldFloatingWithBorder("", text: .constant("Surname"), hasWarning: .constant(true), background: .white)
            .previewLayout(.sizeThatFits)
            .padding()
            .previewCases()
    }
}
#endif
