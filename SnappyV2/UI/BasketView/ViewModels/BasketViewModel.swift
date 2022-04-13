//
//  BasketViewModel.swift
//  SnappyV2
//
//  Created by Henrik Gustavii on 20/12/2021.
//

import Combine
import Foundation
import OSLog

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
    private var selectedStore: RetailStoreDetails?
    
    @Published var couponCode = ""
    @Published var applyingCoupon = false
    @Published var removingCoupon = false
    @Published var isUpdatingItem = false
    @Published var driverTip: Double = 0
    @Published var changeTipBy: Double = 0
    let driverTipIncrement: Double
    let tipLevels: [TipLimitLevel]?
    @Published var updatingTip: Bool = false
    
    @Published var couponAppliedSuccessfully = false
    @Published var couponAppliedUnsuccessfully = false
    
    @Published var showingServiceFeeAlert = false
    @Published var showCouponAlert = false
    
    @Published var isContinueToCheckoutTapped = false
    @Published var profile: MemberProfile?
    
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
    
    var disableDecreaseTipButton: Bool { driverTip == 0 }
    
    var showBasketItems: Bool { basket?.items.isEmpty == false }
    
    private func setupBasket(with appState: Store<AppState>) {
        appState
            .map(\.userData.basket)
            .receive(on: RunLoop.main)
            .assignWeak(to: \.basket, on: self)
            .store(in: &cancellables)
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
    
    func submitCoupon() {
        if couponCode.isEmpty == false {
            applyingCoupon = true
            
            container.services.basketService.applyCoupon(code: couponCode)
                .receive(on: RunLoop.main)
                .sink { [weak self] completion in
                    guard let self = self else { return }
                    switch completion {
                    case .finished:
                        Logger.basket.info("Added coupon: \(self.couponCode)")
                        self.applyingCoupon = false
                        self.couponAppliedSuccessfully = true
                        self.couponCode = ""
                    case .failure(let error):
                        #warning("Add error handling, e.g. alert for unvalid coupon")
                        Logger.basket.error("Failed to add coupon: \(self.couponCode) - \(error.localizedDescription)")
                        self.applyingCoupon = false
                        self.couponAppliedUnsuccessfully = true
                    }
                }
                .store(in: &cancellables)
        }
    }
    
    func removeCoupon() {
        if let coupon = basket?.coupon {
            removingCoupon = true

            container.services.basketService.removeCoupon()
                .receive(on: RunLoop.main)
                .sink { [weak self] completion in
                    guard let self = self else { return }
                    switch completion {
                    case .finished:
                        Logger.basket.info("Removed coupon: \(coupon.name)")
                        self.removingCoupon = false
                    case .failure(let error):
                        #warning("Add error handling, e.g. alert for coupon removed?")
                        Logger.basket.error("Failed to remove coupon: \(coupon.name) - \(error.localizedDescription)")
                        self.removingCoupon = false
                    }
                }
                .store(in: &cancellables)
        }
    }
    
    func clearCouponAndContinue() {
        couponCode = ""
        checkoutTapped()
    }
    
    func checkoutTapped() {
        if couponCode.isEmpty {
            isContinueToCheckoutTapped = true
        } else {
            showCouponAlert = true
        }
    }
    
    func showServiceFeeAlert() {
        showingServiceFeeAlert = true
    }
    
    func dismissAlert() {
        showingServiceFeeAlert = false
    }

    func updateBasketItem(itemId: Int, quantity: Int, basketLineId: Int) {
        isUpdatingItem = true
        
        #warning("Check if defaults affect basket item")
        let basketItem = BasketItemRequest(menuItemId: itemId, quantity: quantity, changeQuantity: nil, sizeId: 0, bannerAdvertId: 0, options: [], instructions: nil)
        self.container.services.basketService.updateItem(item: basketItem, basketLineId: basketLineId)
            .receive(on: RunLoop.main)
            .sink { [weak self] completion in
                guard let self = self else { return }
                switch completion {
                case .finished:
                    Logger.basket.info("Updated basket item id: \(basketLineId) with \(quantity) in basket")
                    self.isUpdatingItem = false
                case .failure(let error):
                    Logger.basket.error("Error updating \(basketLineId) in basket - \(error.localizedDescription)")
                    #warning("Code to handle error")
                    self.isUpdatingItem = false
                }
            }
            .store(in: &cancellables)
    }
    
    func increaseTip() { changeTipBy += driverTipIncrement }
    
    func decreaseTip() { changeTipBy -= driverTipIncrement }
    
    private func updateTip(with tipChange: Double) {
        updatingTip = true
        
        container.services.basketService.updateTip(to: tipChange)
            .receive(on: RunLoop.main)
            .sink { [weak self] completion in
                guard let self = self else { return }
                switch completion {
                case .finished:
                    Logger.basket.log("Updated tip to \(tipChange)")
                case .failure(let error):
                    Logger.basket.error("Could not update driver tip - Error: \(error.localizedDescription)")
                }
                self.updatingTip = false
                self.changeTipBy = 0
            }
            .store(in: &cancellables)
    }
    
    func setupChangeTipBy() {
        $changeTipBy
            .debounce(for: 0.4, scheduler: RunLoop.main)
            .receive(on: RunLoop.main)
            .sink { [weak self] newValue in
                guard let self = self else { return }
                if newValue == 0 { return } // Avoids looping when updateTip resets changeTipBy
                var updateValue = self.driverTip + newValue
                if updateValue <= 0 { updateValue = 0 } // updateTip can't take negative numbers
                self.updateTip(with: updateValue)
            }
            .store(in: &cancellables)
    }
}
