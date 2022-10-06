//
//  StoreTypeCard.swift
//  SnappyV2
//
//  Created by David Bage on 15/05/2022.
//

import SwiftUI

struct StoreTypeCard: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.horizontalSizeClass) var sizeClass
    @Environment(\.sizeCategory) var sizeCategory: ContentSizeCategory
    
    struct Constants {
        static let height: CGFloat = 104
        static let minCornerRadius: CGFloat = 8
        static let maxCornerRadius: CGFloat = 16
        static let deSelectedOpacity: CGFloat = 0.4
        static let minimalLayoutThreshold = 5
        
        struct Label {
            static let vPadding: CGFloat = 10
            static let hPadding: CGFloat = 8
            static let backgroundOpacity: CGFloat = 0.7
            static let minimumScaleFactor: CGFloat = 0.01
            static let lineLimit = 10
        }
    }
    
    let container: DIContainer
    let storeType: RetailStoreProductType
    @Binding var selected: Bool
    @ObservedObject var viewModel: StoresViewModel
    
    private var colorPalette: ColorPalette {
        ColorPalette(container: container, colorScheme: colorScheme)
    }
    
    private var minimalLayout: Bool {
        sizeCategory.size > Constants.minimalLayoutThreshold && sizeClass == .compact
    }
    
    private var active: Bool {
        if selected || viewModel.filteredRetailStoreType == nil {
            return true
        }
        return false
    }
    
    private var fontColor: Color {
        .black.opacity(active ? 0.8 : 0.3)
    }
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            AsyncImage(urlString: storeType.image?[AppV2Constants.API.imageScaleFactor]?.absoluteString, placeholder: {
                Image.Placeholders.productPlaceholder
                    .resizable()
                    .scaledToFill()
                    .cornerRadius(Constants.minCornerRadius, corners: [.topLeft, .bottomRight])
                    .cornerRadius(Constants.maxCornerRadius, corners: [.topRight, .bottomLeft])
                    .opacity(active ? 1 : Constants.deSelectedOpacity)
            })
            .scaledToFit()
            .frame(height: Constants.height)
            .cornerRadius(Constants.minCornerRadius, corners: [.topLeft, .bottomRight])
            .cornerRadius(Constants.maxCornerRadius, corners: [.topRight, .bottomLeft])
            .opacity(active ? 1 : Constants.deSelectedOpacity)
            
            if minimalLayout == false {
                HStack {
                    Text(storeType.name)
                        .font(.button2())
                        .minimumScaleFactor(Constants.Label.minimumScaleFactor) // Allows for font size to adjust to avoid breaking lines mid-word
                        .lineLimit(Constants.Label.lineLimit)
                        .padding(.vertical, Constants.Label.vPadding)
                        .padding(.horizontal, Constants.Label.hPadding)
                        .multilineTextAlignment(.leading)
                        .foregroundColor(fontColor)
                    
                    Spacer()
                }
                .frame(maxWidth: .infinity)
                .background(Color.white.opacity(Constants.Label.backgroundOpacity))
                .cornerRadius(Constants.minCornerRadius, corners: [.topLeft])
                .cornerRadius(Constants.maxCornerRadius, corners: [.topRight])
            }
        }
        .frame(width: Constants.height, height: Constants.height)
    }
}

#if DEBUG
struct StoreTypeCard_Previews: PreviewProvider {
    static var previews: some View {
        StoreTypeCard(
            container: .preview,
            storeType:  RetailStoreProductType(
                id: 21,
                name: "Convenience Stores",
                image: [
                    "mdpi_1x": URL(string: "https://www.snappyshopper.co.uk/uploads/images/store_types_full_width/mdpi_1x/1613754190stores.png")!,
                    "xhdpi_2x": URL(string: "https://www.snappyshopper.co.uk/uploads/images/store_types_full_width/xhdpi_2x/1613754190stores.png")!,
                    "xxhdpi_3x": URL(string: "https://www.snappyshopper.co.uk/uploads/images/store_types_full_width/xxhdpi_3x/1613754190stores.png")!
                ]
            ), selected: .constant(true), viewModel: .init(container: .preview))
    }
}
#endif
