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
import PassKit
import SwiftUI

@MainActor
class CheckoutFulfilmentInfoViewModel: ObservableObject {
    enum PaymentNavigation {
        case payByCard
        case payByApple
        case payByCash
    }
    
    let container: DIContainer
    private let timeZone: TimeZone?
    private let dateGenerator: () -> Date
    private let selectedStore: RetailStoreDetails?
    private let fulfilmentType: RetailStoreOrderMethodType
    @Published var selectedRetailStoreFulfilmentTimeSlots: Loadable<RetailStoreTimeSlots> = .notRequested
    var deliveryLocation: Location?
    @Published var basket: Basket?
    @Published var postcode = ""
    @Published var instructions = ""
    @Binding var checkoutState: CheckoutRootViewModel.CheckoutState
    @Published var tempTodayTimeSlot: RetailStoreSlotDayTimeSlot?
    let wasPaymentUnsuccessful: Bool
    @Published var navigateToPaymentHandling: PaymentNavigation?
    private let memberSignedIn: Bool
    var isDeliveryAddressSet: Bool { selectedDeliveryAddress != nil }
    @Published var settingDeliveryAddress: Bool = false
    @Published var selectedDeliveryAddress: Address?
    var prefilledAddressName: Name?
    var processingPayByCash: Bool = false
    var businessOrderId: Int?
    
    private var applePayAvailable: Bool = false
    
    @Published private(set) var error: Error?
    
    var showPayByCard: Bool {
        if let store = selectedStore, let paymentMethods = store.paymentMethods {
            return store.isCompatible(with: .realex) && paymentMethods.contains(where: { $0.isCompatible(with: fulfilmentType, for: .realex)
            })
        }
        return false
    }
    
    var showPayByApple: Bool {
        if applePayAvailable {
            if let store = selectedStore, let paymentMethods = store.paymentMethods {
                return paymentMethods.contains {
                    $0.name.lowercased() == "applepay" && paymentMethods.contains(where: {
                        $0.isCompatible(with: fulfilmentType, for: .worldpay)
                    })
                }
            }
        }
        return false
    }
    
    var showPayByCash: Bool {
        if let store = selectedStore, let paymentMethods = store.paymentMethods {
            guard store.isCompatible(with: .cash), let paymentMethod = paymentMethods.first(where: { $0.isCompatible(with: fulfilmentType, for: .cash)
            }) else { return false }
            
            // Check if an alcohol item is in basket
            if let basket = basket, basket.items.contains(where: { $0.isAlcohol }) {
                
                // Check if a temporary time slot is in appState and then compare with cutoff time
                if let tempTodayTimeSlot = tempTodayTimeSlot {
                    if let cutoffTime = paymentMethod.settings.cutOffTime, let cutOffTimeDateFormat = cutoffTime.stringToHoursMinsAndSecondsOnly, let slotEndDateHMSOnly = tempTodayTimeSlot.endTime.hourMinutesSecondsString(timeZone: nil).stringToHoursMinsAndSecondsOnly {
                        return cutOffTimeDateFormat > slotEndDateHMSOnly
                    }
                }
                
                // Check if todaySelected then compare cutoff time with actual time
                if let todaySelected = basket.selectedSlot?.todaySelected, todaySelected {
                    if let cutoffTimeDateFormat = paymentMethod.settings.cutOffTime?.stringToHoursMinsAndSecondsOnly, let dateNow = dateGenerator().trueDate.hourMinutesSecondsString(timeZone: nil).stringToHoursMinsAndSecondsOnly {
                        return cutoffTimeDateFormat > dateNow
                    }
                }
                
                // Check if a future time slot selected, then compare cutoff time with reserved time slot end time
                if let selectedSlotEnd = basket.selectedSlot?.end {
                    if let cutoffTimeDateFormat = paymentMethod.settings.cutOffTime?.stringToHoursMinsAndSecondsOnly, let slotEndDateHMSOnly = selectedSlotEnd.hourMinutesSecondsString(timeZone: nil).stringToHoursMinsAndSecondsOnly {
                        return cutoffTimeDateFormat > slotEndDateHMSOnly
                    }
                }
            }
            return true
        }
        return false
    }
    
    private var cancellables = Set<AnyCancellable>()
    
    init(container: DIContainer, wasPaymentUnsuccessful: Bool = false, checkoutState: Binding<CheckoutRootViewModel.CheckoutState>, dateGenerator: @escaping () -> Date = Date.init) {
        self.container = container
        self.dateGenerator = dateGenerator
        let appState = container.appState
        basket = appState.value.userData.basket
        fulfilmentType = appState.value.userData.selectedFulfilmentMethod
        selectedStore = appState.value.userData.selectedStore.value
        _selectedDeliveryAddress = .init(initialValue: appState.value.userData.basketDeliveryAddress)
        _checkoutState = checkoutState
        self.wasPaymentUnsuccessful = wasPaymentUnsuccessful
        self.memberSignedIn = appState.value.userData.memberProfile == nil
        _tempTodayTimeSlot = .init(initialValue: appState.value.userData.tempTodayTimeSlot)
        timeZone = appState.value.userData.selectedStore.value?.storeTimeZone
        
        if let basket = basket, let details = basket.addresses?.first(where: { $0.type == AddressType.billing.rawValue }) {
            self.prefilledAddressName = Name(firstName: details.firstName ?? "", secondName: details.lastName ?? "")
        }
        
        applePayAvailable = PKPassLibrary.isPassLibraryAvailable() && PKPaymentAuthorizationController.canMakePayments(
            usingNetworks: [.amex, .masterCard, .visa]
        )
        
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
    func setDelivery(address: Address) async {
        settingDeliveryAddress = true
        
        let basketAddressRequest = BasketAddressRequest(
            firstName: address.firstName ?? "",
            lastName: address.lastName ?? "",
            addressLine1: address.addressLine1,
            addressLine2: address.addressLine2 ?? "",
            town: address.town,
            postcode: address.postcode,
            countryCode: address.countryCode ?? "",
            type: AddressType.delivery.rawValue,
            email: basket?.addresses?.first(where: { $0.type == AddressType.billing.rawValue })?.email ?? "",
            telephone: basket?.addresses?.first(where: { $0.type == AddressType.billing.rawValue })?.telephone ?? "",
            state: nil,
            county: address.county,
            location: nil
        )
        
        do {
            try await container.services.basketService.setDeliveryAddress(to: basketAddressRequest)
            
            Logger.checkout.info("Successfully added delivery address")
            #warning("Might want to clear selectedDeliveryAddress at some point")
            self.selectedDeliveryAddress = address
            self.settingDeliveryAddress = false
            self.checkAndAssignASAP()
        } catch {
            self.error = error
            Logger.checkout.error("Failure to set delivery address - \(error.localizedDescription)")
            self.settingDeliveryAddress = false
        }
    }
    
    #warning("Replace store location with one returned from basket addresses")
    private func checkAndAssignASAP() {
        if basket?.selectedSlot?.todaySelected == true, tempTodayTimeSlot == nil, let selectedStore = selectedStore {
            let todayDate = Date().trueDate
            
            if fulfilmentType == .delivery, let fulfilmentLocation = container.appState.value.userData.searchResult.value?.fulfilmentLocation {
                container.services.retailStoresService.getStoreDeliveryTimeSlots(slots: loadableSubject(\.selectedRetailStoreFulfilmentTimeSlots), storeId: selectedStore.id, startDate: todayDate.startOfDay, endDate: todayDate.endOfDay, location: CLLocationCoordinate2D(latitude: CLLocationDegrees(Float(fulfilmentLocation.location.latitude)), longitude: CLLocationDegrees(Float(fulfilmentLocation.location.longitude))))
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
        checkoutState = .card
    }
    
    func payByAppleTapped() {
        navigateToPaymentHandling = .payByApple
    }
    
    func payByCashTapped() async {
        processingPayByCash = true
        var draftOrderTimeRequest: DraftOrderFulfilmentDetailsTimeRequest? = nil
        
        if let start = tempTodayTimeSlot?.startTime, let end = tempTodayTimeSlot?.endTime {
            let requestedTime = "\(start.hourMinutesString(timeZone: timeZone)) - \(end.hourMinutesString(timeZone: timeZone))"
            draftOrderTimeRequest = DraftOrderFulfilmentDetailsTimeRequest(date: start.dateOnlyString(storeTimeZone: timeZone), requestedTime: requestedTime)
            
        } else if let start = basket?.selectedSlot?.start, let end = basket?.selectedSlot?.end {
            let requestedTime = "\(start.hourMinutesString(timeZone: timeZone)) - \(end.hourMinutesString(timeZone: timeZone))"
            draftOrderTimeRequest = DraftOrderFulfilmentDetailsTimeRequest(date: start.dateOnlyString(storeTimeZone: timeZone), requestedTime: requestedTime)
        }
        
        let draftOrderDetailsRequest = DraftOrderFulfilmentDetailsRequest(time: draftOrderTimeRequest, place: nil)
        
        do {
            let result  = try await container.services.checkoutService.createDraftOrder(fulfilmentDetails: draftOrderDetailsRequest, paymentGateway: .cash, instructions: instructions).singleOutput()
            
            if result.businessOrderId == nil {
                Logger.checkout.fault("Successful order creation failed - BusinessOrderId missing")
                self.processingPayByCash = false
                return
            }
            
            self.processingPayByCash = false
            checkoutState = .paymentSuccess
        } catch {
            self.error = error
            Logger.checkout.error("Failed creating draft order - Error: \(error.localizedDescription)")
            self.processingPayByCash = false
        }
    }
}

#if DEBUG
// This hack is neccessary in order to expose 'checkAndAssignASAP' and enable Apple Pay for testing. These cannot easily be tested without.
extension CheckoutFulfilmentInfoViewModel {
    func exposeCheckAndAssignASAP() {
        return self.checkAndAssignASAP()
    }
    
    func enableApplePay() {
        self.applePayAvailable = true
    }
}
#endif
