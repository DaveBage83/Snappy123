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
    
    let dismissCheckoutRootView: () -> Void
    
    // MARK: - Main view container
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                CheckoutOrderSummaryBanner(checkoutRootViewModel: viewModel)
                
                VStack(spacing: 0) {
                    
                    if viewModel.isLoading {
                        // When a view is being prepared, e.g. fetching the retail membership based on the
                        // selected store for the CheckoutDetailsView.
                        VStack {
                            Spacer()
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle())
                            Spacer()
                        }
                    } else {
                        switch viewModel.checkoutState {
                            
                        case .initial:
                            CheckoutView(viewModel: viewModel)
                                .withNavigationAnimation(direction: viewModel.navigationDirection)
                                .dismissableNavBar(presentation: nil, color: colorPalette.primaryBlue, title: Strings.CheckoutView.Payment.secureCheckout.localized, navigationDismissType: .back, backButtonAction: {
                                    viewModel.backButtonPressed(dismissView: dismissCheckoutRootView)
                                })
                            
                        case .login:
                            LoginView(loginViewModel: .init(container: viewModel.container, isInCheckout: true), socialLoginViewModel: .init(container: viewModel.container, isInCheckout: true))
                                .withNavigationAnimation(direction: viewModel.navigationDirection)
                                .dismissableNavBar(presentation: nil, color: colorPalette.primaryBlue, title: Strings.CheckoutView.Payment.secureCheckout.localized, navigationDismissType: .back, backButtonAction: {
                                    viewModel.backButtonPressed(dismissView: dismissCheckoutRootView)
                                })
                            
                        case .createAccount:
                            CreateAccountView(viewModel: .init(container: viewModel.container, isInCheckout: true), socialLoginViewModel: .init(container: viewModel.container, isInCheckout: true))
                                .withNavigationAnimation(direction: viewModel.navigationDirection)
                                .dismissableNavBar(presentation: nil, color: colorPalette.primaryBlue, title: Strings.CheckoutView.Payment.secureCheckout.localized, navigationDismissType: .back, backButtonAction: {
                                    viewModel.backButtonPressed(dismissView: dismissCheckoutRootView)
                                })
                            
                        case .details:
                            CheckoutDetailsView(viewModel: viewModel, marketingPreferencesViewModel: .init(container: viewModel.container, viewContext: .checkout, hideAcceptedMarketingOptions: false), editAddressViewModel: .init(container: viewModel.container, addressType: .delivery, includeSavedAddressButton: true))
                                .withNavigationAnimation(direction: viewModel.navigationDirection)
                                .dismissableNavBar(presentation: nil, color: colorPalette.primaryBlue, title: Strings.CheckoutView.Payment.secureCheckout.localized, navigationDismissType: .back, backButtonAction: {
                                    viewModel.backButtonPressed(dismissView: dismissCheckoutRootView)
                                })
                            
                        case .paymentSelection:
                            CheckoutFulfilmentInfoView(viewModel: .init(container: viewModel.container, instructions: viewModel.deliveryNote, checkoutState: { state in
                                viewModel.setCheckoutState(state: state)
                            }))
                            .withNavigationAnimation(direction: viewModel.navigationDirection)
                            .dismissableNavBar(presentation: nil, color: colorPalette.primaryBlue, title: Strings.CheckoutView.Payment.secureCheckout.localized, navigationDismissType: .back, backButtonAction: {
                                viewModel.backButtonPressed(dismissView: dismissCheckoutRootView)
                            })
                            
                        case .card:
                            CheckoutPaymentHandlingView(
                                viewModel: .init(
                                    container: viewModel.container,
                                    instructions: viewModel.deliveryNote,
                                    paymentSuccess: {
                                        viewModel.setCheckoutState(state: .paymentSuccess)
                                    },
                                    paymentFailure: {}),
                                editAddressViewModel: .init(container: viewModel.container, addressType: .billing, includeSavedAddressButton: false), checkoutRootViewModel: viewModel)
                            .withNavigationAnimation(direction: viewModel.navigationDirection)
                            .dismissableNavBar(presentation: nil, color: colorPalette.primaryBlue, title: Strings.CheckoutView.Payment.secureCheckout.localized, navigationDismissType: .back, backButtonAction: {
                                viewModel.backButtonPressed(dismissView: dismissCheckoutRootView)
                            })
                            
                        case .paymentSuccess:
                            CheckoutSuccessView(viewModel: .init(container: viewModel.container))
                                .dismissableNavBar(presentation: nil, color: .clear, title: Strings.CheckoutView.Payment.secureCheckout.localized, navigationDismissType: .back, backButtonAction: {})
                        }
                    }
                }
            }
            .disabled(viewModel.showOTPPrompt)
            
            if viewModel.showOTPPrompt {
                OTPPromptView(viewModel: .init(container: viewModel.container, email: viewModel.email, otpTelephone: viewModel.otpTelephone, isInCheckout: true, dismiss: { viewModel.dismissOTPPrompt() }))
            }
        }
    }
}

#if DEBUG
struct CheckoutRootView_Previews: PreviewProvider {
    static var previews: some View {
        CheckoutRootView(viewModel: .init(container: .preview), dismissCheckoutRootView: {})
    }
}
#endif
