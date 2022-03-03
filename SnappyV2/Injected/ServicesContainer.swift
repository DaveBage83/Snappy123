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
        //let imageService: String
        let imageService: ImageServiceProtocol
        
        init(
            businessProfileService: BusinessProfileServiceProtocol,
            retailStoreService: RetailStoresServiceProtocol,
            retailStoreMenuService: RetailStoreMenuServiceProtocol,
            basketService: BasketServiceProtocol,
            userService: UserServiceProtocol,
            checkoutService: CheckoutServiceProtocol,
            addressService: AddressServiceProtocol,
            utilityService: UtilityServiceProtocol,
            imageService: ImageServiceProtocol
        ) {
            self.businessProfileService = businessProfileService
            self.retailStoresService = retailStoreService
            self.retailStoreMenuService = retailStoreMenuService
            self.basketService = basketService
            self.userService = userService
            self.checkoutService = checkoutService
            self.addressService = addressService
            self.utilityService = utilityService
            //self.imagesService = imagesService
            self.imageService = imageService
            //self.userPermissionsService = userPermissionsService
        }
        
        static var stub: Self {
            .init(
                businessProfileService: StubBusinessProfileService(),
                retailStoreService: StubRetailStoresService(),
                retailStoreMenuService: StubRetailStoreMenuService(),
                basketService: StubBasketService(),
                userService: StubUserService(),
                checkoutService: StubCheckoutService(),
                addressService: StubAddressService()/*, imageService: ""*/,
                utilityService: StubUtilityService(),
                imageService: StubImageService()
            )
        }
    }
}
