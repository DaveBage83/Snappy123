//
//  OrderListItemView.swift
//  SnappyV2
//
//  Created by David Bage on 05/04/2022.
//

import SwiftUI

struct OrderListView: View {
    // MARK: - Env objects
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.mainWindowSize) var mainWindowSize
    
    // MARK: - Constants
    struct Constants {
        struct ItemImage {
            static let size: CGFloat = 40
            static let cornerRadius: CGFloat = 5
        }
        
        struct Lines {
            static let spacing: CGFloat = 20
        }
        
        struct Comments {
            static let widthAdjustment: CGFloat = 90 // 2 x 16 (padding) + image width + 8 padding
            static let padding: CGFloat = 8
            static let vSpacing: CGFloat = 4
        }
        
        struct ItemDetails {
            static let spacing: CGFloat = 4
        }
    }
    
    // MARK: - View model
    @StateObject var viewModel: OrderListViewModel
    
    private var colorPalette: ColorPalette {
        .init(container: viewModel.container, colorScheme: colorScheme)
    }
    
    // MARK: - Grid setup
    let columns = [
        GridItem(.fixed(50), alignment: .topLeading),
        GridItem(.flexible(minimum: 100), alignment: .topLeading),
        GridItem(.fixed(20), alignment: .topTrailing),
        GridItem(.fixed(50), alignment: .topTrailing)
    ]
    
    // MARK: - Main body
    var body: some View {
        if viewModel.showRefundedLines {
            PastOrderLineTab(
                container: viewModel.container,
                tabType: .refund,
                content: {
                    refundedLines
                })
        }
        
        if viewModel.showSubbedLines {
            PastOrderLineTab(
                container: viewModel.container,
                tabType: .substitute,
                content: {
                    subbedLines
                })
        }
        
        if viewModel.showStandardLines, let lines = viewModel.standardLines {
            VStack(spacing: Constants.Lines.spacing) {
                ForEach(lines, id: \.self) { line in
                    itemLine(mainLine: line, secondaryLine: nil)
                }
            }
        }
    }
    
    // MARK: - Refunded Lines
    private var refundedLines: some View {
        VStack(spacing: Constants.Lines.spacing) {
            if let rejectedLines = viewModel.refundedLines {
                ForEach(rejectedLines, id: \.self) { line in
                    itemLine(mainLine: line, secondaryLine: nil)
                }
            }
        }
    }
    
    // MARK: - Subbed lines
    private var subbedLines: some View {
        VStack(spacing: Constants.Lines.spacing) {
            if let subbedLines = viewModel.linesWithSubstitutes {
                ForEach(subbedLines, id: \.self) { line in
                    VStack(alignment: .leading) {
                        itemLine(mainLine: line.substitutedLine, secondaryLine: line.originalLine)
                    }
                }
            }
        }
    }
    
    // MARK: - Item line
    private func itemLine(mainLine: PlacedOrderLine, secondaryLine: PlacedOrderLine?) -> some View {
        LazyVGrid(columns: columns) {
            itemImage(item: mainLine.item)
            
            VStack(alignment: .leading, spacing: Constants.ItemDetails.spacing) {
                Text(viewModel.itemName(mainLine.item))
                    .font(.Body2.regular())
                
                if let options = mainLine.item.options {
                    ForEach(viewModel.groupedOptions(options: options), id: \.self) { option in
                        Text("\(option.optionName): ")
                            .font(.Body2.semiBold())
                        +
                        Text(option.selectedOptions.joined(separator: ", "))
                            .font(.Body2.regular())
                    }
                }
                
                Text(Strings.General.Custom.perItem.localizedFormat(mainLine.item.price.toCurrencyString(using: viewModel.order.currency)))
                    .font(.Body2.semiBold())
                
                // If we pass in a secondary line, present as a substituted item
                if let secondaryLine = secondaryLine {
                    HStack {
                        notes(
                            primaryText: Strings.PlacedOrders.OrderDetailsView.replaces.localized,
                            secondaryText: "\(secondaryLine.quantity)x \(secondaryLine.item.name)",
                            tertiaryText: mainLine.storeNote, isRefunded: false)
                        .padding(.leading, Constants.Comments.padding)
                        Spacer()
                    }
                    .frame(width: mainWindowSize.width - Constants.Comments.widthAdjustment) // Screen width - image width - padding
                    .multilineTextAlignment(.leading)
                    
                    // Otherwise if we have no secondary line but we do have a rejectin reason, then display as rejected item
                } else if let rejectionReason = mainLine.rejectionReason {
                    HStack {
                        notes(primaryText: rejectionReason, secondaryText: mainLine.storeNote, tertiaryText: nil, isRefunded: true)
                            .padding(.leading, Constants.Comments.padding)
                        Spacer()
                    }
                    .frame(width: mainWindowSize.width - Constants.Comments.widthAdjustment) // Screen width - image width - padding
                    .multilineTextAlignment(.leading)
                }
            }
            
            quantityAndPrice(line: mainLine, isRejected: viewModel.isRefundedItem(originalLine: mainLine, substituteLine: secondaryLine))
        }
    }
    
    // MARK: - Notes
    @ViewBuilder private func notes(primaryText: String, secondaryText: String?, tertiaryText: String?, isRefunded: Bool) -> some View {
        if let secondaryText = secondaryText, let tertiaryText = tertiaryText {
            VStack(alignment: .leading, spacing: Constants.Comments.vSpacing) {
                
                HStack {
                    Text(primaryText)
                        .font(.Body2.semiBold())
                        .italic()
                        .foregroundColor(isRefunded ? colorPalette.primaryRed : colorPalette.primaryBlue)
                    
                    +
                    Text(": \(secondaryText)")
                        .font(.Body2.regular())
                        .italic()
                        .foregroundColor(colorPalette.typefacePrimary)
                    Spacer()
                }
                .frame(width: mainWindowSize.width - Constants.Comments.widthAdjustment)
                .background(isRefunded ? colorPalette.primaryRed.withOpacity(.ten) : colorPalette.primaryBlue.withOpacity(.ten))
                
                HStack {
                    Text(tertiaryText.firstLetterCapitalized)
                        .font(.Body2.regular())
                        .italic()
                        .foregroundColor(colorPalette.typefacePrimary)
                    Spacer()
                }
                .frame(width: mainWindowSize.width - Constants.Comments.widthAdjustment)
                .background(isRefunded ? colorPalette.primaryRed.withOpacity(.ten) : colorPalette.primaryBlue.withOpacity(.ten))
            }
        } else if let secondaryText = secondaryText {
            HStack  {
                Text(primaryText)
                    .font(.Body2.semiBold())
                    .italic()
                    .foregroundColor(isRefunded ? colorPalette.primaryRed : colorPalette.primaryBlue)
                
                +
                Text(": \(secondaryText)")
                    .font(.Body2.regular())
                    .italic()
                    .foregroundColor(colorPalette.typefacePrimary)
                Spacer()
            }
            .frame(width: mainWindowSize.width - Constants.Comments.widthAdjustment)
            .background(isRefunded ? colorPalette.primaryRed.withOpacity(.ten) : colorPalette.primaryBlue.withOpacity(.ten))
        } else {
            HStack {
                Text(primaryText)
                    .font(.Body2.semiBold())
                    .italic()
                    .foregroundColor(isRefunded ? colorPalette.primaryRed : colorPalette.primaryBlue)
                Spacer()
            }
            .frame(width: mainWindowSize.width - Constants.Comments.widthAdjustment)
            .background(isRefunded ? colorPalette.primaryRed.withOpacity(.ten) : colorPalette.primaryBlue.withOpacity(.ten))
        }
    }
    
    // MARK: - Quantity and price
    @ViewBuilder private func quantityAndPrice(line: PlacedOrderLine, isRejected: Bool) -> some View {
        Text("\(line.quantity)")
            .font(.Body2.semiBold())
            .foregroundColor(isRejected ? colorPalette.primaryRed : colorPalette.primaryBlue)
        
        Text(viewModel.pricePaid(line: line))
            .font(.Body2.semiBold())
            .foregroundColor(isRejected ? colorPalette.primaryRed : colorPalette.primaryBlue)
            .strikethrough(isRejected)
    }
    
    // MARK: - Item image
    @ViewBuilder private func itemImage(item: PastOrderLineItem) -> some View {
        AsyncImage(container: viewModel.container, urlString: item.images?.first?[AppV2Constants.API.imageScaleFactor]?.absoluteString)
            .cornerRadius(Constants.ItemImage.cornerRadius)
            .basketAndPastOrderImage(container: viewModel.container)
    }
}

#if DEBUG
struct OrderListItemView_Previews: PreviewProvider {
    static var previews: some View {
        OrderListView(viewModel: .init(
            container: .preview,
            order: PlacedOrder(
                id: 1963404,
                businessOrderId: 2106,
                status: "Store Accepted / Picking",
                statusText: "store_accepted_picking",
                totalPrice: 11.25,
                totalDiscounts: 0,
                totalSurcharge: 0.58999999999999997,
                totalToPay: 13.09,
                platform: AppV2Constants.Client.platform,
                firstOrder: true,
                createdAt: "2022-02-23 10:35:10",
                updatedAt: "2022-02-23 10:35:10",
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
                paymentMethod: PlacedOrderPaymentMethod(
                    name: "realex",
                    dateTime: "2022-02-18 "
                ),
                orderLines: [PlacedOrderLine(
                    id: 12136536,
                    substitutesOrderLineId: nil,
                    quantity: 12,
                    rewardPoints: nil,
                    pricePaid: 10,
                    discount: 0,
                    substitutionAllowed: nil,
                    customerInstructions: nil,
                    rejectionReason: nil,
                    item: PastOrderLineItem(
                        id: 3206126,
                        name: "Max basket quantity 10",
                        images: [
                            [
                                "mdpi_1x": URL(string: "https://www.snappyshopper.co.uk/uploads/images/stores/mdpi_1x/1486738973default.png")!,
                                "xhdpi_2x": URL(string: "https://www.snappyshopper.co.uk/uploads/images/stores/xhdpi_2x/1486738973default.png")!,
                                "xxhdpi_3x": URL(string: "https://www.snappyshopper.co.uk/uploads/images/stores/xxhdpi_3x/1486738973default.png")!
                            ]
                        ],
                        price: 10,
                        size: nil,
                        options: nil
                    ), refundAmount: 0,
                    storeNote: nil
                ), PlacedOrderLine(
                    id: 12136526,
                    substitutesOrderLineId: nil,
                    quantity: 12,
                    rewardPoints: nil,
                    pricePaid: 10,
                    discount: 0,
                    substitutionAllowed: nil,
                    customerInstructions: nil,
                    rejectionReason: nil,
                    item: PastOrderLineItem(
                        id: 3206126,
                        name: "Max basket quantity 10",
                        images: [
                            [
                                "mdpi_1x": URL(string: "https://www.snappyshopper.co.uk/uploads/images/stores/mdpi_1x/1486738973default.png")!,
                                "xhdpi_2x": URL(string: "https://www.snappyshopper.co.uk/uploads/images/stores/xhdpi_2x/1486738973default.png")!,
                                "xxhdpi_3x": URL(string: "https://www.snappyshopper.co.uk/uploads/images/stores/xxhdpi_3x/1486738973default.png")!
                            ]
                        ],
                        price: 10,
                        size: nil,
                        options: nil
                    ), refundAmount: 0,
                    storeNote: nil
                )],
                customer: PlacedOrderCustomer(
                    firstname: "Kevin",
                    lastname: "Palser"
                ),
                discount: [PlacedOrderDiscount(
                    name: "Multi Buy Example",
                    amount: 0.4,
                    type: "nforn",
                    lines: [12136536]
                )],
                surcharges: [PlacedOrderSurcharge(
                    name: "Service Charge",
                    amount: 0.09
                )],
                loyaltyPoints: PlacedOrderLoyaltyPoints(
                    type: "refer",
                    name: "Friend Reward Discount",
                    deductCost: 0
                ),
                coupon: PlacedOrderCoupon(
                    title: "Test % Coupon",
                    couponDeduct: 1.83,
                    type: "percentage",
                    freeDelivery: false,
                    value: 1.83,
                    iterableCampaignId: 0,
                    percentage: 10,
                    registeredMemberRequirement: false
                ),
                currency: .init(currencyCode: "GBP", symbol: "&pound;", ratio: 0, symbolChar: "£", name: "Great British Pound"),
                totalOrderValue: 20,
                totalRefunded: 0
            )
        ))
    }
}
#endif
