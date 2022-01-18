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
        memberService: [MockedMemberService.Action] = [],
        addressService: [MockedAddressService.Action] = []
    ) -> DIContainer.Services {
        .init(
            retailStoreService: MockedRetailStoreService(expected: retailStoreService),
            retailStoreMenuService: MockedRetailStoreMenuService(expected: retailStoreMenuService),
            basketService: MockedBasketService(expected: basketService),
            memberService: MockedMemberService(expected: memberService),
            addressService: MockedAddressService(expected: addressService)
        )
    }
    
    func verify(file: StaticString = #file, line: UInt = #line) {
        (retailStoresService as? MockedRetailStoreService)?
            .verify(file: file, line: line)
        (retailStoreMenuService as? MockedRetailStoreMenuService)?
            .verify(file: file, line: line)
        (basketService as? MockedBasketService)?
            .verify(file: file, line: line)
        (memberService as? MockedMemberService)?
            .verify(file: file, line: line)
        (addressService as? MockedAddressService)?
            .verify(file: file, line: line)
    }
}
