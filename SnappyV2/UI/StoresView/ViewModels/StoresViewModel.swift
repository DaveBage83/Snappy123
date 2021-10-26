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
    @Published var selectedOrderMethod: RetailStoreOrderMethodType = .delivery
    
    @Published var storeSearchResult: Loadable<RetailStoresSearch>
    @Published var retailStores = [RetailStore]()
    @Published var shownRetailStores = [RetailStore]()
    @Published var retailStoreTypes = [RetailStoreProductType]()
    @Published var filteredRetailStoreType: Int?
    
    @Published var shownOpenStores = [RetailStore]()
    @Published var showClosedStores = [RetailStore]()
    @Published var showPreorderStores = [RetailStore]()
    
    @Published var isFocused = false
    
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
        
        setupOrderMethodStatusSections()
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
                result.value?.stores
            }
            .assignWeak(to: \.retailStores, on: self)
            .store(in: &cancellables)
    }
    
    func setupRetailStoreTypes() {
        $storeSearchResult
            .map { result in
                result.value?.storeProductTypes ?? []
            }
            .assignWeak(to: \.retailStoreTypes, on: self)
            .store(in: &cancellables)
    }
    
    func setupSelectedRetailStoreTypesANDIsDeliverySelected() {
        Publishers.CombineLatest3($selectedOrderMethod, $filteredRetailStoreType, $retailStores)
            .map { selectedOrderMethod, selectedType, retailStores -> ([RetailStore], RetailStoreOrderMethodType) in
                
                var returnStores = [RetailStore]()
                
                if let unwrappedSelectedType = selectedType {
                        var tempStores = [RetailStore]()
                        
                        for store in retailStores {
                            if let storeTypes = store.storeProductTypes {
                                if storeTypes.contains(unwrappedSelectedType) {
                                    tempStores.append(store)
                                }
                            }
                        }
                        
                        returnStores = tempStores
                    } else {
                        returnStores = retailStores
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
    
    func setupOrderMethodStatusSections() {
        // setup Open Stores
        Publishers.CombineLatest($shownRetailStores, $selectedOrderMethod)
            .map { stores, selectedOrderMethod in
                return stores.filter { store in
                    return store.orderMethods?[selectedOrderMethod.rawValue]?.status == .open
                }
            }
            .assignWeak(to: \.shownOpenStores, on: self)
            .store(in: &cancellables)
        
        // setup Closed Stores
        Publishers.CombineLatest($shownRetailStores, $selectedOrderMethod)
            .map { stores, selectedOrderMethod in
                return stores.filter { store in
                    return store.orderMethods?[selectedOrderMethod.rawValue]?.status == .closed
                }
            }
            .assignWeak(to: \.showClosedStores, on: self)
            .store(in: &cancellables)
        
        // setup Preorder Stores
        Publishers.CombineLatest($shownRetailStores, $selectedOrderMethod)
            .map { stores, selectedOrderMethod in
                return stores.filter { store in
                    return store.orderMethods?[selectedOrderMethod.rawValue]?.status == .preorder
                }
            }
            .assignWeak(to: \.showPreorderStores, on: self)
            .store(in: &cancellables)
    }
    
    func sendNotificationEmail() {
        #warning("send email address to server once API exists")
    }
    
    func searchPostcode() {
        isFocused = false
        container.services.retailStoresService.searchRetailStores(search: loadableSubject(\.storeSearchResult), postcode: postcodeSearchString)
    }
    
    func selectFilteredRetailStoreType(id: Int) {
        filteredRetailStoreType = id
    }
    
    func clearFilteredRetailStoreType() {
        filteredRetailStoreType = nil
    }
}