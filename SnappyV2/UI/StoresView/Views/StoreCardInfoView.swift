//
//  StoreCardInfoView.swift
//  SnappyV2Study
//
//  Created by Henrik Gustavii on 14/06/2021.
//

import SwiftUI

struct StoreCardInfoView: View {
    // MARK: - Environment objects
    @Environment(\.sizeCategory) var sizeCategory: ContentSizeCategory
    @Environment(\.horizontalSizeClass) var sizeClass
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.mainWindowSize) var mainWindowSize

    @ScaledMetric var scale: CGFloat = 1 // Used to scale icon for accessibility options
    
    // MARK: - TypeAliases
    typealias DeliveryStrings = Strings.StoreInfo.Delivery
    
    struct Constants {
        struct Logo {
            static let size: CGFloat = 96
            static let cornerRadius: CGFloat = 8
            static let reviewPillYOffset: CGFloat = 9
        }
        
        struct General {
            static let minimalLayoutThreshold: Int = 7
            static let maxPadding: CGFloat = 12
            static let minPadding: CGFloat = 5
        }
        
        struct Icons {
            static let width: CGFloat = 18
            static let spacing: CGFloat = 4
        }
        
        struct IconInfoStacks {
            static let spacing: CGFloat = 2
            static let maxWidthMultiplier: CGFloat = 0.33
        }
        
        struct FreeDeliveryPill {
            static let spacing: CGFloat = 4
            static let iconFrameWidth: CGFloat = 11
            static let vPadding: CGFloat = 4
            static let hPadding: CGFloat = 8
        }
        
        struct DeliveryFee {
            static let iconFrameWidth: CGFloat = 16
            static let spacing: CGFloat = 2
        }
    }
    
    // MARK: - View model
    @StateObject var viewModel: StoreCardInfoViewModel
    @Binding var isLoading: Bool
    
    // MARK: - Computed variables
    private var colorPalette: ColorPalette {
        ColorPalette(container: viewModel.container, colorScheme: colorScheme)
    }
    
    private var minimalLayout: Bool {
        sizeCategory.size > Constants.General.minimalLayoutThreshold && sizeClass == .compact
    }
    
    // MARK: - Main view
    var body: some View {
        mainBody
            .background(colorPalette.secondaryWhite)
            .standardCardFormat(container: viewModel.container, isHighlighted: $viewModel.isSelectedStore)
            .withLoadingToast(container: viewModel.container, loading: $isLoading)
    }
    
    private var mainBody: some View {
        VStack {
            HStack(alignment: .center) {
                if minimalLayout == false { // do not show logo when sizeCategory.size font size over 7
                    logo
                }
                
                VStack(alignment: .leading) {
                    Text(viewModel.storeDetails.storeName)
                        .font(.Body1.semiBold())
                        .foregroundColor(colorPalette.typefacePrimary)
                    
                    HStack(spacing: Constants.IconInfoStacks.spacing) {
                        HStack {
                            deliveryTime
                            Spacer()
                        }
                        .frame(maxWidth: mainWindowSize.width * Constants.IconInfoStacks.maxWidthMultiplier)
                        
                        HStack {
                            distance
                            Spacer()
                        }
                        .frame(maxWidth: .infinity)
                    }
                    
                    HStack(spacing: Constants.IconInfoStacks.spacing) {
                        HStack {
                            minSpend
                            Spacer()
                        }
                        .frame(maxWidth: mainWindowSize.width * Constants.IconInfoStacks.maxWidthMultiplier)

                        if let fromDeliveryCost = viewModel.orderDeliveryMethod?.fromDeliveryCost(currency: viewModel.currency) {
                            
                            HStack {
                                deliveryFee(fromDeliveryCost: fromDeliveryCost)
                                Spacer()
                            }
                            .frame(maxWidth: .infinity)
                        }
                    }
                    
                    if let deliveryOffer = viewModel.freeDeliveryText {
                        freeDeliveryPill(deliveryOffer: deliveryOffer)
                    }
                }
                .fixedSize(horizontal: false, vertical: true)
                .multilineTextAlignment(.leading)
            }
            .padding([.leading, .vertical], Constants.General.maxPadding)
            .padding(.trailing, Constants.General.minPadding)
            .frame(maxWidth: .infinity)
            Spacer()
        }
        .frame(maxHeight: .infinity)
    }
    
    private func freeDeliveryPill(deliveryOffer: String) -> some View {
        HStack(spacing: Constants.FreeDeliveryPill.spacing) {
            Image.Icons.Tag.filled
                .renderingMode(.template)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: Constants.FreeDeliveryPill.iconFrameWidth)
                .foregroundColor(colorPalette.alertSuccess)
            Text(deliveryOffer)
        }
        .font(.Body2.semiBold())
        .foregroundColor(colorPalette.alertSuccess)
        .padding(.vertical, Constants.FreeDeliveryPill.vPadding)
        .padding(.horizontal, Constants.FreeDeliveryPill.hPadding)
        .background(Color.white)
        .standardPillFormat()
    }
    
    private func deliveryFee(fromDeliveryCost: (hasTiers: Bool, text: String)) -> some View {
        HStack(spacing: Constants.Icons.spacing) {
            infoStackIcon(image: viewModel.showDeliveryCost ? Image.Icons.Delivery.standard : Image.Icons.BagShopping.heavy)
                .frame(width: Constants.Icons.width)
            
            HStack(spacing: Constants.DeliveryFee.spacing) {
                if fromDeliveryCost.hasTiers, viewModel.showDeliveryCost {
                    Text(GeneralStrings.from.localized)
                        .font(.Caption2.bold())
                        .foregroundColor(colorPalette.typefacePrimary)
                }
                Text(viewModel.showDeliveryCost ? fromDeliveryCost.text : GeneralStrings.free.localized)
                    .font(.Body1.semiBold())
                    .foregroundColor(colorPalette.typefacePrimary)
            }
        }
    }
    
    private func infoStackIcon(image: Image) -> some View {
        image
            .renderingMode(.template)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(height: Constants.DeliveryFee.iconFrameWidth)
            .foregroundColor(colorPalette.primaryBlue)
    }
    
    // MARK: - Logo
    private var logo: some View {
        ZStack(alignment: .bottom) {
            AsyncImage(container: viewModel.container, urlString: viewModel.storeDetails.storeLogo?[AppV2Constants.API.imageScaleFactor]?.absoluteString)
                .frame(width: Constants.Logo.size, height: Constants.Logo.size)
                .scaledToFit()
                .cornerRadius(Constants.Logo.cornerRadius)
            
            if let ratings = viewModel.storeDetails.ratings {
                StoreReviewPill(container: viewModel.container, rating: ratings)
                    .offset(y: Constants.Logo.reviewPillYOffset * scale)
            }
        }
    }
    
    // MARK: - Delivery time
    private var deliveryTime: some View {
        HStack(spacing: Constants.Icons.spacing) {
            infoStackIcon(image: Image.Icons.Clock.heavy)
                .frame(width: Constants.Icons.width)
            
            if viewModel.isClosed {
                Text(Strings.StoreInfo.Status.closed.localized)
                    .font(.Body1.semiBold())
                    .foregroundColor(colorPalette.primaryRed)
            } else {
                if let fulfilmentIn = viewModel.fulfilmentTime {
                    Text(fulfilmentIn)
                        .font(.Body1.semiBold())
                        .foregroundColor(colorPalette.typefacePrimary)
                }
            }
        }
        .multilineTextAlignment(.leading)
    }
    
    private var minSpend: some View {
        HStack(spacing: Constants.Icons.spacing) {
            infoStackIcon(image: Image.Icons.Basket.heavy)
                .frame(width: Constants.Icons.width)
            
            Text(viewModel.minOrder)
                .font(.Body1.semiBold())
                .foregroundColor(colorPalette.typefacePrimary)
        }
    }
    
    // MARK: - Distance
    private var distance: some View {
        HStack(spacing: Constants.Icons.spacing) {
            infoStackIcon(image: Image.Icons.LocationDot.heavy)
                .frame(width: Constants.Icons.width)
            
            Text(DeliveryStrings.Customisable.distanceShort.localizedFormat(viewModel.distance))
                .font(.Body1.semiBold())
                .foregroundColor(colorPalette.typefacePrimary)
        }
    }
}

#if DEBUG
struct StoreCardInfoView_Previews: PreviewProvider {
    static var previews: some View {
        StoreCardInfoView(viewModel: StoreCardInfoViewModel(container: .preview, storeDetails: RetailStore(id: 123, storeName: "Coop", distance: 0.47, storeLogo: nil, storeProductTypes: nil, orderMethods: ["delivery": RetailStoreOrderMethod.init(name: .delivery, earliestTime: "01:50 - 02:05", status: .open, cost: 5, fulfilmentIn: nil, freeFulfilmentMessage: "Free from £10", deliveryTiers: nil, freeFrom: nil, minSpend: nil)], ratings: RetailStoreRatings(averageRating: 4, numRatings: 54), currency: RetailStoreCurrency(currencyCode: "GBP", symbol: "&pound;", ratio: 0, symbolChar: "£", name: "Great British Pound"))), isLoading: .constant(false))
            .previewLayout(.sizeThatFits)
            .padding()
            .previewDevice(PreviewDevice(rawValue: "iPod touch (7th generation) (15.5)"))

        
        StoreCardInfoView(viewModel: StoreCardInfoViewModel(container: .preview, storeDetails: RetailStore(id: 123, storeName: "Keystore", distance: 5.4, storeLogo: nil, storeProductTypes: nil, orderMethods: ["delivery": RetailStoreOrderMethod.init(name: .delivery, earliestTime: "20-30 mins", status: .open, cost: 3.5, fulfilmentIn: nil, freeFulfilmentMessage: nil, deliveryTiers: nil, freeFrom: nil, minSpend: nil)], ratings: nil, currency: RetailStoreCurrency(currencyCode: "GBP", symbol: "&pound;", ratio: 0, symbolChar: "£", name: "Great British Pound"))), isLoading: .constant(false))
            .previewLayout(.sizeThatFits)
            .padding()
        
        StoreCardInfoView(viewModel: StoreCardInfoViewModel(container: .preview, storeDetails: RetailStore(id: 123, storeName: "Coop", distance: 1.4, storeLogo: nil, storeProductTypes: nil, orderMethods: ["delivery": RetailStoreOrderMethod.init(name: .delivery, earliestTime: "20-30 mins", status: .open, cost: nil, fulfilmentIn: nil, freeFulfilmentMessage: nil, deliveryTiers: nil, freeFrom: nil, minSpend: nil)], ratings: nil, currency: RetailStoreCurrency(currencyCode: "GBP", symbol: "&pound;", ratio: 0, symbolChar: "£", name: "Great British Pound"))), isLoading: .constant(false))
            .previewLayout(.sizeThatFits)
            .padding()
        
        StoreCardInfoView(viewModel: StoreCardInfoViewModel(container: .preview, storeDetails: RetailStore(id: 123, storeName: "Keystore", distance: 5.4, storeLogo: nil, storeProductTypes: nil, orderMethods: ["delivery": RetailStoreOrderMethod.init(name: .delivery, earliestTime: "20-30 mins", status: .open, cost: 3.5, fulfilmentIn: nil, freeFulfilmentMessage: nil, deliveryTiers: nil, freeFrom: nil, minSpend: nil)], ratings: nil, currency: RetailStoreCurrency(currencyCode: "GBP", symbol: "&pound;", ratio: 0, symbolChar: "£", name: "Great British Pound"))), isLoading: .constant(false))
            .previewLayout(.sizeThatFits)
            .padding()
    }
}
#endif
