//
//  CheckoutServiceTests.swift
//  SnappyV2Tests
//
//  Created by Kevin Palser on 06/02/2022.
//

import XCTest
import Combine

// import 3rd party
import AppsFlyerLib
import FBSDKCoreKit
import Frames

@testable import SnappyV2
import SwiftUI

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
            eventLogger: mockedEventLogger,
            checkoutComClient: { MockCheckoutAPIClient(publicKey: $0, environment: $1) }
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

class MockCheckoutAPIClient: CheckoutAPIClientProtocol {
    let publicKey: String
    let environment: Frames.Environment
    
    init(publicKey: String, environment: Frames.Environment) {
        self.publicKey = publicKey
        self.environment = environment
    }
    
    func createCardToken(card: CkoCardTokenRequest) async throws -> CkoCardTokenResponse {
        let ckoCardTokenResponseJson: String = """
            {
            "type": "",
            "token": "SomeToken",
            "expires_on": "",
            "expiry_month": 0,
            "expiry_year": 0,
            "last4": "",
            "bin": ""
            }
        """
        
        let ckoCardTokenResponse = try! JSONDecoder().decode(CkoCardTokenResponse.self, from: ckoCardTokenResponseJson.data(using: .utf8)!)
        return ckoCardTokenResponse
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
        
        let expectedLastDeliverOnDevice = LastDeliveryOrderOnDevice(
            businessOrderId: draftOrderResult.businessOrderId!,
            storeName: RetailStoreDetails.mockedData.storeName,
            storeContactNumber: RetailStoreDetails.mockedData.telephone,
            deliveryPostcode: nil)
        
        mockedDBRepo.actions = .init(expected: [
            .clearLastDeliveryOrderOnDevice,
            .store(lastDeliveryOrderOnDevice: expectedLastDeliverOnDevice),
            .clearBasket
        ])
        
        let appsFlyerEventParameters: [String: Any] = [
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
        
        let facebookParams: [AppEvents.ParameterName: Any] = [
            .numItems: 1,
            .description: "business order 6666",
            .orderID: "6666",
            .content: "[{\"order_id\": \"6666\"}, {\"id\": \"2923969\", \"quantity\":1, \"item_price\": 10.50}]"
        ]
        
        let firebaseEventParameters: [String: Any] = [
            "checkedOutTotalCost": 23.3,
            "currency":"GBP",
            "facebookParams": facebookParams
        ]
        
        mockedEventLogger.actions = .init(expected: [
            .sendEvent(for: .firstPurchase, with: .appsFlyer, params: appsFlyerEventParameters),
            .sendEvent(for: .firstPurchase, with: .facebook, params: firebaseEventParameters)
        ])
        
        // Configuring responses from repositories
        mockedWebRepo.createDraftOrderResponse = .success(draftOrderResult)
        
        let exp = XCTestExpectation(description: #function)
        sut
            .createDraftOrder(
                fulfilmentDetails: DraftOrderFulfilmentDetailsRequest.mockedData,
                paymentGatewayType: .cash,
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
        
        let expectedLastDeliverOnDevice = LastDeliveryOrderOnDevice(
            businessOrderId: 6666,
            storeName: RetailStoreDetails.mockedData.storeName,
            storeContactNumber: RetailStoreDetails.mockedData.telephone,
            deliveryPostcode: nil)
        
        mockedDBRepo.actions = .init(expected: [
            .clearLastDeliveryOrderOnDevice,
            .store(lastDeliveryOrderOnDevice: expectedLastDeliverOnDevice),
            .clearBasket
        ])

        let appsFlyerEventParameters: [String: Any] = [
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
        
        let facebookParams: [AppEvents.ParameterName: Any] = [
            .numItems: 1,
            .description: "business order 6666",
            .orderID: "6666",
            .content: "[{\"order_id\": \"6666\"}, {\"id\": \"2923969\", \"quantity\":1, \"item_price\": 10.50}]"
        ]
        
        let firebaseEventParameters: [String: Any] = [
            "checkedOutTotalCost": 23.3,
            "currency":"GBP",
            "facebookParams": facebookParams
        ]
        
        mockedEventLogger.actions = .init(expected: [
            .sendEvent(for: .purchase, with: .appsFlyer, params: appsFlyerEventParameters),
            .sendEvent(for: .purchase, with: .facebook, params: firebaseEventParameters)
        ])

        // Configuring responses from repositories
        mockedWebRepo.createDraftOrderResponse = .success(draftOrderResult)
        
        let exp = XCTestExpectation(description: #function)
        sut
            .createDraftOrder(
                fulfilmentDetails: DraftOrderFulfilmentDetailsRequest.mockedData,
                paymentGatewayType: .cash,
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
                paymentGatewayType: .cash,
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
                paymentGatewayType: .cash,
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
                paymentGatewayType: .realex,
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
                paymentGatewayType: .stripe,
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
                paymentGatewayType: .realex,
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
        
        let expectedLastDeliverOnDevice = LastDeliveryOrderOnDevice(
            businessOrderId: 2158,
            storeName: RetailStoreDetails.mockedData.storeName,
            storeContactNumber: RetailStoreDetails.mockedData.telephone,
            deliveryPostcode: nil)
        
        mockedDBRepo.actions = .init(expected: [
            .clearLastDeliveryOrderOnDevice,
            .store(lastDeliveryOrderOnDevice: expectedLastDeliverOnDevice),
            .clearBasket
        ])
        
        let appsFlyerEventParameters: [String: Any] = [
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
        
        let facebookParams: [AppEvents.ParameterName: Any] = [
            .numItems: 1,
            .description: "business order 2158",
            .orderID: "2158",
            .content: "[{\"order_id\": \"2158\"}, {\"id\": \"2923969\", \"quantity\":1, \"item_price\": 10.50}]"
        ]
        
        let firebaseEventParameters: [String: Any] = [
            "checkedOutTotalCost": 23.3,
            "currency":"GBP",
            "facebookParams": facebookParams
        ]
        
        mockedEventLogger.actions = .init(expected: [
            .sendEvent(for: .purchase, with: .appsFlyer, params: appsFlyerEventParameters),
            .sendEvent(for: .purchase, with: .facebook, params: firebaseEventParameters)
        ])
        
        // Configuring responses from repositories
        mockedWebRepo.createDraftOrderResponse = .success(draftOrderResult)
        mockedWebRepo.processRealexHPPConsumerDataResponse = .success(processRealexHPPConsumerDataResult)
        
        let exp = XCTestExpectation(description: #function)
        
        sut
            .createDraftOrder(
                fulfilmentDetails: DraftOrderFulfilmentDetailsRequest.mockedData,
                paymentGatewayType: .realex,
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
        XCTAssertEqual(appState.value.userData.successCheckoutBasket, Basket.mockedData)
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


// MARK: - func processApplePaymentOrder(fulfilmentDetails:paymentGateway:instructions:publicKey:merchantId:)
class MockedApplePaymentHandler: ApplePaymentHandlerProtocol {
    func startApplePayment(basket: Basket, publicKey: String, merchantId: String, paymentGatewayMode: PaymentGatewayMode, makePayment: @escaping MakePaymentAction) async throws -> Int? {
        let result = try await makePayment("TOKEN")
        return result.order?.businessOrderId
    }
}

final class processApplePaymentOrderTests: CheckoutServiceTests {
    
    func test_givenCorrectDetails_whenProcessApplePaymentOrder_thenBusinessOrderIdReturned() async {
        let draftOrderResult = DraftOrderResult.mockedCardData
        let businessOrderId = 123
        let selectedStore = RetailStoreDetails.mockedDataWithCheckoutComApplePay
        let basket = Basket.mockedDataTomorrowSlot
        let applePayHandler = MockedApplePaymentHandler()
        let requestedTime = "\(basket.selectedSlot?.start?.hourMinutesString(timeZone: nil) ?? "") - \(basket.selectedSlot?.end?.hourMinutesString(timeZone: nil) ?? "")"
        let draftOrderFulfilmentDetailsTimeRequest = DraftOrderFulfilmentDetailsTimeRequest(date: basket.selectedSlot?.start?.dateOnlyString(storeTimeZone: nil) ?? "", requestedTime: requestedTime)
        let draftOrderFulfilmentDetailRequest = DraftOrderFulfilmentDetailsRequest(time: draftOrderFulfilmentDetailsTimeRequest, place: nil)
        let makePaymentResponse = MakePaymentResponse(gatewayData: GatewayData(id: nil, status: nil, gateway: nil, saveCard: nil, paymentMethod: nil, approved: nil, _links: nil), order: Order(draftOrderId: draftOrderResult.draftOrderId, businessOrderId: businessOrderId, pointsEarned: nil, message: nil))
        
        // Configuring app prexisting states
        appState.value.userData.basket = basket
        appState.value.userData.selectedStore = .loaded(selectedStore)
        
        // Configuring expected actions on repositories
        mockedWebRepo.actions = .init(expected: [
            .createDraftOrder(basketToken: basket.basketToken, fulfilmentDetails: draftOrderFulfilmentDetailRequest, instructions: nil, paymentGateway: .checkoutcom, storeId: selectedStore.id),
            .makePayment(orderId: draftOrderResult.draftOrderId, type: .applepay, paymentMethod: "apple_pay", token: "TOKEN", cardId: nil, cvv: nil)
        ])
        
        let appsFlyerEventParameters: [String: Any] = [
            AFEventParamContentId:[2923969],
            "item_price":[10.5],
            "item_quantity":[1],
            "item_barcode":[""],
            AFEventParamCurrency:"GBP",
            AFEventParamQuantity:1,
            "delivery_cost":0.0,
            "payment_type":"checkoutcom",
            AFEventParamRevenue:23.3,
            AFEventParamPrice:23.3,
            "fulfilment_method":"delivery",
            "asap":false,
            "store_id":1569,
            "store_name":"Family Shopper Lochee",
            AFEventParamOrderId:makePaymentResponse.order?.businessOrderId!,
            AFEventParamReceiptId:makePaymentResponse.order?.businessOrderId!,
            "coupon_code":"ACME",
            "coupon_discount_amount":2.1,
            "campaign_id":3454356
        ]

        let facebookParams: [AppEvents.ParameterName: Any] = [
            .numItems: 1,
            .description: "business order 123",
            .orderID: "123",
            .content: "[{\"order_id\": \"123\"}, {\"id\": \"2923969\", \"quantity\":1, \"item_price\": 10.50}]"
        ]
        
        let firebaseEventParameters: [String: Any] = [
            "checkedOutTotalCost": 23.3,
            "currency":"GBP",
            "facebookParams": facebookParams
        ]
        
        mockedEventLogger.actions = .init(expected: [
            .sendEvent(for: .purchase, with: .appsFlyer, params: appsFlyerEventParameters),
            .sendEvent(for: .purchase, with: .facebook, params: firebaseEventParameters)
        ])
        
        // Configuring responses from repositories
        mockedWebRepo.createDraftOrderResponse = .success(draftOrderResult)
        mockedWebRepo.makePaymentResponse = makePaymentResponse
        
        do {
            let result = try await sut.exposeProcessApplePaymentOrder(fulfilmentDetails: draftOrderFulfilmentDetailRequest, paymentGatewayType: .checkoutcom, paymentGatewayMode: .sandbox, instructions: nil, publicKey: selectedStore.paymentGateways?[0].fields?["publicKey"] as! String, merchantId: selectedStore.paymentGateways?[0].fields?["applePayMerchantId"] as! String, applePayHandler: applePayHandler)
            XCTAssertEqual(result, businessOrderId)
        } catch {
            XCTFail("Unexpected error: \(error.localizedDescription)")
        }
        
        mockedWebRepo.verify()
        mockedEventLogger.verify()
    }
    
    func test_givenCorrectDetailsWithTestMode_whenProcessApplePaymentOrder_thenBusinessOrderIdReturned() async {
        let draftOrderResult = DraftOrderResult.mockedCardData
        let businessOrderId = 123
        let selectedStore = RetailStoreDetails.mockedDataWithCheckoutComApplePayWithTestMode
        let basket = Basket.mockedDataTomorrowSlot
        let applePayHandler = MockedApplePaymentHandler()
        let requestedTime = "\(basket.selectedSlot?.start?.hourMinutesString(timeZone: nil) ?? "") - \(basket.selectedSlot?.end?.hourMinutesString(timeZone: nil) ?? "")"
        let draftOrderFulfilmentDetailsTimeRequest = DraftOrderFulfilmentDetailsTimeRequest(date: basket.selectedSlot?.start?.dateOnlyString(storeTimeZone: nil) ?? "", requestedTime: requestedTime)
        let draftOrderFulfilmentDetailRequest = DraftOrderFulfilmentDetailsRequest(time: draftOrderFulfilmentDetailsTimeRequest, place: nil)
        let makePaymentResponse = MakePaymentResponse(gatewayData: GatewayData(id: nil, status: nil, gateway: nil, saveCard: nil, paymentMethod: nil, approved: nil, _links: nil), order: Order(draftOrderId: draftOrderResult.draftOrderId, businessOrderId: businessOrderId, pointsEarned: nil, message: nil))
        
        // Configuring app prexisting states
        appState.value.userData.basket = basket
        appState.value.userData.selectedStore = .loaded(selectedStore)
        
        // Configuring expected actions on repositories
        mockedWebRepo.actions = .init(expected: [
            .createDraftOrder(basketToken: basket.basketToken, fulfilmentDetails: draftOrderFulfilmentDetailRequest, instructions: nil, paymentGateway: .checkoutcom, storeId: selectedStore.id),
            .makePayment(orderId: draftOrderResult.draftOrderId, type: .applepay, paymentMethod: "apple_pay", token: "TOKEN", cardId: nil, cvv: nil)
        ])
        
        let appsFlyerEventParameters: [String: Any] = [
            AFEventParamContentId:[2923969],
            "item_price":[10.5],
            "item_quantity":[1],
            "item_barcode":[""],
            AFEventParamCurrency:"GBP",
            AFEventParamQuantity:1,
            "delivery_cost":0.0,
            "payment_type":"checkoutcom",
            AFEventParamRevenue:23.3,
            AFEventParamPrice:23.3,
            "fulfilment_method":"delivery",
            "asap":false,
            "store_id":1569,
            "store_name":"Family Shopper Lochee",
            AFEventParamOrderId:makePaymentResponse.order?.businessOrderId!,
            AFEventParamReceiptId:makePaymentResponse.order?.businessOrderId!,
            "coupon_code":"ACME",
            "coupon_discount_amount":2.1,
            "campaign_id":3454356
        ]

        let facebookParams: [AppEvents.ParameterName: Any] = [
            .numItems: 1,
            .description: "business order 123",
            .orderID: "123",
            .content: "[{\"order_id\": \"123\"}, {\"id\": \"2923969\", \"quantity\":1, \"item_price\": 10.50}]"
        ]
        
        let firebaseEventParameters: [String: Any] = [
            "checkedOutTotalCost": 23.3,
            "currency":"GBP",
            "facebookParams": facebookParams
        ]
        
        mockedEventLogger.actions = .init(expected: [
            .sendEvent(for: .purchase, with: .appsFlyer, params: appsFlyerEventParameters),
            .sendEvent(for: .purchase, with: .facebook, params: firebaseEventParameters)
        ])
        
        // Configuring responses from repositories
        mockedWebRepo.createDraftOrderResponse = .success(draftOrderResult)
        mockedWebRepo.makePaymentResponse = makePaymentResponse
        
        do {
            let result = try await sut.exposeProcessApplePaymentOrder(fulfilmentDetails: draftOrderFulfilmentDetailRequest, paymentGatewayType: .checkoutcom, paymentGatewayMode: .sandbox, instructions: nil, publicKey: selectedStore.paymentGateways?[0].fields?["publicKey"] as! String, merchantId: selectedStore.paymentGateways?[0].fields?["applePayMerchantId"] as! String, applePayHandler: applePayHandler)
            XCTAssertEqual(result, businessOrderId)
        } catch {
            XCTFail("Unexpected error: \(error.localizedDescription)")
        }
        
        mockedWebRepo.verify()
        mockedEventLogger.verify()
    }
    
    func test_givenNoBusinessOrderId_whenProcessApplePaymentOrder_thenThrowBusinessOrderIdMissingError() async {
        let draftOrderResult = DraftOrderResult.mockedCardData
        let selectedStore = RetailStoreDetails.mockedDataWithCheckoutComApplePay
        let basket = Basket.mockedDataTomorrowSlot
        let applePayHandler = MockedApplePaymentHandler()
        let requestedTime = "\(basket.selectedSlot?.start?.hourMinutesString(timeZone: nil) ?? "") - \(basket.selectedSlot?.end?.hourMinutesString(timeZone: nil) ?? "")"
        let draftOrderFulfilmentDetailsTimeRequest = DraftOrderFulfilmentDetailsTimeRequest(date: basket.selectedSlot?.start?.dateOnlyString(storeTimeZone: nil) ?? "", requestedTime: requestedTime)
        let draftOrderFulfilmentDetailRequest = DraftOrderFulfilmentDetailsRequest(time: draftOrderFulfilmentDetailsTimeRequest, place: nil)
        let makePaymentResponse = MakePaymentResponse(gatewayData: GatewayData(id: nil, status: nil, gateway: nil, saveCard: nil, paymentMethod: nil, approved: nil, _links: nil), order: Order(draftOrderId: draftOrderResult.draftOrderId, businessOrderId: nil, pointsEarned: nil, message: nil))
        
        // Configuring app prexisting states
        appState.value.userData.basket = basket
        appState.value.userData.selectedStore = .loaded(selectedStore)
        
        // Configuring expected actions on repositories
        mockedWebRepo.actions = .init(expected: [
            .createDraftOrder(basketToken: basket.basketToken, fulfilmentDetails: draftOrderFulfilmentDetailRequest, instructions: nil, paymentGateway: .checkoutcom, storeId: selectedStore.id),
            .makePayment(orderId: draftOrderResult.draftOrderId, type: .applepay, paymentMethod: "apple_pay", token: "TOKEN", cardId: nil, cvv: nil)
        ])
        
        // Configuring responses from repositories
        mockedWebRepo.createDraftOrderResponse = .success(draftOrderResult)
        mockedWebRepo.makePaymentResponse = makePaymentResponse
        
        do {
            let _ = try await sut.exposeProcessApplePaymentOrder(fulfilmentDetails: draftOrderFulfilmentDetailRequest, paymentGatewayType: .checkoutcom, paymentGatewayMode: .sandbox, instructions: nil, publicKey: selectedStore.paymentGateways?[0].fields?["publicKey"] as! String, merchantId: selectedStore.paymentGateways?[0].fields?["applePayMerchantId"] as! String, applePayHandler: applePayHandler)
            XCTFail("Unexpected success")
        } catch {
            XCTAssertEqual(error as! CheckoutServiceError, CheckoutServiceError.businessOrderIdNotReturned)
        }
        
        mockedWebRepo.verify()
        mockedEventLogger.verify()
    }
}

// MARK: - func processNewCardPaymentOrder(fulfilmentDetails:paymentGateway:instructions:publicKey:cardDetails:)
final class ProcessNewCardPaymentOrderTests: CheckoutServiceTests {
    
    func test_givenCorrectDetails_whenProcessNewCardPaymentOrder_thenBusinessOrderIdReturned() async {
        let draftOrderResult = DraftOrderResult.mockedCardData
        let businessOrderId = 123
        let selectedStore = RetailStoreDetails.mockedDataWithCheckoutComApplePay
        let basket = Basket.mockedDataTomorrowSlot
        let cardDetails = CheckoutCardDetails(number: "4242424242424242", expiryMonth: "05", expiryYear: "25", cvv: "100", cardName: "Some Name")
        let requestedTime = "\(basket.selectedSlot?.start?.hourMinutesString(timeZone: nil) ?? "") - \(basket.selectedSlot?.end?.hourMinutesString(timeZone: nil) ?? "")"
        let draftOrderFulfilmentDetailsTimeRequest = DraftOrderFulfilmentDetailsTimeRequest(date: basket.selectedSlot?.start?.dateOnlyString(storeTimeZone: nil) ?? "", requestedTime: requestedTime)
        let draftOrderFulfilmentDetailRequest = DraftOrderFulfilmentDetailsRequest(time: draftOrderFulfilmentDetailsTimeRequest, place: nil)
        let makePaymentResponse = MakePaymentResponse(gatewayData: GatewayData(id: nil, status: nil, gateway: nil, saveCard: nil, paymentMethod: nil, approved: nil, _links: nil), order: Order(draftOrderId: draftOrderResult.draftOrderId, businessOrderId: businessOrderId, pointsEarned: nil, message: nil))
        
        // Configuring app prexisting states
        appState.value.userData.basket = basket
        appState.value.userData.selectedStore = .loaded(selectedStore)
        
        // Configuring expected actions on repositories
        mockedWebRepo.actions = .init(expected: [
            .createDraftOrder(basketToken: basket.basketToken, fulfilmentDetails: draftOrderFulfilmentDetailRequest, instructions: nil, paymentGateway: .checkoutcom, storeId: selectedStore.id),
            .makePayment(orderId: draftOrderResult.draftOrderId, type: .token, paymentMethod: "card", token: "SomeToken", cardId: nil, cvv: nil)
        ])
        
        let appsFlyerEventParameters: [String: Any] = [
            AFEventParamContentId:[2923969],
            "item_price":[10.5],
            "item_quantity":[1],
            "item_barcode":[""],
            AFEventParamCurrency:"GBP",
            AFEventParamQuantity:1,
            "delivery_cost":0.0,
            "payment_type":"checkoutcom",
            AFEventParamRevenue:23.3,
            AFEventParamPrice:23.3,
            "fulfilment_method":"delivery",
            "asap":false,
            "store_id":1569,
            "store_name":"Family Shopper Lochee",
            AFEventParamOrderId:makePaymentResponse.order?.businessOrderId!,
            AFEventParamReceiptId:makePaymentResponse.order?.businessOrderId!,
            "coupon_code":"ACME",
            "coupon_discount_amount":2.1,
            "campaign_id":3454356
        ]

        let facebookParams: [AppEvents.ParameterName: Any] = [
            .numItems: 1,
            .description: "business order 123",
            .orderID: "123",
            .content: "[{\"order_id\": \"123\"}, {\"id\": \"2923969\", \"quantity\":1, \"item_price\": 10.50}]"
        ]
        
        let firebaseEventParameters: [String: Any] = [
            "checkedOutTotalCost": 23.3,
            "currency":"GBP",
            "facebookParams": facebookParams
        ]
        
        mockedEventLogger.actions = .init(expected: [
            .sendEvent(for: .purchase, with: .appsFlyer, params: appsFlyerEventParameters),
            .sendEvent(for: .purchase, with: .facebook, params: firebaseEventParameters)
        ])
        
        // Configuring responses from repositories
        mockedWebRepo.createDraftOrderResponse = .success(draftOrderResult)
        mockedWebRepo.makePaymentResponse = makePaymentResponse
        
        do {
            let result = try await sut.processNewCardPaymentOrder(fulfilmentDetails: draftOrderFulfilmentDetailRequest, paymentGatewayType: .checkoutcom, paymentGatewayMode: .sandbox, instructions: nil, publicKey: selectedStore.paymentGateways?[0].fields?["publicKey"] as! String, cardDetails: cardDetails, saveCardPaymentHandler: nil)
            XCTAssertEqual(result.0, businessOrderId)
            XCTAssertNil(result.1)
        } catch {
            XCTFail("Unexpected error: \(error.localizedDescription)")
        }
        
        mockedWebRepo.verify()
        mockedEventLogger.verify()
    }
    
    func test_givenCorrectDetailsWithExpected3DS_whenProcessNewCardPaymentOrder_thenSuccessAndFailURLsAreReturned() async {
        let draftOrderResult = DraftOrderResult.mockedCardData
        let selectedStore = RetailStoreDetails.mockedDataWithCheckoutComApplePay
        let basket = Basket.mockedDataTomorrowSlot
        let cardDetails = CheckoutCardDetails(number: "4242424242424242", expiryMonth: "05", expiryYear: "25", cvv: "100", cardName: "Some Name")
        let requestedTime = "\(basket.selectedSlot?.start?.hourMinutesString(timeZone: nil) ?? "") - \(basket.selectedSlot?.end?.hourMinutesString(timeZone: nil) ?? "")"
        let draftOrderFulfilmentDetailsTimeRequest = DraftOrderFulfilmentDetailsTimeRequest(date: basket.selectedSlot?.start?.dateOnlyString(storeTimeZone: nil) ?? "", requestedTime: requestedTime)
        let draftOrderFulfilmentDetailRequest = DraftOrderFulfilmentDetailsRequest(time: draftOrderFulfilmentDetailsTimeRequest, place: nil)
        let redirectURL = "https://api.sandbox.checkout.com/sessions-interceptor/sid_izyb2mdu3o5ujofrezmzapigri"
        let successURL = "https://www.snapppyshopper.co.uk/takeaway/checkout/payment/?success=true&platform=ios&o=1969990"
        let failURL = "https://www.snapppyshopper.co.uk/takeaway/checkout/payment/?failure=true&platform=ios&o=1969990"
        let threeDSLinks: ThreeDSLinks = ThreeDSLinks(redirect: HREF(
            href: redirectURL),
            success: HREF(href: successURL),
            failure: HREF(href: failURL)
        )
        let makePaymentResponse = MakePaymentResponse(gatewayData: GatewayData(id: nil, status: .pending, gateway: nil, saveCard: nil, paymentMethod: nil, approved: nil, _links: threeDSLinks), order: nil)
        
        // Configuring app prexisting states
        appState.value.userData.basket = basket
        appState.value.userData.selectedStore = .loaded(selectedStore)
        
        // Configuring expected actions on repositories
        mockedWebRepo.actions = .init(expected: [
            .createDraftOrder(basketToken: basket.basketToken, fulfilmentDetails: draftOrderFulfilmentDetailRequest, instructions: nil, paymentGateway: .checkoutcom, storeId: selectedStore.id),
            .makePayment(orderId: draftOrderResult.draftOrderId, type: .token, paymentMethod: "card", token: "SomeToken", cardId: nil, cvv: nil)
        ])
        
        // Configuring responses from repositories
        mockedWebRepo.createDraftOrderResponse = .success(draftOrderResult)
        mockedWebRepo.makePaymentResponse = makePaymentResponse
        
        do {
            let result = try await sut.processNewCardPaymentOrder(fulfilmentDetails: draftOrderFulfilmentDetailRequest, paymentGatewayType: .checkoutcom, paymentGatewayMode: .sandbox, instructions: nil, publicKey: selectedStore.paymentGateways?[0].fields?["publicKey"] as! String, cardDetails: cardDetails, saveCardPaymentHandler: nil)
            XCTAssertEqual(result.1?.redirectUrl, URL(string: redirectURL)!)
            XCTAssertEqual(result.1?.successUrl, URL(string: successURL)!)
            XCTAssertEqual(result.1?.failUrl, URL(string: failURL)!)
            XCTAssertNil(result.0)
        } catch {
            XCTFail("Unexpected error: \(error.localizedDescription)")
        }
        
        mockedWebRepo.verify()
        mockedEventLogger.verify()
    }
    
    func test_givenCorrectDetailsWithUnvalidPayment_whenProcessNewCardPaymentOrder_thenDeclinedErrorThrown() async {
        let draftOrderResult = DraftOrderResult.mockedCardData
        let selectedStore = RetailStoreDetails.mockedDataWithCheckoutComApplePay
        let basket = Basket.mockedDataTomorrowSlot
        let cardDetails = CheckoutCardDetails(number: "4242424242424242", expiryMonth: "05", expiryYear: "25", cvv: "100", cardName: "Some Name")
        let requestedTime = "\(basket.selectedSlot?.start?.hourMinutesString(timeZone: nil) ?? "") - \(basket.selectedSlot?.end?.hourMinutesString(timeZone: nil) ?? "")"
        let draftOrderFulfilmentDetailsTimeRequest = DraftOrderFulfilmentDetailsTimeRequest(date: basket.selectedSlot?.start?.dateOnlyString(storeTimeZone: nil) ?? "", requestedTime: requestedTime)
        let draftOrderFulfilmentDetailRequest = DraftOrderFulfilmentDetailsRequest(time: draftOrderFulfilmentDetailsTimeRequest, place: nil)
        let makePaymentResponse = MakePaymentResponse(gatewayData: GatewayData(id: nil, status: .declined, gateway: nil, saveCard: nil, paymentMethod: nil, approved: nil, _links: nil), order: nil)
        
        // Configuring app prexisting states
        appState.value.userData.basket = basket
        appState.value.userData.selectedStore = .loaded(selectedStore)
        
        // Configuring expected actions on repositories
        mockedWebRepo.actions = .init(expected: [
            .createDraftOrder(basketToken: basket.basketToken, fulfilmentDetails: draftOrderFulfilmentDetailRequest, instructions: nil, paymentGateway: .checkoutcom, storeId: selectedStore.id),
            .makePayment(orderId: draftOrderResult.draftOrderId, type: .token, paymentMethod: "card", token: "SomeToken", cardId: nil, cvv: nil)
        ])
        
        // Configuring responses from repositories
        mockedWebRepo.createDraftOrderResponse = .success(draftOrderResult)
        mockedWebRepo.makePaymentResponse = makePaymentResponse
        
        do {
            let result = try await sut.processNewCardPaymentOrder(fulfilmentDetails: draftOrderFulfilmentDetailRequest, paymentGatewayType: .checkoutcom, paymentGatewayMode: .sandbox, instructions: nil, publicKey: selectedStore.paymentGateways?[0].fields?["publicKey"] as! String, cardDetails: cardDetails, saveCardPaymentHandler: nil)
            
            XCTFail("Unexpected success - Result: \(result)")
        } catch {
            XCTAssertEqual(error as! CheckoutServiceError, CheckoutServiceError.paymentDeclined, file: #file, line: #line)
        }
        
        mockedWebRepo.verify()
        mockedEventLogger.verify()
    }
    
    func test_givenCorrectDetails_whenProcessNewCardPaymentOrderFails_thenCorrectErrorThrown() async {
        let draftOrderResult = DraftOrderResult.mockedCardData
        let selectedStore = RetailStoreDetails.mockedDataWithCheckoutComApplePay
        let basket = Basket.mockedDataTomorrowSlot
        let cardDetails = CheckoutCardDetails(number: "4242424242424242", expiryMonth: "05", expiryYear: "25", cvv: "100", cardName: "Some Name")
        let requestedTime = "\(basket.selectedSlot?.start?.hourMinutesString(timeZone: nil) ?? "") - \(basket.selectedSlot?.end?.hourMinutesString(timeZone: nil) ?? "")"
        let draftOrderFulfilmentDetailsTimeRequest = DraftOrderFulfilmentDetailsTimeRequest(date: basket.selectedSlot?.start?.dateOnlyString(storeTimeZone: nil) ?? "", requestedTime: requestedTime)
        let draftOrderFulfilmentDetailRequest = DraftOrderFulfilmentDetailsRequest(time: draftOrderFulfilmentDetailsTimeRequest, place: nil)
        let makePaymentResponse = MakePaymentResponse(gatewayData: GatewayData(id: nil, status: .authorised, gateway: nil, saveCard: nil, paymentMethod: nil, approved: nil, _links: nil), order: nil)
        
        // Configuring app prexisting states
        appState.value.userData.basket = basket
        appState.value.userData.selectedStore = .loaded(selectedStore)
        
        // Configuring expected actions on repositories
        mockedWebRepo.actions = .init(expected: [
            .createDraftOrder(basketToken: basket.basketToken, fulfilmentDetails: draftOrderFulfilmentDetailRequest, instructions: nil, paymentGateway: .checkoutcom, storeId: selectedStore.id),
            .makePayment(orderId: draftOrderResult.draftOrderId, type: .token, paymentMethod: "card", token: "SomeToken", cardId: nil, cvv: nil)
        ])
        
        // Configuring responses from repositories
        mockedWebRepo.createDraftOrderResponse = .success(draftOrderResult)
        mockedWebRepo.makePaymentResponse = makePaymentResponse
        
        do {
            let result = try await sut.processNewCardPaymentOrder(fulfilmentDetails: draftOrderFulfilmentDetailRequest, paymentGatewayType: .checkoutcom, paymentGatewayMode: .sandbox, instructions: nil, publicKey: selectedStore.paymentGateways?[0].fields?["publicKey"] as! String, cardDetails: cardDetails, saveCardPaymentHandler: nil)
            
            XCTFail("Unexpected success - Result: \(result)")
        } catch {
            XCTAssertEqual(error as! CheckoutServiceError, CheckoutServiceError.businessOrderIdNotReturnedAndMakePaymentResultNotPending, file: #file, line: #line)
        }
        
        mockedWebRepo.verify()
        mockedEventLogger.verify()
    }
    
    func test_givenCorrectDetailsButMissingBasket_whenProcessNewCardPaymentOrderFails_thenCorrectErrorThrown() async {
        let selectedStore = RetailStoreDetails.mockedDataWithCheckoutComApplePay
        let basket = Basket.mockedDataTomorrowSlot
        let cardDetails = CheckoutCardDetails(number: "4242424242424242", expiryMonth: "05", expiryYear: "25", cvv: "100", cardName: "Some Name")
        let requestedTime = "\(basket.selectedSlot?.start?.hourMinutesString(timeZone: nil) ?? "") - \(basket.selectedSlot?.end?.hourMinutesString(timeZone: nil) ?? "")"
        let draftOrderFulfilmentDetailsTimeRequest = DraftOrderFulfilmentDetailsTimeRequest(date: basket.selectedSlot?.start?.dateOnlyString(storeTimeZone: nil) ?? "", requestedTime: requestedTime)
        let draftOrderFulfilmentDetailRequest = DraftOrderFulfilmentDetailsRequest(time: draftOrderFulfilmentDetailsTimeRequest, place: nil)
        
        // Configuring app prexisting states
        appState.value.userData.selectedStore = .loaded(selectedStore)
        
        do {
            let result = try await sut.processNewCardPaymentOrder(fulfilmentDetails: draftOrderFulfilmentDetailRequest, paymentGatewayType: .checkoutcom, paymentGatewayMode: .sandbox, instructions: nil, publicKey: selectedStore.paymentGateways?[0].fields?["publicKey"] as! String, cardDetails: cardDetails, saveCardPaymentHandler: nil)
            
            XCTFail("Unexpected success - Result: \(result)")
        } catch {
            XCTAssertEqual(error as! CheckoutServiceError, CheckoutServiceError.unableToProceedWithoutBasket, file: #file, line: #line)
        }
        
        mockedWebRepo.verify()
        mockedEventLogger.verify()
    }
    
    func test_givenMissingBillingDetails_whenProcessNewCardPaymentOrderFails_thenCorrectErrorThrown() async {
        let draftOrderResult = DraftOrderResult.mockedCardData
        let selectedStore = RetailStoreDetails.mockedDataWithCheckoutComApplePay
        let basket = Basket.mockedDataNoAddresses
        let cardDetails = CheckoutCardDetails(number: "4242424242424242", expiryMonth: "05", expiryYear: "25", cvv: "100", cardName: "Some Name")
        let requestedTime = "\(basket.selectedSlot?.start?.hourMinutesString(timeZone: nil) ?? "") - \(basket.selectedSlot?.end?.hourMinutesString(timeZone: nil) ?? "")"
        let draftOrderFulfilmentDetailsTimeRequest = DraftOrderFulfilmentDetailsTimeRequest(date: basket.selectedSlot?.start?.dateOnlyString(storeTimeZone: nil) ?? "", requestedTime: requestedTime)
        let draftOrderFulfilmentDetailRequest = DraftOrderFulfilmentDetailsRequest(time: draftOrderFulfilmentDetailsTimeRequest, place: nil)
        
        // Configuring app prexisting states
        appState.value.userData.basket = basket
        appState.value.userData.selectedStore = .loaded(selectedStore)
        
        // Configuring expected actions on repositories
        mockedWebRepo.actions = .init(expected: [
            .createDraftOrder(basketToken: basket.basketToken, fulfilmentDetails: draftOrderFulfilmentDetailRequest, instructions: nil, paymentGateway: .checkoutcom, storeId: selectedStore.id)
        ])
        
        // Configuring responses from repositories
        mockedWebRepo.createDraftOrderResponse = .success(draftOrderResult)
        
        do {
            let result = try await sut.processNewCardPaymentOrder(fulfilmentDetails: draftOrderFulfilmentDetailRequest, paymentGatewayType: .checkoutcom, paymentGatewayMode: .sandbox, instructions: nil, publicKey: selectedStore.paymentGateways?[0].fields?["publicKey"] as! String, cardDetails: cardDetails, saveCardPaymentHandler: nil)
            
            XCTFail("Unexpected success - Result: \(result)")
        } catch {
            XCTAssertEqual(error as! CheckoutServiceError, CheckoutServiceError.billingAddressDetailsMissing, file: #file, line: #line)
        }
        
        mockedWebRepo.verify()
        mockedEventLogger.verify()
    }
    
    func test_givenCorrectDetailsWithUnvalid3DS_whenProcessNewCardPaymentOrderFails_thenCorrectErrorThrown() async {
        let draftOrderResult = DraftOrderResult.mockedCardData
        let selectedStore = RetailStoreDetails.mockedDataWithCheckoutComApplePay
        let basket = Basket.mockedDataTomorrowSlot
        let cardDetails = CheckoutCardDetails(number: "4242424242424242", expiryMonth: "05", expiryYear: "25", cvv: "100", cardName: "Some Name")
        let requestedTime = "\(basket.selectedSlot?.start?.hourMinutesString(timeZone: nil) ?? "") - \(basket.selectedSlot?.end?.hourMinutesString(timeZone: nil) ?? "")"
        let draftOrderFulfilmentDetailsTimeRequest = DraftOrderFulfilmentDetailsTimeRequest(date: basket.selectedSlot?.start?.dateOnlyString(storeTimeZone: nil) ?? "", requestedTime: requestedTime)
        let draftOrderFulfilmentDetailRequest = DraftOrderFulfilmentDetailsRequest(time: draftOrderFulfilmentDetailsTimeRequest, place: nil)
        let redirectURL = "https://api.sandbox.checkout.com/sessions-interceptor/sid_izyb2mdu3o5ujofrezmzapigri"
        let successURL = ""
        let failURL = ""
        let threeDSLinks: ThreeDSLinks = ThreeDSLinks(redirect: HREF(
            href: redirectURL),
            success: HREF(href: successURL),
            failure: HREF(href: failURL)
        )
        let makePaymentResponse = MakePaymentResponse(gatewayData: GatewayData(id: nil, status: .pending, gateway: nil, saveCard: nil, paymentMethod: nil, approved: nil, _links: threeDSLinks), order: nil)
        
        // Configuring app prexisting states
        appState.value.userData.basket = basket
        appState.value.userData.selectedStore = .loaded(selectedStore)
        
        // Configuring expected actions on repositories
        mockedWebRepo.actions = .init(expected: [
            .createDraftOrder(basketToken: basket.basketToken, fulfilmentDetails: draftOrderFulfilmentDetailRequest, instructions: nil, paymentGateway: .checkoutcom, storeId: selectedStore.id),
            .makePayment(orderId: draftOrderResult.draftOrderId, type: .token, paymentMethod: "card", token: "SomeToken", cardId: nil, cvv: nil)
        ])
        
        // Configuring responses from repositories
        mockedWebRepo.createDraftOrderResponse = .success(draftOrderResult)
        mockedWebRepo.makePaymentResponse = makePaymentResponse
        
        do {
            let result = try await sut.processNewCardPaymentOrder(fulfilmentDetails: draftOrderFulfilmentDetailRequest, paymentGatewayType: .checkoutcom, paymentGatewayMode: .sandbox, instructions: nil, publicKey: selectedStore.paymentGateways?[0].fields?["publicKey"] as! String, cardDetails: cardDetails, saveCardPaymentHandler: nil)
            
            XCTFail("Unexpected success - Result: \(result)")
        } catch {
            XCTAssertEqual(error as! CheckoutServiceError, CheckoutServiceError.failedToUnwrap3DSURLs, file: #file, line: #line)
        }
        
        mockedWebRepo.verify()
        mockedEventLogger.verify()
    }
}

// MARK: - func processSavedCardPaymentOrder(fulfilmentDetails:paymentGatewayType:paymentGatewayMode:instructions:publicKey:cardId:cvv:)
final class ProcessSavedCardPaymentOrderTests: CheckoutServiceTests {
    func test_givenCorrectDetails_whenProcessSavedCardPaymentOrder_thenBusinessOrderIdReturned() async {
        let draftOrderResult = DraftOrderResult.mockedCardData
        let businessOrderId = 123
        let selectedStore = RetailStoreDetails.mockedDataWithCheckoutComApplePay
        let basket = Basket.mockedDataTomorrowSlot
        let memberCard = MemberCardDetails.mockedData
        let requestedTime = "\(basket.selectedSlot?.start?.hourMinutesString(timeZone: nil) ?? "") - \(basket.selectedSlot?.end?.hourMinutesString(timeZone: nil) ?? "")"
        let draftOrderFulfilmentDetailsTimeRequest = DraftOrderFulfilmentDetailsTimeRequest(date: basket.selectedSlot?.start?.dateOnlyString(storeTimeZone: nil) ?? "", requestedTime: requestedTime)
        let draftOrderFulfilmentDetailRequest = DraftOrderFulfilmentDetailsRequest(time: draftOrderFulfilmentDetailsTimeRequest, place: nil)
        let makePaymentResponse = MakePaymentResponse(gatewayData: GatewayData(id: nil, status: nil, gateway: nil, saveCard: nil, paymentMethod: nil, approved: nil, _links: nil), order: Order(draftOrderId: draftOrderResult.draftOrderId, businessOrderId: businessOrderId, pointsEarned: nil, message: nil))
        
        // Configuring app prexisting states
        appState.value.userData.basket = basket
        appState.value.userData.selectedStore = .loaded(selectedStore)
        
        // Configuring expected actions on repositories
        mockedWebRepo.actions = .init(expected: [
            .createDraftOrder(basketToken: basket.basketToken, fulfilmentDetails: draftOrderFulfilmentDetailRequest, instructions: nil, paymentGateway: .checkoutcom, storeId: selectedStore.id),
            .makePayment(orderId: draftOrderResult.draftOrderId, type: .id, paymentMethod: "card", token: nil, cardId: memberCard.id, cvv: 100)
        ])
        
        let appsFlyerEventParameters: [String: Any] = [
            AFEventParamContentId:[2923969],
            "item_price":[10.5],
            "item_quantity":[1],
            "item_barcode":[""],
            AFEventParamCurrency:"GBP",
            AFEventParamQuantity:1,
            "delivery_cost":0.0,
            "payment_type":"checkoutcom",
            AFEventParamRevenue:23.3,
            AFEventParamPrice:23.3,
            "fulfilment_method":"delivery",
            "asap":false,
            "store_id":1569,
            "store_name":"Family Shopper Lochee",
            AFEventParamOrderId:makePaymentResponse.order?.businessOrderId!,
            AFEventParamReceiptId:makePaymentResponse.order?.businessOrderId!,
            "coupon_code":"ACME",
            "coupon_discount_amount":2.1,
            "campaign_id":3454356
        ]

        let facebookParams: [AppEvents.ParameterName: Any] = [
            .numItems: 1,
            .description: "business order 123",
            .orderID: "123",
            .content: "[{\"order_id\": \"123\"}, {\"id\": \"2923969\", \"quantity\":1, \"item_price\": 10.50}]"
        ]
        
        let firebaseEventParameters: [String: Any] = [
            "checkedOutTotalCost": 23.3,
            "currency":"GBP",
            "facebookParams": facebookParams
        ]
        
        mockedEventLogger.actions = .init(expected: [
            .sendEvent(for: .purchase, with: .appsFlyer, params: appsFlyerEventParameters),
            .sendEvent(for: .purchase, with: .facebook, params: firebaseEventParameters)
        ])
        
        // Configuring responses from repositories
        mockedWebRepo.createDraftOrderResponse = .success(draftOrderResult)
        mockedWebRepo.makePaymentResponse = makePaymentResponse
        
        do {
            let result = try await sut.processSavedCardPaymentOrder(fulfilmentDetails: draftOrderFulfilmentDetailRequest, paymentGatewayType: .checkoutcom, paymentGatewayMode: .sandbox, instructions: nil, publicKey: selectedStore.paymentGateways?[0].fields?["publicKey"] as! String, cardId: memberCard.id, cvv: "100")
            XCTAssertEqual(result.0, businessOrderId)
            XCTAssertNil(result.1)
        } catch {
            XCTFail("Unexpected error: \(error.localizedDescription)")
        }
        
        mockedWebRepo.verify()
        mockedEventLogger.verify()
    }
    
    func test_givenCorrectDetailsWithExpected3DS_whenProcessSavedCardPaymentOrder_thenSuccessAndFailURLsAreReturned() async {
        let draftOrderResult = DraftOrderResult.mockedCardData
        let selectedStore = RetailStoreDetails.mockedDataWithCheckoutComApplePay
        let basket = Basket.mockedDataTomorrowSlot
        let memberCard = MemberCardDetails.mockedData
        let requestedTime = "\(basket.selectedSlot?.start?.hourMinutesString(timeZone: nil) ?? "") - \(basket.selectedSlot?.end?.hourMinutesString(timeZone: nil) ?? "")"
        let draftOrderFulfilmentDetailsTimeRequest = DraftOrderFulfilmentDetailsTimeRequest(date: basket.selectedSlot?.start?.dateOnlyString(storeTimeZone: nil) ?? "", requestedTime: requestedTime)
        let draftOrderFulfilmentDetailRequest = DraftOrderFulfilmentDetailsRequest(time: draftOrderFulfilmentDetailsTimeRequest, place: nil)
        let redirectURL = "https://api.sandbox.checkout.com/sessions-interceptor/sid_izyb2mdu3o5ujofrezmzapigri"
        let successURL = "https://www.snapppyshopper.co.uk/takeaway/checkout/payment/?success=true&platform=ios&o=1969990"
        let failURL = "https://www.snapppyshopper.co.uk/takeaway/checkout/payment/?failure=true&platform=ios&o=1969990"
        let threeDSLinks: ThreeDSLinks = ThreeDSLinks(redirect: HREF(
            href: redirectURL),
            success: HREF(href: successURL),
            failure: HREF(href: failURL)
        )
        let makePaymentResponse = MakePaymentResponse(gatewayData: GatewayData(id: nil, status: .pending, gateway: nil, saveCard: nil, paymentMethod: nil, approved: nil, _links: threeDSLinks), order: nil)
        
        // Configuring app prexisting states
        appState.value.userData.basket = basket
        appState.value.userData.selectedStore = .loaded(selectedStore)
        
        // Configuring expected actions on repositories
        mockedWebRepo.actions = .init(expected: [
            .createDraftOrder(basketToken: basket.basketToken, fulfilmentDetails: draftOrderFulfilmentDetailRequest, instructions: nil, paymentGateway: .checkoutcom, storeId: selectedStore.id),
            .makePayment(orderId: draftOrderResult.draftOrderId, type: .id, paymentMethod: "card", token: nil, cardId: memberCard.id, cvv: 100)
        ])
        
        // Configuring responses from repositories
        mockedWebRepo.createDraftOrderResponse = .success(draftOrderResult)
        mockedWebRepo.makePaymentResponse = makePaymentResponse
        
        do {
            let result = try await sut.processSavedCardPaymentOrder(fulfilmentDetails: draftOrderFulfilmentDetailRequest, paymentGatewayType: .checkoutcom, paymentGatewayMode: .sandbox, instructions: nil, publicKey: selectedStore.paymentGateways?[0].fields?["publicKey"] as! String, cardId: memberCard.id, cvv: "100")
            XCTAssertEqual(result.1?.redirectUrl, URL(string: redirectURL)!)
            XCTAssertEqual(result.1?.successUrl, URL(string: successURL)!)
            XCTAssertEqual(result.1?.failUrl, URL(string: failURL)!)
            XCTAssertNil(result.0)
        } catch {
            XCTFail("Unexpected error: \(error.localizedDescription)")
        }
        
        mockedWebRepo.verify()
        mockedEventLogger.verify()
    }
    
    func test_givenCorrectDetailsWithUnvalidPayment_whenProcessSavedCardPaymentOrder_thenDeclinedErrorThrown() async {
        let draftOrderResult = DraftOrderResult.mockedCardData
        let selectedStore = RetailStoreDetails.mockedDataWithCheckoutComApplePay
        let basket = Basket.mockedDataTomorrowSlot
        let memberCard = MemberCardDetails.mockedData
        let requestedTime = "\(basket.selectedSlot?.start?.hourMinutesString(timeZone: nil) ?? "") - \(basket.selectedSlot?.end?.hourMinutesString(timeZone: nil) ?? "")"
        let draftOrderFulfilmentDetailsTimeRequest = DraftOrderFulfilmentDetailsTimeRequest(date: basket.selectedSlot?.start?.dateOnlyString(storeTimeZone: nil) ?? "", requestedTime: requestedTime)
        let draftOrderFulfilmentDetailRequest = DraftOrderFulfilmentDetailsRequest(time: draftOrderFulfilmentDetailsTimeRequest, place: nil)
        let makePaymentResponse = MakePaymentResponse(gatewayData: GatewayData(id: nil, status: .declined, gateway: nil, saveCard: nil, paymentMethod: nil, approved: nil, _links: nil), order: nil)
        
        // Configuring app prexisting states
        appState.value.userData.basket = basket
        appState.value.userData.selectedStore = .loaded(selectedStore)
        
        // Configuring expected actions on repositories
        mockedWebRepo.actions = .init(expected: [
            .createDraftOrder(basketToken: basket.basketToken, fulfilmentDetails: draftOrderFulfilmentDetailRequest, instructions: nil, paymentGateway: .checkoutcom, storeId: selectedStore.id),
            .makePayment(orderId: draftOrderResult.draftOrderId, type: .id, paymentMethod: "card", token: nil, cardId: memberCard.id, cvv: 100)
        ])
        
        // Configuring responses from repositories
        mockedWebRepo.createDraftOrderResponse = .success(draftOrderResult)
        mockedWebRepo.makePaymentResponse = makePaymentResponse
        
        do {
            let result = try await sut.processSavedCardPaymentOrder(fulfilmentDetails: draftOrderFulfilmentDetailRequest, paymentGatewayType: .checkoutcom, paymentGatewayMode: .sandbox, instructions: nil, publicKey: selectedStore.paymentGateways?[0].fields?["publicKey"] as! String, cardId: memberCard.id, cvv: "100")
            
            XCTFail("Unexpected success - Result: \(result)")
        } catch {
            XCTAssertEqual(error as! CheckoutServiceError, CheckoutServiceError.paymentDeclined, file: #file, line: #line)
        }
        
        mockedWebRepo.verify()
        mockedEventLogger.verify()
    }
    
    func test_givenCorrectDetails_whenProcessSavedCardPaymentOrderFails_thenCorrectErrorThrown() async {
        let draftOrderResult = DraftOrderResult.mockedCardData
        let selectedStore = RetailStoreDetails.mockedDataWithCheckoutComApplePay
        let basket = Basket.mockedDataTomorrowSlot
        let memberCard = MemberCardDetails.mockedData
        let requestedTime = "\(basket.selectedSlot?.start?.hourMinutesString(timeZone: nil) ?? "") - \(basket.selectedSlot?.end?.hourMinutesString(timeZone: nil) ?? "")"
        let draftOrderFulfilmentDetailsTimeRequest = DraftOrderFulfilmentDetailsTimeRequest(date: basket.selectedSlot?.start?.dateOnlyString(storeTimeZone: nil) ?? "", requestedTime: requestedTime)
        let draftOrderFulfilmentDetailRequest = DraftOrderFulfilmentDetailsRequest(time: draftOrderFulfilmentDetailsTimeRequest, place: nil)
        let makePaymentResponse = MakePaymentResponse(gatewayData: GatewayData(id: nil, status: .authorised, gateway: nil, saveCard: nil, paymentMethod: nil, approved: nil, _links: nil), order: nil)
        
        // Configuring app prexisting states
        appState.value.userData.basket = basket
        appState.value.userData.selectedStore = .loaded(selectedStore)
        
        // Configuring expected actions on repositories
        mockedWebRepo.actions = .init(expected: [
            .createDraftOrder(basketToken: basket.basketToken, fulfilmentDetails: draftOrderFulfilmentDetailRequest, instructions: nil, paymentGateway: .checkoutcom, storeId: selectedStore.id),
            .makePayment(orderId: draftOrderResult.draftOrderId, type: .id, paymentMethod: "card", token: nil, cardId: memberCard.id, cvv: 100)
        ])
        
        // Configuring responses from repositories
        mockedWebRepo.createDraftOrderResponse = .success(draftOrderResult)
        mockedWebRepo.makePaymentResponse = makePaymentResponse
        
        do {
            let result = try await sut.processSavedCardPaymentOrder(fulfilmentDetails: draftOrderFulfilmentDetailRequest, paymentGatewayType: .checkoutcom, paymentGatewayMode: .sandbox, instructions: nil, publicKey: selectedStore.paymentGateways?[0].fields?["publicKey"] as! String, cardId: memberCard.id, cvv: "100")
            
            XCTFail("Unexpected success - Result: \(result)")
        } catch {
            XCTAssertEqual(error as! CheckoutServiceError, CheckoutServiceError.businessOrderIdNotReturnedAndMakePaymentResultNotPending, file: #file, line: #line)
        }
        
        mockedWebRepo.verify()
        mockedEventLogger.verify()
    }
    
    func test_givenCorrectDetailsButMissingBasket_whenProcessSavedCardPaymentOrderFails_thenCorrectErrorThrown() async {
        let selectedStore = RetailStoreDetails.mockedDataWithCheckoutComApplePay
        let basket = Basket.mockedDataTomorrowSlot
        let memberCard = MemberCardDetails.mockedData
        let requestedTime = "\(basket.selectedSlot?.start?.hourMinutesString(timeZone: nil) ?? "") - \(basket.selectedSlot?.end?.hourMinutesString(timeZone: nil) ?? "")"
        let draftOrderFulfilmentDetailsTimeRequest = DraftOrderFulfilmentDetailsTimeRequest(date: basket.selectedSlot?.start?.dateOnlyString(storeTimeZone: nil) ?? "", requestedTime: requestedTime)
        let draftOrderFulfilmentDetailRequest = DraftOrderFulfilmentDetailsRequest(time: draftOrderFulfilmentDetailsTimeRequest, place: nil)
        
        // Configuring app prexisting states
        appState.value.userData.selectedStore = .loaded(selectedStore)
        
        do {
            let result = try await sut.processSavedCardPaymentOrder(fulfilmentDetails: draftOrderFulfilmentDetailRequest, paymentGatewayType: .checkoutcom, paymentGatewayMode: .sandbox, instructions: nil, publicKey: selectedStore.paymentGateways?[0].fields?["publicKey"] as! String, cardId: memberCard.id, cvv: "100")
            
            XCTFail("Unexpected success - Result: \(result)")
        } catch {
            XCTAssertEqual(error as! CheckoutServiceError, CheckoutServiceError.unableToProceedWithoutBasket, file: #file, line: #line)
        }
        
        mockedWebRepo.verify()
        mockedEventLogger.verify()
    }
    
    func test_givenMissingBillingDetails_whenProcessSavedCardPaymentOrderFails_thenCorrectErrorThrown() async {
        let draftOrderResult = DraftOrderResult.mockedCardData
        let selectedStore = RetailStoreDetails.mockedDataWithCheckoutComApplePay
        let basket = Basket.mockedDataNoAddresses
        let memberCard = MemberCardDetails.mockedData
        let requestedTime = "\(basket.selectedSlot?.start?.hourMinutesString(timeZone: nil) ?? "") - \(basket.selectedSlot?.end?.hourMinutesString(timeZone: nil) ?? "")"
        let draftOrderFulfilmentDetailsTimeRequest = DraftOrderFulfilmentDetailsTimeRequest(date: basket.selectedSlot?.start?.dateOnlyString(storeTimeZone: nil) ?? "", requestedTime: requestedTime)
        let draftOrderFulfilmentDetailRequest = DraftOrderFulfilmentDetailsRequest(time: draftOrderFulfilmentDetailsTimeRequest, place: nil)
        let makePaymentResponse = MakePaymentResponse(gatewayData: GatewayData(id: nil, status: .authorised, gateway: nil, saveCard: nil, paymentMethod: nil, approved: nil, _links: nil), order: nil)
        
        // Configuring app prexisting states
        appState.value.userData.basket = basket
        appState.value.userData.selectedStore = .loaded(selectedStore)
        
        // Configuring expected actions on repositories
        mockedWebRepo.actions = .init(expected: [
            .createDraftOrder(basketToken: basket.basketToken, fulfilmentDetails: draftOrderFulfilmentDetailRequest, instructions: nil, paymentGateway: .checkoutcom, storeId: selectedStore.id),
            .makePayment(orderId: draftOrderResult.draftOrderId, type: .id, paymentMethod: "card", token: nil, cardId: memberCard.id, cvv: 100)
        ])
        
        // Configuring responses from repositories
        mockedWebRepo.createDraftOrderResponse = .success(draftOrderResult)
        mockedWebRepo.makePaymentResponse = makePaymentResponse
        
        do {
            let result = try await sut.processSavedCardPaymentOrder(fulfilmentDetails: draftOrderFulfilmentDetailRequest, paymentGatewayType: .checkoutcom, paymentGatewayMode: .sandbox, instructions: nil, publicKey: selectedStore.paymentGateways?[0].fields?["publicKey"] as! String, cardId: memberCard.id, cvv: "100")
            
            XCTFail("Unexpected success - Result: \(result)")
        } catch {
            XCTAssertEqual(error as! CheckoutServiceError, CheckoutServiceError.businessOrderIdNotReturnedAndMakePaymentResultNotPending, file: #file, line: #line)
        }
        
        mockedWebRepo.verify()
        mockedEventLogger.verify()
    }
    
    func test_givenCorrectDetailsWithUnvalid3DS_whenProcessSavedCardPaymentOrderFails_thenCorrectErrorThrown() async {
        let draftOrderResult = DraftOrderResult.mockedCardData
        let selectedStore = RetailStoreDetails.mockedDataWithCheckoutComApplePay
        let basket = Basket.mockedDataTomorrowSlot
        let memberCard = MemberCardDetails.mockedData
        let requestedTime = "\(basket.selectedSlot?.start?.hourMinutesString(timeZone: nil) ?? "") - \(basket.selectedSlot?.end?.hourMinutesString(timeZone: nil) ?? "")"
        let draftOrderFulfilmentDetailsTimeRequest = DraftOrderFulfilmentDetailsTimeRequest(date: basket.selectedSlot?.start?.dateOnlyString(storeTimeZone: nil) ?? "", requestedTime: requestedTime)
        let draftOrderFulfilmentDetailRequest = DraftOrderFulfilmentDetailsRequest(time: draftOrderFulfilmentDetailsTimeRequest, place: nil)
        let redirectURL = "https://api.sandbox.checkout.com/sessions-interceptor/sid_izyb2mdu3o5ujofrezmzapigri"
        let successURL = ""
        let failURL = ""
        let threeDSLinks: ThreeDSLinks = ThreeDSLinks(redirect: HREF(
            href: redirectURL),
            success: HREF(href: successURL),
            failure: HREF(href: failURL)
        )
        let makePaymentResponse = MakePaymentResponse(gatewayData: GatewayData(id: nil, status: .pending, gateway: nil, saveCard: nil, paymentMethod: nil, approved: nil, _links: threeDSLinks), order: nil)
        
        // Configuring app prexisting states
        appState.value.userData.basket = basket
        appState.value.userData.selectedStore = .loaded(selectedStore)
        
        // Configuring expected actions on repositories
        mockedWebRepo.actions = .init(expected: [
            .createDraftOrder(basketToken: basket.basketToken, fulfilmentDetails: draftOrderFulfilmentDetailRequest, instructions: nil, paymentGateway: .checkoutcom, storeId: selectedStore.id),
            .makePayment(orderId: draftOrderResult.draftOrderId, type: .id, paymentMethod: "card", token: nil, cardId: memberCard.id, cvv: 100)
        ])
        
        // Configuring responses from repositories
        mockedWebRepo.createDraftOrderResponse = .success(draftOrderResult)
        mockedWebRepo.makePaymentResponse = makePaymentResponse
        
        do {
            let result = try await sut.processSavedCardPaymentOrder(fulfilmentDetails: draftOrderFulfilmentDetailRequest, paymentGatewayType: .checkoutcom, paymentGatewayMode: .sandbox, instructions: nil, publicKey: selectedStore.paymentGateways?[0].fields?["publicKey"] as! String, cardId: memberCard.id, cvv: "100")
            
            XCTFail("Unexpected success - Result: \(result)")
        } catch {
            XCTAssertEqual(error as! CheckoutServiceError, CheckoutServiceError.failedToUnwrap3DSURLs, file: #file, line: #line)
        }
        
        mockedWebRepo.verify()
        mockedEventLogger.verify()
    }
}

// MARK: - func verifyCheckoutcomPayment()
final class VerifyCheckoutcomPaymentTests: CheckoutServiceTests {
    func test_givenCorrectDetails_whenVerifyPayment_thenSuccess() async {
        let basket = Basket.mockedDataTomorrowSlot
        let businessProfile = BusinessProfile.mockedDataFromAPI
        let selectedStore = RetailStoreDetails.mockedDataWithCheckoutComApplePay
        let draftOrderId = 1970016
        let paymentId = "pay_lq7znmvow65efgyqxrbhlrm6wm"
        let verifyPaymentResponse = VerifyPaymentResponse(draftOrderId: draftOrderId, businessOrderId: businessProfile.id, pointsEarned: 0, basketToken: "SomeToken", message: "SomeMessage")
        
        // Configuring app/sut prexisting states
        appState.value.businessData.businessProfile = businessProfile
        appState.value.userData.basket = basket
        appState.value.userData.selectedStore = .loaded(selectedStore)
        sut.exposeAndUpdateDraftOrderIdAndPaymentId(draftOrderId: draftOrderId, paymentId: paymentId)
        
        // Configuring expected actions on repositories
        mockedWebRepo.actions = .init(expected: [
            .verifyCheckoutcomPayment(
                draftOrderId: draftOrderId,
                businessId: businessProfile.id,
                paymentId: paymentId)
        ])
        
        let appsFlyerEventParameters: [String: Any] = [
            AFEventParamContentId:[2923969],
            "item_price":[10.5],
            "item_quantity":[1],
            "item_barcode":[""],
            AFEventParamCurrency:"GBP",
            AFEventParamQuantity:1,
            "delivery_cost":0.0,
            "payment_type":"checkoutcom",
            AFEventParamRevenue:23.3,
            AFEventParamPrice:23.3,
            "fulfilment_method":"delivery",
            "asap":false,
            "store_id":1569,
            "store_name":"Family Shopper Lochee",
            AFEventParamOrderId:15,
            AFEventParamReceiptId:15,
            "coupon_code":"ACME",
            "coupon_discount_amount":2.1,
            "campaign_id":3454356
        ]

        let facebookParams: [AppEvents.ParameterName: Any] = [
            .numItems: 1,
            .description: "business order 15",
            .orderID: "15",
            .content: "[{\"order_id\": \"15\"}, {\"id\": \"2923969\", \"quantity\":1, \"item_price\": 10.50}]"
        ]
        
        let firebaseEventParameters: [String: Any] = [
            "checkedOutTotalCost": 23.3,
            "currency":"GBP",
            "facebookParams": facebookParams
        ]
        
        mockedEventLogger.actions = .init(expected: [
            .sendEvent(for: .purchase, with: .appsFlyer, params: appsFlyerEventParameters),
            .sendEvent(for: .purchase, with: .facebook, params: firebaseEventParameters)
        ])
        
        // Configuring responses from repositories
        mockedWebRepo.verifyCheckoutcomPaymentResponse = .success(verifyPaymentResponse)
        
        do {
            try await sut.verifyCheckoutcomPayment()
        } catch {
            XCTFail("Unexpected error: \(error.localizedDescription)")
        }
        
        XCTAssertNil(sut.exposeDraftOrderId)
        XCTAssertNil(sut.exposeCheckoutcomPaymentId)
        mockedWebRepo.verify()
        mockedEventLogger.verify()
    }
    
    func test_givenMissingPaymentID_whenVerifyPayment_thenCorrectError() async {
        let draftOrderId = 1970016
        
        // Configuring app/sut prexisting states
        sut.exposeAndUpdateDraftOrderIdAndPaymentId(draftOrderId: draftOrderId, paymentId: nil)
        
        do {
            try await sut.verifyCheckoutcomPayment()
            
            XCTFail("Unexpected success")
        } catch {
            XCTAssertEqual(error as! CheckoutServiceError, CheckoutServiceError.paymentIdRequired)
        }
        
        mockedWebRepo.verify()
        mockedEventLogger.verify()
    }
    
    func test_givenMissingDraftOrderId_whenVerifyPayment_thenCorrectError() async {
        let paymentId = "pay_lq7znmvow65efgyqxrbhlrm6wm"
        
        // Configuring app/sut prexisting states
        sut.exposeAndUpdateDraftOrderIdAndPaymentId(draftOrderId: nil, paymentId: paymentId)
        
        do {
            try await sut.verifyCheckoutcomPayment()
            
            XCTFail("Unexpected success")
        } catch {
            XCTAssertEqual(error as! CheckoutServiceError, CheckoutServiceError.draftOrderRequired)
        }
        
        mockedWebRepo.verify()
        mockedEventLogger.verify()
    }
}

// MARK: - func confirmPayment()
final class ConfirmPaymentTests: CheckoutServiceTests {
    
    func test_successfulConfirmPayment_whenDraftOrder_thenConfirmPaymentResponse() async {
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
        
        let expectedLastDeliverOnDevice = LastDeliveryOrderOnDevice(
            businessOrderId: 2158,
            storeName: RetailStoreDetails.mockedData.storeName,
            storeContactNumber: RetailStoreDetails.mockedData.telephone,
            deliveryPostcode: nil)
        
        mockedDBRepo.actions = .init(expected: [
            .clearLastDeliveryOrderOnDevice,
            .store(lastDeliveryOrderOnDevice: expectedLastDeliverOnDevice),
            .clearBasket
        ])
        
        let appsFlyerEventParameters: [String: Any] = [
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
        
        let facebookParams: [AppEvents.ParameterName: Any] = [
            .numItems: 1,
            .description: "business order 2158",
            .orderID: "2158",
            .content: "[{\"order_id\": \"2158\"}, {\"id\": \"2923969\", \"quantity\":1, \"item_price\": 10.50}]"
        ]
        
        let firebaseEventParameters: [String: Any] = [
            "checkedOutTotalCost": 23.3,
            "currency":"GBP",
            "facebookParams": facebookParams
        ]
        
        mockedEventLogger.actions = .init(expected: [
            .sendEvent(for: .firstPurchase, with: .appsFlyer, params: appsFlyerEventParameters),
            .sendEvent(for: .firstPurchase, with: .facebook, params: firebaseEventParameters)
        ])
        
        // Configuring responses from repositories
        mockedWebRepo.createDraftOrderResponse = .success(draftOrderResult)
        mockedWebRepo.confirmPaymentResponse = .success(confirmPaymentResponseResult)
        
        do {
            
            let _ = try await sut
                .createDraftOrder(
                    fulfilmentDetails: DraftOrderFulfilmentDetailsRequest.mockedData,
                    paymentGatewayType: .realex,
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

final class lastBusinessOrderIdInCurrentSessionTests: CheckoutServiceTests {
    
    func test_lastBusinessOrderIdInCurrentSession_whenCashOrder_thenReturnBusinessOrderId() {
        let draftOrderResult = DraftOrderResult.mockedCashData
        
        // Configuring app prexisting states
        appState.value.userData.basket = Basket.mockedData
        appState.value.userData.selectedStore = .loaded(RetailStoreDetails.mockedData)

        // Configuring responses from repositories
        mockedWebRepo.createDraftOrderResponse = .success(draftOrderResult)
        
        let exp = XCTestExpectation(description: #function)
        sut
            .createDraftOrder(
                fulfilmentDetails: DraftOrderFulfilmentDetailsRequest.mockedData,
                paymentGatewayType: .cash,
                instructions: "Knock twice!"
            )
            .sinkToResult { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success:
                    XCTAssertEqual(self.sut.lastBusinessOrderIdInCurrentSession(), draftOrderResult.businessOrderId, file: #file, line: #line)
                case let .failure(error):
                    XCTFail("Unexpected error: \(error)", file: #file, line: #line)
                }
                exp.fulfill()
            }
            .store(in: &subscriptions)

        wait(for: [exp], timeout: 2)
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
