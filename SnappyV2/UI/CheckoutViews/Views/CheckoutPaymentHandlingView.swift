//
//  CheckoutPaymentHandlingView.swift
//  SnappyV2
//
//  Created by Henrik Gustavii on 28/01/2022.
//

import SwiftUI
import Combine

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
        
        struct Card {
            static let cardWidth: CGFloat = 32
        }
        
        struct Camera {
            static let height: CGFloat = 35
        }
        
        struct BillingAddress {
            static let hSpacing: CGFloat = 16
            static let buttonIconWidth: CGFloat = 24
            static let vSpacing: CGFloat = 5
        }
        
        static let scrollToID = 1
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
            ScrollViewReader { value in
                VStack {
                    VStack(alignment: .leading, spacing: Constants.vSpacing) {
                        payByCardHeader
                        
                        EditAddressView(viewModel: editAddressViewModel, checkoutRootViewModel: checkoutRootViewModel)
                            .id(Constants.scrollToID)
                        
                        cardDetailsSection()
                        
                        SnappyButton(
                            container: viewModel.container,
                            type: .success,
                            size: .large,
                            title: CheckoutStrings.PaymentCustom.buttonTitle.localizedFormat(viewModel.basketTotal ?? ""),
                            largeTextTitle: nil,
                            icon: Image.Icons.Padlock.filled,
                            isEnabled: .constant(!viewModel.continueButtonDisabled),
                            isLoading: $viewModel.handlingPayment) {
                                Task {
                                    await viewModel.continueButtonTapped() {
                                        try await editAddressViewModel.setAddress(email: editAddressViewModel.contactEmail, phone: editAddressViewModel.contactPhone)
                                    } errorHandler: { error in
                                        checkoutRootViewModel.setCheckoutError(error)
                                    }
                                }
                            }
                    }
                    .padding()
                }
                .onChange(of: editAddressViewModel.fieldErrorsPresent) { fieldErrorsPresent in
                    withAnimation {
                        if fieldErrorsPresent {
                            value.scrollTo(Constants.scrollToID)
                            editAddressViewModel.resetFieldErrorsPresent()
                        }
                    }
                }
                
            }
            .background(colorPalette.secondaryWhite)
            .standardCardFormat()
            .padding()
            .withAlertToast(container: viewModel.container, error: $viewModel.error)
            .sheet(item: $viewModel.threeDSWebViewURLs) { url in
                Checkoutcom3DSHandleView(urls: url, delegate: Checkoutcom3DSHandleView.Delegate(
                    didSucceed: { Task { await viewModel.threeDSSuccess() } },
                    didFail: { viewModel.threeDSFail() }))
            }
            .sheet(isPresented: $viewModel.showCardCamera) {
                CardCameraScanView() { name, number, expiry in
                    viewModel.handleCardCameraReturn(name: name, number: number, expiry: expiry)
                }
                .onDisappear() {
                    viewModel.showCardCamera = false
                }
            }
        }
    }
    
    func cardDetailsSection() -> some View {
        VStack(alignment: .leading) {
            // Saved Cards section
            if viewModel.memberProfile != nil {
                Text(CheckoutView.PaymentStrings.savedCards.localized)
                    .font(.heading4())
                    .foregroundColor(colorPalette.typefacePrimary)

                
                // - e.g. Visa card
                HStack {
                    Button {
                        viewModel.saveCreditCard.toggle()
                    } label: {
                        (viewModel.saveCreditCard ? Image.Icons.CircleCheck.filled : Image.Icons.Circle.standard)
                            .renderingMode(.template)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: Constants.BillingAddress.buttonIconWidth)
                            .foregroundColor(colorPalette.primaryBlue)
                    }
                    
                    Image.PaymentCards.visa
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: Constants.Card.cardWidth)
                        .padding()
                    
                    Text("**** **** **** 3333")
                        .font(.snappyBody2)
                        .padding()
                    
                    Text("04/25")
                        .font(.snappyBody2)
                        .padding()
                }
                // - e.g Mastercard
                HStack {
                    Button {
                        viewModel.saveCreditCard.toggle()
                    } label: {
                        (viewModel.saveCreditCard ? Image.Icons.CircleCheck.filled : Image.Icons.Circle.standard)
                            .renderingMode(.template)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: Constants.BillingAddress.buttonIconWidth)
                            .foregroundColor(colorPalette.primaryBlue)
                    }
                    
                    Image.PaymentCards.masterCard
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: Constants.Card.cardWidth)
                        .padding()
                    
                    Text("**** **** **** 2222")
                        .font(.snappyBody2)
                        .padding()
                    
                    Text("02/24")
                        .font(.snappyBody2)
                        .padding()
                }
                
                // --- OR ---
                HStack {
                    VStack {
                        Divider()
                    }
                    
                    Text(GeneralStrings.or.localized)
                        .font(.button1())
                        .foregroundColor(colorPalette.typefacePrimary)
                        .background(Color.clear)
                    
                    VStack {
                        Divider()
                    }
                }
                .padding(.bottom)
            }
            
            // Use new card section
            Text(CheckoutStrings.Payment.useNewCard.localized)
                .font(.heading4())
                .foregroundColor(colorPalette.typefacePrimary)
            
            // Card type icons
            HStack {
                Image.PaymentCards.visa
                    .opacity(viewModel.showVisaCard ? 1 : 0.4)
                Image.PaymentCards.masterCard
                    .opacity(viewModel.showMasterCardCard ? 1 : 0.4)
                Image.PaymentCards.jcb
                    .opacity(viewModel.showJCBCard ? 1 : 0.4)
                Image.PaymentCards.discover
                    .opacity(viewModel.showDiscoverCard ? 1 : 0.4)
                
                Spacer()
            }
            
            // [Card holder name] | Camera Button
            HStack(alignment: .center) {
                SnappyTextfield(container: viewModel.container, text: $viewModel.creditCardName, isDisabled: .constant(false), hasError: .constant(viewModel.isUnvalidCardName), labelText: CheckoutStrings.Payment.cardHolderName.localized, largeTextLabelText: CheckoutStrings.Payment.cardHolderNameShort.localized, bgColor: .white, fieldType: .standardTextfield, keyboardType: .alphabet, autoCaps: .words, spellCheckingEnabled: false, internalButton: nil)
                
                Button(action: { viewModel.showCardCameraTapped() }) {
                    Image.Icons.Camera.standard
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: Constants.Camera.height)
                }
                .padding([.vertical, .leading], 6)
            }
            .padding(.top)
            
            // [Card number] [Expiry Month / Expiry Year] [CVV]
            HStack {
                SnappyTextfield(container: viewModel.container, text: $viewModel.creditCardNumber, isDisabled: .constant(false), hasError: $viewModel.isUnvalidCardNumber, labelText: CheckoutStrings.Payment.cardNumber.localized, largeTextLabelText: CheckoutStrings.Payment.cardNumberShort.localized, bgColor: .white, fieldType: .standardTextfield, keyboardType: .numberPad, autoCaps: nil, internalButton: nil)
                    .onReceive(Just(viewModel.creditCardNumber)) { newValue in
                        viewModel.filterCardNumber(newValue: newValue)
                    }
                HStack {
                    CardExpiryDateSelector(expiryMonth: $viewModel.creditCardExpiryMonth, expiryYear: $viewModel.creditCardExpiryYear, hasError: $viewModel.isUnvalidExpiry)
                    
                    SnappyTextfield(container: viewModel.container, text: $viewModel.creditCardCVV, isDisabled: .constant(false), hasError: $viewModel.isUnvalidCVV, labelText: CheckoutStrings.Payment.cvv.localized, largeTextLabelText: nil, bgColor: .white, fieldType: .standardTextfield, keyboardType: .numberPad, autoCaps: nil, internalButton: nil)
                        .onReceive(Just(viewModel.creditCardCVV)) { newValue in
                            viewModel.filterCardCVV(newValue: newValue)
                        }
                }
            }
            .padding(.vertical)
            
            if viewModel.memberProfile != nil {
                // O - Save card details checkmark
                HStack {
                    Button {
                        viewModel.saveCreditCard.toggle()
                    } label: {
                        (viewModel.saveCreditCard ? Image.Icons.CircleCheck.filled : Image.Icons.Circle.standard)
                            .renderingMode(.template)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: Constants.BillingAddress.buttonIconWidth)
                            .foregroundColor(colorPalette.primaryBlue)
                    }
                    
                    Text(CheckoutStrings.Payment.saveCardDetails.localized)
                        .font(.Body2.regular())
                        .foregroundColor(colorPalette.typefacePrimary)
                }
            }
            
        }
    }
    
    func cardDetailsSection() -> some View {
        VStack(alignment: .leading) {
            // Saved Cards section
            if true { // if signed in
                Text("Saved Cards")
                    .font(.heading4())
                    .foregroundColor(colorPalette.typefacePrimary)

                
                // - e.g. Visa card
                HStack {
                    Button {
                        viewModel.saveCreditCard.toggle()
                    } label: {
                        (viewModel.saveCreditCard ? Image.Icons.CircleCheck.filled : Image.Icons.Circle.standard)
                            .renderingMode(.template)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: Constants.BillingAddress.buttonIconWidth)
                            .foregroundColor(colorPalette.primaryBlue)
                    }
                    
                    Image.PaymentCards.visa
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: Constants.Card.cardWidth)
                        .padding()
                    
                    Text("**** **** **** 3333")
                        .font(.snappyBody2)
                        .padding()
                    
                    Text("04/25")
                        .font(.snappyBody2)
                        .padding()
                }
                // - e.g Mastercard
                HStack {
                    Button {
                        viewModel.saveCreditCard.toggle()
                    } label: {
                        (viewModel.saveCreditCard ? Image.Icons.CircleCheck.filled : Image.Icons.Circle.standard)
                            .renderingMode(.template)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: Constants.BillingAddress.buttonIconWidth)
                            .foregroundColor(colorPalette.primaryBlue)
                    }
                    
                    Image.PaymentCards.masterCard
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: Constants.Card.cardWidth)
                        .padding()
                    
                    Text("**** **** **** 2222")
                        .font(.snappyBody2)
                        .padding()
                    
                    Text("02/24")
                        .font(.snappyBody2)
                        .padding()
                }
                
                // --- OR ---
                HStack {
                    VStack {
                        Divider()
                    }
                    
                    Text(GeneralStrings.or.localized)
                        .font(.button1())
                        .foregroundColor(colorPalette.typefacePrimary)
                        .background(Color.clear)
                    
                    VStack {
                        Divider()
                    }
                }
                .padding(.bottom)
            }
            
            // Use new card section
            Text("Use New Card")
                .font(.heading4())
                .foregroundColor(colorPalette.typefacePrimary)
            // Card type icons
            
            HStack {
                Image.PaymentCards.visa
                Image.PaymentCards.masterCard
                Image.PaymentCards.jcb
                Image.PaymentCards.discover
                
                Spacer()
            }
            
            // [Card holder name]
            SnappyTextfield(container: viewModel.container, text: $viewModel.creditCardName, isDisabled: .constant(false), hasError: .constant(false), labelText: "Card Holder Name", largeTextLabelText: "Name", bgColor: .white, fieldType: .standardTextfield, keyboardType: nil, autoCaps: .sentences, internalButton: nil)
                .padding(.top)
            
            // [Card number] [Expiry date] [CVV]
            HStack {
                SnappyTextfield(container: viewModel.container, text: $viewModel.creditCardNumber, isDisabled: .constant(false), hasError: .constant(false), labelText: "Card Number", largeTextLabelText: "Number", bgColor: .white, fieldType: .standardTextfield, keyboardType: nil, autoCaps: .sentences, internalButton: nil)
                HStack {
                    SnappyTextfield(container: viewModel.container, text: $viewModel.creditCardExpiry, isDisabled: .constant(false), hasError: .constant(false), labelText: "Expiry", largeTextLabelText: nil, bgColor: .white, fieldType: .standardTextfield, keyboardType: nil, autoCaps: nil, internalButton: nil)
                    
                    SnappyTextfield(container: viewModel.container, text: $viewModel.creditCardCVV, isDisabled: .constant(false), hasError: .constant(false), labelText: "CVV", largeTextLabelText: nil, bgColor: .white, fieldType: .standardTextfield, keyboardType: nil, autoCaps: nil, internalButton: nil)
                }
            }
            .padding(.vertical)
            
            if true { // if signed in
                // O - Save card details checkmark
                HStack {
                    Button {
                        viewModel.saveCreditCard.toggle()
                    } label: {
                        (viewModel.saveCreditCard ? Image.Icons.CircleCheck.filled : Image.Icons.Circle.standard)
                            .renderingMode(.template)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: Constants.BillingAddress.buttonIconWidth)
                            .foregroundColor(colorPalette.primaryBlue)
                    }
                    
                    Text("Save card details?")
                        .font(.Body2.regular())
                        .foregroundColor(colorPalette.typefacePrimary)
                }
            }
            
        }
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
}

#if DEBUG
struct CheckoutPaymentHandlingView_Previews: PreviewProvider {
    static var previews: some View {
        CheckoutPaymentHandlingView(viewModel: .init(container: .preview, instructions: nil, paymentSuccess: {}, paymentFailure: {}), editAddressViewModel: .init(container: .preview, addressType: .billing), checkoutRootViewModel: .init(container: .preview))
    }
}
#endif
