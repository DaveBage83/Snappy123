//
//  AddressWebRepository.swift
//  SnappyV2
//
//  Created by Kevin Palser on 14/01/2022.
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

protocol AddressWebRepositoryProtocol: WebRepository {
    func findAddresses(postcode: String, countryCode: String) -> AnyPublisher<[FoundAddress]?, Error>
    func getCountries() -> AnyPublisher<[AddressSelectionCountry]?, Error>
}

struct AddressWebRepository: AddressWebRepositoryProtocol {

    let networkHandler: NetworkHandler
    let baseURL: String
    
    init(networkHandler: NetworkHandler, baseURL: String) {
        self.networkHandler = networkHandler
        self.baseURL = baseURL
    }
    
    func findAddresses(postcode: String, countryCode: String) -> AnyPublisher<[FoundAddress]?, Error> {
        
        // See general note (a)
        if postcode.trimmingCharacters(in: .whitespaces).isEmpty {
            return Fail<[FoundAddress]?, Error>(error: AddressServiceError.invalidParameters(["postcode empty"]))
                .eraseToAnyPublisher()
        }
        
        // 2021-01-16 - no checking for countryCode being empty, at the time of writing
        // the v2 API does not use the field in its logic and it may be removed in the
        // future
        
        let parameters: [String: Any] = [
            "postcode": postcode,
            "countryCode": countryCode
        ]

        return call(endpoint: API.findAddresses(parameters))
    }
    
    func getCountries() -> AnyPublisher<[AddressSelectionCountry]?, Error> {
        return call(endpoint: API.getCountries)
    }
}

// MARK: - Endpoints

extension AddressWebRepository {
    enum API {
        case findAddresses([String: Any]?)
        case getCountries
    }
}

extension AddressWebRepository.API: APICall {
    var path: String {
        switch self {
        case .findAddresses:
            return AppV2Constants.Client.languageCode + "/location/addressFinder.json"
        case .getCountries:
            return AppV2Constants.Client.languageCode + "/countries/list.json"
        }
    }
    var method: String {
        switch self {
        case .findAddresses:
            return "POST"
        case .getCountries:
            return "GET"
        }
    }
    var jsonParameters: [String : Any]? {
        switch self {
        case let .findAddresses(parameters):
            return parameters
        case .getCountries:
            return nil
        }
    }
}
