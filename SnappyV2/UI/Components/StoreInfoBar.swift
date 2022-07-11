//
//  StoreInfoBar.swift
//  SnappyV2
//
//  Created by David Bage on 10/06/2022.
//

import SwiftUI

struct StoreInfoBar: View {
    // MARK: - Environment objects
    @Environment(\.colorScheme) var colorScheme
    
    // MARK: - Constants
    struct Constants {
        struct ShopLogo {
            static let width: CGFloat = 24
            static let padding: CGFloat = 3
        }
        
        struct Main {
            static let vPadding: CGFloat = 12
        }
    }
    
    // MARK: - Properties
    let container: DIContainer
    let store: RetailStoreDetails
    
    private var colorPalette: ColorPalette {
        ColorPalette(container: container, colorScheme: colorScheme)
    }
    
    // MARK: - Main view
    var body: some View {
        HStack{
            AsyncImage(urlString: store.storeLogo?[AppV2Constants.API.imageScaleFactor]?.absoluteString, placeholder: {
                Image.Placeholders.productPlaceholder
                    .resizable()
                    .scaledToFit()
            })
            .scaledToFit()
            .frame(width: Constants.ShopLogo.width)
            .clipShape(Circle())
            .padding(Constants.ShopLogo.padding)
            .overlay(
                Circle()
                    .fill(colorPalette.secondaryDark.withOpacity(.ten))
                
            )
            
            Text(store.nameWithAddress1)
                .font(.button2())
                .foregroundColor(colorPalette.typefacePrimary)
            
            Spacer()
        }
        .padding(.vertical, Constants.Main.vPadding)
        .background(colorPalette.secondaryWhite)
        .frame(maxWidth: .infinity)
        .fixedSize(horizontal: false, vertical: true)
    }
}

#if DEBUG
struct StoreInfoBar_Previews: PreviewProvider {
    static var previews: some View {
        StoreInfoBar(container: .preview, store: RetailStoreDetails(
            id: 123,
            menuGroupId: 123,
            storeName: "My Test Store",
            telephone: "09292929292",
            lat: 1,
            lng: 1,
            ordersPaused: false,
            canDeliver: true,
            distance: nil,
            pausedMessage: nil,
            address1: "38 My Road",
            address2: "Wallingham",
            town: "Exeter",
            postcode: "EX12 9EG",
            customerOrderNotePlaceholder: nil,
            memberEmailCheck: nil,
            guestCheckoutAllowed: true,
            basketOnlyTimeSelection: true,
            ratings: nil,
            tips: nil,
            storeLogo: nil,
            storeProductTypes: nil,
            orderMethods: nil,
            deliveryDays: [],
            collectionDays: [],
            paymentMethods: nil,
            paymentGateways: nil,
            allowedMarketingChannels: [],
            timeZone: nil,
            searchPostcode: nil))
    }
}
#endif
