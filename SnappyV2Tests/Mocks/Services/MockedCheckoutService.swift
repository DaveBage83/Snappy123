//
//  MockedCheckoutService.swift
//  SnappyV2Tests
//
//  Created by Kevin Palser on 07/02/2022.
//

import XCTest
import Combine
@testable import SnappyV2

class MockedCheckoutService: Mock, CheckoutServiceProtocol {
    
    enum Action: Equatable {
        case createDraftOrder(
            fulfilmentDetails: DraftOrderFulfilmentDetailsRequest,
            paymentGateway: PaymentGateway,
            instructions: String?,
            firstname: String,
            lastname: String,
            emailAddress: String,
            phoneNumber: String
        )
    }
    
    let actions: MockActions<Action>
    
    init(expected: [Action]) {
        self.actions = .init(expected: expected)
    }
    
    func createDraftOrder(
        fulfilmentDetails: DraftOrderFulfilmentDetailsRequest,
        paymentGateway: PaymentGateway,
        instructions: String?,
        firstname: String,
        lastname: String,
        emailAddress: String,
        phoneNumber: String
    ) -> Future<(businessOrderId: Int?, savedCards: DraftOrderPaymentMethods?), Error> {
        register(
            .createDraftOrder(
                fulfilmentDetails: fulfilmentDetails,
                paymentGateway: paymentGateway,
                instructions: instructions,
                firstname: firstname,
                lastname: lastname,
                emailAddress: emailAddress,
                phoneNumber: phoneNumber
            )
        )
        return Future { $0(.success((businessOrderId: nil, savedCards: nil))) }
    }
    
}
