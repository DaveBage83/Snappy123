//
//  NavigationBarView.swift
//  SnappyV2
//
//  Created by Henrik Gustavii on 01/12/2021.
//

import SwiftUI

class NavigationBarViewModel: ObservableObject {
    let container: DIContainer
    @Published var selectedStore: Loadable<RetailStoreDetails> = .notRequested
    @Published var selectedFulfilmentMethod: RetailStoreOrderMethodType
    
    init(container: DIContainer) {
        self.container = container
        let appState = container.appState
        
        self.selectedStore = appState.value.userData.selectedStore
        self.selectedFulfilmentMethod = appState.value.userData.selectedFulfilmentMethod
    }
    
    func navigateToStoreSelection() {
        container.appState.value.routing.selectedTab = 1
    }
}

struct NavigationBarView: View {
    @StateObject var viewModel: NavigationBarViewModel
    let backButtonAction: (() -> Void)?
    let title: String?
    
    init(container: DIContainer, title: String?, backButtonAction: (() -> Void)?) {
        self._viewModel = StateObject(wrappedValue: NavigationBarViewModel(container: container))
        self.title = title
        self.backButtonAction = backButtonAction
    }
    
    var body: some View {
        HStack(alignment: .center) {
            if let backAction = backButtonAction {
                Button(action: backAction ) {
                    Image(systemName: "chevron.left")
                        .font(.title2)
                        .foregroundColor(.black)
                }
            }
            
            if let title = title {
                Text(title)
                    .font(.snappyBody)
                    .fontWeight(.semibold)
            }
            
            Spacer()
            
            Button(action: { viewModel.navigateToStoreSelection() }) {
                VStack {
                    Text(viewModel.selectedFulfilmentMethod.rawValue.capitalizingFirstLetter())
                        .font(.snappyFootnote)
                        .foregroundColor(.black)
                    
                    if let postcode = viewModel.selectedStore.value?.searchPostcode {
                        Text(postcode)
                            .font(.snappySubheadline)
                            .foregroundColor(.black)
                    }
                }
                
                Image(systemName: "car")
                    .font(.title2)
                    .foregroundColor(.black)
                
                if let logo = viewModel.selectedStore.value?.storeLogo?["xhdpi_2x"]?.absoluteString {
                    RemoteImage(url: logo)
                        .scaledToFit()
                } else {
                    Image("default_large_logo")
                        .resizable()
                        .scaledToFit()
                }
            }
        }
        .frame(height: 44)
        .padding()
    }
}

struct NavigationBarView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationBarView(container: .preview, title: "Stores", backButtonAction: {})
            .previewLayout(.sizeThatFits)
    }
}
