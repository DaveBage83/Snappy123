//
//  PostcodeSearchBarContainer.swift
//  SnappyV2
//
//  Created by David Bage on 08/02/2022.
//

import SwiftUI

struct PostcodeSearchBarContainer: View {
    struct Constants {
        struct AddressCard {
            static let addressBottomPadding: CGFloat = 3
            static let cornerRadius: CGFloat = 8
            static let borderWidth: CGFloat = 1
        }
    }
    
    @StateObject var viewModel: AddressSearchViewModel
    
    let didSelectAddress: (Address?) -> Void
    
    var body: some View {
        switch viewModel.rootViewState {
        case .addressCard(let address):
            addressCard(address: address)
        case .postcodeSearchBar:
            postCodeSearchBar
        }
    }
    
    private var postCodeSearchBar: some View {
        VStack {
            PostcodeSearchBarWithButton(viewModel: viewModel)
            
            Text(Strings.PostCodeSearch.initialPrompt.localized)
                .font(Font.snappyBody)
                .foregroundColor(.snappyTextGrey1)
                .fontWeight(.medium)
        }
        .padding()
        .sheet(isPresented: $viewModel.isAddressSelectionViewPresented) {
            viewModel.viewDismissed()
        } content: {
            AddressSearchView(viewModel: viewModel, didSelectAddress: { address in
                self.didSelectAddress(address)
            })
        }
    }
    
    private func addressCard(address: Address) -> some View {
        VStack(alignment: .leading) {
            Text("\(address.firstName) \(address.lastName)")
                .font(.snappyBody)
                .fontWeight(.semibold)
                .foregroundColor(.snappyTextGrey1)
                .padding(.bottom, Constants.AddressCard.addressBottomPadding)
            Text(address.singleLineAddress())
                .font(.snappyBody)
                .fontWeight(.regular)
                .foregroundColor(.snappyTextGrey1)
                .padding(.bottom, Constants.AddressCard.addressBottomPadding)
            HStack {
                Text(GeneralStrings.edit.localized.uppercased())
                    .font(.snappyBody)
                    .fontWeight(.bold)
                    .foregroundColor(.snappyTextGrey1)
                Image.Navigation.chevronRight
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: Constants.AddressCard.cornerRadius)
                .strokeBorder(Color.snappyBlue, lineWidth: Constants.AddressCard.borderWidth)
        )
        .onTapGesture {
            viewModel.editAddressTapped(address: address)
        }
        .sheet(isPresented: $viewModel.isAddressSelectionViewPresented) {
            viewModel.viewDismissed()
        } content: {
            AddressSearchView(viewModel: viewModel, didSelectAddress: { address in
                self.didSelectAddress(address)
            })
        }
    }
}

struct InitialPostCodeSearchView_Previews: PreviewProvider {
    
    static var previews: some View {
        PostcodeSearchBarContainer(viewModel: AddressSearchViewModel(container: .preview), didSelectAddress: { address in
            print("Address")
        })
            .previewCases()
    }
}
