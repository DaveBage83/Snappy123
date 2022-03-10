//
//  BasketViewModel.swift
//  SnappyV2
//
//  Created by Henrik Gustavii on 20/12/2021.
//

import Combine
import Foundation

class BasketViewModel: ObservableObject {
    let container: DIContainer
    @Published var basket: Basket?
    
    @Published var couponCode = ""
    @Published var applyingCoupon = false
    @Published var removingCoupon = false
    @Published var isUpdatingItem = false
    
    @Published var couponAppliedSuccessfully = false
    @Published var couponAppliedUnsuccessfully = false
    
    @Published var showingServiceFeeAlert = false
    
    @Published var isContinueToCheckoutTapped = false
    let isMemberSignedIn: Bool
    
    private var cancellables = Set<AnyCancellable>()
    
    init(container: DIContainer) {
        self.container = container
        let appState = container.appState
        
        _basket = .init(initialValue: appState.value.userData.basket)
        self.isMemberSignedIn = appState.value.userData.memberSignedIn
        
        setupBasket(with: appState)
    }
    
    private func setupBasket(with appState: Store<AppState>) {
        appState
            .map(\.userData.basket)
            .receive(on: RunLoop.main)
            .assignWeak(to: \.basket, on: self)
            .store(in: &cancellables)
    }
    
    func submitCoupon() {
        if couponCode.isEmpty == false {
            applyingCoupon = true
            
            #warning("Replace print with logging")
            container.services.basketService.applyCoupon(code: couponCode)
                .receive(on: RunLoop.main)
                .sink { [weak self] completion in
                    guard let self = self else { return }
                    switch completion {
                    case .finished:
                        print("Added coupon: \(self.couponCode)")
                    case .failure(let error):
                        #warning("Add error handling, e.g. alert for unvalid coupon")
                        print("Failed to add coupon: \(self.couponCode) - \(error)")
                        self.applyingCoupon = false
                        self.couponAppliedUnsuccessfully = true
                    }
                } receiveValue: { _ in
                    self.applyingCoupon = false
                    self.couponAppliedSuccessfully = true
                }
                .store(in: &cancellables)
        }
    }
    
    func removeCoupon() {
        if let _ = basket?.coupon {
            removingCoupon = true
            
            #warning("Replace print with logging")
            container.services.basketService.removeCoupon()
                .receive(on: RunLoop.main)
                .sink { completion in
                    switch completion {
                    case .finished:
                        print("Removed coupon")
                    case .failure(let error):
                        #warning("Add error handling, e.g. alert for coupon removed?")
                        print("Failed to remove coupon - \(error)")
                        self.removingCoupon = false
                    }
                } receiveValue: { _ in
                    self.removingCoupon = false
                }
                .store(in: &cancellables)
        }
    }
    
    func checkOutTapped() {
        isContinueToCheckoutTapped = true
    }
    
    func showServiceFeeAlert() {
        showingServiceFeeAlert = true
    }
    
    func dismissAlert() {
        showingServiceFeeAlert = false
    }
    
    #warning("Replace print with logging below")
    func updateBasketItem(itemId: Int, quantity: Int, basketLineId: Int) {
        isUpdatingItem = true
        
        #warning("Check if defaults affect basket item")
        let basketItem = BasketItemRequest(menuItemId: itemId, quantity: quantity, sizeId: 0, bannerAdvertId: 0, options: [], instructions: nil)
        self.container.services.basketService.updateItem(item: basketItem, basketLineId: basketLineId)
            .receive(on: RunLoop.main)
            .sink { completion in
                switch completion {
                case .finished:
                    print("Updated basket item id: \(basketLineId) with \(quantity) in basket")
                case .failure(let error):
                    print("Error updating \(basketLineId) in basket - \(error)")
                    #warning("Code to handle error")
                    self.isUpdatingItem = false
                }
            } receiveValue: { _ in
                self.isUpdatingItem = false
            }
            .store(in: &cancellables)
    }
}
