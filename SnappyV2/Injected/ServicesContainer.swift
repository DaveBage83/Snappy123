//
//  ServicesContainer.swift
//  SnappyV2
//
//  Created by Henrik Gustavii on 15/09/2021.
//

import Foundation

extension DIContainer {
    struct Services {
        let businessProfileService: BusinessProfileServiceProtocol
        let retailStoresService: RetailStoresServiceProtocol
        let retailStoreMenuService: RetailStoreMenuServiceProtocol
        let basketService: BasketServiceProtocol
        let userService: UserServiceProtocol
        let checkoutService: CheckoutServiceProtocol
        let addressService: AddressServiceProtocol
        let utilityService: UtilityServiceProtocol
        let imageService: ImageServiceProtocol
        let notificationService: NotificationServiceProtocol
        
        init(
            businessProfileService: BusinessProfileServiceProtocol,
            retailStoreService: RetailStoresServiceProtocol,
            retailStoreMenuService: RetailStoreMenuServiceProtocol,
            basketService: BasketServiceProtocol,
            userService: UserServiceProtocol,
            checkoutService: CheckoutServiceProtocol,
            addressService: AddressServiceProtocol,
            utilityService: UtilityServiceProtocol,
            imageService: ImageServiceProtocol,
            notificationService: NotificationServiceProtocol
        ) {
            self.businessProfileService = businessProfileService
            self.retailStoresService = retailStoreService
            self.retailStoreMenuService = retailStoreMenuService
            self.basketService = basketService
            self.userService = userService
            self.checkoutService = checkoutService
            self.addressService = addressService
            self.utilityService = utilityService
            self.imageService = imageService
            self.notificationService = notificationService
        }
        
        static var stub: Self {
            .init(
                businessProfileService: StubBusinessProfileService(),
                retailStoreService: StubRetailStoresService(),
                retailStoreMenuService: StubRetailStoreMenuService(),
                basketService: StubBasketService(),
                userService: StubUserService(),
                checkoutService: StubCheckoutService(),
                addressService: StubAddressService(),
                utilityService: StubUtilityService(),
                imageService: StubImageService(),
                notificationService: StubNotificationService()
            )
        }
    }
}
