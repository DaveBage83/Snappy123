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
        case createDraftOrder(basketToken: String, fulfilmentDetails: DraftOrderFulfilmentDetailsRequest, instructions: String?, paymentGateway: PaymentGatewayType, storeId: Int)
        case getRealexHPPProducerData(orderId: Int)
        case processRealexHPPConsumerData(orderId: Int, hppResponse: [String: Any])
        case confirmPayment(orderId: Int)
        case verifyPayment(orderId: Int)
        case getPlacedOrderStatus(forBusinessOrderId: Int)
    
        // required because processRealexHPPConsumerData(hppResponse: [String : Any]) is not Equatable
        static func == (lhs: MockedCheckoutWebRepository.Action, rhs: MockedCheckoutWebRepository.Action) -> Bool {
            switch (lhs, rhs) {

            case (
                let .createDraftOrder(lhsBasketToken, lhsFulfilmentDetails, lhsInstructions, lhsPaymentGateway, lhsStoreId),
                let .createDraftOrder(rhsBasketToken, rhsFulfilmentDetails, rhsInstructions, rhsPaymentGateway, rhsStoreId)):
                return lhsBasketToken == rhsBasketToken && lhsFulfilmentDetails == rhsFulfilmentDetails && lhsPaymentGateway == rhsPaymentGateway && lhsStoreId == rhsStoreId && lhsInstructions == rhsInstructions

            case (.getRealexHPPProducerData, .getRealexHPPProducerData):
                return true

            case (let .processRealexHPPConsumerData(lhsOrderId, lhsHppResponse), let .processRealexHPPConsumerData(rhsOrderId, rhsHppResponse)):
                return lhsOrderId == rhsOrderId && lhsHppResponse.isEqual(to: rhsHppResponse)

            case (.confirmPayment, .confirmPayment):
                return true

            case (.verifyPayment, .verifyPayment):
                return true
                
            case (.getPlacedOrderStatus, .getPlacedOrderStatus):
                return true

            default:
                return false
            }
        }
    }
    var actions = MockActions<Action>(expected: [])
    
    var createDraftOrderResponse: Result<DraftOrderResult, Error> = .failure(MockError.valueNotSet)
    var getRealexHPPProducerDataResponse: Result<Data, Error> = .failure(MockError.valueNotSet)
    var processRealexHPPConsumerDataResponse: Result<ConfirmPaymentResponse, Error> = .failure(MockError.valueNotSet)
    var confirmPaymentResponse: Result<ConfirmPaymentResponse, Error> = .failure(MockError.valueNotSet)
    var verifyPaymentResponse: Result<ConfirmPaymentResponse, Error> = .failure(MockError.valueNotSet)
    var getPlacedOrderStatusResponse: Result<PlacedOrderStatus, Error> = .failure(MockError.valueNotSet)
    
    func createDraftOrder(
        basketToken: String,
        fulfilmentDetails: DraftOrderFulfilmentDetailsRequest,
        instructions: String?,
        paymentGateway: PaymentGatewayType,
        storeId: Int
    ) -> AnyPublisher<DraftOrderResult, Error> {
        register(
            .createDraftOrder(
                basketToken: basketToken,
                fulfilmentDetails: fulfilmentDetails,
                instructions: instructions,
                paymentGateway: paymentGateway,
                storeId: storeId
            )
        )
        return createDraftOrderResponse.publish()
    }
    
    func getRealexHPPProducerData(orderId: Int) -> AnyPublisher<Data, Error> {
        register(
            .getRealexHPPProducerData(orderId: orderId)
        )
        return getRealexHPPProducerDataResponse.publish()
    }
    
    func processRealexHPPConsumerData(orderId: Int, hppResponse: [String: Any]) -> AnyPublisher<ConfirmPaymentResponse, Error> {
        register(
            .processRealexHPPConsumerData(orderId: orderId, hppResponse: hppResponse)
        )
        return processRealexHPPConsumerDataResponse.publish()
    }

    func confirmPayment(orderId: Int) -> AnyPublisher<ConfirmPaymentResponse, Error> {
        register(
            .confirmPayment(orderId: orderId)
        )
        return confirmPaymentResponse.publish()
    }
    
    func verifyPayment(orderId: Int) -> AnyPublisher<ConfirmPaymentResponse, Error> {
        register(
            .verifyPayment(orderId: orderId)
        )
        return verifyPaymentResponse.publish()
    }
    
    func getPlacedOrderStatus(forBusinessOrderId businessOrderId: Int) -> AnyPublisher<PlacedOrderStatus, Error> {
        register(
            .getPlacedOrderStatus(forBusinessOrderId: businessOrderId)
        )
        return getPlacedOrderStatusResponse.publish()
    }

}
