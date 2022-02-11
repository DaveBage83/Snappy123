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
    
}

// MARK: - Endpoints

extension CheckoutWebRepository {
    enum API {
        case createDraftOrder([String: Any]?)
    }
}

extension CheckoutWebRepository.API: APICall {
    var path: String {
        switch self {
        case .createDraftOrder:
            return AppV2Constants.Client.languageCode + "/checkout/processOrder.json"
        }
    }
    var method: String {
        switch self {
        case .createDraftOrder:
            return "POST"
        }
    }
    var jsonParameters: [String : Any]? {
        switch self {
        case let .createDraftOrder(parameters):
            return parameters
        }
    }
}
