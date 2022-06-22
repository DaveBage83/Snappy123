//
//  SnappyTextfield.swift
//  SnappyV2
//
//  Created by David Bage on 16/05/2022.
//

import SwiftUI

struct SnappyTextfield: View {
    @Environment(\.colorScheme) var colorScheme
    @ScaledMetric var scale: CGFloat = 1 // Used to scale icon for accessibility options
    @Environment(\.sizeCategory) var sizeCategory: ContentSizeCategory
    
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
        
        struct General {
            static let largeTextThreshold: Int = 8
        }
        
        struct InternalButton {
            static let width: CGFloat = 24
        }
    }
    
    // MARK: - ColorPalette
    var colorPalette: ColorPalette {
        ColorPalette(container: container, colorScheme: colorScheme)
    }
    
    // MARK: - Properties
    let container: DIContainer // required to init the colorPalette
    let labelText: String // floating text label
    let largeTextLabelText: String // used when large text selected
    let bgColor: Color
    let fieldType: FieldType
    let keyboardType: UIKeyboardType?
    let autoCaps: UITextAutocapitalizationType?
    let internalButton: (icon: Image, action: () -> Void)?
    
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
    @State var isRevealed = true // Only used for secure field and should be set to true as default
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
        
    init(container: DIContainer, text: Binding<String>, isDisabled: Binding<Bool> = .constant(false), hasError: Binding<Bool>, labelText: String, largeTextLabelText: String?, bgColor: Color = .clear, fieldType: FieldType = .standardTextfield, keyboardType: UIKeyboardType? = nil, autoCaps: UITextAutocapitalizationType? = nil, internalButton: (icon: Image, action: () -> Void)? = nil) {
        self.container = container
        self._text = text
        self._isDisabled = isDisabled
        self._hasError = hasError
        self.labelText = labelText
        self.largeTextLabelText = largeTextLabelText ?? labelText
        self.bgColor = bgColor
        self.fieldType = fieldType
        self.keyboardType = keyboardType ?? .default
        self.autoCaps = autoCaps ?? UITextAutocapitalizationType.none
        self._isRevealed = .init(initialValue: fieldType != .secureTextfield)
        self.internalButton = internalButton
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
                        } else if let internalButton = internalButton {
                            Button {
                                internalButton.action()
                            } label: {
                                internalButton.icon
                                    .renderingMode(.template)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: Constants.InternalButton.width)
                                    .foregroundColor(colorPalette.typefacePrimary.withOpacity(.eighty))
                                    .padding(.trailing)
                            }
                        }
                    }
                }
            }
        }
        .background(bgColor)
        .disabled(isDisabled)
    }
    
    // MARK: - Subviews
    
    private var snappyTextfield: some View {
        return FocusTextField(text: $text,
                              isEnabled: $isDisabled,
                              isRevealed: $isRevealed,
                              isFocused: $isFocused,
                              placeholder: labelText,
                              largeTextPlaceholder: largeTextLabelText,
                              keyboardType: keyboardType,
                              autoCaps: autoCaps)
        .font(.Body1.regular())
        .foregroundColor(inputTextColor)
        .padding(.leading, Constants.Text.inset)
    }
    
    @ViewBuilder var textfieldView: some View {
        snappyTextfield
            .onChange(of: isFocused) { isFocused in
                if isFocused {
                    adjustFloatingLabel()
                    
                } else if text.isEmpty {
                    labelYOffset = 0
                    DispatchQueue.main.asyncAfter(deadline: .now() + Constants.Animations.fontChangeDelay) { // we want the offset to change before we amend the font
                        font = regularLabelFont
                    }
                }
            }
    }
    
    private func adjustFloatingLabel() {
        labelYOffset = floatingLabelYAdjustment
        DispatchQueue.main.asyncAfter(deadline: .now() + Constants.Animations.fontChangeDelay) { // we want the offset to change before we amend the font
            font = floatedLabelFont
        }
    }
    
    // Border
    private func border(trim: Bool) -> some View {
        return TextfieldBorder()
            .trim(from: trim ? labelProportion : 0, to: 1)
            .stroke(tintColor, lineWidth: Constants.Border.lineWidth)
            .frame(maxWidth: .infinity)
            .frame(height: Constants.Border.height * scale)
            .animation(.default, value: trim)
            .measureSize { size in // Tracks the current dimensions of the border
                self.borderWidth = size.width
                self.borderHeight = size.height
                
                if text.isEmpty == false {
                    adjustFloatingLabel()
                }
            }
    }
    
    // Floating label
    private var animatedFloatingLabel: some View {
        HStack {
            Text(sizeCategory.size < Constants.General.largeTextThreshold ? labelText : largeTextLabelText)
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
            isRevealed.toggle()
        } label: {
            (isRevealed ? Image.Icons.EyeSlash.standard : Image.Icons.Eye.standard)
                .renderingMode(.template)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: Constants.HideButton.iconSize * scale)
                .foregroundColor(colorPalette.textGrey1.withOpacity(isDisabled ? .twenty : .eighty))
        }
        .padding(.trailing, Constants.HideButton.padding)
    }
}

#if DEBUG
struct SnappyTextfield_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            // With internal button
            SnappyTextfield(
                container: .preview,
                text: .constant(""),
                isDisabled: .constant(false),
                hasError: .constant(false),
                labelText: "Home Address",
                largeTextLabelText: "Address",
                fieldType: .label,
                internalButton: (Image.Icons.LocationArrow.standard, {}))
            
            // Enabled
            SnappyTextfield(
                container: .preview,
                text: .constant(""),
                isDisabled: .constant(false),
                hasError: .constant(false),
                labelText: "Home Address",
                largeTextLabelText: "Address",
                fieldType: .label,
                internalButton: nil)
            
            // Disabled
            SnappyTextfield(
                container: .preview,
                text: .constant(""),
                isDisabled: .constant(true),
                hasError: .constant(false),
                labelText: "Home Address",
                largeTextLabelText: "Address",
                internalButton: nil)
            
            // With error
            SnappyTextfield(
                container: .preview,
                text: .constant(""),
                isDisabled: .constant(false),
                hasError: .constant(true),
                labelText: "Home Address",
                largeTextLabelText: "Address",
                internalButton: nil)
            
            // Secure field
            SnappyTextfield(
                container: .preview,
                text: .constant(""),
                isDisabled: .constant(false),
                hasError: .constant(false),
                labelText: "Home Address",
                largeTextLabelText: "Address",
                fieldType: .secureTextfield,
                internalButton: nil)
            
            // Label field (used for drop downs)
            SnappyTextfield(
                container: .preview,
                text: .constant(""),
                isDisabled: .constant(false),
                hasError: .constant(false),
                labelText: "Home Address",
                largeTextLabelText: "Address",
                fieldType: .label,
                internalButton: nil)
        }
    }
}
#endif

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
