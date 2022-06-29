//
//  FulfilmentTimeSlotSelectionViewModel.swift
//  SnappyV2
//
//  Created by Henrik Gustavii on 24/09/2021.
//
import Foundation
import Combine
import OSLog

@MainActor
class FulfilmentTimeSlotSelectionViewModel: ObservableObject {
    enum FulfilmentSlotPeriod {
        case morning
        case afternoon
        case evening
        
        var title: String {
            switch self {
            case .morning:
                return Strings.SlotSelection.morningSlots.localized
            case .afternoon:
                return Strings.SlotSelection.afternoonSlots.localized
            case .evening:
                return Strings.SlotSelection.eveningSlots.localized
            }
        }
        
        @MainActor func slots(viewModel: FulfilmentTimeSlotSelectionViewModel) -> [RetailStoreSlotDayTimeSlot] {
            switch self {
            case .morning:
                return viewModel.morningTimeSlots
            case .afternoon:
                return viewModel.afternoonTimeSlots
            case .evening:
                return viewModel.eveningTimeSlots
            }
        }
    }
    
    enum State {
        case timeSlotSelection
        case changeTimeSlot
    }
    
    // MARK: - Publishers
    @Published var storeSearchResult: Loadable<RetailStoresSearch>
    @Published var selectedRetailStoreDetails: Loadable<RetailStoreDetails>
    @Published var selectedRetailStoreFulfilmentTimeSlots: Loadable<RetailStoreTimeSlots> = .notRequested
    @Published var isReservingTimeSlot = false
    @Published var viewDismissed: Bool = false
    @Published var availableFulfilmentDays = [RetailStoreFulfilmentDay]()
    @Published var selectedDate: Date?
    @Published var selectedDaySlot: RetailStoreSlotDay?
    @Published var morningTimeSlots = [RetailStoreSlotDayTimeSlot]()
    @Published var afternoonTimeSlots = [RetailStoreSlotDayTimeSlot]()
    @Published var eveningTimeSlots = [RetailStoreSlotDayTimeSlot]()
    @Published var selectedTimeSlot: RetailStoreSlotDayTimeSlot?
    @Published var fulfilmentType: RetailStoreOrderMethodType
    @Published var isTodaySelectedWithSlotSelectionRestrictions: Bool = false
    @Published var earliestFulfilmentTimeString: String?
    @Published private(set) var error: Error?
    @Published var basket: Basket?
    @Published var isPaused = false
    @Published var showSuccessfullyUpdateTimeSlotAlert = false
    
    // MARK: - Properties
    let container: DIContainer
    let isInCheckout: Bool
    private var timeslotSelectedAction: () -> Void
    var pausedMessage: String?
    private var cancellables = Set<AnyCancellable>()
    let state: State
    
    // MARK: - Computed variables
    var isFulfilmentSlotSelected: Bool { isTodaySelectedWithSlotSelectionRestrictions || (selectedDaySlot != nil && selectedTimeSlot != nil) }
    
    var slotDescription: String { fulfilmentType == .delivery ? GeneralStrings.delivery.localized : GeneralStrings.collection.localized }
    
    var isSlotSelectedToday: Bool {
        if isInCheckout, let startTime = selectedTimeSlot?.startTime {
            return Calendar.current.isDateInToday(startTime)
        }
        return false
    }
    
    var todayFulfilmentExists: Bool {
        if let startDate = availableFulfilmentDays.first?.date.stringToDateOnly {
            return Calendar.current.isDateInToday(startDate)
        }
        return false
    }

    // MARK: - Init
    init(container: DIContainer, isInCheckout: Bool = false, state: State = .timeSlotSelection, overrideFulfilmentType: RetailStoreOrderMethodType? = nil, timeslotSelectedAction: @escaping () -> Void = {}) {
        self.container = container
        let appState = container.appState
        self.timeslotSelectedAction = timeslotSelectedAction
        
        _selectedRetailStoreDetails = .init(initialValue: appState.value.userData.selectedStore)
        _storeSearchResult = .init(initialValue: appState.value.userData.searchResult)
        _fulfilmentType = .init(initialValue: appState.value.userData.selectedFulfilmentMethod)
        _basket = .init(initialValue: appState.value.userData.basket)
        
        if let overrideFulfilmentType = overrideFulfilmentType {
            self.fulfilmentType = overrideFulfilmentType
        }
        
        self.isInCheckout = isInCheckout
        self.state = state
        
        setupSelectedRetailStoreDetails(with: appState)
        setupStoreSearchResult(with: appState)
        setupAvailableFulfilmentDays()
        
        if overrideFulfilmentType == nil {
            setupFulfilmentMethod()
        }
        
        setupBasket(with: appState)
        setupSelectedTimeDaySlot()
        setupDeliveryDaytimeSectionSlots()
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
                self.isPaused = details.value?.ordersPaused ?? false
                self.pausedMessage = details.value?.pausedMessage
                let fulfilmentDays = self.fulfilmentType == .delivery ? details.value?.deliveryDays ?? [] : details.value?.collectionDays ?? []
                return (fulfilmentDays, details.value?.id)
            }
            .map { [weak self] availableDays, id in
                guard let self = self else { return availableDays }
                
                self.selectHighlightedDay(availableDays: availableDays, storeID: id)
                
                return availableDays
            }
            .receive(on: RunLoop.main)
            .assignWeak(to: \.availableFulfilmentDays, on: self)
            .store(in: &cancellables)
    }
    
    private func selectHighlightedDay(availableDays: [RetailStoreFulfilmentDay], storeID: Int?) {
        if let start = self.basket?.selectedSlot?.start, let end = self.basket?.selectedSlot?.end {
            
            // If there's a selected slot in basket, select basket slot day
            self.selectFulfilmentDate(startDate: start.startOfDay, endDate: end.endOfDay, storeID: self.selectedRetailStoreDetails.value?.id)
        } else if self.isInCheckout, let tempTimeSlot = self.container.appState.value.userData.tempTodayTimeSlot {
            
            // If there's a temporary slot selected and in checkout process, select temp slot day
            self.selectFulfilmentDate(startDate: tempTimeSlot.startTime.startOfDay, endDate: tempTimeSlot.endTime.endOfDay, storeID: storeID)
        } else if let startDate = availableDays.first?.storeDateStart, let endDate = availableDays.first?.storeDateEnd, let storeID = storeID {
            
            // If none of the above, select first available day
            self.selectFulfilmentDate(startDate: startDate, endDate: endDate, storeID: storeID)
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
                
                if let firstSlot = slotDays?.slots?.first, firstSlot.startTime.isToday {
                    if self.isInCheckout == false {
                        self.isTodaySelectedWithSlotSelectionRestrictions = true
                        self.earliestFulfilmentTimeString = firstSlot.info.fulfilmentIn
                        return
                    }
                } else {
                    self.isTodaySelectedWithSlotSelectionRestrictions = false
                    self.earliestFulfilmentTimeString = nil
                }
                
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
                    
                    // Selects the time slot that is stored in tempoTodayTimeSlot in AppState
                    if let tempTodaySlot = self.container.appState.value.userData.tempTodayTimeSlot {
                        self.selectedTimeSlot = tempTodaySlot
                    }
                }
            })
            .store(in: &cancellables)
    }
        
    #warning("Consider using fulfilment location in AppState and remove coupling to AppState store search")
    func selectFulfilmentDate(startDate: Date, endDate: Date, storeID: Int?) {
        self.selectedDate = startDate
        if let fulfilmentLocation = storeSearchResult.value?.fulfilmentLocation, let id = storeID {
            if fulfilmentType == .delivery {
                container.services.retailStoresService.getStoreDeliveryTimeSlots(slots: loadableSubject(\.selectedRetailStoreFulfilmentTimeSlots), storeId: id, startDate: startDate, endDate: endDate, location: fulfilmentLocation.location)
            } else if fulfilmentType == .collection {
                container.services.retailStoresService.getStoreCollectionTimeSlots(slots: loadableSubject(\.selectedRetailStoreFulfilmentTimeSlots), storeId: id, startDate: startDate, endDate: endDate)
            } else {
                Logger.fulfilmentTimeSlotSelection.fault("'selectFulfilmentDate' failed - \(self.fulfilmentType.rawValue)")
            }
        } else {
            Logger.fulfilmentTimeSlotSelection.fault("'selectFulfilmentDate' failed checks")
        }
    }

    private func reserveTimeSlot(date: String, time: String?) async {
        self.isReservingTimeSlot = true
        
        do {
            try await container.services.basketService.reserveTimeSlot(timeSlotDate: date, timeSlotTime: time)
            Logger.fulfilmentTimeSlotSelection.info("Reserved \(date) \(String(describing: time)) slot")
            self.isReservingTimeSlot = false
            self.dismissView()
        } catch {
            self.error = error
            Logger.fulfilmentTimeSlotSelection.error("Error reserving \(date) \(String(describing: time)) - \(error.localizedDescription)")
            self.isReservingTimeSlot = false
        }
    }
    
    var isTimeSlotsLoading: Bool {
        switch selectedRetailStoreFulfilmentTimeSlots {
        case .isLoading(last: _, cancelBag: _):
            return true
        default:
            return false
        }
    }
    
    func shopNowButtonTapped() async {
        if isTodaySelectedWithSlotSelectionRestrictions {
            if todayFulfilmentExists, let day = availableFulfilmentDays.first?.date {
                await reserveTimeSlot(date: day, time: nil)
                if state == .changeTimeSlot {
                    container.appState.value.userData.selectedFulfilmentMethod = fulfilmentType
                    showSuccessfullyUpdateTimeSlotAlert = true
                }
            }
        } else {
            if let day = selectedDaySlot?.slotDate, let timeSlot = selectedTimeSlot {
                if isSlotSelectedToday {
                    container.appState.value.userData.tempTodayTimeSlot = timeSlot
                    dismissView()
                } else {
                    let timeZone = selectedRetailStoreDetails.value?.storeTimeZone
                    let startTime = timeSlot.startTime.hourMinutesString(timeZone: timeZone)
                    let endTime = timeSlot.endTime.hourMinutesString(timeZone: timeZone)
                    let stringTimeSlot = "\(startTime) - \(endTime)"
                    await reserveTimeSlot(date: day, time: stringTimeSlot)
                    if state == .changeTimeSlot {
                        container.appState.value.userData.selectedFulfilmentMethod = fulfilmentType
                        showSuccessfullyUpdateTimeSlotAlert = true
                    }
                }
            }
        }
    }
    
    // Holiday message is returned with the available days array returned via stores/select.json rather than
    // on the response from stores/slots/list.json. We therefore need to retrieve the correct message at the
    // time of hitting this endpoint
    func getHolidayMessage(for date: String?) -> String? {
        availableFulfilmentDays.filter { $0.date == date }[0].holidayMessage
    }
    
    private func dismissView() {
        timeslotSelectedAction()
        viewDismissed = true
    }
}
