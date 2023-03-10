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
        static let cardSpacing: CGFloat = 16
        static let internalCardPadding: CGFloat = 24
    }
    
    @StateObject var viewModel:  CheckoutFulfilmentInfoViewModel
    
    private var colorPalette: ColorPalette {
        ColorPalette(container: viewModel.container, colorScheme: colorScheme)
    }
    
    var body: some View {
        ScrollView {
            VStack {
                VStack(spacing: Constants.cardSpacing) {
                    ForEach(viewModel.paymentMethodsOrder, id: \.self) { method in
                        switch method {
                        case .payByCard:
                            Button(action: { viewModel.payByCardTapped() }) {
                                PaymentCard(container: viewModel.container, paymentMethod: .card)
                            }
                        case .payByCash:
                            Button(action: { Task { await viewModel.payByCashTapped() }}) {
                                PaymentCard(container: viewModel.container, paymentMethod: .cash)
                            }
                        case .payByApple:
                            Button(action: { Task { await viewModel.payByAppleTapped() }}) {
                                PaymentCard(container: viewModel.container, paymentMethod: .apple)
                            }
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, Constants.internalCardPadding)
                
            }
            .withLoadingToast(container: viewModel.container, loading: $viewModel.processingPayByCash)
            .alert(isPresented: $viewModel.showConfirmCashPaymentAlert) { ()-> Alert in
                Alert(title: Text(Strings.CheckoutView.PaymentCustom.confirmCashPaymentMessage.localizedFormat(viewModel.orderTotalPriceString ?? "")),
                      primaryButton: .cancel(),
                      secondaryButton: .default(Text(Strings.CheckoutView.Payment.placeOrder.localized), action: { Task { await viewModel.confirmCashPayment() }})
                )
            }
            .background(colorPalette.typefaceInvert)
            .standardCardFormat(container: viewModel.container)
            .padding()
            .snappySheet(container: viewModel.container, isPresented: $viewModel.handleGlobalPayment, sheetContent: paymentSheet)
        }
    }
    
    @ViewBuilder private var paymentSheet: some View {
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

#if DEBUG
struct CheckoutDeliveryAddressView_Previews: PreviewProvider {
    static var previews: some View {
        CheckoutFulfilmentInfoView(viewModel: .init(container: .preview, checkoutState: {_ in}))
    }
}
#endif
