//
//  MemberDashboardOptionsViewModelTests.swift
//  SnappyV2Tests
//
//  Created by David Bage on 20/03/2022.
//

import XCTest
import SwiftUI
@testable import SnappyV2

class MemberDashboardOptionsViewModelTests: XCTestCase {
    
    typealias OptionStrings = Strings.MemberDashboard.Options
    
    func test_init_whenTypeIsDashboard() {
        let sut = makeSUT(optionType: .dashboard, action: {
            print("test")
        }, isActive: false)
        
        XCTAssertFalse(sut.isActive)
        XCTAssertEqual(sut.title, OptionStrings.dashboard.localized)
    }
    
    func test_init_whenTypeIsOrders() {
        let sut = makeSUT(optionType: .orders, action: {}, isActive: false)
        
        XCTAssertFalse(sut.isActive)
        XCTAssertEqual(sut.title, OptionStrings.orders.localized)
    }
    
    func test_init_whenTypeIsAddresses() {
        let sut = makeSUT(optionType: .addresses, action: {
            print("test")
        }, isActive: false)
        
        XCTAssertFalse(sut.isActive)
        XCTAssertEqual(sut.title, OptionStrings.addresses.localized)
    }
    
    func test_init_whenTypeIsProfile() {
        let sut = makeSUT(optionType: .profile, action: {
            print("test")
        }, isActive: false)
        
        XCTAssertFalse(sut.isActive)
        XCTAssertEqual(sut.title, OptionStrings.profile.localized)
    }
    
    func test_init_whenTypeIsLoyalty() {
        let sut = makeSUT(optionType: .loyalty, action: {
            print("test")
        }, isActive: false)
        
        XCTAssertFalse(sut.isActive)
        XCTAssertEqual(sut.title, OptionStrings.loyalty.localized)
    }
    
    func test_init_whenTypeIsLogout() {
        let sut = makeSUT(optionType: .logOut, action: {
            print("test")
        }, isActive: false)
        
        XCTAssertFalse(sut.isActive)
        XCTAssertEqual(sut.title, OptionStrings.logout.localized)
    }
    
    func makeSUT(container: DIContainer = DIContainer(appState: AppState(), services: .mocked()), optionType: MemberDashboardOptionsViewModel.MemberDashboardOptionType, action: @escaping () -> Void, isActive: Bool) -> MemberDashboardOptionsViewModel {
        let sut = MemberDashboardOptionsViewModel(optionType, action: action, isActive: isActive)
        trackForMemoryLeaks(sut)
        return sut
    }
}
