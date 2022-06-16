//
//  SnappyTopNavigation.swift
//  SnappyV2
//
//  Created by David Bage on 13/06/2022.
//

import SwiftUI

struct SnappyTopNavigation: View {
    // MARK: - Environment objects
    @Environment(\.sizeCategory) var sizeCategory: ContentSizeCategory
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.horizontalSizeClass) var sizeClass
    
    // MARK: - Constants
    private struct Constants {
        struct Logo {
            static let width: CGFloat = 207.25
            static let largeScreenWidthMultiplier: CGFloat = 1.5
        }
        
        struct SearchBar {
            static let padding: CGFloat = 10
        }
    }
    
    // MARK: - Properties
    let container: DIContainer
    let withLogo: Bool
    
    // MARK: - Binding properties
    @Binding var text: String
    @Binding var isEditing: Bool
    
    // MARK: - Computed variables
    private var colorPalette: ColorPalette {
        ColorPalette(container: container, colorScheme: colorScheme)
    }
    
    private var adoptMinimalLayout: Bool {
        sizeCategory.size > 7 && sizeClass == .compact
    }
    
    // MARK: - Main view
    var body: some View {
        VStack {
            if withLogo {
                Image.Branding.Logo.inline
                    .resizable()
                    .scaledToFit()
                    .frame(width: Constants.Logo.width * (sizeClass == .compact ? 1 : Constants.Logo.largeScreenWidthMultiplier))
                    .padding(.top)
            }
            
            SearchBarView(container: container, label: Strings.ProductsView.searchStore.localized, text: $text, isEditing: $isEditing)
                .padding(.top, Constants.SearchBar.padding)
                .padding(.bottom, adoptMinimalLayout ? Constants.SearchBar.padding : 0)
            
            if !adoptMinimalLayout, let store = container.appState.value.userData.selectedStore.value {
                StoreInfoBar(container: container, store: store)
            }
        }
        .padding(.horizontal)
        .background(colorPalette.secondaryWhite)
    }
}

#if DEBUG
struct SnappyTopNavigation_Previews: PreviewProvider {
    static var previews: some View {
        SnappyTopNavigation(container: .preview, withLogo: true, text: .constant(""), isEditing: .constant(false))
    }
}
#endif
