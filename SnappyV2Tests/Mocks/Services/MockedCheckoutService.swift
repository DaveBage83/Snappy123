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
    
    var currentDraftOrderIdResult: Int?
    var processNewCardPaymentOrderResult: (Int?, CheckoutCom3DSURLs?) = (nil, nil)
    var processSavedCardPaymentOrderResult: (Int?, CheckoutCom3DSURLs?) = (nil, nil)
    var processApplePaymentOrderResult: Result<Int?, Error> = .failure(MockError.valueNotSet)
    var driverLocationResult: Result<DriverLocation, Error> = .failure(MockError.valueNotSet)
    
    enum Action: Equatable {
        case currentDraftOrderId
        case createDraftOrder(
            fulfilmentDetails: DraftOrderFulfilmentDetailsRequest,
            paymentGateway: PaymentGatewayType,
            instructions: String?
        )
        case getRealexHPPProducerData
        case processRealexHPPConsumerData(hppResponse: [String : Any], firstOrder: Bool)
        case confirmPayment(firstOrder: Bool)
        case verifyPayment
        case processApplePaymentOrder(fulfilmentDetails: DraftOrderFulfilmentDetailsRequest, paymentGatewayType: PaymentGatewayType, paymentGatewayMode: PaymentGatewayMode, instructions: String?, publicKey: String, merchantId: String)
        case processNewCardPaymentOrder(fulfilmentDetails: DraftOrderFulfilmentDetailsRequest, paymentGatewayType: PaymentGatewayType, paymentGatewayMode: PaymentGatewayMode, instructions: String?, publicKey: String, cardDetails: CheckoutCardDetails)
        case processSavedCardPaymentOrder(fulfilmentDetails: DraftOrderFulfilmentDetailsRequest, paymentGatewayType: PaymentGatewayType, paymentGatewayMode: PaymentGatewayMode, instructions: String?, publicKey: String, cardId: String, cvv: String)
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

            case (.currentDraftOrderId, .currentDraftOrderId):
                return true
            case (
                let .createDraftOrder(lhsFulfilmentDetails, lhsPaymentGateway, lhsInstructions),
                let .createDraftOrder(rhsFulfilmentDetails, rhsPaymentGateway, rhsInstructions)):
                return lhsFulfilmentDetails == rhsFulfilmentDetails && lhsPaymentGateway == rhsPaymentGateway && lhsInstructions == rhsInstructions
            case (
                let .processApplePaymentOrder(lhsFulfilmentDetails, lhsPaymentGatewayType, lhsPaymentGatewayMode, lhsInstructions, lhsPublicKey, lhsMerchantId),
                let .processApplePaymentOrder(rhsFulfilmentDetails, rhsPaymentGatewayType, rhsPaymentGatewayMode, rhsInstructions, rhsPublicKey, rhsMerchantId)):
                return lhsFulfilmentDetails == rhsFulfilmentDetails && lhsPaymentGatewayType == rhsPaymentGatewayType && lhsPaymentGatewayMode == rhsPaymentGatewayMode && lhsInstructions == rhsInstructions && lhsPublicKey == rhsPublicKey && lhsMerchantId == rhsMerchantId
                
            case (
                let .processNewCardPaymentOrder(lhsFulfilmentDetails, lhsPaymentGatewayType, lhsPaymentGatewayMode, lhsInstructions, lhsPublicKey, lhsCardDetails),
                let .processNewCardPaymentOrder(rhsFulfilmentDetails, rhsPaymentGatewayType, rhsPaymentGatewayMode, rhsInstructions, rhsPublicKey, rhsCardDetails)):
                return lhsFulfilmentDetails == rhsFulfilmentDetails && lhsPaymentGatewayType == rhsPaymentGatewayType && lhsPaymentGatewayMode == rhsPaymentGatewayMode && lhsInstructions == rhsInstructions && lhsPublicKey == rhsPublicKey && lhsCardDetails == rhsCardDetails

            case (
                let .processSavedCardPaymentOrder(lhsFulfilmentDetails, lhsPaymentGatewayType, lhsPaymentGatewayMode, lhsInstructions, lhsPublicKey, lhsCardId, lhsCVV),
                let .processSavedCardPaymentOrder(rhsFulfilmentDetails, rhsPaymentGatewayType, rhsPaymentGatewayMode, rhsInstructions, rhsPublicKey, rhsCardId, rhsCVV)):
                return lhsFulfilmentDetails == rhsFulfilmentDetails && lhsPaymentGatewayType == rhsPaymentGatewayType && lhsPaymentGatewayMode == rhsPaymentGatewayMode && lhsInstructions == rhsInstructions && lhsPublicKey == rhsPublicKey && lhsCardId == rhsCardId && lhsCVV == rhsCVV
                
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
    
    var currentDraftOrderId: Int? {
        register(.currentDraftOrderId)
        return currentDraftOrderIdResult
    }
    
    func createDraftOrder(
        fulfilmentDetails: DraftOrderFulfilmentDetailsRequest,
        paymentGatewayType paymentGateway: PaymentGatewayType,
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
    
    func verifyCheckoutcomPayment() async throws {
        register(
            .verifyPayment
        )
    }
    
    func processApplePaymentOrder(fulfilmentDetails: DraftOrderFulfilmentDetailsRequest, paymentGatewayType: PaymentGatewayType, paymentGatewayMode: PaymentGatewayMode, instructions: String?, publicKey: String, merchantId: String) async throws -> Int? {
        register(
            .processApplePaymentOrder(fulfilmentDetails: fulfilmentDetails, paymentGatewayType: paymentGatewayType, paymentGatewayMode: paymentGatewayMode, instructions: instructions, publicKey: publicKey, merchantId: merchantId)
        )
        switch processApplePaymentOrderResult {
        case .success(let result):
            return result
        case .failure(let error):
            throw error
        }
    }
    
    func processNewCardPaymentOrder(fulfilmentDetails: DraftOrderFulfilmentDetailsRequest, paymentGatewayType: PaymentGatewayType, paymentGatewayMode: PaymentGatewayMode, instructions: String?, publicKey: String, cardDetails: CheckoutCardDetails, saveCardPaymentHandler: ((String) async throws -> ())?) async throws ->  (Int?, CheckoutCom3DSURLs?) {
        register(.processNewCardPaymentOrder(fulfilmentDetails: fulfilmentDetails, paymentGatewayType: paymentGatewayType, paymentGatewayMode: paymentGatewayMode, instructions: instructions, publicKey: publicKey, cardDetails: cardDetails))
        return processNewCardPaymentOrderResult
    }
    
    func processSavedCardPaymentOrder(fulfilmentDetails: DraftOrderFulfilmentDetailsRequest, paymentGatewayType: PaymentGatewayType, paymentGatewayMode: PaymentGatewayMode, instructions: String?, publicKey: String, cardId: String, cvv: String) async throws -> (Int?, CheckoutCom3DSURLs?) {
        register(.processSavedCardPaymentOrder(fulfilmentDetails: fulfilmentDetails, paymentGatewayType: paymentGatewayType, paymentGatewayMode: paymentGatewayMode, instructions: instructions, publicKey: publicKey, cardId: cardId, cvv: cvv))
        return processSavedCardPaymentOrderResult
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
        switch driverLocationResult {
        case .success(let result):
            return result
        case .failure(let error):
            throw error
        }
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
