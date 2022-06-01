//
//  CheckoutServiceTests.swift
//  SnappyV2Tests
//
//  Created by Kevin Palser on 06/02/2022.
//

import XCTest
import Combine
@testable import SnappyV2

class CheckoutServiceTests: XCTestCase {
    
    var appState = CurrentValueSubject<AppState, Never>(AppState())
    var mockedEventLogger: MockedEventLogger!
    var mockedWebRepo: MockedCheckoutWebRepository!
    var mockedDBRepo: MockedCheckoutDBRepository!
    var subscriptions = Set<AnyCancellable>()
    var sut: CheckoutService!

    override func setUp() {
        mockedEventLogger = MockedEventLogger()
        mockedWebRepo = MockedCheckoutWebRepository()
        mockedDBRepo = MockedCheckoutDBRepository()
        sut = CheckoutService(
            webRepository: mockedWebRepo,
            dbRepository: mockedDBRepo,
            appState: appState,
            eventLogger: mockedEventLogger
        )
    }
    
    func delay(_ closure: @escaping () -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: closure)
    }

    override func tearDown() {
        appState = CurrentValueSubject<AppState, Never>(AppState())
        subscriptions = Set<AnyCancellable>()
        mockedEventLogger = nil
        mockedWebRepo = nil
        mockedDBRepo = nil
        sut = nil
    }
}

// MARK: - func createDraftOrder(fulfilmentDetails:paymentGateway:instructions:firstname:lastname:emailAddress:phoneNumber:)
final class CreateDraftOrderTests: CheckoutServiceTests {
    
    func test_successfulCreateDraftOrder_whenCashOrder_thenDraftOrderWithBusinessOrderId() {
        let draftOrderResult = DraftOrderResult.mockedCashData
        
        // Configuring app prexisting states
        appState.value.userData.basket = Basket.mockedData
        appState.value.userData.selectedStore = .loaded(RetailStoreDetails.mockedData)
        
        // Configuring expected actions on repositories
        mockedWebRepo.actions = .init(expected: [
            .createDraftOrder(
                basketToken: Basket.mockedData.basketToken,
                fulfilmentDetails: DraftOrderFulfilmentDetailsRequest.mockedData,
                instructions: "Knock twice!",
                paymentGateway: .cash,
                storeId: RetailStoreDetails.mockedData.id
            )
        ])
        mockedDBRepo.actions = .init(expected: [
            .clearBasket
        ])
        
        let params: [String: Any] = [
            "af_content_id":[2923969],
            "item_price":[10.5],
            "item_quantity":[1],
            "item_barcode":[""],
            "af_currency":"GBP",
            "af_quantity":1,
            "delivery_cost":0.0,
            "payment_type":"cash",
            "af_revenue":23.3,
            "af_price":23.3,
            "fulfilment_method":"delivery",
            "asap":true,
            "store_id":1569,
            "store_name":"Family Shopper Lochee",
            "af_order_id":6666,
            "af_receipt_id":6666,
            "coupon_code":"ACME",
            "coupon_discount_amount":2.1,
            "campaign_id":3454356
        ]
        
        mockedEventLogger.actions = .init(expected: [.sendEvent(for: .purchase, with: .appsFlyer, params: params)])
        
        // Configuring responses from repositories
        mockedWebRepo.createDraftOrderResponse = .success(draftOrderResult)
        mockedDBRepo.clearBasketResult = .success(true)
        
        let exp = XCTestExpectation(description: #function)
        sut
            .createDraftOrder(
                fulfilmentDetails: DraftOrderFulfilmentDetailsRequest.mockedData,
                paymentGateway: .cash,
                instructions: "Knock twice!"
            )
            .sinkToResult { [weak self] result in
                guard let self = self else { return }
                switch result {
                case let .success(resultValue):
                    XCTAssertEqual(resultValue.businessOrderId, draftOrderResult.businessOrderId, file: #file, line: #line)
                    XCTAssertEqual(resultValue.savedCards, draftOrderResult.paymentMethods, file: #file, line: #line)
                case let .failure(error):
                    XCTFail("Unexpected error: \(error)", file: #file, line: #line)
                }
                self.mockedWebRepo.verify()
                self.mockedDBRepo.verify()
                self.mockedEventLogger.verify()
                exp.fulfill()
            }
            .store(in: &subscriptions)

        wait(for: [exp], timeout: 2)
    }
    
    func test_unsuccessfulCreateDraftOrder_whenNoBasket_thenError() {

        // Configuring app prexisting states
        appState.value.userData.selectedStore = .loaded(RetailStoreDetails.mockedData)
        
        let exp = XCTestExpectation(description: #function)
        sut
            .createDraftOrder(
                fulfilmentDetails: DraftOrderFulfilmentDetailsRequest.mockedData,
                paymentGateway: .cash,
                instructions: "Knock twice!"
            )
            .sinkToResult { [weak self] result in
                guard let self = self else { return }
                switch result {
                case let .success(resultValue):
                    XCTFail("Unexpected result: \(resultValue)", file: #file, line: #line)
                case let .failure(error):
                    if let checkoutError = error as? CheckoutServiceError {
                        XCTAssertEqual(checkoutError, CheckoutServiceError.unableToProceedWithoutBasket, file: #file, line: #line)
                    } else {
                        XCTFail("Unexpected error type: \(error)", file: #file, line: #line)
                    }
                }
                self.mockedWebRepo.verify()
                self.mockedDBRepo.verify()
                exp.fulfill()
            }
            .store(in: &subscriptions)

        wait(for: [exp], timeout: 2)
    }
    
    func test_unsuccessfulCreateDraftOrder_whenNoSelectedStore_thenError() {
        
        // Configuring app prexisting states
        appState.value.userData.basket = Basket.mockedData
        
        let exp = XCTestExpectation(description: #function)
        sut
            .createDraftOrder(
                fulfilmentDetails: DraftOrderFulfilmentDetailsRequest.mockedData,
                paymentGateway: .cash,
                instructions: "Knock twice!"
            )
            .sinkToResult { [weak self] result in
                guard let self = self else { return }
                switch result {
                case let .success(resultValue):
                    XCTFail("Unexpected result: \(resultValue)", file: #file, line: #line)
                case let .failure(error):
                    if let checkoutError = error as? CheckoutServiceError {
                        XCTAssertEqual(checkoutError, CheckoutServiceError.storeSelectionRequired, file: #file, line: #line)
                    } else {
                        XCTFail("Unexpected error type: \(error)", file: #file, line: #line)
                    }
                }
                self.mockedWebRepo.verify()
                self.mockedDBRepo.verify()
                exp.fulfill()
            }
            .store(in: &subscriptions)

        wait(for: [exp], timeout: 2)
    }
    
    func test_unsuccessfulCreateDraftOrder_whenSelectedStoreDoesNotSupportGateway_thenError() {
        
        // Configuring app prexisting states
        appState.value.userData.selectedStore = .loaded(RetailStoreDetails.mockedDataWithoutRealexAndNoDeliveryForStripe)
        appState.value.userData.basket = Basket.mockedData
        
        let exp = XCTestExpectation(description: #function)
        sut
            .createDraftOrder(
                fulfilmentDetails: DraftOrderFulfilmentDetailsRequest.mockedData,
                paymentGateway: .realex,
                instructions: "Knock twice!"
            )
            .sinkToResult { [weak self] result in
                guard let self = self else { return }
                switch result {
                case let .success(resultValue):
                    XCTFail("Unexpected result: \(resultValue)", file: #file, line: #line)
                case let .failure(error):
                    if let checkoutError = error as? CheckoutServiceError {
                        XCTAssertEqual(checkoutError, CheckoutServiceError.paymentGatewayNotAvaibleToStore, file: #file, line: #line)
                    } else {
                        XCTFail("Unexpected error type: \(error)", file: #file, line: #line)
                    }
                }
                self.mockedWebRepo.verify()
                self.mockedDBRepo.verify()
                exp.fulfill()
            }
            .store(in: &subscriptions)

        wait(for: [exp], timeout: 2)
    }
    
    func test_unsuccessfulCreateDraftOrder_whenSelectedStoreDoesNotSupportMethodWithGateway_thenError() {
        
        // Configuring app prexisting states
        appState.value.userData.selectedFulfilmentMethod = .delivery
        appState.value.userData.selectedStore = .loaded(RetailStoreDetails.mockedDataWithoutRealexAndNoDeliveryForStripe)
        appState.value.userData.basket = Basket.mockedData
        
        let exp = XCTestExpectation(description: #function)
        sut
            .createDraftOrder(
                fulfilmentDetails: DraftOrderFulfilmentDetailsRequest.mockedData,
                paymentGateway: .stripe,
                instructions: "Knock twice!"
            )
            .sinkToResult { [weak self] result in
                guard let self = self else { return }
                switch result {
                case let .success(resultValue):
                    XCTFail("Unexpected result: \(resultValue)", file: #file, line: #line)
                case let .failure(error):
                    if let checkoutError = error as? CheckoutServiceError {
                        XCTAssertEqual(checkoutError, CheckoutServiceError.paymentGatewayNotAvaibleForFulfilmentMethod, file: #file, line: #line)
                    } else {
                        XCTFail("Unexpected error type: \(error)", file: #file, line: #line)
                    }
                }
                self.mockedWebRepo.verify()
                self.mockedDBRepo.verify()
                exp.fulfill()
            }
            .store(in: &subscriptions)

        wait(for: [exp], timeout: 2)
    }

}

// MARK: - func getRealexHPPProducerData()
final class GetRealexHPPProducerDataTests: CheckoutServiceTests {
    
    func test_successfulGetRealexHPPProducerData_whenDraftOrder_thenDataForHPP() {
        
        // Create a draft order because sut.draftOrderId needs to be
        // set and is private
        let draftOrderResult = DraftOrderResult.mockedCardData
        let getRealexHPPProducerDataResult = Data.mockedGlobalpaymentsProducerData
        
        // Configuring app prexisting states
        appState.value.userData.basket = Basket.mockedData
        appState.value.userData.selectedStore = .loaded(RetailStoreDetails.mockedData)
        
        // Configuring expected actions on repositories
        mockedWebRepo.actions = .init(expected: [
            .createDraftOrder(
                basketToken: Basket.mockedData.basketToken,
                fulfilmentDetails: DraftOrderFulfilmentDetailsRequest.mockedData,
                instructions: "Knock twice!",
                paymentGateway: .realex,
                storeId: RetailStoreDetails.mockedData.id
            ),
            .getRealexHPPProducerData(orderId: draftOrderResult.draftOrderId)
        ])
        
        // Configuring responses from repositories
        mockedWebRepo.createDraftOrderResponse = .success(draftOrderResult)
        mockedWebRepo.getRealexHPPProducerDataResponse = .success(getRealexHPPProducerDataResult)
        
        let exp = XCTestExpectation(description: #function)
        sut
            .createDraftOrder(
                fulfilmentDetails: DraftOrderFulfilmentDetailsRequest.mockedData,
                paymentGateway: .realex,
                instructions: "Knock twice!"
            )
            .sinkToResult { [weak self] _ in
                // will now have sut.draftOrderId set
                guard let self = self else { return }
                self.sut
                    .getRealexHPPProducerData()
                    .sinkToResult { [weak self] result in
                        guard let self = self else { return }
                        switch result {
                        case let .success(resultValue):
                            XCTAssertEqual(resultValue, getRealexHPPProducerDataResult, file: #file, line: #line)
                        case let .failure(error):
                            XCTFail("Unexpected error: \(error)", file: #file, line: #line)
                        }
                        self.mockedWebRepo.verify()
                        self.mockedDBRepo.verify()
                        exp.fulfill()
                    }
                    .store(in: &self.subscriptions)
            }
            .store(in: &subscriptions)
        
        
        wait(for: [exp], timeout: 2)
    }
    
    func test_unsuccessfulGetRealexHPPProducerData_whenNoDraftOrder_thenError() {
        
        // Configuring app prexisting states
        appState.value.userData.basket = Basket.mockedData
        appState.value.userData.selectedStore = .loaded(RetailStoreDetails.mockedData)
        
        let exp = XCTestExpectation(description: #function)
        sut
            .getRealexHPPProducerData()
            .sinkToResult { [weak self] result in
                guard let self = self else { return }
                switch result {
                case let .success(resultValue):
                    XCTFail("Unexpected result: \(resultValue)", file: #file, line: #line)
                case let .failure(error):
                    if let checkoutError = error as? CheckoutServiceError {
                        XCTAssertEqual(checkoutError, CheckoutServiceError.draftOrderRequired, file: #file, line: #line)
                    } else {
                        XCTFail("Unexpected error type: \(error)", file: #file, line: #line)
                    }
                }
                self.mockedWebRepo.verify()
                self.mockedDBRepo.verify()
                exp.fulfill()
            }
            .store(in: &subscriptions)
        
        
        wait(for: [exp], timeout: 2)
    }
    
}

// MARK: - func processRealexHPPConsumerData(hppResponse:)
final class ProcessRealexHPPConsumerDataTests: CheckoutServiceTests {
    
    func test_successfulProcessRealexHPPConsumerData_whenDraftOrder_thenShimmedPaymentResponse() {
        
        // Create a draft order because sut.draftOrderId needs to be
        // set and is private
        let draftOrderResult = DraftOrderResult.mockedCardData
        let processRealexHPPConsumerDataResult = ConfirmPaymentResponse.mockedData
        let hppResponse = [String: Any].mockedGlobalpaymentsHPPResponse
        let shimmedPaymentResponse = ShimmedPaymentResponse.mockedData
        
        // Configuring app prexisting states
        appState.value.userData.basket = Basket.mockedData
        appState.value.userData.selectedStore = .loaded(RetailStoreDetails.mockedData)
        
        // Configuring expected actions on repositories
        mockedWebRepo.actions = .init(expected: [
            .createDraftOrder(
                basketToken: Basket.mockedData.basketToken,
                fulfilmentDetails: DraftOrderFulfilmentDetailsRequest.mockedData,
                instructions: "Knock twice!",
                paymentGateway: .realex,
                storeId: RetailStoreDetails.mockedData.id
            ),
            .processRealexHPPConsumerData(
                orderId: draftOrderResult.draftOrderId,
                hppResponse: hppResponse
            )
        ])
        
        mockedDBRepo.actions = .init(expected: [
            .clearBasket
        ])
        
        // Configuring responses from repositories
        mockedWebRepo.createDraftOrderResponse = .success(draftOrderResult)
        mockedWebRepo.processRealexHPPConsumerDataResponse = .success(processRealexHPPConsumerDataResult)
        mockedDBRepo.clearBasketResult = .success(true)
        
        let exp = XCTestExpectation(description: #function)
        sut
            .createDraftOrder(
                fulfilmentDetails: DraftOrderFulfilmentDetailsRequest.mockedData,
                paymentGateway: .realex,
                instructions: "Knock twice!"
            )
            .sinkToResult { [weak self] _ in
                // will now have sut.draftOrderId set
                guard let self = self else { return }
                self.sut
                    .processRealexHPPConsumerData(hppResponse: hppResponse)
                    .sinkToResult { [weak self] result in
                        guard let self = self else { return }
                        switch result {
                        case let .success(resultValue):
                            XCTAssertEqual(resultValue, shimmedPaymentResponse, file: #file, line: #line)
                        case let .failure(error):
                            XCTFail("Unexpected error: \(error)", file: #file, line: #line)
                        }
                        self.mockedWebRepo.verify()
                        self.mockedDBRepo.verify()
                        exp.fulfill()
                    }
                    .store(in: &self.subscriptions)
            }
            .store(in: &subscriptions)
        
        wait(for: [exp], timeout: 2)
        
    }
    
    func test_unsuccessfulProcessRealexHPPConsumerData_whenNoDraftOrder_thenError() {
        
        let hppResponse = [String: Any].mockedGlobalpaymentsHPPResponse
        
        // Configuring app prexisting states
        appState.value.userData.basket = Basket.mockedData
        appState.value.userData.selectedStore = .loaded(RetailStoreDetails.mockedData)
        
        let exp = XCTestExpectation(description: #function)
        sut
            .processRealexHPPConsumerData(hppResponse: hppResponse)
            .sinkToResult { [weak self] result in
                guard let self = self else { return }
                switch result {
                case let .success(resultValue):
                    XCTFail("Unexpected result: \(resultValue)", file: #file, line: #line)
                case let .failure(error):
                    if let checkoutError = error as? CheckoutServiceError {
                        XCTAssertEqual(checkoutError, CheckoutServiceError.draftOrderRequired, file: #file, line: #line)
                    } else {
                        XCTFail("Unexpected error type: \(error)", file: #file, line: #line)
                    }
                }
                self.mockedWebRepo.verify()
                self.mockedDBRepo.verify()
                exp.fulfill()
            }
            .store(in: &subscriptions)
        
        wait(for: [exp], timeout: 2)
        
    }
    
}

// MARK: - func confirmPayment()
final class ConfirmPaymentTests: CheckoutServiceTests {
    
    func test_succesfulConfirmPayment_whenDraftOrder_thenConfirmPaymentResponse() {
        // Create a draft order because sut.draftOrderId needs to be
        // set and is private
        let draftOrderResult = DraftOrderResult.mockedCardData
        let confirmPaymentResponseResult = ConfirmPaymentResponse.mockedData
        
        // Configuring app prexisting states
        appState.value.userData.basket = Basket.mockedData
        appState.value.userData.selectedStore = .loaded(RetailStoreDetails.mockedData)
        
        // Configuring expected actions on repositories
        mockedWebRepo.actions = .init(expected: [
            .createDraftOrder(
                basketToken: Basket.mockedData.basketToken,
                fulfilmentDetails: DraftOrderFulfilmentDetailsRequest.mockedData,
                instructions: "Knock twice!",
                paymentGateway: .realex,
                storeId: RetailStoreDetails.mockedData.id
            ),
            .confirmPayment(orderId: draftOrderResult.draftOrderId)
        ])
        
        mockedDBRepo.actions = .init(expected: [
            .clearBasket
        ])
        
        // Configuring responses from repositories
        mockedWebRepo.createDraftOrderResponse = .success(draftOrderResult)
        mockedWebRepo.confirmPaymentResponse = .success(confirmPaymentResponseResult)
        mockedDBRepo.clearBasketResult = .success(true)
        
        let exp = XCTestExpectation(description: #function)
        sut
            .createDraftOrder(
                fulfilmentDetails: DraftOrderFulfilmentDetailsRequest.mockedData,
                paymentGateway: .realex,
                instructions: "Knock twice!"
            )
            .sinkToResult { [weak self] _ in
                // will now have sut.draftOrderId set
                guard let self = self else { return }
                self.sut
                    .confirmPayment()
                    .sinkToResult { [weak self] result in
                        guard let self = self else { return }
                        switch result {
                        case let .success(resultValue):
                            XCTAssertEqual(resultValue, confirmPaymentResponseResult, file: #file, line: #line)
                        case let .failure(error):
                            XCTFail("Unexpected error: \(error)", file: #file, line: #line)
                        }
                        self.mockedWebRepo.verify()
                        self.mockedDBRepo.verify()
                        exp.fulfill()
                    }
                    .store(in: &self.subscriptions)
            }
            .store(in: &subscriptions)
        
        wait(for: [exp], timeout: 2)
    }
    
    func test_unsuccesfulConfirmPayment_whenNoDraftOrder_thenError() {
        
        // Configuring app prexisting states
        appState.value.userData.basket = Basket.mockedData
        appState.value.userData.selectedStore = .loaded(RetailStoreDetails.mockedData)
        
        let exp = XCTestExpectation(description: #function)
        sut
            .confirmPayment()
            .sinkToResult { [weak self] result in
                guard let self = self else { return }
                switch result {
                case let .success(resultValue):
                    XCTFail("Unexpected result: \(resultValue)", file: #file, line: #line)
                case let .failure(error):
                    if let checkoutError = error as? CheckoutServiceError {
                        XCTAssertEqual(checkoutError, CheckoutServiceError.draftOrderRequired, file: #file, line: #line)
                    } else {
                        XCTFail("Unexpected error type: \(error)", file: #file, line: #line)
                    }
                }
                self.mockedWebRepo.verify()
                self.mockedDBRepo.verify()
                exp.fulfill()
            }
            .store(in: &subscriptions)
        
        wait(for: [exp], timeout: 2)
        
    }
}

final class GetPlacedOrderStatusTests: CheckoutServiceTests {
    
    // MARK: - getPlacedOrderStatus(status:businessOrderId:)
    
    func test_givenBusinessOrderId_whenCallingPlacedOrderStatus_thenSuccessful() {
        let placedOrderStatus = PlacedOrderStatus.mockedData
        
        // Configuring expected actions on repositories
        
        mockedWebRepo.actions = .init(expected: [.getPlacedOrderStatus(forBusinessOrderId: 123)])
        
        // Configuring responses from repositories
        
        mockedWebRepo.getPlacedOrderStatusResponse = .success(placedOrderStatus)
        
        let exp = expectation(description: #function)
        let status = BindingWithPublisher(value: Loadable<PlacedOrderStatus>.notRequested)
        sut.getPlacedOrderStatus(status: status.binding, businessOrderId: 123)
        status.updatesRecorder
            .sink { updates in
                XCTAssertEqual(updates, [
                    .notRequested,
                    .isLoading(last: nil, cancelBag: CancelBag()),
                    .loaded(placedOrderStatus)
                ])
                self.mockedWebRepo.verify()
                exp.fulfill()
            }
            .store(in: &subscriptions)
        
        wait(for: [exp], timeout: 2)
    }
    
    func test_givenBusinessOrderId_whenCallingPlacedOrderStatusAndNetworkError_thenReturnError() {
        let networkError = NSError(domain: NSURLErrorDomain, code: -1009, userInfo: [:])
        
        // Configuring expected actions on repositories
        
        mockedWebRepo.actions = .init(expected: [.getPlacedOrderStatus(forBusinessOrderId: 123)])
        
        // Configuring responses from repositories
        
        mockedWebRepo.getPlacedOrderStatusResponse = .failure(networkError)
        
        let exp = expectation(description: #function)
        let status = BindingWithPublisher(value: Loadable<PlacedOrderStatus>.notRequested)
        sut.getPlacedOrderStatus(status: status.binding, businessOrderId: 123)
        status.updatesRecorder
            .sink { updates in
                XCTAssertEqual(updates, [
                    .notRequested,
                    .isLoading(last: nil, cancelBag: CancelBag()),
                    .failed(networkError)
                ])
                self.mockedWebRepo.verify()
                exp.fulfill()
            }
            .store(in: &subscriptions)
        
        wait(for: [exp], timeout: 2)
    }
}
