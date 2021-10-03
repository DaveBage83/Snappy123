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
    
    @Published var search: Loadable<RetailStoresSearch>
    @Published var details: Loadable<RetailStoreDetails>
    
    var cancellables = Set<AnyCancellable>()
    
    init(container: DIContainer, search: Loadable<RetailStoresSearch> = .notRequested, details: Loadable<RetailStoreDetails> = .notRequested) {
        self.postcode = ""
        self.container = container
        self.search = search
        self.details = details
    }
    
    func searchLocalStoresPressed() {
        container.appState.value.routing.showInitialView = false
    }
    
    func tapLoadRetailStores() {

//        let publisher = container.services.retailStoresService.clearLastSearch()
//        publisher
//            .sink(receiveCompletion: { completion in
//                if case .failure(let error) = completion {
//                    print("** error \(error) **")
//                } else {
//                    print("** concluded **")
//                }
//            }, receiveValue: { (found: Bool) in
//                print(found)
//            })
//            .store(in: &cancellables)
        
        
        //container.services.retailStoresService.searchRetailStores(search: loadableSubject(\.search), postcode: "DD1 3JA")
        container.services.retailStoresService.getStoreDetails(details: loadableSubject(\.details), storeId: 30, postcode: "DD1 3JA")

// old search style fetch prior to embracing loadables
//        let publisher = container.services.retailStoresService.searchRetailStores(postcode: "DD1 3JA")
//
//        publisher
//            .sink(receiveCompletion: { completion in
//                if case .failure(let error) = completion {
//                    print("** error \(error) **")
//                } else {
//                    print("** concluded **")
//                }
//            }, receiveValue: { (found: Bool) in
//                print(found)
//            })
//            .store(in: &cancellables)
    }
}
