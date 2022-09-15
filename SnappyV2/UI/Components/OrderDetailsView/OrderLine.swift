//
//  OrderLine.swift
//  SnappyV2
//
//  Created by David Bage on 06/09/2022.
//

import SwiftUI

class OrderLineViewModel: ObservableObject {
    enum OrderLineDisplayType {
        case singleItem // One item only
        case itemWithQuantityChange // Multiple lines, but all same item id i.e. quantity change
        case itemWithSubs // Item replaced with alternatives i.e. different item ids
    }
    
    let container: DIContainer
    let orderLines: [PlacedOrderLine]
    
    var orderLineDisplayType: OrderLineDisplayType?
    
    var mainOrderLine: PlacedOrderLine? {
        orderLines.first(where: { $0.substitutesOrderLineId == nil })
    }
    
    var substituteLines: [PlacedOrderLine]? {
        orderLines.filter { $0.substitutesOrderLineId != nil }
    }
    
    // We check if there are substitute lines present and if ALL of these lines
    // have the same item ID as the original, main item. If so, we know that this is a quantity
    // change only and so we display the item image and description once only, and just cross out the quantity and price
    // replacing with new values
    var allSameItem: Bool {
        guard let subLines = substituteLines, let mainItemLine = mainOrderLine else { return true }
        
        var allSameItem = true
        
        subLines.forEach { line in
            if line.item.id != mainItemLine.item.id {
                allSameItem = false
            }
        }
        return allSameItem
    }
    
    init(container: DIContainer, orderLines: [PlacedOrderLine]) {
        self.container = container
        self.orderLines = orderLines
        self.setOrderLineDisplayType()
    }
    
    private func setOrderLineDisplayType() {
        guard orderLines.count > 1 else {
            self.orderLineDisplayType = .singleItem
            return
        }
        
        if allSameItem {
            self.orderLineDisplayType = .itemWithQuantityChange
        } else {
            self.orderLineDisplayType = .itemWithSubs
        }
    }
    
    func shouldStrikeThrough(_ line: PlacedOrderLine) -> Bool {
        // First we check if there is more than 1 line. If not, we know the line is not substituted so we return false
        guard orderLines.count > 1 else {
            if line.rejectionReason != nil {
                return true
            }
            return false
        }
        
        // If more than 1 line present, we must have a substitution. If the line passed in has no substitutesOrderLineId then this is the substituted line
        return line.substitutesOrderLineId == nil
    }
    
    func pricePaid(line: PlacedOrderLine) -> String {
        (line.pricePaid * Double(line.quantity)).toCurrencyString()
    }
    
    func itemName(_ item: PastOrderLineItem) -> String {
        if let size = item.size?.name {
            return "\(item.name) (\(size))"
        }
        return item.name
    }
}

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
            case .singleItem:
                if let mainLine = viewModel.mainOrderLine {
                    if let rejectionReason = mainLine.rejectionReason {
                        ZStack(alignment: .bottomTrailing) {
                            singleLine(mainLine)
                                .highlightedItem(container: viewModel.container, banners: [
                                    .init(type: .rejectedItem, text: rejectionReason, action: nil)
                                ])
                            Text("-\(mainLine.refundAmount.toCurrencyString())")
                                .foregroundColor(.white)
                                .font(.Body2.semiBold())
                                .padding(8)
                        }
                        
                    } else {
                        singleLine(mainLine)
                            .padding(.horizontal, 8) // Bring line in to counter formatting for highlighted rows
                    }
                }
            case .itemWithQuantityChange:
                if let mainLine = viewModel.mainOrderLine, let subLines = viewModel.substituteLines {
                    ZStack(alignment: .bottomTrailing) {
                        singleLineQuantityChange(mainLine: mainLine, subLines: subLines)
                            .highlightedItem(
                                container: viewModel.container,
                                banners: [
                                    .init(
                                        type: .itemQuantityChange,
                                        text: "Quantity changed",
                                        action: {})
                                ])
                        Text("-\(mainLine.refundAmount.toCurrencyString())")
                            .foregroundColor(.white)
                            .font(.Body2.semiBold())
                            .padding(8)
                    }
                    
                }
                
            case .itemWithSubs:
                if let mainLine = viewModel.mainOrderLine, let subLines = viewModel.substituteLines {
                    ZStack(alignment: .bottomTrailing) {
                        itemWithSubs(mainLine: mainLine, subLines: subLines)
                        Text("-\(mainLine.refundAmount.toCurrencyString())")
                            .foregroundColor(.white)
                            .font(.Body2.semiBold())
                            .padding(8)
                    }
                }
                
            case .none:
                Text("hmmm")
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
                      text: "Substituted Item",
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
            ]))
            
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
                    item: .init(id: 456, name: "Yummy chocolate", images: nil, price: 5, size: nil), refundAmount: 0)]))
            
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
            ]))
        }
        
    }
}

extension Double {
    var pricePerItemString: String {
        Strings.General.Custom.perItem.localizedFormat(self.toCurrencyString())
    }
}
