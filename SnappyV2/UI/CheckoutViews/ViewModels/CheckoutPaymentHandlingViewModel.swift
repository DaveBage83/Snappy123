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
    @Published private(set) var basket: Basket?
    private var basketContactDetails: BasketContactDetailsRequest?
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
        _basket = .init(initialValue: appState.value.userData.basket)
        tempTodayTimeSlot = appState.value.userData.tempTodayTimeSlot
        setupDetailsFromBasket(with: appState)
    }
    
    private func setupDetailsFromBasket(with appState: Store<AppState>) {
        $basket
            .receive(on: RunLoop.main)
            .sink { [weak self] basket in
                guard let self = self else { return }
                if let details = basket?.addresses?.first(where: { $0.type == "billing" }) {
                    self.basketContactDetails = BasketContactDetailsRequest(
                        firstName: details.firstName ?? "",
                        lastName: details.lastName ?? "",
                        email: details.email ?? "",
                        telephone: details.telephone ?? ""
                    )
                }
            }
            .store(in: &cancellables)
    }
    
    func setBilling(address: Address) {
        settingBillingAddress = true
        
        let basketAddressRequest = BasketAddressRequest(
            firstName: address.firstName ?? "",
            lastName: address.lastName ?? "",
            addressline1: address.addressLine1,
            addressline2: address.addressLine2 ?? "",
            town: address.town,
            postcode: address.postcode,
            countryCode: address.countryCode ,
            type: "billing",
            email: basketContactDetails?.email ?? "",
            telephone: basketContactDetails?.telephone ?? "",
            state: nil,
            county: address.county,
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
