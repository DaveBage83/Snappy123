//
//  CheckoutRootView.swift
//  SnappyV2
//
//  Created by David Bage on 07/07/2022.
//

import SwiftUI

struct CheckoutRootView: View {
    // MARK: - Environment
    @Environment(\.colorScheme) var colorScheme
    
    // MARK: - View model
    @StateObject var viewModel: CheckoutRootViewModel
    
    // MARK: - Colours
    private var colorPalette: ColorPalette {
        ColorPalette(container: viewModel.container, colorScheme: colorScheme)
    }
    
    // MARK: - Main view container
    var body: some View {
        ZStack {
            VStack {
                CheckoutOrderSummaryBanner(checkoutRootViewModel: viewModel)
                
                VStack(spacing: 0) {
                    switch viewModel.checkoutState {
                        
                    case .initial:
                        CheckoutView(viewModel: viewModel)
                            .withNavigationAnimation(direction: viewModel.navigationDirection)
                        
                    case .login:
                        LoginView(loginViewModel: .init(container: viewModel.container, isInCheckout: true), socialLoginViewModel: .init(container: viewModel.container))
                            .withNavigationAnimation(direction: viewModel.navigationDirection)
                        
                    case .createAccount:
                        CreateAccountView(viewModel: .init(container: viewModel.container, isInCheckout: true), socialLoginViewModel: .init(container: viewModel.container))
                            .withNavigationAnimation(direction: viewModel.navigationDirection)
                        
                    case .details:
                        CheckoutDetailsView(viewModel: viewModel, marketingPreferencesViewModel: .init(container: viewModel.container, viewContext: .checkout, hideAcceptedMarketingOptions: false), editAddressViewModel: .init(container: viewModel.container, addressType: .delivery))
                            .withNavigationAnimation(direction: viewModel.navigationDirection)
                        
                    case .paymentSelection:
                        CheckoutFulfilmentInfoView(viewModel: .init(container: viewModel.container, checkoutState: $viewModel.checkoutState))
                            .withNavigationAnimation(direction: viewModel.navigationDirection)
                        
                    case .card:
                        CheckoutPaymentHandlingView(viewModel: .init(container: viewModel.container, instructions: viewModel.deliveryNote, checkoutState: $viewModel.checkoutState), editAddressViewModel: .init(container: viewModel.container, addressType: .billing), checkoutRootViewModel: viewModel)
                            .withNavigationAnimation(direction: viewModel.navigationDirection)
                        
                    case .paymentSuccess:
                        CheckoutSuccessView(viewModel: .init(container: viewModel.container))
                        
                    case .paymentFailure:
                        #warning("To implement this view in future ticket")
                        Text("Failed")
                            .withNavigationAnimation(direction: viewModel.navigationDirection)
                    }
                }
                .withAlertToast(container: viewModel.container, error: $viewModel.checkoutError)
            }
            .disabled(viewModel.showOTPPrompt)
            
            if viewModel.showOTPPrompt {
                OTPPromptView(viewModel: .init(container: viewModel.container, email: viewModel.email, otpTelephone: viewModel.otpTelephone, dismiss: { viewModel.dismissOTPPrompt() }))
            }
        }
        .onTapGesture {
            hideKeyboard() // Placed here, as we want this behavious for entire navigation stack
        }
        .dismissableNavBar(presentation: nil, color: colorPalette.primaryBlue, title: Strings.CheckoutView.Payment.secureCheckout.localized, navigationDismissType: .back, backButtonAction: viewModel.backButtonPressed)
    }
}

#if DEBUG
struct CheckoutRootView_Previews: PreviewProvider {
    static var previews: some View {
        CheckoutRootView(viewModel: .init(container: .preview, keepCheckoutFlowAlive: .constant(true)))
    }
}
#endif
