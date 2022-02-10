//
//  CheckoutPaymentHandlingView.swift
//  SnappyV2
//
//  Created by Henrik Gustavii on 28/01/2022.
//

import SwiftUI

class CheckoutPaymentHandlingViewModel: ObservableObject {
    enum PaymentOutcome {
        case successful
        case unsuccessful
    }
    
    let container: DIContainer
    @Published var paymentOutcome: PaymentOutcome?
    
    init(container: DIContainer) {
        self.container = container
    }
}

struct CheckoutPaymentHandlingView: View {
    typealias ProgressStrings = Strings.CheckoutView.Progress
    
    @StateObject var viewModel: CheckoutPaymentHandlingViewModel
    
    var body: some View {
        ScrollView {
            checkoutProgress()
                .background(Color.white)
            
            paymentHandling()
                .padding([.top, .leading, .trailing])
            
            Button(action: { viewModel.paymentOutcome = .successful }) {
                successButton()
                    .padding([.top, .leading, .trailing])
            }
            
            Button(action: { viewModel.paymentOutcome = .unsuccessful }) {
                failButton()
                    .padding([.top, .leading, .trailing])
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
    
    func successButton() -> some View {
        Text("Payment successful")
            .font(.snappyTitle2)
            .fontWeight(.semibold)
            .foregroundColor(.white)
            .padding(10)
            .padding(.horizontal)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.snappyTeal)
            )
    }
    
    func failButton() -> some View {
        Text("Payment failed")
            .font(.snappyTitle2)
            .fontWeight(.semibold)
            .foregroundColor(.white)
            .padding(10)
            .padding(.horizontal)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.snappyRed)
            )
    }
}

struct CheckoutPaymentHandlingView_Previews: PreviewProvider {
    static var previews: some View {
        CheckoutPaymentHandlingView(viewModel: .init(container: .preview))
            .environmentObject(CheckoutViewModel(container: .preview))
    }
}
