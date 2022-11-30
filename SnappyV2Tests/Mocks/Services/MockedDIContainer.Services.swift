//
//  MockedDIContainer.Services.swift
//  SnappyV2Tests
//
//  Created by Henrik Gustavii on 04/10/2021.
//

import XCTest
@testable import SnappyV2

extension DIContainer.Services {
    enum ServiceType {
        case businessProfile
        case retailStore
        case retailStoreMenu
        case basket
        case member
        case checkout
        case address
        case utility
        case image
        case notifications
        case userPermissions
        case postcodeService
    }
    
    static func mocked(
        businessProfileService: [MockedBusinessProfileService.Action] = [],
        retailStoreService: [MockedRetailStoreService.Action] = [],
        retailStoreMenuService: [MockedRetailStoreMenuService.Action] = [],
        basketService: [MockedBasketService.Action] = [],
        memberService: [MockedUserService.Action] = [],
        checkoutService: [MockedCheckoutService.Action] = [],
        addressService: [MockedAddressService.Action] = [],
        utilityService: [MockedUtilityService.Action] = [],
        imageService: [MockedAsyncImageService.Action] = [],
        notificationService: [MockedNotificationService.Action] = [],
        userPermissionsService: [MockedUserPermissionsService.Action] = [],
        postcodeService: [MockedPostcodeService.Action] = []
    ) -> DIContainer.Services {
        .init(
            businessProfileService: MockedBusinessProfileService(expected: businessProfileService),
            retailStoreService: MockedRetailStoreService(expected: retailStoreService),
            retailStoreMenuService: MockedRetailStoreMenuService(expected: retailStoreMenuService),
            basketService: MockedBasketService(expected: basketService),
            memberService: MockedUserService(expected: memberService),
            checkoutService: MockedCheckoutService(expected: checkoutService),
            addressService: MockedAddressService(expected: addressService),
            utilityService: MockedUtilityService(expected: utilityService),
            imageService: MockedAsyncImageService(expected: imageService),
            notificationService: MockedNotificationService(expected: notificationService),
            userPermissionsService: MockedUserPermissionsService(expected: userPermissionsService),
            postcodeService: MockedPostcodeService(expected: [])
        )
    }
    
    func verify(as serviceType: ServiceType, file: StaticString = #file, line: UInt = #line) {
        switch serviceType {
        case .businessProfile:
            (businessProfileService as? MockedBusinessProfileService)?
                .verify(file: file, line: line)
        case .retailStore:
            (retailStoresService as? MockedRetailStoreService)?
                .verify(file: file, line: line)
        case .retailStoreMenu:
            (retailStoreMenuService as? MockedRetailStoreMenuService)?
                .verify(file: file, line: line)
        case .basket:
            (basketService as? MockedBasketService)?
                .verify(file: file, line: line)
        case .member:
            (memberService as? MockedUserService)?
                .verify(file: file, line: line)
        case .checkout:
            (checkoutService as? MockedCheckoutService)?
                .verify(file: file, line: line)
        case .address:
            (addressService as? MockedAddressService)?
                .verify(file: file, line: line)
        case .utility:
            (utilityService as? MockedUtilityService)?
                .verify(file: file, line: line)
        case .image:
            (imageService as? MockedAsyncImageService)?
                .verify(file: file, line: line)
        case .notifications:
            (notificationService as? MockedNotificationService)?
                .verify(file: file, line: line)
        case .userPermissions:
            (userPermissionsService as? MockedUserPermissionsService)?
                .verify(file: file, line: line)
        case .postcodeService:
            (postcodeService as? MockedPostcodeService)?
                .verify(file: file, line: line)
        }
    }
}
