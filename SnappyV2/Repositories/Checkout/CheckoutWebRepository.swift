//
//  CheckoutWebRepository.swift
//  SnappyV2
//
//  Created by Kevin Palser on 04/02/2022.
//

import Foundation
import Combine

protocol CheckoutWebRepositoryProtocol: WebRepository {
    
    func createDraftOrder(
        basketToken: String,
        fulfilmentDetails: DraftOrderFulfilmentDetailsRequest,
        instructions: String?,
        paymentGateway: PaymentGatewayType,
        storeId: Int,
        notificationDeviceToken: String?
    ) -> AnyPublisher<DraftOrderResult, Error>
    
    func getRealexHPPProducerData(orderId: Int) -> AnyPublisher<Data, Error>
    
    func processRealexHPPConsumerData(orderId: Int, hppResponse: [String: Any]) -> AnyPublisher<ConfirmPaymentResponse, Error>
    
    func confirmPayment(orderId: Int) -> AnyPublisher<ConfirmPaymentResponse, Error>
    
    func verifyCheckoutcomPayment(draftOrderId: Int, businessId: Int, paymentId: String) async throws -> VerifyPaymentResponse
    
    func makePayment(draftOrderId: Int, type: PaymentType, paymentMethod: String, token: String?, cardId: String?, cvv: Int?) async throws -> MakePaymentResponse
    
    func getPlacedOrderStatus(forBusinessOrderId businessOrderId: Int) -> AnyPublisher<PlacedOrderStatus, Error>
    
    func getDriverLocation(forBusinessOrderId: Int) async throws -> DriverLocation
    
    func getOrder(forBusinessOrderId: Int, withHash: String) async throws -> PlacedOrder
    
    func setPreviousOrderedDeviceState(deviceCheckToken: String) async throws -> SetPreviousOrderedDeviceStateResult
}

struct CheckoutWebRepository: CheckoutWebRepositoryProtocol {

    let networkHandler: NetworkHandler
    let baseURL: String
    
    init(networkHandler: NetworkHandler, baseURL: String) {
        self.networkHandler = networkHandler
        self.baseURL = baseURL
    }
    
    func createDraftOrder(
        basketToken: String,
        fulfilmentDetails: DraftOrderFulfilmentDetailsRequest,
        instructions: String?,
        paymentGateway: PaymentGatewayType,
        storeId: Int,
        notificationDeviceToken: String?
    ) -> AnyPublisher<DraftOrderResult, Error> {
        
        var parameters: [String: Any] = [
            "businessId": AppV2Constants.Business.id,
            "basketToken": basketToken,
            "fulfilmentDetails": fulfilmentDetails,
            "channel": AppV2Constants.Client.platform,
            "paymentGateway": paymentGateway.rawValue,
            "storeId": storeId
        ]
        
        if let deviceIdentifier = AppV2Constants.Client.deviceIdentifier {
            parameters["deviceId"] = deviceIdentifier
        }
        
        if let instructions {
            parameters["instructions"] = instructions
        }
        
        if let notificationDeviceToken {
            parameters["platform"] = AppV2Constants.Client.platform
            parameters["messagingDeviceId"] = notificationDeviceToken
        }

        return call(endpoint: API.createDraftOrder(parameters))
    }
    
    func getRealexHPPProducerData(orderId: Int) -> AnyPublisher<Data, Error> {
        
        let parameters: [String: Any] = [
            "orderId": orderId
        ]

        return call(endpoint: API.getRealexHPPProducerData(parameters))
    }
    
    func processRealexHPPConsumerData(orderId: Int, hppResponse: [String: Any]) -> AnyPublisher<ConfirmPaymentResponse, Error> {
        
        let parameters: [String: Any] = [
            "orderId": orderId,
            "hppResponse": hppResponse,
            "displayFlat": false,
            "stringOnlyResults": false
        ]

        return call(endpoint: API.processRealexHPPConsumerData(parameters))
    }
    
    func confirmPayment(orderId: Int) -> AnyPublisher<ConfirmPaymentResponse, Error> {
        
        let parameters: [String: Any] = [
            "orderId": orderId
        ]

        return call(endpoint: API.confirmPayment(parameters))
        
    }
    
    func verifyCheckoutcomPayment(draftOrderId: Int, businessId: Int, paymentId: String) async throws -> VerifyPaymentResponse {
        
        let parameters: [String: Any] = [
            "draftOrderId": draftOrderId,
            "businessId": businessId,
            "paymentId": paymentId
        ]
        
        return try await call(endpoint: API.verifyCheckoutcomPayment(parameters)).singleOutput()
    }
    
    func makePayment(draftOrderId: Int, type: PaymentType, paymentMethod: String, token: String?, cardId: String?, cvv: Int?) async throws -> MakePaymentResponse {
        var parameters: [String: Any] = [
            "businessId": AppV2Constants.Business.id,
            "draftOrderId": draftOrderId,
            "type": type,
            "paymentMethod": paymentMethod
        ]
        
        if let token = token {
            parameters["token"] = token
        }
        
        if type == .id {
            parameters["cardId"] = cardId
            parameters["cvv"] = cvv
        }
        
        return try await call(endpoint: API.makePayment(parameters)).singleOutput()
    }
    
    func getPlacedOrderStatus(forBusinessOrderId businessOrderId: Int) -> AnyPublisher<PlacedOrderStatus, Error> {
        
        let parameters: [String: Any] = [
            "businessId": AppV2Constants.Business.id,
            "businessOrderId": businessOrderId
        ]
        
        return call(endpoint: API.getPlacedOrderStatus(parameters))
    }
    
    func getDriverLocation(forBusinessOrderId businessOrderId: Int) async throws -> DriverLocation {

        let parameters: [String: Any] = [
            "businessOrderId": businessOrderId
        ]
        
        return try await call(endpoint: API.getDriverLocation(parameters)).singleOutput()
    }
    
    func getOrder(forBusinessOrderId businessOrderId: Int, withHash hash: String) async throws -> PlacedOrder {
        
        let parameters: [String: Any] = [
            "businessOrderId": businessOrderId,
            "hash": hash
        ]
        
        return try await call(endpoint: API.getOrderByHash(parameters)).singleOutput()
    }
    
    func setPreviousOrderedDeviceState(deviceCheckToken: String) async throws -> SetPreviousOrderedDeviceStateResult {
        let parameters: [String: Any] = [
            "deviceCheckToken": deviceCheckToken
        ]
        
        return try await call(endpoint: API.setPreviousOrderedDeviceState(parameters)).singleOutput()
    }
}

// MARK: - Endpoints

extension CheckoutWebRepository {
    enum API {
        case createDraftOrder([String: Any]?)
        case getRealexHPPProducerData([String: Any]?)
        case processRealexHPPConsumerData([String: Any]?)
        case confirmPayment([String: Any]?)
        case verifyCheckoutcomPayment([String: Any]?)
        case getPlacedOrderStatus([String: Any]?)
        case getDriverLocation([String: Any]?)
        case getOrderByHash([String: Any]?)
        case makePayment([String: Any]?)
        case setPreviousOrderedDeviceState([String: Any]?)
    }
}

extension CheckoutWebRepository.API: APICall {
    var path: String {
        switch self {
        case .createDraftOrder:
            return AppV2Constants.Client.languageCode + "/checkout/processOrder.json"
        case .getRealexHPPProducerData:
            return AppV2Constants.Client.languageCode + "/checkout/getRealexHPPProducerData.json"
        case .processRealexHPPConsumerData:
            return AppV2Constants.Client.languageCode + "/checkout/processRealexHPPConsumerData.json"
        case .confirmPayment:
            return AppV2Constants.Client.languageCode + "/checkout/confirmPayment.json"
        case .verifyCheckoutcomPayment:
            return AppV2Constants.Client.languageCode + "/payments/verifyPayment.json"
        case .getPlacedOrderStatus:
            return AppV2Constants.Client.languageCode + "/order/status.json"
        case .getDriverLocation:
            return AppV2Constants.Client.languageCode + "/order/getDriverLocation.json"
        case .getOrderByHash:
            return AppV2Constants.Client.languageCode + "/order/getOrderByHash.json"
        case .makePayment:
            return AppV2Constants.Client.languageCode + "/payments/makePayment.json"
        case .setPreviousOrderedDeviceState:
            return "\(AppV2Constants.Client.languageCode)/device/\(AppV2Constants.Client.platform)/setPreviousOrderedState.json"
        }
    }
    var method: String {
        switch self {
        case .createDraftOrder, .getRealexHPPProducerData, .processRealexHPPConsumerData, .confirmPayment, .verifyCheckoutcomPayment, .getPlacedOrderStatus, .getDriverLocation, .getOrderByHash, .makePayment, .setPreviousOrderedDeviceState:
            return "POST"
        }
    }
    var jsonParameters: [String : Any]? {
        switch self {
        case let .createDraftOrder(parameters):
            return parameters
        case let .getRealexHPPProducerData(parameters):
            return parameters
        case let .processRealexHPPConsumerData(parameters):
            return parameters
        case let .confirmPayment(parameters):
            return parameters
        case let .verifyCheckoutcomPayment(parameters):
            return parameters
        case let .getPlacedOrderStatus(parameters):
            return parameters
        case let .getDriverLocation(parameters):
            return parameters
        case let .getOrderByHash(parameters):
            return parameters
        case let .makePayment(parameters):
            return parameters
        case let .setPreviousOrderedDeviceState(parameters):
            return parameters
        }
    }
}
