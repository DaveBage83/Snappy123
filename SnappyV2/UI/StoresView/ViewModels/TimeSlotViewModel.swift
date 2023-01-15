//
//  TimeSlotViewModel.swift
//  SnappyV2
//
//  Created by Kevin Palser on 13/01/2023.
//

import Foundation
import Combine

class TimeSlotViewModel: ObservableObject {
    let container: DIContainer
    let timeSlot: RetailStoreSlotDayTimeSlot
    let startTime: String
    let endTime: String
    
    var disabled: Bool {
        timeSlot.info.status.lowercased() != "available"
    }
    
    var cost: String {
        if timeSlot.info.price == 0 { return GeneralStrings.free.localized}
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = "£"

        guard let total = formatter.string(from: NSNumber(value: timeSlot.info.price)) else { return "" }
        return total
    }
    
    init(container: DIContainer, timeSlot: RetailStoreSlotDayTimeSlot) {
        let appState = container.appState
        self.timeSlot = timeSlot
        self.container = container
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        dateFormatter.timeZone = appState.value.userData.selectedStore.value?.storeTimeZone
        self.startTime = dateFormatter.string(from: timeSlot.startTime)
        self.endTime = dateFormatter.string(from: timeSlot.endTime)
    }
}
