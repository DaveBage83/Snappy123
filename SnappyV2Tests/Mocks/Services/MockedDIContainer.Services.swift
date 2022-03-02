//
//  MockedDIContainer.Services.swift
//  SnappyV2Tests
//
//  Created by Henrik Gustavii on 04/10/2021.
//

import XCTest
@testable import SnappyV2

extension DIContainer.Services {
    static func mocked(
        retailStoreService: [MockedRetailStoreService.Action] = [],
        retailStoreMenuService: [MockedRetailStoreMenuService.Action] = [],
        basketService: [MockedBasketService.Action] = [],
        memberService: [MockedUserService.Action] = [],
        checkoutService: [MockedCheckoutService.Action] = [],
        addressService: [MockedAddressService.Action] = [],
        utilityService: [MockedUtilityService.Action] = [],
        imageService: [MockedImageService.Action] = []
    ) -> DIContainer.Services {
        .init(
            retailStoreService: MockedRetailStoreService(expected: retailStoreService),
            retailStoreMenuService: MockedRetailStoreMenuService(expected: retailStoreMenuService),
            basketService: MockedBasketService(expected: basketService),
            userService: MockedUserService(expected: memberService),
            checkoutService: MockedCheckoutService(expected: checkoutService),
            addressService: MockedAddressService(expected: addressService),
            utilityService: MockedUtilityService(expected: utilityService),
            imageService: MockedImageService(expected: imageService)
        )
    }
    
    func verify(file: StaticString = #file, line: UInt = #line) {
        (retailStoresService as? MockedRetailStoreService)?
            .verify(file: file, line: line)
        (retailStoreMenuService as? MockedRetailStoreMenuService)?
            .verify(file: file, line: line)
        (basketService as? MockedBasketService)?
            .verify(file: file, line: line)
        (userService as? MockedUserService)?
            .verify(file: file, line: line)
        (checkoutService as? MockedCheckoutService)?
            .verify(file: file, line: line)
        (addressService as? MockedAddressService)?
            .verify(file: file, line: line)
        (utilityService as? MockedUtilityService)?
            .verify(file: file, line: line)
        (imageService as? MockedImageService)?
            .verify(file: file, line: line)
    }
}
