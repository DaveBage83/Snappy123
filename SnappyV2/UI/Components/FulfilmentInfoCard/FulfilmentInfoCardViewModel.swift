//
//  FulfilmentInfoCardViewModel.swift
//  SnappyV2
//
//  Created by Henrik Gustavii on 15/02/2022.
//

import Foundation
import Combine
import OSLog

class FulfilmentInfoCardViewModel: ObservableObject {
    let container: DIContainer
    let timeZone: TimeZone?
    @Published var isFulfilmentSlotSelectShown: Bool = false
    @Published var basket: Basket?
    @Published var selectedStore: RetailStoreDetails?
    @Published var selectedFulfilmentMethod: RetailStoreOrderMethodType
    @Published var slotExpired = false
    
    private(set) var isInCheckout: Bool
    
    private var cancellables = Set<AnyCancellable>()
    
    var isSlotExpired: Bool {
        guard slotExpired == false else { return true }
        
        if let expires = basket?.selectedSlot?.expires {
            return expires.trueDate < Date().trueDate
        }

        if let end = basket?.selectedSlot?.end?.trueDate {
            return end.trueDate < Date().trueDate
        }

        return false
    }
    
    var showStoreClosedWarning: Bool {
        selectedStore?.orderMethods?[selectedFulfilmentMethod.rawValue]?.status == .closed
    }
    
    var useWarningCardFormat: Bool {
        showStoreClosedWarning || isSlotExpired
    }
    
    var fulfilmentMethod: RetailStoreOrderMethodType {
        container.appState.value.userData.selectedFulfilmentMethod
    }
    
    var fulfilmentTimeString: String {
        if basket?.selectedSlot?.todaySelected == true {
            if isInCheckout, let timeSlot = container.appState.value.userData.tempTodayTimeSlot {
                let startTime = timeSlot.startTime.hourMinutesString(timeZone: timeZone)
                let endTime = timeSlot.endTime.hourMinutesString(timeZone: timeZone)
                return GeneralStrings.today.localized + " | \(startTime) - \(endTime)"
            } else {
                let fulfilmentTypeString = container.appState.value.userData.selectedFulfilmentMethod == .delivery ? GeneralStrings.delivery.localized : GeneralStrings.collection.localized
                return "\(fulfilmentTypeString) " + GeneralStrings.todayASAP.localized
            }
        }
        
        if let start = basket?.selectedSlot?.start, let end = basket?.selectedSlot?.end {
            #warning("Improve with Date+Extensions handling")
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
        return Strings.SlotSelection.noTimeSelected.localized
    }
    
    init(container: DIContainer, isInCheckout: Bool = false) {
        self.container = container
        let appState = container.appState
        _basket = .init(initialValue: appState.value.userData.basket)
        _selectedStore = .init(initialValue: appState.value.userData.selectedStore.value)
        _selectedFulfilmentMethod = .init(initialValue: appState.value.userData.selectedFulfilmentMethod)
        timeZone = appState.value.userData.selectedStore.value?.storeTimeZone
        self.isInCheckout = isInCheckout
        
        setupBasket(appState: appState)
        setupBindToSlotExpired(appState: appState)
    }
    
    private func setupBindToSlotExpired(appState: Store<AppState>) {
        appState
            .map(\.userData.slotExpired)
            .receive(on: RunLoop.main)
            .replaceNil(with: false)
            .assignWeak(to: \.slotExpired, on: self)
            .store(in: &cancellables)
    }

    private func setupBasket(appState: Store<AppState>) {
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
