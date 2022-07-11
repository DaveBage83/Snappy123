//
//  CheckoutRootView.swift
//  SnappyV2
//
//  Created by David Bage on 07/07/2022.
//

import SwiftUI

struct CheckoutRootView: View {
    @Environment(\.colorScheme) var colorScheme
    @StateObject var viewModel: CheckoutRootViewModel
    
    private var colorPalette: ColorPalette {
        ColorPalette(container: viewModel.container, colorScheme: colorScheme)
    }
    
    var body: some View {
        VStack {
            CheckoutOrderSummaryBanner(container: viewModel.container, orderTotal: viewModel.orderTotal, progressState: $viewModel.progressState)
            
            VStack {
                switch viewModel.checkoutState {
                    
                case .initial:
                    CheckoutView(viewModel: viewModel)
                        .withNavigationAnimation(isBack: viewModel.navigationDirection == .back)
                    
                case .login:
                    LoginView(loginViewModel: .init(container: viewModel.container, isInCheckout: true), socialLoginViewModel: .init(container: viewModel.container))
                        .withNavigationAnimation(isBack: viewModel.navigationDirection == .back)
                    
                case .createAccount:
                    CreateAccountView(viewModel: .init(container: viewModel.container, isInCheckout: true), socialLoginViewModel: .init(container: viewModel.container))
                        .withNavigationAnimation(isBack: viewModel.navigationDirection == .back)
                    
                case .details:
                    CheckoutDetailsView(container: viewModel.container, viewModel: viewModel, marketingPreferencesViewModel: .init(container: viewModel.container, isCheckout: false))
                        .withNavigationAnimation(isBack: viewModel.navigationDirection == .back)

                case .paymentSelection:
                    CheckoutFulfilmentInfoView(viewModel: .init(container: viewModel.container), checkoutRootViewModel: viewModel)
                        .withNavigationAnimation(isBack: viewModel.navigationDirection == .back)
                    
                case .card:
                    CheckoutPaymentHandlingView(viewModel: .init(container: viewModel.container, instructions: viewModel.deliveryNote, checkoutState: $viewModel.checkoutState), editAddressViewModel: .init(container: viewModel.container, email: "dvbage@gmail.com", phone: "00292929292", addressType: .billing), checkoutRootViewModel: viewModel)
                        .withNavigationAnimation(isBack: viewModel.navigationDirection == .back)
                case .paymentSuccess:
                    CheckoutSuccessView(viewModel: .init(container: viewModel.container))
                case .paymentFailure:
                    Text("Failed")
                        .withNavigationAnimation(isBack: viewModel.navigationDirection == .back)
                }
            }
        }

        .dismissableNavBar(presentation: nil, color: colorPalette.primaryBlue, title: Strings.CheckoutView.Payment.secureCheckout.localized, navigationDismissType: .back, backButtonAction: viewModel.backButtonPressed)
    }
}

#if DEBUG
struct CheckoutRootView_Previews: PreviewProvider {
    static var previews: some View {
        CheckoutRootView(viewModel: .init(container: .preview))
    }
}
#endif
