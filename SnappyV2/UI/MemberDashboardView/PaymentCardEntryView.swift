//
//  PaymentCardEntryView.swift
//  SnappyV2
//
//  Created by Henrik Gustavii on 24/08/2022.
//

import SwiftUI
import Combine

struct PaymentCardEntryView: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.presentationMode) var presentationMode
    
    struct Constants {
        struct Camera {
            static let height: CGFloat = 35
        }
        
        struct CardNumbers {
            static let spacing: CGFloat = 10
        }
    }
    
    @StateObject var viewModel: PaymentCardEntryViewModel
    @StateObject var editAddressViewModel: EditAddressViewModel
    
    private var colorPalette: ColorPalette {
        ColorPalette(container: viewModel.container, colorScheme: colorScheme)
    }
    
    var body: some View {
        NavigationView {
            ScrollView(showsIndicators: false) {
                
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
                
                // [Card number] | Camera Button
                HStack(alignment: .center) {
                    SnappyTextfield(container: viewModel.container, text: $viewModel.creditCardNumber, isDisabled: .constant(false), hasError: $viewModel.isUnvalidCardNumber, labelText: Strings.CheckoutView.Payment.cardNumber.localized, largeTextLabelText: Strings.CheckoutView.Payment.cardNumberShort.localized, fieldType: .standardTextfield, keyboardType: .numberPad, autoCaps: .words, spellCheckingEnabled: false, internalButton: nil)
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
                HStack {
                    SnappyTextfield(container: viewModel.container, text: $viewModel.creditCardName, isDisabled: .constant(false), hasError: .constant(viewModel.isUnvalidCardName), labelText: Strings.CheckoutView.Payment.cardHolderName.localized, largeTextLabelText: Strings.CheckoutView.Payment.cardHolderNameShort.localized, fieldType: .standardTextfield, keyboardType: nil, autoCaps: .sentences, internalButton: nil)
                   
                    HStack {
                        CardExpiryDateSelector(container: viewModel.container, expiryMonth: $viewModel.creditCardExpiryMonth, expiryYear: $viewModel.creditCardExpiryYear, hasError: $viewModel.isUnvalidExpiry)
                        
                        SnappyTextfield(container: viewModel.container, text: $viewModel.creditCardCVV, isDisabled: .constant(false), hasError: $viewModel.isUnvalidCVV, labelText: Strings.CheckoutView.Payment.cvv.localized, largeTextLabelText: nil, fieldType: .standardTextfield, keyboardType: .numberPad, autoCaps: nil, internalButton: nil)
                            .onReceive(Just(viewModel.creditCardCVV)) { newValue in
                                viewModel.filterCardCVV(newValue: newValue)
                            }
                    }
                }
                .padding(.vertical)
                
                EditAddressView(viewModel: editAddressViewModel, setContactDetailsHandler: {}, errorHandler: {_ in})
                    .padding(.bottom)
                
                SnappyButton(container: viewModel.container, type: .primary, size: .large, title: Strings.CheckoutView.Payment.addCard.localized, largeTextTitle: Strings.General.add.localized, icon: nil, isEnabled: .constant(!viewModel.saveNewCardButtonDisabled), isLoading: $viewModel.savingNewCard, clearBackground: false, action: {
                    Task { await viewModel.saveCardTapped(address: editAddressViewModel.addCardHolderAddress())
                    }})
            }
            .padding()
            .withAlertToast(container: viewModel.container, error: $viewModel.error)
            .dismissableNavBar(
                presentation: presentationMode,
                color: colorPalette.primaryBlue,
                title: Strings.CheckoutView.Payment.addNewCard.localized,
                navigationDismissType: .close,
                backButtonAction: nil
            )
            .sheet(isPresented: $viewModel.showCardCamera) {
                CardCameraScanView() { name, number, expiry in
                    viewModel.handleCardCameraReturn(name: name, number: number, expiry: expiry)
                }
                .onDisappear() {
                    viewModel.showCardCamera = false
                }
            }
            .onChange(of: viewModel.dismissView ) { dismissed in
                if dismissed {
                    presentationMode.wrappedValue.dismiss()
                }
            }
        }
    }
}

#if DEBUG
struct PaymentCardEntryView_Previews: PreviewProvider {
    static var previews: some View {
        PaymentCardEntryView(viewModel: PaymentCardEntryViewModel(container: .preview), editAddressViewModel: .init(container: .preview, addressType: .card))
    }
}
#endif
