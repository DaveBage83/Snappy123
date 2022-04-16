//
//  CheckoutService.swift
//  SnappyV2
//
//  Created by Kevin Palser on 04/02/2022.
//

import Combine
import Foundation

enum CheckoutServiceError: Swift.Error {
    case selfError
    case storeSelectionRequired
    case unableToProceedWithoutBasket
    case draftOrderRequired
    case paymentGatewayNotAvaibleToStore
    case paymentGatewayNotAvaibleForFulfilmentMethod
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
    ) -> Future<(businessOrderId: Int?, savedCards: DraftOrderPaymentMethods?), Error>
    
    func getRealexHPPProducerData() -> Future<Data, Error>
    
    func processRealexHPPConsumerData(hppResponse: [String: Any]) -> Future<ShimmedPaymentResponse, Error>
    
    func confirmPayment() -> Future<ConfirmPaymentResponse, Error>
    
    func verifyPayment() -> Future<ConfirmPaymentResponse, Error>
    
    func getPlacedOrderStatus(status: LoadableSubject<PlacedOrderStatus>, businessOrderId: Int)
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
    
    private var draftOrderId: Int?
    
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
    ) -> Future<(businessOrderId: Int?, savedCards: DraftOrderPaymentMethods?), Error> {
        
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
            
            self.webRepository
                .createDraftOrder(
                    basketToken: basketToken,
                    fulfilmentDetails: fulfilmentDetails,
                    instructions: instructions,
                    paymentGateway: paymentGateway,
                    storeId: selectedStore.id
                )
                .flatMap({ draft -> AnyPublisher<DraftOrderResult, Error> in
                    // if the result has a business order id then clear the basket
                    if draft.businessOrderId != nil {
                        self.draftOrderId = nil
                        return self.clearBasket(passThrough: draft)
                    } else {
                        // keep the draftOrderId for subsequent operations
                        self.draftOrderId = draft.draftOrderId
                        return Just(draft)
                            .setFailureType(to: Error.self)
                            .eraseToAnyPublisher()
                    }
                })
                .sink(
                    receiveCompletion: { completion in
                        switch completion {
                        case .failure(let error):
                            // report the error back to the future
                            promise(.failure(error))
                        case .finished:
                            break
                        }
                    },
                    receiveValue: { result in
                        promise(.success((businessOrderId: result.businessOrderId, savedCards: result.paymentMethods)))
                    }
                )
                .store(in: self.cancelBag)
        }
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
    
    func processRealexHPPConsumerData(hppResponse: [String: Any]) -> Future<ShimmedPaymentResponse, Error> {
        
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
                .processRealexHPPConsumerData(orderId: draftOrderId, hppResponse: hppResponse)
                .flatMap({ consumerResponse -> AnyPublisher<ShimmedPaymentResponse, Error> in
                    // if the result has a business order id then clear the basket
                    if consumerResponse.result.businessOrderId != nil {
                        self.draftOrderId = nil
                        return self.clearBasket(passThrough: consumerResponse.result)
                    } else {
                        return Just(consumerResponse.result)
                            .setFailureType(to: Error.self)
                            .eraseToAnyPublisher()
                    }
                })
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
    
    func confirmPayment() -> Future<ConfirmPaymentResponse, Error> {
        
        return Future() { [weak self] promise in
            
            guard let self = self else {
                promise(.failure(CheckoutServiceError.selfError))
                return
            }
            
            guard let draftOrderId = self.draftOrderId else {
                promise(.failure(CheckoutServiceError.draftOrderRequired))
                return
            }
            
            self.webRepository
                .confirmPayment(orderId: draftOrderId)
                .flatMap({ confirmPaymentResponse -> AnyPublisher<ConfirmPaymentResponse, Error> in
                    // if the result has a business order id then clear the basket
                    if confirmPaymentResponse.result.businessOrderId != nil {
                        self.draftOrderId = nil
                        return self.clearBasket(passThrough: confirmPaymentResponse)
                    } else {
                        return Just(confirmPaymentResponse)
                            .setFailureType(to: Error.self)
                            .eraseToAnyPublisher()
                    }
                })
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
            
            self.webRepository
                .verifyPayment(orderId: draftOrderId)
                .flatMap({ confirmPaymentResponse -> AnyPublisher<ConfirmPaymentResponse, Error> in
                    // if the result has a business order id then clear the basket
                    if confirmPaymentResponse.result.businessOrderId != nil {
                        self.draftOrderId = nil
                        return self.clearBasket(passThrough: confirmPaymentResponse)
                    } else {
                        return Just(confirmPaymentResponse)
                            .setFailureType(to: Error.self)
                            .eraseToAnyPublisher()
                    }
                })
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
    
    private func clearBasket<T>(passThrough: T) -> AnyPublisher<T, Error> {
        return dbRepository
            .clearBasket()
            .flatMap { [weak self] _ -> AnyPublisher<T, Error> in
                self?.appState.value.userData.basket = nil
                return Just(passThrough)
                    .setFailureType(to: Error.self)
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
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
    
}

class StubCheckoutService: CheckoutServiceProtocol {

    func createDraftOrder(
        fulfilmentDetails: DraftOrderFulfilmentDetailsRequest,
        paymentGateway: PaymentGatewayType,
        instructions: String?
    ) -> Future<(businessOrderId: Int?, savedCards: DraftOrderPaymentMethods?), Error> {
        return Future { promise in
            promise(.success((businessOrderId: nil, savedCards: nil)))
        }
    }
    
    func getRealexHPPProducerData() -> Future<Data, Error> {
        return Future { promise in
            promise(.success(Data()))
        }
    }
    
    func processRealexHPPConsumerData(hppResponse: [String : Any]) -> Future<ShimmedPaymentResponse, Error> {
        return Future { promise in
            promise(.success(ShimmedPaymentResponse(status: true, message: "String", orderId: nil, businessOrderId: nil, pointsEarned: nil, iterableUserEmail: nil)))
        }
    }
    
    func confirmPayment() -> Future<ConfirmPaymentResponse, Error> {
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
    
}
