//
//  PostcodeSearchBarContainer.swift
//  SnappyV2
//
//  Created by David Bage on 08/02/2022.
//

import SwiftUI

struct PostcodeSearchBarContainer: View {
    struct Constants {
        struct Prompt {
            static let color = Color.black.opacity(0.6)
        }
    }
    
    @ObservedObject var viewModel: AddressSearchViewModel
    
    let didSelectAddress: (FoundAddress?) -> Void
    
    var body: some View {
        VStack {
            PostcodeSearchBarWithButton(viewModel: viewModel)
            
            Text(Strings.PostCodeSearch.initialPrompt.localized)
                .font(Font.snappyBody)
                .foregroundColor(Constants.Prompt.color)
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
}


struct InitialPostCodeSearchView_Previews: PreviewProvider {
    
    static var previews: some View {
        PostcodeSearchBarContainer(viewModel: AddressSearchViewModel(container: .preview), didSelectAddress: { address in
            print("Address")
        })
    }
}
