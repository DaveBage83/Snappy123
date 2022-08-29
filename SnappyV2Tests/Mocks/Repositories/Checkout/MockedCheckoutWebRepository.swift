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
        case verifyCheckoutcomPayment(draftOrderId: Int, businessId: Int, paymentId: String)
        case makePayment(orderId: Int, type: PaymentType, paymentMethod: String, token: String?, cardId: String?, cvv: Int?)
        case getPlacedOrderStatus(forBusinessOrderId: Int)
        case getDriverLocation(forBusinessOrderId: Int)
    
        // required because processRealexHPPConsumerData(hppResponse: [String : Any]) is not Equatable
        static func == (lhs: MockedCheckoutWebRepository.Action, rhs: MockedCheckoutWebRepository.Action) -> Bool {
            switch (lhs, rhs) {

            case (
                let .createDraftOrder(lhsBasketToken, lhsFulfilmentDetails, lhsInstructions, lhsPaymentGateway, lhsStoreId),
                let .createDraftOrder(rhsBasketToken, rhsFulfilmentDetails, rhsInstructions, rhsPaymentGateway, rhsStoreId)):
                return lhsBasketToken == rhsBasketToken && lhsFulfilmentDetails == rhsFulfilmentDetails && lhsPaymentGateway == rhsPaymentGateway && lhsStoreId == rhsStoreId && lhsInstructions == rhsInstructions
                
            case (
                let .makePayment(lhsOrderId, lhsType, lhsPaymentMethod, lhsToken, lhsCardId, lhsCVV),
                let .makePayment(rhsOrderId, rhsType, rhsPaymentMethod, rhsToken, rhsCardId, rhsCVV)):
                return lhsOrderId == rhsOrderId && lhsType == rhsType && lhsPaymentMethod == rhsPaymentMethod && lhsToken == rhsToken && lhsCardId == rhsCardId && lhsCVV == rhsCVV

            case (.getRealexHPPProducerData, .getRealexHPPProducerData):
                return true

            case (let .processRealexHPPConsumerData(lhsOrderId, lhsHppResponse), let .processRealexHPPConsumerData(rhsOrderId, rhsHppResponse)):
                return lhsOrderId == rhsOrderId && lhsHppResponse.isEqual(to: rhsHppResponse)

            case (.confirmPayment, .confirmPayment):
                return true

            case (let .verifyCheckoutcomPayment(lhsDraftOrderId, lhsBusinessId, lhsPaymentId), let .verifyCheckoutcomPayment(rhsDraftOrderId, rhsBusinessId, rhsPaymentId)):
                return lhsDraftOrderId == rhsDraftOrderId && lhsBusinessId == rhsBusinessId && lhsPaymentId == rhsPaymentId
                
            case (let .getPlacedOrderStatus(lhsBusinessOrderId), let .getPlacedOrderStatus(rhsBusinessOrderId)):
                return lhsBusinessOrderId == rhsBusinessOrderId
                
            case (let .getDriverLocation(lhsBusinessOrderId), let .getDriverLocation(rhsBusinessOrderId)):
                return lhsBusinessOrderId == rhsBusinessOrderId

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
    var verifyCheckoutcomPaymentResponse: Result<VerifyPaymentResponse, Error> = .failure(MockError.valueNotSet)
    var getPlacedOrderStatusResponse: Result<PlacedOrderStatus, Error> = .failure(MockError.valueNotSet)
    var getDriverLocationResponse: Result<DriverLocation, Error> = .failure(MockError.valueNotSet)
    var makePaymentResponse: MakePaymentResponse = MakePaymentResponse(gatewayData: GatewayData(id: nil, status: nil, gateway: nil, saveCard: nil, paymentMethod: nil, approved: nil, _links: nil), order: Order(draftOrderId: 0, businessOrderId: nil, pointsEarned: nil, message: nil))
    
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
    
    func verifyCheckoutcomPayment(draftOrderId: Int, businessId: Int, paymentId: String) async throws -> VerifyPaymentResponse {
        register(
            .verifyCheckoutcomPayment(draftOrderId: draftOrderId, businessId: businessId, paymentId: paymentId)
        )
        return try await verifyCheckoutcomPaymentResponse.publish().singleOutput()
    }
    
    func makePayment(draftOrderId: Int, type: PaymentType, paymentMethod: String, token: String?, cardId: String?, cvv: Int?) async throws -> MakePaymentResponse {
        register(
            .makePayment(orderId: draftOrderId, type: type, paymentMethod: paymentMethod, token: token, cardId: cardId, cvv: cvv)
        )
        return makePaymentResponse
    }
    
    func getPlacedOrderStatus(forBusinessOrderId businessOrderId: Int) -> AnyPublisher<PlacedOrderStatus, Error> {
        register(
            .getPlacedOrderStatus(forBusinessOrderId: businessOrderId)
        )
        return getPlacedOrderStatusResponse.publish()
    }
    
    func getDriverLocation(forBusinessOrderId businessOrderId: Int) async throws -> DriverLocation {
        register(
            .getDriverLocation(forBusinessOrderId: businessOrderId)
        )
        switch getDriverLocationResponse {
        case let .success(driverLocation):
            return driverLocation
        case let .failure(error):
            throw error
        }
    }

}
