//
//  MockedCheckoutWebRepository.swift
//  SnappyV2Tests
//
//  Created by Kevin Palser on 07/02/2022.
//

import XCTest
import Combine
@testable import SnappyV2

final class MockedCheckoutWebRepository: TestWebRepository, Mock, CheckoutWebRepositoryProtocol {

    enum Action: Equatable {
        case createDraftOrder(basketToken: String, fulfilmentDetails: DraftOrderFulfilmentDetailsRequest, instructions: String?, paymentGateway: PaymentGateway, storeId: Int, firstname: String, lastname: String, emailAddress: String, phoneNumber: String)
    }
    var actions = MockActions<Action>(expected: [])
    
    var createDraftOrderResponse: Result<DraftOrderResult, Error> = .failure(MockError.valueNotSet)
    
    func createDraftOrder(
        basketToken: String,
        fulfilmentDetails: DraftOrderFulfilmentDetailsRequest,
        instructions: String?,
        paymentGateway: PaymentGateway,
        storeId: Int,
        firstname: String,
        lastname: String,
        emailAddress: String,
        phoneNumber: String
    ) -> AnyPublisher<DraftOrderResult, Error> {
        register(
            .createDraftOrder(
                basketToken: basketToken,
                fulfilmentDetails: fulfilmentDetails,
                instructions: instructions,
                paymentGateway: paymentGateway,
                storeId: storeId,
                firstname: firstname,
                lastname: lastname,
                emailAddress: emailAddress,
                phoneNumber: phoneNumber
            )
        )
        return createDraftOrderResponse.publish()
    }

}
