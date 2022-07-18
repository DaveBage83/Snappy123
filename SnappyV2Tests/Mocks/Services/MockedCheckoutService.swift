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
        case processRealexHPPConsumerData(hppResponse: [String : Any], firstOrder: Bool)
        case confirmPayment(firstOrder: Bool)
        case verifyPayment
        case getPlacedOrderDetails(businessOrderId: Int)
        case getPlacedOrderStatus(businessOrderId: Int)
        case getDriverLocation(businessOrderId: Int)
        case getLastDeliveryOrderDriverLocation
        case clearLastDeliveryOrderOnDevice
        case lastBusinessOrderIdInCurrentSession
        case addTestLastDeliveryOrderDriverLocation
        
        // required because processRealexHPPConsumerData(hppResponse: [String : Any]) is not Equatable
        static func == (lhs: MockedCheckoutService.Action, rhs: MockedCheckoutService.Action) -> Bool {
            switch (lhs, rhs) {

            case (
                let .createDraftOrder(lhsFulfilmentDetails, lhsPaymentGateway, lhsInstructions),
                let .createDraftOrder(rhsFulfilmentDetails, rhsPaymentGateway, rhsInstructions)):
                return lhsFulfilmentDetails == rhsFulfilmentDetails && lhsPaymentGateway == rhsPaymentGateway && lhsInstructions == rhsInstructions

            case (.getRealexHPPProducerData, .getRealexHPPProducerData):
                return true

            case (let .processRealexHPPConsumerData(lhsHppResponse, lhsFirstOrderResponse), let .processRealexHPPConsumerData(rhsHppResponse, rhsFirstOrderResponse)):
                return lhsHppResponse.isEqual(to: rhsHppResponse) && lhsFirstOrderResponse == rhsFirstOrderResponse

            case (.confirmPayment(let lhsFirstOrderResponse), .confirmPayment(let rhsFirstOrderResponse)):
                return lhsFirstOrderResponse == rhsFirstOrderResponse

            case (.verifyPayment, .verifyPayment):
                return true
                
            case (
                let .getPlacedOrderDetails(lhsBusinessOrderId),
                let .getPlacedOrderDetails(rhsBusinessOrderId)):
                return lhsBusinessOrderId == rhsBusinessOrderId
                
            case (
                let .getPlacedOrderStatus(lhsBusinessOrderId),
                let .getPlacedOrderStatus(rhsBusinessOrderId)):
                return lhsBusinessOrderId == rhsBusinessOrderId
                
            case (
                let .getDriverLocation(lhsBusinessOrderId),
                let .getDriverLocation(rhsBusinessOrderId)):
                return lhsBusinessOrderId == rhsBusinessOrderId
                
            case (.getLastDeliveryOrderDriverLocation, .getLastDeliveryOrderDriverLocation):
                return true
                
            case (.clearLastDeliveryOrderOnDevice, .clearLastDeliveryOrderOnDevice):
                return true
                
            case (.lastBusinessOrderIdInCurrentSession, .lastBusinessOrderIdInCurrentSession):
                return true
                
            case (.addTestLastDeliveryOrderDriverLocation, .addTestLastDeliveryOrderDriverLocation):
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
    ) -> Future<(businessOrderId: Int?, savedCards: DraftOrderPaymentMethods?, firstOrder: Bool), Error> {
        register(
            .createDraftOrder(
                fulfilmentDetails: fulfilmentDetails,
                paymentGateway: paymentGateway,
                instructions: instructions
            )
        )
        return Future { $0(.success((businessOrderId: 123, savedCards: nil, firstOrder: false))) }
    }
    
    func getRealexHPPProducerData() -> Future<Data, Error> {
        register(
            .getRealexHPPProducerData
        )
        return Future { $0(.success(Data())) }
    }
    
    func processRealexHPPConsumerData(hppResponse: [String : Any], firstOrder: Bool) -> Future<ShimmedPaymentResponse, Error> {
        register(
            .processRealexHPPConsumerData(hppResponse: hppResponse, firstOrder: firstOrder)
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
    
    func confirmPayment(firstOrder: Bool) -> Future<ConfirmPaymentResponse, Error> {
        register(
            .confirmPayment(firstOrder: firstOrder)
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
    
    func getDriverLocation(businessOrderId: Int) async throws -> DriverLocation {
        register(
            .getDriverLocation(businessOrderId: businessOrderId)
        )
        return DriverLocation.mockedDataEnRoute
    }
    
    func getLastDeliveryOrderDriverLocation() async throws -> DriverLocationMapParameters? {
        register(
            .getLastDeliveryOrderDriverLocation
        )
        return DriverLocationMapParameters.mockedWithLastOrderData
    }
    
    func clearLastDeliveryOrderOnDevice() async throws {
        register(
            .clearLastDeliveryOrderOnDevice
        )
    }
    
    func lastBusinessOrderIdInCurrentSession() -> Int? {
        register(.lastBusinessOrderIdInCurrentSession)
        return nil
    }
    
    func addTestLastDeliveryOrderDriverLocation() async throws {
        register(
            .addTestLastDeliveryOrderDriverLocation
        )
    }
    
}
