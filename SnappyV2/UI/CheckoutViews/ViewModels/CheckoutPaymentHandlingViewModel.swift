//
//  CheckoutPaymentHandlingViewModel.swift
//  SnappyV2
//
//  Created by Henrik Gustavii on 28/02/2022.
//

import Foundation
import Combine
import OSLog

class CheckoutPaymentHandlingViewModel: ObservableObject {
    enum PaymentOutcome {
        case successful
        case unsuccessful
    }
    
    let container: DIContainer
    private let timeZone: TimeZone?
    private let basket: Basket?
    private let tempTodayTimeSlot: RetailStoreSlotDayTimeSlot?
    @Published var paymentOutcome: PaymentOutcome?
    
    @Published var deliveryAddress: String = ""
    @Published var isContinueTapped: Bool = false
    @Published var settingBillingAddress: Bool = false
    var prefilledAddressName: Name?
    let instructions: String?
    @Published var continueButtonDisabled: Bool = true
    var draftOrderFulfilmentDetails: DraftOrderFulfilmentDetailsRequest?
    
    private var cancellables = Set<AnyCancellable>()
    
    init(container: DIContainer, instructions: String?) {
        self.container = container
        let appState = container.appState
        self.instructions = instructions
        
        timeZone = appState.value.userData.selectedStore.value?.storeTimeZone
        basket = appState.value.userData.basket
        tempTodayTimeSlot = appState.value.userData.tempTodayTimeSlot
        if let basketContactDetails = appState.value.userData.basketContactDetails {
            self.prefilledAddressName = Name(firstName: basketContactDetails.firstName, secondName: basketContactDetails.surname)
        }
    }
    
    func setBilling(address: SelectedAddress) {
        settingBillingAddress = true
        
        let basketAddressRequest = BasketAddressRequest(
            firstName: address.firstName,
            lastName: address.lastName,
            addressline1: address.address.addressline1,
            addressline2: address.address.addressline2,
            town: address.address.town,
            postcode: address.address.postcode,
            countryCode: address.country?.countryCode ?? AppV2Constants.Business.operatingCountry,
            type: "billing",
            email: container.appState.value.userData.basketContactDetails?.email ?? "",
            telephone: container.appState.value.userData.basketContactDetails?.telephoneNumber ?? "",
            state: nil,
            county: address.address.county,
            location: nil)
        container.services.basketService.setBillingAddress(to: basketAddressRequest)
            .receive(on: RunLoop.main)
            .sink { [weak self] completion in
                guard let self = self else { return }
                switch completion {
                case .failure(let error):
                    Logger.checkout.error("Failed to set billing address - \(error.localizedDescription)")
                    self.settingBillingAddress = false
                case .finished:
                    Logger.checkout.info("Successfully added billing address")
                    self.settingBillingAddress = false
                    self.continueButtonDisabled = false
                }
            }
            .store(in: &cancellables)
    }
    
    func continueButtonTapped() {
        if let start = tempTodayTimeSlot?.startTime, let end = tempTodayTimeSlot?.endTime {
            let requestedTime = "\(start.hourMinutesString(timeZone: timeZone)) - \(end.hourMinutesString(timeZone: timeZone))"
            let draftOrderFulfilmentDetailsTime = DraftOrderFulfilmentDetailsTimeRequest(date: start.dateOnlyString(storeTimeZone: timeZone), requestedTime: requestedTime)
            draftOrderFulfilmentDetails = DraftOrderFulfilmentDetailsRequest(time: draftOrderFulfilmentDetailsTime, place: nil)
            
            isContinueTapped = true
        } else if let start = basket?.selectedSlot?.start, let end = basket?.selectedSlot?.end {
            let requestedTime = "\(start.hourMinutesString(timeZone: timeZone)) - \(end.hourMinutesString(timeZone: timeZone))"
            let draftOrderFulfilmentDetailsTime = DraftOrderFulfilmentDetailsTimeRequest(date: start.dateOnlyString(storeTimeZone: timeZone), requestedTime: requestedTime)
            draftOrderFulfilmentDetails = DraftOrderFulfilmentDetailsRequest(time: draftOrderFulfilmentDetailsTime, place: nil)
            
            isContinueTapped = true
        } else {
            Logger.checkout.fault("'continueButtonTapped' failed - unwraps failed")
        }
    }
    
    func handleGlobalPaymentResult(businessOrderId: Int?, error: Error?) {
        guaranteeMainThread { [weak self] in
            guard let self = self else { return }
            if let businessOrderId = businessOrderId {
                Logger.checkout.info("Payment succeeded - Business Order ID: \(businessOrderId)")
                self.paymentOutcome = .successful
            } else if let error = error {
                Logger.checkout.error("Payment failed - Error: \(error.localizedDescription)")
                self.paymentOutcome = .unsuccessful
            }
        }
    }
}
