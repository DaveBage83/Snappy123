//
//  FulfilmentTimeSlotSelectionViewModel.swift
//  SnappyV2
//
//  Created by Henrik Gustavii on 24/09/2021.
//
import Foundation
import Combine

class FulfilmentTimeSlotSelectionViewModel: ObservableObject {
    let container: DIContainer
    @Published var storeSearchResult: Loadable<RetailStoresSearch>
    @Published var selectedRetailStoreDetails: Loadable<RetailStoreDetails>
    @Published var selectedRetailStoreFulfilmentTimeSlots: Loadable<RetailStoreTimeSlots> = .notRequested
    @Published var isReservingTimeSlot = false
    
    @Published var viewDismissed: Bool = false
    
    @Published var availableFulfilmentDays = [RetailStoreFulfilmentDay]()
    
    @Published var selectedDaySlot: RetailStoreSlotDay?
    @Published var morningTimeSlots = [RetailStoreSlotDayTimeSlot]()
    @Published var afternoonTimeSlots = [RetailStoreSlotDayTimeSlot]()
    @Published var eveningTimeSlots = [RetailStoreSlotDayTimeSlot]()
    @Published var selectedTimeSlot: RetailStoreSlotDayTimeSlot?
    @Published var fulfilmentType: RetailStoreOrderMethodType
    @Published var isFutureFulfilmentSelected = false
    var timeslotSelectedAction: () -> Void
    
    @Published var basket: Basket?
    
    var isFulfilmentSlotSelected: Bool {
        return selectedDaySlot != nil && selectedTimeSlot != nil
    }
    
    var slotDescription: String {
        return fulfilmentType == .delivery ? GeneralStrings.delivery.localized : GeneralStrings.collection.localized
    }

    var isFutureFulfilmentDisabled: Bool {
        if availableFulfilmentDays.isEmpty { return true }
        
        if isTodayFulfilmentDisabled == true { return false }
        
        if availableFulfilmentDays.count > 1 { return false }
        
        return true
    }
    
    var isTodayFulfilmentDisabled: Bool {
        if let startDate = availableFulfilmentDays.first?.storeDateStart {
            return !Calendar.current.isDateInToday(startDate)
        }
        return true
    }

    private var cancellables = Set<AnyCancellable>()
    
    init(container: DIContainer, timeslotSelectedAction: @escaping () -> Void = {}) {
        self.container = container
        let appState = container.appState
        self.timeslotSelectedAction = timeslotSelectedAction
        
        _selectedRetailStoreDetails = .init(initialValue: appState.value.userData.selectedStore)
        _storeSearchResult = .init(initialValue: appState.value.userData.searchResult)
        _fulfilmentType = .init(initialValue: appState.value.userData.selectedFulfilmentMethod)
        _basket = .init(initialValue: appState.value.userData.basket)
        
        setupSelectedRetailStoreDetails(with: appState)
        setupStoreSearchResult(with: appState)
        setupAvailableFulfilmentDays()
        setupFulfilmentMethod()
        setupBasket(with: appState)
    }
    
    private func setupBasket(with appState: Store<AppState>) {
        appState
            .map(\.userData.basket)
            .receive(on: RunLoop.main)
            .assignWeak(to: \.basket, on: self)
            .store(in: &cancellables)
    }
    
    private func setupFulfilmentMethod() {
        container.appState
            .map(\.userData.selectedFulfilmentMethod)
            .removeDuplicates()
            .assignWeak(to: \.fulfilmentType, on: self)
            .store(in: &cancellables)
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
    
    private func setupAvailableFulfilmentDays() {
        $selectedRetailStoreDetails
            .removeDuplicates()
            .map { [weak self] details -> ([RetailStoreFulfilmentDay], Int?) in
                guard let self = self else { return ([], nil)}
                let fulfilmentDays = self.fulfilmentType == .delivery ? details.value?.deliveryDays ?? [] : details.value?.collectionDays ?? []
                return (fulfilmentDays, details.value?.id)
            }
            .map { [weak self] availableDays, id in
                guard let self = self else { return availableDays }
                if self.basket?.selectedSlot == nil {
                    // Highlights the first future day, if there's no selected slot in basket
                    self.selectFirstFutureDay(availableDays: availableDays, storeID: id)
                }
                return availableDays
            }
            .receive(on: RunLoop.main)
            .assignWeak(to: \.availableFulfilmentDays, on: self)
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
                    self.selectFulfilmentDate(startDate: startDate, endDate: endDate, storeID: storeID)
                }
            } else {
                if let startDate = availableDays.first?.storeDateStart, let endDate = availableDays.first?.storeDateEnd, let storeID = storeID {
                    self.selectFulfilmentDate(startDate: startDate, endDate: endDate, storeID: storeID)
                }
            }
        } else if availableDays.count == 1 {
            if let startDate = availableDays.first?.storeDateStart, Calendar.current.isDateInToday(startDate) == false, let endDate = availableDays.first?.storeDateEnd, let storeID = storeID {
                self.selectFulfilmentDate(startDate: startDate, endDate: endDate, storeID: storeID)
            }
        }
    }
    
    private func setupSelectedTimeDaySlot() {
        $selectedRetailStoreFulfilmentTimeSlots
            .map { $0.value?.slotDays?.first }
            .assignWeak(to: \.selectedDaySlot, on: self)
            .store(in: &cancellables)
    }
    
    private func clearSlots() {
        morningTimeSlots = []
        afternoonTimeSlots = []
        eveningTimeSlots = []
    }
    
    private func setupDeliveryDaytimeSectionSlots() {
        $selectedDaySlot
            .removeDuplicates()
            .receive(on: RunLoop.main)
            .sink(receiveValue: { [weak self] slotDays in
                guard let self = self else { return }
                
                self.selectedTimeSlot = nil
                self.clearSlots()
                
                if let slots = slotDays?.slots {
                    self.morningTimeSlots = slots.filter { $0.daytime == "morning" }
                    self.afternoonTimeSlots = slots.filter { $0.daytime == "afternoon" }
                    self.eveningTimeSlots = slots.filter { $0.daytime == "evening" }
                    
                    // Selects the time slot if there exists a selected time in the basket object
                    if let start = self.basket?.selectedSlot?.start, let end = self.basket?.selectedSlot?.end {
                        if let slot = slots.first(where: { $0.startTime == start && $0.endTime == end }) {
                            self.selectedTimeSlot = slot
                        }
                    }
                }
            })
            .store(in: &cancellables)
    }
    
    func selectFulfilmentDate(startDate: Date, endDate: Date, storeID: Int?) {
        if let location = storeSearchResult.value?.fulfilmentLocation.location, let id = storeID {
            if fulfilmentType == .delivery {
                container.services.retailStoresService.getStoreDeliveryTimeSlots(slots: loadableSubject(\.selectedRetailStoreFulfilmentTimeSlots), storeId: id, startDate: startDate, endDate: endDate, location: location)
            } else if fulfilmentType == .collection {
                container.services.retailStoresService.getStoreCollectionTimeSlots(slots: loadableSubject(\.selectedRetailStoreFulfilmentTimeSlots), storeId: id, startDate: startDate, endDate: endDate)
            }
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
                self.dismissView()
            }
            .store(in: &cancellables)
    }
    
    var isTimeSlotsLoading: Bool {
        switch selectedRetailStoreFulfilmentTimeSlots {
        case .isLoading(last: _, cancelBag: _):
            return true
        default:
            return false
        }
    }
    
    func futureFulfilmentSetup() {
        setupSelectedTimeDaySlot()
        setupDeliveryDaytimeSectionSlots()
        
        if let selectedSlot = basket?.selectedSlot {
            showPreselectedSlot(selectedSlot: selectedSlot)
        }
    }
    
    func showPreselectedSlot(selectedSlot: BasketSelectedSlot) {
        if let start = selectedSlot.start, let end = selectedSlot.end {
            selectFulfilmentDate(startDate: start.startOfDay, endDate: end.endOfDay, storeID: selectedRetailStoreDetails.value?.id)
        }
    }
    
    func todayFulfilmentTapped() {
        if isTodayFulfilmentDisabled == false, let day = availableFulfilmentDays.first?.date {
            reserveTimeSlot(date: day, time: nil)
        }
    }
    
    func futureFulfilmentTapped() {
        isFutureFulfilmentSelected = true
    }
    
    func shopNowButtonTapped() {
        if let day = selectedDaySlot?.slotDate, let timeSlot = selectedTimeSlot {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "HH:mm"
            dateFormatter.timeZone = selectedRetailStoreDetails.value?.storeTimeZone
            let startTime = dateFormatter.string(from: timeSlot.startTime)
            let endTime = dateFormatter.string(from: timeSlot.endTime)
            let stringTimeSlot = "\(startTime) - \(endTime)"
            reserveTimeSlot(date: day, time: stringTimeSlot)
        }
    }
    
    func dismissView() {
        viewDismissed = true
        timeslotSelectedAction()
    }
}
