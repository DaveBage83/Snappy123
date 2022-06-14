//
//  CheckoutServiceTests.swift
//  SnappyV2Tests
//
//  Created by Kevin Palser on 06/02/2022.
//

import XCTest
import Combine
import AppsFlyerLib
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
    
    func test_successfulFirstPurchaseCreateDraftOrder_whenCashOrder_thenDraftOrderWithBusinessOrderId() {
        let draftOrderResult = DraftOrderResult.mockedFirstCashData
        
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
            AFEventParamContentId:[2923969],
            "item_price":[10.5],
            "item_quantity":[1],
            "item_barcode":[""],
            AFEventParamCurrency:"GBP",
            AFEventParamQuantity:1,
            "delivery_cost":0.0,
            "payment_type":"cash",
            AFEventParamRevenue:23.3,
            AFEventParamPrice:23.3,
            "fulfilment_method":"delivery",
            "asap":true,
            "store_id":1569,
            "store_name":"Family Shopper Lochee",
            AFEventParamOrderId:6666,
            AFEventParamReceiptId:6666,
            "coupon_code":"ACME",
            "coupon_discount_amount":2.1,
            "campaign_id":3454356
        ]
        
        mockedEventLogger.actions = .init(expected: [.sendEvent(for: .firstPurchase, with: .appsFlyer, params: params)])
        
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
            .clearLastDeliveryOrderOnDevice,
            .lastDeliveryOrderOnDevice,
            .clearBasket
        ])
        
        let params: [String: Any] = [
            AFEventParamContentId:[2923969],
            "item_price":[10.5],
            "item_quantity":[1],
            "item_barcode":[""],
            AFEventParamCurrency:"GBP",
            AFEventParamQuantity:1,
            "delivery_cost":0.0,
            "payment_type":"cash",
            AFEventParamRevenue:23.3,
            AFEventParamPrice:23.3,
            "fulfilment_method":"delivery",
            "asap":true,
            "store_id":1569,
            "store_name":"Family Shopper Lochee",
            AFEventParamOrderId:6666,
            AFEventParamReceiptId:6666,
            "coupon_code":"ACME",
            "coupon_discount_amount":2.1,
            "campaign_id":3454356
        ]
        
        mockedEventLogger.actions = .init(expected: [.sendEvent(for: .purchase, with: .appsFlyer, params: params)])
        
        // Configuring responses from repositories
        mockedWebRepo.createDraftOrderResponse = .success(draftOrderResult)
        
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
            .clearLastDeliveryOrderOnDevice,
            .lastDeliveryOrderOnDevice,
            .clearBasket
        ])
        
        let params: [String: Any] = [
            AFEventParamContentId:[2923969],
            "item_price":[10.5],
            "item_quantity":[1],
            "item_barcode":[""],
            AFEventParamCurrency:"GBP",
            AFEventParamQuantity:1,
            "delivery_cost":0.0,
            "payment_type":"realex",
            AFEventParamRevenue:23.3,
            AFEventParamPrice:23.3,
            "fulfilment_method":"delivery",
            "asap":true,
            "store_id":1569,
            "store_name":"Family Shopper Lochee",
            AFEventParamOrderId:shimmedPaymentResponse.businessOrderId!,
            AFEventParamReceiptId:shimmedPaymentResponse.businessOrderId!,
            "coupon_code":"ACME",
            "coupon_discount_amount":2.1,
            "campaign_id":3454356
        ]
        
        mockedEventLogger.actions = .init(expected: [.sendEvent(for: .purchase, with: .appsFlyer, params: params)])
        
        // Configuring responses from repositories
        mockedWebRepo.createDraftOrderResponse = .success(draftOrderResult)
        mockedWebRepo.processRealexHPPConsumerDataResponse = .success(processRealexHPPConsumerDataResult)
        
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
                    .processRealexHPPConsumerData(hppResponse: hppResponse, firstOrder: false)
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
                        self.mockedEventLogger.verify()
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
            .processRealexHPPConsumerData(hppResponse: hppResponse, firstOrder: false)
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
                self.mockedEventLogger.verify()
                exp.fulfill()
            }
            .store(in: &subscriptions)
        
        wait(for: [exp], timeout: 2)
        
    }
    
}

// MARK: - func confirmPayment()
final class ConfirmPaymentTests: CheckoutServiceTests {
    
    func test_succesfulConfirmPayment_whenDraftOrder_thenConfirmPaymentResponse() async {
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
            .clearLastDeliveryOrderOnDevice,
            .lastDeliveryOrderOnDevice,
            .clearBasket
        ])
        
        let params: [String: Any] = [
            AFEventParamContentId:[2923969],
            "item_price":[10.5],
            "item_quantity":[1],
            "item_barcode":[""],
            AFEventParamCurrency:"GBP",
            AFEventParamQuantity:1,
            "delivery_cost":0.0,
            "payment_type":"realex",
            AFEventParamRevenue:23.3,
            AFEventParamPrice:23.3,
            "fulfilment_method":"delivery",
            "asap":true,
            "store_id":1569,
            "store_name":"Family Shopper Lochee",
            AFEventParamOrderId:confirmPaymentResponseResult.result.businessOrderId!,
            AFEventParamReceiptId:confirmPaymentResponseResult.result.businessOrderId!,
            "coupon_code":"ACME",
            "coupon_discount_amount":2.1,
            "campaign_id":3454356
        ]
        
        mockedEventLogger.actions = .init(expected: [.sendEvent(for: .firstPurchase, with: .appsFlyer, params: params)])
        
        // Configuring responses from repositories
        mockedWebRepo.createDraftOrderResponse = .success(draftOrderResult)
        mockedWebRepo.confirmPaymentResponse = .success(confirmPaymentResponseResult)
        
        do {
            
            let _ = try await sut
                .createDraftOrder(
                    fulfilmentDetails: DraftOrderFulfilmentDetailsRequest.mockedData,
                    paymentGateway: .realex,
                    instructions: "Knock twice!"
                ).singleOutput()
            
            let confirmPaymentResult = try await sut
                .confirmPayment(firstOrder: true)
                .singleOutput()
            
            XCTAssertEqual(confirmPaymentResult, confirmPaymentResponseResult, file: #file, line: #line)
            
            mockedWebRepo.verify()
            mockedDBRepo.verify()
            mockedEventLogger.verify()
            
        } catch {
            XCTFail("Unexpected error: \(error)", file: #file, line: #line)
        }
    }
    
    func test_unsuccesfulConfirmPayment_whenNoDraftOrder_thenError() {
        
        // Configuring app prexisting states
        appState.value.userData.basket = Basket.mockedData
        appState.value.userData.selectedStore = .loaded(RetailStoreDetails.mockedData)
        
        let exp = XCTestExpectation(description: #function)
        sut
            .confirmPayment(firstOrder: true)
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
                self.mockedEventLogger.verify()
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

final class getDriverLocationTests: CheckoutServiceTests {
    
    // MARK: getDriverLocation(businessOrderId:)
    
    func test_givenBusinessOrderId_whenCallingGetDriverLocationWithenrouteState_thenSuccessful() async {
        let driverLocation = DriverLocation.mockedDataEnRoute
        
        // Configuring expected actions on repositories
        
        mockedWebRepo.actions = .init(expected: [.getDriverLocation(forBusinessOrderId: 123)])
        
        // Configuring responses from repositories
        
        mockedWebRepo.getDriverLocationResponse = .success(driverLocation)
        
        do {
            
            let getDriverLocationResult = try await sut.getDriverLocation(businessOrderId: 123)
            
            XCTAssertEqual(getDriverLocationResult, driverLocation, file: #file, line: #line)
            
            mockedWebRepo.verify()
            mockedDBRepo.verify()
            
        } catch {
            XCTFail("Unexpected error: \(error)", file: #file, line: #line)
        }

    }
    
    func test_givenBusinessOrderIdSameAsSaved_whenCallingGetDriverLocationWithCompletedState_thenSuccessfulDeletingLastSaved() async {
        let driverLocation = DriverLocation.mockedDataDelivered
        let lastDeliveryOrderOnDevice = LastDeliveryOrderOnDevice.mockedData
        
        // Configuring expected actions on repositories
        
        mockedWebRepo.actions = .init(expected: [.getDriverLocation(forBusinessOrderId: lastDeliveryOrderOnDevice.businessOrderId)])
        mockedDBRepo.actions = .init(expected: [.lastDeliveryOrderOnDevice, .clearLastDeliveryOrderOnDevice])
        
        // Configuring responses from repositories
        
        mockedWebRepo.getDriverLocationResponse = .success(driverLocation)
        mockedDBRepo.lastDeliveryOrderOnDeviceResult = .success(lastDeliveryOrderOnDevice)
        
        do {
            
            let getDriverLocationResult = try await sut.getDriverLocation(businessOrderId: lastDeliveryOrderOnDevice.businessOrderId)
            
            XCTAssertEqual(getDriverLocationResult, driverLocation, file: #file, line: #line)
            
            mockedWebRepo.verify()
            mockedDBRepo.verify()
            
        } catch {
            XCTFail("Unexpected error: \(error)", file: #file, line: #line)
        }

    }
    
    func test_givenBusinessOrderIdDifferentToSaved_whenCallingGetDriverLocationWithCompletedState_thenSuccessfulwithoutDeletingLastSaved() async {
        let driverLocation = DriverLocation.mockedDataDelivered
        let lastDeliveryOrderOnDevice = LastDeliveryOrderOnDevice.mockedData
        
        // Configuring expected actions on repositories
        
        mockedWebRepo.actions = .init(expected: [.getDriverLocation(forBusinessOrderId: lastDeliveryOrderOnDevice.businessOrderId + 1)])
        mockedDBRepo.actions = .init(expected: [.lastDeliveryOrderOnDevice])
        
        // Configuring responses from repositories
        
        mockedWebRepo.getDriverLocationResponse = .success(driverLocation)
        mockedDBRepo.lastDeliveryOrderOnDeviceResult = .success(lastDeliveryOrderOnDevice)
        
        do {
            
            let getDriverLocationResult = try await sut.getDriverLocation(businessOrderId: lastDeliveryOrderOnDevice.businessOrderId + 1)
            
            XCTAssertEqual(getDriverLocationResult, driverLocation, file: #file, line: #line)
            
            mockedWebRepo.verify()
            mockedDBRepo.verify()
            
        } catch {
            XCTFail("Unexpected error: \(error)", file: #file, line: #line)
        }

    }
    
    func test_givenBusinessOrderId_whenCallingGetDriverLocationAndNetworkError_thenReturnError() async {
        let networkError = NSError(domain: NSURLErrorDomain, code: -1009, userInfo: [:])
        
        // Configuring expected actions on repositories
        
        mockedWebRepo.actions = .init(expected: [.getDriverLocation(forBusinessOrderId: 123)])
        
        // Configuring responses from repositories
        
        mockedWebRepo.getDriverLocationResponse = .failure(networkError)
        
        do {
            let getDriverLocationResult = try await sut.getDriverLocation(businessOrderId: 123)
            XCTFail("Unexpected result: \(getDriverLocationResult)", file: #file, line: #line)
        } catch {
            XCTAssertEqual(error as NSError, networkError, file: #file, line: #line)
            mockedWebRepo.verify()
            mockedDBRepo.verify()
        }

    }
    
}

final class getLastDeliveryOrderDriverLocationTests: CheckoutServiceTests {
    
    // MARK: getLastDeliveryOrderDriverLocation()
    
    func test_givenBusinessOrderId_whenCallingGetDriverLocationAndNotSaved_thenReturnNil() async {

        // Configuring expected actions on repositories
        
        mockedDBRepo.actions = .init(expected: [.lastDeliveryOrderOnDevice])
        
        // Configuring responses from repositories
        
        mockedDBRepo.lastDeliveryOrderOnDeviceResult = .success(nil)
        
        do {
            
            let getLastDeliveryOrderDriverLocationResult = try await sut.getLastDeliveryOrderDriverLocation()
            
            XCTAssertNil(getLastDeliveryOrderDriverLocationResult, file: #file, line: #line)
            
            mockedWebRepo.verify()
            mockedDBRepo.verify()
            
        } catch {
            XCTFail("Unexpected error: \(error)", file: #file, line: #line)
        }

    }
    
    func test_givenBusinessOrderId_whenCallingGetDriverLocationAndStatusEnRoute_thenReturnDriverLocationMapParameters() async {
        let driverLocationMapParameter = DriverLocationMapParameters.mockedWithLastOrderData
        
        // Configuring expected actions on repositories
        
        mockedDBRepo.actions = .init(expected: [.lastDeliveryOrderOnDevice])
        mockedWebRepo.actions = .init(expected: [.getDriverLocation(forBusinessOrderId: driverLocationMapParameter.businessOrderId)])
        
        // Configuring responses from repositories
        
        mockedDBRepo.lastDeliveryOrderOnDeviceResult = .success(driverLocationMapParameter.lastDeliveryOrder)
        mockedWebRepo.getDriverLocationResponse = .success(driverLocationMapParameter.driverLocation)
        
        do {
            
            let getLastDeliveryOrderDriverLocationResult = try await sut.getLastDeliveryOrderDriverLocation()
            
            XCTAssertEqual(getLastDeliveryOrderDriverLocationResult, driverLocationMapParameter, file: #file, line: #line)
            
            mockedWebRepo.verify()
            mockedDBRepo.verify()
            
        } catch {
            XCTFail("Unexpected error: \(error)", file: #file, line: #line)
        }

    }
    
    func test_givenBusinessOrderId_whenCallingGetDriverLocationAndStatusDelivered_thenReturnNilAndDeleteSavedLastOrder() async {
        let driverLocationMapParameter = DriverLocationMapParameters.mockedWithLastOrderData
        
        // Configuring expected actions on repositories
        
        mockedDBRepo.actions = .init(expected: [.lastDeliveryOrderOnDevice, .lastDeliveryOrderOnDevice, .clearLastDeliveryOrderOnDevice])
        mockedWebRepo.actions = .init(expected: [.getDriverLocation(forBusinessOrderId: driverLocationMapParameter.businessOrderId)])
        
        // Configuring responses from repositories
        
        mockedDBRepo.lastDeliveryOrderOnDeviceResult = .success(driverLocationMapParameter.lastDeliveryOrder)
        mockedWebRepo.getDriverLocationResponse = .success(DriverLocation.mockedDataDelivered)
        
        do {
            
            let getLastDeliveryOrderDriverLocationResult = try await sut.getLastDeliveryOrderDriverLocation()
            
            XCTAssertNil(getLastDeliveryOrderDriverLocationResult, file: #file, line: #line)
            
            mockedWebRepo.verify()
            mockedDBRepo.verify()
            
        } catch {
            XCTFail("Unexpected error: \(error)", file: #file, line: #line)
        }

    }
    
    func test_givenBusinessOrderId_whenCallinggetLastDeliveryOrderOnDeviceAndNetworkError_thenReturnError() async {
        let networkError = NSError(domain: NSURLErrorDomain, code: -1009, userInfo: [:])
        let lastDeliveryOrderOnDevice = LastDeliveryOrderOnDevice.mockedData
        
        // Configuring expected actions on repositories
        
        mockedDBRepo.actions = .init(expected: [.lastDeliveryOrderOnDevice])
        mockedWebRepo.actions = .init(expected: [.getDriverLocation(forBusinessOrderId: lastDeliveryOrderOnDevice.businessOrderId)])
        
        // Configuring responses from repositories
        
        mockedDBRepo.lastDeliveryOrderOnDeviceResult = .success(lastDeliveryOrderOnDevice)
        mockedWebRepo.getDriverLocationResponse = .failure(networkError)
        
        do {
            let getLastDeliveryOrderDriverLocationResult = try await sut.getLastDeliveryOrderDriverLocation()
            XCTFail("Unexpected result: \(String(describing: getLastDeliveryOrderDriverLocationResult))", file: #file, line: #line)
        } catch {
            XCTAssertEqual(error as NSError, networkError, file: #file, line: #line)
            mockedWebRepo.verify()
            mockedDBRepo.verify()
        }

    }
    
}
    
final class clearLastDeliveryOrderOnDeviceTests: CheckoutServiceTests {
    
    func test_clearLastDeliveryOrderOnDevice() async {
        // Configuring expected actions on repositories
        
        mockedDBRepo.actions = .init(expected: [.clearLastDeliveryOrderOnDevice])
        
        do {
            try await sut.clearLastDeliveryOrderOnDevice()
            mockedWebRepo.verify()
            mockedDBRepo.verify()
        } catch {
            XCTFail("Unexpected error: \(error)", file: #file, line: #line)
        }
    }
    
}

final class addTestLastDeliveryOrderDriverLocationTests: CheckoutServiceTests {
    
    func test_addTestLastDeliveryOrderDriverLocation() async {
        
        let lastDeliveryOrder = LastDeliveryOrderOnDevice(
            businessOrderId: 4290187,
            storeName: "Mace Dundee",
            storeContactNumber: "0123646474533",
            deliveryPostcode: "DD2 1RW"
        )
        
        // Configuring expected actions on repositories
        
        mockedDBRepo.actions = .init(expected: [.clearLastDeliveryOrderOnDevice, .store(lastDeliveryOrderOnDevice: lastDeliveryOrder)])
        
        do {
            try await sut.addTestLastDeliveryOrderDriverLocation()
            mockedWebRepo.verify()
            mockedDBRepo.verify()
        } catch {
            XCTFail("Unexpected error: \(error)", file: #file, line: #line)
        }
    }
    
}
