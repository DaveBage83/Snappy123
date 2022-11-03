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
    typealias CustomStrings = Strings.SlotSelection.Customisable
    
    // Following enum allows us to access title strings for different day periods (morning, afternoon, evening) as well
    // as the slots themselves for each period
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
    
    // Allows us to define whether we are in original selection mode or change mode. This controls properties such as the button text
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
    @Published var basket: Basket?
    @Published var isPaused = false
    @Published var showSuccessfullyUpdateTimeSlotAlert = false
    @Published var noSlotsAvailable = false
    
    // MARK: - Properties
    let container: DIContainer
    let isInCheckout: Bool // When in checkout we allow user to select specific timeslots for today, otherwise we only select ASAP
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
    
    var showNoSlotsAvailableView: Bool {
        noSlotsAvailable && isTimeSlotsLoading == false
    }
    
    var todayFulfilmentExists: Bool {
        if let startDate = availableFulfilmentDays.first?.date.stringToDateOnly {
            return Calendar.current.isDateInToday(startDate)
        }
        return false
    }
    

    // MARK: - Fulfilment timeframe
    // When not in checkout, we display a message to user to inform of expected timeframe for fulfilment
    
    // Following string controls this timeframe message
    var fulfilmentInTimeframeMessage: String {
        if fulfilmentType == .delivery {
            return CustomStrings.deliveryInTimeframe.localizedFormat(earliestFulfilmentTimeString ?? "")
        }
        
        return CustomStrings.collectionInTimeframe.localizedFormat(earliestFulfilmentTimeString ?? "")
    }
    
    // Following bool controls which icon is shown along with timeframe message (delivery / collection)
    var showDeliveryIconInFulfilmentInTimeframeMessage: Bool {
        fulfilmentType == .delivery
    }
    
    // When in checkout, user has already committed to fulfilment type so we do not allow to change here.
    // Also if either delivery or collection slots are empty we should not show this toggle.
    var showFulfilmentToggle: Bool {
        isInCheckout == false && selectedRetailStoreDetails.value?.deliveryDays.isEmpty == false && selectedRetailStoreDetails.value?.collectionDays.isEmpty == false
    }
    
    var selectSlotAtCheckoutMessage: String {
        if fulfilmentType == .delivery {
          return Strings.SlotSelection.selectDeliverySlotAtCheckout.localized
        }
        return Strings.SlotSelection.selectCollectionSlotAtCheckout.localized
    }

    // MARK: - Init
    init(container: DIContainer, isInCheckout: Bool = false, state: State = .timeSlotSelection, timeslotSelectedAction: @escaping () -> Void = {}) {
        self.container = container
        let appState = container.appState
        self.timeslotSelectedAction = timeslotSelectedAction
        
        _selectedRetailStoreDetails = .init(initialValue: appState.value.userData.selectedStore)
        _storeSearchResult = .init(initialValue: appState.value.userData.searchResult)
        _fulfilmentType = .init(initialValue: appState.value.userData.selectedFulfilmentMethod)
        _basket = .init(initialValue: appState.value.userData.basket)

        self.isInCheckout = isInCheckout
        self.state = state

        setupSelectedRetailStoreDetails(with: appState)
        setupStoreSearchResult(with: appState)
        setupAvailableFulfilmentDays()
        
        setupFulfilmentMethod(with: appState)
        setupFulfilmentType()

        setupBasket(with: appState)
        setupSelectedTimeDaySlot()
        setupDeliveryDaytimeSectionSlots()
    }
    
    // MARK: - Setup subscriptions
    private func setupBasket(with appState: Store<AppState>) {
        appState
            .map(\.userData.basket)
            .receive(on: RunLoop.main)
            .assignWeak(to: \.basket, on: self)
            .store(in: &cancellables)
    }
    
    private func setupFulfilmentMethod(with appState: Store<AppState>) {
        appState
            .map(\.userData.selectedFulfilmentMethod)
            .removeDuplicates()
            .sink(receiveValue: { [weak self] method in
                guard let self = self else { return }
                self.fulfilmentType = method
            })
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
            .receive(on: RunLoop.main)
            .assignWeak(to: \.storeSearchResult, on: self)
            .store(in: &cancellables)
    }

    private func setupFulfilmentType() {
        $fulfilmentType
            .dropFirst()
            .receive(on: RunLoop.main)
            .sink { [weak self] method in
                guard let self = self else { return }
                self.setFulfilmentDays(method: method)
            }
            .store(in: &cancellables)
    }
    
    private func setFulfilmentDays(method: RetailStoreOrderMethodType) {
        self.isPaused = self.selectedRetailStoreDetails.value?.ordersPaused ?? false
        self.pausedMessage = self.selectedRetailStoreDetails.value?.pausedMessage
        
        let fulfilmentDays = method == .delivery ? self.selectedRetailStoreDetails.value?.deliveryDays ?? [] : self.selectedRetailStoreDetails.value?.collectionDays ?? []
        
        self.selectHighlightedDay(availableDays: fulfilmentDays, storeID: self.selectedRetailStoreDetails.value?.id)
        self.availableFulfilmentDays = fulfilmentDays
    }
    
    private func setupAvailableFulfilmentDays() {
        $selectedRetailStoreDetails
            .sink { [weak self] _ in
                guard let self = self else { return }
                self.setFulfilmentDays(method: self.fulfilmentType)
            }
            .store(in: &cancellables)
    }

    private func selectHighlightedDay(availableDays: [RetailStoreFulfilmentDay], storeID: Int?) {
        if self.isInCheckout,
                  let tempTimeSlot = self.container.appState.value.userData.tempTodayTimeSlot {
            
            // If there's a temporary slot selected and in checkout process, select temp slot day
            self.selectFulfilmentDate(startDate: tempTimeSlot.startTime.startOfDay, endDate: tempTimeSlot.endTime.endOfDay, storeID: storeID)
        } else if let start = self.basket?.selectedSlot?.start, let end = self.basket?.selectedSlot?.end {
            
            // If there's a selected slot in basket, select basket slot day
            self.selectFulfilmentDate(startDate: start.startOfDay, endDate: end.endOfDay, storeID: self.selectedRetailStoreDetails.value?.id)
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
            .sink(receiveValue: { [weak self] slotDay in
                guard let self = self else { return }
                
                if let firstSlot = slotDay?.slots?.first, firstSlot.startTime.isToday {
                    if self.isInCheckout == false {
                        self.noSlotsAvailable = false
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
                
                if let slots = slotDay?.slots {
                    self.noSlotsAvailable = false
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
                } else {
                    self.noSlotsAvailable = true
                }
            })
            .store(in: &cancellables)
    }
        
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

    private func reserveTimeSlot(date: String, time: String?, tempTimeSlot: RetailStoreSlotDayTimeSlot? = nil) async {
        self.isReservingTimeSlot = true
        
        do {
            try await container.services.basketService.reserveTimeSlot(timeSlotDate: date, timeSlotTime: time)
            Logger.fulfilmentTimeSlotSelection.info("Reserved \(date) \(String(describing: time)) slot")
            self.isReservingTimeSlot = false
            self.container.appState.value.userData.tempTodayTimeSlot = tempTimeSlot
            self.dismissView()
        } catch {
            self.container.appState.value.errors.append(error)
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
            }
        } else {
            if let day = selectedDaySlot?.slotDate, let timeSlot = selectedTimeSlot {
                if isSlotSelectedToday, isInCheckout == true {
                    await reserveTimeSlot(date: day, time: nil, tempTimeSlot: timeSlot)
                    dismissView()
                } else {
                    let timeZone = selectedRetailStoreDetails.value?.storeTimeZone
                    let startTime = timeSlot.startTime.hourMinutesString(timeZone: timeZone)
                    let endTime = timeSlot.endTime.hourMinutesString(timeZone: timeZone)
                    let stringTimeSlot = "\(startTime) - \(endTime)"

                    await reserveTimeSlot(date: day, time: stringTimeSlot)
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
    
    func resetFulfilment() {
        // If user has toggled fulfilment but not committed to the change, we ensure the selectedFulfilmentType in the appState is restored accordingly
        guard let selectedFulfilment = container.appState.value.userData.basket?.fulfilmentMethod, selectedFulfilment.type != fulfilmentType else { return }
        
        container.appState.value.userData.selectedFulfilmentMethod = selectedFulfilment.type
    }
}
