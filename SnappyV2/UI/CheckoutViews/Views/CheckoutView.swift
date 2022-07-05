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
    
    @StateObject var viewModel: CheckoutViewModel
    
    struct Constants {
        static let buttonSpacing: CGFloat = 16
    }
    
    private var colorPalette: ColorPalette {
        ColorPalette(container: viewModel.container, colorScheme: colorScheme)
    }
    
    var body: some View {
        ScrollView {
                        
            CheckoutOrderSummaryBanner(container: viewModel.container, orderTotal: viewModel.orderTotal)
                        
            VStack(spacing: Constants.buttonSpacing) {
                Button(action: { viewModel.guestCheckoutTapped() } ) {
                    UserStatusCard(container: viewModel.container, actionType: .guestCheckout)
                }
                
                Button(action: { viewModel.loginToAccountTapped() }) {
                    UserStatusCard(container: viewModel.container, actionType: .login)
                }
                
                Button(action: { viewModel.createAccountTapped() }) {
                    UserStatusCard(container: viewModel.container, actionType: .createAccount)
                }
            }
            .padding()

            // MARK: NavigationLinks
            NavigationLink(
                destination: CheckoutDetailsView(container: viewModel.container),
                tag: CheckoutViewModel.NavigationDestinations.details,
                selection: $viewModel.viewState) { EmptyView() }
            
            NavigationLink(
                destination: LoginView(loginViewModel: .init(container: viewModel.container, isInCheckout: true), socialLoginViewModel: .init(container: viewModel.container)),
                tag: CheckoutViewModel.NavigationDestinations.login,
                selection: $viewModel.viewState) { EmptyView() }
            
            NavigationLink(
                destination: CreateAccountView(viewModel: .init(container: viewModel.container, isInCheckout: true), socialLoginViewModel: .init(container: viewModel.container)),
                tag: CheckoutViewModel.NavigationDestinations.create,
                selection: $viewModel.viewState) { EmptyView() }
        }
        .dismissableNavBar(presentation: presentation, color: colorPalette.primaryBlue, title: PaymentStrings.secureCheckout.localized, navigationDismissType: .back, backButtonAction: nil)
    }
}

#if DEBUG
struct CheckoutView_Previews: PreviewProvider {
    static var previews: some View {
        CheckoutView(viewModel: .init(container: .preview))
    }
}
#endif
