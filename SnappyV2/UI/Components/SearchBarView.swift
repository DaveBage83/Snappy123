//
//  SearchBarView.swift
//  SnappyV2Study
//
//  Created by Henrik Gustavii on 02/07/2021.
//

import SwiftUI

struct SearchBarView: View {
    // MARK: - Environment objects
    @Environment(\.colorScheme) var colorScheme
    @ScaledMetric var scale: CGFloat = 1 // Used to scale icon for accessibility options
    
    // MARK: - Constants
    struct Constants {
        static let textfieldIconSize: CGFloat = 16
        static let xmarkWidth: CGFloat = 13
        static let padding: CGFloat = 10
        static let cornerRadius: CGFloat = 8
        static let borderWidth: CGFloat = 1
        static let textfieldHeight: CGFloat = 22
    }
    
    // MARK: - Properties
    let container: DIContainer
    var label: String
    
    // MARK: - Binding properties
    @Binding var text: String
    @Binding var isEditing: Bool
    @State var isFocused: Bool = false
    
    // MARK: - Computed variables
    private var colorPalette: ColorPalette {
        ColorPalette(container: container, colorScheme: colorScheme)
    }
    
    // MARK: - Init
    init(container: DIContainer, label: String = GeneralStrings.Search.search.localized, text: Binding<String>, isEditing: Binding<Bool>) {
        self.container = container
        self.label = label
        self._text = text
        self._isEditing = isEditing
    }
    
    // MARK: - Main view
    var body: some View {
        HStack {
            Image.Icons.Search.magnifyingGlass
                .renderingMode(.template)
                .resizable()
                .scaledToFit()
                .frame(height: Constants.textfieldIconSize)
                .foregroundColor(colorPalette.typefacePrimary.withOpacity(.eighty))
            
            FocusTextField(
                text: $text,
                isEnabled: .constant(true),
                isRevealed: .constant(true),
                isFocused: $isFocused,
                placeholder: label,
                largeTextPlaceholder: nil,
                keyboardType: nil,
                autoCaps: UITextAutocapitalizationType.none,
                spellCheckingEnabled: true)
            .font(.Body1.regular())
            .frame(height: Constants.textfieldHeight * scale)
            
            Spacer()
            
            if isEditing {
                Button(action: {
                    self.isEditing = false
                    self.text = ""
                    hideKeyboard()
                }) {
                    Image.Icons.Xmark.standard
                        .resizable()
                        .renderingMode(.template)
                        .frame(width: Constants.xmarkWidth, height: Constants.xmarkWidth)
                        .foregroundColor(colorPalette.textGrey1.withOpacity(.eighty))
                }
            }
        }
        .padding(Constants.padding)
        .background(colorPalette.typefaceInvert)
        .cornerRadius(Constants.cornerRadius)
        .overlay(
            RoundedRectangle(cornerRadius: Constants.cornerRadius)
                .stroke(isFocused ? colorPalette.primaryBlue : colorPalette.textGrey1.withOpacity(.eighty), lineWidth: Constants.borderWidth)
        )
    }
}

#if DEBUG
struct SearchBarView_Previews: PreviewProvider {
    static var previews: some View {
        SearchBarView(container: .preview, text: .constant(""), isEditing: .constant(false))
            .previewLayout(.sizeThatFits)
            .previewCases()
            .padding()
    }
}
#endif
