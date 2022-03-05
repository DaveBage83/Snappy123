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
        
        let businessProfileRepository = BusinessProfileWebRepository(
            networkHandler: networkHandler,
            baseURL: AppV2Constants.API.baseURL
        )
        
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
        
        let memberRepository = UserWebRepository(
            networkHandler: networkHandler,
            baseURL: AppV2Constants.API.baseURL
        )
        
        let checkoutRepository = CheckoutWebRepository(
            networkHandler: networkHandler,
            baseURL: AppV2Constants.API.baseURL
        )
        
        let addressRepository = AddressWebRepository(
            networkHandler: networkHandler,
            baseURL: AppV2Constants.API.baseURL
        )
        
        let utilityRepository = UtilityWebRepository(
            networkHandler: networkHandler,
            baseURL: AppV2Constants.API.baseURL)
        let imageRepository = ImageWebRepository()
        
//        let pushTokenWebRepository = RealPushTokenWebRepository(
//            session: session,
//            baseURL: "https://fake.backend.com")
        
        return .init(
            businessProfileRepository: businessProfileRepository,
            retailStoresRepository: retailStoresRepository,
            retailStoreMenuRepository: retailStoreMenuRepository,
            basketRepository: basketRepository,
            memberRepository: memberRepository,
            checkoutRepository: checkoutRepository,
            addressRepository: addressRepository,
            utilityRepository: utilityRepository,
            imageService: imageRepository
            /*imageRepository: imageWebRepository,*/
            /*pushTokenWebRepository: pushTokenWebRepository*/)
    }
    
    private static func configuredDBRepositories(appState: Store<AppState>) -> DIContainer.DBRepositories {
        
        let persistentStore = CoreDataStack(version: CoreDataStack.Version.actual)
        let businessProfileDBRepository = BusinessProfileDBRepository(persistentStore: persistentStore)
        let retailStoresDBRepository = RetailStoresDBRepository(persistentStore: persistentStore)
        let retailStoreMenuDBRepository = RetailStoreMenuDBMenuDBRepository(persistentStore: persistentStore)
        let basketDBRepository = BasketDBRepository(persistentStore: persistentStore)
        let memberDBRepository = UserDBRepository(persistentStore: persistentStore)
        let checkoutDBRepository = CheckoutDBRepository(persistentStore: persistentStore)
        let addressDBRepository = AddressDBRepository(persistentStore: persistentStore)
        
        return .init(
            businessProfileRepository: businessProfileDBRepository,
            retailStoresRepository: retailStoresDBRepository,
            retailStoreMenuRepository: retailStoreMenuDBRepository,
            basketRepository: basketDBRepository,
            memberRepository: memberDBRepository,
            checkoutRepository: checkoutDBRepository,
            addressRepository: addressDBRepository
        )
    }
    
    private static func configuredServices(
        appState: Store<AppState>,
        dbRepositories: DIContainer.DBRepositories,
        webRepositories: DIContainer.WebRepositories
    ) -> DIContainer.Services {
        
        let businessProfileService = BusinessProfileService(
            webRepository: webRepositories.businessProfileRepository,
            dbRepository: dbRepositories.businessProfileRepository,
            appState: appState
        )
        
        let retailStoreService = RetailStoresService(
            webRepository: webRepositories.retailStoresRepository,
            dbRepository: dbRepositories.retailStoresRepository,
            appState: appState
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
        
        let memberService = UserService(
            webRepository: webRepositories.memberRepository,
            dbRepository: dbRepositories.memberRepository,
            appState: appState
        )
        
        let checkoutService = CheckoutService(
            webRepository: webRepositories.checkoutRepository,
            dbRepository: dbRepositories.checkoutRepository,
            appState: appState
        )
        
        // the address service does not need the appState because it does
        // not have any external dependencies for API requests
        let addressService = AddressService(
            webRepository: webRepositories.addressRepository,
            dbRepository: dbRepositories.addressRepository
        )
        
        let utilityService = UtilityService(
            webRepository: webRepositories.utilityRepository
        )
        let imageService = ImageService(webRepository: webRepositories.imageService)
        
        return .init(
            businessProfileService: businessProfileService,
            retailStoreService: retailStoreService,
            retailStoreMenuService: retailStoreMenuService,
            basketService: basketService,
            userService: memberService,
            checkoutService: checkoutService,
            addressService: addressService,
            utilityService: utilityService,
            imageService: imageService
            /*, retailStoreMenuService: RetailStoreMenuServiceProtocol, imageService: ""*/
        )
    }
}

extension DIContainer {
    struct WebRepositories {
        //let imageRepository: ImageWebRepository
        let businessProfileRepository: BusinessProfileWebRepository
        let retailStoresRepository: RetailStoresWebRepository
        let retailStoreMenuRepository: RetailStoreMenuWebRepository
        let basketRepository: BasketWebRepository
        let memberRepository: UserWebRepository
        let checkoutRepository: CheckoutWebRepository
        let addressRepository: AddressWebRepository
        let utilityRepository: UtilityWebRepository
        let imageService: ImageWebRepository
        //let pushTokenWebRepository: PushTokenWebRepository
    }
    
    struct DBRepositories {
        let businessProfileRepository: BusinessProfileDBRepository
        let retailStoresRepository: RetailStoresDBRepository
        let retailStoreMenuRepository: RetailStoreMenuDBMenuDBRepository
        let basketRepository: BasketDBRepository
        let memberRepository: UserDBRepository
        let checkoutRepository: CheckoutDBRepository
        let addressRepository: AddressDBRepository
    }
}
