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
    @Environment(\.tabViewHeight) var tabViewHeight
    
    struct Constants {
        static let padding: CGFloat = 10
        static let cornerRadius: CGFloat = 10
        
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
        
        struct DetailsStack {
            static let hSpacing: CGFloat = 10
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
                VStack(alignment: .leading) {
                    payByCardHeader
                    
                    EditAddressView(viewModel: editAddressViewModel, setContactDetailsHandler: checkoutRootViewModel.setContactDetails, errorHandler: checkoutRootViewModel.setError(_:))
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
                                await viewModel.continueButtonTapped(fieldErrors: editAddressViewModel.fieldErrors()) {
                                    try await editAddressViewModel.setAddress(email: editAddressViewModel.contactEmail, phone: editAddressViewModel.contactPhone)
                                } errorHandler: { error in
                                    viewModel.container.appState.value.errors.append(error)
                                }
                            }
                        }
                }
                .padding([.horizontal, .top])
                .padding(.bottom, tabViewHeight)
                .onChange(of: editAddressViewModel.fieldErrorsPresent) { fieldErrorsPresent in
                    withAnimation {
                        if fieldErrorsPresent {
                            value.scrollTo(Constants.scrollToID)
                            editAddressViewModel.resetFieldErrorsPresent()
                        }
                    }
                }
                .onAppear() {
                    Task { await viewModel.onAppearTrigger() }
                }
            }
            .background(colorPalette.secondaryWhite)
            .standardCardFormat()
            .padding()
            .sheet(item: $viewModel.threeDSWebViewURLs) { url in
                ToastableViewContainer(content: {
                    Checkoutcom3DSHandleView(urls: url, delegate: viewModel.threeDSDelegate)
                }, viewModel: .init(container: viewModel.container, isModal: true))
            }
            .snappySheet(container: viewModel.container, isPresented: $viewModel.showCardCamera,
                         sheetContent: CardCameraScanView() { name, number, expiry in
                viewModel.handleCardCameraReturn(name: name, number: number, expiry: expiry)
            }
            .onDisappear() {
                viewModel.showCardCamera = false
            })
        }
    }
    
    func cardDetailsSection() -> some View {
        VStack(alignment: .leading) {
            // Saved Cards section
            if viewModel.showSavedCards {
                Text(CheckoutView.PaymentStrings.savedCards.localized)
                    .font(.heading4())
                    .foregroundColor(colorPalette.typefacePrimary)

                
                // Card details
                ForEach(viewModel.savedCardsDetails) { card in
                    HStack {
                        Button {
                            viewModel.selectSavedCard(card: card)
                        } label: {
                            (viewModel.selectedSavedCard?.id == card.id ? Image.Icons.CircleCheck.filled : Image.Icons.Circle.standard)
                                .renderingMode(.template)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: Constants.BillingAddress.buttonIconWidth)
                                .foregroundColor(colorPalette.primaryBlue)
                        }
                        
                        SavedPaymentCardCard(viewModel: .init(container: viewModel.container, card: card, isCheckout: true), compactVersion: .constant(viewModel.selectedSavedCard?.id == card.id))
                        
                        // Saved card CVV
                        if viewModel.selectedSavedCard?.id == card.id {
                            SnappyTextfield(container: viewModel.container, text: $viewModel.selectedSavedCardCVV, isDisabled: .constant(false), hasError: $viewModel.isUnvalidSelectedCardCVV, labelText: CheckoutStrings.Payment.cvv.localized, largeTextLabelText: nil, fieldType: .standardTextfield, keyboardType: .numberPad, autoCaps: nil, internalButton: nil)
                                .onReceive(Just(viewModel.creditCardCVV)) { newValue in
                                    viewModel.filterCardCVV(newValue: newValue)
                                }
                                .frame(maxWidth: 90)
                        }
                    }
                }
                
                if viewModel.showNewCardEntry {
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
            }
            
            if viewModel.showNewCardEntry {
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
                
                // [Card number | Camera Button
                HStack(alignment: .center) {
                    SnappyTextfield(container: viewModel.container, text: $viewModel.creditCardNumber, isDisabled: .constant(false), hasError: $viewModel.isUnvalidCardNumber, labelText: CheckoutStrings.Payment.cardNumber.localized, largeTextLabelText: CheckoutStrings.Payment.cardNumberShort.localized, fieldType: .standardTextfield, keyboardType: .numberPad, autoCaps: nil, internalButton: nil)
                        .onReceive(Just(viewModel.creditCardNumber)) { newValue in
                            viewModel.filterCardNumber(newValue: newValue)
                        }
                    
                    Button(action: { viewModel.showCardCameraTapped() }) {
                        Image.Icons.Camera.viewFinder
                            .resizable()
                            .foregroundColor(colorPalette.typefacePrimary)
                            .aspectRatio(contentMode: .fit)
                            .frame(height: Constants.Camera.height)
                    }
                    .padding([.vertical, .leading], 6)
                }
                .padding(.top)
                
                // [Card holder name] [Expiry Month / Expiry Year] [CVV]
                HStack(spacing: 10) {
                    SnappyTextfield(container: viewModel.container, text: $viewModel.creditCardName, isDisabled: .constant(false), hasError: .constant(viewModel.isUnvalidCardName), labelText: CheckoutStrings.Payment.cardHolderName.localized, largeTextLabelText: CheckoutStrings.Payment.cardHolderNameShort.localized, fieldType: .standardTextfield, keyboardType: .alphabet, autoCaps: .words, spellCheckingEnabled: false, internalButton: nil)
                    
                    HStack {
                        CardExpiryDateSelector(container: viewModel.container, expiryMonth: $viewModel.creditCardExpiryMonth, expiryYear: $viewModel.creditCardExpiryYear, hasError: $viewModel.isUnvalidExpiry, reverseOrder: true)
                        
                        SnappyTextfield(container: viewModel.container, text: $viewModel.creditCardCVV, isDisabled: .constant(false), hasError: $viewModel.isUnvalidCVV, labelText: CheckoutStrings.Payment.cvv.localized, largeTextLabelText: nil, fieldType: .standardTextfield, keyboardType: .numberPad, autoCaps: nil, internalButton: nil)
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
            
            Spacer()
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
