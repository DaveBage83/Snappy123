//
//  CheckoutService.swift
//  SnappyV2
//
//  Created by Kevin Palser on 04/02/2022.
//

import Combine
import Foundation

// 3rd Party
import AppsFlyerLib
import Checkout
import FBSDKCoreKit
import KeychainAccess
import Firebase

enum CheckoutServiceError: Swift.Error, Equatable {
    case selfError
    case storeSelectionRequired
    case unableToProceedWithoutBasket
    case draftOrderRequired
    case paymentIdRequired
    case paymentGatewayNotAvaibleToStore
    case paymentGatewayNotAvaibleForFulfilmentMethod
    case unablePersistLastDeliverOrder
    case businessOrderIdNotReturned
    case billingAddressDetailsMissing
    case businessOrderIdNotReturnedAndMakePaymentResultNotPending
    case failedToUnwrap3DSURLs
    case paymentDeclined
}

extension CheckoutServiceError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .selfError:
            return Strings.CheckoutServiceErrors.selfError.localized
        case .storeSelectionRequired:
            return Strings.CheckoutServiceErrors.storeSelectionRequired.localized
        case .unableToProceedWithoutBasket:
            return Strings.CheckoutServiceErrors.unableToProceedWithoutBasket.localized
        case .draftOrderRequired:
            return Strings.CheckoutServiceErrors.draftOrderRequired.localized
        case .paymentGatewayNotAvaibleToStore:
            return Strings.CheckoutServiceErrors.paymentGatewayNotAvaibleToStore.localized
        case .paymentGatewayNotAvaibleForFulfilmentMethod:
            return Strings.CheckoutServiceErrors.paymentGatewayNotAvaibleForFulfilmentMethod.localized
        case .unablePersistLastDeliverOrder:
            return Strings.CheckoutServiceErrors.unablePersistLastDeliverOrder.localized
        case .businessOrderIdNotReturned:
            return "Payment failed - businessOrderId not returned"
        case .billingAddressDetailsMissing:
            return "Billing details missing from basket"
        case .businessOrderIdNotReturnedAndMakePaymentResultNotPending:
            return "Payment failed - businessOrderId not returned and 3DS not requested"
        case .failedToUnwrap3DSURLs:
            return "Payment failed - Failed to unwrap 3DS URLs"
        case .paymentDeclined:
            return "Payment failed - Declined"
        case .paymentIdRequired:
            return "Payment Failed - PaymentId missing"
        }
    }
}

protocol CheckoutServiceProtocol: AnyObject {
    
    var currentDraftOrderId: Int? { get }
    
    // Create a draft order based on the current basket. If the order can be created immediately
    // i.e, no payment step for cash and loyalty paid orders, then the businessOrderId will be
    // returned. DraftOrderPaymentMethods is the saved payment cards - currently limited to Stripe.
    func createDraftOrder(
        fulfilmentDetails: DraftOrderFulfilmentDetailsRequest,
        paymentGatewayType: PaymentGatewayType,
        instructions: String?
    ) -> Future<(businessOrderId: Int?, savedCards: DraftOrderPaymentMethods?, firstOrder: Bool), Error>
    
    func getRealexHPPProducerData() -> Future<Data, Error>
    
    func processRealexHPPConsumerData(hppResponse: [String: Any], firstOrder: Bool) -> Future<ShimmedPaymentResponse, Error>
    
    func confirmPayment(firstOrder: Bool) -> Future<ConfirmPaymentResponse, Error>
    
    func verifyCheckoutcomPayment() async throws
    
    func processApplePaymentOrder(fulfilmentDetails: DraftOrderFulfilmentDetailsRequest, paymentGatewayType: PaymentGatewayType, paymentGatewayMode: PaymentGatewayMode, instructions: String?, publicKey: String, merchantId: String) async throws -> Int?
    
    func processNewCardPaymentOrder(fulfilmentDetails: DraftOrderFulfilmentDetailsRequest, paymentGatewayType: PaymentGatewayType, paymentGatewayMode: PaymentGatewayMode, instructions: String?, publicKey: String, cardDetails: CheckoutCardDetails, saveCardPaymentHandler: ((String) async throws -> ())?) async throws -> (Int?, CheckoutCom3DSURLs?)
    
    func processSavedCardPaymentOrder(fulfilmentDetails: DraftOrderFulfilmentDetailsRequest, paymentGatewayType: PaymentGatewayType, paymentGatewayMode: PaymentGatewayMode, instructions: String?, publicKey: String, cardId: String, cvv: String) async throws -> (Int?, CheckoutCom3DSURLs?)
    
    func getPlacedOrderStatus(status: LoadableSubject<PlacedOrderStatus>, businessOrderId: Int)
    
    // When a specific delivery order id is known
    func getDriverLocation(businessOrderId: Int) async throws -> DriverLocation
    
    // After a important transition such as the app opening or moving to the foreground
    func getLastDeliveryOrderDriverLocation() async throws -> DriverLocationMapParameters?
    
    // Used when a result is returned (e.g. Pusher service) that indicates we no longer need
    // to persistently keep the last order
    func clearLastDeliveryOrderOnDevice() async throws
    
    // the most recent business order id generated whilst placing an order since the app was open
    func lastBusinessOrderIdInCurrentSession() -> Int?
    
    // To retrieve an order without needing a membership association or access permissions. Its
    // main purpose is to fetch details when a customer chooses to view their order after an
    // order update push notification is received. The push notification will contain the
    // business order id and hash.
    func getOrder(forBusinessOrderId: Int, withHash: String) async throws -> PlacedOrder
    
    // used for development to leave test order details in core data so that
    // testing can be performed on automatically testing en route orders
    func addTestLastDeliveryOrderDriverLocation() async throws
}

// Needs to be a class because draftOrderResult is mutated ouside of the init method.
final class CheckoutService: CheckoutServiceProtocol {
    let webRepository: CheckoutWebRepositoryProtocol
    
    // Unlike the database repositories for other services, this is purely
    // used to delete the basket
    let dbRepository: CheckoutDBRepositoryProtocol
    
    // Example in the clean architecture Countries exampe of the appState
    // being passed to a service (but not used the code). Using this as
    // a justification to be an acceptable method to update the Basket
    // Henrik/Kevin: 2021-10-26
    let appState: Store<AppState>
    
    let eventLogger: EventLoggerProtocol
    
    private var cancelBag = CancelBag()
    
    private var draftOrderId: Int?
    private var lastBusinessOrderId: Int?
    private var firstOrder: Bool?
    private var checkoutcomPaymentId: String?
    
    private let completedDeliveryOrderStates: [Int] = [
        2, // delivery finished
        3, // delivery problem
        6 // third party - cannot show the map
    ]
    
    private func processConfirmedOrder(forBusinessOrderId businessOrderId: Int) async throws {
        // order placed immediately without additional payment steps required
        draftOrderId = nil
        firstOrder = nil
        checkoutcomPaymentId = nil
        lastBusinessOrderId = businessOrderId
        // keep order information for the automatic displaying of the driver map
        try await storeLastDeliveryOrder(forBusinessOrderId: businessOrderId)
        // clear the basket information
        try await dbRepository.clearBasket()
        guaranteeMainThread {
            // Save basket to appState for use in OrderSummaryCard
            let user = self.appState.value.userData
            self.appState.value.userData.successCheckoutBasket = user.basket
            // Clear basket
            self.appState.value.userData.basket = nil
        }
        
        // perform the mention me actions
        if appState.value.businessData.businessProfile?.mentionMeEnabled ?? false {
            // invalidate the cached results
            guaranteeMainThread {
                self.appState.value.staticCacheData.mentionMeOfferResult = nil
            }
            // inform mention me of the order
            await eventLogger.sendMentionMeConsumerOrderEvent(businessOrderId: businessOrderId)
        }
    }
    
    private func storeLastDeliveryOrder(forBusinessOrderId businessOrderId: Int) async throws {
        let appStateValue = appState.value.userData
        if appStateValue.selectedFulfilmentMethod == .delivery {
            // always clear the last entry
            try await dbRepository.clearLastDeliveryOrderOnDevice()
            // store the new value
            let selectedStore = appStateValue.selectedStore.value
            try await dbRepository.store(
                lastDeliveryOrderOnDevice: LastDeliveryOrderOnDevice(
                    businessOrderId: businessOrderId,
                    storeName: selectedStore?.storeName,
                    storeContactNumber: selectedStore?.telephone,
                    deliveryPostcode: appStateValue.currentFulfilmentLocation?.postcode
                )
            )
        }
    }
    
    typealias CheckoutComClient = (String, Environment) -> CheckoutAPIServiceProtocol
    private let checkoutComClient: CheckoutComClient
    
    init(
        webRepository: CheckoutWebRepositoryProtocol,
        dbRepository: CheckoutDBRepositoryProtocol,
        appState: Store<AppState>,
        eventLogger: EventLoggerProtocol,
        checkoutComClient: @escaping CheckoutComClient = { CheckoutAPIService(publicKey: $0, environment: $1)}
    ) {
        self.webRepository = webRepository
        self.dbRepository = dbRepository
        self.appState = appState
        self.eventLogger = eventLogger
        self.checkoutComClient = checkoutComClient
    }

    var currentDraftOrderId: Int? {
        return draftOrderId
    }
    
    // Protocol Functions
    func createDraftOrder(
        fulfilmentDetails: DraftOrderFulfilmentDetailsRequest,
        paymentGatewayType: PaymentGatewayType,
        instructions: String?
    ) -> Future<(businessOrderId: Int?, savedCards: DraftOrderPaymentMethods?, firstOrder: Bool), Error> {
        
        return Future() { [weak self] promise in
            
            guard let self = self else {
                promise(.failure(CheckoutServiceError.selfError))
                return
            }
            
            let appStateValue = self.appState.value.userData
            
            guard let basketToken = appStateValue.basket?.basketToken else {
                promise(.failure(CheckoutServiceError.unableToProceedWithoutBasket))
                return
            }
            
            guard let selectedStore = appStateValue.selectedStore.value else {
                promise(.failure(CheckoutServiceError.storeSelectionRequired))
                return
            }
            
            if paymentGatewayType != .loyalty {
            
                guard let paymentMethods = appStateValue.selectedStore.value?.paymentMethods else {
                    promise(.failure(CheckoutServiceError.paymentGatewayNotAvaibleToStore))
                    return
                }
            
                switch paymentGatewayType {
                case .cash:
                    var cashFound = false
                    for paymentMethod in paymentMethods where paymentMethod.name.lowercased() == "cash" {
                        cashFound = true
                        if paymentMethod.isCompatible(with: appStateValue.selectedFulfilmentMethod) == false {
                            promise(.failure(CheckoutServiceError.paymentGatewayNotAvaibleForFulfilmentMethod))
                            return
                        }
                    }
                    if cashFound == false {
                        promise(.failure(CheckoutServiceError.paymentGatewayNotAvaibleToStore))
                        return
                    }
                        
                default:
                    if selectedStore.isCompatible(with: paymentGatewayType) {
                        var paymentMethodFound = false
                        if let paymentMethods = selectedStore.paymentMethods {
                            for paymentMethod in paymentMethods where paymentMethod.isCompatible(with: appStateValue.selectedFulfilmentMethod, for: paymentGatewayType) {
                                paymentMethodFound = true
                                break
                            }
                        }
                        if paymentMethodFound == false {
                            promise(.failure(CheckoutServiceError.paymentGatewayNotAvaibleForFulfilmentMethod))
                            return
                        }
                    } else {
                        promise(.failure(CheckoutServiceError.paymentGatewayNotAvaibleToStore))
                        return
                    }
                }
                
            }
            
            Task {
                do {
                    let draft = try await self.webRepository
                        .createDraftOrder(
                            basketToken: basketToken,
                            fulfilmentDetails: fulfilmentDetails,
                            instructions: instructions,
                            paymentGateway: paymentGatewayType,
                            storeId: selectedStore.id,
                            notificationDeviceToken: self.appState.value.system.notificationDeviceToken
                        ).singleOutput()
                    
                    if let businessOrderId = draft.businessOrderId {
                        self.sendPurchaseEvents(firstPurchase: draft.firstOrder, businessOrderId: businessOrderId, paymentType: paymentGatewayType)
                        try await self.processConfirmedOrder(forBusinessOrderId: businessOrderId)
                    } else {
                        // keep the draftOrderId for subsequent operations
                        self.draftOrderId = draft.draftOrderId
                    }
                    
                    promise(.success((businessOrderId: draft.businessOrderId, savedCards: draft.paymentMethods, firstOrder: draft.firstOrder)))
                    
                } catch {
                    promise(.failure(error))
                }
            }
        }
    }
    
    #warning("Add firstPurchase flag when api changes are through")
    private func sendPurchaseEvents(firstPurchase: Bool, businessOrderId: Int, paymentType: PaymentGatewayType) {
        
        let currencyCode = appState.value.userData.selectedStore.value?.currency.currencyCode ?? AppV2Constants.Business.currencyCode
        
        let basket = self.appState.value.userData.basket
        
        // AppsFlyer
        var itemIdArray: [Int] = []
        var itemPricePaidArray: [Double] = []
        var itemQuantityArray: [Int] = []
        var itemEposArray: [String] = []
        var basketQuantity: Int = 0
        var deliveryCost: Double = 0
        if let basket = basket {
            for item in basket.items {
                itemIdArray.append(item.menuItem.id)
                itemPricePaidArray.append(item.pricePaid)
                itemQuantityArray.append(item.quantity)
                itemEposArray.append(item.menuItem.eposCode ?? "")
            }
            basketQuantity = itemQuantityArray.reduce(0, +)
            deliveryCost = basket.fees?.first(where: { fee in
                fee.title == "Delivery"
            })?.amount ?? 0
        }
        
        var purchaseParams: [String: Any] = [
            AFEventParamContentId: itemIdArray,
            "item_price":           itemPricePaidArray,
            "item_quantity":        itemQuantityArray,
            "item_barcode":         itemEposArray,
            AFEventParamCurrency:   appState.value.userData.selectedStore.value?.currency.currencyCode ?? AppV2Constants.Business.currencyCode,
            AFEventParamQuantity:   basketQuantity,
            "delivery_cost":        deliveryCost,
            "payment_type":         paymentType.rawValue
        ]
        
        if let basket = basket {
            purchaseParams[AFEventParamRevenue] = basket.orderTotal
            purchaseParams[AFEventParamPrice] = basket.orderTotal
            purchaseParams["fulfilment_method"] = basket.fulfilmentMethod.type.rawValue
            purchaseParams["asap"] = basket.selectedSlot?.todaySelected ?? false
            purchaseParams["store_id"] = basket.storeId ?? 0
        }
        
        if let storeName = self.appState.value.userData.selectedStore.value?.storeName {
            purchaseParams["store_name"] = storeName
        }
        
        var facebookParams: [AppEvents.ParameterName : Any] = [
            .numItems: basket?.items.count ?? 0
        ]
        
        purchaseParams[AFEventParamOrderId] = businessOrderId
        purchaseParams[AFEventParamReceiptId] = businessOrderId
        facebookParams[.orderID] = "\(businessOrderId)"
        facebookParams[.description] = "business order \(businessOrderId)"
        
        // create a JSON content decription for the Facebook purchase event
        var contentDescription = ""
        if let items = basket?.items {
            for item in items {
                if contentDescription.isEmpty == false {
                    contentDescription += " ,"
                }
                contentDescription += "{\"id\": \"\(item.menuItem.id)\", \"quantity\":\(item.quantity), \"item_price\": \(String(format:"%.2f", item.price))}"
            }
        }
        if contentDescription.isEmpty == false {
            contentDescription = "[{\"order_id\": \"\(businessOrderId)\"}, \(contentDescription)]"
        }
        
        facebookParams[.content] = contentDescription
        
        if let coupon = basket?.coupon {
            purchaseParams["coupon_code"] = coupon.code
            purchaseParams["coupon_discount_amount"] = coupon.deductCost
            purchaseParams["campaign_id"] = coupon.iterableCampaignId
        }
        
        eventLogger.sendEvent(for: firstPurchase ? .firstPurchase : .purchase, with: .appsFlyer, params: purchaseParams)
        
        // Facebook
        purchaseParams = [
            "checkedOutTotalCost": basket?.orderTotal ?? 0.0,
            "currency": currencyCode,
            "facebookParams": facebookParams
        ]
        
        eventLogger.sendEvent(for: .purchase, with: .facebook, params: purchaseParams)
        
        // Firebase
        purchaseParams = [
            AnalyticsParameterTransactionID: "\(businessOrderId)",
            AnalyticsParameterAffiliation: appState.value.userData.selectedStore.value?.storeName ?? "",
            AnalyticsParameterCurrency: currencyCode,
            AnalyticsParameterTax: 0
        ]
        
        if let basket = basket {
            var items: [[String: Any]] = []
            for line in basket.items {
                var item: [String: Any] = [
                    AnalyticsParameterItemID: AppV2Constants.EventsLogging.analyticsItemIdPrefix + "\(line.menuItem.id)",
                    AnalyticsParameterItemName: line.menuItem.name,
                    // unit price, not price paid - this is not a mistake
                    AnalyticsParameterPrice: NSDecimalNumber(value: line.price).rounding(accordingToBehavior: EventLogger.decimalBehavior).doubleValue,
                    AnalyticsParameterQuantity: line.quantity
                ]
                if let size = line.size {
                    item[AnalyticsParameterItemVariant] = AppV2Constants.EventsLogging.analticsSizeIdPrefix + "\(size.id)"
                }
                items.append(item)
            }
            purchaseParams[AnalyticsParameterItems] = items
            purchaseParams[AnalyticsParameterValue] = NSDecimalNumber(value: basket.orderTotal).rounding(accordingToBehavior: EventLogger.decimalBehavior).doubleValue
            purchaseParams[AnalyticsParameterShipping] = NSDecimalNumber(value: basket.fulfilmentMethod.cost).rounding(accordingToBehavior: EventLogger.decimalBehavior).doubleValue
            if let coupon = basket.coupon {
                purchaseParams[AnalyticsParameterCoupon] = coupon.code
            }
        }
        
        eventLogger.sendEvent(for: .purchase, with: .firebaseAnalytics, params: purchaseParams)
    }
    
    func getRealexHPPProducerData() -> Future<Data, Error> {
    
        return Future() { [weak self] promise in
            
            guard let self = self else {
                promise(.failure(CheckoutServiceError.selfError))
                return
            }
            
            // Note: a trouble shooting route to test prepared draft orders is to overide it here, e.g.
            //self.draftOrderId = 1963469
            
//            let appStateValue = self.appState.value.userData
//            guard let basketToken = appStateValue.basket?.basketToken else {
//                promise(.failure(CheckoutServiceError.unableToProceedWithoutBasket))
//                return
//            }
//            guard let storeId = appStateValue.selectedStore.value?.id else {
//                promise(.failure(CheckoutServiceError.storeSelectionRequired))
//                return
//            }
// Waiting on code for: https://snappyshopper.atlassian.net/wiki/spaces/DR/pages/495910917/Store+Payment+Methods
// to check that the Globalpayments method is available for the selected store/method
            
            guard let draftOrderId = self.draftOrderId else {
                promise(.failure(CheckoutServiceError.draftOrderRequired))
                return
            }
            
            self.webRepository
                .getRealexHPPProducerData(orderId: draftOrderId)
                .sinkToResult { result in
                    switch result {
                    case let .success(resultValue):
                        promise(.success(resultValue))
                    case let .failure(error):
                        promise(.failure(error))
                    }
                }
                .store(in: self.cancelBag)
        }
        
    }
    
    func processRealexHPPConsumerData(hppResponse: [String: Any], firstOrder: Bool) -> Future<ShimmedPaymentResponse, Error> {
        
        return Future() { [weak self] promise in
            
            guard let self = self else {
                promise(.failure(CheckoutServiceError.selfError))
                return
            }
            
            // Note: a trouble shooting route to test prepared draft orders is to overide it here, e.g.
            //self.draftOrderId = 1963469
            
            //            let appStateValue = self.appState.value.userData
            //            guard let basketToken = appStateValue.basket?.basketToken else {
            //                promise(.failure(CheckoutServiceError.unableToProceedWithoutBasket))
            //                return
            //            }
            //            guard let storeId = appStateValue.selectedStore.value?.id else {
            //                promise(.failure(CheckoutServiceError.storeSelectionRequired))
            //                return
            //            }
            // Waiting on code for: https://snappyshopper.atlassian.net/wiki/spaces/DR/pages/495910917/Store+Payment+Methods
            // to check that the Globalpayments method is available for the selected store/method
            
            guard let draftOrderId = self.draftOrderId else {
                promise(.failure(CheckoutServiceError.draftOrderRequired))
                return
            }
            
            Task {
                do {
                    let consumerResponse = try await self.webRepository
                        .processRealexHPPConsumerData(orderId: draftOrderId, hppResponse: hppResponse)
                        .singleOutput()
                    
                    if let businessOrderId = consumerResponse.result.businessOrderId {
                        self.sendPurchaseEvents(firstPurchase: firstOrder, businessOrderId: businessOrderId, paymentType: .realex)
                        try await self.processConfirmedOrder(forBusinessOrderId: businessOrderId)
                    }
                    
                    promise(.success(consumerResponse.result))
                    
                } catch {
                    promise(.failure(error))
                }
            }
        }
        
    }
    
    func confirmPayment(firstOrder: Bool) -> Future<ConfirmPaymentResponse, Error> {
        
        return Future() { [weak self] promise in
            
            guard let self = self else {
                promise(.failure(CheckoutServiceError.selfError))
                return
            }
            
            guard let draftOrderId = self.draftOrderId else {
                promise(.failure(CheckoutServiceError.draftOrderRequired))
                return
            }
            
            Task {
                do {
                    let confirmPaymentResponse = try await self.webRepository
                        .confirmPayment(orderId: draftOrderId)
                        .singleOutput()
                    
                    if let businessOrderId = confirmPaymentResponse.result.businessOrderId {
                        self.sendPurchaseEvents(firstPurchase: firstOrder, businessOrderId: businessOrderId, paymentType: .realex)
                        try await self.processConfirmedOrder(forBusinessOrderId: businessOrderId)
                    }
                    
                    promise(.success(confirmPaymentResponse))
                    
                } catch {
                    promise(.failure(error))
                }
            }
            
        }
    }
    
    func processApplePaymentOrder(fulfilmentDetails: DraftOrderFulfilmentDetailsRequest, paymentGatewayType: PaymentGatewayType, paymentGatewayMode: PaymentGatewayMode, instructions: String?, publicKey: String, merchantId: String) async throws -> Int? {
        
        // In order to inject and initialise ApplePaymentHandler as default for testing purposes
        try await processApplePaymentOrder(fulfilmentDetails: fulfilmentDetails, paymentGatewayType: paymentGatewayType, paymentGatewayMode: paymentGatewayMode, instructions: instructions, publicKey: publicKey, merchantId: merchantId, applePayHandler: ApplePaymentHandler())
    }
    
    func getPlacedOrderStatus(status: LoadableSubject<PlacedOrderStatus>, businessOrderId: Int) {
        let cancelBag = CancelBag()
        status.wrappedValue.setIsLoading(cancelBag: cancelBag)
        
        return webRepository
            .getPlacedOrderStatus(forBusinessOrderId: businessOrderId)
            .eraseToAnyPublisher()
            .receive(on: RunLoop.main)
            .sinkToLoadable { status.wrappedValue = $0 }
            .store(in: cancelBag)
    }
    
    func getDriverLocation(businessOrderId: Int) async throws -> DriverLocation {
        let result = try await webRepository.getDriverLocation(forBusinessOrderId: businessOrderId)
        
        // remove the order from further automatic consideration after reaching a
        // completed state
        if
            let deliveryStatus = result.delivery?.status,
            completedDeliveryOrderStates.contains(deliveryStatus)
        {
            if
                let lastDeliveryOrder = try await dbRepository.lastDeliveryOrderOnDevice(),
                lastDeliveryOrder.businessOrderId == businessOrderId
            {
                try await dbRepository.clearLastDeliveryOrderOnDevice()
            }
        }
        
        return result
    }
    
    func getLastDeliveryOrderDriverLocation() async throws -> DriverLocationMapParameters? {
        
        if let lastDeliveryOrder = try await dbRepository.lastDeliveryOrderOnDevice() {
            let result = try await getDriverLocation(businessOrderId: lastDeliveryOrder.businessOrderId)
            // only return a result for automatic map showing if the
            // order is en route
            if
                let deliveryStatus = result.delivery?.status,
                deliveryStatus == 5
            {
                return DriverLocationMapParameters(
                    businessOrderId: lastDeliveryOrder.businessOrderId,
                    driverLocation: result,
                    lastDeliveryOrder: lastDeliveryOrder,
                    placedOrder: nil
                )
            }
        }
        
        return nil
    }
    
    func clearLastDeliveryOrderOnDevice() async throws {
        try await dbRepository.clearLastDeliveryOrderOnDevice()
    }
    
    func lastBusinessOrderIdInCurrentSession() -> Int? {
        return lastBusinessOrderId
    }
    
    func getOrder(forBusinessOrderId businessOrderId: Int, withHash hash: String) async throws -> PlacedOrder {
        return try await webRepository.getOrder(forBusinessOrderId: businessOrderId, withHash: hash)
    }
    
    func addTestLastDeliveryOrderDriverLocation() async throws {
        try await dbRepository.clearLastDeliveryOrderOnDevice()
        try await dbRepository.store(
            lastDeliveryOrderOnDevice: LastDeliveryOrderOnDevice(
                businessOrderId: 4290187,
                storeName: "Mace Dundee",
                storeContactNumber: "0123646474533",
                deliveryPostcode: "DD2 1RW"
            )
        )
    }
    
}

// MARK: - Apple Pay
extension CheckoutService {
    private func processApplePaymentOrder(fulfilmentDetails: DraftOrderFulfilmentDetailsRequest, paymentGatewayType: PaymentGatewayType, paymentGatewayMode: PaymentGatewayMode, instructions: String?, publicKey: String, merchantId: String, applePayHandler: ApplePaymentHandlerProtocol) async throws -> Int? {
        
        guard let basket = appState.value.userData.basket else { throw CheckoutServiceError.unableToProceedWithoutBasket }
        
        // create draft order
        let draftResult = try await self.createDraftOrder(fulfilmentDetails: fulfilmentDetails, paymentGatewayType: paymentGatewayType, instructions: instructions).singleOutput()
        
        // create makePayment function with 2 out of 3 parameters filled in
        let makePaymentFunctionMissingToken = partialisedMakePaymentFunction(type: .applepay, paymentMethod: "apple_pay")
        
        // trigger the payment
        let businessOrderId = try await applePayHandler.startApplePayment(basket: basket, publicKey: publicKey, merchantId: merchantId, paymentGatewayMode: paymentGatewayMode, makePayment: makePaymentFunctionMissingToken)
        
        guard let businessOrderId = businessOrderId else { throw CheckoutServiceError.businessOrderIdNotReturned }
        
        sendPurchaseEvents(firstPurchase: draftResult.firstOrder, businessOrderId: businessOrderId, paymentType: .checkoutcom)
        
        return businessOrderId
    }
    
    private func partialisedMakePaymentFunction(type: PaymentType, paymentMethod: String) -> (String?) async throws -> MakePaymentResponse {
        return { (token: String?) -> MakePaymentResponse in
            return try await self.makePayment(type: type, paymentMethod: paymentMethod, token: token)
        }
    }
    
    #warning("This should be moved back to main class if other functions use it in future")
    private func makePayment(type: PaymentType, paymentMethod: String, token: String? = nil, cardId: String? = nil, cvv: Int? = nil) async throws -> MakePaymentResponse {
        
        guard let draftOrderId = draftOrderId else { throw CheckoutServiceError.draftOrderRequired }
        
        return try await webRepository.makePayment(draftOrderId: draftOrderId, type: type, paymentMethod: paymentMethod, token: token, cardId: cardId, cvv: cvv)
    }
}

// MARK: - Card Payment
extension CheckoutService {
    func processNewCardPaymentOrder(fulfilmentDetails: DraftOrderFulfilmentDetailsRequest, paymentGatewayType: PaymentGatewayType, paymentGatewayMode: PaymentGatewayMode, instructions: String?, publicKey: String, cardDetails: CheckoutCardDetails, saveCardPaymentHandler: ((String) async throws -> ())?) async throws -> (Int?, CheckoutCom3DSURLs?) {
        
        guard let basket = appState.value.userData.basket else { throw CheckoutServiceError.unableToProceedWithoutBasket }
        
        // create draft order
        let draftResult = try await self.createDraftOrder(fulfilmentDetails: fulfilmentDetails, paymentGatewayType: paymentGatewayType, instructions: instructions).singleOutput()
        
        // process checkoutcom
        let checkoutAPIClient = checkoutComClient(publicKey, paymentGatewayMode == .live ? .production : .sandbox)
        
        if let addresses = basket.addresses, let billing = addresses.first(where: {$0.type == "billing"}) {
            
            let phoneNumber = Phone(number: billing.telephone, country: nil)
            let address = Checkout.Address(
                addressLine1: billing.addressLine1,
                addressLine2: billing.addressLine2,
                city: billing.town,
                state: billing.county,
                zip: billing.postcode,
                country: Country(iso3166Alpha2: billing.countryCode ?? "GB")
            )
            let cardTokenRequest = Card(
                number: cardDetails.number,
                expiryDate: ExpiryDate(
                    month: cardDetails.expiryMonth,
                    year: cardDetails.expiryYear
                ),
                name: cardDetails.cardName,
                cvv: cardDetails.cvv,
                billingAddress: address,
                phone: phoneNumber
            )
            
            let result = try await checkoutAPIClient.createCardToken(card: cardTokenRequest)
            
            // make payment using new card details
            let makePaymentResult: MakePaymentResponse = try await makePayment(type: .token, paymentMethod: "card", token: result.token)
            
            // if card needs to be saved, memberService.saveNewCard is passed
            if let saveCard = saveCardPaymentHandler {
                try? await saveCard(result.token)
            }
            
            // process result
            return try await process(makePaymentResult: makePaymentResult, firstOrder: draftResult.firstOrder)
        } else {
            throw CheckoutServiceError.billingAddressDetailsMissing
        }
    }
    
    func processSavedCardPaymentOrder(fulfilmentDetails: DraftOrderFulfilmentDetailsRequest, paymentGatewayType: PaymentGatewayType, paymentGatewayMode: PaymentGatewayMode, instructions: String?, publicKey: String, cardId: String, cvv: String) async throws -> (Int?, CheckoutCom3DSURLs?) {
        
        guard let _ = appState.value.userData.basket else { throw CheckoutServiceError.unableToProceedWithoutBasket }
        
        // create draft order
        let draftResult = try await self.createDraftOrder(fulfilmentDetails: fulfilmentDetails, paymentGatewayType: paymentGatewayType, instructions: instructions).singleOutput()
        
        // make payment using saved card details
        let makePaymentResult = try await makePayment(type: .id, paymentMethod: "card", cardId: cardId, cvv: Int(cvv))
        
        // process result
        return try await process(makePaymentResult: makePaymentResult, firstOrder: draftResult.firstOrder)
    }
    
    private func process(makePaymentResult: MakePaymentResponse, firstOrder: Bool) async throws -> (Int?, CheckoutCom3DSURLs?) {
        if let businessOrderId = makePaymentResult.order?.businessOrderId {
            // trigger event logging if success
            sendPurchaseEvents(firstPurchase: firstOrder, businessOrderId: businessOrderId, paymentType: .checkoutcom)
            
            // process successful order
            try await self.processConfirmedOrder(forBusinessOrderId: businessOrderId)
            
            return (businessOrderId, nil)
        // pending signifies 3DS check and get urls for 3DS
        } else if makePaymentResult.gatewayData.status == .pending {
            if let redirectString = makePaymentResult.gatewayData._links?.redirect?.href,
                let successString = makePaymentResult.gatewayData._links?.success?.href,
                let failString = makePaymentResult.gatewayData._links?.failure?.href,
                let redirectURL = URL(string: redirectString),
                let successURL = URL(string: successString),
                let failURL = URL(string: failString) {
                let urls = CheckoutCom3DSURLs(redirectUrl: redirectURL, successUrl: successURL, failUrl: failURL)
                
                self.firstOrder = firstOrder
                checkoutcomPaymentId = makePaymentResult.gatewayData.id
                
                // return urls necessary to check 3DS - Viewmodel is responsible for 3DS check
                return (nil, urls)
            } else {
                throw CheckoutServiceError.failedToUnwrap3DSURLs
            }
        } else if makePaymentResult.gatewayData.status == .declined {
            throw CheckoutServiceError.paymentDeclined
        } else {
            throw CheckoutServiceError.businessOrderIdNotReturnedAndMakePaymentResultNotPending
        }
    }
    
    func verifyCheckoutcomPayment() async throws {
        guard let draftOrderId = self.draftOrderId else { throw CheckoutServiceError.draftOrderRequired }
        guard let paymentId = checkoutcomPaymentId else { throw CheckoutServiceError.paymentIdRequired}
        
        let verifyPaymentResponse = try await self.webRepository
            .verifyCheckoutcomPayment(draftOrderId: draftOrderId, businessId: appState.value.businessData.businessProfile?.id ?? 15, paymentId: paymentId)
        
        self.sendPurchaseEvents(firstPurchase: firstOrder ?? false, businessOrderId: verifyPaymentResponse.businessOrderId, paymentType: .checkoutcom)
        
        try await self.processConfirmedOrder(forBusinessOrderId: verifyPaymentResponse.businessOrderId)
    }
}

protocol CheckoutAPIServiceProtocol {
    func createCardToken(card: Card) async throws -> TokenDetails
}

extension CheckoutAPIService: CheckoutAPIServiceProtocol {}

extension CheckoutAPIService {
    func createCardToken(card: Card) async throws -> TokenDetails {
        return try await withCheckedThrowingContinuation { continuation in
            createToken(.card(card)) { result in
                continuation.resume(with: result)
            }
            
        }
    }
}

#if DEBUG || DEBUG_TEST
// This hack is neccessary in order to expose 'exposeProcessApplePaymentOrder' etc and enable for testing. These cannot easily be tested without.
extension CheckoutService {
    func exposeProcessApplePaymentOrder(fulfilmentDetails: DraftOrderFulfilmentDetailsRequest, paymentGatewayType: PaymentGatewayType, paymentGatewayMode: PaymentGatewayMode, instructions: String?, publicKey: String, merchantId: String, applePayHandler: ApplePaymentHandlerProtocol) async throws -> Int? {
        return try await self.processApplePaymentOrder(fulfilmentDetails: fulfilmentDetails, paymentGatewayType: paymentGatewayType, paymentGatewayMode: paymentGatewayMode, instructions: instructions, publicKey: publicKey, merchantId: merchantId, applePayHandler: applePayHandler)
    }
    
    func exposeAndUpdateDraftOrderIdAndPaymentId(draftOrderId: Int?, paymentId: String?) {
        self.draftOrderId = draftOrderId
        self.checkoutcomPaymentId = paymentId
    }
    
    var exposeCheckoutcomPaymentId: String? { checkoutcomPaymentId }
}
#endif

final class StubCheckoutService: CheckoutServiceProtocol {

    var currentDraftOrderId: Int? = nil

    func createDraftOrder(
        fulfilmentDetails: DraftOrderFulfilmentDetailsRequest,
        paymentGatewayType: PaymentGatewayType,
        instructions: String?
    ) -> Future<(businessOrderId: Int?, savedCards: DraftOrderPaymentMethods?, firstOrder: Bool), Error> {
        return Future { promise in
            promise(.success((businessOrderId: nil, savedCards: nil, firstOrder: false)))
        }
    }
    
    func getRealexHPPProducerData() -> Future<Data, Error> {
        return Future { promise in
            promise(.success(Data()))
        }
    }
    
    func processRealexHPPConsumerData(hppResponse: [String : Any], firstOrder: Bool) -> Future<ShimmedPaymentResponse, Error> {
        return Future { promise in
            promise(.success(ShimmedPaymentResponse(status: true, message: "String", orderId: nil, businessOrderId: nil, pointsEarned: nil, iterableUserEmail: nil)))
        }
    }
    
    func confirmPayment(firstOrder: Bool) -> Future<ConfirmPaymentResponse, Error> {
        return Future { promise in
            promise(.success(
                ConfirmPaymentResponse(
                    result: ShimmedPaymentResponse(
                        status: true,
                        message: "String",
                        orderId: nil,
                        businessOrderId: nil,
                        pointsEarned: nil,
                        iterableUserEmail: nil
                    )
                )
            ))
        }
    }
    
    func verifyCheckoutcomPayment() async throws {}
    
    func processApplePaymentOrder(fulfilmentDetails: DraftOrderFulfilmentDetailsRequest, paymentGatewayType: PaymentGatewayType, paymentGatewayMode: PaymentGatewayMode, instructions: String?, publicKey: String, merchantId: String) async throws -> Int? { return nil }
    
    func processNewCardPaymentOrder(fulfilmentDetails: DraftOrderFulfilmentDetailsRequest, paymentGatewayType: PaymentGatewayType, paymentGatewayMode: PaymentGatewayMode, instructions: String?, publicKey: String, cardDetails: CheckoutCardDetails, saveCardPaymentHandler: ((String) async throws -> ())?) async throws -> (Int?, CheckoutCom3DSURLs?) { (nil, nil) }
    
    func processSavedCardPaymentOrder(fulfilmentDetails: DraftOrderFulfilmentDetailsRequest, paymentGatewayType: PaymentGatewayType, paymentGatewayMode: PaymentGatewayMode, instructions: String?, publicKey: String, cardId: String, cvv: String) async throws -> (Int?, CheckoutCom3DSURLs?) { (nil, nil) }
    
    func getPlacedOrderStatus(status: LoadableSubject<PlacedOrderStatus>, businessOrderId: Int) { }
    
    func getDriverLocation(businessOrderId: Int) async throws -> DriverLocation {
        DriverLocation(
            orderId: 0,
            pusher: nil,
            store: nil,
            delivery: nil,
            driver: nil
        )
    }
    
    func getLastDeliveryOrderDriverLocation() async throws -> DriverLocationMapParameters? {
        DriverLocationMapParameters(
            businessOrderId: 0,
            driverLocation: DriverLocation(
                orderId: 0,
                pusher: nil,
                store: nil,
                delivery: nil,
                driver: nil
            ),
            lastDeliveryOrder: nil,
            placedOrder: nil
        )
    }
    
    func clearLastDeliveryOrderOnDevice() async throws { }
    
    func lastBusinessOrderIdInCurrentSession() -> Int? {
        return nil
    }
    
    func getOrder(forBusinessOrderId businessOrderId: Int, withHash hash: String) async throws -> PlacedOrder {
        .init(id: 123, businessOrderId: 1, status: "", statusText: "", totalPrice: 1, totalDiscounts: nil, totalSurcharge: nil, totalToPay: nil, platform: "", firstOrder: false, createdAt: "", updatedAt: "", store: .init(id: 1, name: "", originalStoreId: nil, storeLogo: nil, address1: "", address2: nil, town: "", postcode: "", telephone: nil, latitude: 1, longitude: 1), fulfilmentMethod: .init(name: .delivery, processingStatus: "", datetime: .init(requestedDate: nil, requestedTime: nil, estimated: nil, fulfilled: nil), place: nil, address: nil, driverTip: nil, refund: nil, deliveryCost: nil, driverTipRefunds: nil), paymentMethod: .init(name: "", dateTime: ""), orderLines: [], customer: .init(firstname: "", lastname: ""), discount: nil, surcharges: nil, loyaltyPoints: nil, coupon: nil, currency: .init(currencyCode: "", symbol: "", ratio: 1, symbolChar: "", name: ""), totalOrderValue: 1, totalRefunded: 1)
    }
    
    func addTestLastDeliveryOrderDriverLocation() async throws { }
    
}
