//
//  BasketOrderSummaryCard.swift
//  SnappyV2
//
//  Created by David Bage on 27/06/2022.
//

import SwiftUI

class BasketOrderSummaryCardViewModel: ObservableObject {
    let container: DIContainer
    let basket: Basket?
    let selectedStore: RetailStoreDetails?
    
    var selectedSlot: String {
        if let date = basket?.selectedSlot?.start?.dateShortString(storeTimeZone: nil), let time = basket?.selectedSlot?.start {
            return "\(date) | \(time)"
        }
        return Strings.PlacedOrders.OrderSummaryCard.noSlotSelected.localized
    }
    
    init(container: DIContainer, basket: Basket?, selectedStore: RetailStoreDetails?) {
        self.container = container
        self.basket = basket
        self.selectedStore = selectedStore
    }
}

struct BasketOrderSummaryCard: View {
    @Environment(\.colorScheme) var colorScheme
    
    struct Constants {
        struct Logo {
            static let size: CGFloat = 56
            static let cornerRadius: CGFloat = 8
        }
    }
    
    @StateObject var viewModel: BasketOrderSummaryCardViewModel
    
    private var colorPalette: ColorPalette {
        ColorPalette(container: viewModel.container, colorScheme: colorScheme)
    }
    
    var body: some View {
        HStack {
            AsyncImage(urlString: viewModel.selectedStore?.storeLogo?[AppV2Constants.API.imageScaleFactor]?.absoluteString, placeholder: {
                Image.Placeholders.productPlaceholder
                    .resizable()
                    .frame(width: Constants.Logo.size, height: Constants.Logo.size)
                    .scaledToFill()
                    .cornerRadius(Constants.Logo.cornerRadius)
            })
            .frame(width: Constants.Logo.size, height: Constants.Logo.size)
            .scaledToFit()
            .cornerRadius(Constants.Logo.cornerRadius)
            
            VStack {
                Text(viewModel.selectedStore?.nameWithAddress1 ?? "")
                    .font(.Body2.semiBold())
                    .foregroundColor(colorPalette.typefacePrimary)
                
                Text(viewModel.selectedSlot)
                    .font(.Body2.semiBold())
                    .foregroundColor(colorPalette.primaryBlue)
            }
        }
    }
}

struct BasketOrderSummaryCard_Previews: PreviewProvider {
    static var previews: some View {
        BasketOrderSummaryCard(viewModel: .init(container: .preview, basket: Basket(
            basketToken: "1234",
            isNewBasket: false,
            items: [BasketItem(
                basketLineId: 123,
                menuItem: RetailStoreMenuItem(
                    id: 123,
                    name: "Test item",
                    eposCode: nil,
                    outOfStock: false,
                    ageRestriction: 0,
                    description: nil,
                    quickAdd: true,
                    acceptCustomerInstructions: true,
                    basketQuantityLimit: 100,
                    price: RetailStoreMenuItemPrice(
                        price: 10,
                        fromPrice: 10,
                        unitMetric: "ee",
                        unitsInPack: 1,
                        unitVolume: 1,
                        wasPrice: nil),
                    images: nil,
                    menuItemSizes: nil,
                    menuItemOptions: nil,
                    availableDeals: nil,
                    itemCaptions: nil,
                    mainCategory: MenuItemCategory(id: 11, name: "Test category")),
                totalPrice: 10,
                totalPriceBeforeDiscounts: 10,
                price: 10,
                pricePaid: 10,
                quantity: 1,
                instructions: nil,
                size: nil,
                selectedOptions: nil,
                missedPromotions: nil)],
            fulfilmentMethod: BasketFulfilmentMethod(
                type: RetailStoreOrderMethodType.collection,
                cost: 10,
                minSpend: 10),
            selectedSlot: BasketSelectedSlot(todaySelected: true, start: nil, end: nil, expires: nil),
            savings: nil,
            coupon: nil,
            fees: nil,
            tips: nil,
            addresses: nil, orderSubtotal: 10, orderTotal: 10, storeId: nil, basketItemRemoved: nil), selectedStore: RetailStoreDetails(
                id: 11,
                menuGroupId: 11,
                storeName: "Test store",
                telephone: "01234555333",
                lat: 1,
                lng: 1,
                ordersPaused: false,
                canDeliver: true,
                distance: nil,
                pausedMessage: nil,
                address1: "Test Address 1",
                address2: "Test Address 2",
                town: "Farnham",
                postcode: "HU99EP",
                customerOrderNotePlaceholder: nil,
                memberEmailCheck: nil,
                guestCheckoutAllowed: true,
                basketOnlyTimeSelection: false,
                ratings: nil,
                tips: nil,
                storeLogo: nil,
                storeProductTypes: nil,
                orderMethods: nil,
                deliveryDays: nil,
                collectionDays: nil,
                paymentMethods: nil,
                paymentGateways: nil,
                timeZone: nil,
                searchPostcode: nil)))
    }
}
