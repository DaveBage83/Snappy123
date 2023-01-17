//
//  GlobalSearchCategoryCard.swift
//  SnappyV2
//
//  Created by David Bage on 14/06/2022.
//

import SwiftUI

struct GlobalSearchCategoryCard: View {
    // MARK: - Environment objects
    @Environment(\.colorScheme) var colorScheme
    
    // MARK: - Constants
    struct Constants {
        static let itemImageHeight: CGFloat = 80
        static let cardWidth: CGFloat = 120
        static let spacing: CGFloat = 8
        static let lineLimit: Int = 3
        static let minFontScale: CGFloat = 0.6
    }
    
    // MARK: - Properties
    let container: DIContainer
    let category: GlobalSearchResultRecord
    
    // MARK: - Computed variables
    private var colorPalette: ColorPalette {
        ColorPalette(container: container, colorScheme: colorScheme)
    }
    
    // MARK: - Main view
    var body: some View {
        VStack(spacing: Constants.spacing) {
            AsyncImage(container: container, urlString: category.image?[AppV2Constants.API.imageScaleFactor]?.absoluteString)
                .scaledToFit()
                .frame(width: Constants.itemImageHeight)
            
            Spacer()
            
            Text(category.name)
                .font(.heading4())
                .lineLimit(Constants.lineLimit)
                .minimumScaleFactor(Constants.minFontScale)
                .foregroundColor(colorPalette.primaryBlue)
        }
        .padding(Constants.spacing)
        .frame(width: Constants.cardWidth)
        .frame(maxHeight: .infinity)
        .background(colorPalette.secondaryWhite)
        .standardCardFormat(container: container)
    }
}

#if DEBUG
struct GlobalSearchCategoryCard_Previews: PreviewProvider {
    static var previews: some View {
        GlobalSearchCategoryCard(container: .preview, category: GlobalSearchResultRecord(id: 123, name: "Cheese", image: nil, price: nil))
    }
}
#endif
