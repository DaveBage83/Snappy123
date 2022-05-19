//
//  SnappyTextfield.swift
//  SnappyV2
//
//  Created by David Bage on 16/05/2022.
//

import SwiftUI

struct SnappyTextfield: View {
    @Environment(\.colorScheme) var colorScheme
    
    enum TextfieldState {
        case disabled
        case focused
        case error
        case active
    }
    
    enum FieldType {
        case standardTextfield
        case secureTextfield
        case label // to be used for drop down menus in conjunction with SwiftUIs Menu
    }
    
    // MARK: - Constants
    struct Constants {
        struct Border {
            static let height: CGFloat = 47
            static let cornerRadius: CGFloat = 8
            static let lineWidth: CGFloat = 1
        }
        
        struct Text {
            static let inset: CGFloat = 14
        }
        
        struct Animations {
            static let fontChangeDelay: CGFloat = 0.15
        }
        
        struct HideButton {
            static let iconSize: CGFloat = 24
            static let padding: CGFloat = 14.17
        }
    }
    
    // MARK: - ColorPalette
    var colorPalette: ColorPalette {
        ColorPalette(container: container, colorScheme: colorScheme)
    }
    
    // MARK: - Properties
    let container: DIContainer // required to init the colorPalette
    let labelText: String // floating text label
    let bgColor: Color
    let fieldType: FieldType
    
    // MARK: - State / binding variables
    @Binding var text: String // text which binds to the field
    @Binding var isDisabled: Bool
    @Binding var hasError: Bool
    
    // The following are set using GeometryReader, ensuring they track the current dimensions of these elements taking into consideration the device size and orientation
    @State var labelWidth: CGFloat = 0
    @State var borderWidth: CGFloat = 0
    @State var borderHeight: CGFloat = 0
    @State var labelFontSize: CGFloat = 14
    @State var labelYOffset: CGFloat = 0
    @State var font: Font = .Body1.regular()
    @State var textHidden = true // Only used for secure field and should be set to true as default
    @State var isFocused: Bool = false
    
    // MARK: - Computed variables
    
    // We need the total border length to calculate the proportion that the label takes up.
    private var totalBorderLength: CGFloat {
        (borderHeight * 2) + (borderWidth * 2)
    }
    
    // This gives us the % of trim required
    private var labelProportion: CGFloat {
        (labelWidth + 8) / totalBorderLength
    }
    
    private var floatingLabelYAdjustment: CGFloat {
        -borderHeight / 2
    }
    
    private var floatedLabelFont: Font {
        .button2()
    }
    
    private var regularLabelFont: Font {
        .Body1.regular()
    }
    
    private var textfieldState: TextfieldState {
        if isDisabled {
            return .disabled
        } else if hasError {
            return .error
        } else if isFocused {
            return .focused
        }
        
        return .active
    }
    
    private var tintColor: Color {
        switch textfieldState {
        case .disabled:
            return colorPalette.textGrey1.withOpacity(.twenty)
        case .focused:
            return colorPalette.primaryBlue
        case .error:
            return colorPalette.primaryRed
        case .active:
            return colorPalette.textGrey1.withOpacity(.eighty)
        }
    }
    
    private var labelColor: Color {
        switch textfieldState {
        case .disabled:
            return colorPalette.textGrey1.withOpacity(.twenty)
        case .focused:
            return colorPalette.primaryBlue
        case .error:
            return (text.isEmpty == false || isFocused) ? colorPalette.primaryRed : colorPalette.typefacePrimary
        case .active:
            return colorPalette.typefacePrimary
        }
    }
    
    private var inputTextColor: Color {
        if isDisabled {
            return colorPalette.textGrey1.withOpacity(.twenty)
        }
        
        return colorPalette.typefacePrimary
    }
        
    init(container: DIContainer, text: Binding<String>, isDisabled: Binding<Bool>, hasError: Binding<Bool>, labelText: String, bgColor: Color = .clear, fieldType: FieldType = .standardTextfield) {
        self.container = container
        self._text = text
        self._isDisabled = isDisabled
        self._hasError = hasError
        self.labelText = labelText
        self.bgColor = bgColor
        self.fieldType = fieldType
    }
    
    var body: some View {
        VStack {
            ZStack {
                if fieldType == .label {
                    border(trim: true)
                } else {
                    border(trim: isFocused || text.isEmpty == false)
                }
                
                if fieldType == .label {
                    fixedFloatingLabel
                } else {
                    animatedFloatingLabel
                    
                    HStack {
                        textfieldView
                        
                        if fieldType == .secureTextfield {
                            hideTextButton
                        }
                    }
                }
            }
        }
        .background(bgColor)
        .padding()
        .disabled(isDisabled)
    }
    
    // MARK: - Subviews
    
    // Standard textfield
    private var snappyTextfield: some View {
        if fieldType == .secureTextfield && textHidden {
            return AnyView(SecureField(labelText, text: $text))
                .font(.Body1.regular())
                .foregroundColor(inputTextColor)
                .padding(.leading, Constants.Text.inset)
        } else {
            return AnyView(TextField(labelText, text: $text, onEditingChanged: { changed in
                if changed {
                    self.isFocused = true
                } else {
                    self.isFocused = false
                }
                
            }))
            .font(.Body1.regular())
            .foregroundColor(inputTextColor)
            .padding(.leading, Constants.Text.inset)
        }
    }
    
    @ViewBuilder var textfieldView: some View {
        snappyTextfield
            .onChange(of: isFocused) { isFocused in
                if isFocused {
                    labelYOffset = floatingLabelYAdjustment
                    DispatchQueue.main.asyncAfter(deadline: .now() + Constants.Animations.fontChangeDelay) { // we want the offset to change before we amend the font
                        font = floatedLabelFont
                    }
                    
                } else if text.isEmpty {
                    labelYOffset = 0
                    DispatchQueue.main.asyncAfter(deadline: .now() + Constants.Animations.fontChangeDelay) { // we want the offset to change before we amend the font
                        font = regularLabelFont
                    }
                }
            }
    }
    
    // Border
    private func border(trim: Bool) -> some View {
        return TextfieldBorder()
            .trim(from: trim ? labelProportion : 0, to: 1)
            .stroke(tintColor, lineWidth: Constants.Border.lineWidth)
            .frame(maxWidth: .infinity)
            .frame(height: Constants.Border.height)
            .animation(.default)
            .measureSize { size in // Tracks the current dimensions of the border
                self.borderWidth = size.width
                self.borderHeight = size.height
            }
    }
    
    // Floating label
    private var animatedFloatingLabel: some View {
        HStack {
            Text(labelText)
                .font(font)
                .foregroundColor(labelColor)
                .background(Color.clear)
                .measureSize { size in // Tracks the current dimensions of the label
                    labelWidth = size.width
                }
            Spacer()
        }
        .cornerRadius(Constants.Border.cornerRadius)
        .offset(y: labelYOffset)
        .animation(.default)
        .transition(.opacity)
        .padding(.leading, Constants.Text.inset)
    }
    
    private var fixedFloatingLabel: some View {
        HStack {
            Text(labelText)
                .font(floatedLabelFont)
                .foregroundColor(labelColor)
                .background(Color.clear)
                .measureSize { size in // Tracks the current dimensions of the label
                    labelWidth = size.width
                }
            Spacer()
        }
        .cornerRadius(Constants.Border.cornerRadius)
        .offset(y: floatingLabelYAdjustment)
        .padding(.leading, Constants.Text.inset)
    }
    
    // Secure field button
    private var hideTextButton: some View {
        Button {
            textHidden.toggle()
        } label: {
            (textHidden ? Image.Icons.Eye.standard : Image.Icons.EyeSlash.standard)
                .renderingMode(.template)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: Constants.HideButton.iconSize)
                .foregroundColor(colorPalette.textGrey1.withOpacity(isDisabled ? .twenty : .eighty))
        }
        .padding(.trailing, Constants.HideButton.padding)
    }
}

struct SnappyTextfield_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            // Enabled
            SnappyTextfield(
                container: .preview,
                text: .constant(""),
                isDisabled: .constant(false),
                hasError: .constant(false),
                labelText: "Address", fieldType: .label)
            
            // Disabled
            SnappyTextfield(
                container: .preview,
                text: .constant(""),
                isDisabled: .constant(true),
                hasError: .constant(false),
                labelText: "Address")
            
            // With error
            SnappyTextfield(
                container: .preview,
                text: .constant(""),
                isDisabled: .constant(false),
                hasError: .constant(true),
                labelText: "Address")
            
            // Secure field
            SnappyTextfield(
                container: .preview,
                text: .constant(""),
                isDisabled: .constant(false),
                hasError: .constant(false),
                labelText: "Address",
                fieldType: .secureTextfield)
            
            // Label field (used for drop downs)
            SnappyTextfield(
                container: .preview,
                text: .constant(""),
                isDisabled: .constant(false),
                hasError: .constant(false),
                labelText: "Address",
                fieldType: .label)
        }
    }
}

// In order to get the animation that we want for the floating label textfield, we need to draw our own
// border using Path. Only by doing this can we control where the shape begins and therefore exactly where
// the trim starts from

struct TextfieldBorder: Shape {
    struct Constants {
        static let cornerRadius: CGFloat = 8
        static let startingPosition: CGFloat = 10
    }
    
    func path(in rect: CGRect) -> Path {
        Path {
            $0.move(to: CGPoint(x: rect.minX + Constants.startingPosition, y: rect.minY)) // start 10 pts in from leading anchor
            $0.addLine(to: CGPoint(x: rect.maxX - Constants.cornerRadius, y: rect.minY))
            $0.addQuadCurve(to: CGPoint(x: rect.maxX, y: rect.minY + Constants.cornerRadius), control: CGPoint(x: rect.maxX, y: rect.minY))
            
            
            $0.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - Constants.cornerRadius))
            $0.addQuadCurve(to: CGPoint(x: rect.maxX - Constants.cornerRadius, y: rect.maxY), control: CGPoint(x: rect.maxX, y: rect.maxY))
            
            
            $0.addLine(to: CGPoint(x: rect.minX + Constants.cornerRadius, y: rect.maxY))
            $0.addQuadCurve(to: CGPoint(x: rect.minX, y: rect.maxY - Constants.cornerRadius), control: CGPoint(x: rect.minX, y: rect.maxY))
            
            
            $0.addLine(to: CGPoint(x: rect.minX, y: rect.minY + Constants.cornerRadius))
            $0.addQuadCurve(to: CGPoint(x: rect.minX + Constants.cornerRadius, y: rect.minY), control: CGPoint(x: rect.minX, y: rect.minY))
            
            $0.addLine(to: CGPoint(x: rect.minX + Constants.startingPosition, y: rect.minY))
        }
    }
}
