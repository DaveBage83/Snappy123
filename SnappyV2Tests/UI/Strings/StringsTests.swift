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
        
        Strings.General.Logout.allCases.forEach {
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
        
        Strings.CheckoutView.CreateAccount.allCases.forEach {
            XCTAssertFalse(checkLocalizedString(key: $0), "\($0) is missing from strings file.")
        }
        
        Strings.CheckoutView.GuestCheckoutCard.allCases.forEach {
            XCTAssertFalse(checkLocalizedString(key: $0), "\($0) is missing from strings file.")
        }
        
        Strings.CheckoutView.RetailMembershipIdWarning.allCases.forEach {
            XCTAssertFalse(checkLocalizedString(key: $0), "\($0) is missing from strings file.")
        }
        
        Strings.CheckoutView.LoginToAccount.allCases.forEach {
            XCTAssertFalse(checkLocalizedString(key: $0), "\($0) is missing from strings file.")
        }
        
        Strings.CheckoutView.RetailMembership.allCases.forEach {
            XCTAssertFalse(checkLocalizedString(key: $0), "\($0) is missing from strings file.")
        }
        
        Strings.CheckoutView.AddDetails.allCases.forEach {
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
        
        Strings.PostCodeSearch.allCases.forEach {
            XCTAssertFalse(checkLocalizedString(key: $0), "\($0) is missing from strings file.")
        }
        
        Strings.CheckoutDetails.MarketingPreferences.allCases.forEach {
            XCTAssertFalse(checkLocalizedString(key: $0), "\($0) is missing from strings file.")
        }
        
        Strings.CheckoutDetails.ContactDetails.allCases.forEach {
            XCTAssertFalse(checkLocalizedString(key: $0), "\($0) is missing from strings file.")
        }
        
        Strings.CheckoutDetails.WhereDidYouHear.allCases.forEach {
            XCTAssertFalse(checkLocalizedString(key: $0), "\($0) is missing from strings file.")
        }
        
        Strings.AddressService.allCases.forEach {
            XCTAssertFalse(checkLocalizedString(key: $0), "\($0) is missing from strings file.")
        }
        
        Strings.CheckoutDetails.Errors.Missing.allCases.forEach {
            XCTAssertFalse(checkLocalizedString(key: $0), "\($0) is missing from strings file.")
        }
        
        Strings.CheckoutDetails.AddressSelectionView.allCases.forEach {
            XCTAssertFalse(checkLocalizedString(key: $0), "\($0) is missing from strings file.")
        }
        
        Strings.CheckoutDetails.Submit.allCases.forEach {
            XCTAssertFalse(checkLocalizedString(key: $0), "\($0) is missing from strings file.")
        }
        
        Strings.CheckoutDetails.SavedAddressesSelectionView.allCases.forEach {
            XCTAssertFalse(checkLocalizedString(key: $0), "\($0) is missing from strings file.")
        }
        
        Strings.CheckoutDetails.ChangeFulfilmentMethod.allCases.forEach {
            XCTAssertFalse(checkLocalizedString(key: $0), "\($0) is missing from strings file.")
        }
        
        Strings.CheckoutDetails.EditAddress.allCases.forEach {
            XCTAssertFalse(checkLocalizedString(key: $0), "\($0) is missing from strings file.")
        }
        
        Strings.CheckoutDetails.DeliveryNote.allCases.forEach {
            XCTAssertFalse(checkLocalizedString(key: $0), "\($0) is missing from strings file.")
        }
        
        Strings.OrderSummaryCard.allCases.forEach {
            XCTAssertFalse(checkLocalizedString(key: $0), "\($0) is missing from strings file.")
        }
        
        Strings.CreateAccount.allCases.forEach {
            XCTAssertFalse(checkLocalizedString(key: $0), "\($0) is missing from strings file.")
        }
        
        Strings.Terms.allCases.forEach {
            XCTAssertFalse(checkLocalizedString(key: $0), "\($0) is missing from strings file.")
        }
        
        Strings.ForgotPassword.allCases.forEach {
            XCTAssertFalse(checkLocalizedString(key: $0), "\($0) is missing from strings file.")
        }
        
        Strings.ResetPassword.allCases.forEach {
            XCTAssertFalse(checkLocalizedString(key: $0), "\($0) is missing from strings file.")
        }
        
        Strings.MemberDashboard.allCases.forEach {
            XCTAssertFalse(checkLocalizedString(key: $0), "\($0) is missing from strings file.")
        }
        
        Strings.PlacedOrders.MainView.allCases.forEach {
            XCTAssertFalse(checkLocalizedString(key: $0), "\($0) is missing from strings file.")
        }
        
        Strings.PlacedOrders.OrderSummaryCard.allCases.forEach {
            XCTAssertFalse(checkLocalizedString(key: $0), "\($0) is missing from strings file.")
        }
        
        Strings.PlacedOrders.OrderDetailsView.allCases.forEach {
            XCTAssertFalse(checkLocalizedString(key: $0), "\($0) is missing from strings file.")
        }
        
        Strings.PlacedOrders.OrderStoreView.allCases.forEach {
            XCTAssertFalse(checkLocalizedString(key: $0), "\($0) is missing from strings file.")
        }
        
        Strings.PlacedOrders.Errors.allCases.forEach {
            XCTAssertFalse(checkLocalizedString(key: $0), "\($0) is missing from strings file.")
        }
        
        Strings.ToastNotifications.BasketChangeTitle.allCases.forEach {
            XCTAssertFalse(checkLocalizedString(key: $0), "\($0) is missing from strings file.")
        }
        
        Strings.PayMethods.Card.allCases.forEach {
            XCTAssertFalse(checkLocalizedString(key: $0), "\($0) is missing from strings file.")
        }
        
        Strings.PayMethods.Cash.allCases.forEach {
            XCTAssertFalse(checkLocalizedString(key: $0), "\($0) is missing from strings file.")
        }
        
        Strings.PayMethods.Apple.allCases.forEach {
            XCTAssertFalse(checkLocalizedString(key: $0), "\($0) is missing from strings file.")
        }
        
        Strings.StoreRatings.allCases.forEach {
            XCTAssertFalse(checkLocalizedString(key: $0), "\($0) is missing from strings file.")
        }
        
        Strings.CheckoutServiceErrors.allCases.forEach {
            XCTAssertFalse(checkLocalizedString(key: $0), "\($0) is missing from strings file.")
        }
        
        Strings.CheckoutDetails.AddressDisplayCard.allCases.forEach {
            XCTAssertFalse(checkLocalizedString(key: $0), "\($0) is missing from strings file.")
        }
        
        Strings.CheckoutDetails.CheckoutProgress.allCases.forEach {
            XCTAssertFalse(checkLocalizedString(key: $0), "\($0) is missing from strings file.")
        }
        
        Strings.CheckoutDetails.Errors.NoAddresses.allCases.forEach {
            XCTAssertFalse(checkLocalizedString(key: $0), "\($0) is missing from strings file.")
        }
        
        Strings.General.DriverInterface.allCases.forEach {
            XCTAssertFalse(checkLocalizedString(key: $0), "\($0) is missing from strings file.")
        }

        Strings.EditableCardContainer.Delete.allCases.forEach {
            XCTAssertFalse(checkLocalizedString(key: $0), "\($0) is missing from strings file.")
        }
        
        Strings.MemberDashboard.AddressSelectionView.allCases.forEach {
            XCTAssertFalse(checkLocalizedString(key: $0), "\($0) is missing from strings file.")
        }
        
        Strings.General.Errors.allCases.forEach {
            XCTAssertFalse(checkLocalizedString(key: $0), "\($0) is missing from strings file.")
        }
        
        Strings.Settings.Main.allCases.forEach {
            XCTAssertFalse(checkLocalizedString(key: $0), "\($0) is missing from strings file.")
        }
        
        Strings.Settings.UsefulInfo.allCases.forEach {
            XCTAssertFalse(checkLocalizedString(key: $0), "\($0) is missing from strings file.")
        }
        
        Strings.Settings.MarketingPrefs.allCases.forEach {
            XCTAssertFalse(checkLocalizedString(key: $0), "\($0) is missing from strings file.")
        }
        
        Strings.Settings.PushNotifications.allCases.forEach {
            XCTAssertFalse(checkLocalizedString(key: $0), "\($0) is missing from strings file.")
        }
        
        Strings.FormErrors.allCases.forEach {
            XCTAssertFalse(checkLocalizedString(key: $0), "\($0) is missing from strings file.")
        }
        
        Strings.PushNotifications.allCases.forEach {
            XCTAssertFalse(checkLocalizedString(key: $0), "\($0) is missing from strings file.")
        }

        Strings.MentionMe.Main.allCases.forEach {
            XCTAssertFalse(checkLocalizedString(key: $0), "\($0) is missing from strings file.")
        }
        
        Strings.StoreReview.StaticText.allCases.forEach {
            XCTAssertFalse(checkLocalizedString(key: $0), "\($0) is missing from strings file.")
        }
        
        Strings.VerifyMobileNumber.RequestCodeErrors.allCases.forEach {
            XCTAssertFalse(checkLocalizedString(key: $0), "\($0) is missing from strings file.")
        }
        
        Strings.VerifyMobileNumber.EnterCodeViewStaticText.allCases.forEach {
            XCTAssertFalse(checkLocalizedString(key: $0), "\($0) is missing from strings file.")
        }
        
        Strings.StoresView.DeliveryTiers.allCases.forEach {
            XCTAssertFalse(checkLocalizedString(key: $0), "\($0) is missing from strings file.")
        }
        
        Strings.NetworkAuthenticator.Errors.allCases.forEach {
            XCTAssertFalse(checkLocalizedString(key: $0), "\($0) is missing from strings file.")
        }
        
        Strings.VersionUpateAlert.allCases.forEach {
            XCTAssertFalse(checkLocalizedString(key: $0), "\($0) is missing from strings file.")
        }
        
        Strings.ForgetMe.allCases.forEach {
            XCTAssertFalse(checkLocalizedString(key: $0), "\($0) is missing from strings file.")
        }
        
        Strings.CustomAlert.allCases.forEach {
            XCTAssertFalse(checkLocalizedString(key: $0), "\($0) is missing from strings file.")
        }
        
        Strings.LocationIndicator.allCases.forEach {
            XCTAssertFalse(checkLocalizedString(key: $0), "\($0) is missing from strings file.")
        }
    }
    
    // MARK: - Test customisable localisable strings
    
    func testLocalizedStringFormatting() {
        let testString = "Test"
        
        Strings.General.Custom.allCases.forEach {
            XCTAssertFalse(("**\($0)**" == $0.localizedFormat()), "\($0) is missing from the strings file.")
            XCTAssertTrue($0.localizedFormat(testString).contains(testString))
            print("\($0) = \($0.localizedFormat(testString))")
        }
        
        Strings.StoresView.DeliveryTiersCustom.allCases.forEach {
            XCTAssertFalse(("**\($0)**" == $0.localizedFormat()), "\($0) is missing from the strings file.")
            XCTAssertTrue($0.localizedFormat(testString).contains(testString))
            print("\($0) = \($0.localizedFormat(testString))")
        }
        
        Strings.General.Search.Customisable.allCases.forEach {
            XCTAssertFalse(("**\($0)**" == $0.localizedFormat()), "\($0) is missing from the strings file.")
            XCTAssertTrue($0.localizedFormat(testString).contains(testString))
            print("\($0) = \($0.localizedFormat(testString))")
        }
        
        Strings.General.Login.Customisable.allCases.forEach {
            XCTAssertFalse(("**\($0)**" == $0.localizedFormat()), "\($0) is missing from the strings file.")
            XCTAssertTrue($0.localizedFormat(testString).contains(testString))
            print("\($0) = \($0.localizedFormat(testString))")
        }

        Strings.CheckoutDetails.ChangeFulfilmentMethodCustom.allCases.forEach {
            XCTAssertFalse(("**\($0)**" == $0.localizedFormat()), "\($0) is missing from the strings file.")
            XCTAssertTrue($0.localizedFormat(testString).contains(testString))
            print("\($0) = \($0.localizedFormat(testString))")
        }

        Strings.CustomMemberDashboard.allCases.forEach {
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
        
        Strings.SlotSelection.Customisable.allCases.forEach {
            XCTAssertFalse(("**\($0)**" == $0.localizedFormat()), "\($0) is missing from the strings file.")
            XCTAssertTrue($0.localizedFormat(testString).contains(testString))
            print("\($0) = \($0.localizedFormat(testString))")
        }
        
        Strings.ForgetPasswordCustom.allCases.forEach {
            XCTAssertFalse(("**\($0)**" == $0.localizedFormat()), "\($0) is missing from the strings file.")
            XCTAssertTrue($0.localizedFormat(testString).contains(testString))
            print("\($0) = \($0.localizedFormat(testString))")
        }
        
        Strings.ResetPasswordCustom.allCases.forEach {
            XCTAssertFalse(("**\($0)**" == $0.localizedFormat()), "\($0) is missing from the strings file.")
            XCTAssertTrue($0.localizedFormat(testString).contains(testString))
            print("\($0) = \($0.localizedFormat(testString))")
        }
        
        Strings.StoreReview.InstructionsText.allCases.forEach {
            XCTAssertFalse(("**\($0)**" == $0.localizedFormat()), "\($0) is missing from the strings file.")
            XCTAssertTrue($0.localizedFormat(testString).contains(testString))
            print("\($0) = \($0.localizedFormat(testString))")
        }
        
        Strings.StoreReview.CommentsPlaceholderText.allCases.forEach {
            XCTAssertFalse(("**\($0)**" == $0.localizedFormat()), "\($0) is missing from the strings file.")
            XCTAssertTrue($0.localizedFormat(testString).contains(testString))
            print("\($0) = \($0.localizedFormat(testString))")
        }
        
        Strings.VerifyMobileNumber.EnterCodeViewDynamicText.allCases.forEach {
            XCTAssertFalse(("**\($0)**" == $0.localizedFormat()), "\($0) is missing from the strings file.")
            XCTAssertTrue($0.localizedFormat(testString).contains(testString))
            print("\($0) = \($0.localizedFormat(testString))")
        }
        
        Strings.BasketView.Coupon.Customisable.allCases.forEach {
            XCTAssertFalse(("**\($0)**" == $0.localizedFormat()), "\($0) is missing from the strings file.")
            XCTAssertTrue($0.localizedFormat(testString).contains(testString))
            print("\($0) = \($0.localizedFormat(testString))")
        }
        
        Strings.VersionUpdateCustomisable.allCases.forEach {
            XCTAssertFalse(("**\($0)**" == $0.localizedFormat()), "\($0) is missing from the strings file.")
            XCTAssertTrue($0.localizedFormat(testString).contains(testString))
            print("\($0) = \($0.localizedFormat(testString))")
        }
    }
}
