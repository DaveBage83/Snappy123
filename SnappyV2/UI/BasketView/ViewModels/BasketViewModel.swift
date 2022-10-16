//
//  BasketViewModel.swift
//  SnappyV2
//
//  Created by Henrik Gustavii on 20/12/2021.
//

import Combine
import Foundation
import OSLog
import UIKit // required for UIApplication.shared.open

// import 3rd party
import AppsFlyerLib
import Firebase

struct BasketDisplayableFee: Identifiable {
    let id: UUID
    let text: String
    let amount: String
    let description: String?
}

@MainActor
class BasketViewModel: ObservableObject {
    
    typealias BasketViewStrings = Strings.BasketView
    
    enum BasketViewError: LocalizedError {
        case memberRequiredForCoupon
        case verifiedAccountRequiredForCouponWhenNoMobileNumber
        case verifiedAccountRequiredForCouponWhenMobileNumber
        case minimumSpendNotMet
        case couponAppliedUnsuccessfully
        
        var errorDescription: String? {
            switch self {
            case .memberRequiredForCoupon:
                return BasketViewStrings.Coupon.memberRequiredForCoupon.localized
            case .verifiedAccountRequiredForCouponWhenNoMobileNumber:
                return BasketViewStrings.Coupon.Customisable.verifiedAccountRequiredForCoupon.localizedFormat(BasketViewStrings.Coupon.verifiedAccountInstructionsWhenMobileNumber.localized)
            case .verifiedAccountRequiredForCouponWhenMobileNumber:
                return BasketViewStrings.Coupon.Customisable.verifiedAccountRequiredForCoupon.localizedFormat(BasketViewStrings.Coupon.verifiedAccountInstructionsWhenMobileNumber.localized)
            case .minimumSpendNotMet:
                return BasketViewStrings.moreItemsRequired.localized
            case .couponAppliedUnsuccessfully:
                return BasketViewStrings.Coupon.failure.localized
            }
        }
    }
    
    enum TipType: String {
        case driver
    }
    
    enum TipLevel: Int {
        case unhappy
        case neutral
        case happy
        case veryHappy
        case insanelyHappy
    }
    
    let container: DIContainer
    @Published var basket: Basket?
    private var selectedFulfilmentMethod: RetailStoreOrderMethodType
    var selectedStore: RetailStoreDetails?
    
    @Published var couponCode = ""
    @Published var applyingCoupon = false
    @Published var removingCoupon = false
    @Published var isUpdatingItem = false
    @Published var driverTip: Double = 0
    @Published var driverTipPriceString: String?
    @Published var changeTipBy: Double = 0
    let driverTipIncrement: Double
    let tipLevels: [TipLimitLevel]?
    @Published var updatingTip: Bool = false
    @Published var serviceFeeDescription: (title: String, description: String)?
    @Published var couponFieldHasError = false
    @Published var showingServiceFeeAlert = false
    @Published var showCouponAlert = false
    @Published var successfulCouponText: String?
    @Published var mentionMeButtonText: String?
    @Published var showMentionMeLoading = false
    @Published var showMentionMeWebView = false
    @Published var mentionMeRefereeRequestResult = MentionMeRequestResult(success: false, type: .referee, webViewURL: nil, buttonText: nil, postMessageConstants: nil, applyCoupon: nil, openInBrowser: nil)
    
    @Published var isContinueToCheckoutTapped = false
    
    @Published var profile: MemberProfile?
    
    @Published var errorNeedsUserAction: Error?
    
    var isMemberSignedIn: Bool {
        profile != nil
    }
    
    var showCheckoutButton: Bool {
        return selectedStore?.orderMethods?[selectedFulfilmentMethod.rawValue]?.status != .closed && isSlotExpired == false
    }

    private var cancellables = Set<AnyCancellable>()
    private var updatingTipTask: Task<Void, Never>?
    
    init(container: DIContainer) {
        self.container = container
        let appState = container.appState
        
        _basket = .init(initialValue: appState.value.userData.basket)
        selectedFulfilmentMethod = appState.value.userData.selectedFulfilmentMethod
        selectedStore = appState.value.userData.selectedStore.value
        driverTipIncrement = appState.value.businessData.businessProfile?.driverTipIncrement ?? 0
        tipLevels = appState.value.businessData.businessProfile?.tipLimitLevels
        setupBasket(with: appState)
        setupSelectedOrderMethod(with: appState)
        setupSelectedStore(with: appState)
        setupDriverTip()
        setupChangeTipBy()
        
        setupBindToProfile(with: appState)
    }
    
    deinit {
        updatingTipTask?.cancel()
    }
    
    var minimumSpendReached: Bool {
        guard let basket = basket else { return true }
        return basket.fulfilmentMethod.minSpend <= basket.orderSubtotal
    }
    
    var unmetCouponMemberAccountRequirement: BasketViewError? {
        guard
            let basket = basket,
            let registeredMemberRequirement = basket.coupon?.registeredMemberRequirement,
            registeredMemberRequirement != .none
        else { return nil }
        
        if let memberProfile = container.appState.value.userData.memberProfile {
            if registeredMemberRequirement == .registeredWithVerification && memberProfile.mobileValidated == false {
                if memberProfile.mobileContactNumber?.count ?? 0 < 7 {
                    return .verifiedAccountRequiredForCouponWhenNoMobileNumber
                } else {
                    return .verifiedAccountRequiredForCouponWhenMobileNumber
                }
            }
        } else {
            return .memberRequiredForCoupon
        }
        
        return nil
    }
    
    var fulfilmentMethodMinSpendPriceString: String {
        (basket?.fulfilmentMethod.minSpend ?? 0).toCurrencyString(using: selectedStore?.currency ?? AppV2Constants.Business.defaultStoreCurrency)
    }
    
    var deductCostPriceString: String? {
        basket?.coupon?.deductCost.toCurrencyString(using: selectedStore?.currency ?? AppV2Constants.Business.defaultStoreCurrency)
    }
    
    var orderSubtotalPriceString: String? {
        basket?.orderSubtotal.toCurrencyString(using: selectedStore?.currency ?? AppV2Constants.Business.defaultStoreCurrency)
    }
    
    var orderTotalPriceString: String? {
        basket?.orderTotal.toCurrencyString(using: selectedStore?.currency ?? AppV2Constants.Business.defaultStoreCurrency)
    }
    
    var showDriverTips: Bool {
        if selectedFulfilmentMethod == .delivery, let driverTips = selectedStore?.tips, let driverTip = driverTips.first(where: { $0.type == TipType.driver.rawValue }), driverTip.enabled {
            return true
        }
        return false
    }
    
    var displayableFees: [BasketDisplayableFee]? {
        basket?.fees?.reduce(nil, { (feesArray, fee) -> [BasketDisplayableFee]? in
            var array = feesArray ?? []
            array.append(
                BasketDisplayableFee(
                    id: UUID(),
                    text: fee.title,
                    amount: fee.amount.toCurrencyString(using: selectedStore?.currency ?? AppV2Constants.Business.defaultStoreCurrency),
                    description: fee.description
                )
            )
            return array
        })
    }
    
    var isSlotExpired: Bool {
        if let expires = basket?.selectedSlot?.expires {
            return expires.trueDate < Date().trueDate
        }
        
        if let end = basket?.selectedSlot?.end?.trueDate {
            return end.trueDate < Date().trueDate
        }
        
        return false
    }

    private func setupBindToProfile(with appState: Store<AppState>) {
        appState
            .map(\.userData.memberProfile)
            .receive(on: RunLoop.main)
            .sink { [weak self] profile in
                guard let self = self else { return }
                self.profile = profile
            }
            .store(in: &cancellables)
    }
    
    var tipLevel: TipLevel {
        if let tipLevel = tipLevels?.first(where: { $0.level == 4 }), driverTip >= tipLevel.amount {
            return .insanelyHappy
        } else if let tipLevel = tipLevels?.first(where: { $0.level == 3 }), driverTip >= tipLevel.amount {
            return .veryHappy
        } else if let tipLevel = tipLevels?.first(where: { $0.level == 2 }), driverTip >= tipLevel.amount {
            return .happy
        } else if let tipLevel = tipLevels?.first(where: { $0.level == 1 }), driverTip >= tipLevel.amount {
            return .neutral
        }
        return .unhappy
    }
    
    var basketIsEmpty: Bool {
        guard let basket = basket else {
            return true
        }
        return basket.items.isEmpty
    }
    
    var disableDecreaseTipButton: Bool { driverTip == 0 }
    
    var showBasketItems: Bool { basket?.items.isEmpty == false }
    
    private func setupBasket(with appState: Store<AppState>) {
        appState
            .map(\.userData.basket)
            .receive(on: RunLoop.main)
            .sink { [weak self] basket in
                guard let self = self else { return }
                self.basket = basket
                if appState.value.businessData.businessProfile?.mentionMeEnabled ?? false {
                    if let cachedRefereeResult = appState.value.staticCacheData.mentionMeRefereeResult {
                        self.updateMentionMeUI(with: cachedRefereeResult)
                    } else {
                        self.mentionMeButtonText = nil
                        self.showMentionMeLoading = true
                        // attempt to fetch the result
                        Task {
                            do {
                                self.updateMentionMeUI(
                                    with: try await MentionMeHandler(container: self.container).perform(request: .referee)
                                )
                            } catch {
                                // the error will have been logged by the perform method so
                                // only need to hide the progress view
                                guaranteeMainThread {
                                    self.showMentionMeLoading = false
                                }
                            }
                        }
                    }
                }
            }
            .store(in: &cancellables)
    }
    
    private func updateMentionMeUI(with refereeResult: MentionMeRequestResult) {
        guaranteeMainThread { [weak self] in
            guard let self = self else { return }
            if
                let buttonText = refereeResult.buttonText,
                refereeResult.success,
                refereeResult.webViewURL != nil
            {
                self.mentionMeButtonText = buttonText
            } else {
                self.mentionMeButtonText = nil
            }
            self.showMentionMeLoading = false
        }
    }
    
    private func setupSelectedOrderMethod(with appState: Store<AppState>) {
        appState
            .map(\.userData.selectedFulfilmentMethod)
            .removeDuplicates()
            .receive(on: RunLoop.main)
            .assignWeak(to: \.selectedFulfilmentMethod, on: self)
            .store(in: &cancellables)
    }
    
    private func setupSelectedStore(with appState: Store<AppState>) {
        appState
            .map(\.userData.selectedStore)
            .removeDuplicates()
            .receive(on: RunLoop.main)
            .sink { [weak self] store in
                guard let self = self else { return }
                self.selectedStore = store.value
            }
            .store(in: &cancellables)
    }
    
    private func setupDriverTip() {
        $basket
            .sink { [weak self] basket in
                guard let self = self else { return }
                if let tip = basket?.tips?.first(where: { $0.type == TipType.driver.rawValue }) {
                    self.driverTip = tip.amount
                    self.driverTipPriceString = tip.amount.toCurrencyString(using: self.selectedStore?.currency ?? AppV2Constants.Business.defaultStoreCurrency)
                } else if self.showDriverTips {
                    self.driverTip = 0
                    self.driverTipPriceString = (0.0).toCurrencyString(using: self.selectedStore?.currency ?? AppV2Constants.Business.defaultStoreCurrency)
                }
            }
            .store(in: &cancellables)
    }
    
    func submitCoupon() async {
        if couponCode.isEmpty == false {
            applyingCoupon = true
            
            do {
                try await self.container.services.basketService.applyCoupon(code: self.couponCode)
                
                Logger.basket.info("Added coupon: \(self.couponCode)")
                self.applyingCoupon = false
                self.successfulCouponText = Strings.BasketView.Coupon.Customisable.successfullyAddedCoupon.localizedFormat(self.couponCode)
                self.couponCode = ""
                couponFieldHasError = false
                
                // silently trigger fetching a mobile verification code if required by the coupon
                if unmetCouponMemberAccountRequirement == .verifiedAccountRequiredForCouponWhenMobileNumber {
                    do {
                        let openView = try await container.services.memberService.requestMobileVerificationCode()
                        if openView {
                            // The main SnappyV2App will display the app state because the view can
                            // also be requested in various other places within the app such as
                            // from the member area
                            container.appState.value.routing.showVerifyMobileView = true
                        }
                    } catch {
                        Logger.member.error("Failed to request SMS Mobile verification code: \(error.localizedDescription)")
                    }
                }
                
            } catch {
                self.errorNeedsUserAction = error
                Logger.basket.error("Failed to add coupon: \(self.couponCode) - \(error.localizedDescription)")
                self.applyingCoupon = false
                couponFieldHasError = true
            }
        } else {
            errorNeedsUserAction = BasketViewError.couponAppliedUnsuccessfully
            couponFieldHasError = true
        }
    }
    
    func removeCoupon() async {
        if let coupon = basket?.coupon {
            removingCoupon = true
            
            do {
                try await container.services.basketService.removeCoupon()
                
                Logger.basket.info("Removed coupon: \(coupon.name)")
                self.removingCoupon = false
            } catch {
                self.errorNeedsUserAction = error
                Logger.basket.error("Failed to remove coupon: \(coupon.name) - \(error.localizedDescription)")
                self.removingCoupon = false
            }
        }
    }
    
    func clearCouponAndContinue() async {
        couponCode = ""
        await checkoutTapped()
    }
    
    func checkoutTapped() async {
        guard minimumSpendReached else {
            errorNeedsUserAction = BasketViewError.minimumSpendNotMet
            container.eventLogger.sendEvent(for: .checkoutBlockedByMinimumSpend, with: .firebaseAnalytics, params: [:])
            return
        }
        
        if let unmetCouponMemberAccountRequirement = unmetCouponMemberAccountRequirement {
            if unmetCouponMemberAccountRequirement == .verifiedAccountRequiredForCouponWhenMobileNumber {
                // attempt to request the verification code
                do {
                    let openView = try await container.services.memberService.requestMobileVerificationCode()
                    if openView {
                        // The main SnappyV2App will display the app state because the view can
                        // also be requested in various other places within the app such as
                        // from the member area
                        container.appState.value.routing.showVerifyMobileView = true
                    }
                } catch {
                    // for whatever reason the request for the code to be sent failed so display
                    // the original error message - better than displaying the network error
                    // because requestMobileVerificationCode() is more of a background call than
                    // being explicity initiated by the user
                    errorNeedsUserAction = unmetCouponMemberAccountRequirement
                    Logger.member.error("Failed to request SMS Mobile verification code: \(error.localizedDescription)")
                }
            } else {
                errorNeedsUserAction = unmetCouponMemberAccountRequirement
            }
            // block the customer checking out until verified
            return
        }
        
        if couponCode.isEmpty {
            isContinueToCheckoutTapped = true
            
            if let basket = basket {
                var itemIds: [Int] = []
                var totalItemQuantity: Int = 0
                
                for item in basket.items {
                    itemIds.append(item.menuItem.id)
                    totalItemQuantity += item.quantity
                }
                
                var params: [String: Any] = [:]
                
                if let storeId = basket.storeId {
                    params["store_id"] = "\(storeId)"
                }
                
                params[AFEventParamPrice] = basket.orderTotal
                params[AFEventParamContentId] = itemIds
                params[AFEventParamCurrency] = AppV2Constants.Business.currencyCode
                params[AFEventParamQuantity] = totalItemQuantity
                
                if let member = container.appState.value.userData.memberProfile {
                    params["member_id"] = member.uuid
                }
                
                container.eventLogger.sendEvent(for: .initiatedCheckout, with: .appsFlyer, params: params)
            }
        } else {
            showCouponAlert = true
        }
    }
    
    func showServiceFeeAlert(title: String, description: String) {
        self.serviceFeeDescription = (title, description)
        showingServiceFeeAlert = true
    }
    
    func dismissAlert() {
        showingServiceFeeAlert = false
    }

    func updateBasketItem(basketItem: BasketItem, quantity: Int) async {
        isUpdatingItem = true
        
        if quantity == 0 {
            await removeBasketItem(basketLineId: basketItem.basketLineId, item: basketItem.menuItem)
        } else {
            #warning("Check if defaults affect basket item")
            let basketItemRequest = BasketItemRequest(menuItemId: basketItem.menuItem.id, quantity: quantity, sizeId: 0, bannerAdvertId: 0, options: [], instructions: nil)
            
            do {
                try await self.container.services.basketService.updateItem(basketItemRequest: basketItemRequest, basketItem: basketItem)
                Logger.basket.info("Updated basket item id: \(basketItem.basketLineId) with \(quantity) in basket")
                
                self.isUpdatingItem = false
            } catch {
                self.errorNeedsUserAction = error
                Logger.basket.error("Error updating \(basketItem.basketLineId) in basket - \(error.localizedDescription)")
                
                self.isUpdatingItem = false
            }
        }
    }
    
    func removeBasketItem(basketLineId: Int, item: RetailStoreMenuItem) async {
        do {
            try await self.container.services.basketService.removeItem(basketLineId: basketLineId, item: item)
            
            self.isUpdatingItem = false
        } catch {
            self.errorNeedsUserAction = error
            Logger.basket.info("Failed to remove item - Error: \(error.localizedDescription)")
            
            self.isUpdatingItem = false
        }
    }
    
    func increaseTip() { changeTipBy += driverTipIncrement }
    
    func decreaseTip() { changeTipBy -= driverTipIncrement }
    
    private func updateTip(with tipChange: Double) async {
        updatingTip = true
        
        do {
            try await self.container.services.basketService.updateTip(to: tipChange)
            
            Logger.basket.log("Updated tip to \(tipChange)")
            await MainActor.run {
                self.updatingTip = false
                self.changeTipBy = 0
            }
        } catch {
            self.errorNeedsUserAction = error
            Logger.basket.error("Could not update driver tip - Error: \(error.localizedDescription)")
            self.updatingTip = false
            self.changeTipBy = 0
        }
    }
    
    func startShoppingPressed() {
        container.appState.value.routing.selectedTab = .menu
    }
    
    func setupChangeTipBy() {
        $changeTipBy
            .debounce(for: 0.4, scheduler: RunLoop.main)
            .receive(on: RunLoop.main)
            .sink { [weak self] newValue in
                guard let self = self else { return }
                if newValue == 0 { return } // Avoids looping when updateTip resets changeTipBy
                self.updatingTipTask = Task { [weak self] in
                    guard let self = self else { return }
                    var updateValue = self.driverTip + newValue
                    if updateValue <= 0 { updateValue = 0 } // updateTip can't take negative numbers
                    await self.updateTip(with: updateValue)
                }
            }
            .store(in: &cancellables)
    }
    
    func onBasketViewSendEvent() {
        if let basket = basket {
            var totalItemQuantity: Int = 0
            for item in basket.items {
                totalItemQuantity += item.quantity
            }
            
            var params: [String: Any] = [
                AFEventParamPrice: basket.orderTotal,
                AFEventParamQuantity: totalItemQuantity
            ]
            container.eventLogger.sendEvent(for: .viewCart, with: .appsFlyer, params: params)
            
            params = [
                "basketTotal": basket.orderTotal
            ]
            container.eventLogger.sendEvent(for: .viewCart, with: .iterable, params: params)
            
            params = [
                AnalyticsParameterItems: EventLogger.getFirebaseItemsArray(from: basket.items),
                AnalyticsParameterCurrency: container.appState.value.userData.selectedStore.value?.currency.currencyCode ?? AppV2Constants.Business.currencyCode,
                AnalyticsParameterValue: NSDecimalNumber(value: basket.orderTotal).rounding(accordingToBehavior: EventLogger.decimalBehavior).doubleValue
            ]
            
            container.eventLogger.sendEvent(for: .viewCart, with: .firebaseAnalytics, params: params)
        }
    }
    
    func showMentionMeReferral() {
        if
            let refereeResult = container.appState.value.staticCacheData.mentionMeRefereeResult,
            let webViewURL = refereeResult.webViewURL,
            refereeResult.success
        {
            container.eventLogger.sendEvent(for: .mentionMeRefereeView, with: .appsFlyer, params: [:])
            container.eventLogger.sendEvent(for: .mentionMeRefereeView, with: .firebaseAnalytics, params: [:])
            if refereeResult.openInBrowser ?? false {
                UIApplication.shared.open(webViewURL, options: [:], completionHandler: nil)
            } else {
                mentionMeRefereeRequestResult = refereeResult
                showMentionMeWebView = true
            }
        }
    }
    
    func mentionMeWebViewDismissed(with couponAction: MentionMeCouponAction?) {
        self.showMentionMeWebView = false
        
        if let couponAction = couponAction {
            self.couponCode = couponAction.couponCode
            Task {
                await self.submitCoupon()
            }
        }
    }
    
    func dismissView() {
        isContinueToCheckoutTapped = false
    }
}
