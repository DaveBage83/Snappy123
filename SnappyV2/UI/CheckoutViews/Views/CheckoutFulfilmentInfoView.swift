//
//  CheckoutFulfilmentInfoView.swift
//  SnappyV2
//
//  Created by Henrik Gustavii on 28/01/2022.
//

import SwiftUI

struct CheckoutFulfilmentInfoView: View {
    @Environment(\.colorScheme) var colorScheme
    struct Constants {
        static let cornerRadius: CGFloat = 6
        static let progressViewScale: Double = 2
        static let cardSpacing: CGFloat = 16
        static let internalCardPadding: CGFloat = 24
    }
    
    typealias DeliveryStrings = Strings.BasketView.DeliveryBanner
    typealias CheckoutStrings = Strings.CheckoutView
    
    @StateObject var viewModel:  CheckoutFulfilmentInfoViewModel
    
    private var colorPalette: ColorPalette {
        ColorPalette(container: viewModel.container, colorScheme: colorScheme)
    }
    
    var body: some View {
        ScrollView {
            VStack {
                VStack(spacing: Constants.cardSpacing) {
                    if viewModel.showPayByCard {
                        Button(action: { viewModel.payByCardTapped() }) {
                            PaymentCard(container: viewModel.container, paymentMethod: .card)
                        }
                    }
                    
                    if viewModel.showPayByApple {
                        Button(action: { Task { await viewModel.payByAppleTapped() }}) {
                            PaymentCard(container: viewModel.container, paymentMethod: .apple)
                        }
                    }
                    
                    if viewModel.showPayByCash {
                        Button(action: { Task { await viewModel.payByCashTapped() }}) {
                            PaymentCard(container: viewModel.container, paymentMethod: .cash)
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, Constants.internalCardPadding)
                
            }
            .toast(isPresenting: $viewModel.processingPayByCash) {
                AlertToast(displayMode: .alert, type: .loading)
            }
            .background(colorPalette.typefaceInvert)
            .standardCardFormat()
            .padding()
            .sheet(isPresented: $viewModel.handleGlobalPayment) {
                if let draftOrderDetails = viewModel.draftOrderFulfilmentDetails {
                    if #available(iOS 15.0, *) {
                        GlobalpaymentsHPPView(viewModel: GlobalpaymentsHPPViewModel(container: viewModel.container, fulfilmentDetails: draftOrderDetails, instructions: viewModel.instructions, result: { businessOrderId, error in
                            viewModel.handleGlobalPaymentResult(businessOrderId: businessOrderId, error: error)
                        }))
                        .interactiveDismissDisabled()
                    } else {
                        GlobalpaymentsHPPView(viewModel: GlobalpaymentsHPPViewModel(container: viewModel.container, fulfilmentDetails: draftOrderDetails, instructions: viewModel.instructions, result: { businessOrderId, error in
                            viewModel.handleGlobalPaymentResult(businessOrderId: businessOrderId, error: error)
                        }))
                    }
                }
            }
        }
    }
}

#if DEBUG
struct CheckoutDeliveryAddressView_Previews: PreviewProvider {
    static var previews: some View {
        CheckoutFulfilmentInfoView(viewModel: .init(container: .preview, checkoutState: {_ in}))
    }
}
#endif
