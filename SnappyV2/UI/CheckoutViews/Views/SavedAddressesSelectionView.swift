//
//  SavedAddressesSelectionView.swift
//  SnappyV2
//
//  Created by David Bage on 08/07/2022.
//

import SwiftUI

struct SavedAddressesSelectionView: View {
    
    // MARK: - Environment objects
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.presentationMode) var presentation
    
    // MARK: - Constants
    struct Constants {
        struct Main {
            static let vSpacing: CGFloat = 24
        }
        
        struct SavedAddresses {
            static let spacing: CGFloat = 16
        }
    }
    
    // MARK: - View model
    @StateObject var viewModel: SavedAddressesSelectionViewModel
    
    // MARK: - Colors
    private var colorPalette: ColorPalette {
        ColorPalette(container: viewModel.container, colorScheme: colorScheme)
    }
    
    let didSetAddress: (FoundAddress) -> ()
    
    // MARK: - Main content
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                Divider()
                ScrollView(showsIndicators: false) {
                    VStack(spacing: Constants.Main.vSpacing) {
                        Text(viewModel.title)
                            .font(.heading4())
                            .foregroundColor(colorPalette.primaryBlue)
                        
                        savedAddresses
                        
                        setAsAddressButton
                    }
                    .padding(.vertical, Constants.Main.vSpacing)
                    .background(colorPalette.secondaryWhite)
                    .standardCardFormat(container: viewModel.container)
                    .padding()
                    .dismissableNavBar(
                        presentation: presentation,
                        color: colorPalette.primaryBlue,
                        title: viewModel.navTitle,
                        navigationDismissType: .close,
                        backButtonAction: nil)
                }
                .background(colorPalette.backgroundMain)
            }
        }
    }
    
    // MARK: - Saved addresses stack
    private var savedAddresses: some View {
        VStack(spacing: Constants.SavedAddresses.spacing) {
            ForEach(viewModel.addresses, id: \.id) { address in
                Button {
                    viewModel.selectAddress(address)
                } label: {
                    AddressDisplayCard(viewModel: .init(container: viewModel.container, address: address), isSelected: .constant(viewModel.selectedAddress?.id == address.id))
                }
            }
        }
        .padding(.horizontal)
    }
    
    // MARK: - Set delivery address button
    private var setAsAddressButton: some View {
        SnappyButton(
            container: viewModel.container,
            type: .primary,
            size: .large,
            title: viewModel.buttonTitle,
            largeTextTitle: nil,
            icon: nil,
            isEnabled: .constant(true),
            isLoading: $viewModel.settingDeliveryAddress) {
                Task {
                    await viewModel.setAddress(address: viewModel.selectedAddress,
                                               didSetAddress: { address in
                        didSetAddress(address)
                    })
                }
            }
            .padding(.horizontal)
    }
}

#if DEBUG
struct SavedAddressesSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        SavedAddressesSelectionView(viewModel: .init(container: .preview, savedAddressType: .delivery, addresses: [
            Address(
                id: nil,
                isDefault: true,
                addressName: "Home",
                firstName: "Dave",
                lastName: "Bage",
                addressLine1: "38 Address Line 1",
                addressLine2: "Address Line 2",
                town: "Fakesville",
                postcode: "FAK AD1",
                county: "Surrey",
                countryCode: "UK",
                type: .delivery, location: nil, email: nil, telephone: nil),
            Address(
                id: nil,
                isDefault: false,
                addressName: "Home",
                firstName: "Dave",
                lastName: "Bage",
                addressLine1: "38 Address Line 1",
                addressLine2: "Address Line 2",
                town: "Fakesville",
                postcode: "FAK AD1",
                county: "Surrey",
                countryCode: "UK",
                type: .delivery, location: nil, email: nil, telephone: nil),
            Address(
                id: nil,
                isDefault: false,
                addressName: "Home",
                firstName: "Dave",
                lastName: "Bage",
                addressLine1: "38 Address Line 1",
                addressLine2: "Address Line 2",
                town: "Fakesville",
                postcode: "FAK AD1",
                county: "Surrey",
                countryCode: "UK",
                type: .delivery, location: nil, email: nil, telephone: nil)
        ], email: "djjd@xlk.com", phone: "123456"), didSetAddress: {_ in })
    }
}
#endif
