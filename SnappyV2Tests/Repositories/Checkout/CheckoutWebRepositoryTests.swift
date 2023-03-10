//
//  CheckoutWebRepositoryTests.swift
//  SnappyV2Tests
//
//  Created by Kevin Palser on 10/02/2022.
//

import XCTest
import Combine
@testable import SnappyV2

final class CheckoutWebRepositoryTests: XCTestCase {
    
    private var sut: CheckoutWebRepository!
    private var subscriptions = Set<AnyCancellable>()
    
    typealias API = CheckoutWebRepository.API
    typealias Mock = RequestMocking.MockedResponse

    override func setUp() {
        subscriptions = Set<AnyCancellable>()
        sut = CheckoutWebRepository(
            networkHandler: .mockedResponsesOnly,
            baseURL: "https://test.com/"
        )
    }

    override func tearDown() {
        RequestMocking.removeAllMocks()
    }
    
    // MARK: - createDraftOrder(basketToken:fulfilmentDetails:instructions:paymentGateway:storeId:firstname:lastname:emailAddress:phoneNumber: String)
    
    func test_createDraftOrder() throws {

        let data = DraftOrderResult.mockedCashData

        var parameters: [String: Any] = [
            "basketToken": "8c6f3a9a1f2ffa9e93a9ec2920a4a911",
            "fulfilmentDetails": DraftOrderFulfilmentDetailsRequest(
                time: DraftOrderFulfilmentDetailsTimeRequest(
                    date: "2022-02-11",
                    requestedTime: "10:15 - 10:30"
                ),
                place: nil
            ),
            "instructions": "knock twice",
            "paymentGateway": PaymentGatewayType.cash.rawValue,
            "storeId": 910,
            "firstname": "Harold",
            "lastname": "Brown",
            "emailAddress": "h.brown@gmail.com",
            "phoneNumber": "0798883241",
            "platform": AppV2Constants.Client.platform,
            "messagingDeviceId": "740f4707bebcf74f9b7c25d48e3358945f6aa01da5ddb387462c7eaf61bb78ad"
        ]
        
        if let deviceIdentifier = AppV2Constants.Client.deviceIdentifier {
            parameters["deviceId"] = deviceIdentifier
        }

        try mock(.createDraftOrder(parameters), result: .success(data))
        let exp = XCTestExpectation(description: "Completion")

        sut
            .createDraftOrder(
                basketToken: "8c6f3a9a1f2ffa9e93a9ec2920a4a911",
                fulfilmentDetails: DraftOrderFulfilmentDetailsRequest(
                    time: DraftOrderFulfilmentDetailsTimeRequest(
                        date: "2022-02-11",
                        requestedTime: "10:15 - 10:30"
                    ),
                    place: nil
                ),
                instructions: "knock twice",
                paymentGateway: .cash,
                storeId: 910,
                notificationDeviceToken: "740f4707bebcf74f9b7c25d48e3358945f6aa01da5ddb387462c7eaf61bb78ad"
            )
            .sinkToResult { result in
                result.assertSuccess(value: data)
                exp.fulfill()
            }.store(in: &subscriptions)

        wait(for: [exp], timeout: 2)
    }
    
    // MARK: - getRealexHPPProducerData(orderId:)
    
    func test_getRealexHPPProducerData() throws {
        
        let data = Data.mockedGlobalpaymentsProducerData
        
        let parameters: [String: Any] = [
            "orderId": 2567547
        ]

        try mock(.getRealexHPPProducerData(parameters), result: .success(data))
        let exp = XCTestExpectation(description: "Completion")

        sut
            .getRealexHPPProducerData(orderId: 2567547)
            .sinkToResult { result in
                result.assertSuccess(value: data)
                exp.fulfill()
            }.store(in: &subscriptions)

        wait(for: [exp], timeout: 2)
    }
    
    // MARK: - processRealexHPPConsumerData(orderId:hppResponse:)
    
    func test_processRealexHPPConsumerData() throws {
        
        let data = ConfirmPaymentResponse.mockedData
        
        let hppResponse = [String: Any].mockedGlobalpaymentsHPPResponse
        
        let parameters: [String: Any] = [
            "orderId": 2567547,
            "hppResponse": hppResponse,
            "displayFlat": false,
            "stringOnlyResults": false
        ]

        try mock(.processRealexHPPConsumerData(parameters), result: .success(data))
        let exp = XCTestExpectation(description: "Completion")

        sut
            .processRealexHPPConsumerData(
                orderId: 2567547,
                hppResponse: hppResponse
            )
            .sinkToResult { result in
                result.assertSuccess(value: data)
                exp.fulfill()
            }.store(in: &subscriptions)

        wait(for: [exp], timeout: 2)
    }
    
    // MARK: - confirmPayment(orderId:)
    
    func test_confirmPayment() throws {
        
        let data = ConfirmPaymentResponse.mockedData
        
        let parameters: [String: Any] = [
            "orderId": 2567547
        ]

        try mock(.confirmPayment(parameters), result: .success(data))
        let exp = XCTestExpectation(description: "Completion")

        sut
            .confirmPayment(
                orderId: 2567547
            )
            .sinkToResult { result in
                result.assertSuccess(value: data)
                exp.fulfill()
            }.store(in: &subscriptions)

        wait(for: [exp], timeout: 2)
    }
    
    // MARK: - makePayment(draftOrderId:type:paymentMethod:token:cardId:cvv:)
    func test_makePayment() async throws {
        let data = MakePaymentResponse.mockedData3DSChallenge
        
        let parameters: [String: Any] = [
            "draftOrderId": 1970016,
            "paymentMethod": "card",
            "type": "token",
            "token": "tok_lkxmbfnaowmuxmcirpz7p23wuq",
            "businessId": 15
        ]
        
        try mock(.makePayment(parameters), result: .success(data))
        
        let result = try await sut.makePayment(
                draftOrderId: 1970016,
                type: .token,
                paymentMethod: "card",
                token: "tok_lkxmbfnaowmuxmcirpz7p23wuq",
                cardId: nil,
                cvv: nil)
        
        XCTAssertEqual(result, data)
    }
    
    // MARK: - verifyCheckoutcomPayment(draftOrderId:businessId:paymentId:)
    func test_verifyCheckoutcomPayment() async throws {
        let data = VerifyPaymentResponse.mockedData
        
        let parameters: [String: Any] = [
            "businessId": 15,
            "paymentId": "pay_lq7znmvow65efgyqxrbhlrm6wm",
            "draftOrderId": 1970016
        ]
        
        try mock(.verifyCheckoutcomPayment(parameters), result: .success(data))
        
        let result = try await sut.verifyCheckoutcomPayment(
            draftOrderId: 1970016,
            businessId: 15,
            paymentId: "pay_lq7znmvow65efgyqxrbhlrm6wm"
        )
        
        XCTAssertEqual(result, data)
    }
    
    // MARK: - getPlacedOrderStatus(forBusinessOrderId:)
    
    func test_getPlacedOrderStatus() throws {
        
        let data = PlacedOrderStatus.mockedData
        
        let parameters: [String: Any] = [
            "businessId": AppV2Constants.Business.id,
            "businessOrderId": 2106
        ]

        try mock(.getPlacedOrderStatus(parameters), result: .success(data))
        let exp = XCTestExpectation(description: "Completion")

        sut
            .getPlacedOrderStatus(forBusinessOrderId: 2106)
            .sinkToResult { result in
                result.assertSuccess(value: data)
                exp.fulfill()
            }.store(in: &subscriptions)

        wait(for: [exp], timeout: 2)
    }
    
    // MARK: - getDriverLocation(forBusinessOrderId:)
    
    func test_getDriverLocation() async {
    
        let data = DriverLocation.mockedDataEnRoute

        let parameters: [String: Any] = [
            "businessOrderId": 2106
        ]

        do {
            try mock(.getDriverLocation(parameters), result: .success(data))
            let result = try await sut
                .getDriverLocation(forBusinessOrderId: 2106)
            XCTAssertEqual(data, result, file: #file, line: #line)
        } catch {
            XCTFail("Unexpected error: \(error)", file: #file, line: #line)
        }
        
    }
    
    // MARK: - getOrder(forBusinessOrderId:hash)
    
    func test_getOrder() async {
    
        let data = PlacedOrder.mockedData
        let hash = "bf456eaf4556adc345ea"

        let parameters: [String: Any] = [
            "businessOrderId": data.businessOrderId,
            "hash": hash
        ]

        do {
            try mock(.getOrderByHash(parameters), result: .success(data))
            let result = try await sut
                .getOrder(forBusinessOrderId: data.businessOrderId, withHash: hash)
            XCTAssertEqual(data, result, file: #file, line: #line)
        } catch {
            XCTFail("Unexpected error: \(error)", file: #file, line: #line)
        }
        
    }
    
    // MARK: - Helper
    
    private func mock<T>(_ apiCall: API, result: Result<T, Swift.Error>) throws where T: Encodable {
        let mock = try Mock(apiCall: apiCall, baseURL: sut.baseURL, result: result)
        RequestMocking.add(mock: mock)
    }
    
}
