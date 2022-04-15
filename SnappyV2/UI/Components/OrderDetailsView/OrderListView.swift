//
//  OrderListItemView.swift
//  SnappyV2
//
//  Created by David Bage on 05/04/2022.
//

import SwiftUI

class OrderListViewModel: ObservableObject {
    let container: DIContainer
    let orderLines: [PlacedOrderLine]

    init(container: DIContainer, orderLines: [PlacedOrderLine]) {
        self.container = container
        
        self.orderLines = orderLines.sorted(by: { lhs, rhs in
            // If the item names are the same then we order by order ID
            if lhs.item.name == rhs.item.name {
                return lhs.id < rhs.id
            }
            
            // Otherwise we order by item name
            return lhs.item.name < rhs.item.name
        })
    }
    
    #warning("API not yet configured properly to handle item refunds. This is a temp solution that will be revisited")
    
    func itemDiscounted(_ orderLine: PlacedOrderLine) -> Bool {
        orderLine.discount != 0
    }

    func strikeItem(_ orderLine: PlacedOrderLine) -> Bool {
        orderLine.rejectionReason != nil || orderLine.discount != 0
    }
}

struct OrderListView: View {
    
    private typealias ListItemStrings = Strings.PlacedOrders.OrderListItemView
    private typealias CustomListItemStrings = Strings.PlacedOrders.CustomOrderListItem
    
    struct Constants {
        struct Grid {
            static let descriptionWidth: CGFloat = 150
            static let priceWidth: CGFloat = 50
        }
        
        struct ItemImage {
            static let size: CGFloat = 50
            static let cornerRadius: CGFloat = 5
        }
        
        struct LineItemDetail {
            static let spacing: CGFloat = 3
        }
    }
    
    @StateObject var viewModel: OrderListViewModel
    
    let columns = [
        GridItem(.flexible(), alignment: .topLeading),
        GridItem(.flexible(minimum: Constants.Grid.descriptionWidth), alignment: .topLeading),
        GridItem(.flexible(), alignment: .topTrailing),
        GridItem(.flexible(minimum: Constants.Grid.priceWidth), alignment: .topTrailing),
    ]
    
    var body: some View {
        
        LazyVGrid(columns: columns) {
            
            // headers
            Group {
                Text(ListItemStrings.items.localized)
                    .fontWeight(.semibold)
                Text("")
                Text(ListItemStrings.quantity.localized)
                    .fontWeight(.semibold)
                Text(ListItemStrings.price.localized)
                    .fontWeight(.semibold)
            }
            .padding(.bottom)
            .font(.snappyCaption)
            .foregroundColor(.snappyBlue)
                        
            ForEach(viewModel.orderLines, id: \.id) { orderLine in
                if let image = orderLine.item.images?[0][AppV2Constants.API.imageScaleFactor]?.absoluteString, let imageURL = URL(string: image) {
                    RemoteImageView(viewModel: .init(container: viewModel.container, imageURL: imageURL))
                        .frame(width: Constants.ItemImage.size, height: Constants.ItemImage.size)
                        .scaledToFit()
                        .cornerRadius(Constants.ItemImage.cornerRadius)
                } else {
                    Image.RemoteImage.placeholder
                        .font(.system(size: Constants.ItemImage.size))
                }
                
                VStack(alignment: .leading, spacing: Constants.LineItemDetail.spacing) {
                    Text(orderLine.item.name)
                        .font(.snappyCaption)
                        .foregroundColor(.snappyDark)
                        .strikethrough(viewModel.strikeItem(orderLine), color: .snappyRed)
                    Text(CustomListItemStrings.each.localizedFormat(orderLine.item.price.toCurrencyString()))
                        .font(.snappyCaption)
                        .fontWeight(.semibold)
                        .strikethrough(viewModel.strikeItem(orderLine), color: .snappyRed)
                }
                
                Text(String(orderLine.quantity))
                    .font(.snappyBody2)
                    .fontWeight(.semibold)
                    .foregroundColor(.snappyDark)
                    .strikethrough(viewModel.strikeItem(orderLine), color: .snappyRed)
                
                VStack {
                    Text(orderLine.totalCost.toCurrencyString())
                        .font(.snappyBody2)
                        .fontWeight(.semibold)
                        .foregroundColor(.snappyBlue)
                        .strikethrough(viewModel.strikeItem(orderLine), color: .snappyRed)
                    
                    if viewModel.itemDiscounted(orderLine) {
                        Text(((orderLine.pricePaid - orderLine.discount).toCurrencyString()))
                            .font(.snappyBody2)
                            .fontWeight(.semibold)
                            .foregroundColor(.snappyBlue)
                            .strikethrough(viewModel.strikeItem(orderLine), color: .snappyRed)
                    }
                }
            }
        }
        .padding()
    }
}

struct OrderListItemView_Previews: PreviewProvider {
    static var previews: some View {
        OrderListView(viewModel: .init(
            container: .preview,
            orderLines: [PlacedOrderLine(
                id: 12136536,
                substitutesOrderLineId: nil,
                quantity: 2,
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
                    price: 5
                )
            )]
        ))
    }
}
