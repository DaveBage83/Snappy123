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

@MainActor
class CheckoutFulfilmentInfoViewModel: ObservableObject {
    enum PaymentMethod: String {
        case payByCard = "cards"
        case payByApple = "applepay"
        case payByCash = "cash"
    }
    
    let container: DIContainer
    private let timeZone: TimeZone?
    private let dateGenerator: () -> Date
    let selectedStore: RetailStoreDetails?
    private let fulfilmentType: RetailStoreOrderMethodType
    @Published var selectedRetailStoreFulfilmentTimeSlots: Loadable<RetailStoreTimeSlots> = .notRequested
    @Published var basket: Basket?
    var instructions: String?
    @Published var tempTodayTimeSlot: RetailStoreSlotDayTimeSlot?
    @Published var selectedDeliveryAddress: Address?
    @Published var processingPayByCash: Bool = false
    @Published var handleGlobalPayment: Bool = false
    var draftOrderFulfilmentDetails: DraftOrderFulfilmentDetailsRequest?
    let setCheckoutState: (CheckoutRootViewModel.CheckoutState) -> Void
    var hasConfirmedCashPayment = false
    @Published var showConfirmCashPaymentAlert = false
    var paymentMethodsOrder = [PaymentMethod]()

    var showPayByCard: Bool {
        if let store = selectedStore, let paymentMethods = store.paymentMethods {
            return store.isCompatible(with: .checkoutcom) && paymentMethods.contains(where: { $0.isCompatible(with: fulfilmentType, for: .checkoutcom)
            })
        }
        return false
    }
    
    var showPayByApple: Bool {
        if PKPaymentAuthorizationController.canMakePayments(
            usingNetworks: [.masterCard, .visa, .JCB, .discover]
        ) {
            if let store = selectedStore, let paymentMethods = store.paymentMethods {
                return paymentMethods.contains {
                    $0.name.lowercased() == PaymentMethod.payByApple.rawValue && paymentMethods.contains(where: {
                        $0.isCompatible(with: fulfilmentType, for: .checkoutcom)
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
    
    var orderTotalPriceString: String? {
        guard
            let orderTotal = basket?.orderTotal,
            let currency = selectedStore?.currency
        else {
            return nil
        }
        return orderTotal.toCurrencyString(using: currency)
    }
    
    private var cancellables = Set<AnyCancellable>()
    
    init(container: DIContainer, wasPaymentUnsuccessful: Bool = false, instructions: String? = nil, checkoutState: @escaping (CheckoutRootViewModel.CheckoutState) -> Void, dateGenerator: @escaping () -> Date = Date.init) {
        self.container = container
        self.dateGenerator = dateGenerator
        self.setCheckoutState = checkoutState
        let appState = container.appState
        basket = appState.value.userData.basket
        fulfilmentType = appState.value.userData.selectedFulfilmentMethod
        selectedStore = appState.value.userData.selectedStore.value
        _selectedDeliveryAddress = .init(initialValue: appState.value.userData.basketDeliveryAddress)
        self.instructions = instructions
        _tempTodayTimeSlot = .init(initialValue: appState.value.userData.tempTodayTimeSlot)
        timeZone = appState.value.userData.selectedStore.value?.storeTimeZone
        
        setPaymentTypeOrder()
        setupBasket(with: appState)
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
    
    private func setupSelectedDeliveryAddressBinding(with appState: Store<AppState>) {
        $selectedDeliveryAddress
            .removeDuplicates()
            .receive(on: RunLoop.main)
            .sink { appState.value.userData.basketDeliveryAddress = $0 }
            .store(in: &cancellables)
        
        appState
            .map(\.userData.basketDeliveryAddress)
            .removeDuplicates()
            .receive(on: RunLoop.main)
            .assignWeak(to: \.selectedDeliveryAddress, on: self)
            .store(in: &cancellables)
    }
    
    private func setupTempTodayTimeSlot(with appState: Store<AppState>) {
        $tempTodayTimeSlot
            .removeDuplicates()
            .receive(on: RunLoop.main)
            .sink { appState.value.userData.tempTodayTimeSlot = $0 }
            .store(in: &cancellables)
        
        appState
            .map(\.userData.tempTodayTimeSlot)
            .removeDuplicates()
            .receive(on: RunLoop.main)
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
    
    func setPaymentTypeOrder() {
        guard let paymentMethods = selectedStore?.paymentMethods else { return }
        for paymentMethod in paymentMethods {
            if paymentMethod.name.lowercased() == PaymentMethod.payByCash.rawValue && showPayByCash {
                paymentMethodsOrder.append(.payByCash)
            } else if paymentMethod.name.lowercased() == PaymentMethod.payByCard.rawValue && showPayByCard {
                paymentMethodsOrder.append(.payByCard)
            } else if paymentMethod.name.lowercased() == PaymentMethod.payByApple.rawValue && showPayByApple {
                paymentMethodsOrder.append(.payByApple)
            }
        }
    }
    
    private func sendPaymentCardError(gateway: PaymentGatewayType, applePay: Bool, description: String) {
        
        var gatewayDescription: String
        switch gateway {
        case .realex:
            gatewayDescription = "globalpayments"
        default:
            gatewayDescription = gateway.rawValue
        }
        
        var appsFlyerParams: [String: Any] = [
            "order_id": self.container.services.checkoutService.currentDraftOrderId ?? 0,
            "payment_method": gatewayDescription,
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
            "gateway": gatewayDescription,
            "error": description,
            "payment_type": applePay ? "apple_pay" : "card"
        ]
        
        self.container.eventLogger.sendEvent(for: .paymentFailure, with: .firebaseAnalytics, params: firebaseParams)
    }
    
    private func setError(_ err: Error) {
        container.appState.value.errors.append(err)
    }
    
    func payByCardTapped() {
        container.eventLogger.sendEvent(for: .payByCardSelected, with: .firebaseAnalytics, params: [:])
        if let unwrappedPaymentGateway = selectedStore?.paymentGateways?.first(where: { $0.name == PaymentGatewayType.checkoutcom.rawValue || $0.name == PaymentGatewayType.realex.rawValue }) {
            if unwrappedPaymentGateway.name == PaymentGatewayType.checkoutcom.rawValue {
                setCheckoutState(.card)
            } else if unwrappedPaymentGateway.name == PaymentGatewayType.realex.rawValue {
                draftOrderFulfilmentDetails = createDraftOrderRequest()
                
                handleGlobalPayment = true
            } else {
                Logger.checkout.error("Card payment failed - Payment Gateway mismatch")
                self.container.appState.value.errors.append(GenericError.somethingWrong)
            }
        }
    }
    
    // remember to keep logic same as in CheckoutPaymentHandlingViewModel
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
    
    func confirmCashPayment() async {
        hasConfirmedCashPayment = true
        await payByCashTapped()
    }
    
    func payByCashTapped() async {
        guard hasConfirmedCashPayment else {
            container.eventLogger.sendEvent(for: .payByCashSelected, with: .firebaseAnalytics, params: [:])
            showConfirmCashPaymentAlert = true
            return
        }
        
        processingPayByCash = true
        
        let draftOrderDetailsRequest = createDraftOrderRequest()
        
        do {
            let result  = try await container.services.checkoutService.createDraftOrder(fulfilmentDetails: draftOrderDetailsRequest, paymentGatewayType: .cash, instructions: instructions).singleOutput()
            
            if result.businessOrderId == nil {
                #warning("Should there happen something here?, i.e. inform user or move to paymentFailed?")
                Logger.checkout.fault("Successful order creation failed - BusinessOrderId missing")
                self.processingPayByCash = false
                return
            }
            
            self.hasConfirmedCashPayment = false
            self.processingPayByCash = false
            setCheckoutState(.paymentSuccess)
        } catch {
            self.setError(error)
            Logger.checkout.error("Failed creating draft order - Error: \(error.localizedDescription)")
            self.hasConfirmedCashPayment = false
            self.processingPayByCash = false
        }
    }
}

// MARK: - Global Payment Handling
extension CheckoutFulfilmentInfoViewModel {
    func handleGlobalPaymentResult(businessOrderId: Int?, error: Error?) {
        guaranteeMainThread { [weak self] in
            guard let self = self else { return }
            if let businessOrderId = businessOrderId {
                Logger.checkout.info("Payment succeeded - Business Order ID: \(businessOrderId)")
                self.setCheckoutState(.paymentSuccess)
            } else if let error = error {
                self.sendPaymentCardError(
                    gateway: .realex,
                    applePay: false,
                    description: error.localizedDescription
                )
                Logger.checkout.error("Payment failed - Error: \(error.localizedDescription)")
                self.setError(GenericError.somethingWrong)
            }
        }
    }
}

// MARK: - Apple Pay
extension CheckoutFulfilmentInfoViewModel {
    func payByAppleTapped() async {
        container.eventLogger.sendEvent(for: .payByApplePaySelected, with: .firebaseAnalytics, params: [:])
        let draftOrderDetailsRequest = createDraftOrderRequest()
        
        var paymentGateway: PaymentGateway?
        var publicKey: String?
        var merchantId: String?
        if let unwrappedPaymentGateway = selectedStore?.paymentGateways?.first(where: { $0.name == PaymentGatewayType.checkoutcom.rawValue }) {
            paymentGateway = unwrappedPaymentGateway
            publicKey = unwrappedPaymentGateway.fields?["publicKey"] as? String
            merchantId = unwrappedPaymentGateway.fields?["applePayMerchantId"] as? String
        } else if let businessProfile = container.appState.value.businessData.businessProfile {
            paymentGateway = businessProfile.paymentGateways.first(where: { $0.name == PaymentGatewayType.checkoutcom.rawValue })
            publicKey = paymentGateway?.fields?["publicKey"] as? String
            merchantId = paymentGateway?.fields?["applePayMerchantId"] as? String
        }
        
        if let publicKey = publicKey, let merchantId = merchantId {
            do {
                let businessOrderId = try await self.container.services.checkoutService.processApplePaymentOrder(fulfilmentDetails: draftOrderDetailsRequest, paymentGatewayType: .checkoutcom, paymentGatewayMode: paymentGateway?.mode ?? .sandbox, instructions: instructions, publicKey: publicKey, merchantId: merchantId)
                
                guard let _ = businessOrderId else {
                    Logger.checkout.error("Apple pay failed - BusinessOrderId not returned")
                    self.setError(GenericError.somethingWrong)
                    sendPaymentCardError(
                        gateway: .checkoutcom,
                        applePay: true,
                        description: "Apple pay failed - BusinessOrderId not returned"
                    )
                    return
                }
                setCheckoutState(.paymentSuccess)
            } catch {
                Logger.checkout.error("Apple pay failed - Error: \(error.localizedDescription)")
                self.setError(error)
                sendPaymentCardError(
                    gateway: .checkoutcom,
                    applePay: true,
                    description: error.localizedDescription
                )
            }
        } else {
            Logger.checkout.error("Apple pay failed - Missing publicKey or merchantId")
            setError(GenericError.somethingWrong)
            sendPaymentCardError(
                gateway: .checkoutcom,
                applePay: true,
                description: "Missing publicKey or merchantId"
            )
        }
    }
}
