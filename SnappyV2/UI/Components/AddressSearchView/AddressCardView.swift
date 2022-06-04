//
//  AddressCardView.swift
//  SnappyV2
//
//  Created by David Bage on 15/04/2022.
//

import SwiftUI

struct AddressCardView: View {
    struct Constants {
        static let addressBottomPadding: CGFloat = 3
        static let cornerRadius: CGFloat = 8
        static let borderWidth: CGFloat = 1
        static let buttonSpacing: CGFloat = 20
        static let hSpacing: CGFloat = 20
        static let buttonStackSpacing: CGFloat = 4
        static let deleteDisabledOpacity: CGFloat = 0.5
    }
    
    @StateObject var viewModel: AddressCardViewModel
    @ObservedObject var addressSearchViewModel: AddressSearchViewModel
    
    let address: Address
    let didSelectAddress: (Address?) -> Void

    var body: some View {
        VStack(alignment: .leading) {
            HStack(spacing: Constants.hSpacing) {
                addressStack
                    .onTapGesture {
                        addressSearchViewModel.editAddressTapped(address: address)
                    }
                if addressSearchViewModel.allowAdmin {
                    buttonsStack
                }
            }
        }
        .padding()
        .background(viewModel.isDefault ? Color.snappyBlue : Color.white)
        .clipShape(RoundedRectangle(cornerRadius: Constants.cornerRadius))
        .snappyShadow()
        .sheet(isPresented: $addressSearchViewModel.isAddressSelectionViewPresented) {
            addressSearchViewModel.viewDismissed()
        } content: {
            AddressSearchView(viewModel: addressSearchViewModel, didSelectAddress: { address in
                self.didSelectAddress(address)
            })
        }
    }
    
    // MARK: - Main address display
    var addressStack: some View {
        VStack(alignment: .leading) {
            if let addressName = address.addressName, !addressName.isEmpty {
                Text(addressName)
                    .font(.snappyBody)
                    .fontWeight(.semibold)
                    .foregroundColor(viewModel.isDefault ? .white : .snappyTextGrey1)
                    .padding(.bottom, Constants.addressBottomPadding)
            }
            Text("\(address.firstName ?? "") \(address.lastName ?? "")")
                .font(.snappyBody)
                .fontWeight(.semibold)
                .foregroundColor(viewModel.isDefault ? .white : .snappyTextGrey1)
                .padding(.bottom, Constants.addressBottomPadding)
            Text(address.singleLineAddress())
                .font(.snappyBody)
                .fontWeight(.regular)
                .foregroundColor(viewModel.isDefault ? .white : .snappyTextGrey1)
                .padding(.bottom, Constants.addressBottomPadding)

            HStack {
                Text(GeneralStrings.edit.localized.uppercased())
                    .font(.snappyBody)
                    .fontWeight(.bold)
                    .foregroundColor(viewModel.isDefault ? .white : .snappyTextGrey1)
                Image.Navigation.chevronRight
                    .foregroundColor(viewModel.isDefault ? .white : .snappyTextGrey1)
                Spacer()
            }
            .frame(maxWidth: .infinity)
        }
    }
    
    // MARK: - Admin buttons - only available when user is signed in
    var buttonsStack: some View {
        VStack(spacing: Constants.buttonSpacing) {
            Button {
                Task {
                    await viewModel.setAddressToDefault()
                }
            } label: {
                VStack(spacing: Constants.buttonStackSpacing) {
                    (viewModel.isDefault ? Image.General.Checkbox.checked : Image.General.Checkbox.unChecked)
                        .foregroundColor(viewModel.isDefault ? .white : .snappyBlue)
                    Text(GeneralStrings.defaultCase.localized)
                        .font(.snappyCaption)
                        .foregroundColor(viewModel.isDefault ? .white : .snappyBlue)
                        .fontWeight(.semibold)
                }
            }
            .disabled(viewModel.isDefault)
            
            Button {
                Task {
                    await viewModel.deleteAddress()
                }
            } label: {
                (viewModel.allowDelete ? Image.General.delete : Image.General.noDelete)
                    .foregroundColor(viewModel.isDefault ? .white.opacity(Constants.deleteDisabledOpacity) : .snappyBlue)
            }
            .disabled(viewModel.isDefault)
        }
    }
}

#if DEBUG
struct AddressCardView_Previews: PreviewProvider {
    static var previews: some View {
        AddressCardView(viewModel: .init(container: .preview, address: Address(id: nil, isDefault: true, addressName: "Dave Home", firstName: "Dave", lastName: "Bage", addressLine1: "39 Snappy Towers", addressLine2: "", town: "Snappytown", postcode: "SNA PPY", county: "UK", countryCode: "UK", type: .delivery, location: nil, email: nil, telephone: nil)), addressSearchViewModel: .init(container: .preview, type: .delivery), address: Address(id: nil, isDefault: true, addressName: "Dave Home", firstName: "Dave", lastName: "Bage", addressLine1: "39 Snappy Towers", addressLine2: "", town: "Snappytown", postcode: "SNA PPY", county: "UK", countryCode: "UK", type: .delivery, location: nil, email: nil, telephone: nil), didSelectAddress: { address in
            print("Address selected")
        })
    }
}
#endif
