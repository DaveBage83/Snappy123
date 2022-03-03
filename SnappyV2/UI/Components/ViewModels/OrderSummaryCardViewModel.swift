//
//  OrderSummaryCardViewModel.swift
//  SnappyV2
//
//  Created by David Bage on 01/03/2022.
//

import Foundation
import Combine

class OrderSummaryCardViewModel: ObservableObject {
    #warning("This viewModel is not complete. Endpoint to retrieve past orders is not yet ready. We will not be using appState in the final version")
    let container: DIContainer
    
    var selectedStoreLogo: RemoteImage? {
        if let store = container.appState.value.userData.selectedStore.value, let logo = store.storeLogo?["xhdpi_2x"]?.absoluteString {
            return RemoteImage(url: logo)
        }
        return nil
    }
    
    var orderTotal: String {
        if let orderTotal = container.appState.value.userData.basket?.orderTotal {
            return "£\(orderTotal)"
        }
        return "No order"
    }
    
    var selectedSlot: String {
        if let slot = container.appState.value.userData.basket?.selectedSlot, let start = slot.start, let end = slot.end {
            return "\(start.dateShortString(storeTimeZone: nil)) | \(start.timeString(storeTimeZone: nil)) - \(end.timeString(storeTimeZone: nil))"
        }
        return "No slot"
    }
    
    init(container: DIContainer) {
        self.container = container
    }
}
