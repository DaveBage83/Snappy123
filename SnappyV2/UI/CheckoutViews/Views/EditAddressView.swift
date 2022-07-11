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
            
            if viewModel.addressType == .billing {
                useDeliveryAddressForBillingButton
            }
            
            if viewModel.addressType == .delivery {
                fieldsView
            } else if viewModel.addressType == .billing {
                if viewModel.useSameBillingAddressAsDelivery == false {
                    fieldsView
                }
            }
            
            if viewModel.addressType == .delivery {
                selectSavedAddressButton
            }
        }
        .sheet(isPresented: $viewModel.showAddressSelector) {
                if let addresses = viewModel.foundAddresses,
                    let firstName = "",
                   let lastName = "",
                   let email = "",
                   let phone = "" {
                    AddressSelectionView(
                        viewModel: .init(
                            container: viewModel.container,
                            addressSelectionType: viewModel.addressType,
                            addresses: addresses,
                            showAddressSelectionView: $viewModel.showAddressSelector,
                            firstName: firstName,
                            lastName: lastName,
                            email: email,
                            phone: phone))
                }
            }
            .sheet(isPresented: $viewModel.showSavedAddressSelector) {
                if let savedAddresses = viewModel.savedAddresses {
                    
                    if let email = viewModel.email, let phone = viewModel.phone {
                        SavedAddressesSelectionView(
                            viewModel: .init(
                                container: viewModel.container,
                                savedAddressType: viewModel.addressType,
                                addresses: savedAddresses,
                                showSavedAddressSelectionView: $viewModel.showSavedAddressSelector,
                                email: email,
                                phone: phone))
                    }
                }
            }
    }
    
    private var fieldsView: some View {
        VStack(spacing: Constants.Spacing.field) {
            if viewModel.addressType == .billing {
                SnappyTextfield(
                    container: viewModel.container,
                    text: $viewModel.firstNameField.textValue,
                    hasError: $viewModel.firstNameField.hasWarning,
                    labelText: Strings.CheckoutDetails.EditAddress.firstName.localized,
                    largeTextLabelText: nil)
                
                SnappyTextfield(
                    container: viewModel.container,
                    text: $viewModel.lastNameField.textValue,
                    hasError: $viewModel.lastNameField.hasWarning,
                    labelText: Strings.CheckoutDetails.EditAddress.lastName.localized,
                    largeTextLabelText: nil)
            }
            
            // Postcode
            SnappyTextFieldWithButton(
                container: viewModel.container,
                text: $viewModel.postcodeField.textValue,
                hasError: $viewModel.postcodeField.hasWarning,
                isLoading: $viewModel.searchingForAddresses,
                labelText: EditAddressStrings.postcode.localized,
                largeLabelText: nil, mainButton: (EditAddressStrings.findButton.localized, {
                Task {
                    await viewModel.findByPostcodeTapped()
                }
            }))
            .onChange(of: viewModel.postcodeField.textValue) { newValue in
                viewModel.postcodeField.checkValidity()
            }
            
            // Address line 1
            SnappyTextfield(
                container: viewModel.container,
                text: $viewModel.addressLine1Field.textValue,
                hasError: $viewModel.addressLine1Field.hasWarning,
                labelText: EditAddressStrings.addressLine1.localized,
                largeTextLabelText: nil)
                .onChange(of: viewModel.addressLine1Field.textValue) { newValue in
                    viewModel.addressLine1Field.checkValidity()
                }
            
            // Address line 2
            SnappyTextfield(
                container: viewModel.container,
                text: $viewModel.addressLine2Field.textValue,
                hasError: $viewModel.addressLine2Field.hasWarning,
                labelText: EditAddressStrings.addressLine2.localized,
                largeTextLabelText: nil)
            
            // City / town
            SnappyTextfield(
                container: viewModel.container,
                text: $viewModel.cityField.textValue,
                hasError: $viewModel.cityField.hasWarning,
                labelText: EditAddressStrings.town.localized,
                largeTextLabelText: nil)
            .onChange(of: viewModel.cityField.textValue) { newValue in
                    viewModel.cityField.checkValidity()
                }
            
            // County
            SnappyTextfield(
                container: viewModel.container,
                text: $viewModel.countyField.textValue,
                hasError: $viewModel.countyField.hasWarning,
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
                    text: $viewModel.countryField.textValue,
                    hasError: $viewModel.countryField.hasWarning,
                    labelText: EditAddressStrings.country.localized,
                    largeTextLabelText: nil,
                    fieldType: .label)
            }
            .onChange(of: viewModel.countryField.textValue) { newValue in
                viewModel.countryField.checkValidity()
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

#if DEBUG
struct EditDeliveryAddressView_Previews: PreviewProvider {
    static var previews: some View {
        EditAddressView(viewModel: .init(container: .preview, email: "test@email.com", phone: "123456", addressType: .delivery))
    }
}
#endif
