//
//  NavigationBarView.swift
//  SnappyV2
//
//  Created by Henrik Gustavii on 01/12/2021.
//

import SwiftUI
import Combine

class NavigationBarViewModel: ObservableObject {
    let container: DIContainer
    @Published var selectedStore: Loadable<RetailStoreDetails> = .notRequested
    @Published var selectedFulfilmentMethod: RetailStoreOrderMethodType
    
    var cancellables = Set<AnyCancellable>()
    
    init(container: DIContainer) {
        self.container = container
        let appState = container.appState
        
        _selectedStore = .init(initialValue: appState.value.userData.selectedStore)
        _selectedFulfilmentMethod = .init(initialValue: appState.value.userData.selectedFulfilmentMethod)
        
        setupSelectedStore(appState: appState)
    }
    
    #warning("Do we need a subscription?")
    func setupSelectedStore(appState: Store<AppState>) {
        appState
            .map(\.userData.selectedStore)
            .assignWeak(to: \.selectedStore, on: self)
            .store(in: &cancellables)
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
            
            VStack {
                Text("Delivery")
                    .font(.snappyFootnote)
                
                Text("DD1 3ED")
                    .font(.snappySubheadline)
            }
            
            Image(systemName: "car")
                .font(.title2)
            
            Image("default_large_logo")
                .resizable()
                .scaledToFit()
        }
        .frame(height: 44)
        .padding()
    }
}

struct NavigationBarView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationBarView(container: .preview, title: "Stores", backButtonAction: {})
//            .previewLayout(.sizeThatFits)
//            .padding()
    }
}
