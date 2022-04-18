//
//  BasketService.swift
//  SnappyV2
//
//  Created by Kevin Palser on 25/10/2021.
//

import Combine
import Foundation

enum BasketServiceError: Swift.Error {
    case storeSelectionRequired
    case fulfilmentLocationRequired
    case memberRequiredToBeSignedIn
    case unableToPersistResult
    case unableToProceedWithoutBasket // really should never get to this
    case unableToProceedWithoutPostcode // really should never get to this
}

extension BasketServiceError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .storeSelectionRequired:
            return "Ordering location selection is required"
        case .fulfilmentLocationRequired:
            return "Fulfilment location is required"
        case .memberRequiredToBeSignedIn:
            return "function requires member to be signed in"
        case .unableToPersistResult:
            return "Unable to persist web fetch result"
        case .unableToProceedWithoutBasket:
            return "Unable to proceed because of missing basket information"
        case .unableToProceedWithoutPostcode:
            return "Unable to proceed because of missing postcode"
        }
    }
}

protocol BasketServiceProtocol {
    
    // TODO: isFirstOrder logic
    
    // Any of these functions will be placed in a queue and run in serial to ensure that the result of
    // the potentially mutated basket is received and the app has opportunity to react to each response
    // before the next operation.
    
    // When opening the app, we need to restore the basket. This function will load the basket from the
    // persistent store. If there is a basket it will use the token to get the basket from the server to
    // ensure that it still has a menu compatible version.
    func restoreBasket() -> Future<Void, Error>
    
    // Everytime the fulfilment method and/or store changes this method should be called. It is required
    // because the pricing can change, items cleared, deals or coupons have different incompatbile
    // criteria etc
    func updateFulfilmentMethodAndStore() -> Future<Void, Error>
    
    func reserveTimeSlot(timeSlotDate: String, timeSlotTime: String?) -> Future<Void, Error>
    func addItem(item: BasketItemRequest) -> Future<Void, Error>
    func updateItem(item: BasketItemRequest, basketLineId: Int) -> Future<Void, Error>
    func removeItem(basketLineId: Int) -> Future<Void, Error>
    func applyCoupon(code: String) -> Future<Void, Error>
    func removeCoupon() -> Future<Void, Error>
    func clearItems() -> Future<Void, Error>
    func setContactDetails(to: BasketContactDetailsRequest) -> Future<Void, Error>
    func setDeliveryAddress(to: BasketAddressRequest) -> Future<Void, Error>
    func setBillingAddress(to: BasketAddressRequest) -> Future<Void, Error>
    func updateTip(to: Double) -> Future<Void, Error>
    func populateRepeatOrder(businessOrderId: Int) -> Future<Void, Error>
    
    // All the above functions will check if a basket already exists. If a basket does not exist they
    // create a new basket before performing the action. Otherwise they continue by performing the action
    // on the existing basket. The getNewBasket() differs because it explicitly forgets the old basket
    // and fectches a new one. Its intended purpose is after checking out an order.
    func getNewBasket() -> Future<Void, Error>
    
    // Useful during development to add a delay before another operation in queuePublisher
    // in processed
    func test(delay: TimeInterval) -> Future<Void, Error>
    
}

struct BasketService: BasketServiceProtocol {
    
    let webRepository: BasketWebRepositoryProtocol
    let dbRepository: BasketDBRepositoryProtocol
    let notificationService: NotificationServiceProtocol
    
    // Example in the clean architecture Countries exampe of the appState
    // being passed to a service (but not used the code). Using this as
    // a justification to be an acceptable method to update the Basket
    // Henrik/Kevin: 2021-10-26
    let appState: Store<AppState>
    
    let eventLogger: EventLoggerProtocol
    
    indirect enum BasketServiceAction {
        case restoreBasket(promise: (Result<Void, Error>) -> Void)
        case updateFulfilmentMethodAndStore(promise: (Result<Void, Error>) -> Void)
        case reserveTimeSlot(promise: (Result<Void, Error>) -> Void, timeSlotDate: String, timeSlotTime: String?)
        case addItem(promise: (Result<Void, Error>) -> Void, item: BasketItemRequest)
        case updateItem(promise: (Result<Void, Error>) -> Void, basketLineId: Int, item: BasketItemRequest)
        case removeItem(promise: (Result<Void, Error>) -> Void, basketLineId: Int)
        case applyCoupon(promise: (Result<Void, Error>) -> Void, code: String)
        case removeCoupon(promise: (Result<Void, Error>) -> Void)
        case clearItems(promise: (Result<Void, Error>) -> Void)
        case setContactDetails(promise: (Result<Void, Error>) -> Void, details: BasketContactDetailsRequest)
        case setDeliveryAddress(promise: (Result<Void, Error>) -> Void, address: BasketAddressRequest)
        case setBillingAddress(promise: (Result<Void, Error>) -> Void, address: BasketAddressRequest)
        case updateTip(promise: (Result<Void, Error>) -> Void, tip: Double)
        case populateRepeatOrder(promise: (Result<Void, Error>) -> Void, businessOrderId: Int)
        case getNewBasket(promise: (Result<Void, Error>) -> Void)
//        case getBasket(promise: (Result<Void, Error>) -> Void, basketToken: String?, storeId: Int, fulfilmentMethod: RetailStoreOrderMethodType)
        case internalSetBasket(originalAction: BasketServiceAction, basketToken: String?, storeId: Int, fulfilmentMethod: RetailStoreOrderMethodType, fulfilmentLocation: FulfilmentLocation)
        case test(promise: (Result<Void, Error>) -> Void, delay: TimeInterval)
        
        var promise: ((Result<Void, Error>) -> Void)? {
            switch self {
            case let .restoreBasket(promise):
                return promise
            case let .updateFulfilmentMethodAndStore(promise):
                return promise
            case let .reserveTimeSlot(promise, _, _):
                return promise
            case let .updateItem(promise, _, _):
                return promise
            case let .addItem(promise, _):
                return promise
            case let .removeItem(promise, _):
                return promise
            case let .applyCoupon(promise, _):
                return promise
            case let .removeCoupon(promise):
                return promise
            case let .clearItems(promise):
                return promise
            case let .setContactDetails(promise, _):
                return promise
            case let .setDeliveryAddress(promise, _):
                return promise
            case let .setBillingAddress(promise, _):
                return promise
            case let .updateTip(promise, _):
                return promise
            case let .populateRepeatOrder(promise, _):
                return promise
            case let .getNewBasket(promise):
                return promise
//            case let .getBasket(promise, _, _, _):
//                return promise
            case .internalSetBasket:
                return nil
            case let .test(promise, _):
                return promise
            }
        }
        
        var isUpdateFulfilmentMethodAndStore: Bool {
            switch self {
            case .updateFulfilmentMethodAndStore:
                return true
            default:
                return false
            }
        }
        
        var isGetBasket_OR_isRestoreBasket: Bool {
            switch self {
            case /*.getBasket,*/ .restoreBasket, .updateFulfilmentMethodAndStore:
                return true
            default:
                return false
            }
        }
    }
    
    private var cancelBag = CancelBag()
    private var queuePublisher = PassthroughSubject<BasketServiceAction, Never>()

    init(webRepository: BasketWebRepositoryProtocol, dbRepository: BasketDBRepositoryProtocol, appState: Store<AppState>, eventLogger: EventLoggerProtocol, notificationService: NotificationServiceProtocol) {
        self.webRepository = webRepository
        self.dbRepository = dbRepository
        self.appState = appState
        self.eventLogger = eventLogger
		self.notificationService = notificationService
        
        // Use PassthroughSubject to process the basket actions in serial
        queuePublisher
            .buffer(size: Int.max, prefetch: .byRequest, whenFull: .dropOldest)
            // maxPublishers parameter of FlatMap restricting to one creates a back pressure on upstream
            // until the last produced publisher completes. Hence, the objective of having one basket
            // is achieved.
            .flatMap(maxPublishers: .max(1)) { [self] action -> AnyPublisher<Void, Never> in

                var intendedAction: BasketServiceAction = action
                
                let appStateValue = self.appState.value.userData
                
                // capture the values in case they are asynchronous updated following this point
                let basketToken = appStateValue.basket?.basketToken
                let storeId = appStateValue.selectedStore.value?.id
                let fulfilmentMethod = appStateValue.selectedFulfilmentMethod
                
                // cannot continue if we do not already have a basket AND there is sufficient
                // information to generate a basket
                if basketToken == nil && storeId == nil {
                    action.promise?(.failure(BasketServiceError.storeSelectionRequired))
                    return Just(Void()).eraseToAnyPublisher()
                }
                
                // Need to internally set the basket if:
                // (a) selected fulfilment does not match the current basket fulfilment
                // and updateFulfilmentMethodAndStore is not already being called to rectify
                // (b) there is no current basket and this is not a getBasket or restoreBasket
                // action
                
                if let storeId = storeId {

                    var getBasketRequired: Bool = false
                    if let basket = appStateValue.basket {
                        // case a
                        getBasketRequired = fulfilmentMethod != basket.fulfilmentMethod.type && !action.isUpdateFulfilmentMethodAndStore
                    } else {
                        // case b
                        getBasketRequired = !action.isGetBasket_OR_isRestoreBasket
                    }

                    if getBasketRequired {
                        
                        guard let fulfilmentLocation = appStateValue.searchResult.value?.fulfilmentLocation else {
                            action.promise?(.failure(BasketServiceError.fulfilmentLocationRequired))
                            return Just(Void()).eraseToAnyPublisher()
                        }
                        
                        intendedAction = .internalSetBasket(
                            originalAction: action,
                            basketToken: appStateValue.basket?.basketToken,
                            storeId: storeId,
                            fulfilmentMethod: appState.value.userData.selectedFulfilmentMethod,
                            fulfilmentLocation: fulfilmentLocation
                        )
                    }
                }
                
                let future: Future<Void, Never>
                
                switch intendedAction {
                    
                case let .restoreBasket(promise: promise):
                    if let storeId = storeId {
                        if let basketToken = basketToken {
                            // the basket in the persistent store is already loaded
                            future = self.getBasket(
                                promise: promise,
                                basketToken: basketToken,
                                storeId: storeId,
                                fulfilmentMethod: fulfilmentMethod,
                                fulfilmentLocation: nil
                            )
                        } else {
                            // fetch the basket from the persistent store
                            future = self.restoreSavedBasket(
                                promise: promise,
                                storeId: storeId
                            )
                        }
                    } else {
                        action.promise?(.failure(BasketServiceError.storeSelectionRequired))
                        return Just(Void()).eraseToAnyPublisher()
                    }
                    
                case let .updateFulfilmentMethodAndStore(promise: promise):
                    guard let fulfilmentLocation = appStateValue.searchResult.value?.fulfilmentLocation else {
                        action.promise?(.failure(BasketServiceError.fulfilmentLocationRequired))
                        return Just(Void()).eraseToAnyPublisher()
                    }
                    guard let storeId = storeId else {
                        action.promise?(.failure(BasketServiceError.storeSelectionRequired))
                        return Just(Void()).eraseToAnyPublisher()
                    }
                    future = self.getBasket(
                        promise: promise,
                        basketToken: basketToken,
                        storeId: storeId,
                        fulfilmentMethod: fulfilmentMethod,
                        fulfilmentLocation: fulfilmentLocation
                    )

                case let .reserveTimeSlot(promise: promise, timeSlotDate: timeSlotDate, timeSlotTime: timeSlotTime):
                    guard let storeId = storeId else {
                        action.promise?(.failure(BasketServiceError.storeSelectionRequired))
                        return Just(Void()).eraseToAnyPublisher()
                    }
                    guard let basketToken = basketToken else {
                        action.promise?(.failure(BasketServiceError.unableToProceedWithoutBasket))
                        return Just(Void()).eraseToAnyPublisher()
                    }
                    guard let postcode = appStateValue.selectedStore.value?.searchPostcode else {
                        action.promise?(.failure(BasketServiceError.unableToProceedWithoutPostcode))
                        return Just(Void()).eraseToAnyPublisher()
                    }
                    future = self.reserveTimeSlot(
                        promise: promise,
                        basketToken: basketToken,
                        storeId: storeId,
                        fulfilmentMethod: fulfilmentMethod,
                        postcode: postcode,
                        timeSlotDate: timeSlotDate,
                        timeSlotTime: timeSlotTime
                    )
                    
                case let .addItem(promise, item):
                    if let basketToken = basketToken {
                        future = self.addItem(
                            promise: promise,
                            basketToken: basketToken,
                            item: item,
                            fulfilmentMethod: fulfilmentMethod
                        )
                    } else {
                        action.promise?(.failure(BasketServiceError.unableToProceedWithoutBasket))
                        return Just(Void()).eraseToAnyPublisher()
                    }
                    
                case let .updateItem(promise, basketLineId, item):
                    if let basketToken = basketToken {
                        future = self.updateItem(
                            promise: promise,
                            basketToken: basketToken,
                            basketLineId: basketLineId,
                            item: item
                        )
                    } else {
                        action.promise?(.failure(BasketServiceError.unableToProceedWithoutBasket))
                        return Just(Void()).eraseToAnyPublisher()
                    }
                    
                case let .removeItem(promise: promise, basketLineId):
                    if let basketToken = basketToken {
                        future = self.removeItem(promise: promise, basketToken: basketToken, basketLineId: basketLineId)
                    } else {
                        action.promise?(.failure(BasketServiceError.unableToProceedWithoutBasket))
                        return Just(Void()).eraseToAnyPublisher()
                    }
                    
                case let .applyCoupon(promise, code):
                    if let basketToken = basketToken {
                        future = self.applyCoupon(promise: promise, basketToken: basketToken, code: code)
                    } else {
                        action.promise?(.failure(BasketServiceError.unableToProceedWithoutBasket))
                        return Just(Void()).eraseToAnyPublisher()
                    }
                    
                case let .removeCoupon(promise):
                    if let basketToken = basketToken {
                        future = self.removeCoupon(promise: promise, basketToken: basketToken)
                    } else {
                        action.promise?(.failure(BasketServiceError.unableToProceedWithoutBasket))
                        return Just(Void()).eraseToAnyPublisher()
                    }
                    
                case let .clearItems(promise):
                    if let basketToken = basketToken {
                        future = self.clearItems(promise: promise, basketToken: basketToken)
                    } else {
                        action.promise?(.failure(BasketServiceError.unableToProceedWithoutBasket))
                        return Just(Void()).eraseToAnyPublisher()
                    }
                    
                case let .setContactDetails(promise, details):
                    if let basketToken = basketToken {
                        future = self.setContactDetails(promise: promise, basketToken: basketToken, details: details)
                    } else {
                        action.promise?(.failure(BasketServiceError.unableToProceedWithoutBasket))
                        return Just(Void()).eraseToAnyPublisher()
                    }
                    
                case let .setDeliveryAddress(promise, address):
                    if let basketToken = basketToken {
                        future = self.setDeliveryAddress(promise: promise, basketToken: basketToken, address: address)
                    } else {
                        action.promise?(.failure(BasketServiceError.unableToProceedWithoutBasket))
                        return Just(Void()).eraseToAnyPublisher()
                    }
                    
                case let .setBillingAddress(promise, address):
                    if let basketToken = basketToken {
                        future = self.setBillingAddress(promise: promise, basketToken: basketToken, address: address)
                    } else {
                        action.promise?(.failure(BasketServiceError.unableToProceedWithoutBasket))
                        return Just(Void()).eraseToAnyPublisher()
                    }
                    
                case let .updateTip(promise, tip):
                    if let basketToken = basketToken {
                        future = self.updateTip(promise: promise, basketToken: basketToken, tip: tip)
                    } else {
                        action.promise?(.failure(BasketServiceError.unableToProceedWithoutBasket))
                        return Just(Void()).eraseToAnyPublisher()
                    }
                    
                case let .populateRepeatOrder(promise, businessOrderId):
                    // baskets can only be populated with past orders if the customer is signed in
                    if appState.value.userData.memberProfile == nil {
                        promise(.failure(BasketServiceError.memberRequiredToBeSignedIn))
                        return Just(Void()).eraseToAnyPublisher()
                    }
                    if let basketToken = basketToken {
                        future = self.populateRepeatOrder(
                            promise: promise,
                            basketToken: basketToken,
                            businessOrderId: businessOrderId,
                            fulfilmentMethod: fulfilmentMethod
                        )
                    } else {
                        action.promise?(.failure(BasketServiceError.unableToProceedWithoutBasket))
                        return Just(Void()).eraseToAnyPublisher()
                    }
                    
                case let .getNewBasket(promise: promise):
                    guard let fulfilmentLocation = appStateValue.searchResult.value?.fulfilmentLocation else {
                        action.promise?(.failure(BasketServiceError.fulfilmentLocationRequired))
                        return Just(Void()).eraseToAnyPublisher()
                    }
                    guard let storeId = storeId else {
                        action.promise?(.failure(BasketServiceError.storeSelectionRequired))
                        return Just(Void()).eraseToAnyPublisher()
                    }

                    future = self.getBasket(
                        promise: promise,
                        basketToken: nil, // force a new basket
                        storeId: storeId,
                        fulfilmentMethod: fulfilmentMethod,
                        fulfilmentLocation: fulfilmentLocation
                    )
                    
//                case let .getBasket(promise, basketToken, storeId, fulfilmentMethod):
//                    future = self.getBasket(
//                        promise: promise,
//                        basketToken: basketToken,
//                        storeId: storeId,
//                        fulfilmentMethod: fulfilmentMethod
//                    )
                    
                case let .internalSetBasket(originalAction, basketToken, storeId, fulfilmentMethod, fulfilmentLocation):
                    future = self.internalSetBasket(
                        originalAction: originalAction,
                        basketToken: basketToken,
                        storeId: storeId,
                        fulfilmentMethod: fulfilmentMethod,
                        fulfilmentLocation: fulfilmentLocation
                    )
                    
                case let .test(promise, delay):
                    future = self.simulateOperation(withDelay: delay, promise: promise)
                }
                
                return future.eraseToAnyPublisher()

            }
            .sink { print("Complete: \(Date())") }
            .store(in: cancelBag)
    }
    
    private func addItem(promise: @escaping (Result<Void, Error>) -> Void, basketToken: String, item: BasketItemRequest, fulfilmentMethod: RetailStoreOrderMethodType) -> Future<Void, Never> {
        Future() { internalPromise in
            processBasketOutcome(
                webPublisher: webRepository.addItem(basketToken: basketToken, item: item, fulfilmentMethod: fulfilmentMethod),
                promise: promise,
                internalPromise: internalPromise
            )
        }
    }
    
    private func updateItem(promise: @escaping (Result<Void, Error>) -> Void, basketToken: String, basketLineId: Int, item: BasketItemRequest) -> Future<Void, Never> {
        Future() { internalPromise in
            processBasketOutcome(
                webPublisher: webRepository.updateItem(basketToken: basketToken, basketLineId: basketLineId, item: item),
                promise: promise,
                internalPromise: internalPromise
            )
        }
    }
    
    private func removeItem(promise: @escaping (Result<Void, Error>) -> Void, basketToken: String, basketLineId: Int) -> Future<Void, Never> {
        Future() { internalPromise in
            processBasketOutcome(
                webPublisher: webRepository.removeItem(basketToken: basketToken, basketLineId: basketLineId),
                promise: promise,
                internalPromise: internalPromise
            )
        }
    }
    
    private func applyCoupon(promise: @escaping (Result<Void, Error>) -> Void, basketToken: String, code: String) -> Future<Void, Never> {
        Future() { internalPromise in
            processBasketOutcome(
                webPublisher: webRepository.applyCoupon(basketToken: basketToken, code: code),
                promise: promise,
                internalPromise: internalPromise
            )
        }
    }
    
    private func removeCoupon(promise: @escaping (Result<Void, Error>) -> Void, basketToken: String) -> Future<Void, Never> {
        Future() { internalPromise in
            processBasketOutcome(
                webPublisher: webRepository.removeCoupon(basketToken: basketToken),
                promise: promise,
                internalPromise: internalPromise
            )
        }
    }
    
    private func clearItems(promise: @escaping (Result<Void, Error>) -> Void, basketToken: String) -> Future<Void, Never> {
        Future() { internalPromise in
            processBasketOutcome(
                webPublisher: webRepository.clearItems(basketToken: basketToken),
                promise: promise,
                internalPromise: internalPromise
            )
        }
    }
    
    private func setContactDetails(promise: @escaping (Result<Void, Error>) -> Void, basketToken: String, details: BasketContactDetailsRequest) -> Future<Void, Never>  {
        Future() { internalPromise in
            processBasketOutcome(
                webPublisher: webRepository.setContactDetails(basketToken: basketToken, details: details),
                promise: promise,
                internalPromise: internalPromise
            )
        }
    }
    
    private func setDeliveryAddress(promise: @escaping (Result<Void, Error>) -> Void, basketToken: String, address: BasketAddressRequest) -> Future<Void, Never> {
        Future() { internalPromise in
            processBasketOutcome(
                webPublisher: webRepository.setDeliveryAddress(basketToken: basketToken, address: address),
                promise: promise,
                internalPromise: internalPromise
            )
        }
    }
    
    private func setBillingAddress(promise: @escaping (Result<Void, Error>) -> Void, basketToken: String, address: BasketAddressRequest) -> Future<Void, Never> {
        Future() { internalPromise in
            processBasketOutcome(
                webPublisher: webRepository.setBillingAddress(basketToken: basketToken, address: address),
                promise: promise,
                internalPromise: internalPromise
            )
        }
    }
    
    private func updateTip(promise: @escaping (Result<Void, Error>) -> Void, basketToken: String, tip: Double) -> Future<Void, Never> {
        Future() { internalPromise in
            processBasketOutcome(
                webPublisher: webRepository.updateTip(basketToken: basketToken, tip: tip),
                promise: promise,
                internalPromise: internalPromise
            )
        }
    }
    
    private func populateRepeatOrder(promise: @escaping (Result<Void, Error>) -> Void, basketToken: String, businessOrderId: Int, fulfilmentMethod: RetailStoreOrderMethodType) -> Future<Void, Never> {
        Future() { internalPromise in
            processBasketOutcome(
                webPublisher: webRepository.populateRepeatOrder(
                    basketToken: basketToken,
                    businessOrderId: businessOrderId,
                    fulfilmentMethod: fulfilmentMethod
                ),
                promise: promise,
                internalPromise: internalPromise
            )
        }
    }
    
    private func reserveTimeSlot(
        promise: @escaping (Result<Void, Error>) -> Void,
        basketToken: String,
        storeId: Int,
        fulfilmentMethod: RetailStoreOrderMethodType,
        postcode: String,
        timeSlotDate: String,
        timeSlotTime: String?
    ) -> Future<Void, Never> {
        Future() { internalPromise in

            processBasketOutcome(
                webPublisher: webRepository.reserveTimeSlot(
                    basketToken: basketToken,
                    storeId: storeId,
                    timeSlotDate: timeSlotDate,
                    timeSlotTime: timeSlotTime,
                    postcode: postcode,
                    fulfilmentMethod: fulfilmentMethod
                ),
                promise: promise,
                internalPromise: internalPromise
            )
            
        }
    }
    
    private func getBasket(promise: @escaping (Result<Void, Error>) -> Void, basketToken: String?, storeId: Int, fulfilmentMethod: RetailStoreOrderMethodType, fulfilmentLocation: FulfilmentLocation?) -> Future<Void, Never> {
        Future() { internalPromise in

            processBasketOutcome(
                webPublisher: webRepository.getBasket(
                    basketToken: basketToken,
                    storeId: storeId,
                    fulfilmentMethod: fulfilmentMethod,
                    fulfilmentLocation: fulfilmentLocation,
                    isFirstOrder: true
                ),
                promise: promise,
                internalPromise: internalPromise
            )
            
        }
    }
    
    private func restoreSavedBasket(promise: @escaping (Result<Void, Error>) -> Void, storeId: Int) -> Future<Void, Never> {
        Future() { internalPromise in

            dbRepository
                .fetchBasket()
                .flatMap({ basket -> AnyPublisher<Bool, Error> in
                    if let basket = basket {
                        // place the basket in the app state now in case the API
                        // fetch fails to save fetching from the persistent store
                        // when retrying
                        appState.value.userData.basket = basket
                        // save the fetched basket
                        return webRepository.getBasket(
                            basketToken: basket.basketToken,
                            storeId: storeId,
                            fulfilmentMethod: basket.fulfilmentMethod.type,
                            fulfilmentLocation: nil,
                            isFirstOrder: true
                        ).flatMap { basket -> AnyPublisher<Bool, Error> in
                            // no basket was saved so stop here
                            return storeBasketAndUpdateAppstate(fetchedBasket: basket)
                        }.eraseToAnyPublisher()
                    } else {
                        // no basket was saved so stop here
                        return Just(true)
                            .setFailureType(to: Error.self)
                            .eraseToAnyPublisher()
                    }
                })
                .sink(
                    receiveCompletion: { completion in

                        // Only seems to get here if there is an error, e.g. changing getBasket(..) implementation to
                        // return Fail<Basket, Error>(error: BasketServiceError.storeSelectionRequired).eraseToAnyPublisher()

                        switch completion {

                        case .failure(let error):
                            // report the error back to the original future
                            promise(.failure(error))

                        case .finished:
                            // re-queue this request for after the change
                            promise(.success(()))

                        }

                        // finish this queue action so that the next can start
                        internalPromise(.success(()))

                    }, receiveValue: { _ in
                        // no value expected - flatmap has already handled
                        // persistent storage and updating the app state

                        // However, the following are required because it does not
                        // reach the above on a finished state

                        promise(.success(()))
                        internalPromise(.success(()))
                    }
                )
                .store(in: cancelBag)
        }
    }
    
    private func processBasketOutcome(
        webPublisher: AnyPublisher<Basket, Error>,
        promise: @escaping (Result<Void, Error>) -> Void,
        internalPromise: @escaping (Result<Void, Never>) -> Void
    ) {
        webPublisher
            .flatMap({ basket -> AnyPublisher<Bool, Error> in
                return storeBasketAndUpdateAppstate(fetchedBasket: basket)
            })
            .sink(
                receiveCompletion: { completion in

                    // Only seems to get here if there is an error
                    
                    switch completion {

                    case .failure(let error):
                        // report the error back to the original future
                        promise(.failure(error))

                    case .finished:
                        promise(.success(()))
                    }

                    // finish this queue action so that the next can start
                    internalPromise(.success(()))
                }, receiveValue: { _ in
                    // no value expected - flatmap has already handled
                    // persistent storage and updating the app state
                    
                    // However, the following are required because it does not
                    // reach the above on a finished state
                    
                    promise(.success(()))
                    internalPromise(.success(()))
                }
            )
            .store(in: cancelBag)
    }
    
    private func internalSetBasket(
        originalAction: BasketServiceAction,
        basketToken: String?,
        storeId: Int,
        fulfilmentMethod: RetailStoreOrderMethodType,
        fulfilmentLocation: FulfilmentLocation
    ) -> Future<Void, Never> {
        Future() { internalPromise in

            webRepository
                .getBasket(
                    basketToken: basketToken,
                    storeId: storeId,
                    fulfilmentMethod: fulfilmentMethod,
                    fulfilmentLocation: fulfilmentLocation,
                    isFirstOrder: true
                )
                .flatMap({ basket -> AnyPublisher<Bool, Error> in
                    return storeBasketAndUpdateAppstate(fetchedBasket: basket)
                })
                .sink(
                    receiveCompletion: { completion in

                        // Only seems to get here if there is an error, e.g. changing getBasket(..) implementation to
                        // return Fail<Basket, Error>(error: BasketServiceError.storeSelectionRequired).eraseToAnyPublisher()
                        
                        switch completion {

                        case .failure(let error):
                            // report the error back to the original future
                            originalAction.promise?(.failure(error))

                        case .finished:
                            // re-queue this request for after the change
                            self.queuePublisher.send(originalAction)

                        }

                        // finish this queue action so that the next can start
                        internalPromise(.success(()))
                        
                    }, receiveValue: { _ in
                        // no value expected - flatmap has already handled
                        // persistent storage and updating the app state
                        
                        // However, the following are required because it does not
                        // reach the above on a finished state
                        
                        self.queuePublisher.send(originalAction)
                        internalPromise(.success(()))
                    }
                )
                .store(in: cancelBag)

        }
    }
    
    private func simulateOperation(withDelay delay: TimeInterval, promise: @escaping (Result<Void, Error>) -> Void) -> Future<Void, Never> {
        Future() { internalPromise in
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                promise(.success(()))
                internalPromise(.success(()))
            }

        }
    }
    
    private func storeBasketAndUpdateAppstate(fetchedBasket: Basket) -> AnyPublisher<Bool, Error> {
        dbRepository
            .clearBasket()
            .flatMap { _ -> AnyPublisher<Bool, Error> in
                dbRepository.store(basket: fetchedBasket)
                    .flatMap { basket -> AnyPublisher<Bool, Error> in
                        // update the basket app state for the subscribers
                        self.appState.value.userData.basket = basket
                        return Just(true)
                            .setFailureType(to: Error.self)
                            .eraseToAnyPublisher()
                    }
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
    
    private var requestHoldBackTimeInterval: TimeInterval {
        ProcessInfo.processInfo.isRunningTests ? 0 : 0.5
    }
    
    // Protocol Functions
    
    func restoreBasket() -> Future<Void, Error> {
        Future { promise in
            self.queuePublisher.send(.restoreBasket(promise: promise))
        }
    }
    
    func updateFulfilmentMethodAndStore() -> Future<Void, Error> {
        Future { promise in
            self.queuePublisher.send(.updateFulfilmentMethodAndStore(promise: promise))
        }
    }
    
    func reserveTimeSlot(timeSlotDate: String, timeSlotTime: String?) -> Future<Void, Error> {
        Future { promise in
            self.queuePublisher.send(
                .reserveTimeSlot(
                    promise: promise,
                    timeSlotDate: timeSlotDate,
                    timeSlotTime: timeSlotTime
                )
            )
        }
    }
    
    func addItem(item: BasketItemRequest) -> Future<Void, Error> {
        Future { promise in
            self.queuePublisher.send(.addItem(promise: promise, item: item))
        }
    }
    
    func updateItem(item: BasketItemRequest, basketLineId: Int) -> Future<Void, Error> {
        Future { promise in
            self.queuePublisher.send(.updateItem(promise: promise, basketLineId: basketLineId, item: item))
        }
    }
    
    func removeItem(basketLineId: Int) -> Future<Void, Error> {
        Future { promise in
            self.queuePublisher.send(.removeItem(promise: promise, basketLineId: basketLineId))
        }
    }
    
    func applyCoupon(code: String) -> Future<Void, Error> {
        Future { promise in
            self.queuePublisher.send(.applyCoupon(promise: promise, code: code))
        }
    }
    
    func removeCoupon() -> Future<Void, Error> {
        Future { promise in
            self.queuePublisher.send(.removeCoupon(promise: promise))
        }
    }
    
    func clearItems() -> Future<Void, Error> {
        Future { promise in
            self.queuePublisher.send(.clearItems(promise: promise))
        }
    }
    
    func setContactDetails(to details: BasketContactDetailsRequest) -> Future<Void, Error> {
        Future { promise in
            self.queuePublisher.send(.setContactDetails(promise: promise, details: details))
        }
    }
    
    func setDeliveryAddress(to address: BasketAddressRequest) -> Future<Void, Error> {
        Future { promise in
            self.queuePublisher.send(.setDeliveryAddress(promise: promise, address: address))
        }
    }
    
    func setBillingAddress(to address: BasketAddressRequest) -> Future<Void, Error> {
        Future { promise in
            self.queuePublisher.send(.setBillingAddress(promise: promise, address: address))
        }
    }
    
    func updateTip(to value: Double) -> Future<Void, Error> {
        Future { promise in
            self.queuePublisher.send(.updateTip(promise: promise, tip: value))
        }
    }
    
    func populateRepeatOrder(businessOrderId: Int) -> Future<Void, Error> {
        Future { promise in
            self.queuePublisher.send(.populateRepeatOrder(promise: promise, businessOrderId: businessOrderId))
        }
    }
    
    func getNewBasket() -> Future<Void, Error> {
        Future { promise in
            self.queuePublisher.send(.getNewBasket(promise: promise))
        }
    }
    
    func test(delay: TimeInterval) -> Future<Void, Error> {
        Future { promise in
            self.queuePublisher.send(.test(promise: promise, delay: delay))
        }
    }
    
}

struct StubBasketService: BasketServiceProtocol {

    func restoreBasket() -> Future<Void, Error> {
        stubFuture()
    }

    func updateFulfilmentMethodAndStore() -> Future<Void, Error> {
        stubFuture()
    }
    
    func reserveTimeSlot(timeSlotDate: String, timeSlotTime: String?) -> Future<Void, Error> {
        stubFuture()
    }
    
    func addItem(item: BasketItemRequest) -> Future<Void, Error> {
        stubFuture()
    }
    
    func updateItem(item: BasketItemRequest, basketLineId: Int) -> Future<Void, Error> {
        stubFuture()
    }
    
    func removeItem(basketLineId: Int) -> Future<Void, Error> {
        stubFuture()
    }
    
    func applyCoupon(code: String) -> Future<Void, Error> {
        stubFuture()
    }
    
    func removeCoupon() -> Future<Void, Error> {
        stubFuture()
    }
    
    func clearItems() -> Future<Void, Error> {
        stubFuture()
    }
    
    func setContactDetails(to: BasketContactDetailsRequest) -> Future<Void, Error> {
        stubFuture()
    }
    
    func setDeliveryAddress(to: BasketAddressRequest) -> Future<Void, Error> {
        stubFuture()
    }
    
    func setBillingAddress(to: BasketAddressRequest) -> Future<Void, Error> {
        stubFuture()
    }
    
    func updateTip(to: Double) -> Future<Void, Error> {
        stubFuture()
    }
    
    func populateRepeatOrder(businessOrderId: Int) -> Future<Void, Error> {
        stubFuture()
    }
    
    func getNewBasket() -> Future<Void, Error> {
        stubFuture()
    }
    
    func test(delay: TimeInterval) -> Future<Void, Error> {
        stubFuture()
    }
    
    private func stubFuture() -> Future<Void, Error> {
        Future { promise in
            promise(.success(()))
        }
    }
    
}
