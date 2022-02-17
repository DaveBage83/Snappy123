//
//  FulfilmentInfoCardViewModel.swift
//  SnappyV2
//
//  Created by Henrik Gustavii on 15/02/2022.
//

import Foundation
import Combine

class FulfilmentInfoCardViewModel: ObservableObject {
    let container: DIContainer
    @Published var isFulfilmentSlotSelectShown: Bool = false
    @Published var basket: Basket?
    @Published var selectedStore: RetailStoreDetails?
    @Published var selectedFulfilmentMethod: RetailStoreOrderMethodType
    
    private var cancellables = Set<AnyCancellable>()
    
    var fulfilmentTimeString: String {
        if basket?.selectedSlot?.todaySelected == true {
            let fulfilmentTypeString = container.appState.value.userData.selectedFulfilmentMethod == .delivery ? GeneralStrings.delivery.localized : GeneralStrings.collection.localized
            return "\(fulfilmentTypeString) " + GeneralStrings.today.localized
        }
        
        if let start = basket?.selectedSlot?.start, let end = basket?.selectedSlot?.end {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "HH:mm"
            let startTime = dateFormatter.string(from: start)
            let endTime = dateFormatter.string(from: end)
            dateFormatter.dateFormat = "dd"
            let dayOfMonth = dateFormatter.string(from: start)
            dateFormatter.dateFormat = "MMMM"
            let month = dateFormatter.string(from: start)
            
            return "\(dayOfMonth) \(month) | \(startTime) - \(endTime)"
        }
        return "No time selected"
    }
    
    var fulfilmentTypeString: String { selectedFulfilmentMethod == .delivery ? GeneralStrings.delivery.localized : GeneralStrings.collection.localized }
    
    init(container: DIContainer) {
        self.container = container
        let appState = container.appState
        self._basket = .init(initialValue: appState.value.userData.basket)
        self._selectedStore = .init(initialValue: appState.value.userData.selectedStore.value)
        self._selectedFulfilmentMethod = .init(initialValue: appState.value.userData.selectedFulfilmentMethod)
        
        setupBasket(appState: appState)
    }
    
    func setupBasket(appState: Store<AppState>) {
        appState
            .map(\.userData.basket)
            .receive(on: RunLoop.main)
            .sink { [weak self] basket in
                guard let self = self else { return }
                if let basket = basket {
                    self.basket = basket
                }
            }
            .store(in: &cancellables)
    }
    
    func showFulfilmentSelectView() {
        isFulfilmentSlotSelectShown = true
    }
}
