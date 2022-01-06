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
    @Published var isReservingTimeSlot = false
    
    @Published var viewDismissed: Bool = false
    
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
        
        if availableDeliveryDays.count > 1 { return false }
        
        return true
    }
    
    var isASAPDeliveryDisabled: Bool {
        if let startDate = availableDeliveryDays.first?.storeDateStart {
            return !Calendar.current.isDateInToday(startDate)
        }
        return true
    }
    
    private var cancellables = Set<AnyCancellable>()
    
    init(container: DIContainer) {
        self.container = container
        let appState = container.appState
        
        _selectedRetailStoreDetails = .init(initialValue: appState.value.userData.selectedStore)
        _storeSearchResult = .init(initialValue: appState.value.userData.searchResult)
        
        setupSelectedRetailStoreDetails(with: appState)
        setupStoreSearchResult(with: appState)
        setupAvailableDeliveryDays()
    }
    
    private func setupSelectedRetailStoreDetails(with appState: Store<AppState>) {
        appState
            .map(\.userData.selectedStore)
            .removeDuplicates()
            .receive(on: RunLoop.main)
            .assignWeak(to: \.selectedRetailStoreDetails, on: self)
            .store(in: &cancellables)
    }
    
    private func setupStoreSearchResult(with appState: Store<AppState>) {
        appState
            .map(\.userData.searchResult)
            .removeDuplicates()
            .assignWeak(to: \.storeSearchResult, on: self)
            .store(in: &cancellables)
    }
    
    private func setupAvailableDeliveryDays() {
        $selectedRetailStoreDetails
            .removeDuplicates()
            .map { ($0.value?.deliveryDays ?? [], $0.value?.id) }
            .map { [weak self] availableDays, id in
                guard let self = self else { return availableDays }
                self.selectFirstFutureDay(availableDays: availableDays, storeID: id)
                return availableDays
            }
            .receive(on: RunLoop.main)
            .assignWeak(to: \.availableDeliveryDays, on: self)
            .store(in: &cancellables)
    }
    
    // Not tested due to setup complexity as it should not be exposed publically.
    // It is not an essential functionality, so ROI on testing setup time currently not deemed worth it.
    // It would be nice to see test in future as it is a tad complex.
    private func selectFirstFutureDay(availableDays: [RetailStoreFulfilmentDay], storeID: Int?) {
        if availableDays.count > 1 {
            #warning("Add true time today check")
            // https://github.com/MobileNativeFoundation/Kronos
            if let startDate = availableDays.first?.storeDateStart, Calendar.current.isDateInToday(startDate) {
                if let startDate = availableDays[1].storeDateStart, let endDate = availableDays[1].storeDateEnd, let storeID = storeID {
                    self.selectDeliveryDate(startDate: startDate, endDate: endDate, storeID: storeID)
                }
            } else {
                if let startDate = availableDays.first?.storeDateStart, let endDate = availableDays.first?.storeDateEnd, let storeID = storeID {
                    self.selectDeliveryDate(startDate: startDate, endDate: endDate, storeID: storeID)
                }
            }
        } else if availableDays.count == 1 {
            if let startDate = availableDays.first?.storeDateStart, Calendar.current.isDateInToday(startDate) == false, let endDate = availableDays.first?.storeDateEnd, let storeID = storeID {
                self.selectDeliveryDate(startDate: startDate, endDate: endDate, storeID: storeID)
            }
        }
    }
    
    private func setupSelectedTimeDaySlot() {
        $selectedRetailStoreDeliveryTimeSlots
            .map { $0.value?.slotDays?.first }
            .assignWeak(to: \.selectedDaySlot, on: self)
            .store(in: &cancellables)
    }
    
    private func setupDeliveryDaytimeSectionSlots() {
        // Morning slots
        $selectedDaySlot
            .map { [weak self] timeSlot in
                self?.selectedTimeSlot = nil
                if let slots = timeSlot?.slots {
                    return slots.filter { $0.daytime == "morning" }
                }
                return []
            }
            .receive(on: RunLoop.main)
            .assignWeak(to: \.morningTimeSlots, on: self)
            .store(in: &cancellables)
        
        // Afternoon slots
        $selectedDaySlot
            .map { [weak self] timeSlot in
                self?.selectedTimeSlot = nil
                if let slots = timeSlot?.slots {
                    return slots.filter { $0.daytime == "afternoon" }
                }
                return []
            }
            .receive(on: RunLoop.main)
            .assignWeak(to: \.afternoonTimeSlots, on: self)
            .store(in: &cancellables)
        
        // Evening slots
        $selectedDaySlot
            .map { [weak self] timeSlot in
                self?.selectedTimeSlot = nil
                if let slots = timeSlot?.slots {
                    return slots.filter { $0.daytime == "evening" }
                }
                return []
            }
            .receive(on: RunLoop.main)
            .assignWeak(to: \.eveningTimeSlots, on: self)
            .store(in: &cancellables)
    }
    
    func selectDeliveryDate(startDate: Date, endDate: Date, storeID: Int?) {
        if let location = storeSearchResult.value?.fulfilmentLocation.location, let id =  storeID {
            
            container.services.retailStoresService.getStoreDeliveryTimeSlots(slots: loadableSubject(\.selectedRetailStoreDeliveryTimeSlots), storeId: id, startDate: startDate, endDate: endDate, location: location)
        }
        #warning("Should there be an else here if unwrapping fails?")
    }
    
    #warning("Replace print with logging below")
    private func reserveTimeSlot(date: String, time: String?) {
        self.isReservingTimeSlot = true
        
        container.services.basketService.reserveTimeSlot(timeSlotDate: date, timeSlotTime: time)
            .receive(on: RunLoop.main)
            .sink { completion in
                switch completion {
                case .finished:
                    print("Reserved \(date) \(String(describing: time)) slot")
                case .failure(let error):
                    print("Error reserving \(date) \(String(describing: time)) - \(error)")
                    #warning("Code to handle error?")
                    self.isReservingTimeSlot = false
                }
            } receiveValue: { _ in
                self.isReservingTimeSlot = false
                self.continueToItemMenu()
            }
            .store(in: &cancellables)
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
        if isASAPDeliveryDisabled == false, let day = availableDeliveryDays.first?.date {
            reserveTimeSlot(date: day, time: nil)
        }
    }
    
    func futureDeliveryTapped() {
        isFutureDeliverySelected = true
    }
    
    func shopNowButtonTapped() {
        if let day = selectedDaySlot?.slotDate, let time = selectedTimeSlot {
            reserveTimeSlot(date: day, time: time)
        }
    }
    
    func continueToItemMenu() {
        dismissView()
        container.appState.value.routing.selectedTab = 2
    }
    
    func dismissView() {
        viewDismissed = true
    }
}
