//
//  AddressSearchView.swift
//  SnappyV2
//
//  Created by David Bage on 08/02/2022.
//

import SwiftUI

struct AddressSearchView: View {
    
    typealias AddressStrings = Strings.PostCodeSearch.Address
    
    // MARK: - Constants
    
    struct Constants {
        struct Navigation {
            static let closeButtonPadding: CGFloat = 5
        }
        
        struct PostcodeSearchView {
            static let textfieldPadding: CGFloat = 25
            static let addressResultsPadding: CGFloat = 5
            static let foundAddressesPadding: CGFloat = 100
        }
        
        struct AddressResultView {
            static let padding: CGFloat = 10
            static let lineHeight: CGFloat = 1
        }
        
        struct SelectAddressButton {
            static let vPadding: CGFloat = 3
            static let hPadding: CGFloat = 10
        }
        
        struct CountryDropDown {
            static let iconPadding: CGFloat = 5
        }
        
        struct ToManualAddress {
            static let backgroundColor = Color(UIColor.systemBackground.withAlphaComponent(0.95))
        }
        
        struct ToPostcodeSearchButton {
            static let additionalPadding: CGFloat = 2
        }
        
        struct ManualAddressInputView {
            struct ButtonStack {
                static let padding: CGFloat = 13
                static let buttonSpacing: CGFloat = 10
            }
        }
    }
    
    @ObservedObject var viewModel: AddressSearchViewModel
    
    var didSelectAddress: (Address?) -> ()
    
    var body: some View {
        switch viewModel.viewState {
        case .postCodeSearch:
            postcodeSearchView
                .padding()
        case .addressManualInput:
            manualAddressInputView
        }
    }
    
    // MARK: - Close button
    
    private var cancelButton: some View {
        Button {
            viewModel.cancelButtonTapped()
        } label: {
            Text(GeneralStrings.cancel.localized)
        }
    }
    
    // MARK: - Postcode search view
    
    private var postcodeSearchView: some View {
        VStack {
            HStack {
                Spacer()
                cancelButton
                    .padding(.bottom, Constants.Navigation.closeButtonPadding)
            }
            
            PostcodeSearchBarWithButton(viewModel: viewModel)
                .padding(.bottom, Constants.PostcodeSearchView.textfieldPadding)
            
            if viewModel.noAddressesFound {
                Spacer()
                Text(Strings.PostCodeSearch.noAddressFound.localized)
                    .font(.snappyHeadline)
                    .foregroundColor(.snappyRed)
            }
            
            if viewModel.addressesAreLoading {
                Spacer()
                ProgressView().progressViewStyle(CircularProgressViewStyle(tint: .snappyTextGrey1))
            }
            
            ZStack(alignment: .bottom) {
                ScrollView(showsIndicators: false) {
                    ForEach(viewModel.foundAddresses, id: \.self) { address in
                        addressResultView(address: address)
                            .padding(.vertical, Constants.PostcodeSearchView.addressResultsPadding)
                    }
                    .padding(.bottom, Constants.PostcodeSearchView.foundAddressesPadding)
                }
                toManualAddressView
            }
        }
    }
    
    private var toManualAddressView: some View {
        VStack {
            Text(Strings.PostCodeSearch.prompt.localized)
                .font(.snappyBody)
                .foregroundColor(.snappyTextGrey2)
                .fontWeight(.medium)
            
            Button {
                viewModel.enterAddressManuallyTapped()
                
            } label: {
                Text(Strings.PostCodeSearch.enterManually.localized)
                    .font(Font.snappyHeadline)
            }
            .buttonStyle(SnappySecondaryButtonStyle())
            .frame(maxWidth: .infinity)
        }
        .padding(.top)
        .background(Constants.ToManualAddress.backgroundColor)
    }
    
    // MARK: - Subview : Address result view
    
    private func addressResultView(address: FoundAddress) -> some View {
        VStack {
            HStack {
                Text(address.addressLineSingle)
                    .font(Font.snappyBody)
                    .fontWeight(.medium)
                    .foregroundColor(.snappyTextGrey2)
                
                Spacer()

                selectAddressButton(address: Address(
                    id: Int(UUID().uuidString),
                    isDefault: false,
                    addressName: nil,
                    firstName: "",
                    lastName: "",
                    addressline1: address.addressline1,
                    addressline2: address.addressline2,
                    town: address.town,
                    postcode: address.postcode,
                    county: address.county,
                    countryCode: address.countryCode,
                    type: viewModel.addressType,
                    location: nil))
            }
            .padding(.bottom, Constants.AddressResultView.padding)
            
            Rectangle()
                .frame(height: Constants.AddressResultView.lineHeight, alignment: .center)
                .foregroundColor(.snappyTextGrey2)
        }
    }
    
    // MARK: - Subview : Select address buttons
    
    private func selectAddressButton(address: Address) -> some View {
        Button {
            viewModel.selectAddressTapped(address)
            
        } label: {
            HStack {
                Text(GeneralStrings.select.localized.uppercased())
                    .font(Font.snappyCaption2)
                    .padding(.vertical, Constants.SelectAddressButton.vPadding)
                    .padding(.horizontal, Constants.SelectAddressButton.hPadding)
                
                Image.Actions.Add.standard
            }
        }
        .buttonStyle(SnappySecondaryButtonStyle())
    }
    
    // MARK: - Manual address input view
    
    private var manualAddressInputView: some View {
        VStack {
            ZStack {
                HStack {
                    Spacer()
                    cancelButton
                }
                
                Text(viewModel.manualAddressTitle)
                    .font(Font.snappyHeadline)
                    .fontWeight(.medium)
                    .foregroundColor(.snappyBlue)
                    .frame(maxWidth: .infinity)
            }
            .padding(.bottom)
            
            ScrollView(showsIndicators: false) {
                addressInputFields
                countryMenu
                    .padding(.bottom, Constants.ManualAddressInputView.ButtonStack.padding)
                toPostcodeSearchButton
                    .padding(.bottom, Constants.ManualAddressInputView.ButtonStack.buttonSpacing)
                addDeliveryAddressButton
            }
        }
        .padding()
    }
    
    // MARK: - Address input fields
    
    @ViewBuilder var addressInputFields: some View {
        
        HStack {
            TextFieldFloatingWithBorder(AddressStrings.firstName.localized, text: $viewModel.firstNameText, hasWarning: .constant(viewModel.firstNameHasWarning))
            
            TextFieldFloatingWithBorder(AddressStrings.lastName.localized, text: $viewModel.lastNameText, hasWarning: .constant(viewModel.lastNameHasWarning))
        }
        
        TextFieldFloatingWithBorder(AddressStrings.line1.localized, text: $viewModel.addressLine1Text, hasWarning: .constant(viewModel.addressLine1HasWarning))
        
        TextFieldFloatingWithBorder(AddressStrings.line2.localized, text: $viewModel.addressLine2Text)
        
        TextFieldFloatingWithBorder(AddressStrings.city.localized, text: $viewModel.townText, hasWarning: .constant(viewModel.cityHasWarning))
        
        TextFieldFloatingWithBorder(AddressStrings.county.localized, text: $viewModel.countyText)
        
        TextFieldFloatingWithBorder(AddressStrings.postcode.localized, text: $viewModel.postcodeText, hasWarning: .constant(viewModel.postcodeHasWarning))
    }
    
    // MARK: - Country selection menu
    
    private var countryMenu: some View {
        Menu {
            ForEach(viewModel.selectionCountries, id: \.self) { country in
                Button {
                    viewModel.countrySelected(country)
                } label: {
                    Text(country.countryName)
                }
            }
        } label: {
            ZStack(alignment: .trailing) {
                TextFieldFloatingWithBorder(
                    AddressStrings.country.localized, text: $viewModel.countryText,
                    hasWarning: .constant(viewModel.countryHasWarning),
                    isDisabled: true,
                    disableAnimations: true)
                    .multilineTextAlignment(.leading)
                    .foregroundColor(.snappyDark)
                    
                
                Image.Navigation.chevronDown
                    .foregroundColor(.gray)
                    .padding(.trailing, Constants.CountryDropDown.iconPadding)
                    .padding(.top, Constants.CountryDropDown.iconPadding)
            }
        }
    }
    
    // MARK: - Add delivery address button
    
    private var addDeliveryAddressButton: some View {
        Button {
            viewModel.addAddressTapped(addressSetter: didSelectAddress)
            
        } label: {
            Text(viewModel.manualAddressButtonTitle)
                .font(Font.snappyHeadline)
        }
        .buttonStyle(SnappyMainActionButtonStyle(isEnabled: true))
    }
    
    private var toPostcodeSearchButton: some View {
        Button {
            viewModel.toPostcodeButtonTapped()
            
        } label: {
            Text(Strings.PostCodeSearch.toPostcodeSearch.localized)
                .font(Font.snappyHeadline)
                .frame(maxWidth: .infinity)
                .padding(.vertical, Constants.ToPostcodeSearchButton.additionalPadding)
        }
        .buttonStyle(SnappySecondaryButtonStyle())
        .padding(.horizontal)
    }
}


struct AddressSearchView_Previews: PreviewProvider {
    
    static var previews: some View {
        AddressSearchView(viewModel: AddressSearchViewModel(container: DIContainer.preview), didSelectAddress: { address in
            print("Address")
        })
            .previewCases()
    }
}
