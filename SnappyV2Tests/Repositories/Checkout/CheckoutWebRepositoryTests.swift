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
            "paymentGateway": PaymentGateway.cash.rawValue,
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
    
    // MARK: - Helper
    
    private func mock<T>(_ apiCall: API, result: Result<T, Swift.Error>) throws where T: Encodable {
        let mock = try Mock(apiCall: apiCall, baseURL: sut.baseURL, result: result)
        RequestMocking.add(mock: mock)
    }
    
}
