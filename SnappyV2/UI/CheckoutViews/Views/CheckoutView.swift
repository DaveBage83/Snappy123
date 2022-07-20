//
//  CheckoutView.swift
//  SnappyV2
//
//  Created by Henrik Gustavii on 26/01/2022.
//

import SwiftUI

class CheckoutViewModel: ObservableObject {
    enum NavigationDestinations: Hashable {
        case login
        case details
        case create
    }
    
    let container: DIContainer
    @Published var isLoggedIn = false
    @Published var viewState: NavigationDestinations?
    
    var orderTotal: Double {
        container.appState.value.userData.basket?.orderTotal ?? 0.0
    }
    
    init(container: DIContainer) {
        self.container = container
    }
    
    func guestCheckoutTapped() {
        viewState = .details
    }
    
    func createAccountTapped() {
        viewState = .create
    }
    
    func loginToAccountTapped() {
        if isLoggedIn {
            viewState = .details
        } else {
            viewState = .login
        }
    }
}

struct CheckoutView: View {
    @Environment(\.presentationMode) var presentation
    @Environment(\.colorScheme) var colorScheme
    
    typealias GuestCheckoutStrings = Strings.CheckoutView.GuestCheckoutCard
    typealias AccountLoginStrings = Strings.CheckoutView.LoginToAccount
    typealias ProgressStrings = Strings.CheckoutView.Progress
    typealias PaymentStrings = Strings.CheckoutView.Payment
    
    @ObservedObject var viewModel: CheckoutRootViewModel
    
    struct Constants {
        static let buttonSpacing: CGFloat = 16
    }
    
    private var colorPalette: ColorPalette {
        ColorPalette(container: viewModel.container, colorScheme: colorScheme)
    }
    
    init(viewModel: CheckoutRootViewModel) {
        self._viewModel = .init(wrappedValue: viewModel)
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: Constants.buttonSpacing) {
                if viewModel.showGuestCheckoutButton {
                    Button(action: { viewModel.guestCheckoutTapped() } ) {
                        UserStatusCard(container: viewModel.container, actionType: .guestCheckout)
                    }
                }
                
                Button(action: { viewModel.loginToAccountTapped() }) {
                    UserStatusCard(container: viewModel.container, actionType: .login)
                }
                
                Button(action: { viewModel.createAccountTapped() }) {
                    UserStatusCard(container: viewModel.container, actionType: .createAccount)
                }
            }
            .padding()
        }
    }
}

#if DEBUG
struct CheckoutView_Previews: PreviewProvider {
    static var previews: some View {
        CheckoutView(viewModel: .init(container: .preview, keepCheckoutFlowAlive: .constant(true)))
    }
}
#endif
