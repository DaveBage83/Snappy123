//
//  SnappyButton.swift
//  SnappyV2
//
//  Created by David Bage on 05/05/2022.
//

import SwiftUI

struct SnappyButton: View {
    @Environment(\.colorScheme) var colorScheme // Used for colorPalette (dynamic colours)
    @ScaledMetric var scale: CGFloat = 1 // Used to scale icon for accessibility options
    
    enum SnappyButtonType {
        case primary
        case secondary
        case success
        case outline
        case text
    }
    
    enum SnappyButtonSize {
        case large
        case medium
        case small
    }
    
    // Required for dynamic colours
    var colorPalette: ColorPalette {
        ColorPalette(container: container, colorScheme: colorScheme)
    }
    
    // MARK: - Properties
    
    let container: DIContainer
    let type: SnappyButtonType
    let size: SnappyButtonSize
    let title: String
    let icon: Image?
    
    @Binding var isEnabled: Bool
    @Binding var isLoading: Bool
    let action: () -> Void
    
    // MARK: - Styling variables
    
    var font: Font {
        switch size {
        case .large:
            return .button1()
        case .medium:
            return .button2()
        case .small:
            return .button3()
        }
    }
    
    var fontColor: Color {
        switch type {
        case .outline, .text:
            return colorPalette.secondaryDark
        case .primary, .secondary, .success:
            return colorPalette.typefaceInvert
        }
    }
    
    var vPadding: CGFloat {
        switch size {
        case .small:
            return 8
        case .large, .medium:
            return 12
        }
    }

    var cornerRadius: CGFloat {
        switch size {
        case .small:
            return 4
        case .large, .medium:
            return 8
        }
    }
    
    var labelStackSpacing: CGFloat {
        switch size {
        case .large:
            return 16
        case .medium:
            return 11
        case .small:
            return 6
        }
    }
    
    var iconHeight: CGFloat {
        switch size {
        case .large:
            return 14 * scale // scale changes according to accessibility level
        case .medium:
            return 10.5 * scale
        case .small:
            return 7  * scale
        }
    }
    
    var backgroundColor: Color {
        switch type {
        case .primary:
            return isEnabled ? colorPalette.primaryBlue : colorPalette.textGrey4
        case .secondary:
            return isEnabled ? colorPalette.secondaryDark : colorPalette.textGrey4
        case .success:
            return isEnabled ? colorPalette.alertSuccess : colorPalette.textGrey4
        case .outline:
            return .clear
        case .text:
            return .clear
        }
    }
    
    var border: (color: Color, width: CGFloat) {
        switch type {
        case .outline:
            return (isEnabled ? colorPalette.secondaryDark : colorPalette.textGrey3, 2)
        default:
            return (.clear, 0)
        }
    }
    
    init(container: DIContainer, type: SnappyButtonType, size: SnappyButtonSize, title: String, icon: Image?, isEnabled: Binding<Bool> = .constant(true), isLoading: Binding<Bool> = .constant(false), action: @escaping () -> Void) {
        self.container = container
        self.type = type
        self.size = size
        self.title = title
        self.icon = icon
        self._isEnabled = isEnabled
        self._isLoading = isLoading
        self.action = action
    }
    
    var body: some View {
        Button {
            action()
            
        } label: {
            HStack(spacing: labelStackSpacing) {
                if let icon = icon {
                    icon
                        .renderingMode(.template)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: iconHeight)
                        .foregroundColor(isEnabled ? fontColor : colorPalette.textGrey2)
                        .opacity(isLoading ? 0 : 1)
                }
                
                Text(title)
                    .font(font)
                    .foregroundColor(isEnabled ? fontColor : colorPalette.textGrey2)
                    .opacity(isLoading ? 0 : 1)
            }
            .frame(maxWidth: .infinity)
            
            .padding(.vertical, vPadding)
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(border.color, lineWidth: border.width)
            )
            
            .background(backgroundColor)
            .cornerRadius(cornerRadius)
        }
        .withLoadingView(isLoading: $isLoading, color: fontColor)
        .disabled(!isEnabled || isLoading)
    }
}

struct SnappyButton_Previews: PreviewProvider {
    static var previews: some View {

        Group {
            // No icon
            SnappyButton(container: .preview, type: .primary, size: .large, title: "View more orders", icon: nil, isEnabled: .constant(true), action: {})

            // With icon
            SnappyButton(container: .preview, type: .primary, size: .large, title: "View more orders", icon: Image.Icons.Chevrons.Right.light, isEnabled: .constant(true), action: {})

            SnappyButton(container: .preview, type: .primary, size: .medium, title: "View more orders", icon: Image.Icons.Chevrons.Right.light, isEnabled: .constant(true), action: {})

            SnappyButton(container: .preview, type: .primary, size: .small, title: "View more orders", icon: Image.Icons.Chevrons.Right.light, isEnabled: .constant(true), action: {})

            // With icon accessibilityExtraExtraLarge
            SnappyButton(container: .preview, type: .primary, size: .large, title: "View more orders", icon: Image.Icons.Chevrons.Right.light, isEnabled: .constant(true), action: {})
                .environment(\.sizeCategory, .accessibilityExtraExtraExtraLarge)

            // Types
            SnappyButton(container: .preview, type: .secondary, size: .medium, title: "View more orders", icon: nil, isEnabled: .constant(true), action: {})

            SnappyButton(container: .preview, type: .success, size: .small, title: "View more orders", icon: nil, isEnabled: .constant(true), action: {})

            SnappyButton(container: .preview, type: .outline, size: .small, title: "View more orders", icon: nil, isEnabled: .constant(true), action: {})
        }
    }
}
