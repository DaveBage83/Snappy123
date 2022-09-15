//
//  OrderLineViewModel.swift
//  SnappyV2
//
//  Created by David Bage on 12/09/2022.
//

import Foundation

class OrderLineViewModel: ObservableObject {
    // Enum to define the type of orderline we want to display
    enum OrderLineDisplayType {
        case singleItem // One item only
        case itemWithQuantityChange // Multiple lines, but all same item id i.e. quantity change
        case itemWithSubs // Item replaced with alternatives i.e. different item ids
    }
    
    // MARK: - Properties
    let container: DIContainer
    let currency: RetailStoreCurrency
    private let orderLines: [PlacedOrderLine] // Can be a single item array or contain multiple PlacedOrderLine objects
    var orderLineDisplayType: OrderLineDisplayType? // Controls the type of line layout we want to draw
    
    // MARK: - Computed variables
    
    // The non substituted line. There should ALWAYS be one of these present
    var mainOrderLine: PlacedOrderLine? {
        orderLines.first(where: { $0.substitutesOrderLineId == nil })
    }
    
    // Any substitute lines will always contain a substitutesOrderLineId
    var substituteLines: [PlacedOrderLine]? {
        let subLines = orderLines.filter { $0.substitutesOrderLineId != nil && $0.substitutesOrderLineId == mainOrderLine?.id }
        
        if subLines.isEmpty {
            return nil
        }
        
        return subLines
    }
    
    // We check if there are substitute lines present and if ALL of these lines
    // have the same item ID as the original, main item. If so, we know that this is a quantity
    // change
    var allSameItem: Bool {
        // If there are no subLines, then we know we only want a single line displayed, so we return true
        guard let subLines = substituteLines, let mainItemLine = mainOrderLine else { return true }
        
        // If there are no substitute lines with a different id to the mainItemLine id then we know all items are the same so return true
        // Otherwise we return false
        return subLines.filter { $0.item.id != mainItemLine.item.id }.count == 0
    }
    
    init(container: DIContainer, orderLines: [PlacedOrderLine], currency: RetailStoreCurrency) {
        self.container = container
        self.orderLines = orderLines
        self.currency = currency
        self.setOrderLineDisplayType()
    }
    
    // MARK: - Set up
    
    // Set up the order line dispay type
    private func setOrderLineDisplayType() {
        // If there is only 1 line in the array, set to .singleItem
        guard orderLines.count > 1 else {
            self.orderLineDisplayType = .singleItem
            return
        }
        
        // If allSameItem is true then we know this is a quantity change so set to .itemWithQuantityChange
        if allSameItem {
            self.orderLineDisplayType = .itemWithQuantityChange
        } else {
            // Otherwise this must be a substitue item
            self.orderLineDisplayType = .itemWithSubs
        }
    }
    
    // Method used to determine if we should strike through text in an order line
    func shouldStrikeThrough(_ line: PlacedOrderLine) -> Bool {
        // First we check if there is more than 1 line. If not, we know the line is not substituted so we return false
        guard orderLines.count > 1 else {
            // If only 1 line, check if rejectionReason is nil. If it is not, this
            // must be a rejected item so we strike through
            if line.rejectionReason != nil {
                return true
            }
            return false
        }
        
        // If more than 1 line present, we must have a substitution. If the line passed in has no substitutesOrderLineId then this is the substituted line
        return line.substitutesOrderLineId == nil
    }
    
    // Formats the price paid to the correct string
    func pricePaid(line: PlacedOrderLine) -> String {
        (line.pricePaid * Double(line.quantity)).toCurrencyString(using: currency)
    }
    
    // Formats item name correctly, to include size if relevant
    func itemName(_ item: PastOrderLineItem) -> String {
        if let size = item.size?.name {
            return "\(item.name) (\(size))"
        }
        return item.name
    }
}
