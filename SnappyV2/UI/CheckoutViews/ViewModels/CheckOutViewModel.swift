//
//  CheckOutViewModel.swift
//  SnappyV2
//
//  Created by Kevin Palser on 05/10/2022.
//

//import Foundation
//
//@MainActor
//final class CheckoutViewModel: ObservableObject {
//    enum NavigationDestinations: Hashable {
//        case login
//        case details
//        case create
//    }
//    
//    let container: DIContainer
//    @Published var isLoggedIn = false
//    @Published var viewState: NavigationDestinations?
//    
//    var orderTotal: Double {
//        container.appState.value.userData.basket?.orderTotal ?? 0.0
//    }
//    
//    init(container: DIContainer) {
//        self.container = container
//    }
//    
//    func guestCheckoutTapped() {
//        viewState = .details
//    }
//    
//    func createAccountTapped() {
//        viewState = .create
//    }
//    
//    func loginToAccountTapped() {
//        if isLoggedIn {
//            viewState = .details
//        } else {
//            viewState = .login
//        }
//    }
//}
