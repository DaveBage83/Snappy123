//
//  CheckoutFulfilmentInfoViewModel.swift
//  SnappyV2
//
//  Created by Henrik Gustavii on 10/02/2022.
//

import Foundation
import Combine
import CoreLocation
import OSLog

class CheckoutFulfilmentInfoViewModel: ObservableObject {
    enum PaymentNavigation {
        case payByCard
        case payByApple
        case payByCash
    }
    
    let container: DIContainer
    private let selectedStore: RetailStoreDetails?
    private let fulfilmentType: RetailStoreOrderMethodType
    @Published var selectedRetailStoreFulfilmentTimeSlots: Loadable<RetailStoreTimeSlots> = .notRequested
    var deliveryLocation: Location?
    @Published var basket: Basket?
    @Published var postcode = ""
    @Published var instructions = ""
    
    @Published var tempTodayTimeSlot: RetailStoreSlotDayTimeSlot?
    let wasPaymentUnsuccessful: Bool
    @Published var navigateToPaymentHandling: PaymentNavigation?
    private let memberSignedIn: Bool
    var isDeliveryAddressSet: Bool { selectedDeliveryAddress != nil }
    @Published var selectedDeliveryAddress: SelectedAddress?
    var prefilledAddressName: Name?
    
    private var cancellables = Set<AnyCancellable>()
    
    init(container: DIContainer, wasPaymentUnsuccessful: Bool = false) {
        self.container = container
        let appState = container.appState
        basket = appState.value.userData.basket
        fulfilmentType = appState.value.userData.selectedFulfilmentMethod
        selectedStore = appState.value.userData.selectedStore.value
        _selectedDeliveryAddress = .init(initialValue: appState.value.userData.basketDeliveryAddress)
        self.wasPaymentUnsuccessful = wasPaymentUnsuccessful
        self.memberSignedIn = container.appState.value.userData.memberSignedIn
        
        if let basketContactDetails = appState.value.userData.basketContactDetails {
            self.prefilledAddressName = Name(firstName: basketContactDetails.firstName, secondName: basketContactDetails.surname)
        }
        
        setupBasket(with: appState)
        setupDeliveryLocation()
        setupSelectedDeliveryAddressBinding(with: appState)
        setupTempTodayTimeSlot(with: appState)
        setupAutoAssignASAPTimeSlot()
    }
    
    private func setupBasket(with appState: Store<AppState>) {
        appState
            .map(\.userData.basket)
            .receive(on: RunLoop.main)
            .assignWeak(to: \.basket, on: self)
            .store(in: &cancellables)
    }
    
    private func setupDeliveryLocation() {
        $basket
            .removeDuplicates()
            .sink { [weak self] basket in
                guard let self = self else { return }
                if let address = basket?.addresses?.first(where: { $0.type == RetailStoreOrderMethodType.delivery.rawValue }) {
                    self.deliveryLocation = address.location
                }
            }
            .store(in: &cancellables)
    }
    
    private func setupSelectedDeliveryAddressBinding(with appState: Store<AppState>) {
        $selectedDeliveryAddress
            .removeDuplicates()
            .sink { appState.value.userData.basketDeliveryAddress = $0 }
            .store(in: &cancellables)
        
        appState
            .map(\.userData.basketDeliveryAddress)
            .removeDuplicates()
            .assignWeak(to: \.selectedDeliveryAddress, on: self)
            .store(in: &cancellables)
    }
    
    private func setupTempTodayTimeSlot(with appState: Store<AppState>) {
        $tempTodayTimeSlot
            .removeDuplicates()
            .sink { appState.value.userData.tempTodayTimeSlot = $0 }
            .store(in: &cancellables)
        
        appState
            .map(\.userData.tempTodayTimeSlot)
            .removeDuplicates()
            .assignWeak(to: \.tempTodayTimeSlot, on: self)
            .store(in: &cancellables)
    }
    
    private func setupAutoAssignASAPTimeSlot() {
        $selectedRetailStoreFulfilmentTimeSlots
            .removeDuplicates()
            .receive(on: RunLoop.main)
            .sink { [weak self] timeSlots in
                guard let self = self else { return }
                if self.basket?.selectedSlot?.todaySelected == true, self.tempTodayTimeSlot == nil {
                    if let tempTimeSlot = timeSlots.value?.slotDays?.first?.slots?.first {
                        self.tempTodayTimeSlot = tempTimeSlot
                    }
                }
            }
            .store(in: &cancellables)
    }
    
    #warning("Do we need to cater for email and telephone number missing?")
    func setDelivery(address: SelectedAddress) {
        let basketAddressRequest = BasketAddressRequest(
            firstName: address.firstName,
            lastName: address.lastName,
            addressline1: address.address.addressline1,
            addressline2: address.address.addressline2,
            town: address.address.town,
            postcode: address.address.postcode,
            countryCode: address.country?.countryCode ?? AppV2Constants.Business.operatingCountry,
            type: "delivery",
            email: container.appState.value.userData.basketContactDetails?.email ?? "",
            telephone: container.appState.value.userData.basketContactDetails?.telephoneNumber ?? "",
            state: nil,
            county: address.address.county,
            location: nil)
        container.services.basketService.setDeliveryAddress(to: basketAddressRequest)
            .receive(on: RunLoop.main)
            .sinkToResult({ [weak self] result in
                guard let self = self else { return }
                switch result {
                case .failure(let error):
                    Logger.checkout.error("Failure to set delivery address - \(error.localizedDescription)")
                case .success(_):
                    Logger.checkout.info("Successfully added delivery address")
                    #warning("Might want to clear selectedDeliveryAddress at some point")
                    self.selectedDeliveryAddress = address
                    self.checkAndAssignASAP()
                }
            })
            .store(in: &cancellables)
    }
    
    #warning("Replace store location with one returned from basket addresses")
    private func checkAndAssignASAP() {
        if basket?.selectedSlot?.todaySelected == true, tempTodayTimeSlot == nil, let selectedStore = selectedStore {
            let todayDate = Date().trueDate
            
            if fulfilmentType == .delivery, let location = container.appState.value.userData.searchResult.value?.fulfilmentLocation.location {
                container.services.retailStoresService.getStoreDeliveryTimeSlots(slots: loadableSubject(\.selectedRetailStoreFulfilmentTimeSlots), storeId: selectedStore.id, startDate: todayDate.startOfDay, endDate: todayDate.endOfDay, location: CLLocationCoordinate2D(latitude: CLLocationDegrees(Float(location.latitude)), longitude: CLLocationDegrees(Float(location.longitude))))
            } else if fulfilmentType == .collection {
                container.services.retailStoresService.getStoreCollectionTimeSlots(slots: loadableSubject(\.selectedRetailStoreFulfilmentTimeSlots), storeId: selectedStore.id, startDate: todayDate.startOfDay, endDate: todayDate.endOfDay)
            } else {
                Logger.checkout.fault("'checkoutAndAssignASAP' failed - Fulfilment method: \(self.fulfilmentType.rawValue)")
            }
        } else {
            Logger.checkout.fault("'checkoutAndAssignASAP' failed checks")
        }
    }
    
    func payByCardTapped() {
        navigateToPaymentHandling = .payByCard
    }
    
    func payByAppleTapped() {
        navigateToPaymentHandling = .payByApple
    }
    
    func payByCashTapped() {
        navigateToPaymentHandling = .payByCash
    }
}

#if DEBUG
// This hack is neccessary in order to expose 'checkAndAssignASAP' for testing. It cannot easily be confirmed working by using the public methods.
extension CheckoutFulfilmentInfoViewModel {
    public func exposeCheckAndAssignASAP() {
        return self.checkAndAssignASAP()
    }
}
#endif
