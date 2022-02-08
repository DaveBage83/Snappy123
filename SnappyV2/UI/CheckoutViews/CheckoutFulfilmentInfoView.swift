//
//  CheckoutFulfilmentInfoView.swift
//  SnappyV2
//
//  Created by Henrik Gustavii on 28/01/2022.
//

import SwiftUI

class CheckoutFulfilmentInfoViewModel: ObservableObject {
    let container: DIContainer
    @Published var postcode = ""
    @Published var instructions = ""
    let wasPaymentUnsuccessful: Bool
    @Published var continueToPaymentHandling = false
    
    init(container: DIContainer, wasPaymentUnsuccessful: Bool = false) {
        self.container = container
        self.wasPaymentUnsuccessful = wasPaymentUnsuccessful
    }
}

struct CheckoutFulfilmentInfoView: View {
    typealias ProgressStrings = Strings.CheckoutView.Progress
    
    @StateObject var viewModel:  CheckoutFulfilmentInfoViewModel
    @EnvironmentObject var checkoutViewModel: CheckoutViewModel
    
    var body: some View {
        ScrollView {
            checkoutProgressView()
                .background(Color.white)
            
            if viewModel.wasPaymentUnsuccessful {
                unsuccessfulPaymentBanner()
                    .padding([.top, .leading, .trailing])
            }
            
            deliveryAddress()
                .padding([.top, .leading, .trailing])
            
            billingAddress()
                .padding([.top, .leading, .trailing])
            
            Button(action: { viewModel.continueToPaymentHandling = true }) {
                payByCard()
                    .padding([.top, .leading, .trailing])
            }
            
            Button(action: { viewModel.continueToPaymentHandling = true }) {
                payByApplePay()
                    .padding([.top, .leading, .trailing])
            }
            
            Button(action: { viewModel.continueToPaymentHandling = true }) {
                payCash()
                    .padding([.top, .leading, .trailing])
            }
            
            Button(action: { viewModel.continueToPaymentHandling = true }) {
                continueButton()
                    .padding([.top, .leading, .trailing])
            }
            
            // MARK: NavigationLinks
            NavigationLink("", isActive: $viewModel.continueToPaymentHandling) {
                CheckoutPaymentHandlingView(viewModel: .init(container: viewModel.container)).environmentObject(checkoutViewModel)
            }
        }
    }
    
    // MARK: View Components
    func checkoutProgressView() -> some View {
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
    
    func unsuccessfulPaymentBanner() -> some View {
        VStack {
            Text("Your payment was unsuccessful")
                .font(.snappyTitle2).bold()
                .foregroundColor(.snappyRed)
            
            Text("Please check that the details below are correct or choose an alternative payment method")
                .font(.snappyBody)
        }
    }
    
    func deliveryAddress() -> some View {
        VStack(alignment: .leading) {
            Text("Add your delivery address")
                .font(.snappyHeadline)
            
            TextFieldFloatingWithBorder("Postcode", text: $viewModel.postcode, background: Color.snappyBGMain)
            
            Text("Add postcode to find your address")
                .font(.snappyBody)
                .foregroundColor(.snappyTextGrey2)
            
            TextFieldFloatingWithBorder("Add Instructions", text: $viewModel.instructions, background: Color.snappyBGMain)
        }
    }
    
    func billingAddress() -> some View {
        VStack(alignment: .leading) {
            Text("Add your billing address")
                .font(.snappyHeadline)
            
            TextFieldFloatingWithBorder("Postcode", text: $viewModel.postcode, background: Color.snappyBGMain)
            
            Text("Add postcode to find your address")
                .font(.snappyBody)
                .foregroundColor(.snappyTextGrey2)
        }
    }
    
    func payByCard() -> some View {
        HStack {
            Image(systemName: "creditcard")
                .font(.title2)
                .foregroundColor(.snappyBlue)
            
            Spacer()
            
            VStack(alignment: .leading) {
                Text("Pay by Card")
                    .font(.snappyHeadline)
                Text("Pay with all major bank cards")
                    .font(.snappyCaption)
                    .foregroundColor(.snappyTextGrey2)
            }
            
            Spacer()
            
            Image.Navigation.chevronRight
        }
        .padding()
        .background(Color.white)
        .cornerRadius(6)
        .snappyShadow()
    }
    
    func payByApplePay() -> some View {
        HStack {
            Image(systemName: "applelogo")
                .font(.title2)
                .foregroundColor(.snappyBlue)
            
            Spacer()
            
            VStack(alignment: .leading) {
                Text("Pay with Apple Pay")
                    .font(.snappyHeadline)
                Text("Pay with Apple Pay")
                    .font(.snappyCaption)
                    .foregroundColor(.snappyTextGrey2)
            }
            
            Spacer()
            
            Image.Navigation.chevronRight
        }
        .padding()
        .background(Color.white)
        .cornerRadius(6)
        .snappyShadow()
    }
    
    func payCash() -> some View {
        HStack {
            Image(systemName: "banknote")
                .font(.title2)
                .foregroundColor(.snappyBlue)
            
            Spacer()
            
            VStack(alignment: .leading) {
                Text("Pay with Cash")
                    .font(.snappyHeadline)
                Text("Pay on delivery or collection")
                    .font(.snappyCaption)
                    .foregroundColor(.snappyTextGrey2)
            }
            
            Spacer()
            
            Image.Navigation.chevronRight
        }
        .padding()
        .background(Color.white)
        .cornerRadius(6)
        .snappyShadow()
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
                    .fill(Color.snappyTeal)
            )
    }
}

struct CheckoutDeliveryAddressView_Previews: PreviewProvider {
    static var previews: some View {
        CheckoutFulfilmentInfoView(viewModel: .init(container: .preview))
            .environmentObject(CheckoutViewModel(container: .preview))
    }
}
