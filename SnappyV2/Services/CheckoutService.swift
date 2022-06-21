//
//  CheckoutService.swift
//  SnappyV2
//
//  Created by Kevin Palser on 04/02/2022.
//

import Combine
import Foundation
import AppsFlyerLib

// 3rd Party
import KeychainAccess

enum CheckoutServiceError: Swift.Error {
    case selfError
    case storeSelectionRequired
    case unableToProceedWithoutBasket
    case draftOrderRequired
    case paymentGatewayNotAvaibleToStore
    case paymentGatewayNotAvaibleForFulfilmentMethod
    case unablePersistLastDeliverOrder
}

extension CheckoutServiceError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .selfError:
            return "Unable to unwrap self instance"
        case .storeSelectionRequired:
            return "Ordering location selection is required"
        case .unableToProceedWithoutBasket:
            return "Unable to proceed because of missing basket information"
        case .draftOrderRequired:
            return "Unable to proceed until a draft order has been created"
        case .paymentGatewayNotAvaibleToStore:
            return "Selected store does not support payment gateway"
        case .paymentGatewayNotAvaibleForFulfilmentMethod:
            return "Selected store does not support payment gateway and fulfilment method combination"
        case .unablePersistLastDeliverOrder:
            return "Unable to save the last delivery order"
        }
    }
}

protocol CheckoutServiceProtocol: AnyObject {
    
    // Create a draft order based on the current basket. If the order can be created immediately
    // i.e, no payment step for cash and loyalty paid orders, then the businessOrderId will be
    // returned. DraftOrderPaymentMethods is the saved payment cards - currently limited to Stripe.
    func createDraftOrder(
        fulfilmentDetails: DraftOrderFulfilmentDetailsRequest,
        paymentGateway: PaymentGatewayType,
        instructions: String?
    ) -> Future<(businessOrderId: Int?, savedCards: DraftOrderPaymentMethods?, firstOrder: Bool), Error>
    
    func getRealexHPPProducerData() -> Future<Data, Error>
    
    func processRealexHPPConsumerData(hppResponse: [String: Any], firstOrder: Bool) -> Future<ShimmedPaymentResponse, Error>
    
    func confirmPayment(firstOrder: Bool) -> Future<ConfirmPaymentResponse, Error>
    
    func verifyPayment() -> Future<ConfirmPaymentResponse, Error>
    
    func getPlacedOrderStatus(status: LoadableSubject<PlacedOrderStatus>, businessOrderId: Int)
    
    // When a specific delivery order id is known
    func getDriverLocation(businessOrderId: Int) async throws -> DriverLocation
    
    // After a important transition such as the app opening or moving to the foreground
    func getLastDeliveryOrderDriverLocation() async throws -> DriverLocationMapParameters?
    
    // Used when a result is returned (e.g. Pusher service) that indicates we no longer need
    // to persistently keep the last order
    func clearLastDeliveryOrderOnDevice() async throws
    
    // used for development to leave test order details in core data so that
    // testing can be performed on automatically testing en route orders
    func addTestLastDeliveryOrderDriverLocation() async throws
}

// Needs to be a class because draftOrderResult is mutated ouside of the init method.
class CheckoutService: CheckoutServiceProtocol {
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
    private let keychain = Keychain(service: Bundle.main.bundleIdentifier!)
    
    private var draftOrderId: Int?
    
    private let completedDeliveryOrderStates: [Int] = [
        2, // delivery finished
        3, // delivery problem
        6 // third party - cannot show the map
    ]
    
    private func saveDeliveryOrderAndClearBasket(forBusinessOrderId businessOrderId: Int) async throws {
        // order placed immediately without additional payment steps required
        draftOrderId = nil
        // keep order information for the automatic displaying of the driver map
        try await storeLastDeliveryOrder(forBusinessOrderId: businessOrderId)
        // clear the basket information
        try await dbRepository.clearBasket()
        self.appState.value.userData.basket = nil
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
    
    init(
        webRepository: CheckoutWebRepositoryProtocol,
        dbRepository: CheckoutDBRepositoryProtocol,
        appState: Store<AppState>,
        eventLogger: EventLoggerProtocol
    ) {
        self.webRepository = webRepository
        self.dbRepository = dbRepository
        self.appState = appState
        self.eventLogger = eventLogger
    }

    // Protocol Functions
    func createDraftOrder(
        fulfilmentDetails: DraftOrderFulfilmentDetailsRequest,
        paymentGateway: PaymentGatewayType,
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
            
            if paymentGateway != .loyalty {
            
                guard let paymentMethods = appStateValue.selectedStore.value?.paymentMethods else {
                    promise(.failure(CheckoutServiceError.paymentGatewayNotAvaibleToStore))
                    return
                }
            
                switch paymentGateway {
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
                    if selectedStore.isCompatible(with: paymentGateway) {
                        var paymentMethodFound = false
                        if let paymentMethods = selectedStore.paymentMethods {
                            for paymentMethod in paymentMethods where paymentMethod.isCompatible(with: appStateValue.selectedFulfilmentMethod, for: paymentGateway) {
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
                            paymentGateway: paymentGateway,
                            storeId: selectedStore.id
                        ).singleOutput()
                    
                    if let businessOrderId = draft.businessOrderId {
                        self.sendAppsFlyerPurchaseEvent(firstPurchase: draft.firstOrder, businessOrderId: draft.businessOrderId, paymentType: paymentGateway)
                        try await self.saveDeliveryOrderAndClearBasket(forBusinessOrderId: businessOrderId)
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
    private func sendAppsFlyerPurchaseEvent(firstPurchase: Bool, businessOrderId: Int?, paymentType: PaymentGatewayType) {
        let basket = self.appState.value.userData.basket
        
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
            "item_price": itemPricePaidArray,
            "item_quantity": itemQuantityArray,
            "item_barcode": itemEposArray,
            AFEventParamCurrency: AppV2Constants.Business.currencyCode,
            AFEventParamQuantity: basketQuantity,
            "delivery_cost": deliveryCost,
            "payment_type": paymentType.rawValue
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
        
        if let businessOrderId = businessOrderId {
            purchaseParams[AFEventParamOrderId] = businessOrderId
            purchaseParams[AFEventParamReceiptId] = businessOrderId
        }
        
        if let coupon = basket?.coupon {
            purchaseParams["coupon_code"] = coupon.code
            purchaseParams["coupon_discount_amount"] = coupon.deductCost
            purchaseParams["campaign_id"] = coupon.iterableCampaignId
        }
        
        self.eventLogger.sendEvent(for: firstPurchase ? .firstPurchase : .purchase, with: .appsFlyer, params: purchaseParams)
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
                        self.sendAppsFlyerPurchaseEvent(firstPurchase: firstOrder, businessOrderId: consumerResponse.result.businessOrderId, paymentType: .realex)
                        try await self.saveDeliveryOrderAndClearBasket(forBusinessOrderId: businessOrderId)
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
                        self.sendAppsFlyerPurchaseEvent(firstPurchase: firstOrder, businessOrderId: confirmPaymentResponse.result.businessOrderId, paymentType: .realex)
                        try await self.saveDeliveryOrderAndClearBasket(forBusinessOrderId: businessOrderId)
                    }
                    
                    promise(.success(confirmPaymentResponse))
                    
                } catch {
                    promise(.failure(error))
                }
            }
            
        }
    }
    
    
    func verifyPayment() -> Future<ConfirmPaymentResponse, Error> {
        
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
                        .verifyPayment(orderId: draftOrderId)
                        .singleOutput()
                    
                    if let businessOrderId = confirmPaymentResponse.result.businessOrderId {
                        try await self.saveDeliveryOrderAndClearBasket(forBusinessOrderId: businessOrderId)
                    }
                    
                    promise(.success(confirmPaymentResponse))
                    
                } catch {
                    promise(.failure(error))
                }
            }
        }
        
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

class StubCheckoutService: CheckoutServiceProtocol {

    func createDraftOrder(
        fulfilmentDetails: DraftOrderFulfilmentDetailsRequest,
        paymentGateway: PaymentGatewayType,
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
    
    func verifyPayment() -> Future<ConfirmPaymentResponse, Error> {
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
    
    func addTestLastDeliveryOrderDriverLocation() async throws { }
    
}
