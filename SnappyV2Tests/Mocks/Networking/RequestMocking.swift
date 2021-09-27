//
//  RequestMocking.swift
//  SnappyV2Tests
//
//  Created by Kevin Palser on 27/09/2021.
//

import Foundation
@testable import SnappyV2

extension NetworkHandler {
    static var mockedResponsesOnly: NetworkHandler {
        return NetworkHandler(authenticator: NetworkAuthenticator.shared, debugTrace: AppV2Constants.API.debugTrace)
    }
}


//extension AppEnvironment {
//    static func bootstrap() -> AppEnvironment {
//        let appState = Store<AppState>(AppState())
//        
//        let authenticator = configuredAuthenticator()
//        let networkHandler = configuredNetworkHandler(authenticator: authenticator)
//        let webRepositories = configuredWebRepositories(networkHandler: networkHandler)
//        let dbRepositories = configuredDBRepositories(appState: appState) // Why is appState required?
//        
//        let services = configuredServices(
//            appState: appState,
//            dbRepositories: dbRepositories,
//            webRepositories: webRepositories
//        )
//        let diContainer = DIContainer(appState: appState, services: services)
//        
//        return AppEnvironment(container: diContainer)
//    }
//    
//    private static func configuredAuthenticator() -> NetworkAuthenticator {
//        return NetworkAuthenticator.shared
//    }
//    
//    private static func configuredNetworkHandler(authenticator: NetworkAuthenticator) -> NetworkHandler {
//        return NetworkHandler(authenticator: authenticator, debugTrace: AppV2Constants.API.debugTrace)
//    }
//    
//    private static func configuredWebRepositories(networkHandler: NetworkHandler) -> DIContainer.WebRepositories {
////        let countriesWebRepository = RealCountriesWebRepository(
////            session: session,
////            baseURL: "https://restcountries.eu/rest/v2")
//        let retailStoresRepository = RetailStoresWebRepository(
//            networkHandler: networkHandler,
//            baseURL: AppV2Constants.API.baseURL
//        )
////        let pushTokenWebRepository = RealPushTokenWebRepository(
////            session: session,
////            baseURL: "https://fake.backend.com")
//        return .init(/*imageRepository: imageWebRepository,*/
//                     retailStoresRepository: retailStoresRepository//,
//                     /*pushTokenWebRepository: pushTokenWebRepository*/)
//    }
