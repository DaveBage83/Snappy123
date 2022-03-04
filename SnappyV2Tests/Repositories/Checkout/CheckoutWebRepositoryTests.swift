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

        let parameters: [String: Any] = [
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
            "phoneNumber": "0798883241"
        ]

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
                firstname: "Harold",
                lastname: "Brown",
                emailAddress: "h.brown@gmail.com",
                phoneNumber: "0798883241"
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
    
    // MARK: - Helper
    
    private func mock<T>(_ apiCall: API, result: Result<T, Swift.Error>) throws where T: Encodable {
        let mock = try Mock(apiCall: apiCall, baseURL: sut.baseURL, result: result)
        RequestMocking.add(mock: mock)
    }
    
}
