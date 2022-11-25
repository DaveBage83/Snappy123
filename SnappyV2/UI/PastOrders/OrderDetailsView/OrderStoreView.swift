//
//  OrderStoreView.swift
//  SnappyV2
//
//  Created by David Bage on 05/04/2022.
//

import SwiftUI

class OrderStoreViewModel: ObservableObject {
    let container: DIContainer
    let store: PlacedOrderStore
    
    var storeName: String {
        store.name
    }
    
    var storeLogo: String? {
        store.storeLogo?[AppV2Constants.API.imageScaleFactor]?.absoluteString
    }
    
    var address1: String {
        store.address1
    }
    
    var town: String {
        store.town
    }
    
    var address2: String? {
        store.address2
    }
    
    var postcode: String {
        store.postcode
    }
    
    var telephone: String {
        store.telephone ?? Strings.PlacedOrders.OrderStoreView.unknown.localized
    }
    
    init(container: DIContainer, store: PlacedOrderStore) {
        self.store = store
        self.container = container
    }
}

struct OrderStoreView: View {
    @Environment(\.colorScheme) var colorScheme
    
    // MARK: - Constants
    
    struct Constants {
        static let hSpacing: CGFloat = 30
        static let cornerRadius: CGFloat = 6
        
        struct Logo {
            static let cornerRadius: CGFloat = 10
            static let size: CGFloat = 88
        }
        
        struct StoreInfo {
            static let spacing: CGFloat = 10
            static let locationIconWidth: CGFloat = 12
        }
    }
    
    // MARK: - View model
    
    @StateObject var viewModel: OrderStoreViewModel
    
    private var colorPalette: ColorPalette {
        .init(container: viewModel.container, colorScheme: colorScheme)
    }
    
    // MARK: - Main body
    var body: some View {
        HStack(spacing: Constants.hSpacing) {
            storeLogo
            storeInfoView
        }
        .padding()
        .background(colorPalette.secondaryWhite )
        .cornerRadius(Constants.cornerRadius)
        .snappyShadow()
    }
    
    // MARK: - Store logo
    
    @ViewBuilder private var storeLogo: some View {
        AsyncImage(container: viewModel.container, urlString: viewModel.storeLogo)
    }
    
    // MARK: - Store info view
    
    private var storeInfoView: some View {
        VStack(alignment: .leading, spacing: Constants.StoreInfo.spacing) {
            VStack(alignment: .leading) {
                Text(Strings.PlacedOrders.OrderStoreView.store.localized)
                    .font(.Caption1.semiBold())
                Text(viewModel.storeName)
                    .font(.Body1.semiBold())
            }
            
            HStack(alignment: .top) {
                Image.Icons.LocationDot.filled
                    .renderingMode(.template)
                    .resizable()
                    .scaledToFit()
                    .frame(width: Constants.StoreInfo.locationIconWidth)
                    .foregroundColor(colorPalette.primaryBlue)
                                
                VStack(alignment: .leading) {
                    Text(viewModel.address1)
                        .font(.Body2.semiBold())
                        .foregroundColor(colorPalette.typefacePrimary)
                    
                    if let address2 = viewModel.address2 {
                        Text(address2)
                            .font(.Body2.semiBold())
                            .foregroundColor(colorPalette.typefacePrimary)
                    }
                    
                    Text(viewModel.town)
                        .font(.Body2.semiBold())
                        .foregroundColor(colorPalette.typefacePrimary)
                    Text(viewModel.postcode)
                        .font(.Body2.semiBold())
                        .foregroundColor(colorPalette.typefacePrimary)
                }
                Spacer()
            }
            
            HStack {
                Image.OrderStore.phone
                    .foregroundColor(colorPalette.primaryBlue)
                    .frame(width: Constants.StoreInfo.locationIconWidth)
                Text(viewModel.telephone)
                    .font(.Body2.semiBold())
                    .foregroundColor(colorPalette.primaryBlue)
                Spacer()
            }
        }
    }
}

#if DEBUG
struct OrderStoreView_Previews: PreviewProvider {
    static var previews: some View {
        OrderStoreView(viewModel: .init(container: .preview, store: PlacedOrderStore(
            id: 910,
            name: "Master Testtt",
            originalStoreId: nil,
            storeLogo: [
                "mdpi_1x": URL(string: "https://www.snappyshopper.co.uk/uploads/images/stores/mdpi_1x/1589564824552274_13470292_2505971_9c972622_image.png")!,
                "xhdpi_2x": URL(string: "https://www.snappyshopper.co.uk/uploads/images/stores/xhdpi_2x/1589564824552274_13470292_2505971_9c972622_image.png")!,
                "xxhdpi_3x": URL(string: "https://www.snappyshopper.co.uk/uploads/images/stores/xxhdpi_3x/1589564824552274_13470292_2505971_9c972622_image.png")!
            ],
            address1: "Gallanach Rd",
            address2: nil,
            town: "Oban",
            postcode: "PA34 4PD",
            telephone: "07986238097",
            latitude: 56.4087526,
            longitude: -5.4875930999999998
        )
        ))
    }
}
#endif
