//
//  PostcodeSearchBarWithButton.swift
//  SnappyV2
//
//  Created by David Bage on 08/02/2022.
//

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
        
        ZStack(alignment: .trailing) {
            TextFieldFloatingWithBorder(
                Strings.PostCodeSearch.enterPostCode.localized,
                text: $viewModel.searchText)
                .autocapitalization(.allCharacters)
            internalButton
        }
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
