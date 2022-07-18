//
//  EditDeliveryAddressView.swift
//  SnappyV2
//
//  Created by David Bage on 13/07/2022.
//

import SwiftUI

struct EditAddressView: View {
    @Environment(\.colorScheme) var colorScheme
    
    typealias EditAddressStrings = Strings.CheckoutDetails.EditAddress
    
    struct Constants {
        struct Spacing {
            static let main: CGFloat = 24.5
            static let field: CGFloat = 15
        }
        
        struct BillingAddress {
            static let hSpacing: CGFloat = 16
            static let buttonIconWidth: CGFloat = 24
            static let vSpacing: CGFloat = 5
        }
    }
    
    @ObservedObject var viewModel: EditAddressViewModel
    @ObservedObject var checkoutRootViewModel: CheckoutRootViewModel
    
    private var colorPalette: ColorPalette {
        ColorPalette(container: viewModel.container, colorScheme: colorScheme)
    }
    
    var body: some View {
        VStack(alignment: .center, spacing: Constants.Spacing.main) {
            if viewModel.addressType == .delivery {
                Text(EditAddressStrings.editDeliveryAddress.localized)
                    .font(.heading4())
                    .foregroundColor(colorPalette.primaryBlue)
            }
            
            if viewModel.addressType == .billing, viewModel.fulfilmentType == .delivery {
                useDeliveryAddressForBillingButton
            }
            
            if viewModel.addressType == .delivery {
                fieldsView
            } else if viewModel.addressType == .billing {
                if viewModel.useSameBillingAddressAsDelivery == false {
                    fieldsView
                }
            }
            
            if viewModel.addressType == .delivery, viewModel.memberProfile != nil {
                selectSavedAddressButton
            }
        }
        .withStandardAlert(
            container: viewModel.container,
            isPresenting: $viewModel.showEnterAddressManuallyError,
            type: .error,
            title: EditAddressStrings.Error.title.localized,
            subtitle: EditAddressStrings.Error.subtitle.localized)
        .withStandardAlert(
            container: viewModel.container,
            isPresenting: $viewModel.showMissingDetailsAlert,
            type: .error,
            title: Strings.CheckoutDetails.Errors.Missing.title.localized,
            subtitle: Strings.CheckoutDetails.Errors.Missing.subtitle.localized)
        
        .sheet(isPresented: $viewModel.showAddressSelector) {
            
            if let addresses = viewModel.foundAddresses,
                   let contactDetails = checkoutRootViewModel.contactDetails()
            {
                    AddressSelectionView(
                        viewModel: .init(
                            container: viewModel.container,
                            addressSelectionType: viewModel.addressType,
                            addresses: addresses,
                            showAddressSelectionView: $viewModel.showAddressSelector,
                            firstName: contactDetails.firstName,
                            lastName: contactDetails.lastName,
                            email: contactDetails.email,
                            phone: contactDetails.phone,
                            starterPostcode: viewModel.postcodeText))
                }
            }
            .sheet(isPresented: $viewModel.showSavedAddressSelector) {
                if let savedAddresses = viewModel.savedAddresses {
                    
                    if let email = viewModel.emailText, let phone = viewModel.phoneText {
                        SavedAddressesSelectionView(
                            viewModel: .init(
                                container: viewModel.container,
                                savedAddressType: viewModel.addressType,
                                addresses: savedAddresses,
                                showSavedAddressSelectionView: $viewModel.showSavedAddressSelector,
                                email: email.isEmpty ? viewModel.deliveryEmail ?? "" : email,
                                phone: phone.isEmpty ? viewModel.deliveryPhone ?? "" : phone))
                    }
                }
            }
    }
    
    private var fieldsView: some View {
        VStack(spacing: Constants.Spacing.field) {
            if viewModel.addressType == .billing {
                SnappyTextfield(
                    container: viewModel.container,
                    text: $viewModel.firstNameText,
                    hasError: $viewModel.firstNameHasWarning,
                    labelText: Strings.CheckoutDetails.EditAddress.firstName.localized,
                    largeTextLabelText: nil)
                .onChange(of: viewModel.firstNameText) { _ in
                    viewModel.checkField(stringToCheck: viewModel.firstNameText, fieldHasWarning: &viewModel.firstNameHasWarning)
                }
                
                SnappyTextfield(
                    container: viewModel.container,
                    text: $viewModel.lastNameText,
                    hasError: $viewModel.lastNameHasWarning,
                    labelText: Strings.CheckoutDetails.EditAddress.lastName.localized,
                    largeTextLabelText: nil)
                .onChange(of: viewModel.lastNameText) { _ in
                    viewModel.checkField(stringToCheck: viewModel.lastNameText, fieldHasWarning: &viewModel.lastNameHasWarning)
                }
            }
            
            // Postcode
            
            SnappyTextFieldWithButton(
                container: viewModel.container,
                text: $viewModel.postcodeText,
                hasError: $viewModel.postcodeHasWarning,
                isLoading: $viewModel.searchingForAddresses,
                autoCaps: .allCharacters,
                labelText: EditAddressStrings.postcode.localized,
                largeLabelText: nil, mainButton: (EditAddressStrings.findButton.localized, {
                    Task {
                        await viewModel.findByPostcodeTapped(contactDetailsPresent: checkoutRootViewModel.contactDetails() != nil)
                    }
                }), buttonDisabled: .constant(viewModel.postcodeText.isEmpty))
            .onChange(of: viewModel.postcodeText) { newValue in
                viewModel.checkField(stringToCheck: viewModel.postcodeText, fieldHasWarning: &viewModel.postcodeHasWarning)
            }
            
            // Address line 1
            SnappyTextfield(
                container: viewModel.container,
                text: $viewModel.addressLine1Text,
                hasError: $viewModel.addressLine1HasWarning,
                labelText: EditAddressStrings.addressLine1.localized,
                largeTextLabelText: nil)
            .onChange(of: viewModel.addressLine1Text) { newValue in
                viewModel.checkField(stringToCheck: viewModel.addressLine1Text, fieldHasWarning: &viewModel.addressLine1HasWarning)
            }
            
            // Address line 2
            SnappyTextfield(
                container: viewModel.container,
                text: $viewModel.addressLine2Text,
                hasError: $viewModel.addressLine2HasWarning,
                labelText: EditAddressStrings.addressLine2.localized,
                largeTextLabelText: nil)
            
            // City / town
            SnappyTextfield(
                container: viewModel.container,
                text: $viewModel.cityText,
                hasError: $viewModel.cityHasWarning,
                labelText: EditAddressStrings.town.localized,
                largeTextLabelText: nil)
            .onChange(of: viewModel.cityText) { newValue in
                viewModel.checkField(stringToCheck: viewModel.cityText, fieldHasWarning: &viewModel.cityHasWarning)
            }
            
            // County
            SnappyTextfield(
                container: viewModel.container,
                text: $viewModel.countyText,
                hasError: $viewModel.countyHasWarning,
                labelText: EditAddressStrings.county.localized,
                largeTextLabelText: nil)
            
            // Country
            Menu {
                ForEach(viewModel.selectionCountries, id: \.self) { country in
                    Button {
                        viewModel.countrySelected(country)
                    } label: {
                        Text(country.countryName)
                    }
                }
            } label: {
                SnappyTextfield(
                    container: viewModel.container,
                    text: $viewModel.countryText,
                    hasError: $viewModel.countryHasWarning,
                    labelText: EditAddressStrings.country.localized,
                    largeTextLabelText: nil,
                    fieldType: .label)
            }
            .onChange(of: viewModel.countryText) { newValue in
                viewModel.checkField(stringToCheck: viewModel.countryText, fieldHasWarning: &viewModel.countryHasWarning)
            }
        }
    }
    
    // MARK: - Select saved address button
    private var selectSavedAddressButton: some View {
        SnappyButton(
            container: viewModel.container,
            type: .outline,
            size: .large,
            title: EditAddressStrings.selectSavedAddress.localized,
            largeTextTitle: EditAddressStrings.selectSavedAddressShort.localized,
            icon: nil,
            action: {
                viewModel.showSavedAddressSelector = true
            })
    }
    
    private var useDeliveryAddressForBillingButton: some View {
        HStack(spacing: Constants.BillingAddress.hSpacing) {
            Button {
                viewModel.useSameBillingAddressAsDelivery.toggle()
            } label: {
                (viewModel.useSameBillingAddressAsDelivery ? Image.Icons.CircleCheck.filled : Image.Icons.Circle.standard)
                    .renderingMode(.template)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: Constants.BillingAddress.buttonIconWidth)
                    .foregroundColor(colorPalette.primaryBlue)
            }
            
            VStack(alignment: .leading, spacing: Constants.BillingAddress.vSpacing) {
                Text(Strings.CheckoutView.Payment.billingSameAsDelivery.localized)
                    .font(.Body2.regular())
                .foregroundColor(colorPalette.typefacePrimary)
                
                if viewModel.userLoggedIn {
                    Button {
                        viewModel.showSavedAddressSelector = true
                        viewModel.useSameBillingAddressAsDelivery = false
                    } label: {
                        Text(Strings.CheckoutView.Payment.useSavedAddress.localized)
                            .font(.hyperlink2())
                            .foregroundColor(colorPalette.primaryBlue)
                            .underline()
                    }
                }
                
            }
        }
    }
}

#if DEBUG
struct EditDeliveryAddressView_Previews: PreviewProvider {
    static var previews: some View {
        EditAddressView(viewModel: .init(container: .preview, addressType: .delivery), checkoutRootViewModel: .init(container: .preview, keepCheckoutFlowAlive: .constant(true)))
    }
}
#endif
