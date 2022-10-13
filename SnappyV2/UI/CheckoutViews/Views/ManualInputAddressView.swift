//
//  ManualInputAddressView.swift
//  SnappyV2
//
//  Created by David Bage on 26/07/2022.
//

import SwiftUI

struct ManualInputAddressView: View {
    typealias AddressStrings = Strings.PostCodeSearch.Address
    
    // MARK: - Environment objects
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.presentationMode) var presentation
    
    // MARK: - Constants
    
    private struct Constants {
        static let vSpacing: CGFloat = 25
    }
    
    // MARK: - View Model
    @StateObject var viewModel: ManualInputAddressViewModel
    
    // MARK: - Colours
    private var colorPalette: ColorPalette {
        ColorPalette(container: viewModel.container, colorScheme: colorScheme)
    }
    
    let addressSaved: () -> ()
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: Constants.vSpacing) {
                SnappyTextfield(
                    container: viewModel.container,
                    text: $viewModel.addressNickname,
                    hasError: $viewModel.addressNicknameHasError,
                    labelText: AddressStrings.nickname.localized,
                    largeTextLabelText: nil)
                
                SnappyTextfield(
                    container: viewModel.container,
                    text: $viewModel.addressLine1,
                    hasError: $viewModel.addressLine1HasError,
                    labelText: AddressStrings.line1.localized,
                    largeTextLabelText: nil)
                
                SnappyTextfield(
                    container: viewModel.container,
                    text: $viewModel.addressLine2,
                    hasError: .constant(false),
                    labelText: AddressStrings.line2.localized,
                    largeTextLabelText: nil)
                
                SnappyTextfield(
                    container: viewModel.container,
                    text: $viewModel.town,
                    hasError: $viewModel.townHasError,
                    labelText: AddressStrings.city.localized,
                    largeTextLabelText: nil)
                
                SnappyTextfield(
                    container: viewModel.container,
                    text: $viewModel.county,
                    hasError: .constant(false),
                    labelText: AddressStrings.county.localized,
                    largeTextLabelText: nil)
                
                SnappyTextfield(
                    container: viewModel.container,
                    text: $viewModel.postcode,
                    hasError: $viewModel.postcodeHasError,
                    labelText: AddressStrings.postcode.localized,
                    largeTextLabelText: nil)
                
                CountrySelector(
                    viewModel: .init(
                        container: viewModel.container,
                        starterCountryCode: viewModel.address?.countryCode,
                        countrySelected: { country in
                            viewModel.countrySelected(country)
                        })
                )
                
                if viewModel.showDefaultToggle {
                    defaultToggle
                }
            }
            .fixedSize(horizontal: false, vertical: true)
            .padding()
            .padding(.top)
        }
        
        Spacer()
        
        SnappyButton(
            container: viewModel.container,
            type: .primary,
            size: .large,
            title: viewModel.viewState.submitButtonText,
            largeTextTitle: nil,
            icon: nil,
            isLoading: $viewModel.savingAddress) {
                Task {
                    await viewModel.saveAddressTapped(addressSaved: addressSaved)
                }
            }
            .padding()
//            .withAlertToast(container: viewModel.container, error: $viewModel.error)
            .dismissableNavBar(
                presentation: presentation,
                color: colorPalette.primaryBlue,
                title: viewModel.viewState.navigationTitle,
                navigationDismissType: viewModel.viewState.dismissType,
                backButtonAction: nil)
            .frame(maxHeight: .infinity)
            .background(colorPalette.backgroundMain.ignoresSafeArea(edges: .bottom))
    }
    
    private var defaultToggle: some View {
        Toggle(isOn: $viewModel.isDefaultAddress) {
            Text(AddressStrings.setDefaultPrompt.localized)
                .font(.Body1.regular())
                .foregroundColor(colorPalette.typefacePrimary)
        }
    }
}

#if DEBUG
struct ManualInputAddressView_Previews: PreviewProvider {
    static var previews: some View {
        ManualInputAddressView(viewModel: .init(container: .preview, address: FoundAddress(
            addressLine1: "10 Downing Street",
            addressLine2: "",
            town: "London",
            postcode: "SW1 1EP",
            countryCode: "UK",
            county: "",
            addressLineSingle: "").mapToAddress(type: .delivery), addressType: .delivery, viewState: .addAddress), addressSaved: {})
    }
}
#endif
