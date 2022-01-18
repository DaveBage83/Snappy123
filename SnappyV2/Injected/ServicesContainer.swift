//
//  ServicesContainer.swift
//  SnappyV2
//
//  Created by Henrik Gustavii on 15/09/2021.
//

import Foundation

extension DIContainer {
    struct Services {
        let retailStoresService: RetailStoresServiceProtocol
        let retailStoreMenuService: RetailStoreMenuServiceProtocol
        let basketService: BasketServiceProtocol
        let memberService: MemberServiceProtocol
        let addressService: AddressServiceProtocol
        //let imageService: String
        
        init(
            retailStoreService: RetailStoresServiceProtocol,
            retailStoreMenuService: RetailStoreMenuServiceProtocol,
            basketService: BasketServiceProtocol,
            memberService: MemberServiceProtocol,
            addressService: AddressServiceProtocol
        ) {
            self.retailStoresService = retailStoreService
            self.retailStoreMenuService = retailStoreMenuService
            self.basketService = basketService
            self.memberService = memberService
            self.addressService = addressService
            //self.imagesService = imagesService
            //self.userPermissionsService = userPermissionsService
        }
        
        static var stub: Self {
            .init(
                retailStoreService: StubRetailStoresService(),
                retailStoreMenuService: StubRetailStoreMenuService(),
                basketService: StubBasketService(),
                memberService: StubMemberService(),
                addressService: StubAddressService()/*, imageService: ""*/
            )
        }
    }
    
    
}
