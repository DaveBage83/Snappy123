//
//  CheckoutFulfilmentInfoViewModel.swift
//  SnappyV2
//
//  Created by Henrik Gustavii on 10/02/2022.
//

import Foundation
import Combine

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
    @Published var isDeliveryAddressSet: Bool = false
    
    @Published var foundAddress: SelectedAddress?
    var hasAddress: Bool { foundAddress != nil }
    
    private var cancellables = Set<AnyCancellable>()
    
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
    
    func setDelivery(address: SelectedAddress) {
        let basketAddressRequest = BasketAddressRequest(
            firstName: address.firstName,
            lastName: address.lastName,
            addressline1: address.address.addressline1,
            addressline2: address.address.addressline2,
            town: address.address.town,
            postcode: address.address.postcode,
            countryCode: address.country?.countryCode ?? AppV2Constants.Business.operatingCountry,
            type: "delivery",
            email: "email@account.com",
            telephone: "03505890345",
            state: nil,
            county: address.address.county,
            location: nil)
        container.services.basketService.setDeliveryAddress(to: basketAddressRequest)
            .receive(on: RunLoop.main)
            .sinkToResult({ [weak self] result in
                guard let self = self else { return }
                switch result {
                case .failure(let error):
                    print("Failure to set delivery address - \(error)")
                case .success(_):
                    self.isDeliveryAddressSet = true
                }
            })
            .store(in: &cancellables)
    }
}
