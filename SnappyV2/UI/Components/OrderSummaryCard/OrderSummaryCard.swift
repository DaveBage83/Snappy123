//
//  OrderSummaryCard.swift
//  SnappyV2
//
//  Created by David Bage on 28/02/2022.
//

import SwiftUI

struct OrderSummaryCard: View {
    @ScaledMetric var scale: CGFloat = 1 // Used to scale icon for accessibility options
    @Environment(\.colorScheme) var colorScheme
    
    private typealias SummaryStrings = Strings.OrderSummaryCard
    
    // MARK: - Constants
    
    struct Constants {
        struct General {
            static let cornerRadius: CGFloat = 15
            static let height: CGFloat = 130
            static let padding: CGFloat = 16
            static let hSpacing: CGFloat = 16
        }
        
        struct StoreLogo {
            static let size: CGFloat = 96
            static let cornerRadius: CGFloat = 10
        }
        
        struct DeliveryStatus {
            static let hPadding: CGFloat = 12
            static let cornerRadiung: CGFloat = 15
            static let height: CGFloat = 18
            static let bottomPadding: CGFloat = 12
        }
        
        struct OrderSummary {
            static let textHeight: CGFloat = 16
            
            struct StoreName {
                static let bottomPadding: CGFloat = 4
            }
            
            struct SelectedSlot {
                static let bottomPadding: CGFloat = 8
            }
            
            struct ProgressBar {
                static let bottomPadding: CGFloat = 10
            }
        }
        
        struct ProgressBar {
            static let height: CGFloat = 4
        }
        
        struct Chevron {
            static let height: CGFloat = 14
        }
        
        struct FulfilmentIcon {
            static let width: CGFloat = 16
        }
        
        struct OrderTotalStack {
            static let spacing: CGFloat = 4
        }
    }
    
    // MARK: - View model
    
    @StateObject var viewModel: OrderSummaryCardViewModel
    
    var colorPalette: ColorPalette {
        ColorPalette(container: viewModel.container, colorScheme: colorScheme)
    }
    
    let includeNavigation: Bool
    let includeAddress: Bool
    
    init(container: DIContainer, order: PlacedOrderSummary?, basket: Basket?, includeNavigation: Bool = true, includeAddress: Bool = true) {
        self._viewModel = .init(wrappedValue: .init(container: container, order: order, basket: basket))
        self.includeNavigation = includeNavigation
        self.includeAddress = includeAddress
    }
    
    // MARK: - Main body
    
    var body: some View {
        HStack(spacing: Constants.General.hSpacing) {
            storeLogo
            orderSummary
        }
        .padding(.vertical)
        .padding(.horizontal, Constants.General.padding)
        .background(colorPalette.secondaryWhite)
        .standardCardFormat()
    }
    
    // MARK: - Store logo
    
    @ViewBuilder private var storeLogo: some View {
        AsyncImage(container: viewModel.container, urlString: viewModel.storeLogoURLString)
            .scaledToFit()
            .frame(width: Constants.StoreLogo.size)
            .cornerRadius(Constants.StoreLogo.cornerRadius)
    }
    
    // MARK: - Delivery status view
    
    private var deliveryStatus: some View {
        HStack {
            OrderStatusPill(
                container: viewModel.container,
                title: viewModel.status ?? "",
                status: viewModel.statusType ?? .standard,
                size: .large,
                type: .pill)
            
            Spacer()
            
            (viewModel.fulfilmentType == .delivery ? Image.Icons.Truck.standard : Image.Icons.BagShopping.standard)
                .renderingMode(.template)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: Constants.FulfilmentIcon.width)
                .foregroundColor(colorPalette.primaryBlue)
        }
    }
    
    // MARK: - Order total view
    
    private var orderTotal: some View {
        HStack {
            Text(SummaryStrings.total.localized)
                .font(.Body2.regular())
                .foregroundColor(colorPalette.textGrey1)
                .frame(height: Constants.OrderSummary.textHeight * scale)
            
            Text(viewModel.orderTotal ?? "")
                .font(.button2())
                .foregroundColor(colorPalette.primaryBlue)
                .frame(height: Constants.OrderSummary.textHeight * scale)
        }
        .font(.snappyBody)
    }
    
    // MARK: - Order total stack
    
    private var orderTotalStack: some View {
        HStack(spacing: Constants.OrderTotalStack.spacing) {
            orderTotal
            Spacer()
            if includeNavigation {
                Image.Icons.Chevrons.Right.heavy
                    .renderingMode(.template)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: Constants.Chevron.height * scale)
                    .foregroundColor(colorPalette.primaryBlue)
            }
        }
    }
    
    // MARK: - Order summary stack
    
    private var orderSummary: some View {
        VStack(alignment: .leading, spacing: 0) {
            deliveryStatus
                .padding(.bottom, Constants.DeliveryStatus.bottomPadding)
            
            storeAddress
                .padding(.bottom, 10)
            
            Text(viewModel.selectedSlot ?? "")
                .font(.Body2.semiBold())
                .fontWeight(.semibold)
                .foregroundColor(.snappyBlue)
                .padding(.bottom, Constants.OrderSummary.SelectedSlot.bottomPadding)
                .frame(height: Constants.OrderSummary.textHeight * scale)
            if let progress = viewModel.orderProgress {
                ProgressBarView(value: progress, maxValue: 1, backgroundColor: .snappyBGFields1, foregroundColor: viewModel.statusType == .success ? .green : viewModel.statusType == .error ? .snappyRed : .snappyBlue)
                    .frame(height: Constants.ProgressBar.height * scale)
                    .padding(.bottom, Constants.OrderSummary.ProgressBar.bottomPadding)
            }
            
            orderTotalStack
        }
    }
    
    private var storeAddress: some View {
        VStack(alignment: .leading, spacing: 10) {
            if includeAddress {
                if let storeName = viewModel.storeName {
                    Text(storeName)
                        .foregroundColor(colorPalette.typefacePrimary)
                        .font(.Body2.semiBold())
                        .padding(.bottom, Constants.OrderSummary.StoreName.bottomPadding)
                }
                
                
                if let address = viewModel.concatenatedAddress {
                    Text(address)
                        .foregroundColor(colorPalette.typefacePrimary)
                        .font(.Body2.semiBold())
                        .padding(.bottom, Constants.OrderSummary.StoreName.bottomPadding)
                }
                
            } else if let address = viewModel.storeWithAddress1 {
            
                Text(address)
                    .foregroundColor(colorPalette.typefacePrimary)
                    .font(.Body2.semiBold())
                    .frame(height: Constants.OrderSummary.textHeight * scale)
                    .padding(.bottom, Constants.OrderSummary.StoreName.bottomPadding)
            }
        }
    }
}

#if DEBUG
struct OrderSummaryCard_Previews: PreviewProvider {
    static var previews: some View {
        OrderSummaryCard(container: .preview, order: .init(
            id: 123,
            businessOrderId: 123,
            store: PlacedOrderStore(
                id: 910,
                name: "Master Testtt",
                originalStoreId: nil,
                storeLogo: [
                    "mdpi_1x": URL(string: "https://www.snappyshopper.co.uk/uploads/images/stores/mdpi_1x/1589564824552274_13470292_2505971_9c972622_image.png")!,
                    "xhdpi_2x": URL(string: "https://www.snappyshopper.co.uk/uploads/images/stores/xhdpi_2x/1589564824552274_13470292_2505971_9c972622_image.png")!,
                    "xxhdpi_3x": URL(string: "https://www.snappyshopper.co.uk/uploads/images/stores/xxhdpi_3x/1589564824552274_13470292_2505971_9c972622_image.png")!
                ],
                address1: "Gallanach Rd sdssd sdsd s sd sdsdsd sdsd",
                address2: nil,
                town: "Oban",
                postcode: "PA34 4PD",
                telephone: "07986238097",
                latitude: 56.4087526,
                longitude: -5.4875930999999998
            ),
            status: "Test",
            statusText: "Test",
            fulfilmentMethod: PlacedOrderFulfilmentMethod(
                name: RetailStoreOrderMethodType.delivery,
                processingStatus: "Store Accepted / Picking",
                datetime: PlacedOrderFulfilmentMethodDateTime(
                    requestedDate: "2022-02-18",
                    requestedTime: "17:40 - 17:55",
                    estimated: Date(timeIntervalSince1970: 1632146400),
                    fulfilled: nil
                ),
                place: nil,
                address: nil,
                driverTip: 1.5,
                refund: nil,
                deliveryCost: 1,
                driverTipRefunds: nil
            ),
            totalPrice: 1),
                         basket: nil)
    }
}
#endif
