//
//  OrderListItemView.swift
//  SnappyV2
//
//  Created by David Bage on 05/04/2022.
//

import SwiftUI

struct OrderDisplayableLine: Identifiable {
    let id: UUID
    let line: PlacedOrderLine
    let amount: String
    let totalCost: String
    let discount: String
}

class OrderListViewModel: ObservableObject {
    let container: DIContainer
    let orderLines: [OrderDisplayableLine]
    let placedOrderLines: [PlacedOrderLine]
    
    var pairedLines: [Int: [PlacedOrderLine]] {
        Dictionary(grouping: placedOrderLines, by: { $0.id })
    }
    
    // Group substitute items together
    var groupedOrderLines: [[PlacedOrderLine]] {
        var groups = [[PlacedOrderLine]]()
        
        // Filter to substitute rows
        let substituteLines =  placedOrderLines.filter { $0.substitutesOrderLineId != nil }
        
        // Filter all non substitute rows
        let nonSubstituteLines = placedOrderLines.filter { $0.substitutesOrderLineId == nil }

        nonSubstituteLines.forEach { nonSubLine in
            // First we extract any substitute lines which have a substitutesOrderLineId which matches the nonSubline ID
            var matchingLines = substituteLines.filter { $0.substitutesOrderLineId == nonSubLine.id }
            
            // If there are matches, then we add all these matches + the nonSubline to the array
            if matchingLines.count > 0 {
                matchingLines.append(nonSubLine)
                
                groups.append(matchingLines)
            // Otherwise if there are no matches, we simply add this nonSubline as a single item array to the groups array
            } else {
                groups.append([nonSubLine])
            }
        }

        return groups
    }
    
    init(container: DIContainer, orderLines: [PlacedOrderLine]) {
        self.container = container
        self.placedOrderLines = orderLines
        
        let sortedOrderLines = orderLines.sorted(by: { lhs, rhs in
            // If the item names are the same then we order by order ID
            if lhs.item.name == rhs.item.name {
                return lhs.id < rhs.id
            }
            
            // Otherwise we order by item name
            return lhs.item.name < rhs.item.name
        })
        
        let currency = container.appState.value.userData.selectedStore.value?.currency ?? AppV2Constants.Business.defaultStoreCurrency
        
        self.orderLines = sortedOrderLines.reduce(nil, { (linesArray, line) -> [OrderDisplayableLine] in
            var array = linesArray ?? []
            #warning("Need to revist discount calculation to check if correct")
            array.append(
                OrderDisplayableLine(
                    id: UUID(),
                    line: line,
                    amount: line.item.price.toCurrencyString(using: currency),
                    totalCost: line.totalCost.toCurrencyString(using: currency),
                    discount: (line.pricePaid - line.discount).toCurrencyString(using: currency)
                )
            )
            return array
        }) ?? []
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
        GridItem(.flexible(), alignment: .center),
        GridItem(.flexible(minimum: 150), alignment: .topLeading),
        GridItem(.flexible(), alignment: .trailing),
        GridItem(.flexible(), alignment: .trailing),
    ]
    
    var body: some View {
        VStack {
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
                .font(.snappyCaption)
                .foregroundColor(.snappyBlue)
                .padding(.horizontal, 8)
            }
            
            VStack(spacing: 14) {
                ForEach(viewModel.groupedOrderLines, id: \.self) { orderLineGroups in
                    OrderLine(viewModel: .init(container: viewModel.container, orderLines: orderLineGroups))
                }
            }
        }
    }
}

#if DEBUG
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
                    price: 5,
                    size: nil
                ), refundAmount: 0
            )]
        ))
    }
}
#endif

class Box<A> {
    var value: A
    init(_ val: A) {
        self.value = val
    }
}

public extension Sequence {
    func group<U: Hashable>(by key: (Iterator.Element) -> U) -> [U: [Iterator.Element]] {
        var categories: [U: Box<[Iterator.Element]>] = [:]
        for element in self {
            let key = key(element)
            if case nil = categories[key]?.value.append(element) {
                categories[key] = Box([element])
            }
        }
        var result: [U: [Iterator.Element]] = Dictionary(minimumCapacity: categories.count)
        for (key, val) in categories {
            result[key] = val.value
        }
        return result
    }
}
