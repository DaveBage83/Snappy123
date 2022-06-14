//
//  ManualAddressInputView.swift
//  SnappyV2
//
//  Created by David Bage on 15/04/2022.
//

import SwiftUI

struct ManualAddressInputView: View {
    typealias AddressStrings = Strings.PostCodeSearch.Address
    
    struct Constants {
        struct ButtonStack {
            static let padding: CGFloat = 13
            static let buttonSpacing: CGFloat = 10
        }
        
        struct CountryDropDown {
            static let iconPadding: CGFloat = 5
        }
        
        struct ToPostcodeSearchButton {
            static let additionalPadding: CGFloat = 2
        }
        
        struct DefaultButton {
            static let size: CGFloat = 20
        }
        
        struct Main {
            static let padding: CGFloat = 25
        }
        
        struct AddressInputFields {
            static let spacing: CGFloat = 15
        }
    }
    
    var didSelectAddress: (Address?) -> ()
    
    @ObservedObject var viewModel: AddressSearchViewModel
    
    var body: some View {
        VStack {
            HStack {
                Spacer()
                cancelButton
            }
            
            Text(viewModel.manualAddressTitle)
                .font(Font.snappyHeadline)
                .fontWeight(.semibold)
                .foregroundColor(.snappyBlue)
                .frame(maxWidth: .infinity)
            
            ScrollView(showsIndicators: false) {
                VStack {
                    VStack(alignment: .leading) {
                        addressInputFields
                        
                        if viewModel.showSetAddressToDefaultCheckbox {
                            defaultSelectionButton
                        }
                    }
                    .padding(.bottom)
                    
                    Spacer()
                    
                    VStack {
                        toPostcodeSearchButton
                            .padding(.bottom, Constants.ButtonStack.buttonSpacing)
                        addAddressButton
                    }
                }
            }
        }
        .padding(.horizontal, Constants.Main.padding)
        .padding(.vertical)
    }
    
    // MARK: - Subview: Set as default button view
    
    var defaultSelectionButton: some View {
        HStack {
            Button {
                viewModel.setAddressToDefaultTapped()
            } label: {
                (viewModel.isDefaultAddressSelected ? Image.General.Checkbox.checked : Image.General.Checkbox.unChecked)
                    .foregroundColor(.snappyBlue)
                    .font(.system(size: Constants.DefaultButton.size))
            }
            Text(AddressStrings.setDefaultPrompt.localized)
                .font(.snappyCaption)
        }
    }
    
    // MARK: - Address fields stack
    
    var addressInputFields: some View {
        
        VStack(spacing: Constants.AddressInputFields.spacing) {
            if viewModel.showAddressNickname {
                VStack(alignment: .leading) {
                    TextFieldFloatingWithBorder(AddressStrings.nickname.localized, text: $viewModel.addressNicknameText)
                    Text(AddressStrings.nicknamePrompt.localized)
                        .font(.snappyCaption)
                        .foregroundColor(.snappyGrey)
                }
            }
            
            HStack {
                TextFieldFloatingWithBorder(AddressStrings.firstName.localized, text: $viewModel.firstNameText, hasWarning: .constant(viewModel.firstNameHasWarning))
                
                TextFieldFloatingWithBorder(AddressStrings.lastName.localized, text: $viewModel.lastNameText, hasWarning: .constant(viewModel.lastNameHasWarning))
            }
            
            TextFieldFloatingWithBorder(AddressStrings.line1.localized, text: $viewModel.addressLine1Text, hasWarning: .constant(viewModel.addressLine1HasWarning))
            
            TextFieldFloatingWithBorder(AddressStrings.line2.localized, text: $viewModel.addressLine2Text)
            
            TextFieldFloatingWithBorder(AddressStrings.city.localized, text: $viewModel.townText, hasWarning: .constant(viewModel.cityHasWarning))
            
            TextFieldFloatingWithBorder(AddressStrings.county.localized, text: $viewModel.countyText)
            
            TextFieldFloatingWithBorder(AddressStrings.postcode.localized, text: $viewModel.postcodeText, hasWarning: .constant(viewModel.postcodeHasWarning))
            
            countryMenu
                .padding(.bottom, Constants.ButtonStack.padding)
        }
    }
    
    // MARK: - Country selection dropdown
    
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
    
    // MARK: - Cancel button
    
    private var cancelButton: some View {
        Button {
            viewModel.cancelButtonTapped()
        } label: {
            Text(GeneralStrings.cancel.localized)
        }
    }
    
    // MARK: - Return to postcode search view button
    
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
    }
    
    // MARK: - Add address button
    
    private var addAddressButton: some View {
        Button {
            viewModel.addAddressTapped(addressSetter: didSelectAddress)
            
        } label: {
            Text(viewModel.manualAddressButtonTitle)
                .font(Font.snappyHeadline)
                .frame(maxWidth: .infinity)
                .padding(.vertical, Constants.ToPostcodeSearchButton.additionalPadding)
        }
        .buttonStyle(SnappyPrimaryButtonStyle())
    }
}

#if DEBUG
struct ManualAddressInputView_Previews: PreviewProvider {
    static var previews: some View {
        ManualAddressInputView(didSelectAddress: { address in
            print("Address selected")
        }, viewModel: .init(container: .preview, type: .delivery))
    }
}
#endif
