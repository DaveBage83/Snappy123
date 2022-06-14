//
//  SnappyTextFieldWithButton.swift
//  SnappyV2
//
//  Created by David Bage on 30/05/2022.
//

import SwiftUI

struct SnappyTextFieldWithButton: View {
    // MARK: - Environment objects
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.sizeCategory) var sizeCategory: ContentSizeCategory
    @ScaledMetric var scale: CGFloat = 1
    
    // MARK: - Constants
    private struct Constants {
        struct Button {
            static let cornerRadius: CGFloat = 8
            static let height: CGFloat = 48
            static let largeTextImageWidth: CGFloat = 24
        }
    }
    
    // MARK: - Binding properties
    @Binding var text: String
    @Binding var hasError: Bool
    @Binding var isLoading: Bool
    
    // MARK: - Properties
    private let container: DIContainer
    private let labelText: String
    private let largeLabelText: String? // Used for when larger font selected for accessibility
    private let mainButton: (title: String, action: () -> Void)
    private let mainButtonLargeTextLogo: Image? // Used for when larger font selected for accessibility
    private let internalButton: (icon: Image, action: () -> Void)?
    
    // MARK: - Computed variables
    private var colorPalette: ColorPalette {
        ColorPalette(container: container, colorScheme: colorScheme)
    }
    
    private var minimalLayoutView: Bool {
        sizeCategory.size > 7 // Defines at what point we simplify the view for large accessibility font selection
    }
    
    init(container: DIContainer, text: Binding<String>, hasError: Binding<Bool>, isLoading: Binding<Bool>, labelText: String,
         largeLabelText: String?, mainButton: (title: String, action: () -> Void), mainButtonLargeTextLogo: Image? = nil,
         internalButton: (icon: Image, action: () -> Void)? = nil) {
        self.container = container
        self._text = text
        self._hasError = hasError
        self._isLoading = isLoading
        self.labelText = labelText
        self.largeLabelText = largeLabelText
        self.mainButton = mainButton
        self.internalButton = internalButton
        self.mainButtonLargeTextLogo = mainButtonLargeTextLogo
    }
    
    // MARK: - Main view
    var body: some View {
        HStack {
            SnappyTextfield(
                container: container,
                text: $text,
                hasError: $hasError,
                labelText: labelText,
                largeTextLabelText: largeLabelText,
                internalButton: internalButton)
            
            button
        }
    }
    
    // MARK: - Button
    private var button: some View {
        Button {
            mainButton.action()
        } label: {
            if let image = mainButtonLargeTextLogo, minimalLayoutView {
                image
                    .renderingMode(.template)
                    .resizable()
                    .scaledToFit()
                    .frame(width: Constants.Button.largeTextImageWidth * scale)
                    .foregroundColor(.white)
                    .padding()
                    .background(colorPalette.primaryBlue)
                    .foregroundColor(.white)
                    .cornerRadius(Constants.Button.cornerRadius)
                    .frame(height: Constants.Button.height * scale)
                    .opacity(isLoading ? 0 : 1)
            } else {
                Text(mainButton.title)
                    .font(.button2())
                    .opacity(isLoading ? 0 : 1)
                    .padding()
                    .background(colorPalette.primaryBlue)
                    .foregroundColor(.white)
                    .cornerRadius(Constants.Button.cornerRadius)
                    .frame(height: Constants.Button.height * scale)
            }
        }
        .withLoadingView(isLoading: $isLoading, color: .white)
    }
}

#if DEBUG
struct SnappyTextFieldWithButton_Previews: PreviewProvider {
    static var previews: some View {
        SnappyTextFieldWithButton(
            container: .preview,
            text: .constant(""),
            hasError: .constant(false),
            isLoading: .constant(false),
            labelText: "Postcode search",
            largeLabelText: nil,
            mainButton: ("Search", {}),
            internalButton: (Image.Icons.LocationCrosshairs.standard, {})
        )
    }
}
#endif
