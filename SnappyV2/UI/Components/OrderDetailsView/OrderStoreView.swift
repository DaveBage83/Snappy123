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
    // MARK: - Constants
    
    struct Constants {
        static let hSpacing: CGFloat = 30
        static let cornerRadius: CGFloat = 6
        
        struct Logo {
            static let cornerRadius: CGFloat = 10
            static let size: CGFloat = 100
        }
        
        struct StoreInfo {
            static let spacing: CGFloat = 10
        }
    }
    
    // MARK: - View model
    
    @StateObject var viewModel: OrderStoreViewModel
    
    // MARK: - Main body
    var body: some View {
        HStack(spacing: Constants.hSpacing) {
            storeLogo
            storeInfoView
            Spacer()
        }
        .padding()
        .background(Color.white)
        .cornerRadius(Constants.cornerRadius)
        .snappyShadow()
    }
    
    // MARK: - Store logo
    
    @ViewBuilder private var storeLogo: some View {
        if let logo = viewModel.storeLogo, let imageURL = URL(string: logo) {
            RemoteImageView(viewModel: .init(container: viewModel.container, imageURL: imageURL))
                .frame(width: Constants.Logo.size, height: Constants.Logo.size)
                .scaledToFit()
                .cornerRadius(Constants.Logo.cornerRadius)
        } else {
            Image.Stores.convenience
                .resizable()
                .frame(width: Constants.Logo.size, height: Constants.Logo.size)
                .scaledToFit()
                .cornerRadius(Constants.Logo.cornerRadius)
        }
    }
    
    // MARK: - Store info view
    
    private var storeInfoView: some View {
        VStack(alignment: .leading, spacing: Constants.StoreInfo.spacing) {
            VStack(alignment: .leading) {
                Text(Strings.PlacedOrders.OrderStoreView.store.localized)
                    .font(.snappyCaption)
                Text(viewModel.storeName)
                    .font(.snappyBody)
                    .fontWeight(.semibold)
            }
            
            HStack(alignment: .top) {
                Image.OrderStore.address
                    .foregroundColor(.snappyBlue)
                
                VStack(alignment: .leading) {
                    Text(viewModel.address1)
                    if let address2 = viewModel.address2 {
                        Text(address2)
                    }
                    
                    Text(viewModel.town)
                    Text(viewModel.postcode)
                }
                .font(.snappyCaption)
            }
            
            HStack {
                Image.OrderStore.phone
                    .foregroundColor(.snappyBlue)
                Text(viewModel.telephone)
                    .font(.snappyCaption)
                    .foregroundColor(.snappyBlue)
                    .fontWeight(.semibold)
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
