//
//  OrderLine.swift
//  SnappyV2
//
//  Created by David Bage on 06/09/2022.
//

import SwiftUI

struct OrderLine: View {
    @Environment(\.colorScheme) var colorScheme
    @StateObject var viewModel: OrderLineViewModel
    
    struct Constants {
        struct Grid {
            static let descriptionWidth: CGFloat = 150
            static let priceWidth: CGFloat = 50
        }
        
        struct ItemImage {
            static let size: CGFloat = 50
            static let cornerRadius: CGFloat = 5
        }
        
        struct General {
            static let linePadding: CGFloat = 8
        }
    }
    
    private var colorPalette: ColorPalette {
        .init(container: viewModel.container, colorScheme: colorScheme)
    }
    
    // Grid setup
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible(minimum: 150), alignment: .topLeading),
        GridItem(.flexible(), alignment: .topTrailing),
        GridItem(.flexible(), alignment: .topTrailing),
    ]
    
    var body: some View {
        VStack {
            switch viewModel.orderLineDisplayType {
            case .singleItem, .none:
                singleItem
                
            case .itemWithQuantityChange:
                itemWithQuantityChange
                
            case .itemWithSubs:
                itemWithSubs
            }
        }
    }
    
    @ViewBuilder var singleItem: some View {
        if let mainLine = viewModel.mainOrderLine {
            if let rejectionReason = mainLine.rejectionReason {
                ZStack(alignment: .bottomTrailing) {
                    singleLine(mainLine)
                        .highlightedItem(container: viewModel.container, banners: [
                            .init(type: .rejectedItem, text: rejectionReason, action: nil)
                        ])
                    Text("-\(mainLine.refundAmount.toCurrencyString(using: viewModel.currency))")
                        .foregroundColor(.white)
                        .font(.Body2.semiBold())
                        .padding(Constants.General.linePadding)
                }
                
            } else {
                singleLine(mainLine)
                    .padding(.horizontal, Constants.General.linePadding) // Bring line in to counter formatting for highlighted rows
            }
        }
    }
    
    @ViewBuilder var itemWithQuantityChange: some View {
        if let mainLine = viewModel.mainOrderLine, let subLines = viewModel.substituteLines {
            ZStack(alignment: .bottomTrailing) {
                singleLineQuantityChange(mainLine: mainLine, subLines: subLines)
                    .highlightedItem(
                        container: viewModel.container,
                        banners: [
                            .init(
                                type: .itemQuantityChange,
                                text: Strings.PlacedOrders.OrderLine.quantityChanged.localized,
                                action: {})
                        ])
                Text("-\(mainLine.refundAmount.toCurrencyString(using: viewModel.currency))")
                    .foregroundColor(.white)
                    .font(.Body2.semiBold())
                    .padding(Constants.General.linePadding)
            }
        }
    }
    
    @ViewBuilder var itemWithSubs: some View {
        if let mainLine = viewModel.mainOrderLine, let subLines = viewModel.substituteLines {
            ZStack(alignment: .bottomTrailing) {
                itemWithSubs(mainLine: mainLine, subLines: subLines)
                Text("-\(mainLine.refundAmount.toCurrencyString(using: viewModel.currency))")
                    .foregroundColor(.white)
                    .font(.Body2.semiBold())
                    .padding(Constants.General.linePadding)
            }
        }
    }
    
    @ViewBuilder private func singleLine(_ line: PlacedOrderLine) -> some View {
        LazyVGrid(columns: columns) {
            itemImage(item: line.item)
            
            VStack(alignment: .leading) {
                Text(viewModel.itemName(line.item))
                    .font(.Body2.regular())
                    .strikethrough(viewModel.shouldStrikeThrough(line), color: colorPalette.primaryRed)
                
                Spacer()
                
                Text(line.item.price.pricePerItemString)
                    .font(.Body2.semiBold())
                    .strikethrough(viewModel.shouldStrikeThrough(line), color: colorPalette.primaryRed)
            }
            
            Text("\(line.quantity)")
                .font(.Body2.regular())
                .strikethrough(viewModel.shouldStrikeThrough(line), color: colorPalette.primaryRed)
            
            Text(viewModel.pricePaid(line: line))
                .font(.Body2.regular())
                .strikethrough(viewModel.shouldStrikeThrough(line), color: colorPalette.primaryRed)
        }
    }
    
    @ViewBuilder private func singleLineQuantityChange(mainLine: PlacedOrderLine, subLines: [PlacedOrderLine]) -> some View {
        LazyVGrid(columns: columns) {
            itemImage(item: mainLine.item)
            
            VStack(alignment: .leading) {
                Text(viewModel.itemName(mainLine.item))
                    .font(.Body2.regular())
                Spacer()
                Text(mainLine.item.price.pricePerItemString)
                    .font(.Body2.semiBold())
            }
            
            VStack {
                Text("\(mainLine.quantity)")
                    .font(.Body2.regular())
                    .strikethrough(viewModel.shouldStrikeThrough(mainLine), color: colorPalette.primaryRed)
                
                Spacer()
                
                ForEach(subLines, id: \.self) { line in
                    Text("\(line.quantity)")
                        .font(.Body2.regular())
                }
            }
            
            VStack {
                Text(viewModel.pricePaid(line: mainLine))
                    .font(.Body2.regular())
                    .strikethrough(viewModel.shouldStrikeThrough(mainLine), color: colorPalette.primaryRed)
                
                Spacer()
                
                ForEach(subLines, id: \.self) { line in
                    Text(viewModel.pricePaid(line: line))
                        .font(.Body2.regular())
                }
            }
        }
    }
    
    @ViewBuilder private func itemWithSubs(mainLine: PlacedOrderLine, subLines: [PlacedOrderLine]) -> some View {
        VStack {
            singleLine(mainLine)
            
            ForEach(subLines, id: \.self) { line in
                singleLine(line)
            }
        }
        .highlightedItem(
            container: viewModel.container,
            banners: [
                .init(type: .substitutedItem,
                      text: Strings.PlacedOrders.OrderLine.substitutedItem.localized,
                      action: nil)
            ])
    }
    
    @ViewBuilder private func itemImage(item: PastOrderLineItem) -> some View {
        if
            let image = item.images?.first?[AppV2Constants.API.imageScaleFactor]?.absoluteString,
            let imageURL = URL(string: image)
        {
            RemoteImageView(viewModel: .init(container: viewModel.container, imageURL: imageURL))
                .basketAndPastOrderImage(container: viewModel.container)
        } else {
            Image.RemoteImage.placeholder
                .font(.system(size: Constants.ItemImage.size))
        }
    }
}

#if DEBUG
struct OrderLine_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            OrderLine(viewModel: .init(container: .preview, orderLines: [
                PlacedOrderLine(
                    id: 123,
                    substitutesOrderLineId: nil,
                    quantity: 2,
                    rewardPoints: nil,
                    pricePaid: 5,
                    discount: 0,
                    substitutionAllowed: true,
                    customerInstructions: nil,
                    rejectionReason: nil,
                    item: .init(id: 456, name: "Yummy chocolate", images: nil, price: 5, size: nil), refundAmount: 0),
                PlacedOrderLine(
                    id: 222,
                    substitutesOrderLineId: 123,
                    quantity: 1,
                    rewardPoints: nil,
                    pricePaid: 5,
                    discount: 0,
                    substitutionAllowed: true,
                    customerInstructions: nil,
                    rejectionReason: nil,
                    item: .init(id: 456, name: "Yummy chocolate sub", images: nil, price: 5, size: nil), refundAmount: 0)
            ], currency: .init(currencyCode: "GBP", symbol: "&pound;", ratio: 0, symbolChar: "£", name: "Great British Pound")))
            
            OrderLine(viewModel: .init(container: .preview, orderLines: [
                PlacedOrderLine(
                    id: 123,
                    substitutesOrderLineId: nil,
                    quantity: 2,
                    rewardPoints: nil,
                    pricePaid: 5,
                    discount: 0,
                    substitutionAllowed: true,
                    customerInstructions: nil,
                    rejectionReason: nil,
                    item: .init(id: 456, name: "Yummy chocolate", images: nil, price: 5, size: nil), refundAmount: 0)], currency: .init(currencyCode: "GBP", symbol: "&pound;", ratio: 0, symbolChar: "£", name: "Great British Pound")))
            
            OrderLine(viewModel: .init(container: .preview, orderLines: [
                PlacedOrderLine(
                    id: 123,
                    substitutesOrderLineId: nil,
                    quantity: 2,
                    rewardPoints: nil,
                    pricePaid: 5,
                    discount: 0,
                    substitutionAllowed: true,
                    customerInstructions: nil,
                    rejectionReason: nil,
                    item: .init(id: 456, name: "Yummy chocolate", images: nil, price: 5, size: nil), refundAmount: 0),
                PlacedOrderLine(
                    id: 222,
                    substitutesOrderLineId: 123,
                    quantity: 1,
                    rewardPoints: nil,
                    pricePaid: 5,
                    discount: 0,
                    substitutionAllowed: true,
                    customerInstructions: nil,
                    rejectionReason: nil,
                    item: .init(id: 333, name: "Yummy chocolate sub", images: nil, price: 5, size: nil), refundAmount: 0),
                PlacedOrderLine(
                    id: 123,
                    substitutesOrderLineId: 123,
                    quantity: 2,
                    rewardPoints: nil,
                    pricePaid: 5,
                    discount: 0,
                    substitutionAllowed: true,
                    customerInstructions: nil,
                    rejectionReason: nil,
                    item: .init(id: 222, name: "Yummy chocolate", images: nil, price: 5, size: nil), refundAmount: 0)
            ], currency: .init(currencyCode: "GBP", symbol: "&pound;", ratio: 0, symbolChar: "£", name: "Great British Pound")))
        }
    }
}
#endif
