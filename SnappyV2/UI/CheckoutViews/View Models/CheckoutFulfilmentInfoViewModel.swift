//
//  CheckoutFulfilmentInfoViewModel.swift
//  SnappyV2
//
//  Created by Henrik Gustavii on 10/02/2022.
//

import Foundation

class CheckoutFulfilmentInfoViewModel: ObservableObject {
    enum PaymentNavigation {
        case payByCard
        case payByApple
        case payByCash
    }
    
    let container: DIContainer
    @Published var postcode = ""
    @Published var instructions = ""
    let wasPaymentUnsuccessful: Bool
    @Published var navigateToPaymentHandling: PaymentNavigation?
    let memberSignedIn: Bool
    @Published var isFulfilmentSlotSelectShown: Bool = false
    
    @Published var foundAddress: FoundAddress?
    var hasAddress: Bool { foundAddress != nil }
    
    init(container: DIContainer, wasPaymentUnsuccessful: Bool = false) {
        self.container = container
        self.wasPaymentUnsuccessful = wasPaymentUnsuccessful
        self.memberSignedIn = container.appState.value.userData.memberSignedIn
        if memberSignedIn {
            postcode = "PA344AG"
        }
    }
    
    func showFulfilmentSelectView() {
        isFulfilmentSlotSelectShown = true
    }
}
