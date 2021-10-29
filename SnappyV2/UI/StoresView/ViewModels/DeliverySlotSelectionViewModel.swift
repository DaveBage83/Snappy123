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
    @Published var storeSearchResult: Loadable<RetailStoresSearch>
    @Published var selectedRetailStoreDetails: Loadable<RetailStoreDetails>
    @Published var selectedRetailStoreDeliveryTimeSlots: Loadable<RetailStoreTimeSlots> = .notRequested
    @Published var isDeliverySelected = false
    
    @Published var availableDeliveryDays = [RetailStoreFulfilmentDay]()
    
    @Published var selectedDaySlot: RetailStoreSlotDay?
    @Published var morningTimeSlots = [RetailStoreSlotDayTimeSlot]()
    @Published var afternoonTimeSlots = [RetailStoreSlotDayTimeSlot]()
    @Published var eveningTimeSlots = [RetailStoreSlotDayTimeSlot]()
    @Published var selectedTimeSlot: String?
    
    var isDeliverySlotSelected: Bool {
        return selectedDaySlot != nil && selectedTimeSlot != nil
    }
    
    @Published var isFutureDeliverySelected = false
    
    var isFutureDeliveryDisabled: Bool {
        if availableDeliveryDays.isEmpty { return true }
        
        if isASAPDeliveryDisabled == true { return false }
        
        if availableDeliveryDays.count > 1 && isASAPDeliveryDisabled == false { return false }
        
        return true
    }
    
    var isASAPDeliveryDisabled: Bool {
        if availableDeliveryDays.isEmpty { return true }
        
        if let startDate = availableDeliveryDays.first?.storeDateStart {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd"
            let firstDate = dateFormatter.string(from: startDate)
            let today = dateFormatter.string(from: Date())
            
            return firstDate != today
        }
        return true
    }
    
    var cancellables = Set<AnyCancellable>()
    
    init(container: DIContainer) {
        self.container = container
        let appState = container.appState
        
        _selectedRetailStoreDetails = .init(initialValue: appState.value.userData.selectedStore)
        _storeSearchResult = .init(initialValue: appState.value.userData.searchResult)
        
        setupBindToSelectedRetailStoreDetails(with: appState)
        setupStoreSearchResult(with: appState)
        setupAvailableDeliveryDays()
    }
    
    func setupBindToSelectedRetailStoreDetails(with appState: Store<AppState>) {
        appState
            .map(\.userData.selectedStore)
            .removeDuplicates()
            .assignWeak(to: \.selectedRetailStoreDetails, on: self)
            .store(in: &cancellables)
    }
    
    func setupStoreSearchResult(with appState: Store<AppState>) {
        appState
            .map(\.userData.searchResult)
            .removeDuplicates()
            .assignWeak(to: \.storeSearchResult, on: self)
            .store(in: &cancellables)
    }
    
    func setupAvailableDeliveryDays() {
        $selectedRetailStoreDetails
            .removeDuplicates()
            .map { $0.value?.deliveryDays ?? [] }
            .map { [weak self] availableDays in
                guard let self = self else { return availableDays }
                if availableDays.count > 1 {
                    if let startDate = availableDays[1].storeDateStart, let endDate = availableDays[1].storeDateEnd {
                        self.selectDeliveryDate(startDate: startDate, endDate: endDate)
                    }
                } else {
                    
                }
                return availableDays
            }
            .receive(on: DispatchQueue.main)
            .assignWeak(to: \.availableDeliveryDays, on: self)
            .store(in: &cancellables)
    }
    
    func setupSelectedTimeDaySlot() {
        $selectedRetailStoreDeliveryTimeSlots
            .map { $0.value?.slotDays?.first }
            .receive(on: DispatchQueue.main)
            .assignWeak(to: \.selectedDaySlot, on: self)
            .store(in: &cancellables)
    }
    
    func setupDeliveryDaytimeSectionSlots() {
        // Morning slots
        $selectedDaySlot
            .map { timeSlot in
                if let slots = timeSlot?.slots {
                    return slots.filter { $0.daytime == .morning }
                }
                return []
            }
            .receive(on: DispatchQueue.main)
            .assignWeak(to: \.morningTimeSlots, on: self)
            .store(in: &cancellables)
        
        // Afternoon slots
        $selectedDaySlot
            .map { timeSlot in
                if let slots = timeSlot?.slots {
                    return slots.filter { $0.daytime == .afternoon }
                }
                return []
            }
            .receive(on: DispatchQueue.main)
            .assignWeak(to: \.afternoonTimeSlots, on: self)
            .store(in: &cancellables)
        
        // Evening slots
        $selectedDaySlot
            .map { timeSlot in
                if let slots = timeSlot?.slots {
                    return slots.filter { $0.daytime == .evening }
                }
                return []
            }
            .receive(on: DispatchQueue.main)
            .assignWeak(to: \.eveningTimeSlots, on: self)
            .store(in: &cancellables)
    }
    
    func selectDeliveryDate(startDate: Date, endDate: Date) {
        if let location = storeSearchResult.value?.fulfilmentLocation.location, let id =  selectedRetailStoreDetails.value?.id {
            
            container.services.retailStoresService.getStoreDeliveryTimeSlots(slots: loadableSubject(\.selectedRetailStoreDeliveryTimeSlots), storeId: id, startDate: startDate, endDate: endDate, location: location)
        }
        #warning("Should there be an else here if unwrapping fails?")
    }
    
    var isTimeSlotsLoading: Bool {
        switch selectedRetailStoreDeliveryTimeSlots {
        case .isLoading(last: _, cancelBag: _):
            return true
        default:
            return false
        }
    }
    
    func futureDeliverySetup() {
        setupSelectedTimeDaySlot()
        setupDeliveryDaytimeSectionSlots()
    }
    
    func asapDeliveryTapped() {
        continueToItemMenu()
    }
    
    func futureDeliveryTapped() {
        isFutureDeliverySelected = true
    }
    
    func shopNowButtonTapped() {
        #warning("Selected delivery slot service call here")
        continueToItemMenu()
    }
    
    func continueToItemMenu() {
        container.appState.value.routing.selectedTab = 2
    }
}
