//
//  CheckoutPaymentHandlingView.swift
//  SnappyV2
//
//  Created by Henrik Gustavii on 28/01/2022.
//

import SwiftUI

struct CheckoutPaymentHandlingView: View {
    @Environment(\.colorScheme) var colorScheme
    
    struct Constants {
        static let padding: CGFloat = 10
        static let cornerRadius: CGFloat = 10
        static let vSpacing: CGFloat = 24
        
        struct PayByCardHeader {
            static let hSpacing: CGFloat = 16
            static let iconWidth: CGFloat = 32
            static let vSpacing: CGFloat = 4
        }
        
        struct BillingAddress {
            static let hSpacing: CGFloat = 16
            static let buttonIconWidth: CGFloat = 24
            static let vSpacing: CGFloat = 5
        }
    }
    
    typealias ProgressStrings = Strings.CheckoutView.Progress
    typealias CheckoutStrings = Strings.CheckoutView
    
    @StateObject var viewModel: CheckoutPaymentHandlingViewModel
    @StateObject var editAddressViewModel: EditAddressViewModel
    @ObservedObject var checkoutRootViewModel: CheckoutRootViewModel
    
    private var colorPalette: ColorPalette {
        ColorPalette(container: viewModel.container, colorScheme: colorScheme)
    }
    
    var body: some View {
        ScrollView {
            VStack {
                VStack(alignment: .leading, spacing: Constants.vSpacing) {
                    payByCardHeader
                    
                    EditAddressView(viewModel: editAddressViewModel)
                    
                    SnappyButton(
                        container: viewModel.container,
                        type: .success,
                        size: .large,
                        title: CheckoutStrings.PaymentCustom.buttonTitle.localizedFormat(viewModel.basketTotal ?? ""),
                        largeTextTitle: nil,
                        icon: Image.Icons.Padlock.filled,
                        isEnabled: .constant(true),
                        isLoading: $editAddressViewModel.settingAddress) {
                            Task {
                                await viewModel.continueButtonTapped {
                                    try await editAddressViewModel.setAddress()
                                }
                            }
                        }
                }
                .padding()
            }
            .background(colorPalette.secondaryWhite)
            .standardCardFormat()
            .padding()

            .displayError(viewModel.error)
            .sheet(isPresented: $viewModel.isContinueTapped) {
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
        .displayError(viewModel.error)
    }
    
    private var payByCardHeader: some View {
        HStack(spacing: Constants.PayByCardHeader.hSpacing) {
            Image.Icons.CreditCard.standard
                .renderingMode(.template)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: Constants.PayByCardHeader.iconWidth)
                .foregroundColor(colorPalette.typefacePrimary)
            
            VStack(alignment: .leading, spacing: Constants.PayByCardHeader.vSpacing) {
                Text(CheckoutStrings.Payment.payByCard.localized)
                    .font(.heading4())
                .foregroundColor(colorPalette.typefacePrimary)
                
                Text(CheckoutStrings.Payment.payByCardSubtitle.localized)
                    .font(.Body2.regular())
                    .foregroundColor(colorPalette.typefacePrimary)
            }
        }
    }
    
    // MARK: View Components
    
    @ViewBuilder var continueButton: some View {
        if viewModel.settingBillingAddress {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                .padding(Constants.padding)
                .padding(.horizontal)
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: Constants.cornerRadius)
                        .fill(Color.snappyGrey)
                )
        } else {
            Text(GeneralStrings.cont.localized)
                .font(.snappyTitle2)
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .padding(Constants.padding)
                .padding(.horizontal)
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: Constants.cornerRadius)
                        .fill(viewModel.continueButtonDisabled ? Color.gray : Color.snappyTeal)
                )
        }
    }
}

#if DEBUG
struct CheckoutPaymentHandlingView_Previews: PreviewProvider {
    static var previews: some View {
        CheckoutPaymentHandlingView(viewModel: .init(container: .preview, instructions: nil, checkoutState: .constant(.paymentFailure)), editAddressViewModel: .init(container: .preview, email: "sdsd@ss.com", phone: "92939393", addressType: .billing), checkoutRootViewModel: .init(container: .preview))
            .environmentObject(CheckoutViewModel(container: .preview))
    }
}
#endif
