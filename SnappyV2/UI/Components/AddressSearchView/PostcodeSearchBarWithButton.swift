//
//  PostcodeSearchBarWithButton.swift
//  SnappyV2
//
//  Created by David Bage on 08/02/2022.
//

#warning("Component to be deprecated. Will be removed once member area flow has been addressed")
import SwiftUI

struct PostcodeSearchBarWithButton: View {
    
    struct Constants {
        struct FindAddressButton {
            static let trailingPadding: CGFloat = 2
            static let topPadding: CGFloat = 8
            static let width: CGFloat = 70
        }
    }
    
    @ObservedObject var viewModel: AddressSearchViewModel
    
    var body: some View {
        
        SnappyTextFieldWithButton(
            container: viewModel.container,
            text: $viewModel.searchText,
            hasError: .constant(false),
            isLoading: .constant(false),
            labelText: "Postcode", // No need to localize as component to be removed
            largeLabelText: nil,
            mainButton: ("Find", viewModel.findTapped))  // No need to localize as component to be removed
    }
    
    @ViewBuilder var internalButton: some View {
        
        Button(action: {
            viewModel.findTapped()
        }, label: {
            Text(Strings.PostCodeSearch.findButton.localized)
        })
            .buttonStyle(SnappyPrimaryButtonStyle(isEnabled: viewModel.findButtonEnabled))
            .frame(width: Constants.FindAddressButton.width)
            .padding(.trailing, Constants.FindAddressButton.trailingPadding)
            .padding(.top, Constants.FindAddressButton.topPadding)
            .disabled(!viewModel.findButtonEnabled)
    }
}

#if DEBUG
struct PostcodeSearchBarWithButton_Previews: PreviewProvider {
    
    static var previews: some View {
        PostcodeSearchBarWithButton(viewModel: AddressSearchViewModel(container: .preview, type: .delivery))
    }
}
#endif
