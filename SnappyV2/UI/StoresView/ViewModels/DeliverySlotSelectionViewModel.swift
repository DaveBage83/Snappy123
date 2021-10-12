//
//  DeliverySlotSelectionViewModel.swift
//  SnappyV2
//
//  Created by Henrik Gustavii on 24/09/2021.
//
import Foundation
import Combine

class DeliverySlotSelectionViewModel: ObservableObject {
    let container: DIContainer
    @Published var selectedRetailStoreDetails: Loadable<RetailStoreDetails>
    
    @Published var isDeliverySelected = false
    
    @Published var selectedDaySlot: Int?
    @Published var selectedTimeSlot: UUID?
    
    var isDateSelected: Bool {
        return selectedDaySlot != nil && selectedTimeSlot != nil
    }
    
    @Published var isASAPDeliverySelected = false
    @Published var isFutureDeliverySelected = false
    
    var cancellables = Set<AnyCancellable>()
    
    init(container: DIContainer) {
        self.container = container
        let appState = container.appState
        
        _selectedRetailStoreDetails = .init(initialValue: appState.value.userData.selectedStore)
        
        setupBindToSelectedRetailStoreDetails(with: appState)
    }
    
    func setupBindToSelectedRetailStoreDetails(with appState: Store<AppState>) {
        $selectedRetailStoreDetails
            .sink { appState.value.userData.selectedStore = $0 }
            .store(in: &cancellables)
        
        appState
            .map(\.userData.selectedStore)
            .removeDuplicates()
            .assignWeak(to: \.selectedRetailStoreDetails, on: self)
            .store(in: &cancellables)
    }
    
    func isASAPDeliveryTapped() { isASAPDeliverySelected = true }
    
    func isFutureDeliveryTapped() { isFutureDeliverySelected = true }
}
