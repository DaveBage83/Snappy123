//
//  CheckoutPaymentHandlingViewModel.swift
//  SnappyV2
//
//  Created by Henrik Gustavii on 28/02/2022.
//

import Foundation
import Combine

class CheckoutPaymentHandlingViewModel: ObservableObject {
    enum PaymentOutcome {
        case successful
        case unsuccessful
    }
    
    let container: DIContainer
    let timeZone: TimeZone?
    let basket: Basket?
    let tempTodayTimeSlot: RetailStoreSlotDayTimeSlot?
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
            .sinkToResult({ [weak self] result in
                guard let self = self else { return }
                switch result {
                case .failure(let error):
                    print("Failure to set billing address - \(error)")
                    self.settingBillingAddress = false
                case .success(_):
                    self.settingBillingAddress = false
                    self.continueButtonDisabled = false
                }
            })
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
        }
    }
    
    func handleGlobalPaymentResult(businessOrderId: Int?, error: Error?) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            if let businessOrderId = businessOrderId {
                print("Payment succeeded - Business Order ID: \(businessOrderId)")
                self.paymentOutcome = .successful
            } else if let _ = error {
                print("Payment failed - Error: \(error)")
                self.paymentOutcome = .unsuccessful
            }
        }
    }
}
