//
//  AppEnvironment.swift
//  SnappyV2
//
//  Created by Henrik Gustavii on 15/09/2021.
//

import Foundation

struct AppEnvironment {
    let container: DIContainer
}

extension AppEnvironment {
    
    static func bootstrap() -> AppEnvironment {
        let appState = Store<AppState>(AppState())
        
        let authenticator = configuredAuthenticator()
        let networkHandler = configuredNetworkHandler(authenticator: authenticator)
        let webRepositories = configuredWebRepositories(networkHandler: networkHandler)
        let dbRepositories = configuredDBRepositories(appState: appState) // Why is appState required?
        
        let services = configuredServices(
            appState: appState,
            dbRepositories: dbRepositories,
            webRepositories: webRepositories
        )
        let diContainer = DIContainer(appState: appState, services: services)
        
        return AppEnvironment(container: diContainer)
    }
    
    private static func configuredAuthenticator() -> NetworkAuthenticator {
        return NetworkAuthenticator.shared
    }
    
    private static func configuredNetworkHandler(authenticator: NetworkAuthenticator) -> NetworkHandler {
        return NetworkHandler(authenticator: authenticator, debugTrace: AppV2Constants.API.debugTrace)
    }
    
    private static func configuredWebRepositories(networkHandler: NetworkHandler) -> DIContainer.WebRepositories {
        
        let retailStoresRepository = RetailStoresWebRepository(
            networkHandler: networkHandler,
            baseURL: AppV2Constants.API.baseURL
        )
        
        let retailStoreMenuRepository = RetailStoreMenuWebRepository(
            networkHandler: networkHandler,
            baseURL: AppV2Constants.API.baseURL
        )
        
        let basketRepository = BasketWebRepository(
            networkHandler: networkHandler,
            baseURL: AppV2Constants.API.baseURL
        )
        
//        let pushTokenWebRepository = RealPushTokenWebRepository(
//            session: session,
//            baseURL: "https://fake.backend.com")
        
        return .init(
            retailStoresRepository: retailStoresRepository,
            retailStoreMenuRepository: retailStoreMenuRepository,
            basketRepository: basketRepository
            /*imageRepository: imageWebRepository,*/
            /*pushTokenWebRepository: pushTokenWebRepository*/)
    }
    
    private static func configuredDBRepositories(appState: Store<AppState>) -> DIContainer.DBRepositories {
        
        let persistentStore = CoreDataStack(version: CoreDataStack.Version.actual)
        let retailStoresDBRepository = RetailStoresDBRepository(persistentStore: persistentStore)
        let retailStoreMenuDBRepository = RetailStoreMenuDBMenuDBRepository(persistentStore: persistentStore)
        let basketDBRepository = BasketDBRepository(persistentStore: persistentStore)
        
        return .init(
            retailStoresRepository: retailStoresDBRepository,
            retailStoreMenuRepository: retailStoreMenuDBRepository,
            basketRepository: basketDBRepository
        )
    }
    
    private static func configuredServices(
        appState: Store<AppState>,
        dbRepositories: DIContainer.DBRepositories,
        webRepositories: DIContainer.WebRepositories
    ) -> DIContainer.Services {
        
        let retailStoreService = RetailStoresService(
            webRepository: webRepositories.retailStoresRepository,
            dbRepository: dbRepositories.retailStoresRepository
        )
        
        let retailStoreMenuService = RetailStoreMenuService(
            webRepository: webRepositories.retailStoreMenuRepository,
            dbRepository: dbRepositories.retailStoreMenuRepository,
            appState: appState
        )
        
        let basketService = BasketService(
            webRepository: webRepositories.basketRepository,
            dbRepository: dbRepositories.basketRepository,
            appState: appState
        )
        
        return .init(
            retailStoreService: retailStoreService,
            retailStoreMenuService: retailStoreMenuService,
            basketService: basketService
            /*, retailStoreMenuService: RetailStoreMenuServiceProtocol, imageService: ""*/
        )
    }
}

extension DIContainer {
    struct WebRepositories {
        //let imageRepository: ImageWebRepository
        let retailStoresRepository: RetailStoresWebRepository
        let retailStoreMenuRepository: RetailStoreMenuWebRepository
        let basketRepository: BasketWebRepository
        //let pushTokenWebRepository: PushTokenWebRepository
    }
    
    struct DBRepositories {
        let retailStoresRepository: RetailStoresDBRepository
        let retailStoreMenuRepository: RetailStoreMenuDBMenuDBRepository
        let basketRepository: BasketDBRepository
    }
}
