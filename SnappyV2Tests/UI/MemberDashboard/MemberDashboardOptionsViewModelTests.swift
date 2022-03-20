//
//  MemberDashboardOptionsViewModelTests.swift
//  SnappyV2Tests
//
//  Created by David Bage on 20/03/2022.
//

import XCTest
import Combine
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
        XCTAssertEqual(sut.icon, Image.MemberDashboard.Options.dashboard)
    }
    
    func test_init_whenTypeIsOrders() {
        let sut = makeSUT(optionType: .orders, action: {
            print("test")
        }, isActive: false)
        
        XCTAssertFalse(sut.isActive)
        XCTAssertEqual(sut.title, OptionStrings.orders.localized)
        XCTAssertEqual(sut.icon, Image.MemberDashboard.Options.orders)
    }
    
    func test_init_whenTypeIsAddresses() {
        let sut = makeSUT(optionType: .addresses, action: {
            print("test")
        }, isActive: false)
        
        XCTAssertFalse(sut.isActive)
        XCTAssertEqual(sut.title, OptionStrings.addresses.localized)
        XCTAssertEqual(sut.icon, Image.MemberDashboard.Options.addresses)
    }
    
    func test_init_whenTypeIsProfile() {
        let sut = makeSUT(optionType: .profile, action: {
            print("test")
        }, isActive: false)
        
        XCTAssertFalse(sut.isActive)
        XCTAssertEqual(sut.title, OptionStrings.profile.localized)
        XCTAssertEqual(sut.icon, Image.MemberDashboard.Options.profile)
    }
    
    func test_init_whenTypeIsLoyalty() {
        let sut = makeSUT(optionType: .loyalty, action: {
            print("test")
        }, isActive: false)
        
        XCTAssertFalse(sut.isActive)
        XCTAssertEqual(sut.title, OptionStrings.loyalty.localized)
        XCTAssertEqual(sut.icon, Image.MemberDashboard.Options.loyalty)
    }
    
    func test_init_whenTypeIsLogout() {
        let sut = makeSUT(optionType: .logOut, action: {
            print("test")
        }, isActive: false)
        
        XCTAssertFalse(sut.isActive)
        XCTAssertEqual(sut.title, OptionStrings.logout.localized)
        XCTAssertEqual(sut.icon, Image.MemberDashboard.Options.logOut)
    }
    
    func makeSUT(container: DIContainer = DIContainer(appState: AppState(), services: .mocked()), optionType: MemberDashboardOptionsViewModel.MemberDashboardOptionType, action: @escaping () -> Void, isActive: Bool) -> MemberDashboardOptionsViewModel {
        let sut = MemberDashboardOptionsViewModel(optionType, action: action, isActive: isActive)
        return sut
    }
}
