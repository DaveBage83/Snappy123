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
        let memberService: MemberServiceProtocol
        let checkoutService: CheckoutServiceProtocol
        let addressService: AddressServiceProtocol
        let utilityService: UtilityServiceProtocol
        let imageService: AsyncImageServiceProtocol
        let notificationService: NotificationServiceProtocol
        let userPermissionsService: UserPermissionsServiceProtocol
        let searchHistoryService: SearchHistoryServiceProtocol
        
        init(
            businessProfileService: BusinessProfileServiceProtocol,
            retailStoreService: RetailStoresServiceProtocol,
            retailStoreMenuService: RetailStoreMenuServiceProtocol,
            basketService: BasketServiceProtocol,
            memberService: MemberServiceProtocol,
            checkoutService: CheckoutServiceProtocol,
            addressService: AddressServiceProtocol,
            utilityService: UtilityServiceProtocol,
            imageService: AsyncImageServiceProtocol,
            notificationService: NotificationServiceProtocol,
            userPermissionsService: UserPermissionsServiceProtocol,
            searchHistoryService: SearchHistoryServiceProtocol
        ) {
            self.businessProfileService = businessProfileService
            self.retailStoresService = retailStoreService
            self.retailStoreMenuService = retailStoreMenuService
            self.basketService = basketService
            self.memberService = memberService
            self.checkoutService = checkoutService
            self.addressService = addressService
            self.utilityService = utilityService
            self.imageService = imageService
            self.notificationService = notificationService
            self.userPermissionsService = userPermissionsService
            self.searchHistoryService = searchHistoryService
        }
        
        static var stub: Self {
            .init(
                businessProfileService: StubBusinessProfileService(),
                retailStoreService: StubRetailStoresService(),
                retailStoreMenuService: StubRetailStoreMenuService(),
                basketService: StubBasketService(),
                memberService: StubUserService(),
                checkoutService: StubCheckoutService(),
                addressService: StubAddressService(),
                utilityService: StubUtilityService(),
                imageService: StubImageService(),
                notificationService: StubNotificationService(),
                userPermissionsService: StubUserPermissionsService(),
                searchHistoryService: StubSearchHistoryService()
            )
        }
    }
}
