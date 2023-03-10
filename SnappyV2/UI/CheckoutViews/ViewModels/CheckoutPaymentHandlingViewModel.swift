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
import Checkout

enum CheckoutPaymentHandlingViewModelError: Error {
    case missingCheckoutcomPaymentGateway
    case processCardOrderResultEmpty
    case missingPublicKey
    case missingDraftOrderFulfilmentDetails
    case verificationFailed
    case threeDSVerificationFailed
}

extension CheckoutPaymentHandlingViewModelError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .missingCheckoutcomPaymentGateway:
            return Strings.CheckoutDetails.Errors.CardPayment.missingCheckoutcomPaymentGateway.localized
        case .processCardOrderResultEmpty:
            return Strings.CheckoutDetails.Errors.CardPayment.processCardOrderResultEmpty.localized
        case .missingPublicKey:
            return Strings.CheckoutDetails.Errors.CardPayment.missingPublicKey.localized
        case .missingDraftOrderFulfilmentDetails:
            return Strings.CheckoutDetails.Errors.CardPayment.missingDraftOrderFulfilmentDetails.localized
        case .verificationFailed:
            return Strings.CheckoutDetails.Errors.CardPayment.verificationFailed.localized
        case .threeDSVerificationFailed:
            return Strings.CheckoutDetails.Errors.CardPayment.threeDSVerificationFailed.localized
        }
    }
}

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
    @Published var savedCardsDetails = [MemberCardDetails]()
    let instructions: String?
    var draftOrderFulfilmentDetails: DraftOrderFulfilmentDetailsRequest?
    
    // MARK: - Credit card variables
    @Published var threeDSWebViewURLs: CheckoutCom3DSURLs?
    private let cardUtils: CardValidator
    private let paymentEvironment: PaymentGatewayMode
    @Published var creditCardName: String = ""
    @Published var creditCardNumber: String = ""
    @Published var creditCardExpiryMonth: String = ""
    @Published var creditCardExpiryYear: String = ""
    var creditCardExpiry: ExpiryDate?
    @Published var creditCardCVV: String = ""
    @Published var saveCreditCard: Bool = false
    @Published var isUnvalidCardNumber: Bool = false
    @Published var isUnvalidCVV: Bool = false
    @Published var isUnvalidExpiry: Bool = false
    @Published var cardType: Card.Scheme?
    var shownCardType: PaymentCardType? {
        switch cardType {
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
    var showSavedCards: Bool { savedCardsDetails.isEmpty == false }
    @Published var showCardCamera: Bool = false
    @Published var handlingPayment: Bool = false
    @Published var memberProfile: MemberProfile?
    @Published var selectedSavedCard: MemberCardDetails?
    @Published var selectedSavedCardCVV: String = ""
    @Published var isUnvalidSelectedCardCVV: Bool = true
    
    let paymentSuccess: () -> Void
    let paymentFailure: () -> Void
    
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Calculated variables
    
    // Used to display on payment button
    var basketTotal: String? {
        guard let currency = container.appState.value.userData.selectedStore.value?.currency else { return nil }
        return container.appState.value.userData.basket?.orderTotal.toCurrencyString(using: currency)
    }
    
    lazy var threeDSDelegate: Checkoutcom3DSHandleView.Delegate = { Checkoutcom3DSHandleView.Delegate(
        didSucceed: { [weak self] in
            guard let self = self else { return }
            Task { await self.threeDSSuccess() }},
        didFail: { [weak self] in
            guard let self = self else { return }
            self.threeDSFail() }
    )}()
    
    init(container: DIContainer, instructions: String?, paymentSuccess: @escaping () -> Void, paymentFailure: @escaping () -> Void) {
        self.container = container
        let appState = container.appState
        self.instructions = instructions
        self.paymentSuccess = paymentSuccess
        self.paymentFailure = paymentFailure
        if let paymentGateway = appState.value.userData.selectedStore.value?.paymentGateways?.first(where: { $0.name.lowercased() ==  "checkoutcom"}) {
            self.paymentEvironment = paymentGateway.mode
            self.cardUtils = CardValidator(environment: paymentEvironment == .live ? .production : .sandbox)
        } else if let  paymentGateway = appState.value.businessData.businessProfile?.paymentGateways.first(where: { $0.name.lowercased() ==  "checkoutcom"}) {
            self.paymentEvironment = paymentGateway.mode
            self.cardUtils = CardValidator(environment: paymentEvironment == .live ? .production : .sandbox)
        } else {
            self.cardUtils = CardValidator(environment: .sandbox)
            self.paymentEvironment = .sandbox
        }
        
        self._memberProfile = .init(wrappedValue: appState.value.userData.memberProfile)
        selectedStore = appState.value.userData.selectedStore.value
        timeZone = selectedStore?.storeTimeZone
        _basket = .init(initialValue: appState.value.userData.basket)
        tempTodayTimeSlot = appState.value.userData.tempTodayTimeSlot
        setupDetailsFromBasket()
        setupPaymentOutcome()
        setupCreditCardNumber()
        setupCreditCardCVV()
        setupCreditCardExpiry()
        setupSelectedSavedCardCVV()
    }
    
    func setupCreditCardNumber() {
        $creditCardNumber
            .receive(on: RunLoop.main)
            .sink { [weak self] number in
                guard let self = self else { return }
                if number.isEmpty { return }
                if !number.isEmpty && self.isUnvalidCardNumber { self.isUnvalidCardNumber = false }
                do {
                    self.cardType = try? self.cardUtils.validateCompleteness(cardNumber: number).get().scheme
                    self.isUnvalidCardNumber = try self.cardUtils.validateCompleteness(cardNumber: number).get().isComplete == false
                } catch {
                    self.container.appState.value.errors.append(error)
                }
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
                    self.isUnvalidCVV = self.cardUtils.isValid(cvv: cvv, for: cardType) == false
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
                self.creditCardExpiry = try? self.cardUtils.validate(expiryMonth: month, expiryYear: year).get()
                self.isUnvalidExpiry = self.creditCardExpiry == nil
            }
            .store(in: &cancellables)
    }
    
    func setupSelectedSavedCardCVV() {
        $selectedSavedCardCVV
            .receive(on: RunLoop.main)
            .sink { [weak self] cvv in
                guard let self = self else { return }
                if cvv.isEmpty { self.isUnvalidSelectedCardCVV = true; return }
                if let cardType = self.selectedSavedCard?.checkoutcomScheme {
                    self.isUnvalidSelectedCardCVV = self.cardUtils.isValid(cvv: cvv, for: cardType) == false
                }
            }
            .store(in: &cancellables)
    }
    
    func areCardDetailsValid() -> Bool {
        if selectedSavedCard != nil {
            return isUnvalidSelectedCardCVV == false
        } else {
            return isUnvalidCVV == false && isUnvalidExpiry == false && isUnvalidCardNumber == false && isUnvalidCardName == false
        }
    }
    
    var isUnvalidCardName: Bool {
        creditCardName.isEmpty && creditCardNumber.isEmpty == false && creditCardCVV.isEmpty == false
    }
    
    var showNewCardEntry: Bool {
        if memberProfile == nil {
            return true
        } else {
            return selectedSavedCard == nil
        }
    }
    
    var continueButtonDisabled: Bool {
        if selectedSavedCard != nil {
            return isUnvalidSelectedCardCVV
        } else {
        return (creditCardName.isEmpty || creditCardNumber.isEmpty || creditCardExpiryMonth.isEmpty || creditCardExpiryYear.isEmpty || creditCardCVV.isEmpty) || (isUnvalidCardName || isUnvalidCardNumber || isUnvalidExpiry || isUnvalidCVV)
        }
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
    
    func filterCardNumber(newValue: String) {
        let filtered = newValue.filter { "0123456789".contains($0) }
        if filtered != newValue {
            self.creditCardNumber = filtered
        }
    }
    
    func filterCardCVV(newValue: String) {
        let filtered = newValue.filter { "0123456789".contains($0) }
        if filtered != newValue {
            self.creditCardCVV = filtered
        }
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
    
    private func setupDetailsFromBasket() {
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
    
    private func sendPaymentCardError(gateway: String, applePay: Bool, description: String) {
        
        var appsFlyerParams: [String: Any] = [
            "order_id": self.container.services.checkoutService.currentDraftOrderId ?? 0,
            "payment_method": gateway,
            "error": description,
            "payment_type": applePay ? "apple_pay" : "card"
        ]
        
        if let basket = self.basket {
            var totalItemQuantity: Int = 0
            for item in basket.items {
                totalItemQuantity += item.quantity
            }
            appsFlyerParams["quantity"] = totalItemQuantity
            appsFlyerParams["price"] = basket.orderTotal
        }
        
        if let uuid = self.container.appState.value.userData.memberProfile?.uuid {
            appsFlyerParams["member_id"] = uuid
        }
        
        self.container.eventLogger.sendEvent(for: .paymentFailure, with: .appsFlyer, params: appsFlyerParams)
        
        var firebaseParams: [String: Any] = [
            "order_id": self.container.services.checkoutService.currentDraftOrderId ?? 0,
            "gateway": gateway,
            "error": description,
            "payment_type": applePay ? "apple_pay" : "card"
        ]
        
        self.container.eventLogger.sendEvent(for: .paymentFailure, with: .firebaseAnalytics, params: firebaseParams)
    }
    
    private func setError(_ err: Error) {
        container.appState.value.errors.append(err)
    }
        
    func continueButtonTapped(fieldErrors: [CheckoutRootViewModel.DetailsFormElements], setBilling: @escaping () async throws -> (), errorHandler: (Swift.Error) -> ()) async {
                
        // check if all card details are valid
        guard fieldErrors.isEmpty, areCardDetailsValid() else { return }
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
    private func processCardPayment() async throws {
        if let unwrappedPaymentGateway = selectedStore?.paymentGateways?.first(where: { $0.name == PaymentGatewayType.checkoutcom.rawValue }) {
            try await handleCheckoutcomCardPayment(gateway: unwrappedPaymentGateway)
        } else if let businessProfile = container.appState.value.businessData.businessProfile, let paymentGateway = businessProfile.paymentGateways.first(where: { $0.name == PaymentGatewayType.checkoutcom.rawValue }) {
            try await handleCheckoutcomCardPayment(gateway: paymentGateway)
        } else {
            Logger.checkout.error("Card payment failed - Missing Checkoutcom Payment Gateway")
            self.setError(CheckoutPaymentHandlingViewModelError.missingCheckoutcomPaymentGateway)
        }
    }
}

extension CheckoutPaymentHandlingViewModel {
    
    private func handleCheckoutcomCardPayment(gateway: PaymentGateway) async throws {
        
        if let draftOrderFulfilmentDetails = draftOrderFulfilmentDetails {
            
            if let publicKey = gateway.fields?["publicKey"] as? String {
                let processOrderResult: (Int?, CheckoutCom3DSURLs?)?
                
                // select saved/new card and process order
                if let selectedSavedCard = selectedSavedCard, selectedSavedCardCVV.isEmpty == false {
                    // process with saved card details
                    processOrderResult = try await self.container.services.checkoutService.processSavedCardPaymentOrder(fulfilmentDetails: draftOrderFulfilmentDetails, paymentGatewayType: .checkoutcom, paymentGatewayMode: gateway.mode == .live ? .live : .sandbox, instructions: instructions, publicKey: publicKey, cardId: selectedSavedCard.id, cvv: selectedSavedCardCVV)
                } else {
                    // get new card details from entered data
                    let cardDetails = CheckoutCardDetails(number: creditCardNumber, expiryMonth: Int(creditCardExpiryMonth) ?? 0, expiryYear: Int(creditCardExpiryYear) ?? 0, cvv: creditCardCVV, cardName: creditCardName)
                    
                    // if card is to be saved, pass in memberService.saveNewCard(token:)
                    let saveNewCardHandler: ((String) async throws -> ())? = saveCreditCard ? container.services.memberService.saveNewCard : nil
                    
                    // with all necessary data, process card payment
                    processOrderResult = try await self.container.services.checkoutService.processNewCardPaymentOrder(fulfilmentDetails: draftOrderFulfilmentDetails, paymentGatewayType: .checkoutcom, paymentGatewayMode: gateway.mode == .live ? .live : .sandbox, instructions: instructions, publicKey: publicKey, cardDetails: cardDetails, saveCardPaymentHandler: saveNewCardHandler)
                }
                
                // if card payment process return businessOrderId then success
                if processOrderResult?.0 != nil {
                    
                    paymentOutcome = .successful
                    return
                    
                // if card payment process returns urls, then 3DS is needed
                } else if let urls = processOrderResult?.1 {
                    
                    // populate variable to trigger 3DS in view
                    threeDSWebViewURLs = urls
                    
                    Logger.checkout.info("3DS verification needed")
                    return
                } else {
                    Logger.checkout.error("Card payment failed - processCardPaymentOrder result empty")
                    setError(CheckoutPaymentHandlingViewModelError.processCardOrderResultEmpty)
                    sendPaymentCardError(gateway: gateway.name, applePay: false, description: "processCardPaymentOrder result empty")
                }
                
            } else {
                Logger.checkout.error("Card payment failed - Missing publicKey")
                setError(CheckoutPaymentHandlingViewModelError.missingPublicKey)
                sendPaymentCardError(gateway: gateway.name, applePay: false, description: "Missing publicKey")
            }
        } else {
            Logger.checkout.error("Card payment failed - Missing draftOrderFulfilmentDetails")
            setError(CheckoutPaymentHandlingViewModelError.missingDraftOrderFulfilmentDetails)
            sendPaymentCardError(gateway: gateway.name, applePay: false, description: "Missing draftOrderFulfilmentDetails")
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
            setError(CheckoutPaymentHandlingViewModelError.verificationFailed)
            sendPaymentCardError(gateway: PaymentGatewayType.checkoutcom.rawValue, applePay: false, description: "verification failed: " + error.localizedDescription)
        }
    }
    
    // 3DS failure handler
    func threeDSFail() {
        threeDSWebViewURLs = nil
        Logger.checkout.error("Card payment failed - 3DS verification failed")
        setError(CheckoutPaymentHandlingViewModelError.threeDSVerificationFailed)
        sendPaymentCardError(gateway: PaymentGatewayType.checkoutcom.rawValue, applePay: false, description: "3DS verification failed")
    }
    
    func onAppearTrigger() async {
        do {
            savedCardsDetails = try await container.services.memberService.getSavedCards()
        } catch {
            Logger.member.error("Saved card details could not be retreived")
        }
    }
    
    func selectSavedCard(card: MemberCardDetails) {
        if selectedSavedCard == card {
            selectedSavedCard = nil
        } else {
            selectedSavedCard = card
        }
    }
}
