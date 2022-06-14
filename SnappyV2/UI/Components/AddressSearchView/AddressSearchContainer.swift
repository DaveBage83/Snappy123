//
//  AddressSearchContainer.swift
//  SnappyV2
//
//  Created by David Bage on 15/04/2022.
//

import SwiftUI

struct AddressSearchContainer: View {
    
    struct Constants {
        
        struct Button {
            static let padding: CGFloat = 10
        }
    }
    
    @StateObject var viewModel: AddressSearchViewModel
    
    let didSelectAddress: (Address?) -> Void
    
    var body: some View {
        if viewModel.initialSearchActionType == .searchBar {
            switch viewModel.rootViewState {
            case .addressCard(let address):
                AddressCardView(viewModel: .init(container: viewModel.container, address: address), addressSearchViewModel: viewModel, address: address) { address in
                    didSelectAddress(address)
                }
                
            case .postcodeSearchBar:
                postcodeSearchTriggerView
            }
        } else {
            postcodeSearchTriggerView
        }
    }
    
    // MARK: - Controls the initial view that is displayed to launch the search functionality (either button or textfield)
    
    private var postcodeSearchTriggerView: some View {
        VStack {
            if viewModel.initialSearchActionType == .searchBar {
                PostcodeSearchBarWithButton(viewModel: viewModel)
                
                Text(Strings.PostCodeSearch.initialPrompt.localized)
                    .font(Font.snappyBody)
                    .foregroundColor(.snappyTextGrey1)
                    .fontWeight(.medium)
            } else {
                Button {
                    viewModel.initialAddAddressButtonTapped()
                } label: {
                    Text(viewModel.buttonText)
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .font(.snappyBody)
                        .padding(Constants.Button.padding)
                }
                .buttonStyle(SnappyPrimaryButtonStyle())
            }
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

#if DEBUG
struct InitialPostCodeSearchView_Previews: PreviewProvider {

    static var previews: some View {
        AddressSearchContainer(viewModel: AddressSearchViewModel(container: .preview, type: .delivery, initialSearchActionType: .button), didSelectAddress: { address in
            print("Address")
        })
        .previewCases()
    }
}
#endif
