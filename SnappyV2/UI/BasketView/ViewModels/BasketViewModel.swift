//
//  BasketViewModel.swift
//  SnappyV2
//
//  Created by Henrik Gustavii on 20/12/2021.
//

import Combine
import Foundation
import OSLog
import AppsFlyerLib
import UIKit // required for UIApplication.shared.open

@MainActor
class BasketViewModel: ObservableObject {
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
    @Published var changeTipBy: Double = 0
    @Published var showMinSpendWarning = false
    let driverTipIncrement: Double
    let tipLevels: [TipLimitLevel]?
    @Published var updatingTip: Bool = false
    @Published var serviceFeeDescription: (title: String, description: String)?
    @Published var couponAppliedSuccessfully = false
    @Published var couponAppliedUnsuccessfully = false
    @Published var showingServiceFeeAlert = false
    @Published var showCouponAlert = false
    
    @Published var mentionMeButtonText: String?
    @Published var showMentionMeLoading = false
    @Published var showMentionMeWebView = false
    @Published var mentionMeRefereeRequestResult = MentionMeRequestResult(success: false, type: .referee, webViewURL: nil, buttonText: nil, postMessageConstants: nil, applyCoupon: nil, openInBrowser: nil)
    
    @Published var isContinueToCheckoutTapped = false
    @Published var profile: MemberProfile?
    
    @Published private(set) var error: Error?
    
    var isMemberSignedIn: Bool {
        profile != nil
    }

    private var cancellables = Set<AnyCancellable>()
    
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
    
    var minimumSpendReached: Bool {
        guard let basket = basket else { return true }
        return basket.fulfilmentMethod.minSpend <= basket.orderSubtotal
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
    
    var showDriverTips: Bool {
        if selectedFulfilmentMethod == .delivery, let driverTips = selectedStore?.tips, let driverTip = driverTips.first(where: { $0.type == TipType.driver.rawValue }), driverTip.enabled {
            return true
        }
        return false
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
                                let result = try await MentionMeHandler(container: self.container).perform(request: .referee)
                                self.updateMentionMeUI(with: result)
                            } catch {
                                // the error will have been logged by the perform method so
                                // only need to hide the progress view
                                self.showMentionMeLoading = false
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
                } else if self.showDriverTips {
                    self.driverTip = 0
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
                self.couponAppliedSuccessfully = true
                self.couponCode = ""
            } catch {
                self.error = error
                Logger.basket.error("Failed to add coupon: \(self.couponCode) - \(error.localizedDescription)")
                self.applyingCoupon = false
                self.couponAppliedUnsuccessfully = true
            }
        } else {
            self.couponAppliedUnsuccessfully = true
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
                self.error = error
                Logger.basket.error("Failed to remove coupon: \(coupon.name) - \(error.localizedDescription)")
                self.removingCoupon = false
            }
        }
    }
    
    func clearCouponAndContinue() {
        couponCode = ""
        checkoutTapped()
    }
    
    func checkoutTapped() {
        guard minimumSpendReached else {
            self.showMinSpendWarning = true
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
                self.error = error
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
            self.error = error
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
            self.error = error
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
                Task {
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
            
            let params: [String: Any] = [
                AFEventParamPrice: basket.orderTotal,
                AFEventParamQuantity: totalItemQuantity
            ]
            
            container.eventLogger.sendEvent(for: .viewCart, with: .appsFlyer, params: params)
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
        guaranteeMainThread { [weak self] in
            guard let self = self else { return }
            self.showMentionMeWebView = false
            if let couponAction = couponAction {
                self.couponCode = couponAction.couponCode
                Task {
                    await self.submitCoupon()
                }
            }
>>>>>>> f1a8aa3 (Showing mention me from the basket)
        }
    }
}
