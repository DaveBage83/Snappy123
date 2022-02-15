//
//  CheckoutFulfilmentInfoView.swift
//  SnappyV2
//
//  Created by Henrik Gustavii on 28/01/2022.
//

import SwiftUI

struct CheckoutFulfilmentInfoView: View {
    typealias ProgressStrings = Strings.CheckoutView.Progress
    typealias DeliveryStrings = Strings.BasketView.DeliveryBanner
    
    @StateObject var viewModel:  CheckoutFulfilmentInfoViewModel
    
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
            
            if viewModel.isDeliveryAddressSet {
                deliveryBanner()
                    .padding([.top, .leading, .trailing])
                
                fulfilmentInstructions()
                    .padding([.top, .leading, .trailing])
                
                Button(action: { viewModel.navigateToPaymentHandling = .payByCard }) {
                    payByCard()
                        .padding([.top, .leading, .trailing])
                }
                
                Button(action: { viewModel.navigateToPaymentHandling = .payByApple }) {
                    payByApplePay()
                        .padding([.top, .leading, .trailing])
                }
                
                Button(action: { viewModel.navigateToPaymentHandling = .payByCash }) {
                    payCash()
                        .padding([.top, .leading, .trailing])
                }
            }
            
            // MARK: NavigationLinks
            // Pay by card
            NavigationLink(
                destination: CheckoutPaymentHandlingView(viewModel: .init(container: viewModel.container)),
                tag: CheckoutFulfilmentInfoViewModel.PaymentNavigation.payByCard,
                selection: $viewModel.navigateToPaymentHandling) { EmptyView() }
            
            // Pay by Apple
            NavigationLink(
                destination: EmptyView() /* Payment by Apple handling view */,
                tag: CheckoutFulfilmentInfoViewModel.PaymentNavigation.payByApple,
                selection: $viewModel.navigateToPaymentHandling) { EmptyView() }
            
            // Pay by cash
            NavigationLink(
                destination: CheckoutSuccessView(viewModel: .init(container: viewModel.container)),
                tag: CheckoutFulfilmentInfoViewModel.PaymentNavigation.payByCash,
                selection: $viewModel.navigateToPaymentHandling) { EmptyView() }
            
            // Fulfilment slot selection
            NavigationLink("", isActive: $viewModel.isFulfilmentSlotSelectShown) {
                FulfilmentTimeSlotSelectionView(viewModel: .init(container: viewModel.container))
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
            
            PostcodeSearchBarContainer(viewModel: .init(container: viewModel.container)) { address in
                if let address = address {
                    viewModel.setDelivery(address: address)
//                    viewModel.isDeliveryAddressSet = true
                }
            }
        }
    }
    
    func fulfilmentInstructions() -> some View {
        TextFieldFloatingWithBorder("Add Instructions", text: $viewModel.instructions, background: Color.snappyBGMain)
    }
    
    func deliveryBanner() -> some View {
        HStack {
            VStack(alignment: .leading) {
                HStack {
                    Image.Checkout.car
                    
                    Text(GeneralStrings.delivery.localized)
                    
                    #warning("Replace expiry time with actual expiry time")
                    Text(DeliveryStrings.Customisable.expires.localizedFormat("45"))
                        .font(.snappyCaption2)
                        .fontWeight(.bold)
                        .padding(EdgeInsets(top: 4, leading: 8, bottom: 4, trailing: 8))
                        .background(Capsule().fill(Color.snappyRed))
                }
                
                Text("12 March | 17:30 - 18:25")
                    .bold()
            }
            
            Button(action: { viewModel.showFulfilmentSelectView() }) {
                Text(DeliveryStrings.change.localized)
                    .padding(.vertical, 6)
                    .padding(.horizontal, 10)
                    .background(
                        RoundedRectangle(cornerRadius: 6)
                            .stroke()
                            .foregroundColor(.white)
                    )
            }
        }
        .font(.snappySubheadline)
        .padding(.vertical, 6)
        .padding(.horizontal, 10)
        .foregroundColor(.white)
        .background(Color.snappyDark)
        .cornerRadius(6)
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
}

struct CheckoutDeliveryAddressView_Previews: PreviewProvider {
    static var previews: some View {
        CheckoutFulfilmentInfoView(viewModel: .init(container: .preview))
            .environmentObject(CheckoutViewModel(container: .preview))
    }
}
