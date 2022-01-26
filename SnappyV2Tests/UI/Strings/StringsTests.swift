//
//  StringsTests.swift
//  SnappyV2Tests
//
//  Created by David Bage on 07/01/2022.
//

import XCTest
@testable import SnappyV2

class StringsTests: XCTestCase {
    func checkLocalizedString(key: SnappyString) -> Bool {
        print("\(key) = \(key.localized)")
        return (key.localized == "**\(key)**")
    }
    
    // MARK: - Test standard localisable strings
    
    func testLocalizedStringPresent() {
        Strings.General.allCases.forEach {
            XCTAssertFalse(checkLocalizedString(key: $0), "\($0) is missing from strings file.")
        }
        
        Strings.General.Login.allCases.forEach {
            XCTAssertFalse(checkLocalizedString(key: $0), "\($0) is missing from strings file.")
        }
        
        Strings.General.Search.allCases.forEach {
            XCTAssertFalse(checkLocalizedString(key: $0), "\($0) is missing from strings file.")
        }
        
        Strings.RootView.Tabs.allCases.forEach {
            XCTAssertFalse(checkLocalizedString(key: $0), "\($0) is missing from strings file.")
        }
        
        Strings.RootView.ChangeStore.allCases.forEach {
            XCTAssertFalse(checkLocalizedString(key: $0), "\($0) is missing from strings file.")
        }
        
        Strings.InitialView.allCases.forEach {
            XCTAssertFalse(checkLocalizedString(key: $0), "\($0) is missing from strings file.")
        }
        
        Strings.CheckoutView.Progress.allCases.forEach {
            XCTAssertFalse(checkLocalizedString(key: $0), "\($0) is missing from strings file.")
        }
        
        Strings.CheckoutView.GuestCheckoutCard.allCases.forEach {
            XCTAssertFalse(checkLocalizedString(key: $0), "\($0) is missing from strings file.")
        }
        
        Strings.CheckoutView.LoginToAccount.allCases.forEach {
            XCTAssertFalse(checkLocalizedString(key: $0), "\($0) is missing from strings file.")
        }
        
        Strings.CheckoutView.AddDetails.allCases.forEach {
            XCTAssertFalse(checkLocalizedString(key: $0), "\($0) is missing from strings file.")
        }
        
        Strings.CheckoutView.AddAddress.allCases.forEach {
            XCTAssertFalse(checkLocalizedString(key: $0), "\($0) is missing from strings file.")
        }
        
        Strings.CheckoutView.TsAndCs.allCases.forEach {
            XCTAssertFalse(checkLocalizedString(key: $0), "\($0) is missing from strings file.")
        }
        
        Strings.BasketView.allCases.forEach {
            XCTAssertFalse(checkLocalizedString(key: $0), "\($0) is missing from strings file.")
        }
        
        Strings.BasketView.DeliveryBanner.allCases.forEach {
            XCTAssertFalse(checkLocalizedString(key: $0), "\($0) is missing from strings file.")
        }
        
        Strings.BasketView.Coupon.allCases.forEach {
            XCTAssertFalse(checkLocalizedString(key: $0), "\($0) is missing from strings file.")
        }
        
        Strings.BasketView.ListEntry.allCases.forEach {
            XCTAssertFalse(checkLocalizedString(key: $0), "\($0) is missing from strings file.")
        }
        
        Strings.StoresView.allCases.forEach {
            XCTAssertFalse(checkLocalizedString(key: $0), "\($0) is missing from strings file.")
        }
        
        Strings.StoresView.StoreTypes.allCases.forEach {
            XCTAssertFalse(checkLocalizedString(key: $0), "\($0) is missing from strings file.")
        }
        
        Strings.StoresView.FailedSearch.allCases.forEach {
            XCTAssertFalse(checkLocalizedString(key: $0), "\($0) is missing from strings file.")
        }
        
        Strings.StoresView.StoreStatus.allCases.forEach {
            XCTAssertFalse(checkLocalizedString(key: $0), "\($0) is missing from strings file.")
        }
        
        Strings.StoreInfo.Delivery.allCases.forEach {
            XCTAssertFalse(checkLocalizedString(key: $0), "\($0) is missing from strings file.")
        }
        
        Strings.SlotSelection.allCases.forEach {
            XCTAssertFalse(checkLocalizedString(key: $0), "\($0) is missing from strings file.")
        }
        
        Strings.ProductsView.allCases.forEach {
            XCTAssertFalse(checkLocalizedString(key: $0), "\($0) is missing from strings file.")
        }
        
        Strings.ProductsView.ProductCard.allCases.forEach {
            XCTAssertFalse(checkLocalizedString(key: $0), "\($0) is missing from strings file.")
        }
        
        Strings.ProductsView.ProductDetail.allCases.forEach {
            XCTAssertFalse(checkLocalizedString(key: $0), "\($0) is missing from strings file.")
        }
        
        Strings.ProductOptions.allCases.forEach {
            XCTAssertFalse(checkLocalizedString(key: $0), "\($0) is missing from strings file.")
        }
        
        Strings.ProductCarousel.allCases.forEach {
            XCTAssertFalse(checkLocalizedString(key: $0), "\($0) is missing from strings file.")
        }
    }
    
    // MARK: - Test customisable localisable strings
    
    func testLocalizedStringFormatting() {
        let testString = "Test"
        
        Strings.General.Login.Customisable.allCases.forEach {
            XCTAssertFalse(("**\($0)**" == $0.localizedFormat()), "\($0) is missing from the strings file.")
            XCTAssertTrue($0.localizedFormat(testString).contains(testString))
            print("\($0) = \($0.localizedFormat(testString))")
        }
        
        Strings.BasketView.DeliveryBanner.Customisable.allCases.forEach {
            XCTAssertFalse(("**\($0)**" == $0.localizedFormat()), "\($0) is missing from the strings file.")
            XCTAssertTrue($0.localizedFormat(testString).contains(testString))
            print("\($0) = \($0.localizedFormat(testString))")
        }
        
        Strings.StoreInfo.Delivery.Customisable.allCases.forEach {
            XCTAssertFalse(("**\($0)**" == $0.localizedFormat()), "\($0) is missing from the strings file.")
            XCTAssertTrue($0.localizedFormat(testString).contains(testString))
            print("\($0) = \($0.localizedFormat(testString))")
        }
        
        Strings.ProductOptions.Customisable.allCases.forEach {
            XCTAssertFalse(("**\($0)**" == $0.localizedFormat()), "\($0) is missing from the strings file.")
            XCTAssertTrue($0.localizedFormat(testString).contains(testString))
            print("\($0) = \($0.localizedFormat(testString))")
        }
        
        Strings.BasketView.Promotions.allCases.forEach {
            XCTAssertFalse(("**\($0)**" == $0.localizedFormat()), "\($0) is missing from the strings file.")
            XCTAssertTrue($0.localizedFormat(testString).contains(testString))
            print("\($0) = \($0.localizedFormat(testString))")
        }
        
        Strings.SlotSelection.Customisable.allCases.forEach {
            XCTAssertFalse(("**\($0)**" == $0.localizedFormat()), "\($0) is missing from the strings file.")
            XCTAssertTrue($0.localizedFormat(testString).contains(testString))
            print("\($0) = \($0.localizedFormat(testString))")
        }
    }
}
