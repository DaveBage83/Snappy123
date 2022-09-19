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
    
    private let setContactDetailsHandler: () async throws -> ()
    private let errorHandler: @MainActor (Swift.Error) -> ()
        
    @ObservedObject var viewModel: EditAddressViewModel
    
    private var colorPalette: ColorPalette {
        ColorPalette(container: viewModel.container, colorScheme: colorScheme)
    }
    
    init(viewModel: EditAddressViewModel, setContactDetailsHandler: @escaping () async throws -> (), errorHandler: @MainActor @escaping (Swift.Error) -> ()) {
        self.viewModel = viewModel
        self.setContactDetailsHandler = setContactDetailsHandler
        self.errorHandler = errorHandler
    }
    
    var body: some View {
        VStack(alignment: .center, spacing: Constants.Spacing.main) {
            if viewModel.showEditDeliveryAddressOption{
                Text(EditAddressStrings.editDeliveryAddress.localized)
                    .font(.heading4())
                    .foregroundColor(colorPalette.primaryBlue)
            }
            
            if viewModel.showUseDeliveryAddressForBillingButton {
                useDeliveryAddressForBillingButton
            } else if viewModel.showUseDefaultBillingAddressForCardButton {
                useDefaultBillingAddressForCardbutton
            }
            
            if viewModel.showAddressFields {
                fieldsView
            }
        }
        .sheet(isPresented: $viewModel.showAddressSelector) {
            AddressSelectionView(
                viewModel: .init(
                    container: viewModel.container,
                    addressSelectionType: viewModel.addressType,
                    addresses: viewModel.foundAddresses,
                    showAddressSelectionView: $viewModel.showAddressSelector,
                    firstName: viewModel.contactFirstName,
                    lastName: viewModel.contactLastName,
                    email: viewModel.contactEmail,
                    phone: viewModel.contactPhone,
                    starterPostcode: viewModel.postcodeText,
                    isInCheckout: true),
                didSelectAddress: { address in
                    viewModel.populateFields(address: address)
                }, addressSaved: {})
        }
        .sheet(isPresented: $viewModel.showSavedAddressSelector) {
            SavedAddressesSelectionView(
                viewModel: .init(
                    container: viewModel.container,
                    savedAddressType: viewModel.addressType,
                    addresses: viewModel.savedAddresses,
                    firstName: viewModel.contactFirstName,
                    lastName: viewModel.contactLastName,
                    email: viewModel.contactEmail,
                    phone:viewModel.contactPhone), didSetAddress: { address in
                        viewModel.populateFields(address: address)
                    })
        }
    }
    
    private var fieldsView: some View {
        VStack(spacing: Constants.Spacing.field) {
            if viewModel.addressType == .billing {
                // First Name
                SnappyTextfield(
                    container: viewModel.container,
                    text: $viewModel.firstNameText,
                    hasError: $viewModel.firstNameHasWarning,
                    labelText: Strings.CheckoutDetails.EditAddress.firstName.localized,
                    largeTextLabelText: nil)
                .onChange(of: viewModel.firstNameText) { _ in
                    viewModel.checkField(stringToCheck: viewModel.firstNameText, fieldHasWarning: &viewModel.firstNameHasWarning)
                }
                
                // Surname
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
                largeLabelText: nil,
                mainButton: (EditAddressStrings.findButton.localized, {
                    Task {
                        await viewModel.findByPostcodeTapped(
                            setContactDetails: setContactDetailsHandler,
                            errorHandler: { error in
                                errorHandler(error)
                            }
                        )
                    }
                }),
                buttonDisabled: .constant(viewModel.postcodeText.isEmpty)
            )
            .onChange(of: viewModel.postcodeText) { newValue in
                viewModel.checkField(stringToCheck: viewModel.postcodeText, fieldHasWarning: &viewModel.postcodeHasWarning)
            }
            
            // Address line 1
            SnappyTextfield(
                container: viewModel.container,
                text: $viewModel.addressLine1Text,
                hasError: $viewModel.addressLine1HasWarning,
                labelText: EditAddressStrings.addressLine1.localized,
                largeTextLabelText: nil
            )
            .onChange(of: viewModel.addressLine1Text) { newValue in
                viewModel.checkField(stringToCheck: viewModel.addressLine1Text, fieldHasWarning: &viewModel.addressLine1HasWarning)
            }
            
            if viewModel.showBillingOrDeliveryFields {
                // Address line 2
                SnappyTextfield(
                    container: viewModel.container,
                    text: $viewModel.addressLine2Text,
                    hasError: $viewModel.addressLine2HasWarning,
                    labelText: EditAddressStrings.addressLine2.localized,
                    largeTextLabelText: nil
                )
                
                // City / town
                SnappyTextfield(
                    container: viewModel.container,
                    text: $viewModel.cityText,
                    hasError: $viewModel.cityHasWarning,
                    labelText: EditAddressStrings.town.localized,
                    largeTextLabelText: nil
                )
                .onChange(of: viewModel.cityText) { newValue in
                    viewModel.checkField(stringToCheck: viewModel.cityText, fieldHasWarning: &viewModel.cityHasWarning)
                }
                
                // County
                SnappyTextfield(
                    container: viewModel.container,
                    text: $viewModel.countyText,
                    hasError: $viewModel.countyHasWarning,
                    labelText: EditAddressStrings.county.localized,
                    largeTextLabelText: nil
                )
            }
            
            // Country
            CountrySelector(viewModel: .init(
                container: viewModel.container,
                starterCountryCode: viewModel.selectedCountry?.countryCode,
                countrySelected: { country in viewModel.countrySelected(country) }
            ))
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
            isLoading: $viewModel.searchingForSavedAddresses,
            action: {
                Task {
                    await viewModel.showSavedAddressesTapped(
                        setEmptyAddressesError: {
                            errorHandler(CheckoutRootViewError.noAddressesFound)
                        },
                        setContactDetails: setContactDetailsHandler
                    )
                }
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
                        viewModel.showSavedAddressSelectorView()
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
    
    private var useDefaultBillingAddressForCardbutton: some View {
        HStack(spacing: Constants.BillingAddress.hSpacing) {
            Button {
                viewModel.useSameCardAddressAsDefaultBilling.toggle()
            } label: {
                (viewModel.useSameCardAddressAsDefaultBilling ? Image.Icons.CircleCheck.filled : Image.Icons.Circle.standard)
                    .renderingMode(.template)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: Constants.BillingAddress.buttonIconWidth)
                    .foregroundColor(colorPalette.primaryBlue)
            }
            
            VStack(alignment: .leading, spacing: Constants.BillingAddress.vSpacing) {
                Text("Card address is the same as default billing address")
                    .font(.Body2.regular())
                .foregroundColor(colorPalette.typefacePrimary)
                
                if viewModel.userLoggedIn {
                    Button {
                        viewModel.showSavedAddressSelectorView()
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
        EditAddressView(viewModel: .init(container: .preview, addressType: .billing), setContactDetailsHandler: {}, errorHandler: {_ in })
    }
}
#endif
