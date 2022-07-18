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
                        Button(action: { viewModel.payByAppleTapped() }) {
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
            .background(colorPalette.secondaryWhite)
            .standardCardFormat()
            .padding()
        }
    }
    
    
    
    // MARK: View Components
    #warning("This component to be replaced by separate view")
    func checkoutProgressView() -> some View {
        VStack(alignment: .leading) {
            HStack(alignment: .center) {
                Image.Checkout.delivery
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
            
            AddressSearchContainer(viewModel: .init(container: viewModel.container, name: viewModel.prefilledAddressName, type: .delivery)) { address in
                if let address = address {
                    Task {
                        await viewModel.setDelivery(address: address)
                    }
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

#if DEBUG
struct CheckoutDeliveryAddressView_Previews: PreviewProvider {
    static var previews: some View {
        CheckoutFulfilmentInfoView(viewModel: .init(container: .preview, checkoutState: .constant(.paymentSelection)))
            .environmentObject(CheckoutViewModel(container: .preview))
    }
}
#endif
