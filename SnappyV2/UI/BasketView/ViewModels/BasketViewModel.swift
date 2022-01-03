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
    // for banner under coupon textfield - needs code to handle
    @Published var couponAppliedSuccessfully = false
    @Published var couponAppliedUnsuccessfully = false
    
    private var cancellables = Set<AnyCancellable>()
    
    init(container: DIContainer) {
        self.container = container
        let appState = container.appState
        
        _basket = .init(initialValue: appState.value.userData.basket)
        
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
        #warning("Add code to post basket and navigate to checkout")
    }
}
