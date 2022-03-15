//
//  CheckoutFulfilmentInfoView.swift
//  SnappyV2
//
//  Created by Henrik Gustavii on 28/01/2022.
//

import SwiftUI

struct CheckoutFulfilmentInfoView: View {
    struct Constants {
        static let cornerRadius: CGFloat = 6
        static let progressViewScale: Double = 2
    }
    
    typealias DeliveryStrings = Strings.BasketView.DeliveryBanner
    typealias CheckoutStrings = Strings.CheckoutView
    
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
            
            if viewModel.settingDeliveryAddress {
                ProgressView()
                    .scaleEffect(x: Constants.progressViewScale, y: Constants.progressViewScale)
                    .progressViewStyle(CircularProgressViewStyle(tint: .snappyGrey))
                    .padding()
            }
            
            if viewModel.settingDeliveryAddress == false, viewModel.isDeliveryAddressSet {
                FulfilmentInfoCard(viewModel: .init(container: viewModel.container, isInCheckout: true))
                    .padding([.top, .leading, .trailing])
                
                fulfilmentInstructions()
                    .padding([.top, .leading, .trailing])
                
                if viewModel.showPayByCard {
                    Button(action: { viewModel.payByCardTapped() }) {
                        payByCard()
                            .padding([.top, .leading, .trailing])
                    }
                }
                
                if viewModel.showPayByApple {
                    Button(action: { viewModel.payByAppleTapped() }) {
                        payByApplePay()
                            .padding([.top, .leading, .trailing])
                    }
                }
                
                if viewModel.showPayByCash {
                    Button(action: { viewModel.payByCashTapped() }) {
                        payCash()
                            .padding([.top, .leading, .trailing])
                    }
                }
            }
            
            // MARK: NavigationLinks
            // Pay by card
            NavigationLink(
                destination: CheckoutPaymentHandlingView(viewModel: .init(container: viewModel.container, instructions: viewModel.instructions)),
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
        }
    }
    
    
    
    // MARK: View Components
    #warning("This component to be replaced by separate view")
    func checkoutProgressView() -> some View {
        VStack(alignment: .leading) {
            HStack(alignment: .center) {
                Image.Checkout.car
                    .font(.title2)
                    .foregroundColor(.snappyBlue)
                    .padding()
                
                VStack(alignment: .leading) {
                    Text(CheckoutStrings.Progress.time.localized)
                        .font(.snappyCaption)
                        .foregroundColor(.gray)
                    
                    #warning("To replace with actual order time")
                    Text("Sun, 15 October, 10:30").bold()
                        .font(.snappyCaption)
                        .foregroundColor(.snappyBlue)
                }
                
                Spacer()
                
                VStack(alignment: .leading) {
                    Text(CheckoutStrings.Progress.orderTotal.localized)
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
            Text(CheckoutStrings.Payment.unsuccessfulPayment.localized)
                .font(.snappyTitle2).bold()
                .foregroundColor(.snappyRed)
            
            Text(CheckoutStrings.Payment.checkAndChooseAlternativePayment.localized)
                .font(.snappyBody)
        }
    }
    
    func deliveryAddress() -> some View {
        VStack(alignment: .leading) {
            Text(CheckoutStrings.AddAddress.titleDelivery.localized)
                .font(.snappyHeadline)
            
            PostcodeSearchBarContainer(viewModel: .init(container: viewModel.container, name: viewModel.prefilledAddressName, address: viewModel.selectedDeliveryAddress)) { address in
                if let address = address {
                    viewModel.setDelivery(address: address)
                }
            }
        }
    }
    
    func fulfilmentInstructions() -> some View {
        TextFieldFloatingWithBorder(CheckoutStrings.General.addInstructions.localized, text: $viewModel.instructions, background: Color.snappyBGMain)
    }
    
    func payByCard() -> some View {
        HStack {
            Image.Checkout.creditCard
                .font(.title2)
                .foregroundColor(.snappyBlue)
            
            Spacer()
            
            VStack(alignment: .leading) {
                Text(CheckoutStrings.Payment.payByCard.localized)
                    .font(.snappyHeadline)
                Text(CheckoutStrings.Payment.payByCardSubtitle.localized)
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
            Image.Login.Methods.apple
                .font(.title2)
                .foregroundColor(.snappyBlue)
            
            Spacer()
            
            VStack(alignment: .leading) {
                Text(CheckoutStrings.Payment.payByApple.localized)
                    .font(.snappyHeadline)
                Text(CheckoutStrings.Payment.payByApple.localized)
                    .font(.snappyCaption)
                    .foregroundColor(.snappyTextGrey2)
            }
            
            Spacer()
            
            Image.Navigation.chevronRight
        }
        .padding()
        .background(Color.white)
        .cornerRadius(Constants.cornerRadius)
        .snappyShadow()
    }
    
    func payCash() -> some View {
        HStack {
            if viewModel.processingPayByCash {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .snappyGrey))
                    .scaleEffect(x: Constants.progressViewScale, y: Constants.progressViewScale)
            } else {
                Image.Checkout.cash
                    .font(.title2)
                    .foregroundColor(.snappyBlue)
                
                Spacer()
                
                VStack(alignment: .leading) {
                    Text(CheckoutStrings.Payment.payByCash.localized)
                        .font(.snappyHeadline)
                    Text(CheckoutStrings.Payment.payByCashSubtitle.localized)
                        .font(.snappyCaption)
                        .foregroundColor(.snappyTextGrey2)
                }
                
                Spacer()
                
                Image.Navigation.chevronRight
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(Constants.cornerRadius)
        .snappyShadow()
    }
}

struct CheckoutDeliveryAddressView_Previews: PreviewProvider {
    static var previews: some View {
        CheckoutFulfilmentInfoView(viewModel: .init(container: .preview))
            .environmentObject(CheckoutViewModel(container: .preview))
    }
}
