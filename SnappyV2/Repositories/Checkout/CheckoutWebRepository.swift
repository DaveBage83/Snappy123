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
        paymentGateway: PaymentGateway,
        storeId: Int,
        firstname: String,
        lastname: String,
        emailAddress: String,
        phoneNumber: String
    ) -> AnyPublisher<DraftOrderResult, Error>
    
    func getRealexHPPProducerData(orderId: Int) -> AnyPublisher<Data, Error>
    
    func getRealexHPPProducerData(orderId: Int, hppResponse: [String: Any]) -> AnyPublisher<ShimmedPaymentResponse, Error>

    func confirmPayment(orderId: Int) -> AnyPublisher<ConfirmPaymentResponse, Error>
    
    func verifyPayment(orderId: Int) -> AnyPublisher<ConfirmPaymentResponse, Error>
    
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
        paymentGateway: PaymentGateway,
        storeId: Int,
        firstname: String,
        lastname: String,
        emailAddress: String,
        phoneNumber: String
    ) -> AnyPublisher<DraftOrderResult, Error> {
        
        var parameters: [String: Any] = [
            "businessId": AppV2Constants.Business.id,
            "basketToken": basketToken,
            "fulfilmentDetails": fulfilmentDetails,
            "channel": "ios",
            "paymentGateway": paymentGateway.rawValue,
            "storeId": storeId,
            "firstname": firstname,
            "lastname": lastname,
            "emailAddress": emailAddress,
            "phoneNumber": phoneNumber
        ]
        
        if let instructions = instructions {
            parameters["instructions"] = instructions
        }

        return call(endpoint: API.createDraftOrder(parameters))
    }
    
    func getRealexHPPProducerData(orderId: Int) -> AnyPublisher<Data, Error> {
        
        let parameters: [String: Any] = [
            "orderId": orderId
        ]

        return call(endpoint: API.getRealexHPPProducerData(parameters))
    }
    
    func getRealexHPPProducerData(orderId: Int, hppResponse: [String: Any]) -> AnyPublisher<ShimmedPaymentResponse, Error> {
        
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
    
    func verifyPayment(orderId: Int) -> AnyPublisher<ConfirmPaymentResponse, Error> {
        
        let parameters: [String: Any] = [
            "orderId": orderId
        ]

        return call(endpoint: API.verifyPayment(parameters))
        
    }
    
}

// MARK: - Endpoints

extension CheckoutWebRepository {
    enum API {
        case createDraftOrder([String: Any]?)
        case getRealexHPPProducerData([String: Any]?)
        case processRealexHPPConsumerData([String: Any]?)
        case confirmPayment([String: Any]?)
        case verifyPayment([String: Any]?)
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
        case .verifyPayment:
            return AppV2Constants.Client.languageCode + "/checkout/verifyPayment.json"
        }
    }
    var method: String {
        switch self {
        case .createDraftOrder, .getRealexHPPProducerData, .processRealexHPPConsumerData, .confirmPayment, .verifyPayment:
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
        case let .verifyPayment(parameters):
            return parameters
        }
    }
}
