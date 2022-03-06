//
//  UserWebRepository.swift
//  SnappyV2
//
//  Created by Kevin Palser on 16/12/2021.
//

import Foundation
import Combine

// General Note:
// (a) Parameter requirement checking (PRC) could be at higher point in the call chain, e.g. in RetailStoresService
// public or helper methods. We could also try an map it to server responses. In the end we (Henrik|Kevin) decided
// to have it at this web repository level because:
// - parent calling methods might easily omit the checks if their implementation is updated
// - the web repository is nearer to the business logic and PRC is based on this logic
// - the server responses vary and don't always adhere to APIErrorResult structure or http codes

protocol UserWebRepositoryProtocol: WebRepository {
    func login(email: String, password: String) -> AnyPublisher<Bool, Error>
    func logout() -> AnyPublisher<Bool, Error>
    func getProfile(storeId: Int?) -> AnyPublisher<MemberProfile, Error>
    func addAddress(address: Address) -> AnyPublisher<MemberProfile, Error>
    func updateAddress(address: Address) -> AnyPublisher<MemberProfile, Error>
    func setDefaultAddress(addressId: Int) -> AnyPublisher<MemberProfile, Error>
    func removeAddress(addressId: Int) -> AnyPublisher<MemberProfile, Error>
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
    
    func addAddress(address: Address) -> AnyPublisher<MemberProfile, Error> {
        // required parameters
        var parameters: [String: Any] = [
            "businessId": AppV2Constants.Business.id,
            "isDefault": address.isDefault ?? false,
            "addressline1": address.addressline1,
            "town": address.town,
            "postcode": address.postcode,
            "countryCode": address.countryCode,
            "type": address.type.rawValue
        ]
        
        // optional paramters
        if let addressName = address.addressName {
            parameters["addressName"] = addressName
        }
        
        if address.firstName.isEmpty == false {
            parameters["firstName"] = address.firstName
        }
        
        if address.lastName.isEmpty == false {
            parameters["lastName"] = address.lastName
        }
        
        if let addressline2 = address.addressline2 {
            parameters["addressline2"] = addressline2
        }
        
        if let county = address.county {
            parameters["county"] = county
        }
        
        if let location = address.location {
            parameters["location"] = location
        }
        
        return call(endpoint: API.addAddress(parameters))
    }
    
    func updateAddress(address: Address) -> AnyPublisher<MemberProfile, Error> {
        
        // See general note (a)
        if let id = address.id {
            
            // required parameters
            var parameters: [String: Any] = [
                "id": id,
                "businessId": AppV2Constants.Business.id,
                "isDefault": address.isDefault ?? false,
                "addressline1": address.addressline1,
                "town": address.town,
                "postcode": address.postcode,
                "countryCode": address.countryCode,
                "type": address.type.rawValue
            ]
            
            // optional paramters
            if let addressName = address.addressName {
                parameters["addressName"] = addressName
            }
            
            if address.firstName.isEmpty == false {
                parameters["firstName"] = address.firstName
            }
            
            if address.lastName.isEmpty == false {
                parameters["lastName"] = address.lastName
            }
            
            if let addressline2 = address.addressline2 {
                parameters["addressline2"] = addressline2
            }
            
            if let county = address.county {
                parameters["county"] = county
            }
            
            if let location = address.location {
                parameters["location"] = location
            }
            
            return call(endpoint: API.updateAddress(parameters))
        } else {
            return Fail(outputType: MemberProfile.self, failure: UserServiceError.invalidParameters(["address id not set"]))
                .eraseToAnyPublisher()
        }
    }
    
    func setDefaultAddress(addressId: Int) -> AnyPublisher<MemberProfile, Error> {
        // required parameters
        let parameters: [String: Any] = [
            "businessId": AppV2Constants.Business.id,
            "addressId": addressId
        ]
        
        return call(endpoint: API.setDefaultAddress(parameters))
    }
    
    func removeAddress(addressId: Int) -> AnyPublisher<MemberProfile, Error> {
        // required parameters
        let parameters: [String: Any] = [
            "businessId": AppV2Constants.Business.id,
            "addressId": addressId
        ]
        
        return call(endpoint: API.removeAddress(parameters))
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
        case addAddress([String: Any]?)
        case updateAddress([String: Any]?)
        case setDefaultAddress([String: Any]?)
        case removeAddress([String: Any]?)
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
        case .addAddress:
            return AppV2Constants.Client.languageCode + "/member/address/add.json"
        case .updateAddress:
            return AppV2Constants.Client.languageCode + "/member/address/update.json"
        case .setDefaultAddress:
            return AppV2Constants.Client.languageCode + "/member/address/setDefault.json"
        case .removeAddress:
            return AppV2Constants.Client.languageCode + "/member/address/remove.json"
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
        case .getProfile, .addAddress, .getMarketingOptions, .getPastOrders, .setDefaultAddress:
            return "POST"
        case .updateMarketingOptions, .updateAddress:
            return "PUT"
        case .removeAddress:
            return "DELETE"
        }
    }
    var jsonParameters: [String : Any]? {
        switch self {
        case let .getProfile(parameters):
            return parameters
        case let .addAddress(parameters):
            return parameters
        case let .updateAddress(parameters):
            return parameters
        case let .setDefaultAddress(parameters):
            return parameters
        case let .removeAddress(parameters):
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



