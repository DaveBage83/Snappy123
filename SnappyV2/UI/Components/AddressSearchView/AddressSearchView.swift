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
        struct PostcodeSearchView {
            static let textfieldPadding: CGFloat = 25
            static let addressResultsPadding: CGFloat = 5
            static let promptColor = Color.black.opacity(0.6)
        }
        
        struct AddressResultView {
            static let padding: CGFloat = 10
            static let lineHeight: CGFloat = 1
            static let lineColor = Color.black.opacity(0.3)
        }
        
        struct SelectAddressButton {
            static let vPadding: CGFloat = 3
            static let hPadding: CGFloat = 10
        }
        
        struct CountryDropDown {
            static let iconPadding: CGFloat = 5
        }
    }
    
    @ObservedObject var viewModel: AddressSearchViewModel
    
    var didSelectAddress: (FoundAddress?) -> ()
    
    var body: some View {
        VStack {
            if viewModel.viewState == .postCodeSearch {
                postcodeSearchView
                    .padding()
            } else if viewModel.viewState == .addressManualInput {
                manualAddressInputView
            }
        }
        .padding()
    }
    
    // MARK: - Postcode search view
    
    @ViewBuilder var postcodeSearchView: some View {
        PostcodeSearchBarWithButton(viewModel: viewModel)
            .padding(.bottom, Constants.PostcodeSearchView.textfieldPadding)
        
        ScrollView(showsIndicators: false) {
            ForEach(viewModel.foundAddresses, id: \.self) { address in
                addressResultView(address: address)
                    .padding(.vertical, Constants.PostcodeSearchView.addressResultsPadding)
            }
        }
        
        VStack {
            Text(Strings.PostCodeSearch.prompt.localized)
                .font(Font.snappyBody)
                .foregroundColor(Constants.PostcodeSearchView.promptColor)
                .fontWeight(.medium)
            
            Button {
                viewModel.enterAddressManuallyTapped()
                
            } label: {
                Text(Strings.PostCodeSearch.enterManually.localized)
                    .font(Font.snappyHeadline)
            }
            .buttonStyle(SnappyMainActionButtonStyle(isEnabled: true))
        }
    }
    
    // MARK: - Subview : Address result view
    
    private func addressResultView(address: FoundAddress) -> some View {
        VStack {
            HStack {
                Text(address.addressLineSingle)
                    .font(Font.snappyBody)
                    .fontWeight(.medium)
                    .foregroundColor(.gray)
                
                Spacer()
                
                selectAddressButton(address: address)
            }
            .padding(.bottom, Constants.AddressResultView.padding)
            
            Rectangle()
                .frame(height: Constants.AddressResultView.lineHeight, alignment: .center)
                .foregroundColor(Constants.AddressResultView.lineColor)
        }
    }
    
    // MARK: - Subview : Select address buttons
    
    private func selectAddressButton(address: FoundAddress) -> some View {
        Button {
            viewModel.selectAddressTapped(address: address, addressSetter: didSelectAddress)
            
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
    
    @ViewBuilder var manualAddressInputView: some View {
        VStack {
            HStack {
                backButton
                Spacer()
            }
            
            Text(Strings.PostCodeSearch.addDeliveryAddress.localized)
                .font(Font.snappyTitle2)
                .fontWeight(.medium)
                .foregroundColor(.snappyBlue)
                .frame(maxWidth: .infinity)
            
                .padding()
            
            ScrollView(showsIndicators: false) {
                addressInputFields
                countryMenu
            }
            
            addDeliveryAddressButton
        }
        .padding()
    }
    
    // MARK: - Back button
    
    @ViewBuilder var backButton: some View {
        Button {
            viewModel.backButtonTapped()
        } label: {
            HStack {
                Image.Navigation.chevronLeft
                Text(GeneralStrings.back.localized)
            }
        }
    }
    
    // MARK: - Address input fields
    
    @ViewBuilder var addressInputFields: some View {
        
        TextFieldFloatingWithBorder(AddressStrings.line1.localized, text: $viewModel.addressLine1Text, hasWarning: .constant(viewModel.addressLine1HasWarning))
        
        TextFieldFloatingWithBorder(AddressStrings.line2.localized, text: $viewModel.addressLine2Text)
        
        TextFieldFloatingWithBorder(AddressStrings.city.localized, text: $viewModel.cityText, hasWarning: .constant(viewModel.cityHasWarning))
        
        TextFieldFloatingWithBorder(AddressStrings.county.localized, text: $viewModel.countyText)
        
        TextFieldFloatingWithBorder(AddressStrings.postcode.localized, text: $viewModel.postcodeText, hasWarning: .constant(viewModel.postcodeHasWarning))
    }
    
    // MARK: - Country selection menu
    
    @ViewBuilder var countryMenu: some View {
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
                    isDisabled: true)
                
                Image.Navigation.chevronDown
                    .foregroundColor(.gray)
                    .padding(.trailing, Constants.CountryDropDown.iconPadding)
                    .padding(.top, Constants.CountryDropDown.iconPadding)
            }
        }
    }
    
    // MARK: - Add delivery address button
    
    @ViewBuilder var addDeliveryAddressButton: some View {
        Button {
            viewModel.addDeliveryAddressTapped()
            self.didSelectAddress(viewModel.selectedAddress)
        } label: {
            HStack {
                Text(Strings.PostCodeSearch.addDeliveryAddress.localized)
                    .font(Font.snappyHeadline)
                
                Image.Navigation.forwardArrow
            }
        }
        .buttonStyle(SnappyMainActionButtonStyle(isEnabled: true))
    }
}


struct AddressSearchView_Previews: PreviewProvider {
    
    static var previews: some View {
        AddressSearchView(viewModel: AddressSearchViewModel(container: DIContainer.preview), didSelectAddress: { address in
            print("Address")
        })
    }
}
