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
    
    @Published var hasStore = false
    var cancellables = Set<AnyCancellable>()
    
    init(container: DIContainer) {
        self.postcode = ""
        self.container = container
    }
    
    func searchLocalStoresPressed() {
        container.appState.value.routing.showInitialView = false
    }
    
    func tapLoadRetailStores() {
        let publisher = container.services.retailStoresService.searchRetailStores(postcode: "DD1 3JA")
        
        publisher
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    print("** error \(error) **")
                } else {
                    print("** concluded **")
                }
            }, receiveValue: { (found: Bool) in
                print(found)
            })
            .store(in: &cancellables)
    }
}
