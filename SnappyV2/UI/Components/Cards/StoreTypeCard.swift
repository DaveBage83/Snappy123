//
//  StoreTypeCard.swift
//  SnappyV2
//
//  Created by David Bage on 15/05/2022.
//

import SwiftUI

struct StoreTypeCard: View {
    struct Constants {
        static let height: CGFloat = 104
        static let minCornerRadius: CGFloat = 8
        static let maxCornerRadius: CGFloat = 16
        static let deSelectedOpacity: CGFloat = 0.4
    }
    
    let container: DIContainer
    let storeType: RetailStoreProductType
    @Binding var selected: Bool
    @ObservedObject var viewModel: StoresViewModel
    
    private var active: Bool {
        if selected || viewModel.filteredRetailStoreType == nil {
            return true
        }
        return false
    }
    
    var body: some View {
        if let storeLogo = storeType.image?[AppV2Constants.API.imageScaleFactor]?.absoluteString, let imageURL = URL(string: storeLogo) {
            RemoteImageView(viewModel: .init(container: container, imageURL: imageURL))
                .scaledToFit()
                .frame(height: Constants.height)
                .cornerRadius(Constants.minCornerRadius, corners: [.topLeft, .bottomRight])
                .cornerRadius(Constants.maxCornerRadius, corners: [.topRight, .bottomLeft])
                .opacity(active ? 1 : Constants.deSelectedOpacity)
        }
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
