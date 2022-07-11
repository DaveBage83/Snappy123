//
//  AddressSelectionView.swift
//  SnappyV2
//
//  Created by David Bage on 07/07/2022.
//

import SwiftUI

struct AddressSelectionView: View {
    
    // MARK: - Environment objects
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.presentationMode) var presentation
    
    // MARK: - Constants {
    struct Constants {
        struct AddressRow {
            static let spacing: CGFloat = 10
            static let lineLimit = 1
            static let vPadding: CGFloat = 8
        }
        
        struct SelectAddressButton {
            static let width: CGFloat = 85
        }
    }

    // MARK: - State object
    @StateObject var viewModel: AddressSelectionViewModel
        
    // MARK: - Colors
    private var colorPalette: ColorPalette {
        ColorPalette(container: viewModel.container, colorScheme: colorScheme)
    }
        
    // MARK: - Main content
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                Divider()
                
                VStack(alignment: .leading) {
                    
                   findByPostcodeButton
                    
                    ScrollView(showsIndicators: false) {
                        ForEach(viewModel.addresses, id: \.self) { address in
                            HStack(spacing: Constants.AddressRow.spacing) {
                                Text(address.addressLineSingle)
                                    .font(.Body2.regular())
                                    .foregroundColor(colorPalette.typefacePrimary.withOpacity(.eighty))
                                    .lineLimit(Constants.AddressRow.lineLimit)
                                
                                Spacer()
                                
                                selectAddressButton(address)
                            }
                            .padding(.vertical, Constants.AddressRow.vPadding)
                            Divider()
                        }
                    }
                }
                .padding()
                .background(colorPalette.backgroundMain)
                .dismissableNavBar(
                    presentation: presentation,
                    color: colorPalette.primaryBlue,
                    title: Strings.CheckoutDetails.AddressSelectionView.navTitle.localized,
                    navigationDismissType: .close,
                backButtonAction: nil)
            }
        }
        .withStandardAlert(
            container: viewModel.container,
            isPresenting: $viewModel.showDeliveryAddressSetterError,
            type: .error,
            title: Strings.CheckoutDetails.AddressSelectionView.addressErrorTitle.localized,
            subtitle: viewModel.addressSetterError ?? Strings.CheckoutDetails.AddressSelectionView.addressErrorGeneric.localized)
    }
    
    // MARK: - Find button
    private var findByPostcodeButton: some View {
        SnappyTextFieldWithButton(
            container: viewModel.container,
            text: $viewModel.postcode,
            hasError: $viewModel.postcodeHasError,
            isLoading: .constant(false),
            labelText: Strings.CheckoutDetails.EditAddress.postcode.localized,
            largeLabelText: nil,
            mainButton: (Strings.CheckoutDetails.EditAddress.findButton.localized, {}))
        .fixedSize(horizontal: false, vertical: true)
        .padding(.bottom)
    }
    
    private func selectAddressButton(_ address: FoundAddress) -> some View {
        SnappyButton(
            container: viewModel.container,
            type: .outline,
            size: .medium,
            title: Strings.CheckoutDetails.AddressSelectionView.select.localized,
            largeTextTitle: nil,
            icon: Image.Icons.Plus.standard,
            isLoading: .constant(viewModel.settingDeliveryAddress && viewModel.selectedAddress?.id == address.id),
            action: {
                Task {
                    await viewModel.setDelivery(address: address)
                }
            })
        .frame(width: Constants.SelectAddressButton.width)
    }
}

#if DEBUG
struct AddressSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        AddressSelectionView(viewModel: .init(
            container: .preview, addressSelectionType: .delivery,
            addresses: [
            FoundAddress(
                addressLine1: "First Line",
                addressLine2: "Second Line",
                town: "Town Name",
                postcode: "TOWN1EE",
                countryCode: "UK",
                county: "Surrey",
                addressLineSingle: "First Line, Second Line, Town Name, TOWN1EE")
            ],
            showAddressSelectionView: .constant(true),
            firstName: "Dave",
            lastName: "Bage",
            email: "davebage@dave.com",
            phone: "09987667655"))
    }
}
#endif
