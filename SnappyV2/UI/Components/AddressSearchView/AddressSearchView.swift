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
            static let hPadding: CGFloat = 15
        }
        
        struct SelectAddressButton {
            static let vPadding: CGFloat = 3
            static let hPadding: CGFloat = 5
        }
        
        struct ToManualAddress {
            static let backgroundColor = Color(UIColor.systemBackground.withAlphaComponent(0.95))
        }
        
        struct emptySearchView {
            static let imageSize: CGFloat = 70
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
            ManualAddressInputView(didSelectAddress: didSelectAddress, viewModel: viewModel)
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
            
            emptySearchView
            
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
    
    // MARK: -  Subview : Empty search results view
    
    @ViewBuilder var emptySearchView: some View {
        if viewModel.searchOutcomeState == .noAddressesFound {
            Text(Strings.PostCodeSearch.noAddressFound.localized)
                .font(.snappyHeadline)
                .foregroundColor(.snappyRed)
                .frame(maxHeight: .infinity)
        } else if viewModel.searchOutcomeState == .newSearch {
            HStack(alignment: .center) {
                Image.Actions.Search.address
                    .font(.system(size: Constants.emptySearchView.imageSize))
                    .foregroundColor(.snappyTextGrey3)
            }
            .frame(maxHeight: .infinity)
        }
    }
    
    // MARK: -  Subview : Navigation to manual input view
    
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
                    .frame(maxWidth: .infinity)
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
            HStack(spacing: Constants.AddressResultView.hPadding) {
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
                    addressLine1: address.addressLine1,
                    addressLine2: address.addressLine2,
                    town: address.town,
                    postcode: address.postcode,
                    county: address.county,
                    countryCode: address.countryCode,
                    type: viewModel.addressType,
                    location: nil,
                    email: nil,
                    telephone: nil))
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
}


struct AddressSearchView_Previews: PreviewProvider {
    
    static var previews: some View {
        AddressSearchView(viewModel: AddressSearchViewModel(container: DIContainer.preview, type: .delivery), didSelectAddress: { address in
            print("Address")
        })
        .previewCases()
    }
}
