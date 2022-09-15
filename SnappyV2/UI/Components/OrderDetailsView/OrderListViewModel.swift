//
//  OrderListViewModel.swift
//  SnappyV2
//
//  Created by David Bage on 13/09/2022.
//

import Foundation

class OrderListViewModel: ObservableObject {
    let container: DIContainer
//    let placedOrderLines: [PlacedOrderLine]
    let order: PlacedOrder
    
    var currency: RetailStoreCurrency {
        order.currency
    }
    
    var placedOrderLines: [PlacedOrderLine] {
        order.orderLines
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
    
    init(container: DIContainer, order: PlacedOrder) {
        self.container = container
        self.order = order
    }
}
