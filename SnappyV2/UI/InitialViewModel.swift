//
//  InitialViewModel.swift
//  SnappyV2
//
//  Created by Henrik Gustavii on 16/09/2021.
//

import Combine
import SwiftUI

class InitialViewModel: ObservableObject {
    let container: DIContainer
    
    @Published var postcode: String
    
    @Published var loginButtonPressed = false
    
    @Binding var viewState: ViewState
    
    let repo = RetailStoreWebRepository()
    @Published var hasStore = false
    var cancellables = Set<AnyCancellable>()
    
    init(container: DIContainer, viewState: Binding<ViewState>) {
        self.postcode = ""
        self._viewState = viewState
        self.container = container
    }
    
    func searchLocalStoresPressed() {
        viewState = .root
    }
    
    func tapLoadRetailStores() {
        let publisher = repo.loadRetailStores()
        
        publisher
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    print("** error \(error) **")
                } else {
                    print("** concluded **")
                }
            }, receiveValue: { (data: RetailStoreResult) in
                print(data)
            })
            .store(in: &cancellables)
    }
}
