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
            static let width: CGFloat = 60
        }
    }
    
    @ObservedObject var viewModel: AddressSearchViewModel
    
    var body: some View {
        
        ZStack(alignment: .trailing) {
            TextFieldFloatingWithBorder(
                Strings.PostCodeSearch.enterPostCode.localized,
                text: $viewModel.searchText)
            internalButton
        }
    }
    
    @ViewBuilder var internalButton: some View {
        
        Button(action: {
            viewModel.findTapped()
        }, label: {
            if viewModel.addressesAreLoading {
                ProgressView()
                    .foregroundColor(.white)
            } else {
                Text(Strings.PostCodeSearch.findButton.localized)
            }
        })
            .buttonStyle(SnappyPrimaryButtonStyle())
            .frame(width: Constants.FindAddressButton.width)
            .padding(.trailing, Constants.FindAddressButton.trailingPadding)
            .padding(.top, Constants.FindAddressButton.topPadding)
    }
}

struct PostcodeSearchBarWithButton_Previews: PreviewProvider {
    
    static var previews: some View {
        PostcodeSearchBarWithButton(viewModel: AddressSearchViewModel(container: .preview))
    }
}
