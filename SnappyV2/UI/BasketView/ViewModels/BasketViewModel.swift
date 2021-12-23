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
            
            #warning("Replace pring with logging")
            container.services.basketService.applyCoupon(code: couponCode)
                .receive(on: RunLoop.main)
                .sink { [weak self] completion in
                    guard let self = self else { return }
                    switch completion {
                    case .finished:
                        print("Added coupon: \(self.couponCode)")
                    case .failure(let error):
                        #warning("Add error handling, e.g. alert for unvalid coupons")
                        print("Failed to add coupon: \(self.couponCode) - \(error)")
                    }
                } receiveValue: { _ in
                    self.applyingCoupon = false
                }
                .store(in: &cancellables)
        }
    }
}
