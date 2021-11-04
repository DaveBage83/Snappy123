//
//  BasketService.swift
//  SnappyV2
//
//  Created by Kevin Palser on 25/10/2021.
//

import Combine
import Foundation

enum BasketServiceError: Swift.Error {
    case storeOrFulfilmentSelectionRequired
    case unableToPersistResult
    case unableToProceedWithoutBasket // really should never get to this
}

extension BasketServiceError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .storeOrFulfilmentSelectionRequired:
            return "Ordering location and fulfilment method selections are required"
        case .unableToPersistResult:
            return "Unable to persist web fetch result"
        case .unableToProceedWithoutBasket:
            return "Unable to proceed because of missing basket information"
        }
    }
}

//enum BasketUpdateState {
//    acheived
//    notAcheived
//}

protocol BasketServiceProtocol {
    
    // TODO: isFirstOrder logic
    
    /*
    // Anything that could mutate the basket should be queued so that the previous result succeds or fails
    // Do we return a loadable Basket or do we have some form of general subscription
    func addItem(..., item: ItemModel, storeId: Int) // storeId could be from AppState?
    func removeItem(..., basketLineId: Int) // success or not
    func updateBasketLineQuantity(..., basketLineId: Int, quantity: Int) // success or not
    func getBasket(..., storeId: Int, fulfilmentMethod: FulfilmentMethod) // success or not
    func applyCoupon(..., code: String) // success or not
    func removeCoupon(...) // success or not
    func clearBasket(...) // success or not
    */
    
    // Any of these functions will be placed in a queue and run in serial to ensure that the result of
    // the potentially mutated basket is received and the app has opportunity to react to each response
    // before the next operation.
    
    func addItem(item: BasketItemRequest) -> Future<Bool, Error>
    func removeItem(basketLineId: Int) -> Future<Bool, Error>
    func applyCoupon(code: String) -> Future<Bool, Error>
    func removeCoupon() -> Future<Bool, Error>
    
}

struct BasketService: BasketServiceProtocol {

    let webRepository: BasketWebRepositoryProtocol
    let dbRepository: BasketDBRepositoryProtocol
    
    // Example in the clean architecture Countries exampe of the appState
    // being passed to a service (but not used the code). Using this as
    // a justification to be an acceptable method to update the Basket
    // Henrik/Kevin: 2021-10-26
    let appState: Store<AppState>
    
    indirect enum BasketServiceAction {
        case addItem(promise: (Result<Bool, Error>) -> Void, item: BasketItemRequest)
        case removeItem(promise: (Result<Bool, Error>) -> Void, basketLineId: Int)
        case applyCoupon(promise: (Result<Bool, Error>) -> Void, code: String)
        case removeCoupon(promise: (Result<Bool, Error>) -> Void)
        case getBasket(promise: (Result<Bool, Error>) -> Void, basketToken: String?, storeId: Int, fulfilmentMethod: FulfilmentMethod)
        case internalSetBasket(originalAction: BasketServiceAction, basketToken: String?, storeId: Int, fulfilmentMethod: FulfilmentMethod)
        
        var promise: ((Result<Bool, Error>) -> Void)? {
            switch self {
            case let .addItem(promise, _):
                return promise
            case let .removeItem(promise, _):
                return promise
            case let .applyCoupon(promise, _):
                return promise
            case let .removeCoupon(promise):
                return promise
            case let .getBasket(promise, _, _, _):
                return promise
            case .internalSetBasket:
                return nil
            }
        }
        
        var isGetBasket: Bool {
            switch self {
            case .getBasket:
                return true
            default:
                return false
            }
        }
    }
    
    private var cancelBag = CancelBag()
    private var queuePublisher = PassthroughSubject<BasketServiceAction, Never>()

    init(webRepository: BasketWebRepositoryProtocol, dbRepository: BasketDBRepositoryProtocol, appState: Store<AppState>) {
        self.webRepository = webRepository
        self.dbRepository = dbRepository
        self.appState = appState
        
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
                let storeId = appStateValue.selectedStoreId
                let fulfilmentMethod = appStateValue.selectedFulFilmentMethod
                
                // cannot continue if we do not already have a basket AND there is sufficient
                // information to generate a basket
                if basketToken == nil && (storeId == nil || fulfilmentMethod == nil) {
                    action.promise?(.failure(BasketServiceError.storeOrFulfilmentSelectionRequired))
                    return Empty<Void, Never>(completeImmediately: true).eraseToAnyPublisher()
                }
                
                // Need to internally set the basket if:
                // (a) selected fulfilment does not match the current basket fulfilment, or
                // (b) there is no current basket and this is not a getBasket action
                
                if
                    let fulfilmentMethod = fulfilmentMethod,
                    let storeId = storeId
                {
                    var getBasketRequired: Bool = false
                    if let basket = appStateValue.basket {
                        // case a
                        getBasketRequired = fulfilmentMethod != basket.fulfilmentMethod.type
                    } else if action.isGetBasket == false {
                        // case b
                        getBasketRequired = true
                    }
                    
                    if getBasketRequired {
                        intendedAction = .internalSetBasket(
                            originalAction: action,
                            basketToken: appStateValue.basket?.basketToken,
                            storeId: storeId,
                            fulfilmentMethod: .delivery
                        )
                    }
                }
                
                let future: Future<Void, Never>
                
                switch intendedAction {
                    
                case let .addItem(promise, item):
                    if let basketToken = basketToken {
                        future = self.addItem(promise: promise, basketToken: basketToken, item: item, fulfilmentMethod: fulfilmentMethod ?? .delivery)
                    } else {
                        action.promise?(.failure(BasketServiceError.unableToProceedWithoutBasket))
                        return Empty<Void, Never>(completeImmediately: true).eraseToAnyPublisher()
                    }
                    
                case let .removeItem(promise: promise, basketLineId):
                    if let basketToken = basketToken {
                        future = self.removeItem(promise: promise, basketToken: basketToken, basketLineId: basketLineId)
                    } else {
                        action.promise?(.failure(BasketServiceError.unableToProceedWithoutBasket))
                        return Empty<Void, Never>(completeImmediately: true).eraseToAnyPublisher()
                    }
                    
                case let .applyCoupon(promise, code):
                    if let basketToken = basketToken {
                        future = self.applyCoupon(promise: promise, basketToken: basketToken, code: code)
                    } else {
                        action.promise?(.failure(BasketServiceError.unableToProceedWithoutBasket))
                        return Empty<Void, Never>(completeImmediately: true).eraseToAnyPublisher()
                    }
                    
                case .removeCoupon(promise: let promise):
                    if let basketToken = basketToken {
                        future = self.removeCoupon(promise: promise, basketToken: basketToken)
                    } else {
                        action.promise?(.failure(BasketServiceError.unableToProceedWithoutBasket))
                        return Empty<Void, Never>(completeImmediately: true).eraseToAnyPublisher()
                    }
                    
                case let .getBasket(promise, basketToken, storeId, fulfilmentMethod):
                    future = self.getBasket(
                        promise: promise,
                        basketToken: basketToken,
                        storeId: storeId,
                        fulfilmentMethod: fulfilmentMethod
                    )
                    
                case let .internalSetBasket(originalAction, basketToken, storeId, fulfilmentMethod):
                    future = self.internalSetBasket(
                        originalAction: originalAction,
                        basketToken: basketToken,
                        storeId: storeId,
                        fulfilmentMethod: fulfilmentMethod
                    )

                }
                
                return future.eraseToAnyPublisher()

            }
            .sink { print("Complete: \(Date())") }
            .store(in: cancelBag)
    }
    
    private func addItem(promise: @escaping (Result<Bool, Error>) -> Void, basketToken: String, item: BasketItemRequest, fulfilmentMethod: FulfilmentMethod) -> Future<Void, Never> {
        return Future() { internalPromise in

            processBasketOutcome(
                webPublisher: webRepository.addItem(basketToken: basketToken, item: item, fulfilmentMethod: fulfilmentMethod),
                promise: promise,
                internalPromise: internalPromise
            )
            
        }
    }
    
    private func removeItem(promise: @escaping (Result<Bool, Error>) -> Void, basketToken: String, basketLineId: Int) -> Future<Void, Never> {
        return Future() { internalPromise in

            processBasketOutcome(
                webPublisher: webRepository.removeItem(basketToken: basketToken, basketLineId: basketLineId),
                promise: promise,
                internalPromise: internalPromise
            )
            
        }
    }
    
    private func applyCoupon(promise: @escaping (Result<Bool, Error>) -> Void, basketToken: String, code: String) -> Future<Void, Never> {
        return Future() { internalPromise in

            processBasketOutcome(
                webPublisher: webRepository.applyCoupon(basketToken: basketToken, code: code),
                promise: promise,
                internalPromise: internalPromise
            )
        }
    }
    
    private func removeCoupon(promise: @escaping (Result<Bool, Error>) -> Void, basketToken: String) -> Future<Void, Never> {
        return Future() { internalPromise in
            
            processBasketOutcome(
                webPublisher: webRepository.removeCoupon(basketToken: basketToken),
                promise: promise,
                internalPromise: internalPromise
            )
            
        }
    }
    
    private func getBasket(promise: @escaping (Result<Bool, Error>) -> Void, basketToken: String?, storeId: Int, fulfilmentMethod: FulfilmentMethod) -> Future<Void, Never> {
        return Future() { internalPromise in

            processBasketOutcome(
                webPublisher: webRepository.getBasket(basketToken: basketToken, storeId: storeId, fulfilmentMethod: fulfilmentMethod, isFirstOrder: true),
                promise: promise,
                internalPromise: internalPromise
            )
            
        }
    }
    
    private func processBasketOutcome(
        webPublisher: AnyPublisher<Basket, Error>,
        promise: @escaping (Result<Bool, Error>) -> Void,
        internalPromise: @escaping (Result<Void, Never>) -> Void
    ) {
        webPublisher
            .flatMap({ basket -> AnyPublisher<Void, Error> in
                return storeBasketAndUpdateAppstate(fetchedBasket: basket)
            })
            .sink(
                receiveCompletion: { completion in

                    switch completion {

                    case .failure(let error):
                        // report the error back to the original future
                        promise(.failure(error))

                    case .finished:
                        promise(.success(true))
                    }

                    // finish this queue action so that the next can start
                    internalPromise(.success(()))
                }, receiveValue: {
                    // no value expected - flatmap has already handled
                    // persistent storage and updating the app state
                }
            )
            .store(in: cancelBag)
    }
    
    private func internalSetBasket(originalAction: BasketServiceAction, basketToken: String?, storeId: Int, fulfilmentMethod: FulfilmentMethod) -> Future<Void, Never> {
        return Future() { internalPromise in

            webRepository
                .getBasket(basketToken: basketToken, storeId: storeId, fulfilmentMethod: fulfilmentMethod, isFirstOrder: true)
                .flatMap({ basket -> AnyPublisher<Void, Error> in
                    return storeBasketAndUpdateAppstate(fetchedBasket: basket)
                })
                .sink(
                    receiveCompletion: { completion in

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
                    }, receiveValue: {
                        // no value expected - flatmap has already handled
                        // persistent storage and updating the app state
                    }
                )
                .store(in: cancelBag)

        }
    }
    
    private func simulateOperation(withDelay delay: TimeInterval, promise: @escaping (Result<Bool, Error>) -> Void) -> Future<Void, Never> {
        return Future() { internalPromise in
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                promise(.success(true))
                internalPromise(.success(()))
            }

        }
    }
    
    private func storeBasketAndUpdateAppstate(fetchedBasket: Basket) -> AnyPublisher<Void, Error> {
        return dbRepository
            .clearBasket()
            .flatMap { _ -> AnyPublisher<Void, Error> in
                dbRepository.store(basket: fetchedBasket)
                    .flatMap { basket -> AnyPublisher<Void, Error> in
                        // update the basket app state for the subscribers
                        self.appState.value.userData.basket = basket
                        return Empty<Void, Error>(completeImmediately: true)
                            .eraseToAnyPublisher()
                    }
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
    
    private var requestHoldBackTimeInterval: TimeInterval {
        return ProcessInfo.processInfo.isRunningTests ? 0 : 0.5
    }
    
    // Protocol Functions
    
    func addItem(item: BasketItemRequest) -> Future<Bool, Error> {
        return Future { promise in
            self.queuePublisher.send(.addItem(promise: promise, item: item))
        }
    }
    
    func removeItem(basketLineId: Int) -> Future<Bool, Error> {
        return Future { promise in
            self.queuePublisher.send(.removeItem(promise: promise, basketLineId: basketLineId))
        }
    }
    
    func applyCoupon(code: String) -> Future<Bool, Error> {
        return Future { promise in
            self.queuePublisher.send(.applyCoupon(promise: promise, code: code))
        }
    }
    
    func removeCoupon() -> Future<Bool, Error> {
        return Future { promise in
            self.queuePublisher.send(.removeCoupon(promise: promise))
        }
    }
    
}

struct StubBasketService: BasketServiceProtocol {

    func addItem(item: BasketItemRequest) -> Future<Bool, Error> {
        return Future { promise in
            promise(.success(true))
        }
    }
    
    func removeItem(basketLineId: Int) -> Future<Bool, Error> {
        return Future { promise in
            promise(.success(true))
        }
    }
    
    func applyCoupon(code: String) -> Future<Bool, Error> {
        return Future { promise in
            promise(.success(true))
        }
    }
    
    func removeCoupon() -> Future<Bool, Error> {
        return Future { promise in
            promise(.success(true))
        }
    }
    
}

