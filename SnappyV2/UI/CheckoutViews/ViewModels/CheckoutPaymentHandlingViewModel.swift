//
//  CheckoutPaymentHandlingViewModel.swift
//  SnappyV2
//
//  Created by Henrik Gustavii on 28/02/2022.
//

import Foundation
import Combine
import OSLog
import SwiftUI
import Frames

@MainActor
class CheckoutPaymentHandlingViewModel: ObservableObject {
    enum PaymentOutcome {
        case successful
        case unsuccessful
    }
    
    let container: DIContainer
    private let timeZone: TimeZone?
    @Published private(set) var basket: Basket?
    private let selectedStore: RetailStoreDetails?
    private var basketContactDetails: BasketContactDetailsRequest?
    private let tempTodayTimeSlot: RetailStoreSlotDayTimeSlot?
    @Published var paymentOutcome: PaymentOutcome?
    
    
    @Published var deliveryAddress: String = ""
    @Published var settingBillingAddress: Bool = false
    @Published var useSameBillingAddressAsDelivery = true
    var prefilledAddressName: Name?
    let instructions: String?
    @Published var continueButtonDisabled: Bool = true
    var draftOrderFulfilmentDetails: DraftOrderFulfilmentDetailsRequest?
    
    // MARK: - Credit card variables
    @Published var threeDSWebViewURLs: CheckoutCom3DSURLs?
    let cardUtils = CardUtils()
    @Published var creditCardName: String = ""
    @Published var creditCardNumber: String = ""
    @Published var creditCardExpiryMonth: String = ""
    @Published var creditCardExpiryYear: String = ""
    @Published var creditCardCVV: String = ""
    @Published var saveCreditCard: Bool = false
    @Published var isUnvalidCardNumber: Bool = false
    @Published var isUnvalidCVV: Bool = false
    @Published var isUnvalidExpiry: Bool = false
    @Published var cardType: CardType?
    var shownCardType: PaymentCardType? {
        switch cardType?.scheme {
        case .visa:
            return .visa
        case .mastercard:
            return .masterCard
        case .jcb:
            return .jcb
        case .discover:
            return .discover
        default:
            return nil
        }
    }
    var showVisaCard: Bool { (shownCardType == .visa || shownCardType == nil) }
    var showMasterCardCard: Bool { (shownCardType == .masterCard || shownCardType == nil) }
    var showJCBCard: Bool { (shownCardType == .jcb || shownCardType == nil) }
    var showDiscoverCard: Bool { (shownCardType == .discover || shownCardType == nil) }
    @Published var showCardCamera: Bool = false
    @Published var handlingPayment: Bool = false
    @Published var memberProfile: MemberProfile?
    
    @Published var error: Error?
    let paymentSuccess: () -> Void
    let paymentFailure: () -> Void
    
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Calculated variables
    
    // Used to display on payment button
    var basketTotal: String? {
        guard let currency = container.appState.value.userData.selectedStore.value?.currency else { return nil }
        return container.appState.value.userData.basket?.orderTotal.toCurrencyString(using: currency)
    }
    
    init(container: DIContainer, instructions: String?, paymentSuccess: @escaping () -> Void, paymentFailure: @escaping () -> Void) {
        self.container = container
        let appState = container.appState
        self.instructions = instructions
        self.paymentSuccess = paymentSuccess
        self.paymentFailure = paymentFailure
        self._memberProfile = .init(wrappedValue: appState.value.userData.memberProfile)
        selectedStore = appState.value.userData.selectedStore.value
        timeZone = selectedStore?.storeTimeZone
        _basket = .init(initialValue: appState.value.userData.basket)
        tempTodayTimeSlot = appState.value.userData.tempTodayTimeSlot
        setupDetailsFromBasket(with: appState)
        setupPaymentOutcome()
        setupCreditCardNumber()
        setupCreditCardCVV()
        setupCreditCardExpiry()
    }
    
    func setupCreditCardNumber() {
        $creditCardNumber
            .receive(on: RunLoop.main)
            .sink { [weak self] number in
                guard let self = self else { return }
                if number.isEmpty { return }
                if !number.isEmpty && self.isUnvalidCardNumber { self.isUnvalidCardNumber = false }
                self.cardType = self.cardUtils.getTypeOf(cardNumber: number)
                self.isUnvalidCardNumber = self.cardUtils.isValid(cardNumber: number) == false
            }
            .store(in: &cancellables)
    }
    
    func setupCreditCardCVV() {
        $creditCardCVV
            .receive(on: RunLoop.main)
            .sink { [weak self] cvv in
                guard let self = self else { return }
                if !cvv.isEmpty && self.isUnvalidCVV { self.isUnvalidCVV = false }
                if let cardType = self.cardType {
                    self.isUnvalidCVV = self.cardUtils.isValid(cvv: cvv, cardType: cardType) == false
                }
            }
            .store(in: &cancellables)
    }
    
    func setupCreditCardExpiry() {
        Publishers.CombineLatest($creditCardExpiryMonth, $creditCardExpiryYear)
            .receive(on: RunLoop.main)
            .sink { [weak self] month, year in
                guard let self = self else { return }
                if month.isEmpty && year.isEmpty { return }
                if (!month.isEmpty && !year.isEmpty) && self.isUnvalidExpiry { self.isUnvalidExpiry = false }
                self.isUnvalidExpiry = self.cardUtils.isValid(expirationMonth: month, expirationYear: year) == false
            }
            .store(in: &cancellables)
    }
    
    func areCardDetailsValid() -> Bool {
        self.isUnvalidCardNumber = self.cardUtils.isValid(cardNumber: creditCardNumber) == false
        self.isUnvalidExpiry = self.cardUtils.isValid(expirationMonth: creditCardExpiryMonth, expirationYear: creditCardExpiryYear) == false
        if let cardType = self.cardType {
            self.isUnvalidCVV = self.cardUtils.isValid(cvv: creditCardCVV, cardType: cardType) == false
        }
        return isUnvalidCVV == false && isUnvalidExpiry == false && isUnvalidCardNumber == false && isUnvalidCardName == false
    }
    
    var isUnvalidCardName: Bool {
        creditCardName.isEmpty && creditCardNumber.isEmpty == false && creditCardCVV.isEmpty == false
    }
    
    func showCardCameraTapped() {
        showCardCamera = true
    }
    
    func handleCardCameraReturn(name: String?, number: String?, expiry: String?) {
        creditCardName = name ?? ""
        creditCardNumber = number?.replacingOccurrences(of: " ", with: "") ?? ""
        creditCardExpiryMonth = String(expiry?.prefix(2) ?? "")
        creditCardExpiryYear = String(expiry?.suffix(2) ?? "")
    }
    
    private func setupPaymentOutcome() {
        $paymentOutcome
            .receive(on: RunLoop.main)
            .sink { [weak self] outcome in
                guard let self = self else { return }
                if outcome == .successful {
                    self.paymentSuccess()
                } else if outcome == .unsuccessful {
                    self.paymentFailure()
                }
            }
            .store(in: &cancellables)
    }
    
    private func setupDetailsFromBasket(with appState: Store<AppState>) {
        $basket
            .receive(on: RunLoop.main)
            .sink { [weak self] basket in
                guard let self = self else { return }
                if let details = basket?.addresses?.first(where: { $0.type == AddressType.billing.rawValue }) {
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
    
    func setBilling(address: Address) async {
        settingBillingAddress = true
        
        let basketAddressRequest = BasketAddressRequest(
            firstName: address.firstName ?? "",
            lastName: address.lastName ?? "",
            addressLine1: address.addressLine1,
            addressLine2: address.addressLine2 ?? "",
            town: address.town,
            postcode: address.postcode,
            countryCode: address.countryCode ?? "" ,
            type: AddressType.billing.rawValue,
            email: basketContactDetails?.email ?? "",
            telephone: basketContactDetails?.telephone ?? "",
            state: nil,
            county: address.county,
            location: nil)
        
        do {
            try await container.services.basketService.setBillingAddress(to: basketAddressRequest)
            
            self.settingBillingAddress = false
            self.continueButtonDisabled = false
        } catch {
            self.error = error
            Logger.checkout.error("Failed to set billing address - \(error.localizedDescription)")
            self.settingBillingAddress = false
        }
    }
    
    func continueButtonTapped(setBilling: @escaping () async throws -> (), errorHandler: (Swift.Error) -> ()) async {
        guard areCardDetailsValid() else { return }
        handlingPayment = true
        
        do {
            try await setBilling()
            
            draftOrderFulfilmentDetails = createDraftOrderRequest()
            
            try await processCardPayment()
            
            handlingPayment = false
        } catch {
            handlingPayment = false
            errorHandler(error)
        }
    }
    
    // remember to keep logic same as in CheckoutFulfilmentInfoViewModel
    func createDraftOrderRequest() -> DraftOrderFulfilmentDetailsRequest {
        var draftOrderTimeRequest: DraftOrderFulfilmentDetailsTimeRequest?
        if let start = tempTodayTimeSlot?.startTime, let end = tempTodayTimeSlot?.endTime {
            let requestedTime = "\(start.hourMinutesString(timeZone: timeZone)) - \(end.hourMinutesString(timeZone: timeZone))"
            draftOrderTimeRequest = DraftOrderFulfilmentDetailsTimeRequest(date: start.dateOnlyString(storeTimeZone: timeZone), requestedTime: requestedTime)
            
        } else if let start = basket?.selectedSlot?.start, let end = basket?.selectedSlot?.end {
            let requestedTime = "\(start.hourMinutesString(timeZone: timeZone)) - \(end.hourMinutesString(timeZone: timeZone))"
            draftOrderTimeRequest = DraftOrderFulfilmentDetailsTimeRequest(date: start.dateOnlyString(storeTimeZone: timeZone), requestedTime: requestedTime)
        }
        
        return DraftOrderFulfilmentDetailsRequest(time: draftOrderTimeRequest, place: nil)
    }
    
    // First step in card payment flow
    func processCardPayment() async throws {
        if let unwrappedPaymentGateway = selectedStore?.paymentGateways?.first(where: { $0.name == PaymentGatewayType.checkoutcom.rawValue }) {
            try await handleCheckoutcomCardPayment(gateway: unwrappedPaymentGateway)
        } else if let businessProfile = container.appState.value.businessData.businessProfile, let paymentGateway = businessProfile.paymentGateways.first(where: { $0.name == PaymentGatewayType.checkoutcom.rawValue }) {
            try await handleCheckoutcomCardPayment(gateway: paymentGateway)
        } else {
            Logger.checkout.error("Card payment failed - Missing Checkoutcom Payment Gateway")
            paymentOutcome = .unsuccessful
        }
    }
}

extension CheckoutPaymentHandlingViewModel {
    private func handleCheckoutcomCardPayment(gateway: PaymentGateway) async throws {
        if let draftOrderFulfilmentDetails = draftOrderFulfilmentDetails {
            var publicKey: String?
            
            // get card details from entered data
            let cardDetails = CardDetails(number: creditCardNumber, expiryMonth: creditCardExpiryMonth, expiryYear: creditCardExpiryYear, cvv: creditCardCVV, cardName: creditCardName)
            publicKey = gateway.fields?["publicKey"] as? String
            if let publicKey = publicKey {
                
                // with all necessary data, process card payment
                let processOrderResult = try await self.container.services.checkoutService.processCardPaymentOrder(fulfilmentDetails: draftOrderFulfilmentDetails, paymentGatewayType: .checkoutcom, paymentGatewayMode: gateway.mode, instructions: instructions, publicKey: publicKey, cardDetails: cardDetails)
                
                // if card payment process return businessOrderId then success
                if let _ = processOrderResult.0 {
                    
                    paymentOutcome = .successful
                    return
                    
                // if card payment process returns urls, then 3DS is needed
                } else if let urls = processOrderResult.1 {
                    
                    // populate variable to trigger 3DS in view
                    threeDSWebViewURLs = urls
                    
                    Logger.checkout.info("3DS verification needed")
                    return
                } else {
                    Logger.checkout.error("Card payment failed - processCardPaymentOrder result empty")
                    paymentOutcome = .unsuccessful
                }
                
            } else {
                Logger.checkout.error("Card payment failed - Missing publicKey")
                paymentOutcome = .unsuccessful
            }
        } else {
            Logger.checkout.error("Card payment failed - Missing draftOrderFulfilmentDetails")
            paymentOutcome = .unsuccessful
        }
    }
    
    // 3DS success handler which verifies payment with server
    func threeDSSuccess() async {
        threeDSWebViewURLs = nil
        
        do {
            try await container.services.checkoutService.verifyCheckoutcomPayment()
            
            paymentOutcome = .successful
        } catch {
            Logger.checkout.error("Card payment failed - verification failed")
            paymentOutcome = .unsuccessful
        }
    }
    
    // 3DS failure handler
    func threeDSFail() {
        threeDSWebViewURLs = nil
        Logger.checkout.error("Card payment failed - 3DS verification failed")
        paymentOutcome = .unsuccessful
    }
}
