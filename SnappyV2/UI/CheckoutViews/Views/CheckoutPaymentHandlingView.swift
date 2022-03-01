//
//  CheckoutPaymentHandlingView.swift
//  SnappyV2
//
//  Created by Henrik Gustavii on 28/01/2022.
//

import SwiftUI

struct CheckoutPaymentHandlingView: View {
    typealias ProgressStrings = Strings.CheckoutView.Progress
    typealias CheckoutStrings = Strings.CheckoutView
    
    @StateObject var viewModel: CheckoutPaymentHandlingViewModel
    
    var body: some View {
        ScrollView {
            checkoutProgress()
                .background(Color.white)
            
            billingAddress()
                .padding([.top, .leading, .trailing])
            
            paymentHandling()
                .padding([.top, .leading, .trailing])
            
            Button(action: { viewModel.continueButtonTapped() }) {
                continueButton()
                    .padding([.top, .leading, .trailing])
                    .disabled(viewModel.continueButtonDisabled)
            }
            
            // MARK: NavigationLinks
            NavigationLink(
                destination: CheckoutFulfilmentInfoView(viewModel: .init(container: viewModel.container, wasPaymentUnsuccessful: true)),
                tag: CheckoutPaymentHandlingViewModel.PaymentOutcome.unsuccessful,
                selection: $viewModel.paymentOutcome) { EmptyView() }
            NavigationLink(
                destination: CheckoutSuccessView(viewModel: .init(container: viewModel.container)),
                tag: CheckoutPaymentHandlingViewModel.PaymentOutcome.successful,
                selection: $viewModel.paymentOutcome) { EmptyView() }
        }
        .sheet(isPresented: $viewModel.isContinueTapped) {
            if let draftOrderDetails = viewModel.draftOrderFulfilmentDetails {
                if #available(iOS 15.0, *) {
                    GlobalpaymentsHPPView(viewModel: GlobalpaymentsHPPViewModel(container: viewModel.container, fulfilmentDetails: draftOrderDetails, instructions: viewModel.instructions, result: { businessOrderId, error in
                        viewModel.handleGlobalPaymentResult(businessOrderId: businessOrderId, error: error)
                    }))
                        .interactiveDismissDisabled()
                } else {
                    // Fallback on earlier versions
                }
            }
        }
    }
    
    // MARK: View Components
    func checkoutProgress() -> some View {
        VStack(alignment: .leading) {
            HStack(alignment: .center) {
                Image.Checkout.car
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
    
    func paymentHandling() -> some View {
        VStack(alignment: .leading) {
            Text("Payment handling should go here")
                .font(.snappyHeadline)
        }
    }
    
    func billingAddress() -> some View {
        VStack(alignment: .leading) {
            Text(CheckoutStrings.AddAddress.titleBilling.localized)
                .font(.snappyHeadline)
            
            PostcodeSearchBarContainer(viewModel: .init(container: viewModel.container, name: viewModel.prefilledAddressName)) { address in
                if let address = address {
                    viewModel.setBilling(address: address)
                }
            }
        }
    }
    
    func continueButton() -> some View {
        Text("Continue")
            .font(.snappyTitle2)
            .fontWeight(.semibold)
            .foregroundColor(.white)
            .padding(10)
            .padding(.horizontal)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(viewModel.continueButtonDisabled ? Color.gray : Color.snappyTeal)
            )
    }
}

struct CheckoutPaymentHandlingView_Previews: PreviewProvider {
    static var previews: some View {
        CheckoutPaymentHandlingView(viewModel: .init(container: .preview, instructions: nil))
            .environmentObject(CheckoutViewModel(container: .preview))
    }
}
