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
    @Published var emailToNotify = ""
    @Published var selectedOrderMethod: RetailStoreOrderMethodName = .delivery
    
    @Published var storeSearchResult: Loadable<RetailStoresSearch>?
    @Published var retailStores = [RetailStore]()
    @Published var shownRetailStores: [RetailStore]?
    @Published var retailStoreTypes: [RetailStoreProductType]?
    @Published var selectedRetailStoreTypes = [Int]()
    
    var hasReturnedResult: Bool = false
    private var cancellables = Set<AnyCancellable>()
    
    init(container: DIContainer, storeSearchResult: Loadable<RetailStoresSearch> = .notRequested) {
        self.container = container
        let appState = container.appState
        
        self.postcodeSearchString = appState.value.userData.postcodeSearch
        _storeSearchResult = .init(initialValue: appState.value.userData.searchResult)
        
        setupBindToPostcodeSearchString(with: appState)
        
        setupBindToSearchStoreResult(with: appState)
        
        setupRetailStoreTypes()
        
        setupSelectedRetailStoreTypesANDIsDeliverySelected()
    }
    
    var isDeliverySelected: Bool {
        selectedOrderMethod == .delivery
    }
    
    func setupBindToPostcodeSearchString(with appState: Store<AppState>) {
        $postcodeSearchString
            .sink { appState.value.userData.postcodeSearch = $0 }
            .store(in: &cancellables)
        
        appState
            .map(\.userData.postcodeSearch)
            .removeDuplicates()
            .assignWeak(to: \.postcodeSearchString, on: self)
            .store(in: &cancellables)
    }
    
    func setupBindToSearchStoreResult(with appState: Store<AppState>) {
        appState
            .map(\.userData.searchResult)
            .removeDuplicates()
            .assignWeak(to: \.storeSearchResult, on: self)
            .store(in: &cancellables)
        
        $storeSearchResult
            .compactMap { result in
                result?.value?.stores
            }
            .assignWeak(to: \.retailStores, on: self)
            .store(in: &cancellables)
    }
    
    func setupRetailStoreTypes() {
        $storeSearchResult
            .map { result in
                result?.value?.storeProductTypes
            }
            .assignWeak(to: \.retailStoreTypes, on: self)
            .store(in: &cancellables)
    }
    
    func setupSelectedRetailStoreTypesANDIsDeliverySelected() {
        Publishers.CombineLatest($selectedOrderMethod, $selectedRetailStoreTypes)
            .map { [weak self] selectedOrderMethod, selectedTypes -> ([RetailStore], RetailStoreOrderMethodName) in
                guard let self = self else { return ([], .delivery) }
                
                var returnStores = [RetailStore]()
                
                if selectedTypes.isEmpty == false {
                        var tempStores = [RetailStore]()
                        
                        for store in self.retailStores {
                            if let storeTypes = store.storeProductTypes {
                                if (storeTypes.contains {
                                    return selectedTypes.contains($0)
                                }) {
                                    tempStores.append(store)
                                }
                            }
                        }
                        
                        returnStores = tempStores
                    } else {
                        returnStores = self.retailStores
                    }
                
                return (returnStores, selectedOrderMethod)
            }
            .map { stores, selectedOrderMethod in
                guard stores.isEmpty == false else { return [] }
                
                var returnStores = [RetailStore]()
                
                returnStores = stores.filter { value in
                    if let orderMethods = value.orderMethods {
                        return orderMethods.keys.contains(selectedOrderMethod.rawValue)
                    }
                    return false
                }
                
                return returnStores
            }
            .assignWeak(to: \.shownRetailStores, on: self)
            .store(in: &cancellables)
    }
    
    func sendNotificationEmail() {
        // send email address to server
    }
}
