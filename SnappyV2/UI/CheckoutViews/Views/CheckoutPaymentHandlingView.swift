//
//  CheckoutPaymentHandlingView.swift
//  SnappyV2
//
//  Created by Henrik Gustavii on 28/01/2022.
//

import SwiftUI

struct CheckoutPaymentHandlingView: View {
    struct Constants {
        static let padding: CGFloat = 10
        static let cornerRadius: CGFloat = 10
    }
    
    typealias ProgressStrings = Strings.CheckoutView.Progress
    typealias CheckoutStrings = Strings.CheckoutView
    
    @StateObject var viewModel: CheckoutPaymentHandlingViewModel
    
    var body: some View {
        ScrollView {
            checkoutProgress()
                .background(Color.white)
            
            billingAddress()
                .padding([.top, .leading, .trailing])
            
            Button(action: { viewModel.continueButtonTapped() }) {
                continueButton
                    .padding([.top, .leading, .trailing])
                    .disabled(viewModel.continueButtonDisabled)
            }
            
            // MARK: NavigationLinks
            NavigationLink(
                destination: CheckoutFulfilmentInfoView(viewModel: .init(container: viewModel.container, wasPaymentUnsuccessful: true)),
                tag: CheckoutPaymentHandlingViewModel.PaymentOutcome.unsuccessful,
                selection: $viewModel.paymentOutcome) { EmptyView() }
            NavigationLink(
                destination: CheckoutSuccessView(viewModel: .init(container: viewModel.container, businessOrderID: viewModel.businessOrderID ?? 1)),
                tag: CheckoutPaymentHandlingViewModel.PaymentOutcome.successful,
                selection: $viewModel.paymentOutcome) { EmptyView() }
        }
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
    
    // MARK: View Components
    func checkoutProgress() -> some View {
        VStack(alignment: .leading) {
            HStack(alignment: .center) {
                Image.Checkout.delivery
                    .font(.title2)
                    .foregroundColor(.snappyBlue)
                    .padding()
                
                VStack(alignment: .leading) {
                    Text(ProgressStrings.time.localized)
                        .font(.snappyCaption)
                        .foregroundColor(.gray)
                    
                    #warning("To replace with actual order time")
                    Text("Sun, 15 October, 10:30").bold()
                        .font(.snappyCaption)
                        .foregroundColor(.snappyBlue)
                }
                
                Spacer()
                
                VStack(alignment: .leading) {
                    Text(ProgressStrings.orderTotal.localized)
                        .foregroundColor(.gray)
                    
                    HStack {
                    #warning("To replace with actual order value")
                        Text("£8.95")
                            .fontWeight(.semibold)
                            .foregroundColor(.snappyBlue)
                        
                        Image.General.bulletList
                            .foregroundColor(.snappyBlue)
                    }
                }
                .font(.snappyCaption)
                
            }
            .padding(.horizontal)
            
            ProgressBarView(value: 1, maxValue: 4, backgroundColor: .snappyBGFields1, foregroundColor: .snappyBlue)
                .frame(height: 6)
                .padding(.horizontal, -3)
        }
    }
    
    func billingAddress() -> some View {
        VStack(alignment: .leading) {
            Text(CheckoutStrings.AddAddress.titleBilling.localized)
                .font(.snappyHeadline)
            
            AddressSearchContainer(viewModel: .init(container: viewModel.container, name: viewModel.prefilledAddressName, type: .billing)) { address in
                if let address = address {
                    Task { await viewModel.setBilling(address: address) }
                }
            }
        }
    }
    
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
        CheckoutPaymentHandlingView(viewModel: .init(container: .preview, instructions: nil))
            .environmentObject(CheckoutViewModel(container: .preview))
    }
}
#endif
