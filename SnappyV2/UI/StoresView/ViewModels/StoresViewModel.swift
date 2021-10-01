//
//  StoresViewModel.swift
//  SnappyV2
//
//  Created by Henrik Gustavii on 27/09/2021.
//

import Combine

class StoresViewModel: ObservableObject {
    let container: DIContainer
    @Published var postcodeSearchString: String
    @Published var isDeliverySelected = false
    @Published var emailToNotify = ""
    
    @Published var storeSearchResult: Loadable<RetailStoresSearch>?
    @Published var retailStores: [RetailStore]?
    @Published var retailStoreTypes: [RetailStoreProductType]?
    
    var hasReturnedResult: Bool = false
    private var cancellables = Set<AnyCancellable>()
    
    init(container: DIContainer, storeSearchResult: Loadable<RetailStoresSearch> = .notRequested) {
        self.container = container
        let appState = container.appState
        
        self.postcodeSearchString = appState.value.userData.postcodeSearch
        _storeSearchResult = .init(initialValue: appState.value.userData.searchResult)
        
        // Binding to postcodeSearch in AppState
        $postcodeSearchString
            .sink { appState.value.userData.postcodeSearch = $0 }
            .store(in: &cancellables)
        
        appState
            .map(\.userData.postcodeSearch)
            .removeDuplicates()
            .assignWeak(to: \.postcodeSearchString, on: self)
            .store(in: &cancellables)
        
        appState
            .map(\.userData.searchResult)
            .removeDuplicates()
            .assignWeak(to: \.storeSearchResult, on: self)
            .store(in: &cancellables)
        
        $storeSearchResult
            .map { value in
                value?.value?.stores
            }
            .assignWeak(to: \.retailStores, on: self)
            .store(in: &cancellables)
        
        $storeSearchResult
            .map { value in
                value?.value?.storeProductTypes
            }
            .assignWeak(to: \.retailStoreTypes, on: self)
            .store(in: &cancellables)
        
        // Temporary sub to demonstrate view change
        $postcodeSearchString
            .sink { value in
                self.hasReturnedResult = value.isEmpty == false
            }
            .store(in: &cancellables)
        
        initialSearch()
    }
    
    func sendNotificationEmail() {
        // send email address to server
    }
    
    func initialSearch() {
        if postcodeSearchString.isEmpty == false {
            
        }
    }
}
