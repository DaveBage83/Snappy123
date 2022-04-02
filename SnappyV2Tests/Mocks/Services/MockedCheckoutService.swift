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
            paymentGateway: PaymentGatewayType,
            instructions: String?
        )
        case getRealexHPPProducerData
        case processRealexHPPConsumerData(hppResponse: [String : Any])
        case confirmPayment
        case verifyPayment
        case getPlacedOrderDetails(businessOrderId: Int)
        case getPlacedOrderStatus(businessOrderId: Int)
        
        // required because processRealexHPPConsumerData(hppResponse: [String : Any]) is not Equatable
        static func == (lhs: MockedCheckoutService.Action, rhs: MockedCheckoutService.Action) -> Bool {
            switch (lhs, rhs) {

            case (
                let .createDraftOrder(lhsFulfilmentDetails, lhsPaymentGateway, lhsInstructions),
                let .createDraftOrder(rhsFulfilmentDetails, rhsPaymentGateway, rhsInstructions)):
                return lhsFulfilmentDetails == rhsFulfilmentDetails && lhsPaymentGateway == rhsPaymentGateway && lhsInstructions == rhsInstructions

            case (.getRealexHPPProducerData, .getRealexHPPProducerData):
                return true

            case (let .processRealexHPPConsumerData(lhsHppResponse), let .processRealexHPPConsumerData(rhsHppResponse)):
                return lhsHppResponse.isEqual(to: rhsHppResponse)

            case (.confirmPayment, .confirmPayment):
                return true

            case (.verifyPayment, .verifyPayment):
                return true

            default:
                return false
            }
        }
    }
    
    let actions: MockActions<Action>
    
    init(expected: [Action]) {
        self.actions = .init(expected: expected)
    }
    
    func createDraftOrder(
        fulfilmentDetails: DraftOrderFulfilmentDetailsRequest,
        paymentGateway: PaymentGatewayType,
        instructions: String?
    ) -> Future<(businessOrderId: Int?, savedCards: DraftOrderPaymentMethods?), Error> {
        register(
            .createDraftOrder(
                fulfilmentDetails: fulfilmentDetails,
                paymentGateway: paymentGateway,
                instructions: instructions
            )
        )
        return Future { $0(.success((businessOrderId: 123, savedCards: nil))) }
    }
    
    func getRealexHPPProducerData() -> Future<Data, Error> {
        register(
            .getRealexHPPProducerData
        )
        return Future { $0(.success(Data())) }
    }
    
    func processRealexHPPConsumerData(hppResponse: [String : Any]) -> Future<ShimmedPaymentResponse, Error> {
        register(
            .processRealexHPPConsumerData(hppResponse: hppResponse)
        )
        return Future { $0(
            .success(
                ShimmedPaymentResponse(
                    status: true,
                    message: nil,
                    orderId: nil,
                    businessOrderId: nil,
                    pointsEarned: nil,
                    iterableUserEmail: nil
                )
            )
        ) }
    }
    
    func confirmPayment() -> Future<ConfirmPaymentResponse, Error> {
        register(
            .confirmPayment
        )
        return Future { $0(
            .success(
                ConfirmPaymentResponse(
                    result: ShimmedPaymentResponse(
                        status: true,
                        message: nil,
                        orderId: nil,
                        businessOrderId: nil,
                        pointsEarned: nil,
                        iterableUserEmail: nil
                    )
                )
            )
        ) }
    }
    
    func verifyPayment() -> Future<ConfirmPaymentResponse, Error> {
        register(
            .verifyPayment
        )
        return Future { $0(
            .success(
                ConfirmPaymentResponse(
                    result: ShimmedPaymentResponse(
                        status: true,
                        message: nil,
                        orderId: nil,
                        businessOrderId: nil,
                        pointsEarned: nil,
                        iterableUserEmail: nil
                    )
                )
            )
        ) }
    }
    
    func getPlacedOrderDetails(orderDetails: LoadableSubject<PlacedOrder>, businessOrderId: Int) {
        register(
            .getPlacedOrderDetails(businessOrderId: businessOrderId)
        )
    }
    
    func getPlacedOrderStatus(status: LoadableSubject<PlacedOrderStatus>, businessOrderId: Int) {
        register(
            .getPlacedOrderStatus(businessOrderId: businessOrderId)
        )
    }
    
}
