//
//  RetailStoreDeliveryTiers.swift
//  SnappyV2
//
//  Created by David Bage on 17/10/2022.
//

import SwiftUI

struct RetailStoreDeliveryTiers: View {
    typealias TierString = Strings.StoresView.DeliveryTiers
    
    @Environment(\.colorScheme) var colorScheme
    @StateObject var viewModel: RetailStoreDeliveryTiersViewModel
    
    struct Constants {
        static let gridVSpacing: CGFloat = 8
        static let bottomPadding: CGFloat = 30
    }
    
    // Grid layout
    
    let columns = [
        GridItem(.flexible(), alignment: .center),
        GridItem(.flexible(), alignment: .center)
    ]
    
    private var colorPalette: ColorPalette {
        .init(container: viewModel.container, colorScheme: colorScheme)
    }
    
    var body: some View {
        if let deliveryTiers = viewModel.deliveryTiers {
            VStack(spacing: 0) {
                Divider()
                VStack {
                    if let minSpend = viewModel.minSpend {
                        Text(minSpend)
                            .font(.Body1.semiBold())
                    }
                    
                    LazyVGrid(columns: columns, spacing: Constants.gridVSpacing) {
                        Group {
                            Text(TierString.orderValue.localized)
                            Text(TierString.delivery.localized)
                        }
                        .font(.Body1.semiBold())
                        
                        if let currency = viewModel.currency {
                            ForEach(deliveryTiers.deliveryTiers, id: \.self) { tier in
                                Text(tier.minBasketSpend.toCurrencyString(using: currency))
                                Text(tier.deliveryFee.toCurrencyString(using: currency))
                            }
                            .font(.Body1.regular())
                        } else {
                            ForEach(deliveryTiers.deliveryTiers, id: \.self) { tier in
                                Text(tier.minBasketSpend.toCurrencyString(using: AppV2Constants.Business.defaultStoreCurrency))
                                Text(tier.deliveryFee.toCurrencyString(using: AppV2Constants.Business.defaultStoreCurrency))
                            }
                            .font(.Body1.regular())
                        }
                    }
                    
                    Text(TierString.orderValueCondition.localized)
                        .font(.Body2.regular())
                        .padding(.top)
                }
                .padding(.bottom, Constants.bottomPadding)
                .padding(.top)
                .edgesIgnoringSafeArea(.bottom)
                .background(colorPalette.backgroundMain)
            }
        }
    }
}

#if DEBUG
struct RetailStoreDeliveryTiers_Previews: PreviewProvider {
    static var previews: some View {
        RetailStoreDeliveryTiers(viewModel: .init(
            container: .preview,
            deliveryOrderMethod: .init(
                name: .delivery,
                earliestTime: "",
                status: .open,
                cost: 1,
                fulfilmentIn: nil,
                freeFulfilmentMessage: nil,
                deliveryTiers: [
                    .init(minBasketSpend: 5, deliveryFee: 3)
                ],
                freeFrom: nil,
                minSpend: nil),
            currency: .init(currencyCode: "GBP", symbol: "£", ratio: 1, symbolChar: "£", name: "Pound")))
    }
}
#endif
