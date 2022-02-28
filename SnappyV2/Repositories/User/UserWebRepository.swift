//
//  UserWebRepository.swift
//  SnappyV2
//
//  Created by Kevin Palser on 16/12/2021.
//

import Foundation
import Combine

protocol UserWebRepositoryProtocol: WebRepository {
    func login(email: String, password: String) -> AnyPublisher<Bool, Error>
    func logout() -> AnyPublisher<Bool, Error>
    func getProfile(storeId: Int?) -> AnyPublisher<MemberProfile, Error>
    func getPastOrders(
        dateFrom: String?,
        dateTo: String?,
        status: String?,
        page: Int?,
        limit: Int?
    ) -> AnyPublisher<[PastOrder]?, Error>
    
    // do not need a member signed in
    func getMarketingOptions(isCheckout: Bool, notificationsEnabled: Bool, basketToken: String?) -> AnyPublisher<UserMarketingOptionsFetch, Error>
    func updateMarketingOptions(options: [UserMarketingOptionRequest], basketToken: String?) -> AnyPublisher<UserMarketingOptionsUpdateResponse, Error>
}

struct UserWebRepository: UserWebRepositoryProtocol {

    let networkHandler: NetworkHandler
    let baseURL: String
    
    init(networkHandler: NetworkHandler, baseURL: String) {
        self.networkHandler = networkHandler
        self.baseURL = baseURL
    }
    
    func login(email: String, password: String) -> AnyPublisher<Bool, Error> {
        networkHandler.signIn(
            connectionTimeout: AppV2Constants.API.connectionTimeout,
            // TODO: add notification device paramters
            parameters: [
                "username": email,
                "password": password
            ]
        )
    }
    
    func logout() -> AnyPublisher<Bool, Error> {
        networkHandler.signOut(
            connectionTimeout: AppV2Constants.API.connectionTimeout,
            // TODO: add notification device paramters
            parameters: [:]
        )
    }
    
    func getProfile(storeId: Int?) -> AnyPublisher<MemberProfile, Error> {
        // required parameters
        var parameters: [String: Any] = [:]
        
        // optional paramters
        if let storeId = storeId {
            parameters["storeId"] = storeId
        }
        return call(endpoint: API.getProfile(parameters))
    }
    
    func getMarketingOptions(isCheckout: Bool, notificationsEnabled: Bool, basketToken: String?) -> AnyPublisher<UserMarketingOptionsFetch, Error> {
        // required parameters
        var parameters: [String: Any] = [
            "isCheckout": isCheckout,
            "notificationsEnabled": notificationsEnabled
        ]
        
        // optional paramters
        if let basketToken = basketToken {
            parameters["basketToken"] = basketToken
        }
        return call(endpoint: API.getMarketingOptions(parameters))
    }
    
    func updateMarketingOptions(options: [UserMarketingOptionRequest], basketToken: String?) -> AnyPublisher<UserMarketingOptionsUpdateResponse, Error> {
        // required parameters
        var parameters: [String: Any] = [
            "marketingOptions": options
        ]
        
        // optional paramters
        if let basketToken = basketToken {
            parameters["basketToken"] = basketToken
        }
        return call(endpoint: API.updateMarketingOptions(parameters))
    }
    
    func getPastOrders(
        dateFrom: String?,
        dateTo: String?,
        status: String?,
        page: Int?,
        limit: Int?
    ) -> AnyPublisher<[PastOrder]?, Error> {
        // required parameters
        var parameters: [String: Any] = [
            "businessId": AppV2Constants.Business.id
        ]
        
        // optional paramters
        if let dateFrom = dateFrom {
            parameters["dateFrom"] = dateFrom
        }
        if let dateTo = dateTo {
            parameters["dateTo"] = dateTo
        }
        if let status = status {
            parameters["status"] = status
        }
        if let page = page {
            parameters["page"] = page
        }
        if let limit = limit {
            parameters["limit"] = limit
        }
        
        return call(endpoint: API.getPastOrders(parameters))
    }
    
}

// MARK: - Endpoints

extension UserWebRepository {
    enum API {
        case getProfile([String: Any]?)
        case getMarketingOptions([String: Any]?)
        case updateMarketingOptions([String: Any]?)
        case getPastOrders([String: Any]?)
    }
}

extension UserWebRepository.API: APICall {
    var path: String {
        switch self {
        case .getProfile:
            return AppV2Constants.Client.languageCode + "/member/profile.json"
        case .getMarketingOptions:
            return AppV2Constants.Client.languageCode + "/member/marketing/get.json"
        case .updateMarketingOptions:
            return AppV2Constants.Client.languageCode + "/member/marketing/update.json"
        case .getPastOrders:
            return AppV2Constants.Client.languageCode + "/member/orders.json"
        }
    }
    var method: String {
        switch self {
        case .getProfile, .getMarketingOptions, .getPastOrders:
            return "POST"
        case .updateMarketingOptions:
            return "PUT"
        }
    }
    var jsonParameters: [String : Any]? {
        switch self {
        case let .getProfile(parameters):
            return parameters
        case let .getMarketingOptions(parameters):
            return parameters
        case let .updateMarketingOptions(parameters):
            return parameters
        case let .getPastOrders(parameters):
            return parameters
        }
    }
}



