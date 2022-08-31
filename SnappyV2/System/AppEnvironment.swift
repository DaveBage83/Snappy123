//
//  AppEnvironment.swift
//  SnappyV2
//
//  Created by Henrik Gustavii on 15/09/2021.
//

import Foundation
import UIKit // Needed for UIApplication
import Frames

struct AppEnvironment {
    let container: DIContainer
    let systemEventsHandler: SystemEventsHandler
}

extension AppEnvironment {
    static func bootstrap() -> AppEnvironment {
        let appState = Store<AppState>(AppState())
        let eventLogger = configuredEventLogger(appState: appState)
        let authenticator = configuredAuthenticator()
        let networkHandler = configuredNetworkHandler(authenticator: authenticator)
        let webRepositories = configuredWebRepositories(networkHandler: networkHandler)
        let dbRepositories = configuredDBRepositories(appState: appState) // Why is appState required?
        
        let services = configuredServices(
            appState: appState,
            eventLogger: eventLogger,
            dbRepositories: dbRepositories,
            webRepositories: webRepositories
        )
        let diContainer = DIContainer(
            appState: appState,
            eventLogger: eventLogger,
            services: services
        )
        let deepLinksHandler = DeepLinksHandler(container: diContainer)
        let pushNotificationsHandler = PushNotificationsHandler(appState: appState, deepLinksHandler: deepLinksHandler)
        let systemEventsHandler = SystemEventsHandler(
            container: diContainer,
            deepLinksHandler: deepLinksHandler,
            pushNotificationsHandler: pushNotificationsHandler,
            pushNotificationsWebRepository: webRepositories.pushNotificationsWebRepository
        )
        
        return AppEnvironment(container: diContainer, systemEventsHandler: systemEventsHandler)
    }
    
    private static func configuredEventLogger(appState: Store<AppState>) -> EventLogger {
        return EventLogger(appState: appState)
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
            baseURL: AppV2Constants.API.baseURL
        )
        
        let imageRepository = ImageWebRepository()
        
        let pushNotificationRepository = PushNotificationWebRepository(
            networkHandler: networkHandler,
            baseURL: AppV2Constants.API.baseURL
        )
        
        return .init(
            businessProfileRepository: businessProfileRepository,
            retailStoresRepository: retailStoresRepository,
            retailStoreMenuRepository: retailStoreMenuRepository,
            basketRepository: basketRepository,
            memberRepository: memberRepository,
            checkoutRepository: checkoutRepository,
            addressRepository: addressRepository,
            utilityRepository: utilityRepository,
            imageRepository: imageRepository,
            pushNotificationsWebRepository: pushNotificationRepository
        )
    }
    
    private static func configuredDBRepositories(appState: Store<AppState>) -> DIContainer.DBRepositories {
        
        let persistentStore = CoreDataStack(version: CoreDataStack.Version.actual)
        let businessProfileDBRepository = BusinessProfileDBRepository(persistentStore: persistentStore)
        let retailStoresDBRepository = RetailStoresDBRepository(persistentStore: persistentStore)
        let retailStoreMenuDBRepository = RetailStoreMenuDBRepository(persistentStore: persistentStore)
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
        eventLogger: EventLoggerProtocol,
        dbRepositories: DIContainer.DBRepositories,
        webRepositories: DIContainer.WebRepositories
    ) -> DIContainer.Services {
        
        let notificationService = NotificationService(appState: appState)
        
        let businessProfileService = BusinessProfileService(
            webRepository: webRepositories.businessProfileRepository,
            dbRepository: dbRepositories.businessProfileRepository,
            appState: appState,
            eventLogger: eventLogger
        )
        
        let retailStoreService = RetailStoresService(
            webRepository: webRepositories.retailStoresRepository,
            dbRepository: dbRepositories.retailStoresRepository,
            appState: appState,
            eventLogger: eventLogger
        )
        
        let retailStoreMenuService = RetailStoreMenuService(
            webRepository: webRepositories.retailStoreMenuRepository,
            dbRepository: dbRepositories.retailStoreMenuRepository,
            appState: appState,
            eventLogger: eventLogger
        )
        
        let basketService = BasketService(
            webRepository: webRepositories.basketRepository,
            dbRepository: dbRepositories.basketRepository,
            notificationService: notificationService,
            appState: appState,
            eventLogger: eventLogger
        )
        
        let memberService = UserService(
            webRepository: webRepositories.memberRepository,
            dbRepository: dbRepositories.memberRepository,
            appState: appState,
            eventLogger: eventLogger
        )
        
        let checkoutService = CheckoutService(
            webRepository: webRepositories.checkoutRepository,
            dbRepository: dbRepositories.checkoutRepository,
            appState: appState,
            eventLogger: eventLogger
        )
        
        // the address service does not need the appState because it does
        // not have any external dependencies for API requests
        let addressService = AddressService(
            webRepository: webRepositories.addressRepository,
            dbRepository: dbRepositories.addressRepository, eventLogger: eventLogger
        )
        
        let utilityService = UtilityService(
            webRepository: webRepositories.utilityRepository,
            eventLogger: eventLogger
        )
        
        let imageService = ImageService(
            webRepository: webRepositories.imageRepository,
            eventLogger: eventLogger
        )
        
        let userPermissionsService = UserPermissionsService(
            appState: appState,
            openAppSettings: {
                URL(string: UIApplication.openSettingsURLString).flatMap {
                    UIApplication.shared.open($0, options: [:], completionHandler: nil)
                }
            }
        )
        
        return .init(
            businessProfileService: businessProfileService,
            retailStoreService: retailStoreService,
            retailStoreMenuService: retailStoreMenuService,
            basketService: basketService,
            memberService: memberService,
            checkoutService: checkoutService,
            addressService: addressService,
            utilityService: utilityService,
            imageService: imageService,
            notificationService: notificationService,
            userPermissionsService: userPermissionsService
        )
    }
}

extension DIContainer {
    struct WebRepositories {
        let businessProfileRepository: BusinessProfileWebRepository
        let retailStoresRepository: RetailStoresWebRepository
        let retailStoreMenuRepository: RetailStoreMenuWebRepository
        let basketRepository: BasketWebRepository
        let memberRepository: UserWebRepository
        let checkoutRepository: CheckoutWebRepository
        let addressRepository: AddressWebRepository
        let utilityRepository: UtilityWebRepository
        let imageRepository: ImageWebRepository
        let pushNotificationsWebRepository: PushNotificationWebRepository
    }
    
    struct DBRepositories {
        let businessProfileRepository: BusinessProfileDBRepository
        let retailStoresRepository: RetailStoresDBRepository
        let retailStoreMenuRepository: RetailStoreMenuDBRepository
        let basketRepository: BasketDBRepository
        let memberRepository: UserDBRepository
        let checkoutRepository: CheckoutDBRepository
        let addressRepository: AddressDBRepository
    }
}
