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
            static let spacing: CGFloat = 24
            static let minPadding: CGFloat = 1
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
        VStack {
            HStack(alignment: .center) {
                if minimalLayout == false { // do not show logo when sizeCategory.size font size over 7
                    logo
                }
                
                VStack(alignment: .leading) {
                    Text(viewModel.storeDetails.storeName)
                        .font(.Body1.semiBold())
                        .foregroundColor(colorPalette.typefacePrimary)
                    
                    HStack(alignment: .top, spacing: Constants.General.spacing) {
                        deliveryTime
                        
                        Spacer()
                        
                        distance
                    }
                    .font(.snappyFootnote)
                    .padding(.vertical, Constants.General.minPadding)
                    
                    Text(viewModel.deliveryChargeString)
                        .font(.Body2.semiBold())
                        .foregroundColor(colorPalette.primaryBlue)
                }
                .multilineTextAlignment(.leading)
                
            }
            .padding()
            .frame(maxWidth: .infinity)
        }
        .background(colorPalette.secondaryWhite)
        .standardCardFormat()
        .toast(isPresenting: $isLoading) {
            AlertToast(displayMode: .alert, type: .loading)
        }
    }
    
    // MARK: - Logo
    private var logo: some View {
        ZStack(alignment: .bottom) {
            AsyncImage(urlString: viewModel.storeDetails.storeLogo?[AppV2Constants.API.imageScaleFactor]?.absoluteString, placeholder: {
                Image.Placeholders.productPlaceholder
                    .resizable()
                    .frame(width: Constants.Logo.size, height: Constants.Logo.size)
                    .scaledToFill()
                    .cornerRadius(Constants.Logo.cornerRadius)
            })
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
        VStack(alignment: .leading) {
            AdaptableText(
                text: GeneralStrings.deliveryTime.localized,
                altText: GeneralStrings.deliveryTimeShort.localized,
                threshold: Constants.General.minimalLayoutThreshold)
            .font(.Caption2.semiBold())
            .foregroundColor(viewModel.isClosed ? colorPalette.primaryRed : colorPalette.typefacePrimary)
            
            if viewModel.isClosed {
                Text(Strings.StoreInfo.Status.closed.localized)
                    .font(.Body1.semiBold())
                    .foregroundColor(colorPalette.primaryRed)
            } else {
                Text(viewModel.storeDetails.orderMethods?[RetailStoreOrderMethodType.delivery.rawValue]?.earliestTime ?? "-")
                    .font(.Body1.semiBold())
                    .foregroundColor(colorPalette.typefacePrimary)
            }
            
        }
        .multilineTextAlignment(.leading)
    }
    
    // MARK: - Distance
    private var distance: some View {
        VStack(alignment: .leading) {
            AdaptableText(
                text: DeliveryStrings.distance.localized,
                altText: DeliveryStrings.distanceShort.localized,
                threshold: Constants.General.minimalLayoutThreshold)
            .font(.Caption2.semiBold())
            .foregroundColor(colorPalette.typefacePrimary)
            
            AdaptableText(
                text: DeliveryStrings.Customisable.distance.localizedFormat(viewModel.distance),
                altText: DeliveryStrings.Customisable.distanceShort.localizedFormat(viewModel.distance),
                threshold: Constants.General.minimalLayoutThreshold)
            .font(.Body1.semiBold())
            .foregroundColor(colorPalette.typefacePrimary)
        }
    }
}

#if DEBUG
struct StoreCardInfoView_Previews: PreviewProvider {
    static var previews: some View {
        StoreCardInfoView(viewModel: StoreCardInfoViewModel(container: .preview, storeDetails: RetailStore(id: 123, storeName: "Coop", distance: 0.47, storeLogo: nil, storeProductTypes: nil, orderMethods: ["delivery": RetailStoreOrderMethod.init(name: .delivery, earliestTime: "01:50 - 02:05", status: .open, cost: nil, fulfilmentIn: nil)], ratings: RetailStoreRatings(averageRating: 4, numRatings: 54), currency: RetailStoreCurrency(currencyCode: "GBP", symbol: "&pound;", ratio: 0, symbolChar: "£", name: "Great British Pound"))), isLoading: .constant(false))
            .previewLayout(.sizeThatFits)
            .padding()
            .previewDevice(PreviewDevice(rawValue: "iPod touch (7th generation) (15.5)"))

        
        StoreCardInfoView(viewModel: StoreCardInfoViewModel(container: .preview, storeDetails: RetailStore(id: 123, storeName: "Keystore", distance: 5.4, storeLogo: nil, storeProductTypes: nil, orderMethods: ["delivery": RetailStoreOrderMethod.init(name: .delivery, earliestTime: "20-30 mins", status: .open, cost: 3.5, fulfilmentIn: nil)], ratings: nil, currency: RetailStoreCurrency(currencyCode: "GBP", symbol: "&pound;", ratio: 0, symbolChar: "£", name: "Great British Pound"))), isLoading: .constant(false))
            .previewLayout(.sizeThatFits)
            .padding()
        
        StoreCardInfoView(viewModel: StoreCardInfoViewModel(container: .preview, storeDetails: RetailStore(id: 123, storeName: "Coop", distance: 1.4, storeLogo: nil, storeProductTypes: nil, orderMethods: ["delivery": RetailStoreOrderMethod.init(name: .delivery, earliestTime: "20-30 mins", status: .open, cost: nil, fulfilmentIn: nil)], ratings: nil, currency: RetailStoreCurrency(currencyCode: "GBP", symbol: "&pound;", ratio: 0, symbolChar: "£", name: "Great British Pound"))), isLoading: .constant(false))
            .previewLayout(.sizeThatFits)
            .padding()
        
        StoreCardInfoView(viewModel: StoreCardInfoViewModel(container: .preview, storeDetails: RetailStore(id: 123, storeName: "Keystore", distance: 5.4, storeLogo: nil, storeProductTypes: nil, orderMethods: ["delivery": RetailStoreOrderMethod.init(name: .delivery, earliestTime: "20-30 mins", status: .open, cost: 3.5, fulfilmentIn: nil)], ratings: nil, currency: RetailStoreCurrency(currencyCode: "GBP", symbol: "&pound;", ratio: 0, symbolChar: "£", name: "Great British Pound"))), isLoading: .constant(false))
            .previewLayout(.sizeThatFits)
            .padding()
    }
}
#endif
