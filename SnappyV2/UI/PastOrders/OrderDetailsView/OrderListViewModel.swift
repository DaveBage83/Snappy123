//
//  OrderListViewModel.swift
//  SnappyV2
//
//  Created by David Bage on 13/09/2022.
//

import Foundation

struct PlacedOrderLineWithSubstitute: Hashable {
    let originalLine: PlacedOrderLine
    let substitutedLine: PlacedOrderLine
}

struct GroupedItemOption: Hashable {
    let optionName: String
    let selectedOptions: [String]
}

class OrderListViewModel: ObservableObject {
    let container: DIContainer
    let order: PlacedOrder
    
    var currency: RetailStoreCurrency {
        order.currency
    }
    
    var placedOrderLines: [PlacedOrderLine] {
        order.orderLines
    }
    
    var showStandardLines: Bool {
        standardLines != nil
    }
    
    var showRefundedLines: Bool {
        refundedLines != nil
    }
    
    var showSubbedLines: Bool {
        linesWithSubstitutes != nil
    }
    
    var linesWithSubstitutes: [PlacedOrderLineWithSubstitute]? {
        var linesGroupedWithSubs = [PlacedOrderLineWithSubstitute]()
        
        // Filter to substitute rows
        let substituteLines =  placedOrderLines.filter { $0.substitutesOrderLineId != nil }
        
        // Filter all non substitute rows
        let nonSubstituteLines = placedOrderLines.filter { $0.substitutesOrderLineId == nil }
        
        nonSubstituteLines.forEach { nonSubline in
            let matchingLines = substituteLines.filter { $0.substitutesOrderLineId == nonSubline.id }
            
            matchingLines.forEach { match in
                linesGroupedWithSubs.append(.init(originalLine: nonSubline, substitutedLine: match))
            }
        }
        
        return linesGroupedWithSubs.count > 0 ? linesGroupedWithSubs : nil
    }
    
    var refundedLines: [PlacedOrderLine]? {
        // Filter to substitute rows
        let substituteLines =  placedOrderLines.filter { $0.substitutesOrderLineId != nil }
        
        // Filter all non substitute rows
        let nonSubstituteLines = placedOrderLines.filter { $0.substitutesOrderLineId == nil }
        
        var rejections = [PlacedOrderLine]()
        
        nonSubstituteLines.filter { $0.rejectionReason != nil }.forEach { rejectedLine in
            if substituteLines.filter({ $0.substitutesOrderLineId == rejectedLine.id }).count == 0 {
                rejections.append(rejectedLine)
            }
        }
        
        return rejections.count > 0 ? rejections : nil
    }
    
    var standardLines: [PlacedOrderLine]? {
        return placedOrderLines.filter { $0.substitutesOrderLineId == nil && $0.rejectionReason == nil }
    }
    
    init(container: DIContainer, order: PlacedOrder) {
        self.container = container
        self.order = order
    }
    
    func pricePaid(line: PlacedOrderLine) -> String {
        (line.pricePaid * Double(line.quantity)).toCurrencyString(using: currency)
    }
    
    func itemName(_ item: PastOrderLineItem) -> String {
        if let size = item.size?.name {
            return "\(item.name) (\(size))"
        }
        return item.name
    }
    
    func isRefundedItem(originalLine: PlacedOrderLine, substituteLine: PlacedOrderLine?) -> Bool {
        originalLine.rejectionReason != nil && substituteLine == nil
    }
    
    func groupedOptions(options: [PastOrderLineOption]) -> [GroupedItemOption] {
        // Get unique optionNameIds
        let uniqueOptionNameIds = options.map { $0.optionId }.removingDuplicates()
        
        var groupedItemOptions = [GroupedItemOption]()
        
        uniqueOptionNameIds.forEach { id in
            let groupedOptions = options.filter { $0.optionId == id }
            let optionName = groupedOptions.first?.optionName ?? ""
            let selectedOptions = groupedOptions.map { $0.name }
            groupedItemOptions.append(.init(optionName: optionName, selectedOptions: selectedOptions))
        }
        return groupedItemOptions
    }
}
